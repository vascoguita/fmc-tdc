// SPDX-License-Identifier: GPL-2.0-or-later
/*
 * Copyright (C) 2020 CERN (www.cern.ch)
 * Author: Federico Vaga <federico.vaga@cern.ch>
 */

#include <linux/platform_device.h>
#include <linux/version.h>

#if KERNEL_VERSION(5, 4, 0) > LINUX_VERSION_CODE
/*
 * INSPIRED from Linux 5.6 where this issue is fixed
 * Set up default DMA mask for platform devices if the they weren't
 * previously set by the architecture / DT.
 *
 * It should never fail, use WARN to report errors.
 * We allocate 8bytes but we are not going to release them
 * to avoid overcomplications for something that is fixed it modern kernel.
 * Anyway this driver should not be loaded/unloaded continously,
 * so we do not care for 8bytes.
 */
static inline void internal_setup_pdev_dma_masks(struct platform_device *pdev)
{
	if (!pdev->dev.coherent_dma_mask)
		pdev->dev.coherent_dma_mask = DMA_BIT_MASK(32);
	if (!pdev->dev.dma_mask) {
		pdev->dev.dma_mask = kmalloc(sizeof(*pdev->dev.dma_mask),
					     GFP_KERNEL);
		WARN(!pdev->dev.dma_mask,
		     "Failed to allocate dma_mask\n");
	}
}
#else
static inline void internal_setup_pdev_dma_masks(struct platform_device *pdev)
{}
#endif
