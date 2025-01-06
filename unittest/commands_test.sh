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


# Prefix for cli messages printed by this module.
_Prefix="commands_test: "


shtk_unittest_add_fixture check_command
check_command_fixture() {
    shtk_unittest_add_test defaults__all_ok
    defaults__all_ok_test() {
        ( shtk_unittest_assert_command true \
            >out 2>err ) || fail "Failed to validate successful command"
        expect_file inline:"Running checked command: true\n" out
        expect_file empty err
    }


    shtk_unittest_add_test defaults__fail_exit_code
    defaults__fail_exit_code_test() {
        cat >command.sh <<EOF
echo this is
echo the stdout
echo this is 1>&2
echo the stderr 1>&2
false
EOF
        ( shtk_unittest_assert_command sh ./command.sh \
            >out 2>err ) && fail "Failed to validate failing command"
        expect_file stdin out <<EOF
Running checked command: sh ./command.sh
Expected exit code 0 != actual exit code 1
stdout: this is
stdout: the stdout
stderr: this is
stderr: the stderr
EOF
        expect_file stdin err <<EOF
${_Prefix}E: Check of 'sh ./command.sh' failed; see stdout for details
EOF
    }


    shtk_unittest_add_test defaults__fail_stdout_spec
    defaults__fail_stdout_spec_test() {
        ( shtk_unittest_assert_command echo "stuff" \
            >out 2>err ) && fail "Failed to validate failing command"
        expect_file stdin out <<EOF
Running checked command: echo stuff
Expected standard output to be empty; found:
stuff
EOF
        expect_file stdin err <<EOF
${_Prefix}E: Check of 'echo stuff' failed; see stdout for details
EOF
    }


    shtk_unittest_add_test defaults__fail_stderr_spec
    defaults__fail_stderr_spec_test() {
        cat >command.sh <<EOF
echo "stuff" 1>&2
EOF
        ( shtk_unittest_assert_command sh ./command.sh \
            >out 2>err ) && fail "Failed to validate failing command"
        expect_file stdin out <<EOF
Running checked command: sh ./command.sh
Expected standard error to be empty; found:
stuff
EOF
        expect_file stdin err <<EOF
${_Prefix}E: Check of 'sh ./command.sh' failed; see stdout for details
EOF
    }


    shtk_unittest_add_test defaults__fail_all_specs
    defaults__fail_all_specs_test() {
        cat >command.sh <<EOF
echo "this is the output"
echo "this is the error" 1>&2
exit 23
EOF
        ( shtk_unittest_assert_command sh ./command.sh \
            >out 2>err ) && fail "Failed to validate failing command"
        expect_file stdin out <<EOF
Running checked command: sh ./command.sh
Expected exit code 0 != actual exit code 23
stdout: this is the output
stderr: this is the error
EOF
        expect_file stdin err <<EOF
${_Prefix}E: Check of 'sh ./command.sh' failed; see stdout for details
EOF
    }


    shtk_unittest_add_test defaults__fail_output_specs
    defaults__fail_output_specs_test() {
        cat >command.sh <<EOF
echo "this is the output"
echo "this is the error" 1>&2
true
EOF
        ( shtk_unittest_assert_command sh ./command.sh \
            >out 2>err ) && fail "Failed to validate failing command"
        expect_file stdin out <<EOF
Running checked command: sh ./command.sh
Expected standard output to be empty; found:
this is the output
Expected standard error to be empty; found:
this is the error
EOF
        expect_file stdin err <<EOF
${_Prefix}E: Check of 'sh ./command.sh' failed; see stdout for details
EOF
    }


    shtk_unittest_add_test overrides__pass_all_specs
    overrides__pass_all_specs_test() {
        cat >command.sh <<EOF
echo "this is the output"
echo "this is the error" 1>&2
exit 23
EOF
        ( shtk_unittest_assert_command \
            -e match:"error" -o match:"the output" -s exit:23 sh ./command.sh \
            >out 2>err ) || fail "Failed to validate passing command"
        expect_file stdin out <<EOF
Running checked command: sh ./command.sh
EOF
        expect_file empty err
    }


    shtk_unittest_add_test overrides__pass_repeated_specs
    overrides__pass_repeated_specs_test() {
        cat >command.sh <<EOF
echo "this is the output"
echo "this is the error" 1>&2
exit 23
EOF
        ( shtk_unittest_assert_command \
            -e match:"error" -e match:"this is" \
            -o match:"the output" -o not-match:"foo bar" \
            -s exit:23 -s not-exit:25 \
            sh ./command.sh \
            >out 2>err ) || fail "Failed to validate passing command"
        expect_file stdin out <<EOF
Running checked command: sh ./command.sh
EOF
        expect_file empty err
    }


    shtk_unittest_add_test overrides__fail_all_specs
    overrides__fail_all_specs_test() {
        cat >command.sh <<EOF
echo "this is the output"
echo "this is the error" 1>&2
exit 23
EOF
        ( shtk_unittest_assert_command \
            -e empty -o match:"not here" -s 20 sh ./command.sh \
            >out 2>err ) && fail "Failed to validate failing command"
        expect_file stdin out <<EOF
Running checked command: sh ./command.sh
Expected exit code 20 != actual exit code 23
stdout: this is the output
stderr: this is the error
EOF
        expect_file stdin err <<EOF
${_Prefix}E: Check of 'sh ./command.sh' failed; see stdout for details
EOF
    }


    shtk_unittest_add_test overrides__fail_repeated_exit_specs
    overrides__fail_repeated_exit_specs_test() {
        cat >command.sh <<EOF
echo "this is the output"
echo "this is the error" 1>&2
exit 23
EOF
        ( shtk_unittest_assert_command \
            -e empty -o match:"not here" -s 20 -s 30 sh ./command.sh \
            >out 2>err ) && fail "Failed to validate failing command"
        expect_file stdin out <<EOF
Running checked command: sh ./command.sh
Expected exit code 20 != actual exit code 23
Expected exit code 30 != actual exit code 23
stdout: this is the output
stderr: this is the error
EOF
        expect_file stdin err <<EOF
${_Prefix}E: Check of 'sh ./command.sh' failed; see stdout for details
EOF
    }


    shtk_unittest_add_test overrides__fail_output_specs
    overrides__fail_output_specs_test() {
        cat >command.sh <<EOF
echo "this is the output"
echo "this is the error" 1>&2
exit 20
EOF
        ( shtk_unittest_assert_command \
            -e empty -o match:"not here" -s 20 sh ./command.sh \
            >out 2>err ) && fail "Failed to validate failing command"
        expect_file stdin out <<EOF
Running checked command: sh ./command.sh
Expected standard error to be empty; found:
this is the error
Expected regexp 'not here' not found in standard output:
this is the output
EOF
        expect_file stdin err <<EOF
${_Prefix}E: Check of 'sh ./command.sh' failed; see stdout for details
EOF
    }


    shtk_unittest_add_test overrides__fail_repeated_output_specs
    overrides__fail_repeated_output_specs_test() {
        cat >command.sh <<EOF
echo "this is the output"
echo "this is the error" 1>&2
exit 20
EOF
        ( shtk_unittest_assert_command \
            -e empty -o match:"not here" -e empty -o match:"not either" \
            -s 20 sh ./command.sh \
            >out 2>err ) && fail "Failed to validate failing command"
        expect_file stdin out <<EOF
Running checked command: sh ./command.sh
Expected standard error to be empty; found:
this is the error
Expected regexp 'not here' not found in standard output:
this is the output
Expected standard error to be empty; found:
this is the error
Expected regexp 'not either' not found in standard output:
this is the output
EOF
        expect_file stdin err <<EOF
${_Prefix}E: Check of 'sh ./command.sh' failed; see stdout for details
EOF
    }


    shtk_unittest_add_test command_can_be_shell_builtin
    command_can_be_shell_builtin_test() {
        builtin_command() {
            echo "command args: ${*}"
            exit 1
        }

        ( shtk_unittest_assert_command builtin_command a1 a2 \
            >out 2>err ) && fail "Failed to validate failing command"
        expect_file stdin out <<EOF
Running checked command: builtin_command a1 a2
Expected exit code 0 != actual exit code 1
stdout: command args: a1 a2
EOF
        expect_file stdin err <<EOF
${_Prefix}E: Check of 'builtin_command a1 a2' failed; see stdout for details
EOF
    }


    shtk_unittest_add_test change_workdir
    change_workdir_test() {
        mkdir tmp
        echo "expected contents" >tmp/data1
        echo "expected contents" >tmp/data2
        ( shtk_unittest_assert_command -w tmp -o file:tmp/data2 cat data1 \
            >out 2>err ) || fail "Failed to validate successful command"
        expect_file inline:"Running checked command: cat data1\n" out
        expect_file empty err
    }


    shtk_unittest_add_test unknown_flag
    unknown_flag_test() {
        ( shtk_unittest_assert_command -Z foo >out 2>err ) \
            && fail "Invalid option did not raise an error"
        expect_file empty out
        expect_file stdin err <<EOF
${_Prefix}E: Invalid option -Z to shtk_unittest_assert_command
EOF
    }


    shtk_unittest_add_test invalid_eflag
    invalid_eflag_test() {
        ( shtk_unittest_assert_command -o empty -e oops \
            echo executed >out 2>err ) \
            && fail "Invalid -e argument did not raise an error"
        expect_file stdin out <<EOF
Running checked command: echo executed
Expected standard output to be empty; found:
executed
EOF
        expect_file stdin err <<EOF
${_Prefix}E: Invalid file check specification in shtk_unittest_assert_command; got oops
EOF
    }


    shtk_unittest_add_test invalid_oflag
    invalid_oflag_test() {
        ( shtk_unittest_assert_command -o oops \
            echo executed >out 2>err ) \
            && fail "Invalid -o argument did not raise an error"
        expect_file stdin out <<EOF
Running checked command: echo executed
EOF
        expect_file stdin err <<EOF
${_Prefix}E: Invalid file check specification in shtk_unittest_assert_command; got oops
EOF
    }


    shtk_unittest_add_test invalid_sflag
    invalid_sflag_test() {
        ( shtk_unittest_assert_command -s no \
            echo executed >out 2>err ) \
            && fail "Invalid -s argument did not raise an error"
        expect_file stdin out <<EOF
Running checked command: echo executed
EOF
        expect_file stdin err <<EOF
${_Prefix}E: Invalid exit code check specification in shtk_unittest_assert_command; got no
EOF
    }
}


