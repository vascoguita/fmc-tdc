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
    def __init__(self, device_id):
        self.dev_id = device_id

    def generate_pulse(self, ch, rel_time_us,
                       period_ns, count, sync):
        cmd = ["/usr/local/bin/fmc-fdelay-pulse",
               "-d", "0x{:x}".format(self.dev_id),
               "-o", str(ch),
               "-r", "{:d}u".format(rel_time_us),
               "-T", "{:d}n".format(period_ns),
               "-c", str(count),
               "-t"
               ]
        proc = subprocess.Popen(cmd)
        proc.wait()
        if sync:
            time.sleep(1 + 2 * (period_ns * count) / 1000000000.0)

@pytest.fixture(scope="session")
def fmcfd():
    return FmcFineDelay(pytest.fd_id)

def fmctdc_channel_default(chan):
    chan.termination = False
    chan.timestamp_mode = "post"
    chan.enable = False

@pytest.fixture(scope="function")
def fmctdc():
    tdc = FmcTdc(pytest.tdc_id)
    for i in range(tdc.CHANNEL_NUMBER):
        fmctdc_channel_default(tdc.chan[i])
        tdc.chan[i].flush()
    yield tdc
    for i in range(tdc.CHANNEL_NUMBER):
        fmctdc_channel_default(tdc.chan[i])
        tdc.chan[i].flush()

def pytest_addoption(parser):
    parser.addoption("--tdc-id", type=lambda x : int(x, 16),
                     required=True)
    parser.addoption("--fd-id", type=lambda x : int(x, 16),
                     required=True)

def pytest_configure(config):
    pytest.tdc_id = config.getoption("--tdc-id")
    pytest.fd_id = config.getoption("--fd-id")
