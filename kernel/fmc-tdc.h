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

#ifdef __KERNEL__ /* All the rest is only of kernel users */
#include <linux/spinlock.h>
#include <linux/timer.h>
#include <linux/fmc.h>
#include <linux/version.h>
#endif

#define FT_VERSION    2 /* version of the driver */

/* default gatewares */
#define FT_GATEWARE_SVEC  "fmc/svec-fmc-tdc.bin"
#define FT_GATEWARE_SPEC  "fmc/spec-fmc-tdc.bin"

#define FT_BUFFER_EVENTS 256

#define FT_CH_1   1
#define FT_NUM_CHANNELS 5

enum ft_channel_flags {
  FT_FLAG_CH_TERMINATED = 0,
  FT_FLAG_CH_DO_INPUT,
  FT_FLAG_CH_INPUT_READY
};

enum ft_zattr_dev_idx {
  FT_ATTR_DEV_VERSION = 0,
  FT_ATTR_DEV_SECONDS,
  FT_ATTR_DEV_COARSE,
  FT_ATTR_DEV_COMMAND, /* see below for commands */
  FT_ATTR_DEV_TEMP,
  FT_ATTR_DEV_RESERVE_6,
  FT_ATTR_DEV_RESERVE_7,
  FT_ATTR_DEV__LAST,
};

enum ft_zattr_in_idx {
  /* PLEASE check "NOTE:" above if you edit this*/
  FT_ATTR_TDC_SECONDS = FT_ATTR_DEV__LAST,
  FT_ATTR_TDC_COARSE,
  FT_ATTR_TDC_FRAC,
  FT_ATTR_TDC_SEQ,
  FT_ATTR_TDC_TERMINATION,
  FT_ATTR_TDC_OFFSET,
  FT_ATTR_TDC_USER_OFFSET,
  FT_ATTR_TDC_PURGE_FIFO,
  FT_ATTR_TDC__LAST,
};


enum ft_command {
  FT_CMD_WR_ENABLE = 0,
  FT_CMD_WR_DISABLE,
  FT_CMD_WR_QUERY,
  FT_CMD_IDENTIFY_ON,
  FT_CMD_IDENTIFY_OFF 
};

/* rest of the file is kernel-only */
#ifdef __KERNEL__

/* Carrier-specific operations (gateware does not fully decouple carrier specific stuff, such as
   DMA or resets, from mezzanine-specific operations). */

struct fmctdc_dev;

struct ft_carrier_specific {
  char *gateware_name;

  int (*init)(struct fmctdc_dev *);
  int (*reset_core)(struct fmctdc_dev *);
  int (*copy_timestamps) (struct fmctdc_dev *, int base_addr, int size, void *dst );
  int (*setup_irqs)(struct fmctdc_dev *, irq_handler_t handler);
  int (*disable_irqs)(struct fmctdc_dev *);
  int (*ack_irq)(struct fmctdc_dev *);
};


struct ft_calibration { /* All of these are big endian */
  /* Input-to-internal-timebase offset in ps. Add to all timestamps. */
  int32_t zero_offset[5];

  /* Default DAC value for VCXO. Set during init and for local timing */
  uint32_t vcxo_default_tune;
};

/* Hardware TDC timestamp */
struct ft_hw_timestamp {
  uint32_t bins;   /* In BIN (81 ps resolution) */
  uint32_t coarse;  /* 8 ns resolution */
  uint32_t utc;    /* 1 second resolution */
  uint32_t metadata; /* channel, polarity, etc. */
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
  spinlock_t lock;
	
  int ft_core_base;
	int ft_i2c_base;
	int ft_owregs_base;
	int ft_dma_base;
  int ft_carrier_base;
  int ft_irq_base;
	 
  struct fmc_device *fmc;
  struct zio_device *zdev, *hwzdev;
  struct timer_list temp_timer;

  struct ft_carrier_specific *carrier_specific;
  void *carrier_data;

  struct ft_calibration calib;
  struct tasklet_struct readout_tasklet;
  
  int initialized;
  int wr_mode_active;

  uint8_t ds18_id[8];
  unsigned long next_t;
  int temp;     /* temperature: scaled by 4 bits */
  int temp_ready;

  int verbose;
  uint32_t acam_r0;

  struct ft_channel_state channels[FT_NUM_CHANNELS];

  uint32_t cur_wr_ptr, prev_wr_ptr;

  struct ft_hw_timestamp *raw_events;
};


extern struct ft_carrier_specific ft_carrier_spec;

static inline uint32_t ft_readl(struct fmctdc_dev *ft, unsigned long reg)
{
  return fmc_readl(ft->fmc, ft->ft_core_base + reg);
}

static inline void ft_writel(struct fmctdc_dev *ft, uint32_t v, unsigned long reg)
{
  fmc_writel(ft->fmc, v, ft->ft_core_base + reg);
}

int ft_acam_init(struct fmctdc_dev *ft);
void ft_acam_exit(struct fmctdc_dev *ft);
int ft_acam_enable_channel(struct fmctdc_dev *ft, int channel, int enable);
int ft_acam_enable_termination(struct fmctdc_dev *dev, int channel, int enable);
int ft_acam_enable_acquisition(struct fmctdc_dev *ft, int enable);

int ft_onewire_init(struct fmctdc_dev *ft);
void ft_onewire_exit(struct fmctdc_dev *ft);
int ft_read_temp(struct fmctdc_dev *ft, int verbose);

int ft_pll_init(struct fmctdc_dev *ft);
void ft_pll_exit(struct fmctdc_dev *ft);

void ft_ts_apply_offset(struct ft_wr_timestamp *ts, int32_t offset_picos );
void ft_ts_sub (struct ft_wr_timestamp *a, struct ft_wr_timestamp *b);

int ft_set_tai_time(struct fmctdc_dev *ft, uint64_t seconds, uint32_t coarse);
int ft_get_tai_time(struct fmctdc_dev *ft, uint64_t *seconds, uint32_t *coarse);
int ft_enable_wr_mode (struct fmctdc_dev *ft, int enable);
int ft_check_wr_mode (struct fmctdc_dev *ft);

int ft_handle_eeprom_calibration(struct fmctdc_dev *ft);

int ft_irq_init(struct fmctdc_dev *ft);
void ft_irq_exit(struct fmctdc_dev *ft);

int ft_time_init(struct fmctdc_dev *ft);
void ft_time_exit(struct fmctdc_dev *ft);

int ft_zio_register(void);
void ft_zio_unregister(void);
int ft_zio_init(struct fmctdc_dev *ft);
void ft_zio_exit(struct fmctdc_dev *ft);

struct zio_channel;

int ft_read_sw_fifo(struct fmctdc_dev *ft, int channel, struct zio_channel *chan);
int ft_enable_termination(struct fmctdc_dev *ft, int channel, int enable);

#endif 

#endif
