"""
SPDX-License-Identifier: LGPL-2.1-or-later
SPDX-FileCopyrightText: 2022 Adam Wujek for CERN
"""

import pytest
import random
import select
import time
import sys
import os
import math
from PyFmcTdc import FmcTdc, FmcTdcTime

from fractions import Fraction

def ts_sub_frac(ts1, ts2):
    ts = Fraction(0.0)
    tmp1 = Fraction(0.0)
    tmp2 = Fraction(0.0)
    ts = Fraction(ts1.seconds) - Fraction(ts2.seconds)
    tmp1 = Fraction(ts1.coarse)
    tmp2 = Fraction(ts2.coarse)
    ts = ts + (tmp1 - tmp2) * 8 / Fraction(1000000000.0)
    tmp1 = Fraction(ts1.frac)
    tmp2 = Fraction(ts2.frac)
    ts = ts + (tmp1 - tmp2) * Fraction(8.0) / Fraction(4096) / Fraction(1000000000)
    return ts

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

@pytest.fixture(scope="function")
def fmctdc_chan_selected():
    # to support multiple boards for tdcx in pytest.tdc_id:
    ch_list = []
    tdc = FmcTdc(pytest.tdc_id)
    for ch in tdc.chan:
        ch.enable = False
    for ch_use in pytest.channels:
        tdc.chan[ch_use].termination = False
        tdc.chan[ch_use].timestamp_mode = "post"
        tdc.chan[ch_use].flush()
        tdc.chan[ch_use].coalescing_timeout = 1

        tdc.chan[ch_use].enable = True
        # create tuple
        ch_list.append((pytest.tdc_id, ch_use, tdc.chan[ch_use], tdc))

    yield ch_list
    for ch_t in ch_list:
        ch_t[2].enable = False
    del tdc

def dump_histogram_file(pytest, ch_data):
    for tdc_id, tdc_ch in pytest.tdc_id_ch_list:
        ch_data[(tdc_id, tdc_ch)].file_histogram = \
                    open("{:s}_tdc_0x{:x}_ch_{:d}.txt"\
                            .format(pytest.histogram_file, tdc_id, tdc_ch),
                            'w')
        ch_data[(tdc_id, tdc_ch)].file_histogram.write("min {:d}  \"-:{:d})\"\n".format(ch_data[(tdc_id, tdc_ch)].hist_min, pytest.histogram_bin_min_ps))
        for i in range(pytest.histogram_bins_n):
            bin_min_val_ps = pytest.histogram_bin_min_ps + i *(pytest.histogram_bin_max_ps - pytest.histogram_bin_min_ps)/pytest.histogram_bins_n
            bin_max_val_ps = pytest.histogram_bin_min_ps + (i+1) *(pytest.histogram_bin_max_ps - pytest.histogram_bin_min_ps)/pytest.histogram_bins_n
            ch_data[(tdc_id, tdc_ch)].file_histogram.write("{:d} {:d} \"[{:0.0f}:{:0.0f})\"\n".format(i+1, ch_data[(tdc_id, tdc_ch)].hist_data[i], bin_min_val_ps, bin_max_val_ps))
        ch_data[(tdc_id, tdc_ch)].file_histogram.write("max {:d} \"[{:d}:-\"\n".format(ch_data[(tdc_id, tdc_ch)].hist_max, pytest.histogram_bin_max_ps))
        ch_data[(tdc_id, tdc_ch)].file_histogram.close()

class emptyObject():
    pass

