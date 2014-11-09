# Copyright 2013 Google Inc.
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

shtk_import cleanup
shtk_import unittest


# Installs a cleanup handler and validates execution on exit.
#
# \param exitcode Exit code to validate.
do_register_exit_test() {
    local exitcode="${1}"; shift

    local failed=0
    (
        handler() {
            echo 'in the handler'
            return 123
        }
        shtk_cleanup_register handler
        echo 'before exiting'
        if [ ${exitcode} -ne 0 ]; then
            exit ${exitcode}
            echo 'after exiting'
        fi
    ) >out 2>err || failed="${?}"
    [ ${failed} = ${exitcode} ] \
        || fail "Cleanup handler didn't respect exit code"

    expect_command -o inline:"before exiting\nin the handler\n" cat out
    expect_command -o empty cat err
}


shtk_unittest_add_test register__exit_success
register__exit_success_test() {
    do_register_exit_test 0
}


shtk_unittest_add_test register__exit_failure
register__exit_failure_test() {
    do_register_exit_test 56
}


# Installs a cleanup handler and validates execution on signal delivery.
#
# \param uppercase_name Name of the signal to deliver in uppercase; e.g. HUP.
# \param lowercase_name Name of the signal to deliver in lowercase; e.g. hup.
do_register_signal_test() {
    local uppercase_name="${1}"; shift
    local lowercase_name="${1}"; shift

    # We must create a standalone script because we need the ability to deliver
    # a signal to self and accessing ${$} from subshells does not work as
    # intended.
    cat >script.sh <<EOF
shtk_import cleanup

handler() {
    echo 'in the handler'
}

main() {
    shtk_cleanup_register handler
    echo 'before signal'
    eval kill "-${uppercase_name}" \${$}
    echo 'after signal'
}
EOF
    expect_command shtk build script.sh

    expect_command -s "signal:${lowercase_name}" \
        -o inline:"before signal\nin the handler\n" -e empty ./script
}


shtk_unittest_add_test register__sighup
register__sighup_test() {
    do_register_signal_test HUP hup
}


shtk_unittest_add_test register__sigint
register__sigint_test() {
    do_register_signal_test INT int
}


shtk_unittest_add_test register__sigterm
register__sigterm_test() {
    do_register_signal_test TERM term
}


shtk_unittest_add_test register__many
register__many_test() {
    local failed=0
    (
        handler1() { echo 'first'; }
        handler2() { echo 'second'; }
        handler3() { echo 'third'; }
        shtk_cleanup_register handler1 handler2 handler3
        echo 'before exiting'
        exit 72
        echo 'after exiting'
    ) >out 2>err || failed="${?}"
    [ ${failed} = 72 ] || fail "Cleanup handler didn't respect exit code"

    expect_command -o inline:"before exiting\nfirst\nsecond\nthird\n" cat out
    expect_command -o empty cat err
}
