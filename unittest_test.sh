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


shtk_unittest_add_fixture add_fixture
add_fixture_fixture() {
    shtk_unittest_add_test default_methods
    default_methods_test() {
        shtk_unittest_add_fixture first \
            || fail "Failed to register fixture"

        ( first_fixture >out 2>err ) \
            && fail "fixture method not properly defined"
        assert_file_contents err \
            "unittest_test: E: first_fixture not defined"
    }


    shtk_unittest_add_test duplicate_error
    duplicate_error_test() {
        shtk_unittest_add_fixture first || fail "add_fixture failed"
        shtk_unittest_add_fixture dup || fail "add_fixture failed"
        shtk_unittest_add_fixture last || fail "add_fixture failed"

        shtk_unittest_add_test first || fail "add_test failed"

        ( shtk_unittest_add_fixture dup >out 2>err ) \
            && fail "add_fixture did not fail for a duplicate test case"
        assert_file_contents err \
            "unittest_test: E: Duplicate test fixture found: dup"
    }
}


shtk_unittest_add_fixture add_test
add_test_fixture() {
    shtk_unittest_add_test default_methods
    default_methods_test() {
        shtk_unittest_add_test first \
            || fail "Failed to register test case"

        ( first_test >out 2>err ) \
            && fail "test method not properly defined"
        assert_file_contents err \
            "unittest_test: E: first_test not defined"
    }


    shtk_unittest_add_test duplicate_error
    duplicate_error_test() {
        shtk_unittest_add_test first || fail "add_test failed"
        shtk_unittest_add_test dup || fail "add_test failed"
        shtk_unittest_add_test last || fail "add_test failed"

        ( shtk_unittest_add_test dup >out 2>err ) \
            && fail "add_test did not fail for a duplicate test case"
        assert_file_contents err \
            "unittest_test: E: Duplicate test case found: dup"
    }
}


shtk_unittest_add_fixture delayed_fail
delayed_fail_fixture() {
    shtk_unittest_add_test one_argument
    one_argument_test() {
        ( shtk_unittest_delayed_fail "This is a message"; echo "more stuff" ) \
            >out 2>err || fail "delayed_fail exited prematurely"
        assert_file_contents out <<EOF
more stuff
EOF
        assert_file_contents err <<EOF
unittest_test: W: Delayed failure: This is a message
EOF
        assert_file_contents result.delayed-fail 1
        rm -f result.delayed-fail
    }


    shtk_unittest_add_test argument_concatenation
    argument_concatenation_test() {
        ( shtk_unittest_delayed_fail "One" "more message"; echo "hi" ) \
            >out 2>err || fail "delayed_fail exited prematurely"
        assert_file_contents out <<EOF
hi
EOF
        assert_file_contents err <<EOF
unittest_test: W: Delayed failure: One more message
EOF
        assert_file_contents result.delayed-fail 1
        rm -f result.delayed-fail
    }


    shtk_unittest_add_test counter
    counter_test() {
        (
            shtk_unittest_delayed_fail "This is a message";
            echo "more stuff"
            shtk_unittest_delayed_fail "This is another message";
            echo "exiting"
        ) >out 2>err || fail "delayed_fail exited prematurely"
        assert_file_contents out <<EOF
more stuff
exiting
EOF
        assert_file_contents err <<EOF
unittest_test: W: Delayed failure: This is a message
unittest_test: W: Delayed failure: This is another message
EOF
        assert_file_contents result.delayed-fail 2
        rm -f result.delayed-fail
    }


    shtk_unittest_add_test expect_failure
    expect_failure_test() {
        (
            shtk_unittest_set_expect_failure
            shtk_unittest_delayed_fail "This is a message"
            echo "more stuff"
        ) >out 2>err
        if [ "${?}" -eq 0 ]; then
            rm -f result.expect-fail
            fail "delayed_fail exited cleanly"
        else
            rm -f result.expect-fail
        fi
        assert_file_contents out ""
        assert_file_contents err <<EOF
unittest_test: E: delayed_fail does not support expected failures
EOF
        [ ! -f result.delayed-fail ] || fail "Found delayed_fail cookie"
    }
}


