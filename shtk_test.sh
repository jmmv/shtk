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


shtk_unittest_add_test build__unknown_option
build__unknown_option_test() {
    cat >experr <<EOF
shtk: E: Unknown option -Z in build
Type 'man shtk' for help
EOF
    expect_command -s exit:1 -e file:experr shtk build -Z
}


shtk_unittest_add_test build__missing_argument
build__missing_argument_test() {
    cat >experr <<EOF
shtk: E: Missing argument to option -m in build
Type 'man shtk' for help
EOF
    expect_command -s exit:1 -e file:experr shtk build -m
}


shtk_unittest_add_test run__defaults
run__defaults_test() {
    cat >script.sh <<EOF
shtk_import cli

main() {
    shtk_cli_info "It works"
}
EOF

    expect_command -e inline:'script: I: It works\n' shtk run script.sh
    expect_command test ! -e script
}


shtk_unittest_add_test run__mflag
run__mflag_test() {
    cat >script.sh <<EOF
my_main() {
    echo "Print this"
}

main() {
    echo "Don't print this"
}
EOF

    expect_command -o inline:'Print this\n' shtk run -m my_main script.sh
}


shtk_unittest_add_test run__sflag
run__sflag_test() {
    cat >interpreter <<EOF
#! /bin/sh
echo "Using custom interpreter"
exec /bin/sh "\${@}"
EOF
    chmod +x interpreter

    cat >script.sh <<EOF
main() {
    echo "Running script"
}
EOF

    cat >expout <<EOF
Using custom interpreter
Running script
EOF
    expect_command -o file:expout shtk run -s "$(pwd)/interpreter" script.sh
}


shtk_unittest_add_test run__arguments
run__arguments_test() {
    cat >script.sh <<EOF
main() {
    for arg in "\${@}"; do
        echo "<\${arg}>"
    done
}
EOF

    cat >expout <<EOF
<one>
<two words>
<*>
EOF
    expect_command -o file:expout shtk run script.sh one 'two words' '*'
}


shtk_unittest_add_test run__stdin
run__stdin_test() {
    cat >script.sh <<EOF
main() {
    read line
    echo "Read: \${line}"
}
EOF

    echo 'from stdin' \
        | expect_command -o inline:'Read: from stdin\n' shtk run script.sh
}


shtk_unittest_add_test run__exit_code
run__exit_code_test() {
    cat >script.sh <<EOF
main() {
    return 42
}
EOF

    expect_command -s exit:42 shtk run script.sh
}


shtk_unittest_add_test run__cleanup
run__cleanup_test() {
    cat >script.sh <<EOF
main() {
    return 1
}
EOF

    expect_command -s exit:1 shtk run script.sh
    expect_command sh -c 'set -- shtk.*; test "${1}" = "shtk.*"'
}


shtk_unittest_add_test run__no_args
run__no_args_test() {
    cat >experr <<EOF
shtk: E: run requires an input file
Type 'man shtk' for help
EOF
    expect_command -s exit:1 -e file:experr shtk run
}


shtk_unittest_add_test run__stdin_input
run__stdin_input_test() {
    cat >experr <<EOF
shtk: E: run does not accept standard input
Type 'man shtk' for help
EOF
    expect_command -s exit:1 -e file:experr shtk run -
}


shtk_unittest_add_test run__missing_input
run__missing_input_test() {
    expect_command -s exit:1 -e inline:'shtk: E: Cannot open missing.sh\n' \
        shtk run missing.sh
}


shtk_unittest_add_test run__unknown_option
run__unknown_option_test() {
    cat >experr <<EOF
shtk: E: Unknown option -Z in run
Type 'man shtk' for help
EOF
    expect_command -s exit:1 -e file:experr shtk run -Z
}


shtk_unittest_add_test run__missing_argument
run__missing_argument_test() {
    cat >experr <<EOF
shtk: E: Missing argument to option -m in run
Type 'man shtk' for help
EOF
    expect_command -s exit:1 -e file:experr shtk run -m
}


