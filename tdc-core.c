/*
 * core tdc driver 
 *
 * Copyright (C) 2012 CERN (www.cern.ch)
 * Author: Samuel Iglesias Gonsalvez <siglesias@igalia.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * version 2 as published by the Free Software Foundation.
 */

#include <linux/kernel.h>
#include <linux/module.h>

#include "spec.h"
#include "hw/tdc_regs.h"

static int tdc_init(void)
{
	return 0;
}

static void tdc_exit(void)
{
}

module_init(tdc_init);
module_exit(tdc_exit);

MODULE_LICENSE("GPL");
