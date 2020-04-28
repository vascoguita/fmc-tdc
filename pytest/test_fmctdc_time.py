"""
SPDX-License-Identifier: GPL-3.0-or-later
SPDX-FileCopyrightText: 2020 CERN
"""

import pytest
import time


class TestFmctdcTime(object):

    def test_time_flows(self, fmctdc):
        """Just check that the time flows more or less correctly second by
        second for a minute"""
        for i in range(60):
            t_prev = fmctdc.time.seconds
            time.sleep(1)
            assert t_prev + 1 == fmctdc.time.seconds
