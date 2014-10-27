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


shtk_unittest_add_test build__defaults
build__defaults_test() {
    cat >script.sh <<EOF
shtk_import cli

main() {
    shtk_cli_info "It works"
}
EOF

    expect_command shtk build script.sh

    cat >experr <<EOF
script: I: It works
EOF
    expect_command -e file:experr ./script
}


shtk_unittest_add_test build__mflag__explicit
build__mflag__explicit_test() {
    cat >script.sh <<EOF
shtk_import cli

my_main() {
    shtk_cli_info "Print this"
}

main() {
    shtk_cli_info "Don't print this"
}
EOF

    expect_command shtk build -m my_main script.sh

    cat >experr <<EOF
script: I: Print this
EOF
    expect_command -e file:experr ./script
}


shtk_unittest_add_test build__mflag__empty
build__mflag__empty_test() {
    cat >script.sh <<EOF
shtk_import cli

shtk_cli_info "Outside of main"

main() {
    shtk_cli_info "Don't print this"
}
EOF

    expect_command shtk build -m '' script.sh

    cat >experr <<EOF
script: I: Outside of main
EOF
    expect_command -e file:experr ./script
}


shtk_unittest_add_test build__oflag__explicit
build__oflag__explicit_test() {
    cat >script.sh <<EOF
shtk_import cli

main() {
    shtk_cli_info "A string"
}
EOF
    expect_command shtk build -o first script.sh
    expect_command -e inline:'first: I: A string\n' ./first
}


shtk_unittest_add_test build__oflag__stdin
build__oflag__stdin_test() {
    cat >script.sh <<EOF
shtk_import cli

main() {
    shtk_cli_info "A string"
}
EOF
    cat script.sh | expect_command shtk build -o second -
    expect_command -e inline:'second: I: A string\n' ./second
}


shtk_unittest_add_test build__oflag__necessary
build__oflag__necessary_test() {
    touch script

    cat >experr <<EOF
shtk: E: Input file should end in .sh or you must specify -o
Type 'man shtk' for help
EOF
    expect_command -s exit:1 -e file:experr shtk build script
    echo "foo" | expect_command -s exit:1 -e file:experr shtk build -
}


shtk_unittest_add_test build__sflag
build__sflag_test() {
    cat >script.sh <<EOF
We won't run this anyway.
EOF
    expect_command shtk build -s '/custom/interpreter' script.sh
    expect_command -o inline:'#! /custom/interpreter\n' head -n1 script
}


shtk_unittest_add_test build__no_args
build__no_args_test() {
    cat >experr <<EOF
shtk: E: build takes one argument only
Type 'man shtk' for help
EOF
    expect_command -s exit:1 -e file:experr shtk build
}


shtk_unittest_add_test build__too_many_args
build__too_many_args_test() {
    cat >experr <<EOF
shtk: E: build takes one argument only
Type 'man shtk' for help
EOF
    expect_command -s exit:1 -e file:experr shtk build foo bar
}


shtk_unittest_add_test version__ok
version__ok_test() {
    expect_command -s exit:0 -o match:"shtk [0-9]+\.[0-9]+.*" shtk version
}


shtk_unittest_add_test version__too_many_args
version__too_many_args_test() {
    cat >experr <<EOF
shtk: E: version does not take any arguments
Type 'man shtk' for help
EOF
    expect_command -s exit:1 -e file:experr shtk version foo
}


shtk_unittest_add_test no_command
no_command_test() {
    cat >experr <<EOF
shtk: E: No command specified
Type 'man shtk' for help
EOF
    expect_command -s exit:1 -e file:experr shtk
}


shtk_unittest_add_test unknown_command
unknown_command_test() {
    cat >experr <<EOF
shtk: E: Unknown command foo
Type 'man shtk' for help
EOF
    expect_command -s exit:1 -e file:experr shtk foo
}
