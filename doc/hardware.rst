.. SPDX-FileCopyrightText: 2022 CERN (home.cern)
..
.. SPDX-License-Identifier: CC-BY-SA-4.0

Hardware Description
====================

The `FmcTdc` is an FPGA Mezzanine Card (FMC - VITA 57 standard), containing
a 5-channel Time To Digital Converter (TDC). All channels share same time base,
therefore one can relate timestamps of pulses coming to different channels.

Requirements and Supported Platforms
------------------------------------

`FmcTdc` can work with any VITA 57-compliant FMC carrier, provided that
the carrier's FPGA has enough logic resources. This release of the driver
software supports the following carriers:

* SPEC (Simple PCI-Express Carrier),
* SVEC (Simple VME64x Carrier)

In order to operate `FmcTdc`, the following hardware/software components
are required:

* A standard PC with at least one free 4x (or wider) PCI-Express slot and
  a SPEC PCI-Express FMC carrier (supplied with an FmcTdc),
* In case of a VME version: any VME64x crate with a controller (tested on
  a MEN A20 and MEN A25) and a SVEC VME64x FMC carrier (supplied with one
  or two `FmcTdcs`),
* 50-ohm cables with 1-pin LEMO 00 plugs for connecting the I/O signals,
* Any Linux (kernel 3.10+) distribution.

Mechanical/Environmental
------------------------

Mechanical and environmental specification:

* Format: FMC (VITA 57),
* Operating temperature range: 0 - 90 degC,
* Carrier connection: 160-pin Low Pin Count FMC connector.

Electrical
Inputs/Outputs:

* 5 trigger inputs (LEMO 00),
* 6 LEDs: 5 for indicating input pulse, 1 as an PPS indicator,
* Carrier communication via 160-pin Low Pin Count FMC connector.
  
Trigger input:

* TTL/LVTTL levels, DC-coupled,
* 2 kOhm or 50 Ohm input impedance (software-selectable),
* Power-up input impedance: 2 kOhm,
* Protected against short circuit, overcurrent (> 200 mA) and overvoltage
  (up to +15 V),
* Maximum input pulse edge rise time: 20 ns.

Power supply:

* Used power supplies: P12V0, P3V3, P3V3 AUX, VADJ (voltage monitor only).

.. * Typical current consumption: FIXME (P12V0) + FIXME (P3V3).
.. * Power dissipation: [fixme: Eva] W


Timing
------

Input timing:

* Minimum pulse width: 100 ns. Pulses below 100 ns are rejected. Width
  checking is done in gateware by subtracting rising and falling edge
  timestamps.
* Minimum pulse spacing: 100 ns.
* Only rising edges are time tagged.


Time base:

* On-board oscillator accuracy: +/- 4 ppm (i.e. max. 4 ns error for pulses
  separated by 1 ms).
* When using White Rabbit as the timing reference: depending on
  the characteristics of the grandmaster clock and the carrier used.
  Usually < 1ns.

Timestamp transfer modes:

* DMA on SPEC-carrier
* FIFO on SVEC-carrier

Performance:

* TDC precision: 700 ps peak-peak (six sigma). Outliers of ±4 ns are observed
  at the expected frequency of ~ 1 outlier/10M measurements.
* TDC resolution: 81 ps.
* Maximum input pulse rate: Transfer-mode and CPU dependent; some examples:

  * DMA-mode on SPEC-carrier, Siemens IPC847E : continuous 200KHz with the
    minimal processing of samples
  * DMA-mode on SPEC-carrier, Siemens IPC847E : 1 MHz (total from the 5
    channels) in burst of 5k samples
  * FIFO-mode on SVEC-carrier, VME MENA-25: continuous 80KHz with the
    minimal processing of samples
