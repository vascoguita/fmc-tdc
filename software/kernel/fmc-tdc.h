/*
 * fmc-tdc (a.k.a) FmcTdc1ns5cha main header.
 *
 * Copyright (C) 2012-2013 CERN (www.cern.ch)
 * Author: Tomasz Wlostowski <tomasz.wlostowski@cern.ch>
 * Author: Alessandro Rubini <rubini@gnudd.com>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#ifndef __FMC_TDC_H__
#define __FMC_TDC_H__

#ifdef __KERNEL__
#include <linux/types.h>
#else
#include <stdint.h>
#endif

#define FT_VERSION_MAJ   8U		/* version of the driver */
#define FT_VERSION_MIN   0U

#define FT_ZIO_TRIG_TYPE_NAME "tdc1n5c-trg\0"

/* default gatewares */
#define FT_GATEWARE_SVEC  "fmc/svec-fmc-tdc.bin"
#define FT_GATEWARE_SPEC  "fmc/spec-fmc-tdc.bin"

#define FT_BUFFER_EVENTS 256

#define FT_CH_1   1
#define FT_NUM_CHANNELS 5

#define FT_FIFO_MAX 64

enum ft_versions {
	TDC_VER = 0,
};


enum ft_zattr_dev_idx {
	FT_ATTR_DEV_VERSION = 0,
	FT_ATTR_DEV_SECONDS,
	FT_ATTR_DEV_COARSE,
	FT_ATTR_DEV_SEQUENCE,
	FT_ATTR_DEV_COMMAND,	/* see below for commands */
	FT_ATTR_DEV_ENABLE_INPUTS,
	FT_ATTR_DEV_RESERVE_7,
	FT_ATTR_DEV__LAST,
};

enum ft_zattr_in_idx {
	/* PLEASE check "NOTE:" above if you edit this */
	FT_ATTR_TDC_SECONDS = FT_ATTR_DEV__LAST,
	FT_ATTR_TDC_COARSE,
	FT_ATTR_TDC_FRAC,
	FT_ATTR_TDC_TERMINATION,
	FT_ATTR_TDC_ZERO_OFFSET,
	FT_ATTR_TDC_USER_OFFSET,
	FT_ATTR_TDC_WR_OFFSET,
	FT_ATTR_TDC_TRANSFER_MODE,
	FT_ATTR_TDC_COALESCING_TIME,
	FT_ATTR_TDC_RAW_READOUT_MODE,
	FT_ATTR_TDC_RECV,
	FT_ATTR_TDC_TRANS,
	FT_ATTR_TDC__LAST,
};

enum ft_zattr_paremeters {
	FT_ATTR_PARAM_TEMP = FT_ATTR_TDC__LAST,
};

enum ft_command {
	FT_CMD_WR_ENABLE = 0,	/* Enable White Rabbit */
	FT_CMD_WR_DISABLE,	/* Disable it */
	FT_CMD_WR_QUERY,	/* Check if WR is locked */
	FT_CMD_SET_HOST_TIME,	/* Set board time to current host time */
	FT_CMD_IDENTIFY_ON,	/* Identify card by blinking status LEDs, reserved for future use. */
	FT_CMD_IDENTIFY_OFF
};

/* Hardware TDC timestamp */
struct ft_hw_timestamp {
	uint32_t seconds;	/* 1 second resolution */
	uint32_t coarse;	/* 8 ns resolution */
	uint32_t frac;		/* In ACAM bins (81 ps) */
	uint32_t metadata;	/* channel, polarity, etc. */
} __packed;

#define FT_HW_TS_META_CHN_MASK 0x7
#define FT_HW_TS_META_CHN_SHIFT 0
#define FT_HW_TS_META_CHN(_meta) ((_meta & FT_HW_TS_META_CHN_MASK) >> FT_HW_TS_META_CHN_SHIFT)

#define FT_HW_TS_META_POL_MASK 0x8
#define FT_HW_TS_META_POL_SHIFT 3
#define FT_HW_TS_META_POL(_meta) ((_meta & FT_HW_TS_META_POL_MASK) >> FT_HW_TS_META_POL_SHIFT)

#define FT_HW_TS_META_SEQ_MASK 0xFFFFFFF0
#define FT_HW_TS_META_SEQ_SHIFT 4
#define FT_HW_TS_META_SEQ(_meta) ((_meta & FT_HW_TS_META_SEQ_MASK) >> FT_HW_TS_META_SEQ_SHIFT)

struct ft_calibration_raw {
	int32_t zero_offset[FT_NUM_CHANNELS - 1];
	uint32_t vcxo_default_tune;
	uint32_t calibration_temp;
	int32_t wr_offset;
};

