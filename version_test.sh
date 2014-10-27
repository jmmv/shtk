# Copyright 2014 Google Inc.
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

shtk_import unittest
shtk_import version


shtk_unittest_add_test at_least__yes
at_least__yes_test() {
    SHTK_VERSION=3.8  # Override the builtin version with fake data.

    shtk_version_at_least 3.8 || fail "Same version check failed"
    shtk_version_at_least 3.7 || fail "Minor version check failed"
    shtk_version_at_least 2.0 || fail "Major version check failed"
    shtk_version_at_least 2.9 || fail "Minor version check failed"
}


shtk_unittest_add_test at_least__no
at_least__no_test() {
    SHTK_VERSION=3.8  # Override the builtin version with fake data.

    if shtk_version_at_least 3.9; then
        fail "Minor version check failed"
    fi
    if shtk_version_at_least 4.0; then
        fail "Major version check failed"
    fi
}


shtk_unittest_add_test at_most__yes
at_most__yes_test() {
    SHTK_VERSION=3.8  # Override the builtin version with fake data.

    shtk_version_at_most 3.8 || fail "Same version check failed"
    shtk_version_at_most 3.9 || fail "Minor version check failed"
    shtk_version_at_most 4.0 || fail "Major version check failed"
    shtk_version_at_most 4.7 || fail "Minor version check failed"
}


shtk_unittest_add_test at_most__no
at_most__no_test() {
    SHTK_VERSION=3.8  # Override the builtin version with fake data.

    if shtk_version_at_most 3.7; then
        fail "Minor version check failed"
    fi
    if shtk_version_at_most 2.0; then
        fail "Major version check failed"
    fi
}


shtk_unittest_add_test is__yes
is__yes_test() {
    SHTK_VERSION=3.8  # Override the builtin version with fake data.

    shtk_version_is 3.8 || fail "Same version check failed"
}


shtk_unittest_add_test is__no
is__no_test() {
    SHTK_VERSION=3.8  # Override the builtin version with fake data.

    if shtk_version_is 3.7; then
        fail "Minor version check failed"
    fi
    if shtk_version_is 4.0; then
        fail "Major version check failed"
    fi
}