shtk_unittest_add_fixture check_exit_code
check_exit_code_fixture() {
    shtk_unittest_add_test raw_number__match_is_true
    raw_number__match_is_true_test() {
        ( _shtk_unittest_check_exit_code wrapper_name 15 15 \
            >out 2>err ) || fail "check_exit_code reported false for match"
        expect_file empty out
        expect_file empty err
    }


    shtk_unittest_add_test raw_number__non_match_is_false
    raw_number__non_match_is_false_test() {
        ( _shtk_unittest_check_exit_code wrapper_name 15 18 \
            >out 2>err ) && fail "check_exit_code reported true for non-match"
        expect_file stdin out <<EOF
Expected exit code 15 != actual exit code 18
EOF
        expect_file empty err
    }


    shtk_unittest_add_test exit__match_is_true
    exit__match_is_true_test() {
        ( _shtk_unittest_check_exit_code wrapper_name exit:15 15 \
            >out 2>err ) || fail "check_exit_code reported false for match"
        expect_file empty out
        expect_file empty err
    }


    shtk_unittest_add_test exit__non_match_is_false
    exit__non_match_is_false_test() {
        ( _shtk_unittest_check_exit_code wrapper_name exit:15 18 \
            >out 2>err ) && fail "check_exit_code reported true for non-match"
        expect_file stdin out <<EOF
Expected exit code 15 != actual exit code 18
EOF
        expect_file empty err
    }


    shtk_unittest_add_test ignore__is_true
    ignore__is_true_test() {
        ( _shtk_unittest_check_exit_code wrapper_name ignore 18 \
            >out 2>err ) || fail "check_exit_code reported false for ignore"
        expect_file empty out
        expect_file empty err
    }


    shtk_unittest_add_test not_exit__match_is_false
    not_exit__match_is_false_test() {
        ( _shtk_unittest_check_exit_code wrapper_name not-exit:15 15 \
            >out 2>err ) && fail "check_exit_code reported true for non-match"
        expect_file stdin out <<EOF
Expected exit code != 15
EOF
        expect_file empty err
    }


    shtk_unittest_add_test not_exit__non_match_is_true
    not_exit__non_match_is_true_test() {
        ( _shtk_unittest_check_exit_code wrapper_name not-exit:15 18 \
            >out 2>err ) || fail "check_exit_code reported false for match"
        expect_file empty out
        expect_file empty err
    }


    shtk_unittest_add_test not_signal__match_is_false
    not_signal__match_is_false_test() {
        cat >command.sh <<EOF
kill -term \${$}
EOF
        sh command.sh
        local code="${?}"
        ( _shtk_unittest_check_exit_code wrapper_name \
            not-signal:term "${code}" \
            >out 2>err ) && fail "check_exit_code reported true for non-match"
        expect_file inline:"Expected signal != term\n" out
        expect_file empty err
    }


    shtk_unittest_add_test not_signal__non_match_is_true
    not_signal__non_match_is_true_test() {
        cat >command.sh <<EOF
kill -hup \${$}
EOF
        sh command.sh
        local code="${?}"
        ( _shtk_unittest_check_exit_code wrapper_name \
            not-signal:term "${code}" \
            >out 2>err ) || fail "check_exit_code reported false for match"
        expect_file empty out
        expect_file empty err
    }


    shtk_unittest_add_test not_signal__exit_is_false
    not_signal__exit_is_false_test() {
        ( _shtk_unittest_check_exit_code wrapper_name \
            not-signal:term 15 \
            >out 2>err ) && fail "check_exit_code reported true for non-match"
        expect_file stdin out <<EOF
Expected signal different than term but exited with code 15
EOF
        expect_file empty err
    }


    shtk_unittest_add_test signal__match_is_true
    signal__match_is_true_test() {
        for signal in hup int kill term 1 2 9 15; do
            cat >command.sh <<EOF
kill -${signal} \${$}
EOF
            sh command.sh
            local code="${?}"
            ( _shtk_unittest_check_exit_code wrapper_name \
                signal:${signal} "${code}" \
                >out 2>err ) || fail "check_exit_code reported false for match"
            expect_file empty out
            expect_file empty err
        done
    }


    shtk_unittest_add_test signal__non_match_is_false
    signal__non_match_is_false_test() {
        cat >command.sh <<EOF
kill -hup \${$}
EOF
        sh command.sh
        local code="${?}"
        ( _shtk_unittest_check_exit_code wrapper_name \
            signal:term "${code}" \
            >out 2>err ) && fail "check_exit_code reported true for non-match"
        expect_file inline:"Expected signal term != actual signal 1\n" out
        expect_file empty err
    }


    shtk_unittest_add_test signal__exit_is_false
    signal__exit_is_false_test() {
        ( _shtk_unittest_check_exit_code wrapper_name \
            signal:term 15 \
            >out 2>err ) && fail "check_exit_code reported true for non-match"
        expect_file inline:"Expected signal term but exited with code 15\n" out
        expect_file empty err
    }


    shtk_unittest_add_test unknown_spec_is_error
    unknown_spec_is_error_test() {
        ( _shtk_unittest_check_exit_code wrapper_name unknown-spec 0 \
            >out 2>err ) && fail "check_exit_code reported true for" \
            "unknown spec"
        expect_file empty out
        expect_file stdin err <<EOF
${_Prefix}E: Invalid exit code check specification in wrapper_name; got unknown-spec
EOF
    }
}


