#!   /usr/bin/env   python
#    coding: utf8

# Copyright CERN, 2012
# Author: Samuel Iglesias Gonsalvez <siglesias@igalia.com>
# Licence: GPL v2 or later.
# Website: http://www.ohwr.org

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

def print_header():
    print ('')
    print ('\t FMC TDC Testing program \t')
    print ('')
    print ('Author: Samuel Iglesias Gonsalvez - Igalia S.L. ')
    print ('Version: 1.0')
    print ('License: GPLv2 or later')
    print ('Website: http://www.ohwr.org')
    print ('')

class Cli(cmd.Cmd):
    def __init__(self, arg):
        cmd.Cmd.__init__(self)
        self.ruler = ''
        self.libtdc = arg
        self.tdc_open = 0;

    def do_version(self, arg):
        "print version, license and author of the test program"

        print_header()

    def do_open(self, arg):
        "open a TDC device: open <lun>"
        
        self.lun = arg;
	ptr = POINTER(tdc_dev);
#	self.libtdc.tdc_open.restype = ptr;
        self.tdc = self.libtdc.tdc_open(arg);
	self.tdc_open = 1;

    def do_close(self, arg):
        "close an open TDC device"

        if self.tdc_open == 0:
            print "No device to close"
            return

        self.libtdc.tdc_close(self.tdc);
        self.tdc_open = 0;

    def do_current_utc(self, arg):
        "show current UTC time of the board in seconds"

        if (self.tdc_open):
	    val = c_uint(0)
            print "Current utc time: ",
	    print val
            self.libtdc.tdc_get_utc_time(self.tdc, byref(val))
            print "Current utc time: ",
	    print val
        else:
            print "No device open"

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
