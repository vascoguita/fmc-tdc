"""
SPDX-License-Identifier: GPL-3.0-or-later
SPDX-FileCopyrightText: 2020 CERN
"""

import pytest
import PyFmcTdc
import subprocess

class FmcFineDelay(object):
    def __init__(self, device_id):
        self.dev_id = device_id

    def generate_pulse(self, ch, rel_time_us,
                       period_ns, count):
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


@pytest.fixture(scope="module")
def fmcfd():
    return FmcFineDelay(pytest.fd_id)

@pytest.fixture(scope="module")
def fmctdc():
    return PyFmcTdc.FmcTdc(pytest.tdc_id)

def pytest_addoption(parser):
    parser.addoption("--tdc-id", action="store", type=lambda x : int(x, 16),
                     required=True)
    parser.addoption("--fd-id", action="store", type=lambda x : int(x, 16),
                     required=True)

def pytest_configure(config):
    pytest.tdc_id = config.getoption("--tdc-id")
    pytest.fd_id = config.getoption("--fd-id")
