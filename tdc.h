#ifndef __FMC_TDC_H__
#define __FMC_TDC_H__

#define TDC_VERSION	1

struct spec_tdc {
	struct fmc_device *fmc;
	struct spec_dev *spec;
	struct zio_device *zdev, *hwzdev;
	unsigned char __iomem *base;	/* regs files are byte-oriented */
	unsigned char __iomem *regs;
	unsigned char __iomem *gn412x_regs;
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
	TDC_ATTR_DEV_TSTAMPS_THRESH,
	TDC_ATTR_DEV_TIME_THRESH,
	TDC_ATTR_DEV__LAST,
};

/* Channel ZIO attributes */
enum tdc_zattr_chan_idx {
	TDC_ATTR_CHAN_ENABLED = TDC_ATTR_DEV__LAST,
	TDC_ATTR_CHAN__LAST,
};

extern int tdc_zio_register_device(struct spec_tdc *tdc);
extern void tdc_zio_remove(struct spec_tdc *tdc);
extern int tdc_zio_init(void);
extern void tdc_zio_exit(void);

/* FMC helper functions */
int tdc_fmc_init(void);
void tdc_fmc_exit(void);

/* ACAM helper functions */
void tdc_acam_reset(struct spec_tdc *tdc);
int tdc_acam_load_config(struct spec_tdc *tdc, struct tdc_acam_cfg *cfg);
int tdc_acam_get_config(struct spec_tdc *tdc, struct tdc_acam_cfg *cfg);
u32 tdc_acam_status(struct spec_tdc *tdc);
u32 tdc_acam_read_ififo1(struct spec_tdc *tdc);
u32 tdc_acam_read_ififo2(struct spec_tdc *tdc);
u32 tdc_acam_read_start01(struct spec_tdc *tdc);

/* Core functions */
int tdc_probe(struct fmc_device *dev);
int tdc_remove(struct fmc_device *dev);

int tdc_set_utc_time(struct spec_tdc *tdc);
u32 tdc_get_utc_time(struct spec_tdc *tdc);
void tdc_set_irq_tstamp_thresh(struct spec_tdc *tdc, u32 val);
void tdc_set_irq_time_thresh(struct spec_tdc *tdc, u32 val);
u32 tdc_get_irq_time_thresh(struct spec_tdc *tdc);
void tdc_set_dac_word(struct spec_tdc *tdc, u32 val);
void tdc_clear_da_capo_flag(struct spec_tdc *tdc);
void tdc_activate_adquisition(struct spec_tdc *tdc);
void tdc_deactivate_adquisition(struct spec_tdc *tdc);


#endif
