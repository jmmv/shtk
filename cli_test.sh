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

shtk_import cli
shtk_import unittest


# Saves the original value of argv[0] for testing purposes.
_Original_Arg0="${0}"


shtk_unittest_add_test dirname
dirname_test() {
    expect_equal "$(dirname "${_Original_Arg0}")" "$(shtk_cli_dirname)"
}


shtk_unittest_add_test progname
progname_test() {
    expect_equal "$(basename "${_Original_Arg0}")" "$(shtk_cli_progname)"
}


shtk_unittest_add_test error
error_test() {
    subtest() {
        shtk_cli_error "This is" "a message"
        echo "not seen"
    }
    expect_command -s exit:1 \
        -e inline:"cli_test: E: This is a message\n" subtest
}


shtk_unittest_add_test info
info_test() {
    subtest() {
        shtk_cli_info "This is" "a message"
        echo "continuing"
    }
    expect_command -s exit:0 \
        -o inline:"continuing\n" \
        -e inline:"cli_test: I: This is a message\n" subtest
}


shtk_unittest_add_test usage_error
usage_error_test() {
    subtest() {
        shtk_cli_usage_error "This is" "a message"
        echo "not seen"
    }
    cat >experr <<EOF
cli_test: E: This is a message
Type 'man cli_test' for help
EOF
    expect_command -s exit:1 -e file:experr subtest
}


shtk_unittest_add_test warning
warning_test() {
    subtest() {
        shtk_cli_warning "This is" "a message"
        echo "continuing"
    }
    expect_command -s exit:0 \
        -o inline:"continuing\n" \
        -e inline:"cli_test: W: This is a message\n" subtest
}
