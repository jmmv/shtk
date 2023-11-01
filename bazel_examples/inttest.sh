# Copyright 2023 Julio Merino
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

shtk_import cli
shtk_import unittest


one_time_setup() {
    # REAL_HOME provides access to the Bazel and Bazelisk caches from within this
    # test program.  While not strictly necessary, this makes these tests much
    # faster than they would otherwise and minimizes network traffic.
    [ "${REAL_HOME-unset}" != unset ] \
        || shtk_cli_error "REAL_HOME must point to the user's home directory"

    # WORKSPACE points to the root of the bazel_examples directory so that we can
    # run Bazel on it.
    [ "${WORKSPACE-unset}" != unset ] \
        || shtk_cli_error "WORKSPACE must point to the bazel_examples directory"

    # Create a fake Bazel binary that is aware of our configuration variables
    # above.  We do this so that we can invoke this wrapper via assert_command.
    local real_bazel="$(which bazel)"
    cat >run_bazel <<EOF
#! /bin/sh
cd "${WORKSPACE}"
export HOME="${REAL_HOME}"
exec "${real_bazel}" "\${@}"
EOF
    chmod +x run_bazel
}


shtk_unittest_add_test binary
binary_test() {
    assert_command -o ignore -e ignore ../run_bazel build //binary:simple
    assert_command -e match:"Hello, world" "${WORKSPACE}/bazel-bin/binary/simple"
}


shtk_unittest_add_test test
test_test() {
    # Sanity-check that the binary tool we want to test works.
    assert_command -o ignore -e ignore ../run_bazel build //test:adder
    assert_command \
        -o inline:"The sum of 2 and 3 is 5\n" \
        "${WORKSPACE}/bazel-bin/test/adder" 2 3

    assert_command \
        -o match:"addition_works... PASSED" \
        -o match:"bad_first_operand... PASSED" \
        -o match:"bad_second_operand... PASSED" \
        -e ignore \
        ../run_bazel test --nocache_test_results --test_output=streamed \
        //test:adder_test
}
