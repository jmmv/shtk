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
_Prefix="operators_test: "


shtk_unittest_add_fixture equal
equal_fixture() {
    shtk_unittest_add_test same_values_are_true
    same_values_are_true_test() {
        expect_command shtk_unittest_assert_equal foo foo
        expect_command shtk_unittest_assert_equal "a b" "a b"
        expect_command shtk_unittest_assert_equal 5 5
    }


    shtk_unittest_add_test different_values_are_false
    different_values_are_false_test() {
        expect_command -s exit:1 \
            -e inline:"${_Prefix}E: Expected value foo but got bar\n" \
            shtk_unittest_assert_equal foo bar

        expect_command -s exit:1 \
            -e inline:"${_Prefix}E: Expected value a b but got   a   b \n" \
            shtk_unittest_assert_equal "a b" "  a   b "

        expect_command -s exit:1 \
            -e inline:"${_Prefix}E: Expected value 5 but got 8\n" \
            shtk_unittest_assert_equal 5 8
    }


    shtk_unittest_add_test assert_integration
    assert_integration_test() {
        shtk_unittest_add_test subtest
        subtest_test() {
            assert_equal 9 9
            assert_equal 5 9
            echo "not reached"
        }

        cat >experr <<EOF
${_Prefix}I: Testing subtest...
${_Prefix}E: Expected value 5 but got 9
${_Prefix}W: Testing subtest... FAILED
EOF
        expect_command -s exit:1 -e file:experr \
            _shtk_unittest_run_standalone_test subtest
    }


    shtk_unittest_add_test expect_integration
    expect_integration_test() {
        shtk_unittest_add_test subtest
        subtest_test() {
            expect_equal 8 8
            expect_equal foo bar
            expect_equal bar bar
            expect_equal bar baz
        }

        cat >experr <<EOF
${_Prefix}I: Testing subtest...
${_Prefix}W: Delayed failure: Expected value foo but got bar
${_Prefix}W: Delayed failure: Expected value bar but got baz
${_Prefix}W: Testing subtest... FAILED (2 delayed failures)
EOF
        expect_command -s exit:1 -e file:experr \
            _shtk_unittest_run_standalone_test subtest
    }
}


shtk_unittest_add_fixture not_equal
not_equal_fixture() {
    shtk_unittest_add_test same_values_are_false
    same_values_are_false_test() {
        expect_command -s exit:1 \
            -e inline:"${_Prefix}E: Expected value different than foo\n" \
            shtk_unittest_assert_not_equal foo foo
        expect_command -s exit:1 \
            -e inline:"${_Prefix}E: Expected value different than a b\n" \
            shtk_unittest_assert_not_equal "a b" "a b"
        expect_command -s exit:1 \
            -e inline:"${_Prefix}E: Expected value different than 5\n" \
            shtk_unittest_assert_not_equal 5 5
    }


    shtk_unittest_add_test different_values_are_true
    different_values_are_true_test() {
        expect_command shtk_unittest_assert_not_equal foo bar
        expect_command shtk_unittest_assert_not_equal "a b" "  a   b "
        expect_command shtk_unittest_assert_not_equal 5 8
    }


    shtk_unittest_add_test assert_integration
    assert_integration_test() {
        shtk_unittest_add_test subtest
        subtest_test() {
            assert_not_equal 5 9
            assert_not_equal 9 9
            echo "not reached"
        }

        cat >experr <<EOF
${_Prefix}I: Testing subtest...
${_Prefix}E: Expected value different than 9
${_Prefix}W: Testing subtest... FAILED
EOF
        expect_command -s exit:1 -e file:experr \
            _shtk_unittest_run_standalone_test subtest
    }


    shtk_unittest_add_test expect_integration
    expect_integration_test() {
        shtk_unittest_add_test subtest
        subtest_test() {
            expect_not_equal 15 20
            expect_not_equal 8 8
            expect_not_equal foo foo
            expect_not_equal bar bar
            expect_not_equal bar baz
        }

        cat >experr <<EOF
${_Prefix}I: Testing subtest...
${_Prefix}W: Delayed failure: Expected value different than 8
${_Prefix}W: Delayed failure: Expected value different than foo
${_Prefix}W: Delayed failure: Expected value different than bar
${_Prefix}W: Testing subtest... FAILED (3 delayed failures)
EOF
        expect_command -s exit:1 -e file:experr \
            _shtk_unittest_run_standalone_test subtest
    }
}
