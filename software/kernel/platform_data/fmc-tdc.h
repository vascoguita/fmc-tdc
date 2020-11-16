/*
 * Copyright (C) 2020 CERN (www.cern.ch)
 * Author: Federico Vaga <federico.vaga@cern.ch>
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#ifndef __FMC_TDC_PDATA_H__
#define __FMC_TDC_PDATA_H__

#define FMC_TDC_BIG_ENDIAN BIT(0)

struct fmc_tdc_platform_data {
	unsigned long flags;
};

#endif
