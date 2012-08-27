#ifndef __FMC_TDC_H__
#define __FMC_TDC_H__

struct spec_tdc {
	struct spec_dev *spec;
	struct zio_device *zdev, *hwzdev;
	unsigned char __iomem *base;	/* regs files are byte-oriented */
	unsigned char __iomem *regs;
	unsigned char __iomem *gn412x_regs;
};

extern int tdc_zio_register_device(struct spec_tdc *tdc);
extern void tdc_zio_remove(struct spec_tdc *tdc);
extern int tdc_zio_init(void);
extern void tdc_zio_exit(void);

extern int tdc_spec_init(void);
extern void tdc_spec_exit(void);

int tdc_probe(struct spec_dev *dev);
void tdc_remove(struct spec_dev *dev);
#endif
