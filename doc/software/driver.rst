..
  SPDX-License-Identifier: CC-BY-SA-4.0
  SPDX-FileCopyrightText: 2020 CERN

======
Driver
======

Driver Features
===============

Requirements
============

The fmcadc100m14b4ch device driver has been developed and tested on Linux
3.10. Other Linux versions might work as well but it is not guaranteed.

This driver depends on the `zio`_ framework and `fmc`_ library; we
developed and tested against version `zio`_ 1.4 and `fmc`_ 1.1.

The FPGA address space must be visible on the host system. This requires
a driver for the FPGA carrier that exports the FPGA address space to the
host. As of today we support `SPEC`_ and `SVEC`_.


.. _drv_build_install:

Compile And Install
===================

The compile and install the fmctdc1ns5ch device driver you need
first to export the path to its direct dependencies, and then you
execute ``make``. This driver depends on the `zio`_ framework and
`fmc`_ library; on a VME system it depends also on the VME bridge
driver from CERN BE-CEM.

::

      $ cd /path/to/fmc-tdc/software/kernel
      $ export LINUX=/path/to/linux/sources
      $ export ZIO=/path/to/zio
      $ export FMC=/path/to/fmc-sw
      $ export VMEBUS=/path/to/vmebridge
      $ make
      $ make install

.. note::
   Since version v8.0.0 the fmctdc1ns5ch device driver does not
   depend anymore on `fmc-bus`_ subsystem, instead it uses a new
   `fmc`_ library

The building process generates 3 Linux modules:
*kernel/fmc-tdc.ko*, *kernel/fmc-tdc-spec.ko*, and
*kernel/fmc-tdc-svec.ko*.

Top Level Driver
================

The fmctdc is a generic driver for an FPGA device that could
be instanciated on a number of FMC carriers. For each carrier we write
a little Linux module which acts as a top level driver (like the MFD
drivers in the Linux kernel). In these modules there is the knowledge
about the virtual memory range, the IRQ lines, and the DMA engine to
be used.

