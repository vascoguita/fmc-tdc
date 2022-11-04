..
  SPDX-License-Identifier: CC-BY-SA-4.0
  SPDX-FileCopyrightText: 2022 CERN

The Library
===========
Here you can find all the information about the *fmc-tdc* API and the
main library behaviour that you need to be aware of to write
applications.

This document introduces the developers to the development with the TDC library.
Here you can find an overview about the API, the rational behind it and
examples of its usage. It is not the purpose of the document to describe
the API details. The complete API is available in
:doc:`the Library API <library-api>` section.

.. note::

   The TDC hardware design diverged into different buffering
   structures. One based on FIFOs for `SVEC`_, and one based on
   double-buffering in DDR for `SPEC`_. The API tries to provide the same
   user-experience, however this is not always possible. Functions having
   different behaviour are properly declaring it in their documentation.

.. note::
   This document provides also snippet of code from `example.c`. This
   is only to show you an example, please avoid to blindly copy and
   paste.

Initialization and Cleanup
--------------------------

The library may keep internal information, so the application should
call its initialization function :cpp:func:`fmctdc_init()`. After use,
it should call the exit function :cpp:func:`fmctdc_exit()` to release
any internal data.

.. note::

   :cpp:func:`fmctdc_exit()` is not mandatory, the operating system
   releases anything in any case -- the library doesn't leave unexpected
   files in persistent storage.

These functions don't do anything at this point, but they may be
implemented in later releases.  For example, the library may scan the
system and cache the list of peripheral cards found, to make
later *open* calls faster. For this reason it is **recommended**
to, at least, initialize and release the library before starting.

Following an example from the ``example.c`` code available under ``tools``

.. literalinclude:: ../../software/tools/example.c
   :language: c
   :lines: 55-62

Error Reporting
----------------

Each library function returns values according to standard *libc*
conventions: -1 or NULL (for functions returning ``int`` or pointers,
resp.) is an error indication. When error happens, the :manpage:`errno`
variable is set appropriately.

The :manpage:`errno` values can be standard Posix items like
``EINVAL``, or library-specific values, for example
``FMCTDC_ERR_VMALLOC`` (*driver vmalloc allocator not available*). All
library-specific error values have a value greater than 4096, to
prevent collision with standard values. To convert such values to a
string please use :cpp:func:`fmctdc_strerror()`

Following an example from the ``example.c`` code available under ``tools``

.. literalinclude:: ../../software/tools/example.c
   :language: c
   :lines: 74-76

Opening and closing
--------------------

Each device must be opened before use by calling :cpp:func:`fmctdc_open()`,
and it should be closed after use by calling :cpp:func:`fmctdc_close()`.

.. note ::

   :cpp:func:`fmctdc_close()` is not mandatory, but it is recommended, to
   close if the process is going to terminate, as the library has no
   persistent storage to clean up -- but there may be persistent buffer
   storage allocated, and :cpp:func:`fmctdc_close()` may release it in
   future versions.

The data structure returned by :cpp:func:`fmctdc_open()` is an opaque pointer
used as token to access the API functions. The user is not supposed to use
or modify this pointer.

Another kind of open function has been provided to satisfy CERN's developers
needs. Function :cpp:func:`fmctdc_open_by_lun()`  is the open by LUN
(*Logic Unit Number*); here the LUN concept reflects the *CERN* one.
The usage is exactly the same as :cpp:func:`fmctdc_open()` only that it uses
the LUN instead of the device ID.

No automatic action is taken by :cpp:func:`fmctdc_open()`. Hence, you
may want to flush the buffers before starting a new acquisition
session. You can do this with :cpp:func:`fmctdc_flush()`

.. literalinclude:: ../../software/tools/example.c
   :language: c
   :lines: 73-91

Configuration and Status
------------------------

The TDC configuration API is based on a number of getter and setter
function for each option. These include: *termination*, *IRQ
coalescing timeout*, *board time*, *white-rabbit*, *timestamp mode*.

The *termination* options allows you to set the 50 Ohm channel
termination. You can use the following getter and setter:
:cpp:func:`fmctdc_get_termination()`,
:cpp:func:`fmctdc_set_termination()`.

.. literalinclude:: ../../software/tools/example.c
   :language: c
   :lines: 125-130

The *IRQ coalescing timeout* option allows to force an IRQ when the
timeout expire to inform the driver that there is at least one pending
timestamp to be transfered. You can use the following getter and setter:
:cpp:func:`fmctdc_coalescing_timeout_get()`,
:cpp:func:`fmctdc_coalescing_timeout_set()`.

.. literalinclude:: ../../software/tools/example.c
   :language: c
   :lines: 133-138

