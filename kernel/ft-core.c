/*
 * Main fmc-tdc driver module.
 *
 * Copyright (C) 2012-2013 CERN (www.cern.ch)
 * Author: Tomasz Wlostowski <tomasz.wlostowski@cern.ch>
 * Author: Alessandro Rubini <rubini@gnudd.com>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/interrupt.h>
#include <linux/spinlock.h>
#include <linux/bitops.h>
#include <linux/delay.h>
#include <linux/slab.h>
#include <linux/init.h>
#include <linux/list.h>
#include <linux/io.h>

#include <linux/fmc.h>
#include <linux/fmc-sdb.h>

#include <linux/zio.h>
#include <linux/zio-trigger.h>

#include "fmc-tdc.h"
#include "hw/tdc_regs.h"

static int dma_buf_ddr_burst_size_default = 16;
module_param_named(dma_buf_ddr_burst_size, dma_buf_ddr_burst_size_default,
		   int, 0444);
MODULE_PARM_DESC(dma_buf_ddr_burst_size,
		 "DDR size coalesing timeout (default: 16 timestamps).");

static int test_data_period = 0;
module_param_named(test_data_period, test_data_period, int, 0444);
MODULE_PARM_DESC(test_data_period,
		 "It sets how many fake timestamps to generate every seconds on the first channel, 0 to disable (default: 0)");

static int ft_verbose;
module_param_named(verbose, ft_verbose, int, 0444);
MODULE_PARM_DESC(verbose, "Print a lot of debugging messages.");

static struct fmc_driver ft_drv;	/* forward declaration */
FMC_PARAM_BUSID(ft_drv);
FMC_PARAM_GATEWARE(ft_drv);

static char bitstream_name[32];
struct workqueue_struct *ft_workqueue;


static int ft_reset_core(struct fmctdc_dev *ft)
{
	uint32_t val, shift = 0, addr;

	if (!strcmp(ft->fmc->carrier_name, "SVEC")) {
		shift = 1;
		addr = TDC_SVEC_CARRIER_BASE;
	} else {
		addr = TDC_SPEC_CARRIER_BASE;
	}
	addr += TDC_REG_CARRIER_RST;

	dev_dbg(&ft->fmc->dev, "Un-resetting FMCs...\n");

	/* Reset - reset bits are shifted by 1 */
	ft_iowrite(ft, ~(1 << (ft->fmc->slot_id + shift)), addr);

	udelay(5000);

	val = ft_ioread(ft, addr);
	val |= (1 << (ft->fmc->slot_id + shift));

	/* Un-Reset */
	ft_iowrite(ft, val, addr);

	return 0;
}

static int ft_init_channel(struct fmctdc_dev *ft, int channel)
{
	return 0;
}


int ft_enable_termination(struct fmctdc_dev *ft, int channel, int enable)
{
	struct ft_channel_state *st;
	uint32_t ien;

	if (channel < FT_CH_1 || channel > FT_NUM_CHANNELS)
		return -EINVAL;

	st = &ft->channels[channel - 1];

	ien = ft_readl(ft, TDC_REG_INPUT_ENABLE);

	if (enable)
		ien |= (1 << (channel - 1));
	else
		ien &= ~(1 << (channel - 1));

	ft_writel(ft, ien, TDC_REG_INPUT_ENABLE);

	if (enable)
		set_bit(FT_FLAG_CH_TERMINATED, &st->flags);
	else
		clear_bit(FT_FLAG_CH_TERMINATED, &st->flags);

	return 0;
}

static void ft_buffer_burst_size_set(struct fmctdc_dev *ft,
				     unsigned int chan,
				     uint32_t size)
{
	const uint32_t base = ft->ft_dma_base + (0x40 * chan);
	uint32_t tmp;

	tmp = ft_ioread(ft, base + TDC_BUF_REG_CSR);
	tmp &= ~TDC_BUF_CSR_BURST_SIZE_MASK;
	tmp |= TDC_BUF_CSR_BURST_SIZE_W(size);
	ft_iowrite(ft, tmp, base + TDC_BUF_REG_CSR);
}

static void ft_buffer_burst_enable(struct fmctdc_dev *ft,
				   unsigned int chan)
{
	const uint32_t base = ft->ft_dma_base + (0x40 * chan);
	uint32_t tmp;

	tmp = ft_ioread(ft, base + TDC_BUF_REG_CSR);
	tmp |= TDC_BUF_CSR_ENABLE;
	ft_iowrite(ft, tmp, base + TDC_BUF_REG_CSR);

}

