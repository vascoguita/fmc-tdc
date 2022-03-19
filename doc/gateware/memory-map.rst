..
  SPDX-License-Identifier: CC-BY-SA-4.0
  SPDX-FileCopyrightText: 2022 CERN

==============
The Memory Map
==============


Supported Designs
=================
Here you can find the complete memory MAP for the supported
designs. This will include the TDC registers as well as the carrier
registers and any other component used in an FMC-TDC-1NS-5CH design.

.. toctree::
   :maxdepth: 1
   :caption: Table of Contents

   spec_ref_fmc_tdc
   svec_ref_fmc_tdc

.. _tdc_memory_map:

TDC memory map
==============

Following the memory map for the part of the TDC design that drives
the FMC-TDC-1NS-5CH modules.

.. only:: latex

   .. warning::
      Unfortunately we are not able to include the memory map in PDF format.
      Please for the memory map refer to the online documentation,

.. raw:: html
   :file: regs/fmc_tdc_mezzanine_mmap.htm

One wire
--------

.. only:: latex

   .. warning::
      Unfortunately we are not able to include the memory map in PDF format.
      Please for the memory map refer to the online documentation,

.. raw:: html
   :file: regs/tdc_onewire_wb.html

Core
----

.. #note map not in wb nor cheby file

EIC
---


.. only:: latex

   .. warning::
      Unfortunately we are not able to include the memory map in PDF format.
      Please for the memory map refer to the online documentation,

.. raw:: html
   :file: regs/tdc_eic.html

I2C
---

Not used.

Mem
---

.. only:: latex

   .. warning::
      Unfortunately we are not able to include the memory map in PDF format.
      Please for the memory map refer to the online documentation,

.. raw:: html
   :file: regs/timestamp_fifo_wb.html

Mem DMA
-------

.. only:: latex

   .. warning::
      Unfortunately we are not able to include the memory map in PDF format.
      Please for the memory map refer to the online documentation,

.. raw:: html
   :file: regs/tdc_buffer_control_regs.html

Mem DMA EIC
-----------

.. only:: latex

   .. warning::
      Unfortunately we are not able to include the memory map in PDF format.
      Please for the memory map refer to the online documentation,

.. raw:: html
   :file: regs/dma_eic.html

