..
  SPDX-License-Identifier: CC-BY-SA-4.0
  SPDX-FileCopyrightText: 2022 CERN

Tools
=====

The driver is distributed with a few tools living in the ``tools/``
subdirectory, most of these tools use the fmc-tdc library.
The programs are meant to provide examples about the use of the driver and
library interface.

List TDC boards
---------------

The tool ``fmc-tdc-list`` is capable of listing the available boards in
the system. Below is the output from the command on an example system
with 3 SPEC boards, each populated with a TDC mezzanine.
::

    $ fmc-tdc-list
    FMC-TDC Device ID 0019
    FMC-TDC Device ID 0018
    FMC-TDC Device ID 0017


Termination Configuration
-------------------------
The tool ``fmc-tdc-term`` enables or disables the 50 Ohm termination
of a given input channel. The listing below shows the run of ``fmc-tdc-term``
tool to get the current status of the 50 Ohm termination on the TDC board with
an ID assigned to 4:
::

    $ fmc-tdc-term 0x4
    channel 0: 50 Ohm termination is off
    channel 1: 50 Ohm termination is off
    channel 2: 50 Ohm termination is off
    channel 3: 50 Ohm termination is off
    channel 4: 50 Ohm termination is off

To set the 50 Ohm termination e.g. on channel 0 on the TDC board with an ID
assigned to 4 please execute the following command:
::

    $ fmc-tdc-term 0x4 0 on
    channel 0: 50 Ohm termination is on

Reading Temperature
-------------------
The tool ``fmc-tdc-temperature`` allows to read the current temperature of
the TDC board.
The command below reads the temperature of the TDC board with an ID assigned
to 4:
::

  $ fmc-tdc-temperature 0x4
  31.4 deg C



Getting And Setting Board Time
------------------------------
The tool ``fmc-tdc-time`` allows to read and switch the time source to
White-Rabbit or local oscillator. The command below gets the information about
the current time source:
::

    $ fmc-tdc-time 0x4 get
    WR Status: synchronized.
    Current TAI time is 1647471357.000000000 s

In the example above, the time source has been set to White-Rabbit.
To set the time source to the local oscillator:
::

    $ fmc-tdc-time 0x4 local
    # no output after the command is executed

To set the time source to the White-Rabbit:
::

    $ fmc-tdc-time 0x4 wr
    Locking the card to WR: ... locked!

Read Timestamps
---------------
The tool ``fmc-tdc-tstamp`` can print acquired timestamps. In the example below
the tool prints 5 samples (``-s`` parameter) from the channel 2 (``-c`` parameter)
on the board with the ID 0x19 (``-D`` parameter).
::

    fmc-tdc-tstamp -D 0x19 -c 2 -s 5
    channel 2 | channel seq 0           
        ts   0000041028s  590492339195ps
        diff 0000041028s  590492339195ps [0.000024 Hz]
    channel 2 | channel seq 1
        ts   0000041028s  591492339023ps
        diff 0000000000s  000999999828ps [1000.001000 Hz]
    channel 2 | channel seq 2
        ts   0000041028s  592492338931ps
        diff 0000000000s  000999999908ps [1000.001000 Hz]
    channel 2 | channel seq 3
        ts   0000041028s  593492338597ps
        diff 0000000000s  000999999666ps [1000.001000 Hz]
    channel 2 | channel seq 4
        ts   0000041028s  594492338425ps
        diff 0000000000s  000999999828ps [1000.001000 Hz]


User Offset Configuration
-------------------------
The tool ``fmc-tdc-offset`` sets or gets the user-offset applied to the incoming
timestamps. The example below show that all offsets are set to 0 in an example
setup.
::

    $ fmc-tdc-offset 0x19
    channel 0: 0 ps
    channel 1: 0 ps
    channel 2: 0 ps
    channel 3: 0 ps
    channel 4: 0 ps


Calibration Data
----------------
The tool ``fmc-tdc-calibration`` reads calibration data from a file that
contains it in binary form and shows it on STDOUT in binary form or in human
readable one (default).
This could be used to change the TDC calibration data at runtime
by redirecting the binary output of this program to the proper 
sysfs binary attribute.
This tool expects all values to be little endian.
Please note that the TDC driver supports only ps precision, but
calibration data is typically stored with sub-picosecond
precision. For this reason, according to your source, calibration
values may disagree on the fs part.

The example below shows the read of calibration data:
::

    $ fmc-tdc-calibration -f /sys/bus/zio/devices/tdc-1n5c-0004/calibration_data
    Temperature: 47 C
    White Rabbit Offset: 229460000 fs
    Zero Offset
      ch1-ch2: -109000 fs
      ch2-ch3: 493000 fs
      ch3-ch4: 499000 fs
      ch4-ch5: 336000 fs