static void ft_buffer_burst_disable(struct fmctdc_dev *ft,
				    unsigned int chan)
{
	const uint32_t base = ft->ft_dma_base + (0x40 * chan);
	uint32_t tmp;

	tmp = ft_ioread(ft, base + TDC_BUF_REG_CSR);
	tmp &= ~TDC_BUF_CSR_ENABLE;
	ft_iowrite(ft, tmp, base + TDC_BUF_REG_CSR);

}


/**
 * It configure the double buffers for a given channel
 * @param[in] ft FmcTdc device instance
 * @param[in] channel range [0, N-1]
 */
static void ft_buffer_init(struct fmctdc_dev *ft, int channel)
{
	const uint32_t base = ft->ft_dma_base + (0x40 * channel);
	uint32_t val;
	struct ft_channel_state *st;

	if (ft->mode != FT_ACQ_TYPE_DMA)
		return;

	st = &ft->channels[channel];

	st->buf_size = TDC_CHANNEL_BUFFER_SIZE_BYTES / sizeof(struct ft_hw_timestamp);
	st->active_buffer = 0;

	ft_buffer_burst_disable(ft, channel);

	/* Buffer 1 */
	st->buf_addr[0] = TDC_CHANNEL_BUFFER_SIZE_BYTES * (2 * channel);
	ft_iowrite(ft, st->buf_addr[0], base + TDC_BUF_REG_CUR_BASE);
	val = (st->buf_size << TDC_BUF_CUR_SIZE_SIZE_SHIFT);
	val |= TDC_BUF_CUR_SIZE_VALID;
	ft_iowrite(ft, val, base + TDC_BUF_REG_CUR_SIZE);

	/* Buffer 2 */
	st->buf_addr[1] = TDC_CHANNEL_BUFFER_SIZE_BYTES * (2 * channel + 1);
	ft_iowrite(ft, st->buf_addr[1], base + TDC_BUF_REG_NEXT_BASE);
	val = (st->buf_size << TDC_BUF_NEXT_SIZE_SIZE_SHIFT);
	val |= TDC_BUF_NEXT_SIZE_VALID;
	ft_iowrite(ft, val, base + TDC_BUF_REG_NEXT_SIZE);

	ft_buffer_burst_size_set(ft, channel, dma_buf_ddr_burst_size_default);
	ft_buffer_burst_enable(ft, channel);

	dev_info(&ft->fmc->dev,
		 "Config channel %d: base = 0x%x buf[0] = 0x%08x, buf[1] = 0x%08x, %d timestamps per buffer\n",
		 channel, base, st->buf_addr[0], st->buf_addr[1],
		 st->buf_size);
	dev_info(&ft->fmc->dev, "CSR: %08x\n",
		 ft_ioread(ft, base + TDC_BUF_REG_CSR));
}


/**
 * It clears the double buffers configuration for a given channel
 * @param[in] ft FmcTdc device instance
 * @param[in] channel range [0, N-1]
 */
static void ft_buffer_exit(struct fmctdc_dev *ft, int channel)
{
	const uint32_t base = ft->ft_dma_base + (0x40 * channel);

	if (ft->mode != FT_ACQ_TYPE_DMA)
		return;

	ft_iowrite(ft, 0, base + TDC_BUF_REG_CUR_SIZE);
	ft_iowrite(ft, 0, base + TDC_BUF_REG_NEXT_SIZE);
	ft_buffer_burst_disable(ft, channel);
}

static int ft_channels_init(struct fmctdc_dev *ft)
{
	int i, ret;

	for (i = FT_CH_1; i <= FT_NUM_CHANNELS; i++) {
		ret = ft_init_channel(ft, i);
		if (ret < 0)
			return ret;
		/* termination is off by default */
		ft_enable_termination(ft, i, 0);
	}
	return 0;
}

static void ft_channels_exit(struct fmctdc_dev *ft)
{

}

struct ft_modlist {
	char *name;

	int (*init)(struct fmctdc_dev *ft);
	void (*exit)(struct fmctdc_dev *ft);
};

