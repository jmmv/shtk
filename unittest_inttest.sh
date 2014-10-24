#! __SHTK_SHELL__
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

# Bootstrap and integration tests for the "unittest" module.
#
# This file implements a bunch of rudimentary tests for the "unittest"
# module and serve two purposes: first, that test programs using "unittest"
# and built via shtk are runnable and execute all defined test cases; and,
# second, that the pass/fail code of the test program matches the results
# of the individual test cases.
#
# This test program is purposely not written using shtk's modules at all
# precisely to ensure that the shtk+unittest combination works.  Only once
# we have certain confidence in the behavior of shtk-based test programs,
# we can trust the results yielded by the more complex and detailed tests
# in unittest_test.sh.


# The program name for error-reporting purposes.
_ProgName="${0##*/}"


# Logs an error and fails the test program.
#
# \param ... Error message.  Multiple arguments are concatenated using a
#     single whitespace character.
fail() {
    echo "${_ProgName}: ${*}" 1>&2
    exit 1
}


# Executes a command and validates its exit code and its output.
#
# \param expected_exit_code Expected code that the command should return.
# \param expected_stdout_file Path to a file containing the expected stdout.
# \param expected_stderr_file Path to a file containing the expected stderr.
# \param ... The command to execute.
#
# \return True if the command's execution matches the expected conditions;
# false otherwise.
check() {
    local expected_exit_code="${1}"; shift
    local expected_stdout_file="${1}"; shift
    local expected_stderr_file="${1}"; shift

    local exit_code=0
    "${@}" >out 2>err || exit_code="${?}"

    local failed=no
    [ "${exit_code}" -eq "${expected_exit_code}" ] || failed=yes
    cmp -s "${expected_stdout_file}" out || failed=yes
    cmp -s "${expected_stderr_file}" err || failed=yes

    if [ "${failed}" = yes ]; then
        echo "${@} failed"
        echo "Expected exit code ${expected_exit_code}, got ${exit_code}"
        diff -u "${expected_stdout_file}" out
        diff -u "${expected_stderr_file}" err
        return 1
    fi
}


one_test__always_passes() {
    shtk build -m shtk_unittest_main -o program - <<EOF
shtk_import unittest

shtk_unittest_add_test always_passes
always_passes_test() {
    echo "Hello"
}
EOF

    cat >expout <<EOF
Hello
EOF

    cat >experr <<EOF
program: I: Testing always_passes...
program: I: Testing always_passes... PASSED
program: I: Ran 1 tests; ALL PASSED
EOF

    check 0 expout experr ./program || return 1
}


one_test__always_fails() {
    shtk build -m shtk_unittest_main -o program - <<EOF
shtk_import unittest

shtk_unittest_add_test always_fails
always_fails_test() {
    echo "Hello"
    fail "Oops! Explicitly failing"
    echo "Bye"
}
EOF

    cat >expout <<EOF
Hello
EOF

    cat >experr <<EOF
program: I: Testing always_fails...
program: E: Oops! Explicitly failing
program: W: Testing always_fails... FAILED
program: W: Ran 1 tests; 1 FAILED
EOF

    check 1 expout experr ./program || return 1
}


some_tests__all_pass() {
    shtk build -m shtk_unittest_main -o program - <<EOF
shtk_import unittest

shtk_unittest_add_test first
first_test() { echo "First"; }

shtk_unittest_add_test second
second_test() { set_expect_failure; fail "Second"; echo "not reached"; }

shtk_unittest_add_test third
third_test() { echo "Third"; }
EOF

    cat >expout <<EOF
First
Third
EOF

    cat >experr <<EOF
program: I: Testing first...
program: I: Testing first... PASSED
program: I: Testing second...
program: E: Expected failure: Second
program: I: Testing second... EXPECTED FAILURE
program: I: Testing third...
program: I: Testing third... PASSED
program: I: Ran 3 tests; ALL PASSED
EOF

    check 0 expout experr ./program || return 1
}


some_tests__some_fail() {
    shtk build -m shtk_unittest_main -o program - <<EOF
shtk_import unittest

shtk_unittest_add_test first
first_test() { echo "First"; }

shtk_unittest_add_test second
second_test() { echo "Second"; fail "Bailing out"; echo "Second bis"; }

shtk_unittest_add_test third
third_test() { echo "Third"; }
EOF

    cat >expout <<EOF
First
Second
Third
EOF

    cat >experr <<EOF
program: I: Testing first...
program: I: Testing first... PASSED
program: I: Testing second...
program: E: Bailing out
program: W: Testing second... FAILED
program: I: Testing third...
program: I: Testing third... PASSED
program: W: Ran 3 tests; 1 FAILED
EOF

    check 1 expout experr ./program || return 1
}


fixtures() {
    shtk build -m shtk_unittest_main -o program - <<EOF
shtk_import unittest

shtk_unittest_add_fixture first
first_fixture() {
    setup() { echo "Shared setup"; }
    teardown() { echo "Shared teardown"; }
    shtk_unittest_add_test first
    first_test() { echo "First in first fixture"; }
    shtk_unittest_add_test second
    second_test() { echo "Second in first fixture"; fail "Leave 1"; }
}

shtk_unittest_add_fixture second
second_fixture() {
    shtk_unittest_add_test first
    first_test() { echo "First in second fixture"; fail "Leave 2"; }
    shtk_unittest_add_test second
    second_test() { echo "Second in second fixture"; }
}

shtk_unittest_add_test standalone
standalone_test() {
    echo "Runs outside of the fixtures"
}
EOF

    cat >expout <<EOF
Runs outside of the fixtures
Shared setup
First in first fixture
Shared teardown
Shared setup
Second in first fixture
Shared teardown
First in second fixture
Second in second fixture
EOF

    cat >experr <<EOF
program: I: Testing standalone...
program: I: Testing standalone... PASSED
program: I: Testing first__first...
program: I: Testing first__first... PASSED
program: I: Testing first__second...
program: E: Leave 1
program: W: Testing first__second... FAILED
program: I: Testing second__first...
program: E: Leave 2
program: W: Testing second__first... FAILED
program: I: Testing second__second...
program: I: Testing second__second... PASSED
program: W: Ran 5 tests; 2 FAILED
EOF

    check 1 expout experr ./program || return 1
}


main() {
    for name in \
        one_test__always_passes \
        one_test__always_fails \
        some_tests__all_pass \
        some_tests__some_fail \
        fixtures
    do
        local failed=no
        echo "Running test ${name}"
        (
            mkdir work
            cd work
            "${name}"
        ) || failed=yes
        rm -rf work
        [ "${failed}" = no ] || fail "unittest is severely broken; aborting!"
    done
    echo "OK!"
}


main "${@}"
