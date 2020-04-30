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

class FmcFineDelay(object):
    CHANNEL_NUMBER = 4

    def __init__(self, device_id):
        self.dev_id = device_id

    def disable(self, ch):
        cmd = ["/usr/local/bin/fmc-fdelay-pulse",
               "-d", "0x{:x}".format(self.dev_id),
               "-o", str(ch),
               "-m", "disable",
               ]
        proc = subprocess.Popen(cmd)
        proc.wait()

    def generate_pulse(self, ch, rel_time_us,
                       period_ns, count, sync):
        cmd = ["/usr/local/bin/fmc-fdelay-pulse",
               "-d", "0x{:x}".format(self.dev_id),
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

@pytest.fixture(scope="function")
def fmcfd():
    fd =  FmcFineDelay(pytest.fd_id)
    yield fd
    for ch in range(FmcFineDelay.CHANNEL_NUMBER):
        fd.disable(ch + 1)

@pytest.fixture(scope="function")
def fmctdc():
    tdc = FmcTdc(pytest.tdc_id)
    for ch in tdc.chan:
        ch.enable = False
        ch.termination = False
        ch.timestamp_mode = "post"
        ch.flush()
    yield tdc.chan[request.param]

def pytest_addoption(parser):
    parser.addoption("--tdc-id", type=lambda x : int(x, 16),
                     required=True, help="Fmc TDC Linux Identifier")
    parser.addoption("--fd-id", type=lambda x : int(x, 16),
                     required=True, help="Fmc Fine-Delay Linux Identifier")

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
    pytest.channels = config.getoption("--channel")
    if len(pytest.channels) == 0:
        pytest.channels = range(FmcTdc.CHANNEL_NUMBER)
    pytest.usr_acq = (config.getoption("--usr-acq-period-ns"),
                      config.getoption("--usr-acq-count"))

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