static struct ft_modlist init_subsystems[] = {
	{"acam-tdc", ft_acam_init, ft_acam_exit},
	{"onewire", ft_onewire_init, ft_onewire_exit},
	{"time", ft_time_init, ft_time_exit},
	{"channels", ft_channels_init, ft_channels_exit},
	{"zio", ft_zio_init, ft_zio_exit}
};


/**
 * It maps a host buffer and configure the DMA engine
 * @ft FmcTdc device instance
 */
dma_addr_t gn4124_dma_map(struct fmctdc_dev *ft, uint32_t devmem, void *hostmem, int len)
{
	struct gncore_dma_item item;
	dma_addr_t dma_handle;

	dma_handle = dma_map_single(ft->fmc->hwdev, hostmem, len, DMA_TO_DEVICE);
	if (dma_mapping_error(ft->fmc->hwdev, dma_handle)) {
		dev_err(ft->fmc->hwdev, "Failed to map DMA buffer\n");
		return dma_handle;
	}

	item.start_addr = devmem;
	item.dma_addr_h = dma_handle >> 32;
	item.dma_addr_l = dma_handle & 0xFFFFFFFFULL;
	item.dma_len = len;
	item.next_addr_h = 0;
	item.next_addr_l = 0;
	item.attribute = 0;

	gn4124_dma_config(ft, &item);

	return dma_handle;
}


/**
 * It unmap a given DMA buffer
 * @ft FmcTdc device instance
 * @dma_handle DMA buffer
 * @len buffer length in byte
 */
void gn4124_dma_unmap(struct fmctdc_dev *ft, dma_addr_t dma_handle, int len)
{
	dma_unmap_single(ft->fmc->hwdev, dma_handle, len, DMA_FROM_DEVICE);
}

/**
 * It executes a blocking DMA transfer. When this function return, the DMA
 * transfer is complete
 * @ft FmcTdc device instance
 * @devmem device memory offset from which start the DMA transfer
 * @hostmem host memory where to store data
 * @len buffer length in byte
 */
void gn4124_dma_read(struct fmctdc_dev *ft, uint32_t devmem, void *hostmem, int len)
{
	dma_addr_t dma_handle;

	dma_handle = gn4124_dma_map(ft, devmem, hostmem, len);
	if (dma_mapping_error(ft->fmc->hwdev, dma_handle))
		return;

	gn4124_dma_start(ft);
	gn4124_dma_wait_done(ft, 10000);
	gn4124_dma_unmap(ft, dma_handle, len);
}

/**
 * It performs a blocking DMA write on device memory. This is used only for
 * testing purposes
 */
void gn4124_dma_write(struct fmctdc_dev *ft, uint32_t dst, void *src, int len)
{
	struct gncore_dma_item item;
	dma_addr_t dma_handle;

	dma_handle = dma_map_single(ft->fmc->hwdev, src, len, DMA_TO_DEVICE);
	if (dma_mapping_error(ft->fmc->hwdev, dma_handle)) {
		dev_err(ft->fmc->hwdev, "Can't map buffer for DMA\n");
		return;
	}

	dev_dbg(&ft->fmc->dev, "0x%llx %d\n", dma_handle, len);

	item.start_addr = dst;
	item.dma_addr_h = dma_handle >> 32;
	item.dma_addr_l = dma_handle & 0xFFFFFFFFULL;
	item.dma_len = len;
	item.next_addr_h = 0;
	item.next_addr_l = 0;
	item.attribute = GENNUM_DMA_ATTR_DIR;
	gn4124_dma_config(ft, &item);
	gn4124_dma_start(ft);
	gn4124_dma_wait_done(ft, 10000);

	dma_sync_single_for_device(ft->fmc->hwdev, dma_handle, len, DMA_TO_DEVICE);
	dma_unmap_single(ft->fmc->hwdev, dma_handle, len, DMA_TO_DEVICE);
}

static int gn4124_dma_sg(struct fmctdc_dev *ft,
			 uint32_t offset, void *buf, int size,
			 enum dma_data_direction dir)
{
	struct gncore_dma_item *item; /* linked-list descriptor */
	struct sg_table sgt;
	dma_addr_t item_pool; /* DMA mem for linked-list descriptors */
	dma_addr_t item_dma; /* temporary pointer */
	uint32_t devmem = offset;
	struct scatterlist *sg;
	enum gncore_dma_status status;
	int mapbytes = 0;
	int byteleft = size;
	int ret = 0;
	int n = (size / PAGE_SIZE) + (size % PAGE_SIZE ? 1 : 0);
	int i;
	void *bufp;

