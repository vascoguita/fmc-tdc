"""
SPDX-License-Identifier: GPL-3.0-or-later
SPDX-FileCopyrightText: 2020 CERN
"""

import pytest
import random
import time
import os
from PyFmcTdc import FmcTdc

TDC_FD_CABLING = [2, 1, 3, 4, 4]


def fmctdc_acq_100ms():
    return [(p, int(10**8 / p)) for p in  [ 10**x for x in range(4, 8)]]

@pytest.fixture(scope="function", params=pytest.channels)
def fmctdc_chan(request):
    tdc = FmcTdc(pytest.tdc_id)
    for ch in tdc.chan:
        ch.enable = False
    tdc.chan[request.param].termination = False
    tdc.chan[request.param].timestamp_mode = "post"
    tdc.chan[request.param].flush()
    tdc.chan[request.param].enable = True
    yield tdc.chan[request.param]

class TestFmctdcAcquisition(object):

    def test_acq_single_channel_disable(self, fmctdc_chan, fmcfd):
        """Acquistion does not start if the channel is not enable"""
        fmctdc_chan.enable = False
        fmcfd.generate_pulse(TDC_FD_CABLING[fmctdc_chan.idx], 0, 1000000000, 1, True)
        with pytest.raises(OSError):
            ts = fmctdc_chan.read(1, os.O_NONBLOCK)

    @pytest.mark.parametrize("period_ns,count", fmctdc_acq_100ms)
    def test_acq_chan_stats(self, fmctdc_chan, fmcfd, period_ns, count):
        """Check that unders a controlled acquisiton statistics increase
        correctly. Test 100 milli-second acquisition at different
        frequencies"""
        stats_before = fmctdc_chan.stats
        fmcfd.generate_pulse(TDC_FD_CABLING[fmctdc_chan.idx], 1000,
                             period_ns, count, True)
        stats_after = fmctdc_chan.stats
        assert stats_before[0] + count == stats_after[0]
        assert stats_before[1] + count == stats_after[1]

    @pytest.mark.parametrize("period_ns,count", fmctdc_acq_100ms)
    def test_acq_chan_read_count(self, fmctdc_chan, fmcfd, period_ns, count):
        """Check that unders a controlled acquisiton the number of read
        timestamps is correct. Test 100 milli-second acquisition at different
        frequencies"""
        fmcfd.generate_pulse(TDC_FD_CABLING[fmctdc_chan.idx], 1000,
                             period_ns, count, True)
        ts = fmctdc_chan.read(count, os.O_NONBLOCK)
        assert len(ts) == count

    @pytest.mark.parametrize("period_ns,count", fmctdc_acq_100ms)
    def test_acq_timestamp_seq_num(self, fmctdc_chan, fmcfd, period_ns, count):
        """Check that unders a controlled acquisiton the sequence
        number of each timestamps increase by 1. Test 100 milli-second
        acquisition at different frequencies"""
        fmcfd.generate_pulse(TDC_FD_CABLING[fmctdc_chan.idx], 1000,
                             period_ns, count, True)
        ts = fmctdc_chan.read(count, os.O_NONBLOCK)
        for i in  range(len(ts)):
            if i == 0:
                continue
            assert ts[i].seq_id == ts[i - 1].seq_id + 1
