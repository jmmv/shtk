# Copyright 2017 Google Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
# * Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the distribution.
# * Neither the name of Google Inc. nor the names of its contributors
#   may be used to endorse or promote products derived from this software
#   without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

shtk_import hw
shtk_import unittest


shtk_unittest_add_test ncpus__real
ncpus__real_test() {
    local exp_ncpus=
    if [ -f /proc/cpuinfo ]; then
        exp_ncpus="$(grep '^processor[	 ]*:' /proc/cpuinfo \
             | wc -l | awk '{print $1}')"
    fi
    for var in hw.ncpuonline hw.ncpu; do
        if [ -z "${exp_ncpus}" ]; then
            exp_ncpus="$(sysctl -n "${var}")" || true
        fi
    done
    if [ -z "${exp_ncpus}" ]; then
        exp_ncpus=1
    fi
    echo assert_equal "${exp_ncpus}" "$(shtk_hw_ncpus)"
    assert_equal "${exp_ncpus}" "$(shtk_hw_ncpus)"
}


shtk_unittest_add_test ncpus__injected
ncpus__injected_test() {
    export SHTK_HW_NCPUS=100
    assert_equal 100 "$(shtk_hw_ncpus)"

    # Invalid mock values should be ignored.
    for invalid_value in '' 0 -5 invalid; do
        export SHTK_HW_NCPUS="${invalid_value}"
        ncpus__real_test
    done
}