	item = kmalloc(sizeof(struct gncore_dma_item) * (n + 1), GFP_KERNEL);
	if (!item)
		return -ENOMEM;

	item_pool = dma_map_single(ft->fmc->hwdev, item,
				   sizeof(struct gncore_dma_item) * (n + 1),
				   DMA_TO_DEVICE);
	if (dma_mapping_error(ft->fmc->hwdev, item_pool)) {
		ret = -EINVAL;
		goto out_dma_item;
	}

	ret = sg_alloc_table(&sgt, n, GFP_KERNEL);
	if (ret) {
		ret = -ENOMEM;
		goto out_sg_alloc;
	}

	bufp = buf;
	for_each_sg(sgt.sgl, sg, sgt.nents, i) {
		if (byteleft < (PAGE_SIZE - offset_in_page(bufp)))
			mapbytes = byteleft;
		else
			mapbytes = PAGE_SIZE - offset_in_page(bufp);

		sg_set_buf(sg, bufp, mapbytes);
		byteleft -= mapbytes;
		bufp += mapbytes;
	}

	ret = dma_map_sg(ft->fmc->hwdev, sgt.sgl, sgt.nents, dir);
	if (ret < 0)
		goto out_map_sg;

	item_dma = item_pool;
	for_each_sg(sgt.sgl, sg, sgt.nents, i) {
		item_dma += sizeof(struct gncore_dma_item);

		item[i].start_addr = devmem;
		item[i].dma_addr_h = sg_dma_address(sg) >> 32;
		item[i].dma_addr_l = sg_dma_address(sg) & 0xFFFFFFFFULL;
		item[i].dma_len = sg_dma_len(sg);
		item[i].next_addr_h = item_dma >> 32;
		item[i].next_addr_l = item_dma & 0xFFFFFFFFULL;
		item[i].attribute = 0;

		if (dir == DMA_TO_DEVICE)
			item[i].attribute = GENNUM_DMA_ATTR_DIR;
		if (!sg_is_last(sg))
			item[i].attribute |= GENNUM_DMA_ATTR_MORE;

		devmem += sg_dma_len(sg);

		pr_debug("item[%p]: sa %08x ha %08x %08x len %d next %08x %08x attr %x\n",
			 (void*) ( item_pool + sizeof(struct gncore_dma_item)*(&item[i]-&item[0]) ),
			 item[i].start_addr,
			 item[i].dma_addr_h,
			 item[i].dma_addr_l,
			 item[i].dma_len,
			 item[i].next_addr_h,
			 item[i].next_addr_l,
			 item[i].attribute );
	}

	gn4124_dma_config(ft, &item[0]);
	dma_sync_single_for_device(ft->fmc->hwdev, item_pool,
				   sizeof(struct gncore_dma_item) * sgt.nents,
				   DMA_TO_DEVICE);

	gn4124_dma_start(ft);
	status = gn4124_dma_wait_done(ft, 500);
	if (status == GENNUM_DMA_STA_ERROR) {
		dev_err(ft->fmc->hwdev, "DMA transfer error\n");
		ret = -EIO;
	} else if (status == GENNUM_DMA_STA_ABORT) {
		dev_err(ft->fmc->hwdev,
			"DMA transfer timeout or manually aborted\n");
		ret = -EIO;
	}

	dma_unmap_sg(ft->fmc->hwdev, sgt.sgl, sgt.nents, dir);
out_map_sg:
	sg_free_table(&sgt);
out_sg_alloc:
	dma_unmap_single(ft->fmc->hwdev, item_pool,
			 sizeof(struct gncore_dma_item) * n,
			 DMA_TO_DEVICE);
out_dma_item:
	kfree(item);

	return (ret < 0 ? ret : 0);
}


/**
 * It performs a DMA test
 * @ft FmcTDc instance
 * @buf_size number of byte to transfer
 * @use_sg 1 if you want to use scatterlists, 0 to do a single transfer
 *
 * It writes on the device memory a known pattern, then it reads it back
 * and validate.
 *
 * The code will always prepare the SG table, but it will use it only
 * when asked.
 *
 * Return: 0 on success, otherwise a negative error number
 */
