#!   /usr/bin/env   python
#    coding: utf8

# Copyright CERN, 2012
# Author: Samuel Iglesias Gonsalvez <siglesias@igalia.com>
# Licence: GPL v2 or later.
# Website: http://www.ohwr.org/projects/fmc-tdc-sw

import sys
import cmd
import os, os.path
import stat

from ctypes import *
from optparse import OptionParser

lun = -1;
device = -1;

class tdc_dev (Structure):
    _fields_ = [("dev_id", c_int),
		("lun", c_int),
		("devbase", POINTER(c_char)),
		("sysbase", POINTER(c_char)),
		("chan_config", c_uint32),
		("ctrl", POINTER(c_int)),
		("data", POINTER(c_int))]

class tdc_time (Structure):
    _fields_ = [("utc", c_ulonglong),
		("ticks", c_ulonglong),
		("bins", c_ulonglong),
		("dacapo", c_uint32)]

def print_header():
    print ('')
    print ('\t FMC TDC Testing program \t')
    print ('')
    print ('Author: Samuel Iglesias Gonsalvez - Igalia S.L. ')
    print ('Version: 1.0')
    print ('License: GPLv2 or later')
    print ('Website: http://www.ohwr.org/projects/fmc-tdc-sw')
    print ('')

def chan_mask(chans_str):
    "returns the binary mask representing a string of channels"
    mask = 0
    chans_list = chans_str.split()
    for i in range(len(chans_list)):
        mask = mask | (1 << int(chans_list[i]))
    return mask

