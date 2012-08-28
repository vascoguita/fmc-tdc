#ifndef __FMC_TDC_H__
#define __FMC_TDC_H__

#define TDC_VERSION	1

struct spec_tdc {
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
	u32 ififo1;		/* ACAM reg. 8 */
	u32 ififo2;		/* ACAM reg. 9 */
	u32 start01;		/* ACAM reg. 10 */
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

extern int tdc_zio_register_device(struct spec_tdc *tdc);
extern void tdc_zio_remove(struct spec_tdc *tdc);
extern int tdc_zio_init(void);
extern void tdc_zio_exit(void);

extern int tdc_spec_init(void);
extern void tdc_spec_exit(void);

void tdc_acam_reset(struct spec_tdc *tdc);
int tdc_acam_load_config(struct spec_tdc *tdc, struct tdc_acam_cfg *cfg);
int tdc_acam_read_config(struct spec_tdc *tdc, struct tdc_acam_cfg *cfg);

int tdc_probe(struct spec_dev *dev);
void tdc_remove(struct spec_dev *dev);
#endif
