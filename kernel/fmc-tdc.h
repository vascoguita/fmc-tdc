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

#define FT_VERSION_MAJ   2		/* version of the driver */
#define FT_VERSION_MIN   1

/* default gatewares */
#define FT_GATEWARE_SVEC  "fmc/svec-fmc-tdc.bin"
#define FT_GATEWARE_SPEC  "fmc/spec-fmc-tdc.bin"

#define FT_BUFFER_EVENTS 256

#define FT_CH_1   1
#define FT_NUM_CHANNELS 5

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
	FT_ATTR_TDC_DELAY_REF,
	FT_ATTR_TDC_DELAY_REF_SEQ,
	FT_ATTR_TDC_WR_OFFSET,
	FT_ATTR_TDC_TRANSFER_MODE,
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

/* White Rabbit timestamp */
struct ft_wr_timestamp {
	uint64_t seconds;
	uint32_t coarse;
	uint32_t frac;
	uint32_t channel;
	uint32_t hseq_id; /* hardware channel sequence id */
};

/* rest of the file is kernel-only */
#ifdef __KERNEL__

#include <linux/dma-mapping.h>
#include <linux/spinlock.h>
#include <linux/timer.h>
#include <linux/fmc.h>
#include <linux/version.h>
#include <linux/workqueue.h>

#include "hw/tdc_regs.h"
#include "hw/tdc_eic.h"


extern struct workqueue_struct *ft_workqueue;

#define FT_USER_OFFSET_RANGE 1000000000	/* picoseconds */
#define TDC_BYTES_PER_TIMESTAMP       16
#define TDC_CHANNEL_BUFFER_SIZE_BYTES 0x1000000 // 16MB

enum ft_channel_flags {
	FT_FLAG_CH_TERMINATED = 0,
	FT_FLAG_CH_DO_INPUT,
};

/* Carrier-specific operations (gateware does not fully decouple carrier specific stuff, such as
   DMA or resets, from mezzanine-specific operations). */

struct fmctdc_dev;

struct ft_calibration {		/* All of these are big endian in the EEPROM */
	/* Input-to-WR timebase offset in ps. */
	int32_t zero_offset[5];

	/* Default DAC value for VCXO. Set during init and for local timing */
	uint32_t vcxo_default_tune;

	/* Temperature at which the device has been calibrated */
	uint32_t calibration_temp;

	/* White Rabbit timescale offset in ps */
	int32_t wr_offset;
};

/* Hardware TDC timestamp */
struct ft_hw_timestamp {
	uint32_t utc;		/* 1 second resolution */
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

struct ft_channel_state {
	unsigned long flags;
	int delay_reference;

	int32_t user_offset;

	struct ft_wr_timestamp last_ts; /**< used to compute delay
					   between pulses */

	int active_buffer;
#define __FT_BUF_MAX 2
	uint32_t buf_addr[__FT_BUF_MAX];
	uint32_t buf_size; // in timestamps
};

enum ft_transfer_mode {
	FT_ACQ_TYPE_FIFO = 0,
	FT_ACQ_TYPE_DMA,
};

/*
 * Main TDC device context
 * @lock it protects: irq_imr (irq vs user), offset (user vs user),
 *       wr_mode (user vs user)
 * @irq_imr it holds the IMR value since our last modification
 */
struct fmctdc_dev {
	enum ft_transfer_mode mode;
	/* HW buffer/FIFO access lock */
	spinlock_t lock;
	/* base addresses, taken from SDB */
	int ft_core_base;
	int ft_i2c_base;
	int ft_owregs_base;
	int ft_irq_base;
	int ft_fifo_base;
	int ft_dma_base;
	/* IRQ base index (for SVEC) */
	struct fmc_device *fmc;
	struct zio_device *zdev, *hwzdev;
	/* carrier private data */
	void *carrier_data;
	/* current calibration block */
	struct ft_calibration calib;
	int initialized;
	/* DS18S20 temperature sensor 1-wire ID */
	uint8_t ds18_id[8];
	/* next temperature measurement pending? */
	unsigned long next_t;
	/* temperature, degrees Celsius scaled by 16 and its ready flag */
	int temp;
	int temp_ready;
	/* output lots of debug stuff? */
	int verbose;
	struct ft_channel_state channels[FT_NUM_CHANNELS];
	int wr_mode;

	uint32_t irq_imr;
	struct work_struct ts_work;
};

static inline u32 ft_ioread(struct fmctdc_dev *ft, unsigned long addr)
{
	return fmc_readl(ft->fmc, addr);
}

static inline void ft_iowrite(struct fmctdc_dev *ft,
			      u32 value, unsigned long addr)
{
	fmc_writel(ft->fmc, value, addr);
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



void ft_enable_acquisition(struct fmctdc_dev *ft, int enable);

int ft_acam_init(struct fmctdc_dev *ft);
void ft_acam_exit(struct fmctdc_dev *ft);

int ft_onewire_init(struct fmctdc_dev *ft);
void ft_onewire_exit(struct fmctdc_dev *ft);
int ft_read_temp(struct fmctdc_dev *ft, int verbose);

int ft_pll_init(struct fmctdc_dev *ft);
void ft_pll_exit(struct fmctdc_dev *ft);

void ft_ts_apply_offset(struct ft_wr_timestamp *ts, int32_t offset_picos);
void ft_ts_sub(struct ft_wr_timestamp *a, struct ft_wr_timestamp *b);

void ft_set_tai_time(struct fmctdc_dev *ft, uint64_t seconds, uint32_t coarse);
void ft_get_tai_time(struct fmctdc_dev *ft, uint64_t * seconds,
		    uint32_t * coarse);
void ft_set_host_time(struct fmctdc_dev *ft);

int ft_wr_mode(struct fmctdc_dev *ft, int on);
int ft_wr_query(struct fmctdc_dev *ft);

int ft_handle_eeprom_calibration(struct fmctdc_dev *ft);

int ft_irq_init(struct fmctdc_dev *ft);
void ft_irq_exit(struct fmctdc_dev *ft);
void ft_irq_enable(struct fmctdc_dev *ft, uint32_t chan_mask);
void ft_irq_disable(struct fmctdc_dev *ft, uint32_t chan_mask);

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

signed long fmc_sdb_find_nth_device (struct sdb_array *tree, uint64_t vid,
				     uint32_t did, int *ordinal,
				     uint32_t *size );

void gn4124_dma_read(struct fmctdc_dev *ft, uint32_t src, void *dst, int len);
void gn4124_dma_wait_done(struct fmctdc_dev *ft);


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



#endif // __KERNEL__

#endif // __FMC_TDC_H__
