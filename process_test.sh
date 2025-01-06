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

shtk_import process
shtk_import unittest


shtk_unittest_add_test run__ok
run__ok_test() {
    cat >helper.sh <<EOF
#! /bin/sh
echo "This exits cleanly:" "\${@}"
exit 0
EOF
    chmod +x helper.sh

    cat >expout <<EOF
This exits cleanly: one two three
EOF
    cat >experr <<EOF
process_test: I: Running './helper.sh one two three' in $(pwd)
process_test: I: Command finished successfully
EOF
    expect_command -o file:expout -e file:experr \
        shtk_process_run ./helper.sh one two three
}


shtk_unittest_add_test run__fail
run__fail_test() {
    cat >helper.sh <<EOF
#! /bin/sh
echo "This exits with an error:" "\${@}"
exit 42
EOF
    chmod +x helper.sh

    cat >expout <<EOF
This exits with an error: one two three
EOF
    cat >experr <<EOF
process_test: I: Running './helper.sh one two three' in $(pwd)
process_test: W: Command failed with code 42
EOF
    expect_command -s exit:42 -o file:expout -e file:experr \
        shtk_process_run ./helper.sh one two three
}


shtk_unittest_add_test run__workdir__ok
run__workdir__ok_test() {
    mkdir tmp
    cat >tmp/helper.sh <<EOF
#! /bin/sh
echo "This exits cleanly:" "\${@}"
exit 0
EOF
    chmod +x tmp/helper.sh

    cat >expout <<EOF
This exits cleanly: one two three
EOF
    cat >experr <<EOF
process_test: I: Running './helper.sh one two three' in $(pwd)/tmp
process_test: I: Command finished successfully
EOF
    expect_command -o file:expout -e file:experr -w tmp \
        shtk_process_run ./helper.sh one two three
}


shtk_unittest_add_test run__timeout__ok
run__timeout__ok_test() {
    cat >helper.sh <<EOF
#! /bin/sh
echo "This exits quickly:" "\${@}"
exit 0
EOF
    chmod +x helper.sh

    cat >expout <<EOF
This exits quickly: one two three
EOF
    cat >experr <<EOF
process_test: I: Running './helper.sh one two three' in $(pwd)
process_test: I: Command finished successfully
EOF
    expect_command -o file:expout -e file:experr \
        shtk_process_run -t 10 ./helper.sh one two three
}


shtk_unittest_add_test run__timeout__workdir__ok
run__timeout__workdir__ok_test() {
    mkdir tmp
    cat >tmp/helper.sh <<EOF
#! /bin/sh
echo "This exits quickly:" "\${@}"
exit 0
EOF
    chmod +x tmp/helper.sh

    cat >expout <<EOF
This exits quickly: one two three
EOF
    cat >experr <<EOF
process_test: I: Running './helper.sh one two three' in $(pwd)/tmp
process_test: I: Command finished successfully
EOF
    expect_command -o file:expout -e file:experr -w tmp \
        shtk_process_run -t 10 ./helper.sh one two three
}


shtk_unittest_add_test run__timeout__fail
run__timeout__fail_test() {
    cat >helper.sh <<EOF
#! /bin/sh
echo "This exits with an error:" "\${@}"
exit 42
EOF
    chmod +x helper.sh

    cat >expout <<EOF
This exits with an error: one two three
EOF
    cat >experr <<EOF
process_test: I: Running './helper.sh one two three' in $(pwd)
process_test: W: Command failed with code 42
EOF
    expect_command -s exit:42 -o file:expout -e file:experr \
        shtk_process_run -t 10 ./helper.sh one two three
}


shtk_unittest_add_test run__timeout__fail_cookie
run__timeout__fail_cookie_test() {
    echo "Won't be run" >helper.sh

    cat >experr <<EOF
process_test: I: Running './helper.sh one two three' in $(pwd)
process_test: E: Failed to create temporary file using pattern $(pwd)/non-existent/shtk.XXXXXX
EOF
    export TMPDIR="$(pwd)/non-existent"
    expect_command -s exit:1 -e file:experr \
        shtk_process_run -t 10 ./helper.sh one two three
}


shtk_unittest_add_test run__timeout__expired
run__timeout__expired_test() {
    cat >helper.sh <<EOF
#! /bin/sh
echo "This does not exit on time:" "\${@}"
exec >/dev/null  # Force flush.
sleep 100
exit 0
EOF
    chmod +x helper.sh

    cat >expout <<EOF
This does not exit on time: one two three
EOF
    expect_command -s not-exit:0 -o file:expout -e match:"Timer expired" \
        shtk_process_run -t 1 ./helper.sh one two three
}


shtk_unittest_add_test run__missing_argument
run__missing_argument_test() {
    cat >experr <<EOF
process_test: E: Missing argument to option -t in shtk_process_run
EOF
    expect_command -s exit:1 -o empty -e file:experr \
        shtk_process_run -t
}


shtk_unittest_add_test run__unknown_option
run__unknown_option_test() {
    cat >experr <<EOF
process_test: E: Unknown option -Z in shtk_process_run
EOF
    expect_command -s exit:1 -o empty -e file:experr \
        shtk_process_run -Z ls
}