int test_dma(struct fmctdc_dev *ft, unsigned int buf_size, unsigned int use_sg)
{
	uint8_t *buf1, *buf2;
	int i, ret = 0;
	uint32_t eic;

	dev_dbg(&ft->fmc->dev, "Test DMA - scatterlist: %d\n", use_sg);

	/* Disable DMA interrupts, we do active waits here */
	eic = ft_ioread(ft, ft->ft_dma_eic_base + DMA_EIC_REG_EIC_IMR);
	ft_iowrite(ft, eic, ft->ft_dma_eic_base + DMA_EIC_REG_EIC_IDR);

	/* Write buffer one */
	buf1 = kzalloc(buf_size, GFP_KERNEL);
	if (!buf1) {
		ret = -ENOMEM;
		goto out_buf1;
	}

	for (i = 0; i < buf_size; i++)
		buf1[i] = i * 31011 + 12312;

	if (use_sg)
		ret = gn4124_dma_sg(ft, 0, buf1, buf_size, DMA_TO_DEVICE);
	else
		gn4124_dma_write(ft, 0, buf1, buf_size);

	if (ret < 0)
		goto out_fail_w;

	/* Read buffer two */
	buf2 = kzalloc(buf_size, GFP_KERNEL);
	if (!buf2)
		goto out_buf2;

	if (use_sg)
		ret = gn4124_dma_sg(ft, 0, buf2, buf_size, DMA_FROM_DEVICE);
	else
		gn4124_dma_read(ft, 0, buf2, buf_size);

	if (ret < 0)
		goto out_fail_r;

	ret = 0;
	/* Validate */
	for (i = 0; i < buf_size; i++) {
		dev_vdbg(&ft->fmc->dev, "%d 0x%02x 0x%02x\n",
			i, buf1[i], buf2[i]);
		if (buf1[i] != buf2[i]) {
			dev_err(&ft->fmc->dev, "ERROR %d 0x%02x 0x%02x\n",
				i, buf1[i], buf2[i]);
			ret = -EINVAL;
		}
	}

out_fail_r:
	kfree(buf2);
out_buf2:
out_fail_w:
	kfree(buf1);
out_buf1:
	/*
	 * clear any pending interrupt befre re-enabling, we have just
	 * generated and handled them here in this function
	 */
	ft_iowrite(ft, 0xFFFFFFFF, ft->ft_dma_eic_base + DMA_EIC_REG_EIC_ISR);
	ft_iowrite(ft, eic, ft->ft_dma_eic_base + DMA_EIC_REG_EIC_IER);

	dev_dbg(&ft->fmc->dev, "Test DMA complete, status: %d\n", ret);
	return ret;
}

/**
 * It configures the test data
 * @chan channel number [0, 4]
 * @period period in 125Mhz ticks (125000000 -1 = 1Hz)
 * @enable enable or disable
 */
void ft_test_data(struct fmctdc_dev *ft,
		  unsigned int chan,
		  unsigned int period,
		  bool enable)
{
	uint32_t tmp = 0;

	ft_writel(ft, 0, TDC_REG_FAKE_TS_CSR);

	if (!enable)
		return;

	if (chan >= ft->zdev->n_cset) {
		dev_err(&ft->fmc->dev, "%s Invalid channel %d\n",
			__func__, chan);
		return;
	}

	if (period == 0) {
		dev_err(&ft->fmc->dev, "%s Invalid period %d\n",
			__func__, period);
		return;
	}

	tmp |= TDC_FAKE_TS_EN;
	tmp |= ((chan << TDC_FAKE_TS_CHAN_SHIFT) & TDC_FAKE_TS_CHAN_MASK);
	tmp |= ((period << TDC_FAKE_TS_PERIOD_SHIFT) & TDC_FAKE_TS_PERIOD_MASK);
	ft_writel(ft, tmp, TDC_REG_FAKE_TS_CSR);

	dev_warn(&ft->fmc->dev,
		 "Channel 0 is running in test mode 0x%x\n",
		 tmp);
}