class TestFmctdcAcquisition(object):

    @pytest.mark.skipif(0 in pytest.usr_acq,
                        reason="Missing user acquisition option")
    @pytest.mark.skipif(pytest.carrier == "spec" and \
                        pytest.transfer_mode == "fifo" and \
                        pytest.usr_acq[0] < 7000,
                        reason="On SPEC with FIFO acquisition we can't do more than 100kHz")
    @pytest.mark.parametrize("period_ns,count", [pytest.usr_acq])
    def test_acq_performance(self, capsys, fmcfd,
                                          period_ns, count):
        """Test to check the maximum performance of the TDC mezzanine
        """
        start_ts = FmcTdcTime()
        poll = select.poll()

        assert len(pytest.tdc_id_list) == 1, "Only one channel shall be provided in this test"

        # setup TDC
        for tdc_id in pytest.tdc_id_list:
            tdc_handler = FmcTdc(tdc_id)

            if pytest.tdc_use_wr:
                tdc_handler.whiterabbit_mode = True
            if pytest.tdc_use_wr == False:
                tdc_handler.whiterabbit_mode = False
                tdc_handler.time = FmcTdcTime(0, 0, 0, 0, 0)
            # don't touch whiterabbit_mode if --tdc-wr-XXX not defined

            # disable all channels on TDC
            for ch in tdc_handler.chan:
                ch.enable = False

        # setup TDC channel
        for tdc_id, tdc_ch in pytest.tdc_id_ch_list:
            #for ch_use in pytest.channels:
            print("setup TDC: " + str(tdc_id)+" channel: "+str(tdc_ch)+"\n")
            tdc_handler.chan[tdc_ch].termination = False
            tdc_handler.chan[tdc_ch].timestamp_mode = "post"
            tdc_handler.chan[tdc_ch].flush()
            tdc_handler.chan[tdc_ch].coalescing_timeout = 1
            # be able to buffer for 1 second
            tdc_handler.chan[tdc_ch].buffer_len = int(1000000000.0 / period_ns) + 1

            tdc_handler.chan[tdc_ch].enable = True

            poll.register(tdc_handler.chan[tdc_ch].fileno, select.POLLIN)

            prev = None
            seq_prev = 0
            seq_error = 0

        pending = count

        # setup Fine Delay
        if pytest.fd_id > -1:
            fmcfd.generate_pulse(pytest.fd_ch, 100000, period_ns, 0, False)

        timeout = time.time() + 1 + (period_ns * count) / 1000000000.0
        tdc_channel = pytest.tdc_id_ch_list[0][1]
        while pending > 0:
            t = time.time()
            if t >= timeout:
                break
            ret = poll.poll(1)
            if len(ret) == 0:
                continue
            ts = tdc_handler.chan[tdc_channel].read(1, os.O_NONBLOCK)

            for i in range(len(ts)):

                if ts[i].seq_id < 1000:
                    # skip first 1000 samples
                    seq_prev = ts[i].seq_id
                    continue
                if seq_prev + 1 != ts[i].seq_id:
                    seq_error += 1

                seq_prev = ts[i].seq_id
            pending -= len(ts)


        # cleanup TDC channels
        poll.unregister(tdc_handler.chan[tdc_ch].fileno)

        # cleanup TDC cleanup
        tdc_handler.chan[tdc_ch].enable = False
        del tdc_handler

        # disable Fine-Delay
        if pytest.fd_id > -1:
            fmcfd.disable(pytest.fd_ch)

        assert seq_error == 0, "Missing samples, non-consecutive sequence ID's"
        assert pending <= 0, "Some timestamps could be missing"

