.. SPDX-FileCopyrightText: 2022 CERN (home.cern)
..
.. SPDX-License-Identifier: CC-BY-SA-4.0+

##################
Memory map summary
##################

FMC-TDC-1NS-5CH mezzanine memory map

+---------------+--------+-------------+-------------+
| HW address    | Type   | Name        | HDL name    |
+---------------+--------+-------------+-------------+
| 0x1000-0x1fff | SUBMAP | one-wire    | one-wire    |
+---------------+--------+-------------+-------------+
| 0x2000-0x2fff | SUBMAP | core        | core        |
+---------------+--------+-------------+-------------+
| 0x3000-0x3fff | SUBMAP | eic         | eic         |
+---------------+--------+-------------+-------------+
| 0x4000-0x4fff | SUBMAP | i2c         | i2c         |
+---------------+--------+-------------+-------------+
| 0x5000-0x5fff | SUBMAP | mem         | mem         |
+---------------+--------+-------------+-------------+
| 0x6000-0x6fff | SUBMAP | mem-dma     | mem-dma     |
+---------------+--------+-------------+-------------+
| 0x7000-0x7fff | SUBMAP | mem-dma-eic | mem-dma-eic |
+---------------+--------+-------------+-------------+

Registers description
=====================