shtk_unittest_add_fixture fail
fail_fixture() {
    shtk_unittest_add_test one_argument
    one_argument_test() {
        ( shtk_unittest_fail "This is a message" >out 2>err ) \
            && fail "fail did not exit with an error"
        assert_file_contents out ""
        assert_file_contents err <<EOF
unittest_test: E: This is a message
EOF
    }


    shtk_unittest_add_test argument_concatenation
    argument_concatenation_test() {
        ( shtk_unittest_fail "This is" "another message" >out 2>err ) \
            && fail "fail did not exit with an error"
        assert_file_contents out ""
        assert_file_contents err <<EOF
unittest_test: E: This is another message
EOF
    }


    shtk_unittest_add_test expect_failure
    expect_failure_test() {
        (
            shtk_unittest_set_expect_failure
            shtk_unittest_fail "Some text"
            echo "not reached"
        ) >out 2>err
        if [ "${?}" -eq 0 ]; then
            rm -f result.expect-fail
            fail "fail did not exit with an error"
        else
            rm -f result.expect-fail
        fi
        assert_file_contents out ""
        assert_file_contents err <<EOF
unittest_test: E: Expected failure: Some text
EOF
    }
}


shtk_unittest_add_fixture main
main_fixture() {
    setup() {
        _Shtk_Unittest_TestCases=
        _Shtk_Unittest_TestFixtures=
    }


    shtk_unittest_add_test run_one_test_that_passes
    run_one_test_that_passes_test() {
        shtk_unittest_add_test first
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


    shtk_unittest_add_test run_one_test_that_fails
    run_one_test_that_fails_test() {
        shtk_unittest_add_test first
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


    shtk_unittest_add_test run_some_tests_that_pass
    run_some_tests_that_pass_test() {
        shtk_unittest_add_test first
        first_test() { echo "first passes"; }
        shtk_unittest_add_test second
        second_test() { skip "second skips"; echo "Not reached"; }
        shtk_unittest_add_test third
        third_test() { echo "third passes"; }

        ( shtk_unittest_main >out 2>err ) \
            || fail "main returned failure but all tests were supposed to pass"
        assert_file_contents out <<EOF
first passes
third passes
EOF
        assert_file_contents err <<EOF
unittest_test: I: Testing first...
unittest_test: I: Testing first... PASSED
unittest_test: I: Testing second...
unittest_test: W: second skips
unittest_test: W: Testing second... SKIPPED
unittest_test: I: Testing third...
unittest_test: I: Testing third... PASSED
unittest_test: I: Ran 3 tests; ALL PASSED
EOF
    }


    shtk_unittest_add_test run_some_tests_that_fail
    run_some_tests_that_fail_test() {
        shtk_unittest_add_test first
        first_test() { echo "first passes"; }
        shtk_unittest_add_test second
        second_test() { fail "second fails"; }
        shtk_unittest_add_test third
        third_test() { fail "third fails"; }
        shtk_unittest_add_test fourth
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


    shtk_unittest_add_test run_tests_and_fixtures_passing
    run_tests_and_fixtures_passing_test() {
        shtk_unittest_add_test first
        first_test() { echo "first passes"; }
        shtk_unittest_add_test second
        second_test() { echo "second passes"; }

        shtk_unittest_add_fixture third
        third_fixture() {
            setup() { echo "Fixture setup"; }
            teardown() { echo "Fixture teardown"; }

            shtk_unittest_add_test first
            first_test() { echo "first within third passes"; }
            shtk_unittest_add_test other
            other_test() { echo "other within third passes"; }
        }

        ( shtk_unittest_main >out 2>err ) \
            || fail "main returned failure but all tests were supposed to pass"
        assert_file_contents out <<EOF
first passes
second passes
Fixture setup
first within third passes
Fixture teardown
Fixture setup
other within third passes
Fixture teardown
EOF
        assert_file_contents err <<EOF
unittest_test: I: Testing first...
unittest_test: I: Testing first... PASSED
unittest_test: I: Testing second...
unittest_test: I: Testing second... PASSED
unittest_test: I: Testing third__first...
unittest_test: I: Testing third__first... PASSED
unittest_test: I: Testing third__other...
unittest_test: I: Testing third__other... PASSED
unittest_test: I: Ran 4 tests; ALL PASSED
EOF
    }


    shtk_unittest_add_test run_tests_and_fixtures_failing
    run_tests_and_fixtures_failing_test() {
        shtk_unittest_add_test first
        first_test() { echo "first passes"; }
        shtk_unittest_add_test second
        second_test() { fail "second fails"; echo "Not run"; }

        shtk_unittest_add_fixture third
        third_fixture() {
            setup() { echo "Fixture setup"; }
            teardown() { echo "Fixture teardown"; }

            shtk_unittest_add_test first
            first_test() { fail "first within third fails"; echo "Not run"; }
            shtk_unittest_add_test other
            other_test() { echo "other within third passes"; }
        }

        ( shtk_unittest_main >out 2>err ) \
            && fail "main returned success but some tests were supposed to fail"
        assert_file_contents out <<EOF
first passes
Fixture setup
Fixture teardown
Fixture setup
other within third passes
Fixture teardown
EOF
        assert_file_contents err <<EOF
unittest_test: I: Testing first...
unittest_test: I: Testing first... PASSED
unittest_test: I: Testing second...
unittest_test: E: second fails
unittest_test: W: Testing second... FAILED
unittest_test: I: Testing third__first...
unittest_test: E: first within third fails
unittest_test: W: Testing third__first... FAILED
unittest_test: I: Testing third__other...
unittest_test: I: Testing third__other... PASSED
unittest_test: W: Ran 4 tests; 2 FAILED
EOF
    }


    shtk_unittest_add_test different_directories
    different_directories_test() {
        shtk_unittest_add_test first
        first_test() {
            touch the-file
        }
        shtk_unittest_add_test second
        second_test() {
            if [ -f the-file ]; then
                fail "Found file from previous test!"
            fi
        }

        ( shtk_unittest_main >out 2>err ) \
            || fail "main returned failure but all tests were supposed to pass"
        assert_file_contents out ""
        assert_file_contents err <<EOF
unittest_test: I: Testing first...
unittest_test: I: Testing first... PASSED
unittest_test: I: Testing second...
unittest_test: I: Testing second... PASSED
unittest_test: I: Ran 2 tests; ALL PASSED
EOF
    }


    shtk_unittest_add_test one_time_setup_and_teardown
    one_time_setup_and_teardown_test() {
        one_time_setup() { echo "setting up"; echo "still here" >>"cookie"; }
        one_time_teardown() { echo "tearing down"; rm "cookie"; }

        shtk_unittest_add_test first
        first_test() { echo "first test"; cat ../cookie; }
        shtk_unittest_add_test second
        second_test() { echo "second test"; cat ../cookie; }

        ( shtk_unittest_main >out 2>err ) \
            || fail "main returned failure but all tests were supposed to pass"
        assert_file_contents out <<EOF
setting up
first test
still here
second test
still here
tearing down
EOF
        assert_file_contents err <<EOF
unittest_test: I: Testing first...
unittest_test: I: Testing first... PASSED
unittest_test: I: Testing second...
unittest_test: I: Testing second... PASSED
unittest_test: I: Ran 2 tests; ALL PASSED
EOF
    }


    shtk_unittest_add_test no_tests_error
    no_tests_error_test() {
        ( shtk_unittest_main >out 2>err ) \
            && fail "main did not error out on no tests"
        assert_file_contents err \
            "unittest_test: E: No test cases defined; did you call" \
            "shtk_unittest_add_fixture or shtk_unittest_add_test?"
    }
}


shtk_unittest_add_fixture register_check
register_check_fixture() {
    _shtk_unittest_check_mock() {
        local wrapper_name="${1}"; shift
        local fail_function="${1}"; shift

        echo "Mock called by ${wrapper_name}"
        echo "Mock with arguments: ${*}"
        [ "${1}" != fail ] || "${fail_function}" "Failing test"
    }
    _shtk_unittest_register_check mock


    shtk_unittest_add_test assert__ok
    assert__ok_test() {
        (
            assert_mock "this call" "should pass"
            echo reached
        ) >out 2>err || fail "mock call expected to pass but failed"
        assert_file_contents out <<EOF
Mock called by shtk_unittest_assert_mock
Mock with arguments: this call should pass
reached
EOF
        assert_file_contents err ""
    }


    shtk_unittest_add_test assert__fail
    assert__fail_test() {
        (
            assert_mock fail
            echo reached
        ) >out 2>err && fail "mock call expected to fail but passed"
        assert_file_contents out <<EOF
Mock called by shtk_unittest_assert_mock
Mock with arguments: fail
EOF
        assert_file_contents err "unittest_test: E: Failing test"
    }


    shtk_unittest_add_test expect__ok
    expect__ok_test() {
        (
            expect_mock "this call" "should pass"
            echo reached
        ) >out 2>err || fail "mock call expected to pass but failed"
        assert_file_contents out <<EOF
Mock called by shtk_unittest_expect_mock
Mock with arguments: this call should pass
reached
EOF
        assert_file_contents err ""
    }


    shtk_unittest_add_test expect__fail
    expect__fail_test() {
        (
            expect_mock fail
            echo reached
            expect_mock fail
            echo reached as well
        ) >out 2>err || fail "mock call expected to pass but failed"
        assert_file_contents out <<EOF
Mock called by shtk_unittest_expect_mock
Mock with arguments: fail
reached
Mock called by shtk_unittest_expect_mock
Mock with arguments: fail
reached as well
EOF
        assert_file_contents err <<EOF
unittest_test: W: Delayed failure: Failing test
unittest_test: W: Delayed failure: Failing test
EOF
        assert_file_contents result.delayed-fail 2
        rm -f result.delayed-fail
    }


    shtk_unittest_add_test expect__integration_with_run
    expect__integration_with_run_test() {
        shtk_unittest_add_test always_fails
        always_fails_test() {
            expect_mock fail
            echo reached
            expect_mock fail
            echo reached as well
        }

        ( _shtk_unittest_run_standalone_test always_fails >out 2>err ) \
            && fail "run_test reported success for failing test case"

        assert_file_contents out <<EOF
Mock called by shtk_unittest_expect_mock
Mock with arguments: fail
reached
Mock called by shtk_unittest_expect_mock
Mock with arguments: fail
reached as well
EOF
        assert_file_contents err <<EOF
unittest_test: I: Testing always_fails...
unittest_test: W: Delayed failure: Failing test
unittest_test: W: Delayed failure: Failing test
unittest_test: W: Testing always_fails... FAILED (2 delayed failures)
EOF
    }
}


shtk_unittest_add_fixture run_fixture_test
run_fixture_test_fixture() {
    # Because run_fixture_test and run_standalone_test share most of their code
    # via _shtk_unittest_{enter,leave}_test, these tests only verify
    # fixture-specific behavior.

    shtk_unittest_add_test setup_and_teardown_run_on_successful_exit
    setup_and_teardown_run_on_successful_exit_test() {
        setup() { echo "This is the setup"; }
        teardown() { echo "This is the teardown"; }

        shtk_unittest_add_test always_passes
        always_passes_test() {
            echo "This is the test code"
        }

        ( _shtk_unittest_run_fixture_test container always_passes >out 2>err ) \
            || fail "run_fixture reported failure for passing test case"

        assert_file_contents out <<EOF
This is the setup
This is the test code
This is the teardown
EOF
        assert_file_contents err <<EOF
unittest_test: I: Testing container__always_passes...
unittest_test: I: Testing container__always_passes... PASSED
EOF
    }


    shtk_unittest_add_test setup_and_teardown_run_on_failure
    setup_and_teardown_run_on_failure_test() {
        setup() { echo "This is the setup"; }
        teardown() { echo "This is the teardown"; }

        shtk_unittest_add_test always_fails
        always_fails_test() {
            echo "This is the test code"
            fail "Oh noes; exiting"
            echo "Not reached"
        }

        ( _shtk_unittest_run_fixture_test container always_fails >out 2>err ) \
            && fail "run_fixture reported failure for failing test case"

        assert_file_contents out <<EOF
This is the setup
This is the test code
This is the teardown
EOF
        assert_file_contents err <<EOF
unittest_test: I: Testing container__always_fails...
unittest_test: E: Oh noes; exiting
unittest_test: W: Testing container__always_fails... FAILED
EOF
    }


    shtk_unittest_add_test setup_failure_aborts_early
    setup_failure_aborts_early_test() {
        setup() { echo "This is the setup"; exit 1; }
        teardown() { echo "This is the teardown"; }

        shtk_unittest_add_test always_passes
        always_passes_test() {
            echo "This is the test code"
        }

        ( _shtk_unittest_run_fixture_test container always_passes >out 2>err ) \
            && fail "run_fixture reported failure for failing setup"

        assert_file_contents out <<EOF
This is the setup
EOF
        assert_file_contents err <<EOF
unittest_test: I: Testing container__always_passes...
unittest_test: W: Testing container__always_passes... FAILED
EOF
    }


    shtk_unittest_add_test teardown_failure_fails_test
    teardown_failure_fails_test_test() {
        setup() { echo "This is the setup"; }
        teardown() { echo "This is the teardown"; exit 1; }

        shtk_unittest_add_test always_passes
        always_passes_test() {
            echo "This is the test code"
        }

        ( _shtk_unittest_run_fixture_test container always_passes >out 2>err ) \
            && fail "run_fixture reported failure for failing teardown"

        assert_file_contents out <<EOF
This is the setup
This is the test code
This is the teardown
EOF
        assert_file_contents err <<EOF
unittest_test: I: Testing container__always_passes...
unittest_test: W: Testing container__always_passes... FAILED
EOF
    }


    shtk_unittest_add_test pass_on_fallthrough_even_if_false
    pass_on_fallthrough_even_if_false_test() {
        setup() { echo "This is the setup"; false; }
        teardown() { echo "This is the teardown"; false; }

        shtk_unittest_add_test should_pass
        should_pass_test() {
            echo "This is the test code"
            false
        }

        ( _shtk_unittest_run_fixture_test container should_pass >out 2>err ) \
            || fail "run_fixture reported failure for passing test case"

        assert_file_contents out <<EOF
This is the setup
This is the test code
This is the teardown
EOF
        assert_file_contents err <<EOF
unittest_test: I: Testing container__should_pass...
unittest_test: I: Testing container__should_pass... PASSED
EOF
    }


    shtk_unittest_add_test process_lifecycle
    process_lifecycle_test() {
        GLOBAL=empty

        setup() {
            echo "setup enter: ${GLOBAL}"
            [ "${GLOBAL}" = empty ] || fail "Got '${GLOBAL}'; expected 'empty'"
            GLOBAL=setup
            echo "setup exit: ${GLOBAL}"
        }
        teardown() {
            echo "teardown: ${GLOBAL}"
            [ "${GLOBAL}" = setup ] || fail "Got '${GLOBAL}'; expected 'setup'"
        }

        shtk_unittest_add_test change_env
        change_env_test() {
            echo "test enter: ${GLOBAL}"
            [ "${GLOBAL}" = setup ] || fail "Got '${GLOBAL}'; expected 'setup'"
            GLOBAL=body
            echo "test exit: ${GLOBAL}"
        }

        ( _shtk_unittest_run_fixture_test container change_env >out 2>err ) \
            || fail "run_fixture reported failure for passing test case"

        assert_file_contents out <<EOF
setup enter: empty
setup exit: setup
test enter: setup
test exit: body
teardown: setup
EOF
        assert_file_contents err <<EOF
unittest_test: I: Testing container__change_env...
unittest_test: I: Testing container__change_env... PASSED
EOF
    }


    shtk_unittest_add_test same_directory
    same_directory_test() {
        setup() {
            touch created-by-setup
        }
        teardown() {
            [ -f created-by-setup ] || fail "Cannot find file from setup"
        }

        shtk_unittest_add_test always_passes
        always_passes_test() {
            [ -f created-by-setup ] || fail "Cannot find file from setup"
        }

        ( _shtk_unittest_run_fixture_test container always_passes >out 2>err ) \
            || fail "run_fixture reported failure for passing test case"

        assert_file_contents out ""
        assert_file_contents err <<EOF
unittest_test: I: Testing container__always_passes...
unittest_test: I: Testing container__always_passes... PASSED
EOF
    }


    shtk_unittest_add_test unregistered_error
    unregistered_error_test() {
        ( _shtk_unittest_run_fixture_test container not_there >out 2>err ) \
            && fail "run_fixture did not fail for an unregistered test case"
        assert_file_contents err \
        "unittest_test: E: Attempting to run unregistered test case"  \
            "container__not_there"
    }
}


shtk_unittest_add_fixture run_standalone_test
run_standalone_test_fixture() {
    # These tests are intended to verify the execution of individual test cases
    # exhaustively.
    #
    # These tests indirectly verify _shtk_unittest_{enter,leave}_test.

    shtk_unittest_add_test pass_due_to_fallthrough
    pass_due_to_fallthrough_test() {
        shtk_unittest_add_test always_passes
        always_passes_test() {
            echo "This is the test code"
        }

        ( _shtk_unittest_run_standalone_test always_passes >out 2>err ) \
            || fail "run_test reported failure for passing test case"

        assert_file_contents out <<EOF
This is the test code
EOF
        assert_file_contents err <<EOF
unittest_test: I: Testing always_passes...
unittest_test: I: Testing always_passes... PASSED
EOF
    }


    shtk_unittest_add_test pass_on_fallthrough_even_if_false
    pass_on_fallthrough_even_if_false_test() {
        shtk_unittest_add_test should_pass
        should_pass_test() {
            echo "This is the test code"
            false
        }

        ( _shtk_unittest_run_standalone_test should_pass >out 2>err ) \
            || fail "run_test reported failure for passing test case"

        assert_file_contents out <<EOF
This is the test code
EOF
        assert_file_contents err <<EOF
unittest_test: I: Testing should_pass...
unittest_test: I: Testing should_pass... PASSED
EOF
    }


    shtk_unittest_add_test pass_due_to_exit
    pass_due_to_exit_test() {
        shtk_unittest_add_test always_passes
        always_passes_test() {
            echo "This is the test code"
            exit 0
        }

        ( _shtk_unittest_run_standalone_test always_passes >out 2>err ) \
            || fail "run_test reported failure for passing test case"

        assert_file_contents out <<EOF
This is the test code
EOF
        assert_file_contents err <<EOF
unittest_test: I: Testing always_passes...
unittest_test: I: Testing always_passes... PASSED
EOF
    }


    shtk_unittest_add_test fail_due_to_exit
    fail_due_to_exit_test() {
        shtk_unittest_add_test always_fails
        always_fails_test() {
            echo "This is the test code"
            exit 1
        }

        ( _shtk_unittest_run_standalone_test always_fails >out 2>err ) \
            && fail "run_test reported success for failing test case"

        assert_file_contents out <<EOF
This is the test code
EOF
        assert_file_contents err <<EOF
unittest_test: I: Testing always_fails...
unittest_test: W: Testing always_fails... FAILED
EOF
    }


    shtk_unittest_add_test fail_due_to_fail
    fail_due_to_fail_test() {
        shtk_unittest_add_test always_fails
        always_fails_test() {
            echo "This is the test code"
            shtk_unittest_fail "Aborting test"
            echo "Not reached"
        }

        ( _shtk_unittest_run_standalone_test always_fails >out 2>err ) \
            && fail "run_test reported success for failing test case"

        assert_file_contents out <<EOF
This is the test code
EOF
        assert_file_contents err <<EOF
unittest_test: I: Testing always_fails...
unittest_test: E: Aborting test
unittest_test: W: Testing always_fails... FAILED
EOF
    }


    shtk_unittest_add_test fail_due_to_delayed_failures
    fail_due_to_delayed_failures_test() {
        shtk_unittest_add_test always_fails
        always_fails_test() {
            shtk_unittest_delayed_fail "first delayed failure"
            shtk_unittest_delayed_fail "second delayed failure"
            shtk_unittest_delayed_fail "third delayed failure"
        }

        ( _shtk_unittest_run_standalone_test always_fails >out 2>err ) \
            && fail "run_test reported success for failing test case"
        assert_file_contents out ""
        assert_file_contents err <<EOF
unittest_test: I: Testing always_fails...
unittest_test: W: Delayed failure: first delayed failure
unittest_test: W: Delayed failure: second delayed failure
unittest_test: W: Delayed failure: third delayed failure
unittest_test: W: Testing always_fails... FAILED (3 delayed failures)
EOF
    }


    shtk_unittest_add_test fail_trumps_delayed_fail
    fail_trumps_delayed_fail_test() {
        shtk_unittest_add_test always_fails
        always_fails_test() {
            shtk_unittest_delayed_fail "first delayed failure"
            shtk_unittest_fail "fatal failure"
            shtk_unittest_delayed_fail "second delayed failure"
        }

        ( _shtk_unittest_run_standalone_test always_fails >out 2>err ) \
            && fail "run_test reported success for failing test case"
        assert_file_contents out ""
        assert_file_contents err <<EOF
unittest_test: I: Testing always_fails...
unittest_test: W: Delayed failure: first delayed failure
unittest_test: E: fatal failure
unittest_test: W: Testing always_fails... FAILED
EOF
    }


    shtk_unittest_add_test delayed_fail_trumps_skip
    delayed_fail_trumps_skip_test() {
        shtk_unittest_add_test always_fails
        always_fails_test() {
            shtk_unittest_delayed_fail "first delayed failure"
            skip "ignored skip condition"
            shtk_unittest_delayed_fail "second delayed failure"
        }

        ( _shtk_unittest_run_standalone_test always_fails >out 2>err ) \
            && fail "run_test reported success for failing test case"
        assert_file_contents out ""
        assert_file_contents err <<EOF
unittest_test: I: Testing always_fails...
unittest_test: W: Delayed failure: first delayed failure
unittest_test: W: ignored skip condition
unittest_test: W: Testing always_fails... FAILED (1 delayed failures)
EOF
    }


    shtk_unittest_add_test expected_failure__fail_is_pass
    expected_failure__fail_is_pass_test() {
        shtk_unittest_add_test subtest
        subtest_test() {
            shtk_unittest_set_expect_failure
            shtk_unittest_fail "first xfail"
            echo "not reached"
        }

        ( _shtk_unittest_run_standalone_test subtest >out 2>err ) \
            || fail "run_test reported failure for passing test case"
        assert_file_contents out ""
        assert_file_contents err <<EOF
unittest_test: I: Testing subtest...
unittest_test: E: Expected failure: first xfail
unittest_test: I: Testing subtest... EXPECTED FAILURE
EOF
    }


    shtk_unittest_add_test expected_failure__pass_is_fail
    expected_failure__pass_is_fail_test() {
        shtk_unittest_add_test subtest
        subtest_test() {
            shtk_unittest_set_expect_failure
            echo "nothing fails"
        }

        ( _shtk_unittest_run_standalone_test subtest >out 2>err ) \
            && fail "run_test reported success for failing test case"
        assert_file_contents out "nothing fails"
        assert_file_contents err <<EOF
unittest_test: I: Testing subtest...
unittest_test: W: Expected failure but none found
unittest_test: W: Testing subtest... FAILED
EOF
    }


    shtk_unittest_add_test skip
    skip_test() {
        shtk_unittest_add_test always_skips
        always_skips_test() {
            echo "This is the test code"
            skip "Good bye"
            echo "Not reached"
        }

        ( _shtk_unittest_run_standalone_test always_skips >out 2>err ) \
            || fail "run_test reported failure for skipped test case"

        assert_file_contents out <<EOF
This is the test code
EOF
        assert_file_contents err <<EOF
unittest_test: I: Testing always_skips...
unittest_test: W: Good bye
unittest_test: W: Testing always_skips... SKIPPED
EOF
    }


    shtk_unittest_add_test bring_into_namespace
    bring_into_namespace_test() {
        shtk_unittest_add_test call_stubs
        call_stubs_test() {
            local funcs="delayed_fail fail set_expect_failure skip"
            local funcs="${funcs} assert_command expect_command"
            local funcs="${funcs} assert_equal expect_equal"
            local funcs="${funcs} assert_not_equal expect_not_equal"

            for func in ${funcs}; do
                eval "shtk_unittest_${func}() { \
                    echo \"stub for ${func}: \${*}\"; }"
            done

            echo "Calling stubs"
            for func in ${funcs}; do
                "${func}" "arguments to the stub"
            done
            echo "All stubs done"
        }

        ( _shtk_unittest_run_standalone_test call_stubs >out 2>err ) \
            || fail "Failed to bring expected functions into the namespace"

        assert_file_contents out <<EOF
Calling stubs
stub for delayed_fail: arguments to the stub
stub for fail: arguments to the stub
stub for set_expect_failure: arguments to the stub
stub for skip: arguments to the stub
stub for assert_command: arguments to the stub
stub for expect_command: arguments to the stub
stub for assert_equal: arguments to the stub
stub for expect_equal: arguments to the stub
stub for assert_not_equal: arguments to the stub
stub for expect_not_equal: arguments to the stub
All stubs done
EOF
        assert_file_contents err <<EOF
unittest_test: I: Testing call_stubs...
unittest_test: I: Testing call_stubs... PASSED
EOF
    }


    shtk_unittest_add_test unregistered_error
    unregistered_error_test() {
        ( _shtk_unittest_run_standalone_test not_there >out 2>err ) \
            && fail "run_test did not fail for an unregistered test case"
        assert_file_contents err \
        "unittest_test: E: Attempting to run unregistered test case not_there"
    }
}


shtk_unittest_add_fixture skip
skip_fixture() {
    shtk_unittest_add_test one_argument
    one_argument_test() {
        (
            shtk_unittest_skip "This is a message" >out 2>err
            echo "Not reached"
        ) || fail "skip exited with an error"
        rm result.skipped
        assert_file_contents out ""
        assert_file_contents err <<EOF
unittest_test: W: This is a message
EOF
    }


    shtk_unittest_add_test argument_concatenation
    argument_concatenation_test() {
        (
            shtk_unittest_skip "This is" "another message" >out 2>err
            echo "Not reached"
        ) || fail "skip exited with an error"
        rm result.skipped
        assert_file_contents out ""
        assert_file_contents err <<EOF
unittest_test: W: This is another message
EOF
    }


    shtk_unittest_add_test expect_failure
    expect_failure_test() {
        (
            shtk_unittest_set_expect_failure
            shtk_unittest_skip "Some text"
            echo "not reached"
        ) >out 2>err
        if [ "${?}" -eq 0 ]; then
            rm -f result.expect-fail
            fail "skip did not exit with an error"
        else
            rm -f result.expect-fail
        fi
        assert_file_contents out ""
        assert_file_contents err <<EOF
unittest_test: E: Attempted to skip a test while expecting a failure
EOF
    }
}