shtk_unittest_add_fixture assert_and_expect
assert_and_expect_fixture() {
    setup() {
        cat >command.sh <<EOF
echo "some contents to stdout"
echo "some contents to stderr" 1>&2
exit 42
EOF
        command_sh="$(pwd)/command.sh"
    }


    do_pass_test() {
        local func="${1}"; shift

        shtk_unittest_add_test subtest
        subtest_test() {
            "${func}" -s exit:42 -o ignore -e ignore sh "${command_sh}"
            echo reached
        }

        ( _shtk_unittest_run_standalone_test subtest ) >out 2>err \
            || fail "${func} failed but should have passed"
        expect_file stdin out <<EOF
Running checked command: sh ${command_sh}
reached
EOF
        expect_file stdin err <<EOF
${_Prefix}I: Testing subtest...
${_Prefix}I: Testing subtest... PASSED
EOF
    }


    shtk_unittest_add_test assert__pass
    assert__pass_test() {
        do_pass_test assert_command
    }


    shtk_unittest_add_test expect__pass
    expect__pass_test() {
        do_pass_test expect_command
    }


    shtk_unittest_add_test assert__fail
    assert__fail_test() {
        shtk_unittest_add_test subtest
        subtest_test() {
            assert_command -s exit:41 sh "${command_sh}"
            echo not reached
        }

        ( _shtk_unittest_run_standalone_test subtest ) >out 2>err \
            && fail "assert_command passed but should have failed"
        expect_file stdin out <<EOF
Running checked command: sh ${command_sh}
Expected exit code 41 != actual exit code 42
stdout: some contents to stdout
stderr: some contents to stderr
EOF
        expect_file stdin err <<EOF
${_Prefix}I: Testing subtest...
${_Prefix}E: Check of 'sh ${command_sh}' failed; see stdout for details
${_Prefix}W: Testing subtest... FAILED
EOF
    }


    shtk_unittest_add_test expect__fail
    expect__fail_test() {
        shtk_unittest_add_test subtest
        subtest_test() {
            expect_command -s exit:41 sh "${command_sh}"
            echo reached
            expect_command -s exit:42 sh "${command_sh}"
            echo reached
        }

        ( _shtk_unittest_run_standalone_test subtest ) >out 2>err \
            && fail "expect_command passed but should have failed"
        expect_file stdin out <<EOF
Running checked command: sh ${command_sh}
Expected exit code 41 != actual exit code 42
stdout: some contents to stdout
stderr: some contents to stderr
reached
Running checked command: sh ${command_sh}
Expected standard output to be empty; found:
some contents to stdout
Expected standard error to be empty; found:
some contents to stderr
reached
EOF
        expect_file stdin err <<EOF
${_Prefix}I: Testing subtest...
${_Prefix}W: Delayed failure: Check of 'sh ${command_sh}' failed; see stdout for details
${_Prefix}W: Delayed failure: Check of 'sh ${command_sh}' failed; see stdout for details
${_Prefix}W: Testing subtest... FAILED (2 delayed failures)
EOF
    }
}


shtk_unittest_add_fixture signal_number
signal_number_fixture() {
    shtk_unittest_add_test raw_number
    raw_number_test() {
        ( _shtk_unittest_signal_number 12 ) >out 2>err \
            || fail "Failed to determine signal number"
        expect_file inline:"12\n" out
        expect_file empty err
    }


    shtk_unittest_add_test name
    name_test() {
        ( _shtk_unittest_signal_number segv ) >out 2>err \
            || fail "Failed to determine signal number"
        expect_file inline:"11\n" out
        expect_file empty err
    }


    shtk_unittest_add_test unknown
    unknown_test() {
        ( _shtk_unittest_signal_number foobar ) >out 2>err \
            && fail "Failed to determine signal number"
        expect_file empty out
        expect_file stdin err <<EOF
${_Prefix}E: Unknown signal name or number foobar
EOF
    }
}
