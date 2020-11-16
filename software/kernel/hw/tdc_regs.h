/*
 * tdc_registers.h
 *
 * Copyright (c) 2012 CERN (http://www.cern.ch)
 * Author: Samuel Iglesias Gonsalvez <siglesias@igalia.com>
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; version 2 of the License.
 */

#ifndef __TDC_REGISTERS_H
#define __TDC_REGISTERS_H

#include <hw/gennum-dma.h>
#include <hw/tdc_buffer_control_regs.h>

/* Gennum chip register */

#define TDC_REG_ACAM_READBACK(index)  (0x0040 + (index * 4))
#define TDC_REG_ACAM_CONFIG(index)    (0x0000 + (index * 4))

/* TDC core registers */
#define TDC_REG_START_UTC							0x0080
#define TDC_REG_INPUT_ENABLE					0x0084
#define TDC_REG_IRQ_THRESHOLD 0x0090
#define TDC_REG_IRQ_TIMEOUT 0x0094
#define TDC_REG_DAC_TUNE 0x0098
#define TDC_REG_CURRENT_UTC 0x00a0
#define TDC_REG_BUFFER_PTR 0x00a8
#define TDC_REG_STAT 0x00ac
#define TDC_REG_CTRL 0x00fc
#define TDC_REG_WR_CTRL 0x00b4
#define TDC_REG_WR_STAT 0x00b0
#define TDC_REG_FAKE_TS_CSR 0x00b8

/* TDC_REG_FAKE_TS_CSR bits */
#define TDC_FAKE_TS_EN BIT(31)
#define TDC_FAKE_TS_CHAN_MASK 0xE0000000
#define TDC_FAKE_TS_CHAN_SHIFT 28
#define TDC_FAKE_TS_PERIOD_MASK 0x0FFFFFFF
#define TDC_FAKE_TS_PERIOD_SHIFT 0

/* TDC_REG_STAT bits */
#define TDC_STAT_DMA BIT(0)
#define TDC_STAT_FIFO BIT(1)
#define TDC_STAT_FMC_SLOT BIT(2)

#define TDC_FIFO_OFFSET 0x100

#define TDC_WR_CTRL_ENABLE		BIT(0)

#define TDC_WR_STAT_ENABLED		BIT(6)
#define TDC_WR_STAT_LINK		BIT(2)
#define TDC_WR_STAT_TIME_VALID		BIT(8)
#define TDC_WR_STAT_AUX_LOCKED		BIT(4)

/* TDC_REG_CTRL bits */
#define TDC_CTRL_EN_ACQ						BIT(0)
#define TDC_CTRL_DIS_ACQ					BIT(1)
#define TDC_CTRL_LOAD_ACAM_CFG		BIT(2)
#define TDC_CTRL_READ_ACAM_CFG		BIT(3)
#define TDC_CTRL_READ_ACAM_STAT		BIT(4)
#define TDC_CTRL_READ_ACAM_IFIFO1	BIT(5)
#define TDC_CTRL_READ_ACAM_IFIFO2	BIT(6)
#define TDC_CTRL_READ_ACAM_START01_R	BIT(7)
#define TDC_CTRL_RESET_ACAM		BIT(8)
#define TDC_CTRL_LOAD_UTC		BIT(9)
#define TDC_CTRL_CLEAR_DACAPO_FLAG	BIT(10)
#define TDC_CTRL_CONFIG_DAC		BIT(11)

/* TDC_REG_INPUT_ENABLE bits */
#define TDC_INPUT_ENABLE_CH1_SHIFT 16
#define TDC_INPUT_ENABLE_CH2_SHIFT 17
#define TDC_INPUT_ENABLE_CH3_SHIFT 18
#define TDC_INPUT_ENABLE_CH4_SHIFT 19
#define TDC_INPUT_ENABLE_CH5_SHIFT 20

#define TDC_INPUT_ENABLE_FLAG BIT(7)
#define TDC_INPUT_ENABLE_CH1 BIT(TDC_INPUT_ENABLE_CH1_SHIFT)
#define TDC_INPUT_ENABLE_CH2 BIT(TDC_INPUT_ENABLE_CH2_SHIFT)
#define TDC_INPUT_ENABLE_CH3 BIT(TDC_INPUT_ENABLE_CH3_SHIFT)
#define TDC_INPUT_ENABLE_CH4 BIT(TDC_INPUT_ENABLE_CH4_SHIFT)
#define TDC_INPUT_ENABLE_CH5 BIT(TDC_INPUT_ENABLE_CH5_SHIFT)
#define TDC_INPUT_ENABLE_CH_ALL (TDC_INPUT_ENABLE_CH1 | \
				 TDC_INPUT_ENABLE_CH2 | \
				 TDC_INPUT_ENABLE_CH3 | \
				 TDC_INPUT_ENABLE_CH4 | \
				 TDC_INPUT_ENABLE_CH5)

/* IRQ status/enable bits */
#define TDC_IRQ_TDC_TSTAMP		BIT(0)
#define TDC_IRQ_TDC_TIME		BIT(1)

#define TDC_EVENT_BUFFER_SIZE		256
#define TDC_EVENT_CHANNEL_MASK		0xF
#define TDC_EVENT_SLOPE_MASK		0xF0
#define TDC_EVENT_FIFO_LF_MASK		0xF00
#define TDC_EVENT_FIFO_EF_MASK		0xF000
#define TDC_EVENT_DACAPO_FLAG		BIT(0)

/* Carrier CSRs */
#define TDC_REG_CARRIER_CTL0		0x0 /* a.k.a. Carrier revision/PCB id reg */
#define TDC_REG_CARRIER_STATUS		0x4
#define TDC_REG_CARRIER_CTL1		0x8
#define TDC_REG_CARRIER_RST		0xc

#define TDC_CARRIER_CTL0_PLL_STAT_FMC0 	 BIT(5)
#define TDC_CARRIER_CTL0_PLL_STAT_FMC1 	 BIT(6)

#define TDC_CARRIER_CTL1_RSTN_FMC0 	 BIT(3)
#define TDC_CARRIER_CTL1_RSTN_FMC1 	 BIT(4)

#define TDC_SVEC_CARRIER_BASE           0x1000
#define TDC_SPEC_CARRIER_BASE           0x20000
#define TDC_SPEC_DMA_BASE           0x50000

/* TDC core submodule offsets (wrs to the TDC control registers block) */


#define TDC_MEZZ_ONEWIRE_OFFSET 0x1000
#define TDC_MEZZ_CORE_OFFSET 0x2000
#define TDC_MEZZ_EIC_OFFSET 0x3000
#define TDC_MEZZ_I2C_OFFSET 0x4000
#define TDC_MEZZ_MEM_OFFSET 0x5000
#define TDC_MEZZ_MEM_DMA_OFFSET 0x6000
#define TDC_MEZZ_MEM_DMA_EIC_OFFSET 0x7000

#endif /* __TDC_REGISTERS_H */
