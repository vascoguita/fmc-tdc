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

/* Gennum chip register */

#define TDC_PCI_SYS_CFG_SYSTEM 	0x800
#define TDC_PCI_CLK_CSR 	0x808


/* Gennum core registers for DMA transactions */
#define TDC_DMA_CTRL_R		0x0
#define TDC_DMA_STAT_R		0x4
#define TDC_DMA_C_START_R	0x8
#define TDC_DMA_H_START_L_R	0xC
#define TDC_DMA_H_START_H_R	0x10
#define TDC_DMA_LEN_R		0x14
#define TDC_DMA_NEXT_L_R	0x18
#define TDC_DMA_NEXT_H_R	0x1C
#define TDC_DMA_ATTRIB_R	0x20

/* ACAM GPX chip registers available */
#define TDC_ACAM_CFG_REG_0	0x20000
#define TDC_ACAM_CFG_REG_1	0x20004
#define TDC_ACAM_CFG_REG_2	0x20008
#define TDC_ACAM_CFG_REG_3	0x2000C
#define TDC_ACAM_CFG_REG_4	0x20010
#define TDC_ACAM_CFG_REG_5	0x20014
#define TDC_ACAM_CFG_REG_6	0x20018
#define TDC_ACAM_CFG_REG_7	0x2001C
#define TDC_ACAM_CFG_REG_11	0x2002C
#define TDC_ACAM_CFG_REG_12	0x20030
#define TDC_ACAM_CFG_REG_14	0x20038

/* ACAM GPX chip registers available (Read-only) */
#define TDC_ACAM_RDBACK_REG_0	0x20040
#define TDC_ACAM_RDBACK_REG_1	0x20044
#define TDC_ACAM_RDBACK_REG_2	0x20048
#define TDC_ACAM_RDBACK_REG_3	0x2004C
#define TDC_ACAM_RDBACK_REG_4	0x20050
#define TDC_ACAM_RDBACK_REG_5	0x20054
#define TDC_ACAM_RDBACK_REG_6	0x20058
#define TDC_ACAM_RDBACK_REG_7	0x2005C
#define TDC_ACAM_RDBACK_REG_8	0x20060
#define TDC_ACAM_RDBACK_REG_9	0x20064
#define TDC_ACAM_RDBACK_REG_10	0x20068
#define TDC_ACAM_RDBACK_REG_11	0x2006C
#define TDC_ACAM_RDBACK_REG_12	0x20070
#define TDC_ACAM_RDBACK_REG_14	0x2007C

/* TDC core registers */
#define TDC_START_UTC_R		0x20080
#define TDC_INPUT_ENABLE_R	0x20084
#define TDC_DELAY_START_R	0x20088
#define TDC_DELAY_1HZ_PULSE_R	0x2008C
#define TDC_IRQ_TSTAMP_THRESH_R	0x20090
#define TDC_IRQ_TIME_THRESH_R	0x20094
#define TDC_DAC_WORD_R		0x20098
#define TDC_CURRENT_UTC_R	0x200A0
#define TDC_IRQ_CODE_R		0x200A4
#define TDC_CIRCULAR_BUF_PTR_R	0x200A8
#define TDC_STATUS_R		0x200AC

#define TDC_CTRL_REG			0x200FC
#define TDC_CTRL_EN_ACQ			BIT(0)
#define TDC_CTRL_DIS_ACQ		BIT(1)
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

/* IRQ register*/
#define TDC_IRQ_REG			0xA0000
#define TDC_IRQ_GNUM_CORE_0		BIT(0)
#define TDC_IRQ_GNUM_CORE_1		BIT(1)
#define TDC_IRQ_TDC_TSTAMP		BIT(2)
#define TDC_IRQ_TDC_TIME_THRESH		BIT(3)

/* Other registers */
#define TDC_CARRIER_1WIRE		0x40000
#define TDC_MEZZANINE_I2C		0x60000
#define TDC_MEZZANINE_1WIRE		0x80000

/* Constants */
#define TDC_CHAN_NUMBER 5

#define TDC_EVENT_BUFFER_SIZE 256
#define TDC_EVENT_CHANNEL_MASK 0x3
#define TDC_EVENT_DACAPO_FLAG BIT(0)

#endif /* __TDC_REGISTERS_H */
