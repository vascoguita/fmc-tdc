/*
 * FMC support for tdc driver
 *
 * Copyright (C) 2012 CERN (http://www.cern.ch)
 * Author: Samuel Iglesias Gonsalvez <siglesias@igalia.com>
 * Author: Miguel Angel Gomez Sexto <magomez@igalia.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * version 2 as published by the Free Software Foundation.
 */

#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt

#include <linux/delay.h>
#include <linux/workqueue.h>
#include <linux/mutex.h>
#include <linux/wait.h>
#include <linux/sched.h>
#include <linux/atomic.h>

#include <linux/zio.h>
#include <linux/zio-trigger.h>

#include "spec.h"
#include "tdc.h"
#include "hw/tdc_regs.h"

static struct fmc_driver tdc_fmc_driver;
static struct workqueue_struct *tdc_workqueue;
DEFINE_MUTEX(fmc_dma_lock);
DECLARE_WAIT_QUEUE_HEAD(fmc_wait_dma);
static atomic_t fmc_dma_end;

static struct fmc_gpio tdc_gpio = {
	//.carrier_name = "spec",
	.gpio = FMC_GPIO_IRQ(0),
	.mode = GPIOF_DIR_IN,
	.irqmode = IRQF_TRIGGER_RISING,
};

static void tdc_fmc_gennum_setup_local_clock(struct spec_tdc *tdc, int freq)
{
	unsigned int divot;
	unsigned int data;

	/* Setup local clock */
	divot = 800/freq - 1;
	data = 0xE001F00C + (divot << 4);
	writel(data, tdc->gn412x_regs + TDC_PCI_CLK_CSR);
}

static void tdc_fmc_fw_reset(struct spec_tdc *tdc)
{
	/* Reset FPGA. Assert ~RSTOUT33 and de-assert it. BAR 4.*/
	writel(0x00021040, tdc->gn412x_regs + TDC_PCI_SYS_CFG_SYSTEM);
	mdelay(10);
	writel(0x00025000, tdc->gn412x_regs + TDC_PCI_SYS_CFG_SYSTEM);
	/* Allow the FW to initialize the PLLs */
	mdelay(2000);
}

static int tdc_fmc_check_lost_events(u32 curr_wr_ptr, u32 prev_wr_ptr, int *count)
{
	u32 dacapo_prev, dacapo_curr;
	int dacapo_diff, ptr_diff = 0;

	dacapo_prev = prev_wr_ptr >> 12;
	dacapo_curr = curr_wr_ptr >> 12;
	curr_wr_ptr &= 0x00fff; /* Pick last 12 bits */
	curr_wr_ptr >>= 4;	/* Remove last 4 bits. */
	prev_wr_ptr &= 0x00fff; /* Pick last 12 bits */
	prev_wr_ptr >>= 4;	/* Remove last 4 bits. */
	dacapo_diff = dacapo_curr - dacapo_prev;

	switch(dacapo_diff) {

	case 1:
		ptr_diff = curr_wr_ptr - prev_wr_ptr;
		if (ptr_diff > 0) {
			*count = TDC_EVENT_BUFFER_SIZE;
			return 1; /* We lost data */
		}
		*count = curr_wr_ptr - prev_wr_ptr + TDC_EVENT_BUFFER_SIZE;
		break;
	case 0:
		/* We didn't lose data */
		*count = curr_wr_ptr - prev_wr_ptr;
		break;
	default:
		/* We lost data for sure. Notify to the user */
		*count = TDC_EVENT_BUFFER_SIZE;
		return 1;
	}

	return 0;
}

static inline int tdc_is_valid_pulse_width(struct tdc_event rising, struct tdc_event falling)
{
	uint64_t up, down;

	/* Convert the timestamp to picoseconds */
	up = rising.coarse_time * 8000000000 + rising.fine_time * 81;
	down = (falling.local_utc - rising.local_utc) * 1000000000000 +
		falling.coarse_time * 8000000000 + rising.fine_time * 81;
	/* Valid pulse width if it is higher than 100 ns */
	return (down - up > 100000);
}

