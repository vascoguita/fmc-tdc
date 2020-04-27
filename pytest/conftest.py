"""
SPDX-License-Identifier: GPL-3.0-or-later
SPDX-FileCopyrightText: 2020 CERN
"""

import pytest
import PyFmcTdc

@pytest.fixture(scope="module")
def fmctdc():
    return PyFmcTdc.FmcTdc(pytest.tdc_id)

def pytest_addoption(parser):
    parser.addoption("--tdc-id", action="store", type=lambda x : int(x, 16),
                     required=True)
    # parser.addoption("--fd-id", action="store", type=lambda x : int(x, 16),
    #                  required=True)

def pytest_configure(config):
    pytest.tdc_id = config.getoption("--tdc-id")
    # pytest.fd_id = config.getoption("--fd-id")
