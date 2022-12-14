"""
SPDX-License-Identifier: LGPL-2.1-or-later
SPDX-FileCopyrightText: 2020 CERN
"""

import pytest

class TestFmctdcTemperature(object):

    def test_temperature_read(self, fmctdc):
        assert 0 < fmctdc.temperature
