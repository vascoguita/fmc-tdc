"""
SPDX-License-Identifier: GPL-3.0-or-later
SPDX-FileCopyrightText: 2020 CERN
"""

import pytest
import random
from PyFmcTdc import FmcTdc

class TestFmctdcGetterSetter(object):

    @pytest.mark.parametrize("i", range(FmcTdc.CHANNEL_NUMBER))
    @pytest.mark.parametrize("term", [True, False])
    def test_termination(self, fmctdc, i, term):
        """Set temination and read it back"""
        fmctdc.chan[i].termination = term
        assert term == fmctdc.chan[i].termination


    @pytest.mark.parametrize("i", range(FmcTdc.CHANNEL_NUMBER))
    @pytest.mark.parametrize("term", [True, False])
    def test_termination(self, fmctdc, i, term):
        """Set temination and read it back"""
        fmctdc.chan[i].termination = term
        assert term == fmctdc.chan[i].termination

    # TODO vmalloc error EBUSY
    # @pytest.mark.parametrize("buffer_type", FmcTdc.BUFFER_TYPE.keys())
    # def test_buffer_type(self, fmctdc, buffer_type):
    #     """Set buffer type and read it back"""
    #     fmctdc.buffer_type = buffer_type
    #     assert buffer_type == fmctdc.buffer_type

    def test_transfer_mode(self, fmctdc):
        """Set buffer type and read it back"""
        assert fmctdc.transfer_mode in FmcTdc.TRANSFER_MODE

    @pytest.mark.parametrize("i", range(FmcTdc.CHANNEL_NUMBER))
    @pytest.mark.parametrize("term", [True, False])
    def test_termination(self, fmctdc, i, term):
        """Set temination and read it back"""
        fmctdc.chan[i].termination = term
        assert term == fmctdc.chan[i].termination

    @pytest.mark.parametrize("ch", range(FmcTdc.CHANNEL_NUMBER))
    @pytest.mark.parametrize("enable", [True, False])
    def test_enable(self, fmctdc, ch, enable):
        """Set enable status and read it back"""
        """When a channel gets enabled only that one become enabled all
        the other remains disables"""
        fmctdc.chan[ch].enable = True
        for i in range(FmcTdc.CHANNEL_NUMBER):
            assert fmctdc.chan[i].enable == (i == ch)
        fmctdc.chan[ch].enable = False
        for i in range(FmcTdc.CHANNEL_NUMBER):
            assert fmctdc.chan[i].enable == False

    @pytest.mark.parametrize("i", range(FmcTdc.CHANNEL_NUMBER))
    @pytest.mark.parametrize("buffer_mode", FmcTdc.FmcTdcChannel.BUFFER_MODE.keys())
    def test_buffer_mode(self, fmctdc, i, buffer_mode):
        """Set buffer mode and read it back"""
        fmctdc.chan[i].buffer_mode = buffer_mode
        assert buffer_mode == fmctdc.chan[i].buffer_mode

    # TODO vmalloc problems first
    # @pytest.mark.parametrize("i", range(FmcTdc.CHANNEL_NUMBER))
    # @pytest.mark.parametrize("buffer_len", range(1, 10))
    # def test_buffer_len(self, fmctdc, i, buffer_len):
    #     """Set buffer length and read it back"""
    #     fmctdc.chan[i].buffer_len = buffer_len
    #     assert buffer_len == fmctdc.chan[i].buffer_len

    @pytest.mark.parametrize("i", range(FmcTdc.CHANNEL_NUMBER))
    def test_fileno(self, fmctdc, i):
        """file descriptors are always positive numbers"""
        assert 0 < fmctdc.chan[i].fileno

    @pytest.mark.parametrize("i", range(FmcTdc.CHANNEL_NUMBER))
    @pytest.mark.parametrize("offset", random.sample(range(1000000), 10))
    def test_offset(self, fmctdc, i, offset):
        """Set user offset and read it back"""
        fmctdc.chan[i].offset = offset
        assert offset == fmctdc.chan[i].offset

    @pytest.mark.parametrize("i", range(FmcTdc.CHANNEL_NUMBER))
    def test_stats(self, fmctdc, i):
        """Set user offset and read it back"""
        st = fmctdc.chan[i].stats
