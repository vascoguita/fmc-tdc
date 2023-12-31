// SPDX-FileCopyrightText: 2022 CERN (home.cern)
//
// SPDX-License-Identifier: GPL-2.0-or-later

/*
  Register definitions for slave core: TDC EIC

  * File           : hw/tdc_eic.h
  * Author         : auto-generated by wbgen2 from /afs/cern.ch/work/f/fvaga/projects/fmc-tdc/software/kernel/../..//hdl/rtl/wbgen/tdc_eic.wb
  * Created        : Tue Nov 17 11:44:54 2020
  * Standard       : ANSI C

    THIS FILE WAS GENERATED BY wbgen2 FROM SOURCE FILE /afs/cern.ch/work/f/fvaga/projects/fmc-tdc/software/kernel/../..//hdl/rtl/wbgen/tdc_eic.wb
    DO NOT HAND-EDIT UNLESS IT'S ABSOLUTELY NECESSARY!

*/

#ifndef __WBGEN2_REGDEFS_TDC_EIC_WB
#define __WBGEN2_REGDEFS_TDC_EIC_WB

#ifdef __KERNEL__
#include <linux/types.h>
#else
#include <inttypes.h>
#endif

#if defined( __GNUC__)
#define PACKED __attribute__ ((packed))
#else
#error "Unsupported compiler?"
#endif

#ifndef __WBGEN2_MACROS_DEFINED__
#define __WBGEN2_MACROS_DEFINED__
#define WBGEN2_GEN_MASK(offset, size) (((1<<(size))-1) << (offset))
#define WBGEN2_GEN_WRITE(value, offset, size) (((value) & ((1<<(size))-1)) << (offset))
#define WBGEN2_GEN_READ(reg, offset, size) (((reg) >> (offset)) & ((1<<(size))-1))
#define WBGEN2_SIGN_EXTEND(value, bits) (((value) & (1<<bits) ? ~((1<<(bits))-1): 0 ) | (value))
#endif


/* definitions for register: Interrupt disable register */

/* definitions for field: FMC TDC timestamps interrupt (FIFO1) in reg: Interrupt disable register */
#define TDC_EIC_EIC_IDR_TDC_FIFO1             WBGEN2_GEN_MASK(0, 1)

/* definitions for field: FMC TDC timestamps interrupt (FIFO2) in reg: Interrupt disable register */
#define TDC_EIC_EIC_IDR_TDC_FIFO2             WBGEN2_GEN_MASK(1, 1)

/* definitions for field: FMC TDC timestamps interrupt (FIFO3) in reg: Interrupt disable register */
#define TDC_EIC_EIC_IDR_TDC_FIFO3             WBGEN2_GEN_MASK(2, 1)

/* definitions for field: FMC TDC timestamps interrupt (FIFO4) in reg: Interrupt disable register */
#define TDC_EIC_EIC_IDR_TDC_FIFO4             WBGEN2_GEN_MASK(3, 1)

/* definitions for field: FMC TDC timestamps interrupt (FIFO5) in reg: Interrupt disable register */
#define TDC_EIC_EIC_IDR_TDC_FIFO5             WBGEN2_GEN_MASK(4, 1)

/* definitions for field: FMC TDC timestamps interrupt (DMA1) in reg: Interrupt disable register */
#define TDC_EIC_EIC_IDR_TDC_DMA1              WBGEN2_GEN_MASK(5, 1)

/* definitions for field: FMC TDC timestamps interrupt (DMA2) in reg: Interrupt disable register */
#define TDC_EIC_EIC_IDR_TDC_DMA2              WBGEN2_GEN_MASK(6, 1)

/* definitions for field: FMC TDC timestamps interrupt (DMA3) in reg: Interrupt disable register */
#define TDC_EIC_EIC_IDR_TDC_DMA3              WBGEN2_GEN_MASK(7, 1)

