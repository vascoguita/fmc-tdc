#ifndef __FMC_TDC_H__
#define __FMC_TDC_H__


struct spec_tdc {
	struct spec_dev *spec;
	struct zio_device *zdev, *hwzdev;
	unsigned char __iomem *base;	/* regs files are byte-oriented */
	unsigned char __iomem *regs;
	unsigned char __iomem *ow_regs;
};


#endif
