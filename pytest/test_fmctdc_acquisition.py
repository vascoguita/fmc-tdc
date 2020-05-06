"""
SPDX-License-Identifier: GPL-3.0-or-later
SPDX-FileCopyrightText: 2020 CERN
"""

import pytest
import random
import select
import time
import sys
import os
from PyFmcTdc import FmcTdc

TDC_FD_CABLING = [2, 1, 3, 4, 4]

fmctdc_acq_100ms = [(p, int(10**8 / p)) for p in  [ 10**x for x in range(4, 8)]]


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
        prev_seq = None
        fmctdc_chan.buffer_len = count
        fmcfd.generate_pulse(TDC_FD_CABLING[fmctdc_chan.idx], 1000,
                             period_ns, count, True)
        ts = fmctdc_chan.read(count, os.O_NONBLOCK)
        for i in  range(len(ts)):
            if prev_seq == None:
                prev_seq = ts[i].seq_id
                continue
            assert ts[i].seq_id == prev_seq + 1
            prev_seq = ts[i].seq_id

    @pytest.mark.skipif(0 in pytest.usr_acq,
                        reason="Missing user acquisition option")
    @pytest.mark.skipif(pytest.carrier == "spec" and \
                        pytest.transfer_mode == "fifo" and \
                        pytest.usr_acq[0] < 7000,
                        reason="On SPEC with FIFO acquisition we can't do more than 100kHz")
    @pytest.mark.parametrize("period_ns,count", [pytest.usr_acq])
    def test_acq_timestamp_single_channel(self, capsys, fmctdc_chan, fmcfd,
                                          period_ns, count):
        """Run an acquisition with users parameters for period and count.
        The Fine-Delay can generate a burst of maximum 65536 pulses, so we
        compute and approximated timeout to stop the test and we let
        the Fine-Delay generating an infinite train of pulses.

        Since the test can be very long, periodically this test will print the
        timestamp sequence number, you should see it increasing.
        """
        poll = select.poll()
        poll.register(fmctdc_chan.fileno, select.POLLIN)
        pending = count
        prev = None
        # be able to buffer for 1 second
        fmctdc_chan.buffer_len = int(1/(period_ns/1000000000.0)) + 1
        stats_o = fmctdc_chan.stats
        trans_b = stats_o[1]
        fmcfd.generate_pulse(TDC_FD_CABLING[fmctdc_chan.idx], 1000,
                             period_ns, 0, False)
        timeout = time.time() + (period_ns * count) / 1000000000.0
        while pending > 0:
            t = time.time()
            if t >= timeout:
                break
            ret = poll.poll(1)
            if len(ret) == 0:
                continue
            ts = fmctdc_chan.read(1000, os.O_NONBLOCK)
            assert len(ts) <= 1000
            for i in range(len(ts)):
                if prev == None:
                    prev = ts[i]
                    continue
                assert ts[i].seq_id == (prev.seq_id + 1) & 0xFFFFFFF, "Missed {:d} timestamps (idx: {:d}, max: {:d}, prev: {{ {:s}, curr: {:s} }}, full dump;\n{:s}".format(ts[i].seq_id - prev.seq_id + 1, i, len(ts), str(prev), str(ts[i]), "\n".join([str(t) for t in ts]))
                prev = ts[i]
            pending -= len(ts)
        poll.unregister(fmctdc_chan.fileno)
        fmcfd.disable(TDC_FD_CABLING[fmctdc_chan.idx])
        assert stats_o[0] == stats_o[1]
        assert fmctdc_chan.stats[0] == fmctdc_chan.stats[1]
        assert fmctdc_chan.stats[0] - stats_o[0] >= count
        assert pending <= 0, "Some timestamp could be missing"