shtk_unittest_add_test test__defaults
test__defaults_test() {
    cat >script.sh <<EOF
shtk_import unittest

shtk_unittest_add_test ok
ok_test() {
    :
}
EOF

    cat >experr <<EOF
script: I: Testing ok...
script: I: Testing ok... PASSED
script: I: Ran 1 tests; ALL PASSED
EOF
    expect_command -e file:experr shtk test script.sh
}


shtk_unittest_add_test test__multiple
test__multiple_test() {
    cat >first.sh <<EOF
shtk_import unittest
shtk_cli_set_log_level error

shtk_unittest_add_test first
first_test() {
    echo first
}
EOF
    cat >second.sh <<EOF
shtk_import unittest
shtk_cli_set_log_level error

shtk_unittest_add_test second
second_test() {
    echo second
}
EOF

    expect_command -o inline:'first\nsecond\n' shtk test first.sh second.sh
}


shtk_unittest_add_test test__continues_after_failure
test__continues_after_failure_test() {
    cat >first.sh <<EOF
shtk_unittest_main() {
    echo first
    return 1
}
EOF
    cat >second.sh <<EOF
shtk_unittest_main() {
    echo second
}
EOF

    expect_command -s exit:1 -o inline:'first\nsecond\n' \
        shtk test first.sh second.sh
}


shtk_unittest_add_test test__mflag
test__mflag_test() {
    cat >script.sh <<EOF
custom_main() {
    echo custom
}
EOF

    expect_command -o inline:'custom\n' shtk test -m custom_main script.sh
}


shtk_unittest_add_test test__sflag
test__sflag_test() {
    cat >interpreter <<EOF
#! /bin/sh
echo "Using custom interpreter"
exec /bin/sh "\${@}"
EOF
    chmod +x interpreter

    cat >script.sh <<EOF
custom_main() {
    echo "Running test"
}
EOF

    cat >expout <<EOF
Using custom interpreter
Running test
EOF
    expect_command -o file:expout shtk test -m custom_main \
        -s "$(pwd)/interpreter" script.sh
}


shtk_unittest_add_test test__preflight
test__preflight_test() {
    cat >script.sh <<EOF
echo ran >ran

custom_main() {
    :
}
EOF
    mkdir directory

    expect_command -s exit:1 -e inline:'shtk: E: Cannot open missing.sh\n' \
        shtk test -m custom_main script.sh missing.sh
    expect_command test ! -e ran
    expect_command -s exit:1 -e inline:'shtk: E: Cannot open directory\n' \
        shtk test -m custom_main script.sh directory
    expect_command test ! -e ran
}


shtk_unittest_add_test test__double_dash
test__double_dash_test() {
    cat >-script.sh <<EOF
custom_main() {
    echo passed
}
EOF

    expect_command -o inline:'passed\n' \
        shtk test -m custom_main -- -script.sh
}


shtk_unittest_add_test test__cleanup
test__cleanup_test() {
    cat >first.sh <<EOF
custom_main() {
    return 1
}
EOF
    cat >second.sh <<EOF
custom_main() {
    :
}
EOF

    expect_command -s exit:1 shtk test -m custom_main first.sh second.sh
    expect_command sh -c 'set -- shtk.*; test "${1}" = "shtk.*"'
}


shtk_unittest_add_test test__no_args
test__no_args_test() {
    cat >experr <<EOF
shtk: E: test requires at least one input file
Type 'man shtk' for help
EOF
    expect_command -s exit:1 -e file:experr shtk test
}


shtk_unittest_add_test test__stdin_input
test__stdin_input_test() {
    cat >experr <<EOF
shtk: E: test does not accept standard input
Type 'man shtk' for help
EOF
    expect_command -s exit:1 -e file:experr shtk test -
}


shtk_unittest_add_test test__unknown_option
test__unknown_option_test() {
    cat >experr <<EOF
shtk: E: Unknown option -Z in test
Type 'man shtk' for help
EOF
    expect_command -s exit:1 -e file:experr shtk test -Z
}


shtk_unittest_add_test test__missing_argument
test__missing_argument_test() {
    cat >experr <<EOF
shtk: E: Missing argument to option -m in test
Type 'man shtk' for help
EOF
    expect_command -s exit:1 -e file:experr shtk test -m
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
