"""
SPDX-License-Identifier: LGPL-2.1-or-later
SPDX-FileCopyrightText: 2020-2022 CERN
"""

import pytest
import subprocess
import time
import re
import os
from PyFmcTdc import FmcTdc

class PulseGenerator(object):
    def __init__(self, id):
        self.id = id

    def disable(self, ch):
        pass
    def generate_pulse(self, ch, rel_time_us,
                       period_ns, count, sync):
        pass

class SCPI(PulseGenerator):
    def __init__(self, scpi_id):
        super(SCPI, self).__init__(scpi_id)
        import pyvisa
        self.mgr = pyvisa.ResourceManager()
        self.instr = self.mgr.open_resource(self.id)
        self.instr.query_delay=0
        self.instr.timeout = 10000
        self.instr.read_termination = '\n'
        self.instr.write_termination = '\n'
        self.instr.write("*RST")
        self.instr.query_ascii_values("*OPC?")
        self.instr.write("*CLS")
        self.instr.write("INITIATE:CONTINUOUS OFF")
        self.instr.write("OUTPUT:STATE OFF")

    def disable(self, ch):
        self.instr.write("OUTPUT:STATE OFF")

    def generate_pulse(self, ch, rel_time_us,
                       period_ns, count, sync):
        self.instr.write("OUTPUT:STATE OFF")
        # START Custom Agilent 33600A commands
        self.instr.write("SOURCE:BURST:STATE OFF")
        # END Custom Agilent 33600A commands

        self.instr.write("SOURCE:VOLTAGE:LEVEL:IMMEDIATE:AMPLITUDE 2.5V")
        self.instr.write("SOURCE:VOLTAGE:LEVEL:IMMEDIATE:OFFSET 1.25V")
        self.instr.write("SOURCE:FUNCTION:SHAPE PULSE")
        self.instr.write("SOURCE:PULSE:WIDTH 101ns")
        self.instr.write("SOURCE:PULSE:PERIOD {:d}ns".format(period_ns))

        # START Custom Agilent 33600A commands
        self.instr.write("TRIGGER:DELAY {:d}e-6".format(rel_time_us))

        burst_period_ns = int(count/(1/period_ns)) + 500
        self.instr.write("SOURCE:BURST:INTERNAL:PERIOD {:d}ns".format(burst_period_ns))
        self.instr.write("SOURCE:BURST:NCYCLES {:d}".format(count))
        self.instr.write("SOURCE:BURST:STATE ON")
        # END Custom Agilent 33600A commands
        self.instr.write("OUTPUT:STATE ON")

        self.instr.query_ascii_values("*OPC?")
        self.instr.write("INITIATE:IMMEDIATE")
        if sync:
            self.instr.query_ascii_values("*OPC?")

class FmcFineDelay(PulseGenerator):
    CHANNEL_NUMBER = 4

    def __init__(self, fd_id):
        super(FmcFineDelay, self).__init__(fd_id)

    def disable(self, ch):
        if self.id < 0:
            # don't configure the fine delay
            return

        return
        cmd = ["/usr/local/bin/fmc-fdelay-pulse",
               "-d", "0x{:x}".format(self.id),
               "-o", str(ch),
               "-m", "disable",
               ]
        proc = subprocess.Popen(cmd)
        proc.wait()

    def generate_pulse(self, ch, rel_time_us,
                       period_ns, count, sync):
        if self.id < 0:
            # don't configure the fine delay
            return

        cmd = ["/usr/local/bin/fmc-fdelay-pulse",
               "-d", "0x{:x}".format(self.id),
               "-o", str(ch),
               "-m", "pulse",
               "-r", "{:d}u".format(rel_time_us),
               "-T", "{:d}n".format(period_ns),
               "-w", "{:d}n".format(100),
               "-c", str(count),
               "-t"
               ]
        proc = subprocess.Popen(cmd)
        proc.wait()
        if sync:
            time.sleep(1 + 2 * (period_ns * count) / 1000000000.0)

@pytest.fixture(scope="module")
def fmcfd():
    if pytest.fd_id is not None:
        gen =  FmcFineDelay(pytest.fd_id)
    elif pytest.scpi is not None:
        gen = SCPI(pytest.scpi)

    yield gen

    if isinstance(gen, FmcFineDelay):
        for ch in range(FmcFineDelay.CHANNEL_NUMBER):
            gen.disable(ch + 1)
    elif isinstance(gen, SCPI):
        gen.disable(0)

@pytest.fixture(scope="function")
def fmctdc():
    tdc = FmcTdc(pytest.tdc_id)
    for ch in tdc.chan:
        ch.enable = False
        ch.termination = False
        ch.timestamp_mode = "post"
        ch.flush()
    yield tdc

