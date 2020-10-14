"""
SPDX-License-Identifier: GPL-3.0-or-later
SPDX-FileCopyrightText: 2020 CERN
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
        self.instr.query_delay=10
        self.instr.write("*RST")
        self.wait_completion()
        self.instr.write("*CLS")
        self.instr.write("INITIATE:CONTINUOUS OFF")
        self.instr.write("OUTPUT:STATE OFF")

    def wait_completion(self):
        if int(self.instr.query_ascii_values("*OPC?")[0]) != 1:
            raise Exception("Failed to reset the waveform generator")

    def disable(self, ch):
        self.instr.write("OUTPUT:STATE OFF")

    def generate_pulse(self, ch, rel_time_us,
                       period_ns, count, sync):
        import pdb; pdb.set_trace()
        self.instr.write("OUTPUT:STATE OFF")
        self.instr.write("SOURCE:VOLTAGE:LEVEL:IMMEDIATE:AMPLITUDE 5.0V")
        self.instr.write("SOURCE:FUNCTION:SHAPE PULSE")
        self.instr.write("SOURCE:PULSE:WIDTH 100ns")
        self.instr.write("SOURCE:PULSE:PERIOD {:d}ns".format(period_ns))

        # START Custom Agilent 33600A commands
        self.instr.write("SOURCE:BURST:STATE ON")
        self.instr.write("SOURCE:BURST:NCYCLES {:d}".format(count))
#        self.instr.write("TRIGGER:DELAY {:d}us".format(rel_time_us))
        # END Custom Agilent 33600A commands

        self.instr.write("OUTPUT:STATE ON")
        self.wait_completion()
        self.instr.write("INITIATE:IMMEDIATE")
        if sync:
            self.wait_completion()

class FmcFineDelay(PulseGenerator):
    CHANNEL_NUMBER = 4

    def __init__(self, fd_id):
        super(FmcFineDelay, self).__init__(fd_id)

    def disable(self, ch):
        cmd = ["/usr/local/bin/fmc-fdelay-pulse",
               "-d", "0x{:x}".format(self.id),
               "-o", str(ch),
               "-m", "disable",
               ]
        proc = subprocess.Popen(cmd)
        proc.wait()

    def generate_pulse(self, ch, rel_time_us,
                       period_ns, count, sync):
        cmd = ["/usr/local/bin/fmc-fdelay-pulse",
               "-d", "0x{:x}".format(self.id),
               "-o", str(ch),
               "-m", "pulse",
               "-r", "{:d}u".format(rel_time_us),
               "-T", "{:d}n".format(period_ns),
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
    parser.addoption("--tdc-id", type=lambda x : int(x, 16),
                     required=True, help="Fmc TDC Linux Identifier")
    parser.addoption("--fd-id", type=lambda x : int(x, 16), default=None,
                     help="Fmc Fine-Delay Linux Identifier")
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

def pytest_configure(config):
    pytest.tdc_id = config.getoption("--tdc-id")
    pytest.fd_id = config.getoption("--fd-id")
    pytest.scpi = config.getoption("--scpi")
    if pytest.scpi is None and pytest.fd_id is None:
        raise Exception("You must set --fd-id or --scpi")

    pytest.channels = config.getoption("--channel")
    if len(pytest.channels) == 0:
        pytest.channels = range(FmcTdc.CHANNEL_NUMBER)
    if len(pytest.channels) != 1 and pytest.scpi is not None:
        raise Exception("With --scpi we can test only the channel connected to the Waveform generator. Set --channel")

    pytest.usr_acq = (config.getoption("--usr-acq-period-ns"),
                      config.getoption("--usr-acq-count"))
    pytest.dump_range = config.getoption("--dump-range")

    pytest.transfer_mode = None
    with open("/sys/bus/zio/devices/tdc-1n5c-{:04x}/transfer-mode".format(pytest.tdc_id)) as f_mode:
        mode = int(f_mode.read().rstrip())
        for k, v in FmcTdc.TRANSFER_MODE.items():
            if mode == v:
                pytest.transfer_mode = k

    pytest.carrier = None
    full_path = os.readlink("/sys/bus/zio/devices/tdc-1n5c-{:04x}".format(pytest.tdc_id))
    for carr in ["spec", "svec"]:
        is_carr = re.search(carr, full_path)
        if is_carr is not None:
            pytest.carrier = carr