/* rest of the file is kernel-only */
#ifdef __KERNEL__

#include <linux/dma-mapping.h>
#include <linux/spinlock.h>
#include <linux/timer.h>
#include <linux/version.h>
#include <linux/platform_device.h>
#include <linux/fmc.h>
#include <linux/dmaengine.h>
#include <linux/workqueue.h>
#include <linux/debugfs.h>

struct ft_memory_ops {
#if LINUX_VERSION_CODE < KERNEL_VERSION(5,8,0)
	u32 (*read)(void *addr);
#else
	u32 (*read)(const void *addr);
#endif
	void (*write)(u32 value, void *addr);
};

#define TDC_IRQ 0
#define TDC_DMA 0

enum ft_mem_resource {
	TDC_MEM_BASE = 0,
};

enum ft_bus_resource {
	TDC_BUS_FMC_SLOT = 0,
};

#include <linux/zio-dma.h>
#include <linux/zio-trigger.h>

#include "hw/tdc_regs.h"
#include "hw/tdc_eic.h"
#include "hw/tdc_dma_eic.h"

extern struct zio_trigger_type ft_trig_type;
extern int irq_timeout_ms_default;

#define FT_USER_OFFSET_RANGE 1000000000	/* picoseconds */
#define TDC_CHANNEL_BUFFER_SIZE_BYTES 0x1000000 // 16MB

enum ft_channel_flags {
	FT_FLAG_CH_TERMINATED = 0,
	FT_FLAG_CH_DO_INPUT,
};

/* Carrier-specific operations (gateware does not fully decouple carrier specific stuff, such as
   DMA or resets, from mezzanine-specific operations). */

struct fmctdc_dev;

/**
 * Channel statistics
 */
struct fmctdc_channel_stats {
	uint32_t received;
	uint32_t transferred;
};

/**
 * struct ft_calibration - TDC calibration data
 * @zero_offset: Input-to-WR timebase offset in ps
 * @vcxo_default_tune: Default DAC value for VCXO. Set during init and for
 *                     local timing
 * @calibration_temp: Temperature at which the device has been calibrated
 * @wr_offset: White Rabbit timescale offset in ps
 *
 * All of these are little endian in the EEPROM
 */
struct ft_calibration {
	int32_t zero_offset[FT_NUM_CHANNELS];
	uint32_t vcxo_default_tune;
	uint32_t calibration_temp;
	int32_t wr_offset;
};

struct ft_channel_state {
	unsigned long flags;
	int32_t user_offset;

	int active_buffer;
#define __FT_BUF_MAX 2
	uint32_t buf_addr[__FT_BUF_MAX];
	uint32_t buf_size; // in timestamps

	struct fmctdc_channel_stats stats;
	dma_cookie_t cookie;
	struct sg_table sgt;

	struct ft_hw_timestamp dummy[FT_FIFO_MAX];
};

enum ft_transfer_mode {
	FT_ACQ_TYPE_FIFO = 0,
	FT_ACQ_TYPE_DMA,
};


struct fmctdc_trig {
	struct zio_ti ti;
};
static inline struct fmctdc_trig *to_fmctdc_trig(struct zio_ti *ti_ptr)
{
	return container_of(ti_ptr, struct fmctdc_trig, ti);
}

/*
 * Main TDC device context
 * @lock it protects: offset (user vs user), wr_mode (user vs user)
 * @irq_imr it holds the IMR value since our last modification. Use it
 *          **only** in the DMA IRQ handlers
 * @dma_chan_mask: bitmask to keep track of which channels are
 *                 transferring data. Timestamp interrupts are disabled
 *                 while DMA is running and we touch and this is the only
 *                 place where we use it: so, we do not need to protect it.
 */
struct fmctdc_dev {
	enum ft_transfer_mode mode;
	/* HW buffer/FIFO access lock */
	spinlock_t lock;
	/* base addresses, taken from SDB */
	void *ft_base;
	void *ft_core_base;
	void *ft_i2c_base;
	void *ft_owregs_base;
	void *ft_irq_base;
	void *ft_fifo_base;
	void *ft_dma_base;
	void *ft_dma_eic_base;
	struct ft_memory_ops memops;
	/* IRQ base index (for SVEC) */
	struct fmc_slot *slot;
	struct platform_device *pdev;
	struct zio_device *zdev, *hwzdev;
	/* carrier private data */
	void *carrier_data;
	/* current calibration block */
	struct ft_calibration calib;
	/* DS18S20 temperature sensor 1-wire ID */
	uint8_t ds18_id[8];
	/* next temperature measurement pending? */
	unsigned long next_t;
	/* temperature, degrees Celsius scaled by 16 and its ready flag */
	int temp;
	int temp_ready;
	/* output lots of debug stuff? */
	struct ft_channel_state channels[FT_NUM_CHANNELS];
	int wr_mode;

