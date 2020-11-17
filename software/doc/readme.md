Library Overview {#mainpage}
================
This is the **fmc-tdc** library documentation. Here you can find all
the information about the *fmc-tdc* API and the main library behaviour that
you need to be aware of.

If you are reading this from the doxygen documentation, then you can find
the API documentation in the usual Doxygen places. Otherwise, you can get
the API documentation directly from the source code that you can find in
the *lib* directory.

In this document we are going to provides you some clues to understand how
to use the libray API.

Initialization
==============
To be able to use this library the first thing to do is to initialize a library
instance using fmctdc_init(); form this point on you are able to use the
library API. Of course, when you finished to use the library you have to
remove this instance using fmctdc_exit().

By default all TDC channels are disabled. So, in order to start the time-stamps
acquisition you have to enables your channels using fmctdc_channel_enable().

Now you are ready to read your time-stamps. The procedure to read time-stamp is:
-# open a channel with fmctdc_open()
-# read time-stamps as much as you want with fmctdc_read()
-# close the channel with fmctdc_close()

If you fear that the channel buffer is not empyt when you start your acquisition
you can flush it by using fmctdc_flush(). Calling fmctdc_flush() will temporary
disable the acquisition on the given channel.

Time Stamps
===========
The main purpose of this library is to provide *time-stamps* without any
specific policy. All special policies to apply to the time-stamps must be
done on your side.

MODES
-----
The library provides two time-stamp modes that you can configure for
each channel: **base-time** and **difference-time**. The selection of
one or the other mode will change the meaning of the time-stamp that
you will read. To select the time-stamp mode you have to use
the fmctdc_reference_set() function.


The standard mode is the *base-time* mode. When the library is in this mode
for a given channel, the time-stamps coming from this channel will be pure
time-stamps according to the TDC internal base-time.

The *difference-time* mode can be enabled by assigning a channel reference
to a given channel (a.k.a. target). When you assing a channel reference to
a channel the time-stamp produced by will be a time difference between the
pulse on the target channel and the last pulse on the reference channel.
In order to disable the *difference-time* mode, and go back to
the *base-time* mode, you must remove the channel reference.

Bear in mind that the time-stamp mode will affect immediatly the time-stamp
acquisition but **not** the time-stamps already in the buffer.


Buffer
======
The buffer is place where time-stamps are stored. You can configure only the
lenght of the buffer and its operational mode

Modes
-----
You have mainly two buffer modes: **FIFO** and **CIRC** (circular). You can
change the buffer mode for a singel channel using fmctdc_set_buffer_mode().
In *FIFO* mode when the buffer is full all new time-stamps will be dropped,
instead when you use *CIRC* mode old time-stamps will be overwritten by
the new ones.