/* probe and remove are called by the FMC bus core */
int ft_probe(struct fmc_device *fmc)
{
	struct ft_modlist *m;
	struct fmctdc_dev *ft;
	struct device *dev = &fmc->dev;
	char *fwname;
	int i, index, ret, ord;
	uint32_t stat;

	ft = kzalloc(sizeof(struct fmctdc_dev), GFP_KERNEL);
	if (!ft)
		return -ENOMEM;

	index = fmc_validate(fmc, &ft_drv);
	if (index < 0) {
		dev_info(dev, "not using \"%s\" according to modparam\n",
			 KBUILD_MODNAME);
		return -ENODEV;
	}

	fmc->mezzanine_data = ft;
	ft->fmc = fmc;
	ft->verbose = ft_verbose;

	/* apply carrier-specific hacks and workarounds */
	if (!strcmp(ft->fmc->carrier_name, "SVEC")) {
		sprintf(bitstream_name, FT_GATEWARE_SVEC);
	} else if (!strcmp(fmc->carrier_name, "SPEC")) {
		sprintf(bitstream_name, FT_GATEWARE_SPEC);
	} else {
		dev_err(dev, "unsupported carrier '%s'\n", fmc->carrier_name);
		return -ENODEV;
	}

	/*
	 * If the carrier is still using the golden bitstream or the user is
	 * asking for a particular one, then program our bistream, otherwise
	 * we already have our bitstream
	 */
	if (fmc->flags & FMC_DEVICE_HAS_GOLDEN || ft_drv.gw_n) {
		if (ft_drv.gw_n)
			fwname = ""; /* reprogram will pick from module parameter */
		else
			fwname = bitstream_name;
		dev_info(fmc->hwdev, "Gateware (%s)\n", fwname);

		ret = fmc_reprogram(fmc, &ft_drv, fwname, -1);
		if (ret < 0) {
			dev_err(fmc->hwdev, "write firmware \"%s\": error %i\n",
				fwname, ret);
			if (ret == -ESRCH) {
				dev_err(dev, "no gateware at index %i\n",
					index);
				return -ENODEV;
			}
			return ret;	/* other error: pass over */
		}

		dev_dbg(dev, "Gateware successfully loaded\n");
	} else {
		dev_info(fmc->hwdev,
			 "Gateware already there. Set the \"gateware\" parameter to overwrite the current gateware\n");
	}

	ret = ft_reset_core(ft);
	if (ret < 0)
		return ret;

	/* Now that the PLL is locked, we can read the SDB info */
	ret = fmc_scan_sdb_tree(fmc, 0);
	if (ret < 0 && ret != -EBUSY) {
		dev_err(dev,
			"%s: no SDB in the bitstream. Are you sure you've provided the correct one?\n",
			KBUILD_MODNAME);
		return ret;
	}

	/* Now use SDB to find the base addresses */
	ord = fmc->slot_id;
	ft->ft_core_base = fmc_sdb_find_nth_device(fmc->sdb, 0xce42, 0x604,
						   &ord, NULL);

	ft->ft_irq_base = ft->ft_core_base + TDC_MEZZ_EIC_OFFSET;
	ft->ft_owregs_base = ft->ft_core_base + TDC_MEZZ_ONEWIRE_OFFSET;
	ft->ft_fifo_base = ft->ft_core_base + TDC_MEZZ_MEM_FIFO_OFFSET;
	ft->ft_dma_base = ft->ft_core_base + TDC_MEZZ_MEM_DMA_OFFSET;
	ft->ft_dma_eic_base = fmc_sdb_find_nth_device(fmc->sdb, 0xce42, 0x12000661,
						      &ord, NULL);

	if (ft_verbose) {
		dev_info(dev,
			 "Base addrs: core 0x%x, irq 0x%x, 1wire 0x%x, buffer/FIFO 0x%X, buffer/DMA 0x%x\n",
			 ft->ft_core_base, ft->ft_irq_base, ft->ft_owregs_base,
			 ft->ft_fifo_base, ft->ft_dma_base);
	}

	/*
	 * Even if the HDL supports both acquisition mechanism at the same
	 * time, here for the time being we don't.
	 */
	stat = ft_ioread(ft, ft->ft_core_base + TDC_REG_STAT);

	if (dma_set_mask(ft->fmc->hwdev, DMA_BIT_MASK(64)) ||
	    dma_set_mask(ft->fmc->hwdev, DMA_BIT_MASK(32))) {
		dev_warn(ft->fmc->hwdev, "No suitable DMA available\n");
		stat &= ~TDC_STAT_DMA;
	}

	if (stat & TDC_STAT_DMA) {
		ft->mode = FT_ACQ_TYPE_DMA;
	} else if (stat & TDC_STAT_FIFO) {
		ft->mode = FT_ACQ_TYPE_FIFO;
	} else {
		dev_err(dev,
			"Unsupported acquisition type, tdc_reg_stat 0x%x\n",
			stat);
		return -ENODEV;
	}

	spin_lock_init(&ft->lock);

	/* Retrieve calibration from the eeprom, and validate */
	ret = ft_handle_eeprom_calibration(ft);
	if (ret < 0)
		return ret;

	/* init all subsystems */
	for (i = 0, m = init_subsystems; i < ARRAY_SIZE(init_subsystems);
	     i++, m++) {
		ret = m->init(ft);
		if (ret < 0)
			goto err;
	}

	ft_test_data(ft, 0, test_data_period, !!test_data_period);

	ret = ft_irq_init(ft);
	if (ret < 0)
		goto err;

	for (i = 0; i < FT_NUM_CHANNELS; i++)
		ft_buffer_init(ft, i);
	ft_writel(ft, TDC_INPUT_ENABLE_FLAG, TDC_REG_INPUT_ENABLE);
	ft_writel(ft, TDC_CTRL_EN_ACQ, TDC_REG_CTRL);

	ft->initialized = 1;

	/* Pin the carrier */
	if (!try_module_get(fmc->owner))
		goto out_mod;

	return 0;

out_mod:
	ft_irq_exit(ft);
err:
	while (--m, --i >= 0)
		if (m->exit)
			m->exit(ft);
	return ret;
}