/* definitions for field: FMC TDC timestamps interrupt (DMA4) in reg: Interrupt disable register */
#define TDC_EIC_EIC_IDR_TDC_DMA4              WBGEN2_GEN_MASK(8, 1)

/* definitions for field: FMC TDC timestamps interrupt (DMA5) in reg: Interrupt disable register */
#define TDC_EIC_EIC_IDR_TDC_DMA5              WBGEN2_GEN_MASK(9, 1)

/* definitions for register: Interrupt enable register */

/* definitions for field: FMC TDC timestamps interrupt (FIFO1) in reg: Interrupt enable register */
#define TDC_EIC_EIC_IER_TDC_FIFO1             WBGEN2_GEN_MASK(0, 1)

/* definitions for field: FMC TDC timestamps interrupt (FIFO2) in reg: Interrupt enable register */
#define TDC_EIC_EIC_IER_TDC_FIFO2             WBGEN2_GEN_MASK(1, 1)

/* definitions for field: FMC TDC timestamps interrupt (FIFO3) in reg: Interrupt enable register */
#define TDC_EIC_EIC_IER_TDC_FIFO3             WBGEN2_GEN_MASK(2, 1)

/* definitions for field: FMC TDC timestamps interrupt (FIFO4) in reg: Interrupt enable register */
#define TDC_EIC_EIC_IER_TDC_FIFO4             WBGEN2_GEN_MASK(3, 1)

/* definitions for field: FMC TDC timestamps interrupt (FIFO5) in reg: Interrupt enable register */
#define TDC_EIC_EIC_IER_TDC_FIFO5             WBGEN2_GEN_MASK(4, 1)

/* definitions for field: FMC TDC timestamps interrupt (DMA1) in reg: Interrupt enable register */
#define TDC_EIC_EIC_IER_TDC_DMA1              WBGEN2_GEN_MASK(5, 1)

/* definitions for field: FMC TDC timestamps interrupt (DMA2) in reg: Interrupt enable register */
#define TDC_EIC_EIC_IER_TDC_DMA2              WBGEN2_GEN_MASK(6, 1)

/* definitions for field: FMC TDC timestamps interrupt (DMA3) in reg: Interrupt enable register */
#define TDC_EIC_EIC_IER_TDC_DMA3              WBGEN2_GEN_MASK(7, 1)

/* definitions for field: FMC TDC timestamps interrupt (DMA4) in reg: Interrupt enable register */
#define TDC_EIC_EIC_IER_TDC_DMA4              WBGEN2_GEN_MASK(8, 1)

/* definitions for field: FMC TDC timestamps interrupt (DMA5) in reg: Interrupt enable register */
#define TDC_EIC_EIC_IER_TDC_DMA5              WBGEN2_GEN_MASK(9, 1)

/* definitions for register: Interrupt mask register */

/* definitions for field: FMC TDC timestamps interrupt (FIFO1) in reg: Interrupt mask register */
#define TDC_EIC_EIC_IMR_TDC_FIFO1             WBGEN2_GEN_MASK(0, 1)

/* definitions for field: FMC TDC timestamps interrupt (FIFO2) in reg: Interrupt mask register */
#define TDC_EIC_EIC_IMR_TDC_FIFO2             WBGEN2_GEN_MASK(1, 1)

/* definitions for field: FMC TDC timestamps interrupt (FIFO3) in reg: Interrupt mask register */
#define TDC_EIC_EIC_IMR_TDC_FIFO3             WBGEN2_GEN_MASK(2, 1)

/* definitions for field: FMC TDC timestamps interrupt (FIFO4) in reg: Interrupt mask register */
#define TDC_EIC_EIC_IMR_TDC_FIFO4             WBGEN2_GEN_MASK(3, 1)

/* definitions for field: FMC TDC timestamps interrupt (FIFO5) in reg: Interrupt mask register */
#define TDC_EIC_EIC_IMR_TDC_FIFO5             WBGEN2_GEN_MASK(4, 1)