static void tdc_fmc_irq_work(struct work_struct *work)
{
	struct spec_tdc *tdc = container_of(work, struct spec_tdc, irq_work);
	u32 curr_wr_ptr, prev_wr_ptr;
	int ret, dacapo_flag, count, rd_ptr, chan;
	struct tdc_event *events, *tmp_data;

	events = kzalloc(TDC_EVENT_BUFFER_SIZE*sizeof(struct tdc_event), GFP_KERNEL);
	if(!events) {
		dev_err(&tdc->fmc->dev, "error allocating memory for the events\n");
		return;
	}

	/* Setup DMA transfer. Only one process can do it */
	mutex_lock(&fmc_dma_lock);
	curr_wr_ptr = tdc_get_circular_buffer_wr_pointer(tdc);

	if(curr_wr_ptr == tdc->wr_pointer) {
		mutex_unlock(&fmc_dma_lock);
		goto dma_out;	/* No new events happened */
	}

	prev_wr_ptr = tdc->wr_pointer;
	ret = tdc_dma_setup(tdc, 0, (unsigned long)events,
			    TDC_EVENT_BUFFER_SIZE*sizeof(struct tdc_event));
	if (ret) {
		dev_err(&tdc->fmc->dev, "error in DMA setup\n");
		mutex_unlock(&fmc_dma_lock);
		goto dma_out;
	}

	/* Start DMA transfer and wait for it */
	tdc_dma_start(tdc);

	/* Wait for the end of DMA transfer. Timeout of a second to avoid locks */
	ret = wait_event_timeout(fmc_wait_dma, atomic_read(&fmc_dma_end), HZ);
	/* DMA happened */
	atomic_set(&fmc_dma_end, 0);

	/* In case of timeout, notify the user */
	if(!ret) {
		dev_err(&tdc->fmc->dev, "timeout in DMA transfer.\n");
		mutex_unlock(&fmc_dma_lock);
		goto dma_out;
	}

	/* Check the status of the DMA */
	ret = readl(tdc->base + TDC_DMA_STAT_R);
	if((ret & TDC_DMA_STAT_ERR) || (ret & TDC_DMA_STAT_ABORT)) {
		dev_err(&tdc->fmc->dev, "error in DMA transfer\n");
		mutex_unlock(&fmc_dma_lock);
		goto dma_out;
	}
	tdc->wr_pointer = curr_wr_ptr;
	mutex_unlock(&fmc_dma_lock);

	/* Process the data */
	dacapo_flag = tdc_fmc_check_lost_events(curr_wr_ptr, prev_wr_ptr, &count);

	/* Start reading in the oldest event */
	if(count == TDC_EVENT_BUFFER_SIZE)
		rd_ptr = (curr_wr_ptr >> 4) & 0x000ff; /* The oldest is curr_wr_ptr */
	else
		rd_ptr = (prev_wr_ptr >> 4) & 0x000ff; /* The oldest is prev_wr_ptr */

	for ( ; count > 0; count--) {
		tmp_data = &events[rd_ptr];
		/* Check which channel to deliver the data */
		chan = tmp_data->metadata & TDC_EVENT_CHANNEL_MASK;
		/* Add the DaCapo flag to notify the user */
		tdc->event[chan].dacapo_flag = dacapo_flag;
		/* Check if the event is due to rising edge or falling edge */
		if (tmp_data->metadata & TDC_EVENT_SLOPE_MASK)
			/* Copy the data as it is a rising edge one */
			tdc->event[chan].data = *tmp_data;
		else {

			/* Check pulse width using the falling edge event */
			if(tdc_is_valid_pulse_width(tdc->event[chan].data,
						    *tmp_data)) {
				/* Valid pulse width -> Fire ZIO trigger */
				zio_fire_trigger(tdc->zdev->cset[chan].ti);
			}
		}
		rd_ptr = (rd_ptr + 1) % TDC_EVENT_BUFFER_SIZE;
	}

dma_out:
	kfree(events);
}

irqreturn_t tdc_fmc_irq_handler(int irq, void *dev_id)
{
	struct fmc_device *fmc = dev_id;
	struct spec_dev *spec = fmc->carrier_data;
	struct spec_tdc *tdc = spec->sub_priv;
	u32 irq_code;

	/* Check the source of the interrupt */
	irq_code = readl(fmc->base + TDC_IRQ_STATUS_REG);

	/* Tstamp threshold or time threshold */
	if((irq_code & TDC_IRQ_TDC_TSTAMP) ||
	   (irq_code & TDC_IRQ_TDC_TIME_THRESH)) {
		queue_work(tdc_workqueue, &tdc->irq_work);
	}

	/* DMA interrupt */
	if((irq_code & TDC_IRQ_GNUM_CORE_0) ||
	   (irq_code & TDC_IRQ_GNUM_CORE_1)) {
		dma_sync_single_for_cpu(&spec->pdev->dev, tdc->rx_dma,
					TDC_EVENT_BUFFER_SIZE*sizeof(struct tdc_event),
					DMA_FROM_DEVICE);
		dma_unmap_single(&spec->pdev->dev, tdc->rx_dma,
				 TDC_EVENT_BUFFER_SIZE*sizeof(struct tdc_event),
				 DMA_FROM_DEVICE);
		/* Wake up the threads waiting for the DMA transfer */
		atomic_set(&fmc_dma_end, 1);
		wake_up(&fmc_wait_dma);
	}
	/* Acknowledge the IRQ and exit */
	writel(irq_code, fmc->base + TDC_IRQ_STATUS_REG);
	fmc->op->irq_ack(fmc);
	return IRQ_HANDLED;
}

