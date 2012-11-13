#ifndef __FMC_TDC_H__
#define __FMC_TDC_H__

#define TDC_VERSION	1
#define MAX_DEVICES	16

#include <linux/types.h>
#include <linux/workqueue.h>
#include <linux/semaphore.h>
#include "hw/tdc_regs.h"

/* module parameters */
extern int lun[MAX_DEVICES];
extern unsigned int nlun;
extern int bus[MAX_DEVICES];
extern unsigned int nbus;
extern int slot[MAX_DEVICES];
extern unsigned int nslot;
extern char *gateware;

#define DEFAULT_TIME_THRESH	0x10
#define DEFAULT_TSTAMP_THRESH	0x10

struct tdc_event {
	u32 fine_time;		/* In BIN (81 ps resolution) */
	u32 coarse_time;	/* 8 ns resolution */
	u32 local_utc;		/* 1 second resolution */
	u32 metadata;
}  __packed;

struct tdc_event_buffer {
	struct tdc_event data;
	int dacapo_flag;
};

struct tdc_acam_cfg {
	u32 edge_config;	/* ACAM reg. 0 */
	u32 channel_adj;	/* ACAM reg. 1 */
	u32 mode_enable;	/* ACAM reg. 2 */
	u32 resolution;		/* ACAM reg. 3 */
	u32 start_timer_set;	/* ACAM reg. 4 */
	u32 start_retrigger;	/* ACAM reg. 5 */
	u32 lf_flags_level;	/* ACAM reg. 6 */
	u32 pll;		/* ACAM reg. 7 */
	u32 err_flag_cfg;	/* ACAM reg. 11 */
	u32 int_flag_cfg;	/* ACAM reg. 12 */
	u32 ctrl_16_bit_mode;	/* ACAM reg. 14 */
};

/* Device-wide ZIO attributes */
enum tdc_zattr_dev_idx {
	TDC_ATTR_DEV_VERSION = 0,
	TDC_ATTR_DEV_TSTAMP_THRESH,
	TDC_ATTR_DEV_TIME_THRESH,
	TDC_ATTR_DEV_CURRENT_UTC,
	TDC_ATTR_DEV_SET_UTC,
	TDC_ATTR_DEV_INPUT_ENABLED,
	TDC_ATTR_DEV_DAC_WORD,
	TDC_ATTR_DEV_ACTIVATE_ACQUISITION,
	TDC_ATTR_DEV_GET_POINTER,
	TDC_ATTR_DEV_LUN,
	TDC_ATTR_DEV_CLEAR_DACAPO_FLAG,
	TDC_ATTR_DEV_RESET_ACAM,
	TDC_ATTR_DEV__LAST,
};

struct spec_tdc {
	uint32_t lun;
	struct fmc_device *fmc;
	struct spec_dev *spec;
	struct zio_device *zdev, *hwzdev;
	unsigned char __iomem *base;	/* regs files are byte-oriented */
	unsigned char __iomem *gn412x_regs;
	atomic_t busy;		/* whether the device is acquiring data */
	u32 wr_pointer;
	dma_addr_t rx_dma;
	struct work_struct irq_work;
	struct tdc_event_buffer event[TDC_CHAN_NUMBER];
};

/* ZIO helper functions */
extern int tdc_zio_register_device(struct spec_tdc *tdc);
extern void tdc_zio_remove(struct spec_tdc *tdc);
extern int tdc_zio_init(void);
extern void tdc_zio_exit(void);

/* FMC helper functions */
extern int tdc_fmc_init(void);
extern void tdc_fmc_exit(void);

/* ACAM helper functions */
extern void tdc_acam_reset(struct spec_tdc *tdc);
extern int tdc_acam_load_config(struct spec_tdc *tdc, struct tdc_acam_cfg *cfg);
extern int tdc_acam_set_default_config(struct spec_tdc *tdc);

extern int tdc_acam_get_config(struct spec_tdc *tdc, struct tdc_acam_cfg *cfg);
extern u32 tdc_acam_status(struct spec_tdc *tdc);
extern u32 tdc_acam_read_ififo1(struct spec_tdc *tdc);
extern u32 tdc_acam_read_ififo2(struct spec_tdc *tdc);
extern u32 tdc_acam_read_start01(struct spec_tdc *tdc);

/* DMA helper functions */
extern int tdc_dma_setup(struct spec_tdc *tdc, unsigned long src, unsigned long dst, int size);
extern int tdc_dma_start(struct spec_tdc *tdc);

/* Core functions */
extern int tdc_fmc_probe(struct fmc_device *dev);
extern int tdc_fmc_remove(struct fmc_device *dev);

extern void tdc_set_local_utc_time(struct spec_tdc *tdc);
extern void tdc_set_utc_time(struct spec_tdc *tdc, u32 value);
extern void tdc_set_input_enable(struct spec_tdc *tdc, u32 value);
extern void tdc_set_irq_tstamp_thresh(struct spec_tdc *tdc, u32 val);
extern void tdc_set_irq_time_thresh(struct spec_tdc *tdc, u32 val);
extern void tdc_set_dac_word(struct spec_tdc *tdc, u32 val);

extern u32 tdc_get_input_enable(struct spec_tdc *tdc);
extern u32 tdc_get_irq_tstamp_thresh(struct spec_tdc *tdc);
extern u32 tdc_get_irq_time_thresh(struct spec_tdc *tdc);
extern u32 tdc_get_current_utc_time(struct spec_tdc *tdc);
extern u32 tdc_get_circular_buffer_wr_pointer(struct spec_tdc *tdc);
extern u32 tdc_get_dac_word(struct spec_tdc *tdc);

extern void tdc_clear_da_capo_flag(struct spec_tdc *tdc);
extern int tdc_activate_acquisition(struct spec_tdc *tdc);
extern void tdc_deactivate_acquisition(struct spec_tdc *tdc);

#endif