class Cli(cmd.Cmd):
    def __init__(self, arg):
        cmd.Cmd.__init__(self)
        self.ruler = ''
        self.libtdc = arg
        self.tdc_open = 0;
	self.tdc = POINTER(tdc_dev)

    def do_version(self, arg):
        "print version, license and author of the test program"

        print_header()

    def do_open(self, arg):
        "open a TDC device: open <lun>"
        
        self.lun = int(arg);

	if (self.lun < 0) or (self.lun > 15):
		print "Bad lun number"
		return

	ptr = POINTER(tdc_dev);
	self.libtdc.tdc_open.restype = ptr;
        self.tdc = self.libtdc.tdc_open(self.lun);
	self.tdc_open = 1;

    def do_close(self, arg):
        "close an open TDC device"

        if self.tdc_open == 0:
            print "No device to close"
            return

        self.libtdc.tdc_close(self.tdc);
        self.tdc_open = 0;

    def do_start_acq (self, arg):
        "start acquisition"

        if (self.tdc_open):
            self.libtdc.tdc_start_acquisition(self.tdc)
	else:
            print "No device open"

    def do_stop_acq (self, arg):
        "stop acquisition"

        if (self.tdc_open):
            self.libtdc.tdc_stop_acquisition(self.tdc)
	else:
            print "No device open"

    def do_set_host_utc_time (self, arg):
        "set board's UTC time with localhost reference"

        if (self.tdc_open):
            self.libtdc.tdc_set_host_utc_time(self.tdc)
	else:
            print "No device open"

    def do_get_circular_buffer_ptr (self, arg):
        "get circular buffer pointer"

        if (self.tdc_open):
            val = c_uint32(0)
            self.libtdc.tdc_get_circular_buffer_pointer(self.tdc, byref(val))
            print val
	else:
            print "No device open"

    def do_clear_dacapo_flag (self, arg):
        "get clear dacapo flag"

        if (self.tdc_open):
            self.libtdc.tdc_clear_dacapo_flag(self.tdc)
	else:
            print "No device open"

    def do_activate_channels (self, arg):
        "Activate all channels"

        if (self.tdc_open):
            self.libtdc.tdc_activate_channels(self.tdc)
	else:
            print "No device open"

    def do_deactivate_channels (self, arg):
        "Deactivate all channels"

        if (self.tdc_open):
            self.libtdc.tdc_deactivate_channels(self.tdc)
	else:
            print "No device open"

    def do_utc_time (self, arg):
	"get/set UTC time in seconds from EPOC: utc_time [value]"

        if (self.tdc_open == 0):
            print "No device open"
            return

	if arg == "":
	    val = c_uint32(0)
            self.libtdc.tdc_get_utc_time(self.tdc, byref(val))
            print val
	else:
	    val = c_uint32(int(arg))
            self.libtdc.tdc_set_utc_time(self.tdc, val)

    def do_timestamp_threshold (self, arg):
	"get/set timestamp threshold: timestamp_threshold [value]"

        if (self.tdc_open == 0):
            print "No device open"
            return

	if arg == "":
	    val = c_uint32(0)
            self.libtdc.tdc_get_timestamp_threshold(self.tdc, byref(val))
            print val
	else:
	    val = c_uint32(int(arg))
            if (val < 0) or (val > 127):
                 print "wrong timestamp value. Valid values [0-127]"
                 return
            self.libtdc.tdc_set_timestamp_threshold(self.tdc, val)

    def do_time_threshold (self, arg):
	"get/set time threshold (in seconds): timestamp_threshold [value]"

        if (self.tdc_open == 0):
            print "No device open"
            return

	if arg == "":
	    val = c_uint32(0)
            self.libtdc.tdc_get_time_threshold(self.tdc, byref(val))
            print val
	else:
	    val = c_uint32(int(arg))
            self.libtdc.tdc_set_time_threshold(self.tdc, val)

    def do_channels_term (self, arg):
	"get/set active channels: active_channels [value]"

        if (self.tdc_open == 0):
            print "No device open"
            return

	if arg == "":
	    val = c_uint32(0)
            self.libtdc.tdc_getchannels_term(self.tdc, byref(val))
            print val
	else:
	    val = c_uint32(chan_mask(arg))
            self.libtdc.tdc_set_channels_term(self.tdc, val)

    def do_read (self, arg):
        "read samples from a channel: read [chan] [samples]"

        if (self.tdc_open == 0):
            print "No device open"
            return

        args = arg.split()
        if (len(args) != 2):
            print "Invalid arguments"
            return

        if (int(args[0]) < 0) or (int(args[0]) > 4):
            print "Invalid channel"
            return

        chan = chan_mask(args[0])
        nsamples = int(args[1])

        ptr = POINTER(tdc_time)
        self.libtdc.tdc_zalloc.restype = ptr
        samples = self.libtdc.tdc_zalloc(nsamples)

        res = self.libtdc.tdc_read(self.tdc, chan, byref(samples[0]), nsamples, 0)
        if (res < 0):
            print "Got no samples"
            return

        for i in range(res):
            print ("Sample: utc: %s ticks: %s bins: %s da_capo: %s"
                   % (samples[i].utc, samples[i].ticks,
                      samples[i].bins, samples[i].dacapo))

        self.libtdc.tdc_free(samples)

    # -------------------------------------------

    def do_EOF(self, arg):
        print
        return True

    def do_quit(self, arg):
        "exit cli"

        return True

    def do_show(self, arg):
        "show current configuration of suite"

        params_to_list = (
            'current_utc', )
        for param in params_to_list:
            if param in self.__dict__:
                print '%-12s' % (param + ':'),
                print self.__getattribute__(param)

    do_q = do_quit
    do_h = cmd.Cmd.do_help

def main():

    usage = ( '%prog: [options] test ...\n'
            'run %prog with option -h or --help for more help' )
    parser = OptionParser(usage)
    parser.add_option("-l", "--lib", dest="lib", type="str",
        help =("Path to the shared library libtdc.so. [default: %default]"))
    parser.add_option("-v", "--version", action="store_true", dest="version")
    parser.set_defaults(version=0, lib="../lib")

    (options, args) = parser.parse_args()

    # validate arguments and set up Suite object
    if options.version :
        print_header()

    s = options.lib + '/libtdc.so'
    libtdc = cdll.LoadLibrary(s);

    # Start the command line interface
    s = Cli(libtdc)
    s.__dict__.update(options.__dict__)
    s.cmdloop("Execute 'help' command or 'h' for more help\nExecute 'quit' or 'q' to exit.\n")

if __name__ == '__main__':
    main()
