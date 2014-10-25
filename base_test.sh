# Copyright 2012 Google Inc.
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


# Creates a mock module for shtk_import.
#
# The mock module is created in the given location and increments the given
# counter variable (starting at 1).  This counter can be used to determine if
# the inclusion of modules is not idempotent, or if a module has been loaded
# from multiple directories.
create_mock_module() {
    local module="${1}"; shift
    local variable="${1}"; shift

    mkdir -p "$(dirname ${module})"
    cat >"${module}" <<EOF
if [ -z "\${${variable}}" ]; then
    ${variable}=1
else
    ${variable}="\$((\${${variable}} + 1))"
fi
EOF
}


shtk_unittest_add_test import__ok
import__ok_test() {
    create_mock_module modules/mock.subr mock_value
    SHTK_MODULESPATH=
    SHTK_MODULESDIR="$(pwd)/modules"

    [ -z "${mock_value}" ] || fail "mock_value already defined"
    shtk_import mock
    expect_equal 1 "${mock_value}"
}


shtk_unittest_add_test import__ok_from_subdirectory
import__ok_from_subdirectory_test() {
    create_mock_module modules/dir1/dir2/mock.subr mock_value
    SHTK_MODULESPATH=
    SHTK_MODULESDIR="$(pwd)/modules"

    [ -z "${mock_value}" ] || fail "mock_value already defined"
    shtk_import dir1/dir2/mock
    expect_equal 1 "${mock_value}"
}


shtk_unittest_add_test import__idempotent
import__idempotent_test() {
    create_mock_module modules/mock1.subr mock1_value
    create_mock_module modules/mock2.subr mock2_value
    SHTK_MODULESPATH=
    SHTK_MODULESDIR="$(pwd)/modules"

    [ -z "${mock1_value}" ] || fail "mock1_value already defined"
    [ -z "${mock2_value}" ] || fail "mock2_value already defined"
    shtk_import mock1
    shtk_import mock2
    expect_equal 1 "${mock1_value}"
    expect_equal 1 "${mock2_value}"
    shtk_import mock1
    shtk_import mock2
    expect_equal 1 "${mock1_value}"
    expect_equal 1 "${mock2_value}"
}


shtk_unittest_add_test import__from_path__load_once
import__from_path__load_once_test() {
    create_mock_module modules/mock.subr mock_value
    create_mock_module site/mock.subr mock_value
    SHTK_MODULESPATH="$(pwd)/site"
    SHTK_MODULESDIR="$(pwd)/modules"

    [ -z "${mock_value}" ] || fail "mock_value already defined"
    shtk_import mock
    expect_equal 1 "${mock_value}"
}


shtk_unittest_add_test import__from_path__prefer_path
import__from_path__prefer_path_test() {
    create_mock_module modules/mock.subr base_value
    create_mock_module site/mock.subr site_value
    SHTK_MODULESPATH="$(pwd)/site"
    SHTK_MODULESDIR="$(pwd)/modules"

    [ -z "${site_value}" ] || fail "site_value already defined"
    [ -z "${base_value}" ] || fail "base_value already defined"
    shtk_import mock
    [ -n "${site_value}" ] || fail "Site-specific module not loaded"
    [ -z "${base_value}" ] || fail "Base module loaded"
}


shtk_unittest_add_test import__from_path__various_directories
import__from_path__various_directories_test() {
    create_mock_module modules/mock.subr mock_value
    create_mock_module site1/foo.subr foo_value
    create_mock_module site2/bar.subr bar_value
    SHTK_MODULESPATH="$(pwd)/site1:$(pwd)/site2"
    SHTK_MODULESDIR="$(pwd)/modules"

    [ -z "${mock_value}" ] || fail "mock_value already defined"
    [ -z "${foo_value}" ] || fail "foo_value already defined"
    [ -z "${bar_value}" ] || fail "bar_value already defined"
    shtk_import mock
    shtk_import foo
    shtk_import bar
    expect_equal 1 "${mock_value}"
    expect_equal 1 "${foo_value}"
    expect_equal 1 "${bar_value}"
}


shtk_unittest_add_test import__not_found
import__not_found_test() {
    SHTK_MODULESPATH=; export SHTK_MODULESPATH
    SHTK_MODULESDIR=$(pwd); export SHTK_MODULESDIR
    cat >experr <<EOF
base_test: E: Cannot load module abcde; tried $(pwd)/abcde.subr
EOF
    expect_command -s exit:1 -e file:experr shtk_import abcde
}
