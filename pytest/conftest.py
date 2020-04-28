"""
SPDX-License-Identifier: GPL-3.0-or-later
SPDX-FileCopyrightText: 2020 CERN
"""

import pytest
import subprocess
import re
import os
from PyFmcTdc import FmcTdc

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
    tdc = FmcTdc(pytest.tdc_id)
    for i in range(tdc.CHANNEL_NUMBER):
        tdc.chan[i].termination = False
        tdc.chan[i].enable = False
        tdc.chan[i].flush()
    yield tdc
    for i in range(tdc.CHANNEL_NUMBER):
        tdc.chan[i].termination = False
        tdc.chan[i].enable = False
        tdc.chan[i].flush()

def pytest_addoption(parser):
    parser.addoption("--base-root",  default="/")
    parser.addoption("--carrier", choices=["spec", "svec"], required=True)
    parser.addoption("--tdc-bitstream", default=None)
    parser.addoption("--tdc-id", type=lambda x : int(x, 16),
                     required=True)
    parser.addoption("--fd-id", type=lambda x : int(x, 16),
                     required=True)

def fmctdc_configure_drivers(config):
    drv_list = []
    if config.getoption("--carrier") == "spec":
        drv_list += ["zio-buf-vmalloc", "spec-fmc-carrier", "fmc-tdc-spec",
                     "fmc-fine-delay-spec"]
    elif config.getoption("--carrier") == "svec":
        drv_list += ["zio-buf-vmalloc", "svec-fmc-carrier", "fmc-tdc-spev",
                     "fmc-fine-delay-spev"]

    for drv in drv_list:
        proc = subprocess.Popen(["modprobe -d {:s} {:s}".format(config.getoption("--base-root"), drv)],
                                shell=True)
        proc.wait()

def fmctdc_configure_bitstream(config):
    bit = config.getoption("--tdc-bitstream")
    if bit is None:
        return

    full_path = os.readlink("/sys/bus/zio/devices/tdc-1n5c-{:04x}".format(pytest.tdc_id))
    if config.getoption("--carrier") == "spec":
        dev_dbg = re.search("spec-([0-9a-f]{4}:[0-9a-f]{2}:[0-9a-f]{2}.[0-9a-f])",
                            full_path).group(1)
    path = "/sys/kernel/debug/{:s}/fpga_firmware".format(dev_dbg)
    proc = subprocess.Popen(["echo -n {:s} > {:s}".format(os.path.basename(bit), path)], shell=True)
    proc.wait()

def pytest_configure(config):
    pytest.tdc_id = config.getoption("--tdc-id")
    pytest.fd_id = config.getoption("--fd-id")

    # configure the kernel for reporting everything on dmesg
    proc = subprocess.Popen(["echo 8 > /proc/sys/kernel/printk"], shell=True)
    proc.wait()
    bit = config.getoption("--tdc-bitstream")
    if bit is not None:
        proc = subprocess.Popen(["echo -n {:s} > /sys/module/firmware_class/parameters/path".format(os.path.dirname(bit))],
                                shell=True)

    fmctdc_configure_drivers(config)
    fmctdc_configure_bitstream(config)