##########################################################


    @pytest.mark.skipif(0 in pytest.usr_acq,
                        reason="Missing user acquisition option")
    @pytest.mark.parametrize("period_ns,count", [pytest.usr_acq])
    def test_acq_timestamp_multiple_hist(self, capsys, fmcfd,
                                          period_ns, count):
        """Run an acquisition with users parameters for period and count.
        The Fine-Delay can generate a burst of maximum 65536 pulses, so we
        compute and approximated timeout to stop the test and we let
        the Fine-Delay generating an infinite train of pulses.

        Since the test can be very long, periodically this test will print the
        timestamp sequence number, you should see it increasing.
        """
        start_ts = FmcTdcTime()
        poll = select.poll()

        ch_data = {}
        tdc_list = {}


        # setup TDC
        for tdc_id in pytest.tdc_id_list:
            tdc_list[tdc_id] = FmcTdc(tdc_id)

            if pytest.tdc_use_wr:
                print("Enable WR on TDC " + str(tdc_id))
                tdc_list[tdc_id].whiterabbit_mode = True
            if pytest.tdc_use_wr == False:
                print("Disable WR on TDC " + str(tdc_id))
                tdc_list[tdc_id].whiterabbit_mode = False
                tdc_list[tdc_id].time = FmcTdcTime(0, 0, 0, 0, 0)
            # don't touch whiterabbit_mode if --tdc-wr-XXX not defined

            # disable all channels on TDC
            for ch in tdc_list[tdc_id].chan:
                ch.enable = False

        # setup TDC channels
        for tdc_id, tdc_ch in pytest.tdc_id_ch_list:
            #for ch_use in pytest.channels:
            tdc_list[tdc_id].chan[tdc_ch].termination = False
            tdc_list[tdc_id].chan[tdc_ch].timestamp_mode = "post"
            tdc_list[tdc_id].chan[tdc_ch].flush()
            tdc_list[tdc_id].chan[tdc_ch].coalescing_timeout = 1
            # be able to buffer for 1 second
            tdc_list[tdc_id].chan[tdc_ch].buffer_len = int(1000000000.0 / period_ns) +1

            tdc_list[tdc_id].chan[tdc_ch].enable = True

            poll.register(tdc_list[tdc_id].chan[tdc_ch].fileno, select.POLLIN)

            ch_data[(tdc_id, tdc_ch)] = emptyObject()
            ch_data[(tdc_id, tdc_ch)].prev = None
            ch_data[(tdc_id, tdc_ch)].seq_prev = 0
            ch_data[(tdc_id, tdc_ch)].seq_error = 0
            ch_data[(tdc_id, tdc_ch)].file_data = None
            ch_data[(tdc_id, tdc_ch)].file_histogram = None

            # histogram data
            ch_data[(tdc_id, tdc_ch)].hist_data = {}
            for i in range(pytest.histogram_bins_n):
                ch_data[(tdc_id, tdc_ch)].hist_data[i] = 0
            ch_data[(tdc_id, tdc_ch)].hist_min = 0
            ch_data[(tdc_id, tdc_ch)].hist_max = 0
            #ch_data[(tdc_id, tdc_ch)].diff_ps = {}

            if pytest.samples_file:
                ch_data[(tdc_id, tdc_ch)].file_data = \
                            open("{:s}_tdc_0x{:x}_ch_{:d}.txt"\
                                 .format(pytest.samples_file, tdc_id, tdc_ch),
                                 'w')
            if pytest.histogram_file:
                ch_data[(tdc_id, tdc_ch)].file_error = \
                            open("{:s}_tdc_0x{:x}_ch_{:d}_error.txt"\
                                 .format(pytest.histogram_file, tdc_id, tdc_ch),
                                 'w')

        multiple_channels = 1 if len(ch_data) > 1 else 0
        pending = count

        # setup Fine Delay
        if pytest.fd_id > -1:
            fmcfd.generate_pulse(pytest.fd_ch, 100000, period_ns, 0, False)

        timeout = time.time() + 1 + (period_ns * count / len(ch_data)) / 1000000000.0

        while pending > 0:
            t = time.time()
            if t >= timeout:
                #assert 0
                break
            ret = poll.poll(1)
            if len(ret) == 0:
                continue
            for tdc_id, tdc_ch in pytest.tdc_id_ch_list:
                try:
                    ts = tdc_list[tdc_id].chan[tdc_ch].read(1, os.O_NONBLOCK)
                except BlockingIOError:
                    continue

                for i in range(len(ts)):
		    # skip first 1000 samples
                    if count - pending < 1000*len(pytest.tdc_id_ch_list) or ts[i].seq_id < 1000:
                        continue
                    if ts[i].seq_id == 1000:
                        start_ts.seconds = ts[i].seconds
                        ch_data[(tdc_id, tdc_ch)].seq_error = 0
                    if ch_data[(tdc_id, tdc_ch)].prev == None:
                        ch_data[(tdc_id, tdc_ch)].prev = ts[i]
                        continue
                    if ch_data[(tdc_id, tdc_ch)].prev.seq_id + 1 != ts[i].seq_id:
                        ch_data[(tdc_id, tdc_ch)].seq_error += 1

                    curr_ts = ts[i]
                    sample_delta_frac = Fraction(period_ns)/Fraction(1000000000.0)

                    if pytest.compare_relative_first_channel:
                        # compare against first channel from the list
                        prev_ts = ch_data[pytest.tdc_id_ch_list[0]].prev
                        if multiple_channels and (pytest.tdc_id_ch_list[0] != (tdc_id, tdc_ch)):
                            sample_delta_frac = 0
                            if ch_data[(tdc_id, tdc_ch)].prev.seq_id == prev_ts.seq_id:
                                curr_ts = ch_data[(tdc_id, tdc_ch)].prev
                    else:
                        prev_ts = ch_data[(tdc_id, tdc_ch)].prev

                    if pytest.samples_file:
                        try:
                            ch_data[(tdc_id, tdc_ch)].file_data.write("0x{:x}:{:d} {:6d} {: 2.20f} {: 2.20f} {: 2.20f} {:s}\n".format(tdc_id, tdc_ch, curr_ts.seq_id,
                                                                      float(ts_sub_frac(curr_ts, start_ts) - Fraction(curr_ts.seq_id) * (Fraction(period_ns)/Fraction(1000000000))),
                                                                      float(ts_sub_frac(curr_ts, ch_data[(tdc_id, tdc_ch)].prev) - Fraction(period_ns)/Fraction(1000000000.0)), # delta on the same channel
                                                                      float(ts_sub_frac(curr_ts, prev_ts) - sample_delta_frac), # delta with channel 0
                                                                      str(curr_ts)))
                        except Exception:
                            if pytest.histogram_file:
                                dump_histogram_file(pytest, ch_data)
                            raise

                    if pytest.histogram_file:
                        diff_ps = ((ts_sub_frac(curr_ts, prev_ts) - sample_delta_frac)* 1000000000.0) *1000
                        bin_i = 0

                        if diff_ps < pytest.histogram_bin_min_ps:
                            # value is less than set minimum
                            ch_data[(tdc_id, tdc_ch)].hist_min += 1
                        elif diff_ps >= pytest.histogram_bin_max_ps:
                            # value is more than set maximum
                            ch_data[(tdc_id, tdc_ch)].hist_max += 1
                            print("diff more that {:d}ps! prev_id={:d}, curr_id={:d}, delta={:2.20f}s, dump: prev{:s}; curr{:s}\n"\
                                  .format(pytest.histogram_bin_max_ps,
                                          prev_ts.seq_id,
                                          ts[i].seq_id,
                                          float(ts_sub_frac(curr_ts, start_ts)),
                                          str(prev_ts),
                                          str(ts[i])
                                          )
                                  )
                            ch_data[(tdc_id, tdc_ch)].file_error.write("tdc_id:{:x}, tdc_ch:{:x}, diff more than {:d}ps! prev_id={:d}, curr_id={:d}, delta={:2.20f}s, dump: prev{:s}; curr{:s}\n"\
                                                                       .format(tdc_id,
                                                                               tdc_ch,
                                                                               pytest.histogram_bin_max_ps,
                                                                               prev_ts.seq_id,
                                                                               ts[i].seq_id,
                                                                               float(ts_sub_frac(curr_ts, start_ts)),
                                                                               str(prev_ts),
                                                                               str(ts[i])
                                                                               )
                                                                       )
                        else:
                            bin_i = math.floor((diff_ps - pytest.histogram_bin_min_ps) / \
                                               ((pytest.histogram_bin_max_ps - pytest.histogram_bin_min_ps)/pytest.histogram_bins_n))
                            ch_data[(tdc_id, tdc_ch)].hist_data[bin_i] += 1


                    ch_data[(tdc_id, tdc_ch)].prev = ts[i]
                pending -= len(ts)

            # periodic dump of histogram takes too long... don't use it
            # dump histogram data every 1 hour
            #if pending % (1000000000.0 / period_ns):
                #if pytest.histogram_file:
                    #dump_histogram_file(pytest, ch_data)

        # dump histogram data
        if pytest.histogram_file:
            dump_histogram_file(pytest, ch_data)

        # cleanup TDC channels
        for tdc_id, tdc_ch in pytest.tdc_id_ch_list:
            print("clean up tdc {:x} ch {:d}\n".format(tdc_id, tdc_ch))
            tdc_list[tdc_id].chan[tdc_ch].enable = False
            poll.unregister(tdc_list[tdc_id].chan[tdc_ch].fileno)
            if ch_data[(tdc_id, tdc_ch)].file_data:
                ch_data[(tdc_id, tdc_ch)].file_data.close()
            if pytest.histogram_file:
                ch_data[(tdc_id, tdc_ch)].file_error.close()

        # cleanup TDC cleanup
        for tdc_id in tdc_list:
            print("delete tdc {:x}\n".format(tdc_id))
            del tdc_id

        # disable Fine-Delay
        if pytest.fd_id > -1:
            fmcfd.disable(pytest.fd_ch)

        for ch in ch_data:
            assert ch_data[ch].seq_error == 0

        assert pending <= 0, "Some timestamp could be missing"