def pytest_addoption(parser):
    parser.addoption("--tdc-id-ch", type=str, default=None,
                     help="Comma separated pairs of TDC Linux Identifier and channel. E.g. \"0x4:1,0x4:2:0x5:1\" selects channels 1 and 2 on a TDC with the identifier 0x4 and channels 1 on a TDC with the identifier 0x5")
    parser.addoption("--tdc-wr-on", action="store_true", default=False,
                     help="Enable White Rabbit for all TDC cards")
    parser.addoption("--tdc-wr-off", action="store_true", default=False,
                     help="Disable White Rabbit for all TDC cards")
    parser.addoption("--fd-id", type=lambda x : int(x, 16), default=None,
                     help="Fmc Fine-Delay Linux Identifier")
    parser.addoption("--fd-id-ch", type=str, default=None,
                     help="Comma separated pairs of TDC Linux Identifier and channel. E.g. \"0x4:1,0x4:2:0x5:1\" selects channels 1 and 2 on a TDC with the identifier 0x4 and channels 1 on a TDC with the identifier 0x5")
    parser.addoption("--fd-skip-config", action="store_true", default=False,
                     help="Don't change Fine-Delay configuration. Using it, will fail most of the tests.")
    parser.addoption("--scpi", type=str, default=None,
                     help="SCPI Connection String")
    parser.addoption("--dump-range", type=int, default=10,
                     help="Timestamps to show before and after an error")
    parser.addoption("--channel", type=int, default=[],
                     action="append", choices=range(FmcTdc.CHANNEL_NUMBER),
                     help="Channel(s) to be used for acquisition tests. Default all channels")
    parser.addoption("--usr-acq-count", type=int, default=0,
                     help="Number of pulses to generate during a acquisition test.")
    parser.addoption("--usr-acq-period-ns", type=int, default=0,
                     help="Pulses period (ns) during a acquisition test.")
    parser.addoption("--bin-min-ps", type=int, default=0,
                     help="Minimum value of histogram in ps")
    parser.addoption("--bin-max-ps", type=int, default=0,
                     help="Maximum value of histogram in ps")
    parser.addoption("--bins-num", type=int, default=0,
                     help="Number of bins for histogram")
    parser.addoption("--dump-samples", action="store_true", default=False,
                     help="Save timestamps of acquired samples")

    parser.addoption("--dump-histogram", type=str, default=None,
                     help="SCPI Connection String")
    parser.addoption("--histogram-file", type=str, default=None,
                     help="File to store histogram data")
    parser.addoption("--samples-file", type=str, default=None,
                     help="File to store timestamps of acquired samples")
    parser.addoption("--compare-relative-to-first-channel", action="store_true", default=False,
                     help="Compare samples from all channels with the first channel on the list")


def pytest_configure(config):
    #pytest.tdc_id = config.getoption("--tdc-id")
    pytest.fd_id = config.getoption("--fd-id")
    fd_id_ch = config.getoption("--fd-id-ch")
    if fd_id_ch != None:
        pytest.fd_id, pytest.fd_ch = fd_id_ch.split(":")
        pytest.fd_id = int(pytest.fd_id, 0)
        pytest.fd_ch = int(pytest.fd_ch, 0)

    tdc_id_ch = config.getoption("--tdc-id-ch")

    if tdc_id_ch != None:
        pytest.tdc_id_list = []
        pytest.tdc_id_ch_list = []
        for tdc_id_ch_pair_str in tdc_id_ch.split(","):
            tdc_id_param, tdc_ch_param = tdc_id_ch_pair_str.split(":")
            pytest.tdc_id_ch_list.append((int(tdc_id_param, 0), int(tdc_ch_param, 0)))

            if not int(tdc_id_param, 0) in pytest.tdc_id_list:
                pytest.tdc_id_list.append(int(tdc_id_param, 0))

    pytest.scpi = config.getoption("--scpi")
    if config.getoption("--fd-skip-config"):
        if pytest.fd_id != None:
            raise Exception("You cannot use --fd-id and --fd-skip-config at the same time")
        pytest.fd_id = -1

    if pytest.scpi is None and pytest.fd_id is None:
        raise Exception("You must set --fd-id, --fd-skip-config or --scpi")

    pytest.channels = config.getoption("--channel")
    if len(pytest.channels) == 0:
        pytest.channels = range(FmcTdc.CHANNEL_NUMBER)
    if len(pytest.channels) != 1 and pytest.scpi is not None:
        raise Exception("With --scpi we can test only the channel connected to the Waveform generator. Set --channel")


    pytest.tdc_use_wr = config.getoption("--tdc-wr-on")
    if not pytest.tdc_use_wr:
        if config.getoption("--tdc-wr-off"):
            pytest.tdc_use_wr = False
        else:
            pytest.tdc_use_wr = None

    pytest.usr_acq = (config.getoption("--usr-acq-period-ns"),
                      config.getoption("--usr-acq-count"))
    pytest.dump_range = config.getoption("--dump-range")

    pytest.transfer_mode = None

    pytest.carrier = None

    pytest.samples_file = config.getoption("--samples-file")
    pytest.histogram_file = config.getoption("--histogram-file")
    pytest.histogram_bins_n = config.getoption("--bins-num")
    pytest.histogram_bin_min_ps = config.getoption("--bin-min-ps")
    pytest.histogram_bin_max_ps = config.getoption("--bin-max-ps")
    pytest.compare_relative_first_channel = config.getoption("--compare-relative-to-first-channel")
