..
  SPDX-License-Identifier: CC-BY-SA-4.0
  SPDX-FileCopyrightText: 2022 CERN

============
The Gateware
============

About Source Code
=================

Build from Sources
------------------

The fmc-tdc hdl design make use of the ``hdlmake`` tool. It
automatically fetches the required hdl cores and libraries. It also
generates Makefiles for synthesis/par and simulation.

Here is the procedure to build the FPGA binary image from the hdl
source.::

  # Install ``hdlmake`` (version 3.4).
  # Get fmc-tdc hdl sources.
  git clone https://ohwr.org/project/fmc-tdc.git <src_dir>

  # Goto the synthesis directory.
  cd <src_dir>/hdl/syn/<carrier>/

  # Fetch the dependencies and generate a synthesis Makefile.
  hdlmake

  # Perform synthesis, place, route and generate FPGA bitstream.
  make

Source Code Organisation
------------------------

hdl/rtl/
    TDC specific hdl sources.

hdl/ip_cores/
    Location of fetched hdl cores and libraries.

hdl/top/<design>
    Top-level hdl module for selected design.

hdl/syn/<design>
    Synthesis directory for selected design. This is where the
    synthesis top manifest, the design constraints and the ISE project
    are stored. For each release, the synthesis, place&route and timing
    reports are also saved here.

hdl/testbench/
    Simulation files and testbenches.

Dependencies
------------

The fmc-tdc gateware depends on the following hdl cores and libraries:
`General Cores`_, `DDR3 SP6 core`_, `GN4124 core`_ (SPEC only),
`SPEC`_ (SPEC only) `VME64x Slave`_ (SVEC only), `SVEC`_ (SVEC only),
`WR Cores`_.

These dependencies are managed with GIT submodules. Whenever you checkout
a different branch remember to update the submodules as well.::

  git submodule sync
  git submodule update


.. _`General Cores`: http://www.ohwr.org/projects/general-cores
.. _`DDR3 SP6 core`: http://www.ohwr.org/hdl-core-lib/ddr3-sp6-core
.. _`GN4124 core`: http://www.ohwr.org/hdl-core-lib/gn4124-core
.. _`VME64x Slave`: http://www.ohwr.org/hdl-core-lib/vme64x-core
.. _`SPEC`: https://ohwr.org/project/spec
.. _`SVEC`: https://ohwr.org/project/svec
.. _`Wr cores`: https://ohwr.org/project/wr-cores