static int tdc_fmc_get_device_lun(struct fmc_device *dev)
{
	struct spec_dev *spec;
	struct pci_dev *pdev;
	int i;

	spec = dev->carrier_data;
	pdev = spec->pdev;

	for (i = 0; i < nlun; i++) {
		if (PCI_SLOT(pdev->devfn) == slot[i] &&
		    pdev->bus->number == bus[i]) {
			pr_info("Matched LUN %d for device in bus %d and slot %d\n",
				lun[i], bus[i], slot[i]);
			return lun[i];
		}
	}

	pr_err("No LUN found for device in bus %d and slot %d\n",
	       pdev->bus->number, PCI_SLOT(pdev->devfn));
	return -ENODEV;
}

int tdc_fmc_probe(struct fmc_device *dev)
{
	struct spec_tdc *tdc;
	struct spec_dev *spec;
	int ret, dev_lun;
	char gateware_path[128];

	if(strcmp(dev->carrier_name, "SPEC") != 0)
		return -ENODEV;

	dev_lun = tdc_fmc_get_device_lun(dev);
	if (dev_lun < 0)
		return dev_lun;

	sprintf(gateware_path, "fmc/%s", gateware);
	pr_info("Using gateware %s\n", gateware_path);
	ret = dev->op->reprogram(dev, &tdc_fmc_driver, gateware_path);
	if (ret < 0) {
		pr_err("%s: error reprogramming the FPGA\n", __func__);
		return -ENODEV;
	}

	tdc = kzalloc(sizeof(struct spec_tdc), GFP_KERNEL);
	if (!tdc) {
		pr_err("%s: can't allocate device\n", __func__);
		return -ENOMEM;
	}

	/* Initialize structures */
	spec = dev->carrier_data;
	tdc->spec = spec;
	spec->sub_priv = tdc;
	tdc->lun = dev_lun;
	tdc->fmc = dev;
	tdc->base = dev->base;		   /* BAR 0 */
	tdc->gn412x_regs = spec->remap[2]; /* BAR 4  */
	tdc->wr_pointer = 0;

	/* Setup the Gennum 412x local clock frequency */
	tdc_fmc_gennum_setup_local_clock(tdc, 160);
	/* Reset FPGA to load the firmware */
	tdc_fmc_fw_reset(tdc);
	/* Setup default config to ACAM chip */
	tdc_acam_set_default_config(tdc);
	/* Reset ACAM chip */
	tdc_acam_reset(tdc);
	/* Initialice UTC time */
	tdc_set_local_utc_time(tdc);
	/* Initialize DAC */
	tdc_set_dac_word(tdc, 0xA8F5);
	/* Initialize timestamp threshold */
	tdc_set_irq_tstamp_thresh(tdc, DEFAULT_TSTAMP_THRESH);
	/* Initialize time threshold */
	tdc_set_irq_time_thresh(tdc, DEFAULT_TIME_THRESH);
	/* Prepare the irq work */
	INIT_WORK(&tdc->irq_work, tdc_fmc_irq_work);

	/* Setup GPIO to have IRQ */
	dev->op->gpio_config(dev, &tdc_gpio, 1);
	/* Clear IRQ */
	writel(0xF, tdc->base + TDC_IRQ_STATUS_REG);
	/* Request the IRQ */
	dev->op->irq_request(dev, tdc_fmc_irq_handler, "spec-tdc", IRQF_SHARED);
	/* Enable IRQ */
	writel(0xF, tdc->base + TDC_IRQ_ENABLE_REG);

	return tdc_zio_register_device(tdc);
}

int tdc_fmc_remove(struct fmc_device *dev)
{
	struct spec_dev *spec = dev->carrier_data;
	struct spec_tdc *tdc = spec->sub_priv;

	cancel_work_sync(&tdc->irq_work);
	tdc->fmc->op->irq_free(tdc->fmc);
	tdc_zio_remove(tdc);
	kfree(tdc);
	return 0;
}


int tdc_fmc_init(void)
{
	tdc_workqueue = create_singlethread_workqueue(KBUILD_MODNAME);
	atomic_set(&fmc_dma_end, 0);
	tdc_fmc_driver.version = FMC_VERSION;
	tdc_fmc_driver.probe = tdc_fmc_probe;
	tdc_fmc_driver.remove = tdc_fmc_remove;
	fmc_driver_register(&tdc_fmc_driver);
	return 0;
}

void tdc_fmc_exit(void)
{
	destroy_workqueue(tdc_workqueue);
	fmc_driver_unregister(&tdc_fmc_driver);
}
