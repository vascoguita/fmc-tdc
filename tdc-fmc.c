/*
 * FMC support for tdc driver 
 *
 * Copyright (C) 2012 CERN (http://www.cern.ch)
 * Author: Samuel Iglesias Gonsalvez <siglesias@igalia.com>
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
#include <linux/semaphore.h>

#include "spec.h"
#include "tdc.h"
#include "hw/tdc_regs.h"

static struct fmc_driver tdc_fmc_driver;
static struct workqueue_struct *tdc_workqueue;
DEFINE_MUTEX(fmc_dma_lock);
DECLARE_WAIT_QUEUE_HEAD(fmc_wait_dma);
static atomic_t fmc_dma_end;

static void tdc_fmc_gennum_setup_local_clock(struct spec_tdc *tdc, int freq)
{	
	unsigned int divot;
	unsigned int data;

	/* Setup local clock */
	divot = 800/freq - 1;
        data = 0xE001F00C + (divot << 4);
	/* FIXME: Now setup for 160 MHz directly. */
	writel(0x0001F04C, tdc->gn412x_regs + TDC_PCI_CLK_CSR);
}

static void tdc_fmc_fw_reset(struct spec_tdc *tdc)
{
	/* Reset FPGA. Assert ~RSTOUT33 and de-assert it. BAR 4.*/
	writel(0x00021040, tdc->gn412x_regs + TDC_PCI_SYS_CFG_SYSTEM);
	mdelay(10);
	writel(0x00025000, tdc->gn412x_regs + TDC_PCI_SYS_CFG_SYSTEM);
	/* Allow the FW to initialize the PLLs */
	mdelay(600);
}