The top level driver is a platform driver that matches a string
containing the application identifier. The carrier driver builds this
identification string from the device ID embedded into the FPGA
(https://ohwr.org/project/fpga-dev-id).

Module Parameters
=================

The driver accepts a few load-time parameters for configuration. You can
pass them to insmod directly, or write them in ``/etc/modules.conf`` or
the proper file in ``/etc/modutils/``.

The following parameters are used:

irq_timeout_ms=NUMBER
    It sets the IRQ coalesing timeout expressed in milli-seconds
    (ms). By default the value is set to 10ms.
     
test_data_period=NUMBER
    It sets how many fake timestamps to generate every seconds on the
    first channel, 0 to disable. By default the value is set to 0.

dma_buf_ddr_burst_size=NUMBER
    It sets DDR size coalesing timeout expressed in number of
    timestamps. By default the value is set to 16 timestamps.
    
wr_offset_fix=NUMBER
    It overwrites the White-Rabbit calibration offset for calibration
    value computed before 2018. By default this is set to 229460 ps.

.. _zio: https://www.ohwr.org/project/zio
.. _fmc: https://www.ohwr.org/project/fmc-sw
.. _`fmc-bus`: http://www.ohwr.org/projects/fmc-bus
.. _`SVEC`: https://www.ohwr.org/projects/svec
.. _`SPEC`: https://www.ohwr.org/projects/spec

Device Abstraction
==================

This driver is based on the ZIO framework. It supports
initial setup of the board; it allows users to manually configure the
board, to start and stop acquisitions, to force trigger, and to read
all the acquired time-stamps.

The driver is designed as a ZIO driver. ZIO is a framework for
input/output hosted on http://www.ohwr.org/projects/zio.

ZIO devices are organized as csets (channel sets), and each of them
includes channels.  All channels belonging to the same cset trigger
together. This device offers a channel-set for each channel.

.. note::
   Unless specified, the units are the same as for the TDC HDL design.
   Therefore, this driver does not perform any data processing.

The Overall Device
''''''''''''''''''

As said, the device has 5 cset with 1 channel each. Channel sets from
0 to 4 represent the physical channels 1 to 5. In other words a
channel set represents a single TDC channel.

.. graphviz::
  :align: center

    graph layers {
     node [shape=box];
     adc [label="FMC TDC 1NS 5CH"];

     tdc -- cset0;
     tdc -- cset1;
     tdc -- cset2;
     tdc -- cset3;
     tdc -- cset4;

     cset0 -- chan0;
     cset1 -- chan0;
     cset2 -- chan0;
     cset3 -- chan0;
     cset4 -- chan0;
    }

The TDC registers can be accessed in the proper sysfs directory:::

  cd /sys/bus/zio/devices/tdc-1n5c-${ID}.

The overall device (*tdc-1n5c*) provides the following attributes:

calibration_data
  It is a binary attribute which allows the user to change the runt-time
  calibration data (the EEPROM will not be touched). The ``fmc-tdc-calibration``
  tool can be used to read write calibration data.
  To be consistent, this binary interface expects **only** little endian
  values because this is the endianess used to store calibration data for
  this device.

coarse

command

seconds

temperature
  It shows the current temperature

transfer-mode

wr-offset
  
The Channel Set
'''''''''''''''

The TDC has 5 Channel Sets named ``cset[0-4]``. Its attributes are
used to control and monitor each TDC channel individually.  All
channel specific attributes are available at the channel set level.


The Channels
''''''''''''

Because there is a one-to-one relation with the channel set, we have
decided to put all custom attributes at the channel set level. So, at
this level you will find only default ZIO attributes.

The Trigger
'''''''''''
TODO fix this section

In ZIO, the trigger is a separate software module, that can be replaced
at run time. This driver includes its own ZIO trigger type, that is
selected by default when the driver is initialized. You can change
trigger type (for example use the timer ZIO trigger) but this is not the
typical use case for this board.

This is the list of attributes (excluding kernel-generic and ZIO-generic
ones):

enable
     This is a standard zio attribute, and the code uses it to enable or
     disable the hardware trigger (i.e.  internal and external).  By
     default the trigger is enabled.

post-samples, pre-samples
     Number of samples to acquire.  The pre-samples are acquired before
     the actual trigger event (plus its optional delay).  The post
     samples start from the trigger-sample itself.  The total number of
     samples acquired corresponds to the sum of the two numbers.  For
     multi-shot acquisition, each shot acquires that many sample, but
     pre + post must be at most 2048.

The Buffer
''''''''''
TODO fix this section

In ZIO, buffers are separate objects. The framework offers two buffer
types: kmalloc and vmalloc. The former uses the kmalloc function to
allocate each block, the latter uses vmalloc to allocate the whole data
area. While the kmalloc buffer is linked with the core ZIO kernel
module, vmalloc is a separate module. The driver currently prefers
kmalloc, but even when it preferred vmalloc (up to mid June 2013), if
the respective module wad not loaded, ZIO would instantiate kmalloc.

You can change the buffer type, while not acquiring, by writing its name
to the proper attribute. For example::

     echo vmalloc > /sys/bus/zio/devices/adc-100m14b-0200/cset0/current_buffer

The disadvantage of kmalloc is that each block is limited in size.
usually 128kB (but current kernels allows up to 4MB blocks). The bigger
the block the more likely allocation fails. If you make a multi-shot
acquisition you need to ensure the buffer can fit enough blocks, and the
buffer size is defined for each buffer instance, i.e. for each channel.
In this case we acquire only from the interleaved channel, so before
making a 1000-long multishot acquisition you can do::

     export DEV=/sys/bus/zio/devices/adc-100m14b-0200
     echo 1000 > $DEV/cset0/chani/buffer/max-buffer-len

The vmalloc buffer allows mmap support, so when using vmalloc you can
save a copy of your data (actually, you save it automatically if you use
the library calls to allocate and fill the user-space buffer). However,
a vmalloc buffer allocates the whole data space at the beginning, which
may be unsuitable if you have several cards and acquire from one of them
at a time.

The vmalloc buffer type starts off with a size of 128kB, but you can
change it (while not acquiring), by writing to the associated attribute
of the interleaved channel. For example this sets it to 10MB::

     export DEV=/sys/bus/zio/devices/adc-100m14b-0200
     echo 10000 > $DEV/cset0/chani/buffer/max-buffer-kb

The debugfs Interface
=====================

The fmctdc1ns5cha driver exports a set of debugfs attributes which
are supposed to be used only for debugging activities. For each device
instance you will see a directory in ``/sys/kernel/debug/fmc-tdc.*``.

regs
   It dumps the FPGA registers


Reading Data with Char Devices
==============================

To read data from user-space, applications should use the ZIO char
device interface. ZIO creates 2 char devices for each channel (as
documented in ZIO documentation). The TDC can acquire data on each
channel independently, so ZIO creates ten char device, as shown
below::

  $ ls -l /dev/zio/tdc-*
    cr--r----- 1 root root 241, 0 Jan 13 13:36 /dev/zio/tdc-1n5c-000b-0-0-ctrl
    cr--r----- 1 root root 241, 1 Jan 13 13:36 /dev/zio/tdc-1n5c-000b-0-0-data
    cr--r----- 1 root root 241, 2 Jan 13 13:36 /dev/zio/tdc-1n5c-000b-1-0-ctrl
    cr--r----- 1 root root 241, 3 Jan 13 13:36 /dev/zio/tdc-1n5c-000b-1-0-data
    cr--r----- 1 root root 241, 4 Jan 13 13:36 /dev/zio/tdc-1n5c-000b-2-0-ctrl
    cr--r----- 1 root root 241, 5 Jan 13 13:36 /dev/zio/tdc-1n5c-000b-2-0-data
    cr--r----- 1 root root 241, 6 Jan 13 13:36 /dev/zio/tdc-1n5c-000b-3-0-ctrl
    cr--r----- 1 root root 241, 7 Jan 13 13:36 /dev/zio/tdc-1n5c-000b-3-0-data
    cr--r----- 1 root root 241, 8 Jan 13 13:36 /dev/zio/tdc-1n5c-000b-4-0-ctrl
    cr--r----- 1 root root 241, 9 Jan 13 13:36 /dev/zio/tdc-1n5c-000b-4-0-data

If more than one board is probed for, you'll have more similar
pairs of devices, differing in the dev_id field, i.e. the ``000b`` shown
above. The dev_id field is assigned by the Linux kernel platform subsystem.

The char-device model of ZIO is documented in the ZIO manual; basically,
the ctrl device returns metadata and the data device returns data. Items
in there are strictly ordered, so you can read metadata and then the
associated data, or read only data blocks and discard the associated
metadata.

The ``zio-dump`` tool, part of the ZIO distribution, turns metadata and data
into a meaningful grep-friendly text stream.

User Header Files
=================
Both the kernel and the user make use of the same header file
``fmc-tdc.h``. This because they need to share some data stracture and
constants use to interpret data and meta-data in the library or by an
application

Troubleshooting
'''''''''''''''

This chapter lists a few errors that may happen and how to deal with
them.

Installation issue with modules_install
'''''''''''''''''''''''''''''''''''''''

The command ``sudo make modules_install`` may place the modules in the wrong
directory or fail with an error like::

        make: *** /lib/modules/<kernel-version>/build: No such file or directory.

This happens when you compiled by setting ``LINUX=`` and your sudo is not
propagating the environment to its child processes. In this case, you
should run this command instead::

        sudo make modules_install  LINUX=$LINUX