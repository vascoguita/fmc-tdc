"""
@package docstring
@author: Federico Vaga <federico.vaga@cern.ch>

SPDX-License-Identifier: LGPL-2.1-or-later
SPDX-FileCopyrightText: 2020 CERN  (home.cern)
"""

import threading
import ctypes
import errno
import time
import os

class FmcTdcTime(ctypes.Structure):
    _fields_ = [
                ("seconds", ctypes.c_uint64),
                ("coarse", ctypes.c_uint32),
                ("frac", ctypes.c_uint32),
                ("seq_id", ctypes.c_uint32),
                ("debug", ctypes.c_uint32),
                ]

    def __str__(self):
        return "seq: {:d} timestamp: {:f} raw: {:08x}:{:08x}:{:08x}, debug: {:08x}".format(self.seq_id, float(self), self.seconds, self.coarse, self.frac, self.debug)

    def __float__(self):
        ts = self.seconds
        ts = ts + (self.coarse / 1000000000.0 * 8)
        ts = ts + ((self.frac * 8.0) / 4096) / 1000000000
        return ts



def libfmctdc_create():
    """
    Initialize the libfmctdc C library

    :return: a valid object to access the libfmctdc library
    """
    def error_check_int(ret, func, args):
        """Generic error checker for functions returning 0 as success
        and -1 as error"""
        if ret < 0:
            raise OSError(ctypes.get_errno(),
                          fmctdc_strerror(ctypes.get_errno()), "")
        else:
            return ret

    def error_check_pointer(ret, func, args):
        """Generic error handler for functions returning pointers"""
        if ret is None:
            raise OSError(ctypes.get_errno(),
                          fmctdc_strerror(ctypes.get_errno()), "")
        else:
            return ret
    libfmctdc = ctypes.CDLL("libfmctdc.so", use_errno=True)

    libfmctdc.fmctdc_init.argtypes = []
    libfmctdc.fmctdc_init.restype = ctypes.c_int
    libfmctdc.fmctdc_init.errcheck = error_check_int

    libfmctdc.fmctdc_strerror.argtypes = [ctypes.c_int]
    libfmctdc.fmctdc_strerror.restype = ctypes.c_char_p

    libfmctdc.fmctdc_open.argtypes = [ctypes.c_int]
    libfmctdc.fmctdc_open.restype = ctypes.c_void_p
    libfmctdc.fmctdc_open.errcheck = error_check_pointer

    libfmctdc.fmctdc_close.argtypes = [ctypes.c_void_p]
    libfmctdc.fmctdc_close.restype = ctypes.c_int
    libfmctdc.fmctdc_close.errcheck = error_check_int

    # Device
    libfmctdc.fmctdc_read_temperature.argtypes = [ctypes.c_void_p]
    libfmctdc.fmctdc_read_temperature.restype = ctypes.c_float

    libfmctdc.fmctdc_set_termination.argtypes = [ctypes.c_void_p,
                                                 ctypes.c_uint,
                                                 ctypes.c_int]
    libfmctdc.fmctdc_transfer_mode.argtypes = [ctypes.c_void_p,
                                               ctypes.POINTER(ctypes.c_int)]
    libfmctdc.fmctdc_transfer_mode.restype = ctypes.c_int
    libfmctdc.fmctdc_transfer_mode.errcheck = error_check_int

    libfmctdc.fmctdc_set_buffer_type.argtypes = [ctypes.c_void_p,
                                                 ctypes.c_int]
    libfmctdc.fmctdc_set_buffer_type.restype = ctypes.c_int
    libfmctdc.fmctdc_set_buffer_type.errcheck = error_check_int

    libfmctdc.fmctdc_get_buffer_type.argtypes = [ctypes.c_void_p]
    libfmctdc.fmctdc_get_buffer_type.restype = ctypes.c_int
    libfmctdc.fmctdc_get_buffer_type.errcheck = error_check_int

    libfmctdc.fmctdc_set_time.argtypes = [ctypes.c_void_p,
                                          ctypes.POINTER(FmcTdcTime)]
    libfmctdc.fmctdc_set_time.restype = ctypes.c_int
    libfmctdc.fmctdc_set_time.errcheck = error_check_int

    libfmctdc.fmctdc_get_time.argtypes = [ctypes.c_void_p,
                                          ctypes.POINTER(FmcTdcTime)]
    libfmctdc.fmctdc_get_time.restype = ctypes.c_int
    libfmctdc.fmctdc_get_time.errcheck = error_check_int

    libfmctdc.fmctdc_wr_mode.argtypes =[ctypes.c_void_p,
                                        ctypes.c_int]
    libfmctdc.fmctdc_wr_mode.restype = ctypes.c_int
    libfmctdc.fmctdc_wr_mode.errcheck = error_check_int

    libfmctdc.fmctdc_check_wr_mode.argtypes =[ctypes.c_void_p]
    libfmctdc.fmctdc_check_wr_mode.restype = ctypes.c_int

    # Channel
    libfmctdc.fmctdc_set_termination.restype = ctypes.c_int
    libfmctdc.fmctdc_set_termination.errcheck = error_check_int

    libfmctdc.fmctdc_get_termination.argtypes = [ctypes.c_void_p,
                                                 ctypes.c_uint]
    libfmctdc.fmctdc_get_termination.restype = ctypes.c_int
    libfmctdc.fmctdc_get_termination.errcheck = error_check_int

    libfmctdc.fmctdc_channel_status_set.argtypes = [ctypes.c_void_p,
                                                    ctypes.c_uint,
                                                    ctypes.c_int]
    libfmctdc.fmctdc_channel_status_set.restype = ctypes.c_int
    libfmctdc.fmctdc_channel_status_set.errcheck = error_check_int

    libfmctdc.fmctdc_channel_status_get.argtypes = [ctypes.c_void_p,
                                                    ctypes.c_uint]
    libfmctdc.fmctdc_channel_status_get.restype = ctypes.c_int
    libfmctdc.fmctdc_channel_status_get.errcheck = error_check_int

    libfmctdc.fmctdc_set_buffer_mode.argtypes = [ctypes.c_void_p,
                                                 ctypes.c_uint,
                                                 ctypes.c_int]
    libfmctdc.fmctdc_set_buffer_mode.restype = ctypes.c_int
    libfmctdc.fmctdc_set_buffer_mode.errcheck = error_check_int

    libfmctdc.fmctdc_get_buffer_mode.argtypes = [ctypes.c_void_p,
                                                 ctypes.c_uint]
    libfmctdc.fmctdc_get_buffer_mode.restype = ctypes.c_int
    libfmctdc.fmctdc_get_buffer_mode.errcheck = error_check_int

    libfmctdc.fmctdc_set_buffer_len.argtypes = [ctypes.c_void_p,
                                                ctypes.c_uint,
                                                ctypes.c_uint]
    libfmctdc.fmctdc_set_buffer_len.restype = ctypes.c_int
    libfmctdc.fmctdc_set_buffer_len.errcheck = error_check_int

    libfmctdc.fmctdc_get_buffer_len.argtypes = [ctypes.c_void_p,
                                                ctypes.c_uint]
    libfmctdc.fmctdc_get_buffer_len.restype = ctypes.c_int
    libfmctdc.fmctdc_get_buffer_len.errcheck = error_check_int

    libfmctdc.fmctdc_fileno_channel.argtypes = [ctypes.c_void_p,
                                                ctypes.c_uint]
    libfmctdc.fmctdc_fileno_channel.restype = ctypes.c_int
    libfmctdc.fmctdc_fileno_channel.errcheck = error_check_int

    libfmctdc.fmctdc_read.argtypes = [ctypes.c_void_p,
                                      ctypes.c_uint,
                                      ctypes.POINTER(FmcTdcTime),
                                      ctypes.c_int,
                                      ctypes.c_int,
                                      ]
    libfmctdc.fmctdc_read.restype = ctypes.c_int
    libfmctdc.fmctdc_read.errcheck = error_check_int

    libfmctdc.fmctdc_fread.argtypes = [ctypes.c_void_p,
                                       ctypes.c_uint,
                                       ctypes.POINTER(FmcTdcTime),
                                       ctypes.c_int,
                                       ctypes.c_int,
                                       ]
    libfmctdc.fmctdc_fread.restype = ctypes.c_int
    libfmctdc.fmctdc_fread.errcheck = error_check_int

    libfmctdc.fmctdc_flush.argtypes = [ctypes.c_void_p,
                                       ctypes.c_uint]
    libfmctdc.fmctdc_flush.restype = ctypes.c_int
    libfmctdc.fmctdc_flush.errcheck = error_check_int

    libfmctdc.fmctdc_set_offset_user.argtypes = [ctypes.c_void_p,
                                                 ctypes.c_uint,
                                                 ctypes.c_int32]
    libfmctdc.fmctdc_set_offset_user.restype = ctypes.c_int
    libfmctdc.fmctdc_set_offset_user.errcheck = error_check_int

    libfmctdc.fmctdc_get_offset_user.argtypes = [ctypes.c_void_p,
                                                 ctypes.c_uint,
                                                 ctypes.POINTER(ctypes.c_int32)]
    libfmctdc.fmctdc_get_offset_user.restype = ctypes.c_int
    libfmctdc.fmctdc_get_offset_user.errcheck = error_check_int

    libfmctdc.fmctdc_ts_mode_set.argtypes = [ctypes.c_void_p,
                                             ctypes.c_uint,
                                             ctypes.c_int]
    libfmctdc.fmctdc_ts_mode_set.restype = ctypes.c_int
    libfmctdc.fmctdc_ts_mode_set.errcheck = error_check_int

    libfmctdc.fmctdc_ts_mode_get.argtypes = [ctypes.c_void_p,
                                             ctypes.c_uint,
                                             ctypes.POINTER(ctypes.c_int)]
    libfmctdc.fmctdc_ts_mode_get.restype = ctypes.c_int
    libfmctdc.fmctdc_ts_mode_get.errcheck = error_check_int

    libfmctdc.fmctdc_stats_recv_get.argtypes = [ctypes.c_void_p,
                                                ctypes.c_uint,
                                                ctypes.POINTER(ctypes.c_uint32)]
    libfmctdc.fmctdc_stats_recv_get.restype = ctypes.c_int
    libfmctdc.fmctdc_stats_recv_get.errcheck = error_check_int

    libfmctdc.fmctdc_stats_trans_get.argtypes = [ctypes.c_void_p,
                                                 ctypes.c_uint,
                                                 ctypes.POINTER(ctypes.c_uint32)]
    libfmctdc.fmctdc_stats_trans_get.restype = ctypes.c_int
    libfmctdc.fmctdc_stats_trans_get.errcheck = error_check_int

    libfmctdc.fmctdc_coalescing_timeout_set.argtypes = [ctypes.c_void_p,
                                                        ctypes.c_uint,
                                                        ctypes.c_uint]
    libfmctdc.fmctdc_coalescing_timeout_set.restype = ctypes.c_int
    libfmctdc.fmctdc_coalescing_timeout_set.errcheck = error_check_int

    libfmctdc.fmctdc_coalescing_timeout_get.argtypes = [ctypes.c_void_p,
                                                        ctypes.c_uint,
                                                        ctypes.POINTER(ctypes.c_uint)]
    libfmctdc.fmctdc_coalescing_timeout_get.restype = ctypes.c_int
    libfmctdc.fmctdc_coalescing_timeout_get.errcheck = error_check_int

    return libfmctdc

