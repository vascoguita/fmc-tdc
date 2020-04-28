"""
SPDX-License-Identifier: GPL-3.0-or-later
SPDX-FileCopyrightText: 2020 CERN
"""

import pytest
import random
import time
from PyFmcTdc import FmcTdcTime

class TestFmctdcTime(object):

    def test_whiterabbit_mode(self, fmctdc):
        """It must be possible to toggle the White-Rabbit status"""
        fmctdc.whiterabbit_mode = True
        assert fmctdc.whiterabbit_mode == True
        fmctdc.whiterabbit_mode = False
        assert fmctdc.whiterabbit_mode == False

    def test_time_set_fail_wr(self, fmctdc):
        """Time can't be changed when White-Rabbit is enabled"""
        fmctdc.whiterabbit_mode = True
        with pytest.raises(OSError):
            fmctdc.time = FmcTdcTime(10, 0, 0, 0, 0)

    @pytest.mark.parametrize("t", random.sample(range(1000000), 10))
    def test_time_set(self, fmctdc, t):
        """Time can be changed when White-Rabbit is disabled"""
        fmctdc.whiterabbit_mode = False
        t_base = FmcTdcTime(t, 0, 0, 0, 0)
        fmctdc.time = t_base
        assert t_base.seconds == fmctdc.time.seconds

    @pytest.mark.parametrize("whiterabbit", [False, True])
    def test_time_flows(self, fmctdc, whiterabbit):
        """Just check that the time flows more or less correctly second by
        second for a minute"""
        fmctdc.whiterabbit_mode = whiterabbit
        for i in range(20):
            t_prev = fmctdc.time.seconds
            time.sleep(1)
            assert t_prev + 1 == fmctdc.time.seconds
