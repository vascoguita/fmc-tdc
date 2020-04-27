"""
SPDX-License-Identifier: GPL-3.0-or-later
SPDX-FileCopyrightText: 2020 CERN
"""

import pytest

class TestFmctdcTemperature(object):

    def test_temperature_read(self, fmctdc):
        assert 0 < fmctdc.temperature
