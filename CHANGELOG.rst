..
  SPDX-License-Identifier: CC-0.0
  SPDX-FileCopyrightText: 2019 CERN

=========
Changelog
=========

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
