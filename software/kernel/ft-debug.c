// SPDX-License-Identifier: GPL-2.0-or-later
/*
 * Copyright CERN 2018-2019
 * Author: Federico Vaga <federico.vaga@cern.ch>
 */
#include <linux/debugfs.h>
#include "fmc-tdc.h"

#define FT_DBG_REG32_BUF(_n)                                                            \
	{                                                                               \
		.name = "TDC-BUF:ch"#_n":csr",                                          \
		.offset = TDC_MEZZ_MEM_DMA_OFFSET + TDC_BUF_REG_CSR + (_n * 0x40),      \
	},                                                                              \
	{								                \
		.name = "TDC-BUF:ch"#_n":cur-base",				        \
		.offset = TDC_MEZZ_MEM_DMA_OFFSET + TDC_BUF_REG_CUR_BASE + (_n * 0x40), \
	},                                                                              \
	{								                \
		.name = "TDC-BUF:ch"#_n":cur-count",				        \
		.offset = TDC_MEZZ_MEM_DMA_OFFSET + TDC_BUF_REG_CUR_COUNT + (_n * 0x40),\
	},                                                                              \
	{								                \
		.name = "TDC-BUF:ch"#_n":cur-size",				        \
		.offset = TDC_MEZZ_MEM_DMA_OFFSET + TDC_BUF_REG_CUR_SIZE + (_n * 0x40), \
	},								                \
	{								                \
		.name = "TDC-BUF:ch"#_n":next-base",				        \
		.offset = TDC_MEZZ_MEM_DMA_OFFSET + TDC_BUF_REG_NEXT_BASE + (_n * 0x40),\
	},								                \
	{								                \
		.name = "TDC-BUF:ch"#_n":next-size",				        \
		.offset = TDC_MEZZ_MEM_DMA_OFFSET + TDC_BUF_REG_NEXT_SIZE + (_n * 0x40),\
	}

static const struct debugfs_reg32 ft_debugfs_reg32[] = {
	FT_DBG_REG32_BUF(0),
	FT_DBG_REG32_BUF(1),
	FT_DBG_REG32_BUF(2),
	FT_DBG_REG32_BUF(3),
	FT_DBG_REG32_BUF(4),
};

int ft_debug_init(struct fmctdc_dev *ft)
{
	int err;

	ft->dbg_dir = debugfs_create_dir(dev_name(&ft->pdev->dev), NULL);
	if (IS_ERR_OR_NULL(ft->dbg_dir)) {
		err = PTR_ERR(ft->dbg_dir);
		dev_err(&ft->zdev->head.dev,
			"Cannot create debugfs directory \"%s\" (%d)\n",
			dev_name(&ft->zdev->head.dev), err);
		return err;
	}

	switch (ft->mode) {
	case FT_ACQ_TYPE_DMA:
		ft->dbg_reg32.regs = ft_debugfs_reg32;
		ft->dbg_reg32.nregs = ARRAY_SIZE(ft_debugfs_reg32);
		ft->dbg_reg32.base = ft->ft_base;
		debugfs_create_regset32("regs", 0444, ft->dbg_dir,
					&ft->dbg_reg32);
		if (IS_ERR_OR_NULL(ft->dbg_reg)) {
			err = PTR_ERR(ft->dbg_reg);
			dev_warn(&ft->pdev->dev,
				 "Cannot create debugfs file \"regs\" (%d)\n",
				 err);
		}
		break;
	default:
		break;
	}

	return 0;
}


void ft_debug_exit(struct fmctdc_dev *ft)
{
	debugfs_remove_recursive(ft->dbg_dir);
}