	uint32_t irq_imr;

	struct zio_dma_sgt *zdma;
	unsigned long dma_chan_mask;
	struct dma_chan *dchan;
	int pending_dma;
	struct work_struct irq_work;

	struct dentry *dbg_dir;
	struct debugfs_regset32 dbg_reg32;
	struct dentry *dbg_reg;
};

static inline u32 ft_ioread(struct fmctdc_dev *ft, void *addr)
{
	return ft->memops.read(addr);
}

static inline void ft_iowrite(struct fmctdc_dev *ft,
			      u32 value, void *addr)
{
	ft->memops.write(value, addr);
}

static inline uint32_t ft_readl(struct fmctdc_dev *ft, unsigned long reg)
{
	return ft_ioread(ft, ft->ft_core_base + reg);
}

static inline void ft_writel(struct fmctdc_dev *ft, uint32_t v,
			     unsigned long reg)
{
	ft_iowrite(ft, v, ft->ft_core_base + reg);
}


int ft_calib_init(struct fmctdc_dev *ft);
void ft_calib_exit(struct fmctdc_dev *ft);

void ft_enable_acquisition(struct fmctdc_dev *ft, int enable);

int ft_acam_init(struct fmctdc_dev *ft);
void ft_acam_exit(struct fmctdc_dev *ft);

int ft_pll_init(struct fmctdc_dev *ft);
void ft_pll_exit(struct fmctdc_dev *ft);

void ft_ts_apply_offset(struct ft_hw_timestamp *ts, int32_t offset_picos);
void ft_ts_sub(struct ft_hw_timestamp *a, struct ft_hw_timestamp *b);

void ft_set_tai_time(struct fmctdc_dev *ft, uint64_t seconds, uint32_t coarse);
void ft_get_tai_time(struct fmctdc_dev *ft, uint64_t * seconds,
		    uint32_t * coarse);
void ft_set_host_time(struct fmctdc_dev *ft);

int ft_wr_mode(struct fmctdc_dev *ft, int on);
int ft_wr_query(struct fmctdc_dev *ft);

extern struct bin_attribute dev_attr_calibration;

int ft_fifo_init(struct fmctdc_dev *ft);
void ft_fifo_exit(struct fmctdc_dev *ft);

int ft_buf_init(struct fmctdc_dev *ft);
void ft_buf_exit(struct fmctdc_dev *ft);

int ft_time_init(struct fmctdc_dev *ft);
void ft_time_exit(struct fmctdc_dev *ft);

void ft_zio_kill_buffer(struct fmctdc_dev *ft, int channel);

int ft_zio_register(void);
void ft_zio_unregister(void);
int ft_zio_init(struct fmctdc_dev *ft);
void ft_zio_exit(struct fmctdc_dev *ft);

void ft_set_vcxo_tune (struct fmctdc_dev *ft, int value);

struct zio_channel;

int ft_enable_termination(struct fmctdc_dev *ft, int channel, int enable);

void ft_irq_coalescing_size_set(struct fmctdc_dev *ft,
				unsigned int chan,
				uint32_t size);

void ft_irq_coalescing_timeout_set(struct fmctdc_dev *ft,
				   unsigned int chan,
				   uint32_t timeout_ms);
uint32_t ft_irq_coalescing_timeout_get(struct fmctdc_dev *ft,
				       unsigned int chan);

int ft_debug_init(struct fmctdc_dev *ft);
void ft_debug_exit(struct fmctdc_dev *ft);

/**
 * It enables the acquisition on a give channel
 * @ft FmcTdc FMC TDC device instance
 * @chan channel number [0, N]
 */
static inline void ft_enable(struct fmctdc_dev *ft, unsigned int chan)
{
	uint32_t ien;

	ien = ft_readl(ft, TDC_REG_INPUT_ENABLE);
	ien |= (TDC_INPUT_ENABLE_CH1 << chan);
	ft_writel(ft, ien, TDC_REG_INPUT_ENABLE);
}

/**
 * It disables the acquisition on a give channel
 * @ft FmcTdc FMC TDC device instance
 * @chan channel number [0, N]
 */
static inline void ft_disable(struct fmctdc_dev *ft, unsigned int chan)
{
	uint32_t ien;

	ien = ft_readl(ft, TDC_REG_INPUT_ENABLE);
	ien &= ~(TDC_INPUT_ENABLE_CH1 << chan);
	ft_writel(ft, ien, TDC_REG_INPUT_ENABLE);
}

extern int ft_temperature_get(struct fmctdc_dev *ft);

#endif // __KERNEL__

#endif // __FMC_TDC_H__
