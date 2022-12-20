..
  SPDX-License-Identifier: CC-BY-SA-4.0+
  SPDX-FileCopyrightText: 2019 CERN

=========
Changelog
=========

8.0.1 - 2022-12-20
==================

Added
-----
- hdl: bitstreams now published under https://be-cem-edl.web.cern.ch/
- doc: now published under https://be-cem-edl.web.cern.ch/
- sw: support for newer Linux kernels
- tst: timestamp validation

Removed
-------
- sw: ZIO dependency

Changed
-------
- bld: many improvements to CI
- bld: build system cleanup
- hdl: update to latest releases of all dependencies
- hdl: introduced FMC presence status to direct readout interface
- tst: improved performance

Fixed
-----
- hdl: fixed wrong reset logic
- sw: fixes from cppcheck and flawfinder report

8.0.0 - 2022-07-06
==================
Added
-----
- hdl,hw: documentation
- performance tests

Changed
-------
- doc: software updates
- sw: minor fixes

8.0.0.rc2 - 2021-07-29
======================
Changed
-------
- sw: better naming in `/dev`
- sw: better hierarchy in `/sys`

Removed
-------
- sw: module parameter to se offset. This is not handled with platform_data from
  the top level driver.

8.0.0.rc1 - 2020-11-17
======================
Added
-----
- hdl,sw: double buffering DMA support for faster timestamping
- hdl,sw: design built on top of spec-base and svec-base
- tst: integration tests with pytest

Changed
-------
- drv,lib: API change fmctdc_buffer_mode() -> fmctdc_transfer_mode()