The TDC main functionality is to timestap incoming pulses. To assign a
timestamp the board needs a time reference. This can be provided by
the on-board clock, or by the more accurate white-rabbit network.  You
can enable or disable white-rabbit using
:cpp:func:`fmctdc_wr_mode()`. You can check the white-rabbit status
with :cpp:func:`fmctdc_check_wr_mode()`. When working with
white-rabbit the time reference is handled by the white-rabbit
network.

.. literalinclude:: ../../software/tools/example.c
   :language: c
   :lines: 141-146

If you do not have white-rabbit connected to the TDC, or simply this
is not what you want, then be sure to disable. When white-rabbit is
disabled the TDC will use the on-board clock to keep a time
reference. However, in this scenario the user is asked to set first
the time using :cpp:func:`fmctdc_set_time()` or
:cpp:func:`fmctdc_set_host_time()`.

.. literalinclude:: ../../software/tools/example.c
   :language: c
   :lines: 149-151

Whater you are using white-rabbit or not, you can get the current
board time with :cpp:func:`fmctdc_get_time()`.

.. literalinclude:: ../../software/tools/example.c
   :language: c
   :lines: 152-154

Still about time, the user can add it's own offset without changing
the timebase using :cpp:func:`fmctdc_get_offset_user()` and
:cpp:func:`fmctdc_set_offset_user()`.

.. literalinclude:: ../../software/tools/example.c
   :language: c
   :lines: 157-162

Finally, you can monitor the board temperature using
:cpp:func:`fmctdc_read_temperature()`, and pulse and timestamps
statistics with :cpp:func:`fmctdc_stats_recv_get()` and
:cpp:func:`fmctdc_stats_trans_get()`.

.. literalinclude:: ../../software/tools/example.c
   :language: c
   :lines: 226-233

.. note::
   If it can be useful there is one last status function in the API
   used to detect the transfer mode between the driver and the
   board. This function is :cpp:func:`fmctdc_transfer_mode()`

Timestamp buffering has its own set of options. Buffering in hardware
is fixed, it can't be configured, so what we are going to describe
here is the Linux device driver buffering configuration. Because the
TDC driver is based on `ZIO`_, then you can choose the buffer
allocator type. You can handle this option with the pair:
:cpp:func:`fmctdc_get_buffer_type()` and
:cpp:func:`fmctdc_set_buffer_type()`.

.. literalinclude:: ../../software/tools/example.c
   :language: c
   :lines: 165-170

You can configure - and get - the buffer size (number of
timestamps) with: :cpp:func:`fmctdc_get_buffer_len()` and
:cpp:func:`fmctdc_set_buffer_len()`. Beware, that this function works
only when using :cpp:any:`FMCTDC_BUFFER_VMALLOC`.

.. literalinclude:: ../../software/tools/example.c
   :language: c
   :lines: 173-178

Finally, you can select between to modes to handle buffer's overflows:
:cpp:any:`FMCTDC_BUFFER_CIRC` and :cpp:any:`FMCTDC_BUFFER_FIFO`. The
first will discard old timestamps to make space for the new ones, the
latter will discard any new timestamp until the buffer get
consumed. To configure this option you can use:
:cpp:func:`fmctdc_get_buffer_mode()` and
:cpp:func:`fmctdc_set_buffer_mode()`.

.. literalinclude:: ../../software/tools/example.c
   :language: c
   :lines: 181-186

Acquisiton
----------

Before actually being able to get timestamps, the TDC acquisition must
be enabled. The acquisition can be *enabled* or *disabled* through its
gateware using, respectivily, :cpp:func:`fmctdc_channel_enable()` and
:cpp:func:`fmctdc_channel_disable()`.

.. literalinclude:: ../../software/tools/example.c
   :language: c
   :lines: 196-206

To read timestamps you may use functions :cpp:func:`fmctdc_read()`
and :cpp:func:`fmctdc_fread()`. As the name may suggest, the first
behaves like :manpage:`read` and the second as :manpage:`fread`.

.. literalinclude:: ../../software/tools/example.c
   :language: c
   :lines: 220-224

If you need to flush the buffer, you can use :cpp:func:`fmctdc_flush()`.

.. literalinclude:: ../../software/tools/example.c
   :language: c
   :lines: 80-82

Timestamp Math
--------------
The TDC library API has functions to support timestamp math. They
allow you to *add*, *subtract*, *normalize*, and
*approximate*. These functions are: :cpp:func:`fmctdc_ts_add()`,
:cpp:func:`fmctdc_ts_sub()`,
:cpp:func:`fmctdc_ts_norm()`, :cpp:func:`fmctdc_ts_ps()`, and
:cpp:func:`fmctdc_ts_approx_ns()`.

.. # NOTE: the "compare " function is not implemented in the library

.. _`ZIO`: https://www.ohwr.org/project/zio
.. _`SVEC`: https://www.ohwr.org/projects/svec
.. _`SPEC`: https://www.ohwr.org/projects/spec