/* definitions for field: FMC TDC timestamps interrupt (DMA1) in reg: Interrupt mask register */
#define TDC_EIC_EIC_IMR_TDC_DMA1              WBGEN2_GEN_MASK(5, 1)

/* definitions for field: FMC TDC timestamps interrupt (DMA2) in reg: Interrupt mask register */
#define TDC_EIC_EIC_IMR_TDC_DMA2              WBGEN2_GEN_MASK(6, 1)

/* definitions for field: FMC TDC timestamps interrupt (DMA3) in reg: Interrupt mask register */
#define TDC_EIC_EIC_IMR_TDC_DMA3              WBGEN2_GEN_MASK(7, 1)

/* definitions for field: FMC TDC timestamps interrupt (DMA4) in reg: Interrupt mask register */
#define TDC_EIC_EIC_IMR_TDC_DMA4              WBGEN2_GEN_MASK(8, 1)

/* definitions for field: FMC TDC timestamps interrupt (DMA5) in reg: Interrupt mask register */
#define TDC_EIC_EIC_IMR_TDC_DMA5              WBGEN2_GEN_MASK(9, 1)

/* definitions for register: Interrupt status register */

/* definitions for field: FMC TDC timestamps interrupt (FIFO1) in reg: Interrupt status register */
#define TDC_EIC_EIC_ISR_TDC_FIFO1             WBGEN2_GEN_MASK(0, 1)

/* definitions for field: FMC TDC timestamps interrupt (FIFO2) in reg: Interrupt status register */
#define TDC_EIC_EIC_ISR_TDC_FIFO2             WBGEN2_GEN_MASK(1, 1)

/* definitions for field: FMC TDC timestamps interrupt (FIFO3) in reg: Interrupt status register */
#define TDC_EIC_EIC_ISR_TDC_FIFO3             WBGEN2_GEN_MASK(2, 1)

/* definitions for field: FMC TDC timestamps interrupt (FIFO4) in reg: Interrupt status register */
#define TDC_EIC_EIC_ISR_TDC_FIFO4             WBGEN2_GEN_MASK(3, 1)

/* definitions for field: FMC TDC timestamps interrupt (FIFO5) in reg: Interrupt status register */
#define TDC_EIC_EIC_ISR_TDC_FIFO5             WBGEN2_GEN_MASK(4, 1)

/* definitions for field: FMC TDC timestamps interrupt (DMA1) in reg: Interrupt status register */
#define TDC_EIC_EIC_ISR_TDC_DMA1              WBGEN2_GEN_MASK(5, 1)

/* definitions for field: FMC TDC timestamps interrupt (DMA2) in reg: Interrupt status register */
#define TDC_EIC_EIC_ISR_TDC_DMA2              WBGEN2_GEN_MASK(6, 1)

/* definitions for field: FMC TDC timestamps interrupt (DMA3) in reg: Interrupt status register */
#define TDC_EIC_EIC_ISR_TDC_DMA3              WBGEN2_GEN_MASK(7, 1)

/* definitions for field: FMC TDC timestamps interrupt (DMA4) in reg: Interrupt status register */
#define TDC_EIC_EIC_ISR_TDC_DMA4              WBGEN2_GEN_MASK(8, 1)

/* definitions for field: FMC TDC timestamps interrupt (DMA5) in reg: Interrupt status register */
#define TDC_EIC_EIC_ISR_TDC_DMA5              WBGEN2_GEN_MASK(9, 1)
/* [0x20]: REG Interrupt disable register */
#define TDC_EIC_REG_EIC_IDR 0x00000000
/* [0x24]: REG Interrupt enable register */
#define TDC_EIC_REG_EIC_IER 0x00000004
/* [0x28]: REG Interrupt mask register */
#define TDC_EIC_REG_EIC_IMR 0x00000008
/* [0x2c]: REG Interrupt status register */
#define TDC_EIC_REG_EIC_ISR 0x0000000c
#endif
