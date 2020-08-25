// SPDX-License-Identifier: GPL-2.0-or-later
/*
 * Copyright CERN 2018-2019
 * Author: Federico Vaga <federico.vaga@cern.ch>
 */
#include <linux/debugfs.h>
#include "fmc-tdc.h"

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

	return 0;
}


void ft_debug_exit(struct fmctdc_dev *ft)
{
	debugfs_remove_recursive(ft->dbg_dir);
}
