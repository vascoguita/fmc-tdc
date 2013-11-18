/*
 * fmc-tdc (a.k.a) FmcTdc1ns5cha main header.
 *
 * Copyright (C) 2012-2013 CERN (www.cern.ch)
 * Author: Tomasz Wlostowski <tomasz.wlostowski@cern.ch>
 * Author: Alessandro Rubini <rubini@gnudd.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * version 2 as published by the Free Software Foundation or, at your
 * option, any later version.
 */

#ifndef __FMC_TDC_H__
#define __FMC_TDC_H__

#ifdef __KERNEL__		/* All the rest is only of kernel users */
#include <linux/spinlock.h>
#include <linux/timer.h>
#include <linux/fmc.h>
#include <linux/version.h>
#endif

#define FT_VERSION    2		/* version of the driver */

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
	FT_ATTR_DEV_COMMAND,	/* see below for commands */
	FT_ATTR_DEV_TEMP,
	FT_ATTR_DEV_ENABLE_INPUTS,
	FT_ATTR_DEV_RESERVE_7,
	FT_ATTR_DEV__LAST,
};

enum ft_zattr_in_idx {
	/* PLEASE check "NOTE:" above if you edit this */
	FT_ATTR_TDC_SECONDS = FT_ATTR_DEV__LAST,
	FT_ATTR_TDC_COARSE,
	FT_ATTR_TDC_FRAC,
	FT_ATTR_TDC_SEQ,
	FT_ATTR_TDC_TERMINATION,
	FT_ATTR_TDC_OFFSET,
	FT_ATTR_TDC_USER_OFFSET,
	FT_ATTR_TDC__LAST,
};

enum ft_command {
	FT_CMD_WR_ENABLE = 0,	/* Enable White Rabbit */
	FT_CMD_WR_DISABLE,	/* Disable it */
	FT_CMD_WR_QUERY,	/* Check if WR is locked */
	FT_CMD_SET_HOST_TIME,	/* Set board time to current host time */
	FT_CMD_IDENTIFY_ON,	/* Identify card by blinking status LEDs, reserved for future use. */
	FT_CMD_IDENTIFY_OFF
};

/* rest of the file is kernel-only */
#ifdef __KERNEL__

#define FT_USER_OFFSET_RANGE 1000000000	/* picoseconds */

enum ft_channel_flags {
	FT_FLAG_CH_TERMINATED = 0,
	FT_FLAG_CH_DO_INPUT,
	FT_FLAG_CH_INPUT_READY
};

/* Carrier-specific operations (gateware does not fully decouple carrier specific stuff, such as
   DMA or resets, from mezzanine-specific operations). */

struct fmctdc_dev;

struct ft_carrier_specific {
	char *gateware_name;

	int (*init) (struct fmctdc_dev *);
	int (*reset_core) (struct fmctdc_dev *);
	int (*copy_timestamps) (struct fmctdc_dev *, int base_addr, int size,
				void *dst);
	void (*exit) (struct fmctdc_dev *);
};

struct ft_calibration {		/* All of these are big endian in the EEPROM */
	/* Input-to-WR timebase offset in ps. */
	int32_t zero_offset[5];

	/* Default DAC value for VCXO. Set during init and for local timing */
	uint32_t vcxo_default_tune;
};

/* Hardware TDC timestamp */
struct ft_hw_timestamp {
	uint32_t bins;		/* In ACAM bins (81 ps) */
	uint32_t coarse;	/* 8 ns resolution */
	uint32_t utc;		/* 1 second resolution */
	uint32_t metadata;	/* channel, polarity, etc. */
} __packed;

/* White Rabbit timestamp */
struct ft_wr_timestamp {
	uint64_t seconds;
	uint32_t coarse;
	uint32_t frac;
	int seq_id;
	int channel;
};

struct ft_sw_fifo {
	unsigned long head, tail, count, size;
	struct ft_wr_timestamp *t;
};

struct ft_channel_state {
	unsigned long flags;
	int expected_edge;
	int cur_seq_id;

	int32_t user_offset;

	struct ft_wr_timestamp prev_ts;
	struct ft_sw_fifo fifo;
};

/* Main TDC device context */
struct fmctdc_dev {
	/* HW buffer/FIFO access lock */
	spinlock_t lock;
	/* base addresses, taken from SDB */
	int ft_core_base;
	int ft_i2c_base;
	int ft_owregs_base;
	int ft_dma_base;
	int ft_carrier_base;
	int ft_irq_base;
	int ft_buffer_base;
	/* IRQ base index (for SVEC) */
	struct fmc_device *fmc;
	struct zio_device *zdev, *hwzdev;
	/* is acquisition mode active? */
	int acquisition_on;
	/* temperature readout timer */
	struct timer_list temp_timer;
	/* carrier specific functions (init/exit/reset/readout/irq handling) */
	struct ft_carrier_specific *carrier_specific;
	/* carrier private data */
	void *carrier_data;
	/* current calibration block */
	struct ft_calibration calib;
	struct tasklet_struct readout_tasklet;
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
	/* hardware buffer pointers / dacapo regs */
	uint32_t cur_wr_ptr, prev_wr_ptr;
	/* DMA buffer */
	struct ft_hw_timestamp *raw_events;
};

extern struct ft_carrier_specific ft_carrier_spec;
extern struct ft_carrier_specific ft_carrier_svec;

static inline uint32_t ft_readl(struct fmctdc_dev *ft, unsigned long reg)
{
	return fmc_readl(ft->fmc, ft->ft_core_base + reg);
}

static inline void ft_writel(struct fmctdc_dev *ft, uint32_t v,
			     unsigned long reg)
{
	fmc_writel(ft->fmc, v, ft->ft_core_base + reg);
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

int ft_set_tai_time(struct fmctdc_dev *ft, uint64_t seconds, uint32_t coarse);
int ft_get_tai_time(struct fmctdc_dev *ft, uint64_t * seconds,
		    uint32_t * coarse);
int ft_set_host_time(struct fmctdc_dev *ft);

int ft_enable_wr_mode(struct fmctdc_dev *ft, int enable);
int ft_check_wr_mode(struct fmctdc_dev *ft);

int ft_handle_eeprom_calibration(struct fmctdc_dev *ft);

int ft_irq_init(struct fmctdc_dev *ft);
void ft_irq_exit(struct fmctdc_dev *ft);

int ft_time_init(struct fmctdc_dev *ft);
void ft_time_exit(struct fmctdc_dev *ft);

void ft_zio_kill_buffer(struct fmctdc_dev *ft, int channel);

int ft_zio_register(void);
void ft_zio_unregister(void);
int ft_zio_init(struct fmctdc_dev *ft);
void ft_zio_exit(struct fmctdc_dev *ft);

struct zio_channel;

int ft_read_sw_fifo(struct fmctdc_dev *ft, int channel,
		    struct zio_channel *chan);
int ft_enable_termination(struct fmctdc_dev *ft, int channel, int enable);

signed long fmc_find_sdb_device_ext(struct sdb_array *tree,
				    uint64_t vid, uint32_t did, int index,
				    unsigned long *sz);

#endif // __KERNEL__

#endif // __FMC_TDC_H__