libfmctdc = libfmctdc_create()

def fmctdc_strerror(err):
    """
    Return FMC-TDC errors

    :ivar err: error number
    :return: an error string
    """
    return libfmctdc.fmctdc_strerror(err)

class FmcTdc(object):
    """
    It is a Python class that represent an FMC TDC device

    :param devid: FMC TDC device identifier

    :ivar device_id: device ID associated with the instance
    :ivar tkn: device token to be used with the libfmctdc library
    :ivar libfmctdc: the libfmctdc library
    """

    CHANNEL_NUMBER = 5
    BUFFER_TYPE = {"kmalloc": 0,
                   "vmalloc": 1}
    TRANSFER_MODE = {"fifo": 0,
                     "dma": 1}

    class FmcTdcChannel(object):
        BUFFER_MODE = {"fifo": 0,
                       "circ": 1}
        TIMESTAMP_MODE = {"post": 0,
                          "raw": 1}

        def __init__(self, tkn, channel):
            self.tkn = tkn
            self.idx = channel

        @property
        def termination(self):
            return bool(libfmctdc.fmctdc_get_termination(self.tkn, self.idx))

        @termination.setter
        def termination(self, val):
            libfmctdc.fmctdc_set_termination(self.tkn, self.idx, int(val))

        @property
        def enable(self):
            return bool(libfmctdc.fmctdc_channel_status_get(self.tkn,
                                                            self.idx))

        @enable.setter
        def enable(self, val):
            libfmctdc.fmctdc_channel_status_set(self.tkn, self.idx, int(val))

        @property
        def buffer_mode(self):
            ret = libfmctdc.fmctdc_get_buffer_mode(self.tkn, self.idx)
            for k, v in self.BUFFER_MODE.items():
                if ret == v:
                    return k
            raise Exception("Unknown buffer mode")

        @buffer_mode.setter
        def buffer_mode(self, val):
            libfmctdc.fmctdc_set_buffer_mode(self.tkn, self.idx,
                                             self.BUFFER_MODE[val])

        @property
        def buffer_len(self):
            ret = libfmctdc.fmctdc_get_buffer_len(self.tkn, self.idx)

        @buffer_len.setter
        def buffer_len(self, val):
            libfmctdc.fmctdc_set_buffer_len(self.tkn, self.idx, int(val))

        @property
        def fileno(self):
            return libfmctdc.fmctdc_fileno_channel(self.tkn, self.idx)

        @property
        def offset(self):
            off = ctypes.c_int32(0)
            libfmctdc.fmctdc_get_offset_user(self.tkn, self.idx,
                                             ctypes.pointer(off))
            return int(off.value)

        @offset.setter
        def offset(self, val):
            libfmctdc.fmctdc_set_offset_user(self.tkn, self.idx,
                                             int(val))

        @property
        def coalescing_timeout(self):
            timeout = ctypes.c_uint(0)
            libfmctdc.fmctdc_coalescing_timeout_get(self.tkn, self.idx,
                                                    ctypes.pointer(timeout))
            return int(timeout.value)

        @coalescing_timeout.setter
        def coalescing_timeout(self, val):
            libfmctdc.fmctdc_coalescing_timeout_set(self.tkn, self.idx,
                                                    int(val))

        @property
        def timestamp_mode(self):
            mode = ctypes.c_int(0)
            libfmctdc.fmctdc_ts_mode_get(self.tkn, self.idx,
                                         ctypes.pointer(mode))
            for k, v in self.TIMESTAMP_MODE.items():
                if mode.value == v:
                    return k
            raise Exception("Unknown buffer mode")

        @timestamp_mode.setter
        def timestamp_mode(self, val):
            libfmctdc.fmctdc_ts_mode_set(self.tkn, self.idx,
                                         self.TIMESTAMP_MODE[val])

        @property
        def stats(self):
            recv = ctypes.c_uint32(0)
            libfmctdc.fmctdc_stats_recv_get(self.tkn, self.idx,
                                            ctypes.pointer(recv))
            trans = ctypes.c_uint32(0)
            libfmctdc.fmctdc_stats_recv_get(self.tkn, self.idx,
                                            ctypes.pointer(trans))
            return (recv.value, trans.value)

        def read(self, n=1, flags=0):
            ts = (FmcTdcTime * n)()
            ret = libfmctdc.fmctdc_read(self.tkn, self.idx, ts ,n ,flags)
            return list(ts)[:ret]

        def fread(self, n=1, flags=0):
            ts = (FmcTdcTime * n)()
            libfmctdc.fmctdc_fread(self.tkn, self.idx, ts, n ,flags)
            return list(ts)

        def flush(self):
            libfmctdc.fmctdc_flush(self.tkn, self.idx)

    def __init__(self, devid):
        if devid is None:
            raise Exception("Invalid device ID")
        self.device_id = devid

        libfmctdc.fmctdc_init()
        ctypes.set_errno(0)
        self.tkn = libfmctdc.fmctdc_open(self.device_id)

        self.chan = []
        for i in range(self.CHANNEL_NUMBER):
            self.chan.append(self.FmcTdcChannel(self.tkn, i))

    def __del__(self):
        if hasattr(self, 'tkn'):
            libfmctdc.fmctdc_close(self.tkn)
        libfmctdc.fmctdc_exit()

    @property
    def temperature(self):
        return libfmctdc.fmctdc_read_temperature(self.tkn)

    @property
    def time(self):
        ts = FmcTdcTime()
        libfmctdc.fmctdc_get_time(self.tkn, ctypes.pointer(ts))
        return ts

    @time.setter
    def time(self, val):
        libfmctdc.fmctdc_set_time(self.tkn, ctypes.pointer(val))

    @property
    def whiterabbit_mode(self):
        ret = libfmctdc.fmctdc_check_wr_mode(self.tkn)
        if ret == 0:
            return True
        elif ret == -1 and ctypes.get_errno() == errno.ENODEV:
            return False
        else:
            raise OSError(ctypes.get_errno(),
                          fmctdc_strerror(ctypes.get_errno()), "")

    @whiterabbit_mode.setter
    def whiterabbit_mode(self, val):
        libfmctdc.fmctdc_wr_mode(self.tkn, int(val))
        end = time.time() + 30
        timeout = True
        while time.time() < end:
            time.sleep(0.1)
            ret = libfmctdc.fmctdc_check_wr_mode(self.tkn)
            if val and ret == 0:
                timeout = False
                break
            if not val and ret == -1 and ctypes.get_errno() == errno.ENODEV:
                timeout = False
                break
        if timeout:
            raise OSError(ctypes.get_errno(),
                          fmctdc_strerror(ctypes.get_errno()), "")

    @property
    def buffer_type(self):
        ret = libfmctdc.fmctdc_get_buffer_type(self.tkn)
        for k, v in self.BUFFER_TYPE.items():
            if ret == v:
                return k
        raise Exception("Unknown buffer type")

    @buffer_type.setter
    def buffer_type(self, val):
        libfmctdc.fmctdc_set_buffer_type(self.tkn, self.BUFFER_TYPE[val])

    @property
    def transfer_mode(self):
        mode = ctypes.c_int(0)
        libfmctdc.fmctdc_transfer_mode(self.tkn, ctypes.pointer(mode))
        for k, v in self.TRANSFER_MODE.items():
            if mode.value == v:
                return k
        raise Exception("Unknown transfer mode")
