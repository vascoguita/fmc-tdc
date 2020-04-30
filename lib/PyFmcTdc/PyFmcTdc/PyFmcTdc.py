"""
@package docstring
@author: Federico Vaga <federico.vaga@cern.ch>

SPDX-License-Identifier: LGPL-3.0-or-later
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
        ts = self.seconds
        ts = ts + (self.coarse / 1000000000.0 * 8)
        ts = ts + ((self.frac * 7.999) / 4095) / 1000000000
        return "seq: {:d} timestamp: {:f}".format(self.seq_id, ts)


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

        def __init__(self, libfmctdc, tkn, channel):
            self.libfmctdc = libfmctdc
            self.tkn = tkn
            self.idx = channel

        @property
        def termination(self):
            return bool(self.libfmctdc.fmctdc_get_termination(self.tkn,
                                                              self.idx))

        @termination.setter
        def termination(self, val):
            self.libfmctdc.fmctdc_set_termination(self.tkn, self.idx, int(val))

        @property
        def enable(self):
            return bool(self.libfmctdc.fmctdc_channel_status_get(self.tkn,
                                                                 self.idx))

        @enable.setter
        def enable(self, val):
            self.libfmctdc.fmctdc_channel_status_set(self.tkn, self.idx, int(val))

        @property
        def buffer_mode(self):
            ret = self.libfmctdc.fmctdc_get_buffer_mode(self.tkn, self.idx)
            for k, v in self.BUFFER_MODE.items():
                if ret == v:
                    return k
            raise Exception("Unknown buffer mode")

        @buffer_mode.setter
        def buffer_mode(self, val):
            self.libfmctdc.fmctdc_set_buffer_mode(self.tkn, self.idx,
                                                  self.BUFFER_MODE[val])

        @property
        def buffer_len(self):
            ret = self.libfmctdc.fmctdc_get_buffer_len(self.tkn, self.idx)

        @buffer_len.setter
        def buffer_len(self, val):
            self.libfmctdc.fmctdc_set_buffer_len(self.tkn, self.idx, int(val))

        @property
        def fileno(self):
            return self.libfmctdc.fmctdc_fileno_channel(self.tkn, self.idx)

        @property
        def offset(self):
            off = ctypes.c_int32(0)
            self.libfmctdc.fmctdc_get_offset_user(self.tkn, self.idx,
                                                  ctypes.pointer(off))
            return int(off.value)

        @offset.setter
        def offset(self, val):
            self.libfmctdc.fmctdc_set_offset_user(self.tkn, self.idx,
                                                  int(val))

        @property
        def coalescing_timeout(self):
            timeout = ctypes.c_uint(0)
            self.libfmctdc.fmctdc_coalescing_timeout_get(self.tkn, self.idx,
                                                         ctypes.pointer(timeout))
            return int(timeout.value)

        @coalescing_timeout.setter
        def coalescing_timeout(self, val):
            self.libfmctdc.fmctdc_coalescing_timeout_set(self.tkn, self.idx,
                                                         int(val))

        @property
        def timestamp_mode(self):
            mode = ctypes.c_int(0)
            self.libfmctdc.fmctdc_ts_mode_get(self.tkn, self.idx,
                                              ctypes.pointer(mode))
            for k, v in self.TIMESTAMP_MODE.items():
                if mode.value == v:
                    return k
            raise Exception("Unknown buffer mode")

        @timestamp_mode.setter
        def timestamp_mode(self, val):
            self.libfmctdc.fmctdc_ts_mode_set(self.tkn, self.idx,
                                              self.TIMESTAMP_MODE[val])

        @property
        def stats(self):
            recv = ctypes.c_uint32(0)
            self.libfmctdc.fmctdc_stats_recv_get(self.tkn, self.idx,
                                                 ctypes.pointer(recv))
            trans = ctypes.c_uint32(0)
            self.libfmctdc.fmctdc_stats_recv_get(self.tkn, self.idx,
                                                 ctypes.pointer(trans))
            return (recv.value, trans.value)

        def read(self, n=1, flags=0):
            ts = (FmcTdcTime * n)()
            self.libfmctdc.fmctdc_read(self.tkn, self.idx, ts ,n ,flags)
            return list(ts)

        def fread(self, n=1, flags=0):
            ts = (FmcTdcTime * n)()
            self.libfmctdc.fmctdc_fread(self.tkn, self.idx, ts ,n ,flags)
            return list(ts)

        def flush(self):
            self.libfmctdc.fmctdc_flush(self.tkn, self.idx)

    def __init__(self, devid):
        if devid is None:
            raise Exception("Invalid device ID")
        self.__init_library()
        self.device_id = devid

        self.libfmctdc.fmctdc_init()
        ctypes.set_errno(0)
        self.tkn = self.libfmctdc.fmctdc_open(-1, self.device_id)

        self.chan = []
        for i in range(self.CHANNEL_NUMBER):
            self.chan.append(self.FmcTdcChannel(self.libfmctdc, self.tkn, i))

    def __del__(self):
        self.libfmctdc.fmctdc_close(self.tkn)
        self.libfmctdc.fmctdc_exit()

    def __init_library(self):
        self.libfmctdc = ctypes.CDLL("libfmctdc.so", use_errno=True)

        self.libfmctdc.fmctdc_init.argtypes = []
        self.libfmctdc.fmctdc_init.restype = ctypes.c_int
        self.libfmctdc.fmctdc_init.errcheck = self.__errcheck_int

        self.libfmctdc.fmctdc_strerror.argtypes = [ctypes.c_int]
        self.libfmctdc.fmctdc_strerror.restype = ctypes.c_char_p

        self.libfmctdc.fmctdc_open.argtypes = [ctypes.c_int, ctypes.c_int]
        self.libfmctdc.fmctdc_open.restype = ctypes.c_void_p
        self.libfmctdc.fmctdc_open.errcheck = self.__errcheck_pointer

        self.libfmctdc.fmctdc_close.argtypes = [ctypes.c_void_p]
        self.libfmctdc.fmctdc_close.restype = ctypes.c_int
        self.libfmctdc.fmctdc_close.errcheck = self.__errcheck_int

        # Device
        self.libfmctdc.fmctdc_read_temperature.argtypes = [ctypes.c_void_p]
        self.libfmctdc.fmctdc_read_temperature.restype = ctypes.c_float

        self.libfmctdc.fmctdc_set_termination.argtypes = [ctypes.c_void_p,
                                                          ctypes.c_uint,
                                                          ctypes.c_int]
        self.libfmctdc.fmctdc_transfer_mode.argtypes = [ctypes.c_void_p,
                                                        ctypes.POINTER(ctypes.c_int)]
        self.libfmctdc.fmctdc_transfer_mode.restype = ctypes.c_int
        self.libfmctdc.fmctdc_transfer_mode.errcheck = self.__errcheck_int

        self.libfmctdc.fmctdc_set_buffer_type.argtypes = [ctypes.c_void_p,
                                                          ctypes.c_int]
        self.libfmctdc.fmctdc_set_buffer_type.restype = ctypes.c_int
        self.libfmctdc.fmctdc_set_buffer_type.errcheck = self.__errcheck_int

        self.libfmctdc.fmctdc_get_buffer_type.argtypes = [ctypes.c_void_p]
        self.libfmctdc.fmctdc_get_buffer_type.restype = ctypes.c_int
        self.libfmctdc.fmctdc_get_buffer_type.errcheck = self.__errcheck_int

        self.libfmctdc.fmctdc_set_time.argtypes = [ctypes.c_void_p,
                                                   ctypes.POINTER(FmcTdcTime)]
        self.libfmctdc.fmctdc_set_time.restype = ctypes.c_int
        self.libfmctdc.fmctdc_set_time.errcheck = self.__errcheck_int

        self.libfmctdc.fmctdc_get_time.argtypes = [ctypes.c_void_p,
                                                   ctypes.POINTER(FmcTdcTime)]
        self.libfmctdc.fmctdc_get_time.restype = ctypes.c_int
        self.libfmctdc.fmctdc_get_time.errcheck = self.__errcheck_int

        self.libfmctdc.fmctdc_wr_mode.argtypes =[ctypes.c_void_p,
                                                 ctypes.c_int]
        self.libfmctdc.fmctdc_wr_mode.restype = ctypes.c_int
        self.libfmctdc.fmctdc_wr_mode.errcheck = self.__errcheck_int

        self.libfmctdc.fmctdc_check_wr_mode.argtypes =[ctypes.c_void_p]
        self.libfmctdc.fmctdc_check_wr_mode.restype = ctypes.c_int

        # Channel
        self.libfmctdc.fmctdc_set_termination.restype = ctypes.c_int
        self.libfmctdc.fmctdc_set_termination.errcheck = self.__errcheck_int

        self.libfmctdc.fmctdc_get_termination.argtypes = [ctypes.c_void_p,
                                                          ctypes.c_uint]
        self.libfmctdc.fmctdc_get_termination.restype = ctypes.c_int
        self.libfmctdc.fmctdc_get_termination.errcheck = self.__errcheck_int

        self.libfmctdc.fmctdc_channel_status_set.argtypes = [ctypes.c_void_p,
                                                          ctypes.c_uint,
                                                          ctypes.c_int]
        self.libfmctdc.fmctdc_channel_status_set.restype = ctypes.c_int
        self.libfmctdc.fmctdc_channel_status_set.errcheck = self.__errcheck_int

        self.libfmctdc.fmctdc_channel_status_get.argtypes = [ctypes.c_void_p,
                                                          ctypes.c_uint]
        self.libfmctdc.fmctdc_channel_status_get.restype = ctypes.c_int
        self.libfmctdc.fmctdc_channel_status_get.errcheck = self.__errcheck_int

        self.libfmctdc.fmctdc_set_buffer_mode.argtypes = [ctypes.c_void_p,
                                                          ctypes.c_uint,
                                                          ctypes.c_int]
        self.libfmctdc.fmctdc_set_buffer_mode.restype = ctypes.c_int
        self.libfmctdc.fmctdc_set_buffer_mode.errcheck = self.__errcheck_int

        self.libfmctdc.fmctdc_get_buffer_mode.argtypes = [ctypes.c_void_p,
                                                          ctypes.c_uint]
        self.libfmctdc.fmctdc_get_buffer_mode.restype = ctypes.c_int
        self.libfmctdc.fmctdc_get_buffer_mode.errcheck = self.__errcheck_int

        self.libfmctdc.fmctdc_set_buffer_len.argtypes = [ctypes.c_void_p,
                                                          ctypes.c_uint,
                                                          ctypes.c_uint]
        self.libfmctdc.fmctdc_set_buffer_len.restype = ctypes.c_int
        self.libfmctdc.fmctdc_set_buffer_len.errcheck = self.__errcheck_int

        self.libfmctdc.fmctdc_get_buffer_len.argtypes = [ctypes.c_void_p,
                                                         ctypes.c_uint]
        self.libfmctdc.fmctdc_get_buffer_len.restype = ctypes.c_int
        self.libfmctdc.fmctdc_get_buffer_len.errcheck = self.__errcheck_int

        self.libfmctdc.fmctdc_fileno_channel.argtypes = [ctypes.c_void_p,
                                                         ctypes.c_uint]
        self.libfmctdc.fmctdc_fileno_channel.restype = ctypes.c_int
        self.libfmctdc.fmctdc_fileno_channel.errcheck = self.__errcheck_int

        self.libfmctdc.fmctdc_read.argtypes = [ctypes.c_void_p,
                                               ctypes.c_uint,
                                               ctypes.POINTER(FmcTdcTime),
                                               ctypes.c_int,
                                               ctypes.c_int,
                                               ]
        self.libfmctdc.fmctdc_read.restype = ctypes.c_int
        self.libfmctdc.fmctdc_read.errcheck = self.__errcheck_int

        self.libfmctdc.fmctdc_fread.argtypes = [ctypes.c_void_p,
                                                ctypes.c_uint,
                                                ctypes.POINTER(FmcTdcTime),
                                                ctypes.c_int,
                                                ctypes.c_int,
                                               ]
        self.libfmctdc.fmctdc_fread.restype = ctypes.c_int
        self.libfmctdc.fmctdc_fread.errcheck = self.__errcheck_int

        self.libfmctdc.fmctdc_flush.argtypes = [ctypes.c_void_p,
                                                ctypes.c_uint]
        self.libfmctdc.fmctdc_flush.restype = ctypes.c_int
        self.libfmctdc.fmctdc_flush.errcheck = self.__errcheck_int

        self.libfmctdc.fmctdc_set_offset_user.argtypes = [ctypes.c_void_p,
                                                          ctypes.c_uint,
                                                          ctypes.c_int32]
        self.libfmctdc.fmctdc_set_offset_user.restype = ctypes.c_int
        self.libfmctdc.fmctdc_set_offset_user.errcheck = self.__errcheck_int

        self.libfmctdc.fmctdc_get_offset_user.argtypes = [ctypes.c_void_p,
                                                          ctypes.c_uint,
                                                          ctypes.POINTER(ctypes.c_int32)]
        self.libfmctdc.fmctdc_get_offset_user.restype = ctypes.c_int
        self.libfmctdc.fmctdc_get_offset_user.errcheck = self.__errcheck_int

        self.libfmctdc.fmctdc_ts_mode_set.argtypes = [ctypes.c_void_p,
                                                      ctypes.c_uint,
                                                      ctypes.c_int]
        self.libfmctdc.fmctdc_ts_mode_set.restype = ctypes.c_int
        self.libfmctdc.fmctdc_ts_mode_set.errcheck = self.__errcheck_int

        self.libfmctdc.fmctdc_ts_mode_get.argtypes = [ctypes.c_void_p,
                                                      ctypes.c_uint,
                                                      ctypes.POINTER(ctypes.c_int)]
        self.libfmctdc.fmctdc_ts_mode_get.restype = ctypes.c_int
        self.libfmctdc.fmctdc_ts_mode_get.errcheck = self.__errcheck_int

        self.libfmctdc.fmctdc_stats_recv_get.argtypes = [ctypes.c_void_p,
                                                         ctypes.c_uint,
                                                         ctypes.POINTER(ctypes.c_uint32)]
        self.libfmctdc.fmctdc_stats_recv_get.restype = ctypes.c_int
        self.libfmctdc.fmctdc_stats_recv_get.errcheck = self.__errcheck_int

        self.libfmctdc.fmctdc_stats_trans_get.argtypes = [ctypes.c_void_p,
                                                          ctypes.c_uint,
                                                          ctypes.POINTER(ctypes.c_uint32)]
        self.libfmctdc.fmctdc_stats_trans_get.restype = ctypes.c_int
        self.libfmctdc.fmctdc_stats_trans_get.errcheck = self.__errcheck_int

        self.libfmctdc.fmctdc_coalescing_timeout_set.argtypes = [ctypes.c_void_p,
                                                                 ctypes.c_uint,
                                                                 ctypes.c_uint]
        self.libfmctdc.fmctdc_coalescing_timeout_set.restype = ctypes.c_int
        self.libfmctdc.fmctdc_coalescing_timeout_set.errcheck = self.__errcheck_int

        self.libfmctdc.fmctdc_coalescing_timeout_get.argtypes = [ctypes.c_void_p,
                                                                 ctypes.c_uint,
                                                                 ctypes.POINTER(ctypes.c_uint)]
        self.libfmctdc.fmctdc_coalescing_timeout_get.restype = ctypes.c_int
        self.libfmctdc.fmctdc_coalescing_timeout_get.errcheck = self.__errcheck_int

    @property
    def temperature(self):
        return self.libfmctdc.fmctdc_read_temperature(self.tkn)

    @property
    def time(self):
        ts = FmcTdcTime()
        self.libfmctdc.fmctdc_get_time(self.tkn, ctypes.pointer(ts))
        return ts

    @time.setter
    def time(self, val):
        self.libfmctdc.fmctdc_set_time(self.tkn, ctypes.pointer(val))

    @property
    def whiterabbit_mode(self):
        ret = self.libfmctdc.fmctdc_check_wr_mode(self.tkn)
        if ret == 0:
            return True
        elif ret == -1 and ctypes.get_errno() == errno.ENODEV:
            return False
        else:
            raise OSError(ctypes.get_errno(),
                          self.libfmctdc.fmctdc_strerror(ctypes.get_errno()), "")

    @whiterabbit_mode.setter
    def whiterabbit_mode(self, val):
        self.libfmctdc.fmctdc_wr_mode(self.tkn, int(val))
        end = time.time() + 30
        timeout = True
        while time.time() < end:
            time.sleep(0.1)
            ret = self.libfmctdc.fmctdc_check_wr_mode(self.tkn)
            if val and ret == 0:
                timeout = False
                break
            if not val and ret == -1 and ctypes.get_errno() == errno.ENODEV:
                timeout = False
                break
        if timeout:
            raise OSError(ctypes.get_errno(),
                          self.libfmctdc.fmctdc_strerror(ctypes.get_errno()), "")

    @property
    def buffer_type(self):
        ret = self.libfmctdc.fmctdc_get_buffer_type(self.tkn)
        for k, v in self.BUFFER_TYPE.items():
            if ret == v:
                return k
        raise Exception("Unknown buffer type")

    @buffer_type.setter
    def buffer_type(self, val):
        self.libfmctdc.fmctdc_set_buffer_type(self.tkn, self.BUFFER_TYPE[val])

    @property
    def transfer_mode(self):
        mode = ctypes.c_int(0)
        self.libfmctdc.fmctdc_transfer_mode(self.tkn, ctypes.pointer(mode))
        for k, v in self.TRANSFER_MODE.items():
            if mode.value == v:
                return k
        raise Exception("Unknown transfer mode")

    def __errcheck_pointer(self, ret, func, args):
        """Generic error handler for functions returning pointers"""
        if ret is None:
            raise OSError(ctypes.get_errno(),
                          self.libfmctdc.fmctdc_strerror(ctypes.get_errno()),
                          "")
        else:
            return ret

    def __errcheck_int(self, ret, func, args):
        """Generic error checker for functions returning 0 as success
        and -1 as error"""
        if ret < 0:
            raise OSError(ctypes.get_errno(),
                          self.libfmctdc.fmctdc_strerror(ctypes.get_errno()),
                          "")
        else:
            return ret