int ft_remove(struct fmc_device *fmc)
{
	struct ft_modlist *m;
	struct fmctdc_dev *ft = fmc->mezzanine_data;
	int i;

	if (!ft->initialized)
		return 0;	/* No init, no exit */

	ft_writel(ft, TDC_CTRL_DIS_ACQ, TDC_REG_CTRL);
	ft_writel(ft, 0, TDC_REG_INPUT_ENABLE);
	for (i = 0; i < FT_NUM_CHANNELS; i++)
		ft_buffer_exit(ft, i);

	ft_irq_exit(ft);

	i = ARRAY_SIZE(init_subsystems);
	while (--i >= 0) {
		m = init_subsystems + i;
		if (m->exit)
			m->exit(ft);
	}

	/* Release the carrier */
	module_put(fmc->owner);

	return 0;
}

static struct fmc_fru_id ft_fru_id[] = {
	{
	 .product_name = "FmcTdc1ns5cha",
	 },
};

static struct fmc_driver ft_drv = {
	.version = FMC_VERSION,
	.driver.name = KBUILD_MODNAME,
	.probe = ft_probe,
	.remove = ft_remove,
	.id_table = {
		     .fru_id = ft_fru_id,
		     .fru_id_nr = ARRAY_SIZE(ft_fru_id),
		     },
};

static int ft_init(void)
{
	int ret;

	#if LINUX_VERSION_CODE < KERNEL_VERSION(3,15,0)
	ft_workqueue = alloc_workqueue(ft_drv.driver.name,
					WQ_NON_REENTRANT | WQ_UNBOUND |
					WQ_MEM_RECLAIM, 1);
	#else
	ft_workqueue = alloc_workqueue(ft_drv.driver.name,
				       WQ_UNBOUND | WQ_MEM_RECLAIM, 1);
	#endif
	if (ft_workqueue == NULL)
		return -ENOMEM;

	ret = zio_register_trig(&ft_trig_type, FT_ZIO_TRIG_TYPE_NAME);
	if (ret) {
		pr_err("fmc-tdc: cannot register ZIO trigger type \"%s\" (error %i)\n",
		       FT_ZIO_TRIG_TYPE_NAME, ret);
		goto err_zio_trg;
	}

	ret = ft_zio_register();
	if (ret < 0)
		goto err_zio;

	ret = fmc_driver_register(&ft_drv);
	if (ret < 0)
		goto err_fmc;

	return 0;

err_fmc:
	ft_zio_unregister();
err_zio:
	zio_unregister_trig(&ft_trig_type);
err_zio_trg:
	destroy_workqueue(ft_workqueue);

	return ret;
}

static void ft_exit(void)
{
	fmc_driver_unregister(&ft_drv);
	ft_zio_unregister();
	zio_unregister_trig(&ft_trig_type);
	destroy_workqueue(ft_workqueue);
}

module_init(ft_init);
module_exit(ft_exit);

MODULE_VERSION(GIT_VERSION);
MODULE_LICENSE("GPL and additional rights");	/* LGPL */

ADDITIONAL_VERSIONS;
