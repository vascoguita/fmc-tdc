/*
 * DMA support for tdc driver
 *
 * Copyright (C) 2012 CERN (http://www.cern.ch)
 * Author: Samuel Iglesias Gonsalvez <siglesias@igalia.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * version 2 as published by the Free Software Foundation.
 */

#include <asm/io.h>
#include <linux/dma-mapping.h>
#include <linux/delay.h>

#include "spec.h"
#include "tdc.h"
#include "hw/tdc_regs.h"

/*
 * tdc_dma_setup -- Setup DMA operation
 *
 * @tdc: pointer to spec_tdc struct of the device
 * @src: address to copy the data from (in TDC board)
 * @dst: address to copy the data to (in host computer)
 * @size: size of the DMA transfer (in bytes)
 *
 */
int tdc_dma_setup(struct spec_tdc *tdc, unsigned long src, unsigned long dst, int size)
{
	dma_addr_t mapping;

	mapping = dma_map_single(&tdc->spec->pdev->dev, (char *)dst, size,
				 DMA_FROM_DEVICE);
	tdc->rx_dma = mapping;

	if (dma_mapping_error(&tdc->spec->pdev->dev, tdc->rx_dma)) {
		dev_err(&tdc->spec->pdev->dev, "dma_map_single Rx failed\n");
		return -ENOMEM;
	}
	/* Write the source and destination addresses */
	writel(src, tdc->base + TDC_DMA_C_START_R);
	writel(mapping & 0xffffffff, tdc->base + TDC_DMA_H_START_L_R);
	writel((mapping >> 32) & 0x00ffffffff, tdc->base + TDC_DMA_H_START_H_R);
	writel(0, tdc->base + TDC_DMA_NEXT_L_R);
	writel(0, tdc->base + TDC_DMA_NEXT_H_R);
	/* Write the DMA length */
	writel(size, tdc->base + TDC_DMA_LEN_R);
	writel(0x1, tdc->base + TDC_DMA_ATTRIB_R);


	return 0;
}

int tdc_dma_start(struct spec_tdc *tdc)
{
	writel(0x1, tdc->base + TDC_DMA_CTRL_R);
	udelay(50);
	writel(0, tdc->base + TDC_DMA_CTRL_R);
	return 0;
}
