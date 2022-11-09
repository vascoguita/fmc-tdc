..
  SPDX-License-Identifier: CC-BY-SA-4.0+
  SPDX-FileCopyrightText: 2020 CERN

======
Driver
======

Driver Features
===============

Requirements
============

The fmc-tdc device driver has been developed and tested on Linux
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
driver from CERN BE-CEM. Additionally it is assumed that location of wbgen2 is
available via ``PATH`` variable.

::

      $ cd /path/to/fmc-tdc/software/kernel
      $ export KERNELSRC=/path/to/linux/sources
      $ export ZIO=/path/to/zio
      $ export FMC=/path/to/fmc-sw
      $ export VMEBUS=/path/to/vmebridge
      $ make
      $ make install

.. note::
   Since version v8.0.0 the fmc-tdc device driver does not
   depend anymore on `fmc-bus`_ subsystem, instead it uses a new
   `fmc`_ library

The building process generates 3 Linux modules:
*kernel/fmc-tdc.ko*, *kernel/fmc-tdc-spec.ko* (for SPEC card), and
*kernel/fmc-tdc-svec.ko* (for SVEC card).

Drivers' Dependencies
=====================

The TDC driver requires the following drivers to function:

* if the used carrier is SPEC then from `spec`_ repository: *gn412x-fcl.ko*,
  *gn412x-gpio.ko*, *spec-gn412x-dma.ko* and *spec-fmc-carrier.ko*
* if the used carrier is SVEC then *vmebus.ko*
* from `general-cores`_ repository: *spi-ocores.ko*, *i2c-ocores.ko*
  and  *htvic.ko* (more details in the section
  `Building General Cores drivers`_)
* from `zio`_ repository: *zio-buf-vmalloc.ko* and *zio.ko*
  (more details in the section `Building ZIO drivers`_)
* from `fmc`_ repository: *fmc.ko*
  (more details in the section `Building FMC driver`_)
* drivers from the kernel tree: *mtd.ko*, *at24.ko*, *m25p80.ko*,
  *i2c_mux.ko* and *fpga-mgr.ko* (available in kernels v4.4 and newer,
  for older kernels see section `Building FPGA manager driver`_)

In addition the following tools are required to build above drivers:

* `cheby`_ (more details in the section `Installing Cheby`_)
* `wbgen2`_ (more details in the section `Installing Wbgen2`_)

Please read the following subsections for details

Building Drivers 
================
This subsection describes the build process of Linux Device Drivers used by
the TDC and tools needed during their build. 

Installing Cheby
''''''''''''''''

Clone *cheby* repository:
::

    $ git clone https://gitlab.cern.ch/cohtdrivers/cheby.git

Install cheby:
::

    $ cd cheby
    $ python setup.py install

It may be required to install *python-setuptools* or *python-setuptools.noarch*
package using your Linux distribution's software manager.

Installing Wbgen2
'''''''''''''''''

Clone *wbgen2* repository:
::

    $ git clone https://ohwr.org/project/wishbone-gen.git

If needed export the location of *wbgen2* (needed for *fmc-tdc* drivers
compilation):
::

    export WBGEN2=/path/to/wishbone-gen/wbgen2

Building FPGA Manager driver
''''''''''''''''''''''''''''

If kernel module *fpga-mgr.ko* is not available in the kernel that is used,
probably the backported version is needed.

Clone backported *fpga-manager* repository:
::

    $ git clone https://gitlab.cern.ch/coht/fpga-manager.git


Build and install kernel module (*fpga-mgr.ko*):
::

    $ cd fpga-manager
    $ export KERNELSRC=/path/to/linux/sources
    $ make
    $ make install

Building ZIO drivers
''''''''''''''''''''


Clone *zio* repository:
::

    $ git clone https://ohwr.org/misc/zio.git


Build and install kernel modules (*zio-buf-vmalloc.ko* and *zio.ko*):
::

    $ cd zio
    $ export KERNELSRC=/path/to/linux/sources
    $ make
    $ make install

Building General cores drivers
''''''''''''''''''''''''''''''

Clone *general-cores* repository:
::

    $ git clone https://ohwr.org/project/general-cores.git


Build and install kernel modules (*spi-ocores.ko*, *i2c-ocores.ko*
and *htvic.ko*):
::

    $ cd general-cores/software
    $ export KERNELSRC=/path/to/linux/sources
    $ make
    $ make install


Building FMC driver
'''''''''''''''''''

Clone *fmc* repository:
::

    $ git clone https://ohwr.org/project/fmc-sw.git

Build and install kernel module (*fmc.ko*):

    $ cd fmc-sw/
    $ export KERNELSRC=/path/to/linux/sources
    $ make
    $ make install

Building SPEC drivers
'''''''''''''''''''''

