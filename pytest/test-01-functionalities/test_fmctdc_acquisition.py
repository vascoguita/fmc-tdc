"""
SPDX-License-Identifier: LGPL-2.1-or-later
SPDX-FileCopyrightText: 2020 CERN
"""

import pytest
import random
import select
import time
import sys
import os
from PyFmcTdc import FmcTdc, FmcTdcTime

TDC_FD_CABLING = [1, 2, 3, 4, 4]

fmctdc_acq_100ns_spec = [(200, 65000),    #   5 MHz
                         (250, 65000),    #   4 MHz
                         (500, 65000),    #   2 MHz
                         (1000, 65000),   #   1 Mhz
                         (1700, 65000),   # 588 kHz
                         # Let's keep the test within 100ms duration
                         # vvvvvvvvvvv
                         (1875, 60000),   # 533 khz
                         (2500, 40000),   # 400 kHz
                         (5000, 20000),   # 200 khz
                         (10000, 10000),  # 100 kHz
                         (12500, 8000),   #  80 kHz
                         (20000, 5000),   #  50 kHz
                         (100000, 1000),  #  10 kHz
                         (1000000, 100),  #   1 kHz
                         (10000000, 10)]  # 100  Hz

fmctdc_acq_100ns_svec = [(13333, 8000),   #  75 kHz
                         (20000, 5000),   #  50 kHz
                         (100000, 1000),  #  10 kHz
                         (1000000, 100),  #   1 kHz
                         (10000000, 10)]  # 100  Hz

fmctdc_acq_100ns = fmctdc_acq_100ns_svec if pytest.transfer_mode == "fifo" else fmctdc_acq_100ns_spec

@pytest.fixture(scope="function", params=pytest.channels)
def fmctdc_chan(request):
    tdc = FmcTdc(pytest.tdc_id)
    for ch in tdc.chan:
        ch.enable = False
    tdc.chan[request.param].termination = False
    tdc.chan[request.param].timestamp_mode = "post"
    tdc.chan[request.param].flush()
    tdc.chan[request.param].coalescing_timeout = 1
    tdc.whiterabbit_mode = False
    tdc.time = FmcTdcTime(0, 0, 0, 0, 0)
    tdc.chan[request.param].enable = True
    yield tdc.chan[request.param]
    tdc.chan[request.param].enable = False
    del tdc

class TestFmctdcAcquisition(object):

    def test_acq_single_channel_disable(self, fmctdc_chan, fmcfd):
        """Acquistion does not start if the channel is not enable"""
        fmctdc_chan.enable = False
        fmcfd.generate_pulse(TDC_FD_CABLING[fmctdc_chan.idx], 0, 1000000000, 1, True)
        with pytest.raises(OSError):
            ts = fmctdc_chan.read(1, os.O_NONBLOCK)

    @pytest.mark.parametrize("period_ns,count", fmctdc_acq_100ns)
    def test_acq_chan_stats(self, fmctdc_chan, fmcfd, period_ns, count):
        """Check that unders a controlled acquisiton statistics increase
        correctly. Test 100 milli-second acquisition at different
        frequencies"""
        stats_before = fmctdc_chan.stats
        fmctdc_chan.buffer_len =  max(count + 1, 64)
        fmcfd.generate_pulse(TDC_FD_CABLING[fmctdc_chan.idx], 1000,
                             period_ns, count, True)
        stats_after = fmctdc_chan.stats
        assert stats_before[0] + count == stats_after[0]

    @pytest.mark.skipif(pytest.carrier != "spec" or \
                        pytest.transfer_mode != "dma",
                        reason="Only SPEC with DMA can perform this test")
    @pytest.mark.parametrize("period_ns", [200, 250, 500, 1000])
    @pytest.mark.repeat(100)
    def test_acq_chan_high_speed(self, fmctdc_chan, fmcfd, period_ns):
        """Check that at hign speed we get all samples. Do it many times.
        We could use the infinite feature, but it will be then hard to see
        if we missed a timestamp or not. this is a fine-delay limitation"""
        count = 0xFFFF
        stats_before = fmctdc_chan.stats
        fmctdc_chan.buffer_len =  count + 1
        fmcfd.generate_pulse(TDC_FD_CABLING[fmctdc_chan.idx], 1000,
                             period_ns, count, True)
        stats_after = fmctdc_chan.stats
        assert stats_before[0] + count == stats_after[0]

    @pytest.mark.parametrize("period_ns,count", fmctdc_acq_100ns)
    def test_acq_timestamp_valid(self, fmctdc_chan, fmcfd, period_ns, count):
        """Check that under a controlled acquisiton the timestamps and their
        metadata is valid. Coars and franc within range, and the sequence
        number increases by 1 Test 100 milli-second acquisition at different
        frequencies"""
        fmctdc_chan.buffer_len =  max(count + 1, 64)
        prev = None
        fmcfd.generate_pulse(TDC_FD_CABLING[fmctdc_chan.idx], 1000,
                             period_ns, count, True)
        ts = fmctdc_chan.read(count, os.O_NONBLOCK)
        assert len(ts) == count
        for i in  range(len(ts)):
            assert 0 <= ts[i].coarse < 125000000
            assert 0 <= ts[i].frac < 4096
            if prev == None:
                prev = ts[i]
                continue
            assert ts[i].seq_id == (prev.seq_id + 1) & 0xFFFFFFF, \
              "Missed {:d} timestamps (idx: {:d}, max: {:d}, prev: {{ {:s}, curr: {:s} }}, full dump;\n{:s}".format(ts[i].seq_id - prev.seq_id + 1,
                                                                                                                    i,
                                                                                                                    len(ts),
                                                                                                                    str(prev),
                                                                                                                    str(ts[i]),
                                                                                                                    "\n".join([str(x) for x in ts[max(0, i - pytest.dump_range):min(i + pytest.dump_range, len(ts) -1)]]))
            prev = ts[i]

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
        timeout = time.time() + 1 + (period_ns * count) / 1000000000.0
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
                assert ts[i].seq_id == (prev.seq_id + 1) & 0xFFFFFFF, \
                  "Missed {:d} timestamps (idx: {:d}, max: {:d}, prev: {{ {:s}, curr: {:s} }}, full dump;\n{:s}".format(ts[i].seq_id - prev.seq_id + 1,
                                                                                                                        i,
                                                                                                                        len(ts),
                                                                                                                        str(prev),
                                                                                                                        str(ts[i]),
                                                                                                                        "\n".join([str(x) for x in ts[max(0, i - pytest.dump_range):min(i + pytest.dump_range, len(ts) -1)]]))
                prev = ts[i]
            pending -= len(ts)
        poll.unregister(fmctdc_chan.fileno)
        fmcfd.disable(TDC_FD_CABLING[fmctdc_chan.idx])
        assert stats_o[0] == stats_o[1]
        assert fmctdc_chan.stats[0] == fmctdc_chan.stats[1]
        assert fmctdc_chan.stats[0] - stats_o[0] >= count
        assert pending <= 0, "Some timestamp could be missing"
