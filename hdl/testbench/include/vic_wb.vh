// SPDX-FileCopyrightText: 2022 CERN (home.cern)
//
// SPDX-License-Identifier: CERN-OHL-W-2.0+

`define ADDR_VIC_CTL                   8'h0
`define VIC_CTL_ENABLE_OFFSET 0
`define VIC_CTL_ENABLE 32'h00000001
`define VIC_CTL_POL_OFFSET 1
`define VIC_CTL_POL 32'h00000002
`define VIC_CTL_EMU_EDGE_OFFSET 2
`define VIC_CTL_EMU_EDGE 32'h00000004
`define VIC_CTL_EMU_LEN_OFFSET 3
`define VIC_CTL_EMU_LEN 32'h0007fff8
`define ADDR_VIC_RISR                  8'h4
`define ADDR_VIC_IER                   8'h8
`define ADDR_VIC_IDR                   8'hc
`define ADDR_VIC_IMR                   8'h10
`define ADDR_VIC_VAR                   8'h14
`define ADDR_VIC_SWIR                  8'h18
`define ADDR_VIC_EOIR                  8'h1c
`define BASE_VIC_IVT_RAM               8'h80
`define SIZE_VIC_IVT_RAM               32'h20