Clone *spec* repository:
::

    $ git clone https://ohwr.org/project/spec.git


Build and install kernel modules (*gn412x-fcl.ko*, *gn412x-gpio.ko*,
*spec-gn412x-dma.ko* and *spec-fmc-carrier.ko*):
::

    $ cd spec/software
    $ export CHEBY=/path/to/cheby/bin/cheby
    $ export I2C=/path/to/general-cores/software/i2c-ocores
    $ export SPI=/path/to/general-cores/software/spi-ocores
    $ export FPGA_MGR=/path/to/fpga-manager
    $ export FMC=/path/to/fmc-sw
    $ export KERNELSRC=/path/to/linux/sources
    $ make
    $ make install

Building SVEC drivers
'''''''''''''''''''''

Building missing mainline drivers 
'''''''''''''''''''''''''''''''''

It may happen that your system lacks of drivers that are included into
the mainline Linux kernel. This section describes how to build *i2c-mux.ko*
and *m25p80.ko* drivers for CENTOS 7.

The first step is to download the Linux sources that mach the version used
in your system and unpack them using your favorite method. Then prepare sources
for a compilation:
    
::
    make prepare

Select missing drivers by adding ``CONFIG_I2C_MUX=m`` and
``CONFIG_MTD_M25P80=m`` to .config manually, or with a favorite tool (like
``menuconfig``. Start the build of missing drivers:
::

    make M=drivers/i2c/
    make M=drivers/mtd/devices/

Copy drivers from ``drivers/mtd/devices/m25p80.ko`` and ``drivers/i2c/i2c-mux.ko``
to a known place.

.. _zio: https://www.ohwr.org/project/zio
.. _fmc: https://www.ohwr.org/project/fmc-sw
.. _`fmc-bus`: http://www.ohwr.org/projects/fmc-bus
.. _`SVEC`: https://www.ohwr.org/projects/svec
.. _`SPEC`: https://www.ohwr.org/projects/spec
.. _`general-cores`: https://ohwr.org/project/general-cores
.. _`fpga-manager`: https://gitlab.cern.ch/coht/fpga-manager
.. _`wbgen2`: https://ohwr.org/project/wishbone-gen
.. _`cheby`: https://gitlab.cern.ch/cohtdrivers/cheby

Top Level Driver
================

The fmc-tdc is a generic driver for an FPGA device that could
be instanciated on a number of FMC carriers. For each carrier we write
a little Linux module which acts as a top level driver (like the MFD
drivers in the Linux kernel). In these modules there is the knowledge
about the virtual memory range, the IRQ lines, and the DMA engine to
be used.

The top level driver is a platform driver that matches a string
containing the application identifier. The carrier driver builds this
identification string from the device ID embedded into the FPGA
(https://ohwr.org/project/fpga-dev-id).

Loading drivers for SPEC
========================

Load drivers *at24.ko* and *mtd.ko*. They should be distributed with
your Linux distribution in package like ``kernel-plus`` for CENTOS 7 of
``linux-modules`` for Ubuntu. 

::

    sudo modprobe at24
    sudo modprobe mtd

Load drivers from the mainline Linux:
::

    sudo insmod i2c-mux.ko
    sudo insmod m25p80.ko

Load *fmc* drivers:
::

    sudo insmod fmc.ko

Load *fpga-manager* drivers:
::

    sudo insmod fpga-mgr.ko

Load drivers from *general-cores*:
::

    sudo insmod htvic.ko 
    sudo insmod i2c-ocores.ko
    sudo insmod spi-ocores.ko

Load drivers from *spec-sw*:
::

    sudo insmod spec-gn412x-dma.ko 
    sudo insmod gn412x-gpio.ko
    sudo insmod gn412x-fcl.ko
    sudo insmod spec-fmc-carrier.ko 

If you use the custom path to the firmware, set it at the latest at this point.

::

    echo -n <path_to_bitstreams> | sudo tee /sys/module/firmware_class/parameters/path

Load bitstream into SPEC's FPGA:

::

    echo -n <bitstream.bin> | sudo tee /sys/kernel/debug/<PCIe_device>/fpga_firmware

Load the ZIO and TDC drivers:
::

    sudo insmod zio.ko 
    sudo insmod zio-buf-vmalloc.ko 
    sudo insmod fmc-tdc.ko 
    sudo insmod fmc-tdc-spec.ko 

Loading drivers for SVEC
========================

For SVEC the loading procedure is very similar to SPEC. It is required to load
*svec-fmc-carrier.ko* and *fmc-tdc-svec.ko* instead of *spec-fmc-carrier.ko*
and *fmc-tdc-spec.ko*. Additionally, there is no need to load
*spec-gn412x-dma.ko*, *gn412x-gpio.ko* and *gn412x-fcl.ko*, since these
drivers are specific to SPEC.

::

    sudo modprobe at24
    sudo modprobe mtd
    sudo insmod i2c-mux.ko
    sudo insmod m25p80.ko
    sudo insmod fmc.ko
    sudo insmod fpga-mgr.ko
    sudo insmod htvic.ko 
    sudo insmod i2c-ocores.ko
    sudo insmod spi-ocores.ko
    sudo insmod svec-fmc-carrier.ko 
    echo -n <path_to_bitstreams> | sudo tee /sys/module/firmware_class/parameters/path
    echo -n <bitstream.bin> | sudo tee /sys/kernel/debug/svec-vme.<slot>/fpga_firmware
    sudo insmod zio.ko 
    sudo insmod zio-buf-vmalloc.ko 
    sudo insmod fmc-tdc.ko 
    sudo insmod fmc-tdc-svec.ko 

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

The TDC registers can be accessed in the proper sysfs directory:
::

  cd /sys/bus/zio/devices/tdc-1n5c-${ID}

The overall device (*tdc-1n5c*) provides the following attributes:

calibration_data
  It is a binary attribute which allows the user to change the run-time
  calibration data (the EEPROM will not be touched). The ``fmc-tdc-calibration``
  tool can be used to read write calibration data.
  To be consistent, this binary interface expects **only** little endian
  values because this is the endianness used to store calibration data for
  this device.

coarse
 Coarse part of the current TAI time. This value is in nanoseconds with
 8 ns resolution.
 The ``fmc-tdc-time`` tool can be used to read TAI time.

command
 Send the command to the driver. As today it is possible to enable/disable
 White Rabbit, set the board to the current time or check the source of
 the timing.
 The ``fmc-tdc-time`` tool can be used to send the commands related to the
 current time source.

seconds
 Current TAI time in seconds. The ``fmc-tdc-time`` tool can be used to read TAI
 time.

temperature
  It shows the current temperature. To get the temperature in C degrees use
  the formula ``temperature/16``. The ``fmc-tdc-temperature`` tool can be used
  to read the temperature.

transfer-mode
 It shows the current transfer mode. 0 for FIFO, 1 for DMA.

wr-offset
 Offset used by White Rabbit.

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
the respective module was not loaded, ZIO would instantiate kmalloc.

You can change the buffer type, while not acquiring, by writing its name
to the proper attribute. For example::

     echo vmalloc > /sys/bus/zio/devices/tdc-1n5c-0004/cset0/current_buffer

The disadvantage of kmalloc is that each block is limited in size.
usually 128kB (but current kernels allows up to 4MB blocks). The bigger
the block the more likely allocation fails. If you make a multi-shot
acquisition you need to ensure the buffer can fit enough blocks, and the
buffer size is defined for each buffer instance, i.e. for each channel.
In this case we acquire only from the interleaved channel, so before
making a 1000-long multishot acquisition you can do::

     export DEV=/sys/bus/zio/devices/tdc-1n5c-0004
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

     export DEV=/sys/bus/zio/devices/tdc-1n5c-0004
     echo 10000 > $DEV/cset0/chani/buffer/max-buffer-kb

The debugfs Interface
=====================

When the DMA mode is used, the fmctdc1ns5cha driver exports a set of debugfs
attributes which
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

This happens when you compiled by setting ``KERNELSRC=`` and your sudo is not
propagating the environment to its child processes. In this case, you
should run this command instead::

        sudo make modules_install  KERNELSRC=$KERNELSRC
