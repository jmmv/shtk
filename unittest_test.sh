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


# Checks that the given file matches some golden contents.
#
# \param file Name of the file to be checked.
# \param ... If present, the textual contents to expect; if not present, the
#     golden data is read from stdin.
#
# \post Fails the calling test if the file contents do not match.
assert_file_contents() {
    local file="${1}"; shift

    if [ ${#} -gt 0 ]; then
        if [ -z "${*}" ]; then
            rm -f expected
            touch expected
        else
            echo "${@}" >expected
        fi
    else
        cat >expected
    fi

    if ! cmp -s expected "${file}"; then
        diff -u expected "${file}"
        fail "Contents of ${file} do not match golden contents"
    fi
}


shtk_unittest_register fail__one_argument
fail__one_argument_test() {
    ( shtk_unittest_fail "This is a message" >out 2>err ) \
        && fail "fail did not exit with an error"
    assert_file_contents out ""
    assert_file_contents err <<EOF
unittest_test: E: This is a message
EOF
}


shtk_unittest_register fail__argument_concatenation
fail__argument_concatenation_test() {
    ( shtk_unittest_fail "This is" "another message" >out 2>err ) \
        && fail "fail did not exit with an error"
    assert_file_contents out ""
    assert_file_contents err <<EOF
unittest_test: E: This is another message
EOF
}


shtk_unittest_register main__run_one_test_that_passes
main__run_one_test_that_passes_test() {
    _Shtk_Unittest_TestCases=

    shtk_unittest_register first
    first_test() { echo "first passes"; }

    ( shtk_unittest_main >out 2>err ) \
        || fail "main returned failure but all tests were supposed to pass"
    assert_file_contents out <<EOF
first passes
EOF
    assert_file_contents err <<EOF
unittest_test: I: Testing first...
unittest_test: I: Testing first... PASSED
unittest_test: I: Ran 1 tests; ALL PASSED
EOF
}


shtk_unittest_register main__run_one_test_that_fails
main__run_one_test_that_fails_test() {
    _Shtk_Unittest_TestCases=

    shtk_unittest_register first
    first_test() { fail "first fails"; }

    ( shtk_unittest_main >out 2>err ) \
        && fail "main returned success but all tests were supposed to fail"
    assert_file_contents err <<EOF
unittest_test: I: Testing first...
unittest_test: E: first fails
unittest_test: W: Testing first... FAILED
unittest_test: W: Ran 1 tests; 1 FAILED
EOF
}


shtk_unittest_register main__run_some_tests_that_pass
main__run_some_tests_that_pass_test() {
    _Shtk_Unittest_TestCases=

    shtk_unittest_register first
    first_test() { echo "first passes"; }
    shtk_unittest_register second
    second_test() { echo "second passes"; }

    ( shtk_unittest_main >out 2>err ) \
        || fail "main returned failure but all tests were supposed to pass"
    assert_file_contents out <<EOF
first passes
second passes
EOF
    assert_file_contents err <<EOF
unittest_test: I: Testing first...
unittest_test: I: Testing first... PASSED
unittest_test: I: Testing second...
unittest_test: I: Testing second... PASSED
unittest_test: I: Ran 2 tests; ALL PASSED
EOF
}


shtk_unittest_register main__run_some_tests_that_fail
main__run_some_tests_that_fail_test() {
    _Shtk_Unittest_TestCases=

    shtk_unittest_register first
    first_test() { echo "first passes"; }
    shtk_unittest_register second
    second_test() { fail "second fails"; }
    shtk_unittest_register third
    third_test() { fail "third fails"; }
    shtk_unittest_register fourth
    fourth_test() { echo "fourth passes"; }

    ( shtk_unittest_main >out 2>err ) \
        && fail "main returned success but some tests were supposed to fail"
    assert_file_contents out <<EOF
first passes
fourth passes
EOF
    assert_file_contents err <<EOF
unittest_test: I: Testing first...
unittest_test: I: Testing first... PASSED
unittest_test: I: Testing second...
unittest_test: E: second fails
unittest_test: W: Testing second... FAILED
unittest_test: I: Testing third...
unittest_test: E: third fails
unittest_test: W: Testing third... FAILED
unittest_test: I: Testing fourth...
unittest_test: I: Testing fourth... PASSED
unittest_test: W: Ran 4 tests; 2 FAILED
EOF
}


shtk_unittest_register main__no_tests_error
main__no_tests_error_test() {
    _Shtk_Unittest_TestCases=

    ( shtk_unittest_main >out 2>err ) \
        && fail "main did not error out on no tests"
    assert_file_contents err \
        "unittest_test: E: No test cases defined; did you call register?"
}


shtk_unittest_register register__default_methods
register__default_methods_test() {
    shtk_unittest_register default_methods \
        || fail "Failed to register test case"

    ( default_methods_test >out 2>err ) \
        && fail "test method not properly defined"
    assert_file_contents err \
        "unittest_test: E: default_methods_test not defined"
}


shtk_unittest_register register__duplicate_error
register__duplicate_error_test() {
    shtk_unittest_register first || fail "register failed"
    shtk_unittest_register dup || fail "register failed"
    shtk_unittest_register last || fail "register failed"

    ( shtk_unittest_register dup >out 2>err ) \
        && fail "register did not fail for a duplicate test case"
    assert_file_contents err \
        "unittest_test: E: Duplicate test case found: dup"
}


shtk_unittest_register run__pass_due_to_fallthrough
run__pass_due_to_fallthrough_test() {
    shtk_unittest_register always_passes
    always_passes_test() {
        echo "This is the test code"
    }

    ( shtk_unittest_run always_passes >out 2>err ) \
        || fail "run reported failure for passing test case"

    assert_file_contents out <<EOF
This is the test code
EOF
    assert_file_contents err <<EOF
unittest_test: I: Testing always_passes...
unittest_test: I: Testing always_passes... PASSED
EOF
}


shtk_unittest_register run__pass_due_to_exit
run__pass_due_to_exit_test() {
    shtk_unittest_register always_passes
    always_passes_test() {
        echo "This is the test code"
        exit 0
    }

    ( shtk_unittest_run always_passes >out 2>err ) \
        || fail "run reported failure for passing test case"

    assert_file_contents out <<EOF
This is the test code
EOF
    assert_file_contents err <<EOF
unittest_test: I: Testing always_passes...
unittest_test: I: Testing always_passes... PASSED
EOF
}


shtk_unittest_register run__fail_due_to_exit
run__fail_due_to_exit_test() {
    shtk_unittest_register always_fails
    always_fails_test() {
        echo "This is the test code"
        exit 1
    }

    ( shtk_unittest_run always_fails >out 2>err ) \
        && fail "run reported success for failing test case"

    assert_file_contents out <<EOF
This is the test code
EOF
    assert_file_contents err <<EOF
unittest_test: I: Testing always_fails...
unittest_test: W: Testing always_fails... FAILED
EOF
}


shtk_unittest_register run__fail_due_to_fail
run__fail_due_to_fail_test() {
    shtk_unittest_register always_fails
    always_fails_test() {
        echo "This is the test code"
        shtk_unittest_fail "Aborting test"
        echo "Not reached"
    }

    ( shtk_unittest_run always_fails >out 2>err ) \
        && fail "run reported success for failing test case"

    assert_file_contents out <<EOF
This is the test code
EOF
    assert_file_contents err <<EOF
unittest_test: I: Testing always_fails...
unittest_test: E: Aborting test
unittest_test: W: Testing always_fails... FAILED
EOF
}


shtk_unittest_register run__bring_into_namespace
run__bring_into_namespace_test() {
    shtk_unittest_register call_stubs
    call_stubs_test() {
        shtk_unittest_fail() { echo "stub for fail: ${*}"; }

        echo "Calling stubs"
        fail "Aborting test"
        echo "All stubs done"
    }

    ( shtk_unittest_run call_stubs >out 2>err ) \
        || fail "Failed to bring expected functions into the namespace"

    assert_file_contents out <<EOF
Calling stubs
stub for fail: Aborting test
All stubs done
EOF
    assert_file_contents err <<EOF
unittest_test: I: Testing call_stubs...
unittest_test: I: Testing call_stubs... PASSED
EOF
}


shtk_unittest_register run__unregistered_error
run__unregistered_error_test() {
    ( shtk_unittest_run not_there >out 2>err ) \
        && fail "run did not fail for an unregistered test case"
    assert_file_contents err \
        "unittest_test: E: Attempting to run unregistered test case not_there"
}