static int tdc_fmc_check_lost_events(u32 curr_wr_ptr, u32 prev_wr_ptr, int *count)
{
	u32 dacapo_prev, dacapo_curr, dacapo_diff;
	
	dacapo_prev = prev_wr_ptr >> 12;
	dacapo_curr = curr_wr_ptr >> 12;
	curr_wr_ptr &= 0x0fff; /* Pick last 12 bits */
	prev_wr_ptr &= 0x0fff; /* Pick last 12 bits */
	dacapo_diff = dacapo_curr - dacapo_prev;

	switch(dacapo_diff) {

	case 1:
		if ((curr_wr_ptr - prev_wr_ptr) > 0) {
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

static void tdc_fmc_irq_work(struct work_struct *work)
{
	struct spec_tdc *tdc = container_of(work, struct spec_tdc, irq_work);
	u32 curr_wr_ptr, prev_wr_ptr;
	int ret, dacapo_flag, count, rd_ptr, chan;
	struct tdc_event *events, *tmp_data;

	events = kzalloc(TDC_EVENT_BUFFER_SIZE*sizeof(struct tdc_event), GFP_KERNEL);
	if(!events) {
		pr_err("error allocating memory for the events\n");
		return;
	}

	/* Setup DMA transfer. Only one process can do it */
	mutex_lock(&fmc_dma_lock);
	curr_wr_ptr = tdc_get_circular_buffer_wr_pointer(tdc);

	if(curr_wr_ptr == tdc->wr_pointer)
		goto dma_out; 	/* No new events happened */

	prev_wr_ptr = tdc->wr_pointer;
	ret = tdc_dma_setup(tdc, 0, (unsigned long)events,
			    TDC_EVENT_BUFFER_SIZE*sizeof(struct tdc_event));
	if (ret)
		goto dma_out;

	/* Start DMA transfer and wait for it */
	tdc_dma_start(tdc);

	wait_event(fmc_wait_dma, atomic_read(&fmc_dma_end));
	/* DMA happened */
	atomic_set(&fmc_dma_end, 0);
	/* Check the status of the DMA */
	if(readl(tdc->base + TDC_DMA_STAT_R) & (TDC_DMA_STAT_ERR | TDC_DMA_STAT_ABORT))
		goto dma_out;

	tdc->wr_pointer = curr_wr_ptr;

	/* Process the data */
	dacapo_flag = tdc_fmc_check_lost_events(curr_wr_ptr, prev_wr_ptr, &count);
	if (dacapo_flag) {
		pr_err("We have lost data\n");
		/* TODO: Notify it in some way to the user. Flag in ctrl block? */
	}

	/* Start reading in the oldest event */
	if(count == TDC_EVENT_BUFFER_SIZE)
		rd_ptr = curr_wr_ptr; /* The oldest is curr_wr_ptr */
	else
		rd_ptr = prev_wr_ptr; /* The oldest is prev_wr_ptr */
	
	for ( ; count > 0; count--) {
		tmp_data = &events[rd_ptr];
		/* Check which channel to deliver the data */
		chan = tmp_data->metadata & TDC_EVENT_CHANNEL_MASK; /* FIXME: mask to know the channel number */
		/* Add the DaCapo flag to notify the user */
		tdc->event[chan].dacapo_flag = dacapo_flag;

		/* Copy the data and notify the readers (ZIO trigger) */
		tdc->event[chan].data = *tmp_data;
		/* XXX: Flag to avoid the ZIO trigger to read always the same element
		 * Until we change to a mutex or a data buffer bigger than one.
		 */
		tdc->event[chan].read = 0;
		/* XXX: as it has only one element of data, maybe is better a mutex 
		 * instead of semaphore! 
		 */
		up(&tdc->event[chan].lock);
		rd_ptr = (rd_ptr + 1) % TDC_EVENT_BUFFER_SIZE;
	}

dma_out:
	mutex_unlock(&fmc_dma_lock);
	kfree(events);
}

irqreturn_t tdc_fmc_irq_handler(int irq, void *dev_id)
{
	struct fmc_device *fmc = dev_id;
	struct spec_dev *spec = fmc->carrier_data;
	struct spec_tdc *tdc = spec->sub_priv;
	u32 irq_code;

	/* Check the source of the interrupt */
	irq_code = readl(fmc->base + TDC_IRQ_CODE_R);
	
	/* Tstamp threshold or time threshold */
	if((irq_code & TDC_IRQ_TDC_TSTAMP) ||
	   (irq_code & TDC_IRQ_TDC_TIME_THRESH))
		queue_work(tdc_workqueue, &tdc->irq_work);

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
	fmc->op->irq_ack(fmc);
	return IRQ_HANDLED;
}

int tdc_fmc_probe(struct fmc_device *dev)
{
	struct spec_tdc *tdc;
	struct spec_dev *spec;
	int ret, i;

	if(strcmp(dev->carrier_name, "SPEC") != 0)
		return -ENODEV;

	ret = dev->op->reprogram(dev, &tdc_fmc_driver, "fmc/eva_tdc_for_v2.bin");
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
	tdc->fmc = dev;
	tdc->base = spec->remap[0]; // XXX: or fmc->base ?? 		/* BAR 0 */
	tdc->regs = tdc->base; 			/* BAR 0 */
	tdc->gn412x_regs = spec->remap[2]; 	/* BAR 4  */
	tdc->wr_pointer = 0;

	/* XXX: Not implemented yet. Do we needed it? */
#if 0
	/* Check if the device is DMA capable on 32 bits. */
	if (pci_set_dma_mask(spec->pdev, DMA_BIT_MASK(64)) < 0) {
                pr_err("error setting 64-bit DMA mask.\n");
		kfree(tdc);
		return -ENXIO;
        }
#endif
	for(i = 0; i < TDC_CHAN_NUMBER; i++)
		sema_init(&tdc->event[i].lock, 0);
	
	/* Setup the Gennum 412x local clock frequency */
	tdc_fmc_gennum_setup_local_clock(tdc, 160);
	/* Reset FPGA to load the firmware */
	tdc_fmc_fw_reset(tdc);
	/* Setup default config to ACAM chip */
	tdc_acam_set_default_config(tdc);
	/* Reset ACAM chip */
	tdc_acam_reset(tdc);
	/* Prepare the irq work */
	INIT_WORK(&tdc->irq_work, tdc_fmc_irq_work);
	/* Request the IRQ */
	dev->op->irq_request(dev, tdc_fmc_irq_handler, "spec-tdc", IRQF_SHARED);

	return tdc_zio_register_device(tdc);
}

int tdc_fmc_remove(struct fmc_device *dev)
{
	struct spec_dev *spec = dev->carrier_data;
	struct spec_tdc *tdc = spec->sub_priv;

	cancel_work_sync(&tdc->irq_work);
	/* XXX: It gives a kernel oops if I enabled it. Check it out */
	//flush_workqueue(tdc_workqueue);
	tdc->fmc->op->irq_free(tdc->fmc);
	tdc_zio_remove(tdc);
	kfree(tdc);
	return 0;
}


int tdc_fmc_init(void)
{
	tdc_workqueue = create_singlethread_workqueue(KBUILD_MODNAME);
	atomic_set(&fmc_dma_end, 0);
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


