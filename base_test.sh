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

# No imports: we can assume the bootstrap code to be present.


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


atf_test_case import__ok
import__ok_body() {
    create_mock_module modules/mock.subr mock_value
    SHTK_MODULESPATH=
    SHTK_MODULESDIR="$(pwd)/modules"

    [ -z "${mock_value}" ] || atf_fail "mock_value already defined"
    shtk_import mock
    atf_check_equal 1 "${mock_value}"
}


atf_test_case import__idempotent
import__idempotent_body() {
    create_mock_module modules/mock1.subr mock1_value
    create_mock_module modules/mock2.subr mock2_value
    SHTK_MODULESPATH=
    SHTK_MODULESDIR="$(pwd)/modules"

    [ -z "${mock1_value}" ] || atf_fail "mock1_value already defined"
    [ -z "${mock2_value}" ] || atf_fail "mock2_value already defined"
    shtk_import mock1
    shtk_import mock2
    atf_check_equal 1 "${mock1_value}"
    atf_check_equal 1 "${mock2_value}"
    shtk_import mock1
    shtk_import mock2
    atf_check_equal 1 "${mock1_value}"
    atf_check_equal 1 "${mock2_value}"
}


atf_test_case import__from_path__load_once
import__from_path__load_once_body() {
    create_mock_module modules/mock.subr mock_value
    create_mock_module site/mock.subr mock_value
    SHTK_MODULESPATH="$(pwd)/site"
    SHTK_MODULESDIR="$(pwd)/modules"

    [ -z "${mock_value}" ] || atf_fail "mock_value already defined"
    shtk_import mock
    atf_check_equal 1 "${mock_value}"
}


atf_test_case import__from_path__prefer_path
import__from_path__prefer_path_body() {
    create_mock_module modules/mock.subr base_value
    create_mock_module site/mock.subr site_value
    SHTK_MODULESPATH="$(pwd)/site"
    SHTK_MODULESDIR="$(pwd)/modules"

    [ -z "${site_value}" ] || atf_fail "site_value already defined"
    [ -z "${base_value}" ] || atf_fail "base_value already defined"
    shtk_import mock
    [ -n "${site_value}" ] || atf_fail "Site-specific module not loaded"
    [ -z "${base_value}" ] || atf_fail "Base module loaded"
}


atf_test_case import__from_path__various_directories
import__from_path__various_directories_body() {
    create_mock_module modules/mock.subr mock_value
    create_mock_module site1/foo.subr foo_value
    create_mock_module site2/bar.subr bar_value
    SHTK_MODULESPATH="$(pwd)/site1:$(pwd)/site2"
    SHTK_MODULESDIR="$(pwd)/modules"

    [ -z "${mock_value}" ] || atf_fail "mock_value already defined"
    [ -z "${foo_value}" ] || atf_fail "foo_value already defined"
    [ -z "${bar_value}" ] || atf_fail "bar_value already defined"
    shtk_import mock
    shtk_import foo
    shtk_import bar
    atf_check_equal 1 "${mock_value}"
    atf_check_equal 1 "${foo_value}"
    atf_check_equal 1 "${bar_value}"
}


atf_test_case import__not_found
import__not_found_body() {
    SHTK_MODULESPATH=; export SHTK_MODULESPATH
    SHTK_MODULESDIR=$(pwd); export SHTK_MODULESDIR
    if ( shtk_import abcde ) >out 2>err; then
        atf_fail "import of a non-existent module succeeded"
    else
        cat >experr <<EOF
base_test: E: Cannot load module abcde; tried $(pwd)/abcde.subr
EOF
        atf_check -o file:experr cat err
    fi
}


atf_init_test_cases() {
    atf_add_test_case import__ok
    atf_add_test_case import__idempotent
    atf_add_test_case import__from_path__load_once
    atf_add_test_case import__from_path__prefer_path
    atf_add_test_case import__from_path__various_directories
    atf_add_test_case import__not_found
}
