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
_Prefix="files_test: "


# Checks that the given file matches some golden contents.
#
# \param file Name of the file to be checked.
# \param ... If present, the textual contents to expect; if not present, the
#     golden data is read from stdin.
#
# \post Fails the calling test if the file contents do not match.
_assert_file_contents() {
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


shtk_unittest_add_fixture check_file
check_file_fixture() {
    shtk_unittest_add_test missing_file_is_false
    missing_file_is_false_test() {
        ( shtk_unittest_assert_file never_checked missing_file ) >out 2>err \
            && fail "assert_file reported true for missing file"
        _assert_file_contents out ""
        _assert_file_contents err \
            "${_Prefix}E: Cannot find missing_file in call to" \
            "shtk_unittest_assert_file"
    }


    shtk_unittest_add_test empty__empty_file_is_true
    empty__empty_file_is_true_test() {
        touch empty_file
        ( shtk_unittest_assert_file empty empty_file ) >out 2>err \
            || fail "assert_file reported false for empty file"
        _assert_file_contents out ""
        _assert_file_contents err ""
    }


    shtk_unittest_add_test empty__non_empty_file_is_false
    empty__non_empty_file_is_false_test() {
        echo "some contents" >non_empty_file
        ( shtk_unittest_assert_file empty non_empty_file ) \
            >out 2>err && fail "assert_file reported true for non-empty file"
        _assert_file_contents out <<EOF
Expected non_empty_file to be empty; found:
some contents
EOF
        _assert_file_contents err \
            "${_Prefix}E: Failed to validate contents of file non_empty_file"
    }


    shtk_unittest_add_test ignore__is_true
    ignore__is_true_test() {
        echo "this is not checked" >actual
        ( shtk_unittest_assert_file ignore actual ) \
            >out 2>err || fail "assert_file reported false for ignore"
        _assert_file_contents out ""
        _assert_file_contents err ""
    }


    shtk_unittest_add_test file__missing_golden_is_error
    file__missing_golden_is_error_test() {
        touch actual
        ( shtk_unittest_assert_file file:expected actual ) >out 2>err \
            && fail "assert_file reported true for missing file"
        _assert_file_contents out ""
        _assert_file_contents err \
            "${_Prefix}E: Cannot find golden file expected given" \
            "to shtk_unittest_assert_file"
    }


    shtk_unittest_add_test file__golden_and_actual_diverge
    file__golden_and_actual_diverge_test() {
        echo foo >expected
        echo bar >actual
        ( shtk_unittest_assert_file file:expected actual ) >out 2>err \
            && fail "assert_file reported true for diverging files"
        grep -v '^---' out | grep -v '^+++' | grep -v '^@' >out.diff
        _assert_file_contents out.diff <<EOF
actual did not match golden contents:
-foo
+bar
EOF
        _assert_file_contents err \
            "${_Prefix}E: Failed to validate contents of file actual"
    }


    shtk_unittest_add_test file__golden_and_actual_match
    file__golden_and_actual_match_test() {
        echo foo >"expected file"
        echo foo >"actual file"
        ( shtk_unittest_assert_file file:"expected file" "actual file" ) \
            >out 2>err \
            || fail "assert_file reported false for matching files"
        _assert_file_contents out ""
        _assert_file_contents err ""
    }


    shtk_unittest_add_test inline__golden_and_actual_diverge
    inline__golden_and_actual_diverge_test() {
        echo bar >actual
        ( shtk_unittest_assert_file inline:"foo\n" actual ) >out 2>err \
            && fail "assert_file reported true for diverging inline"
        grep -v '^---' out | grep -v '^+++' | grep -v '^@' >out.diff
        _assert_file_contents out.diff <<EOF
actual did not match golden contents:
-foo
+bar
EOF
        _assert_file_contents err \
            "${_Prefix}E: Failed to validate contents of file actual"
    }


    shtk_unittest_add_test inline__golden_and_actual_match
    inline__golden_and_actual_match_test() {
        echo the data >"actual file"
        ( shtk_unittest_assert_file inline:"the data\n" "actual file" ) \
            >out 2>err \
            || fail "assert_file reported false for matching inline"
        _assert_file_contents out ""
        _assert_file_contents err ""
    }


    shtk_unittest_add_test match__true
    match__true_test() {
        echo "This the first line" >actual
        echo "This the second line" >>actual

        ( shtk_unittest_assert_file match:first actual ) >out 2>err \
            || fail "assert_file reported false for matching regexp"
        _assert_file_contents out ""
        _assert_file_contents err ""

        ( shtk_unittest_assert_file match:"second line" actual ) >out 2>err \
            || fail "assert_file reported false for matching regexp"
        _assert_file_contents out ""
        _assert_file_contents err ""
    }


    shtk_unittest_add_test match__false
    match__false_test() {
        echo "This the first line" >actual
        echo "This the second line" >>actual

        ( shtk_unittest_assert_file match:fairst actual ) >out 2>err \
            && fail "assert_file reported true for not matching regexp"
        _assert_file_contents out <<EOF
Expected regexp 'fairst' not found in actual:
This the first line
This the second line
EOF
        _assert_file_contents err \
            "${_Prefix}E: Failed to validate contents of file actual"

        ( shtk_unittest_assert_file match:"second  line" actual ) >out 2>err \
            && fail "assert_file reported true for not matching regexp"
        _assert_file_contents out <<EOF
Expected regexp 'second  line' not found in actual:
This the first line
This the second line
EOF
        _assert_file_contents err \
            "${_Prefix}E: Failed to validate contents of file actual"
    }


    shtk_unittest_add_test not_empty__empty_file_is_false
    not_empty__empty_file_is_false_test() {
        touch empty_file
        ( shtk_unittest_assert_file not-empty empty_file ) >out 2>err \
            && fail "assert_file reported true for empty file"
        _assert_file_contents out <<EOF
Expected empty_file to not be empty
EOF
        _assert_file_contents err \
            "${_Prefix}E: Failed to validate contents of file empty_file"
    }


    shtk_unittest_add_test not_empty__non_empty_file_is_true
    not_empty__non_empty_file_is_true_test() {
        echo "some contents" >non_empty_file
        ( shtk_unittest_assert_file not-empty non_empty_file ) >out 2>err \
            || fail "assert_file reported false for non-empty file"
        _assert_file_contents out ""
        _assert_file_contents err ""
    }


    shtk_unittest_add_test not_match__false
    not_match__false_test() {
        echo "This the first line" >actual
        echo "This the second line" >>actual

        ( shtk_unittest_assert_file not-match:first actual ) >out 2>err \
            && fail "assert_file reported false for matching regexp"
        _assert_file_contents out <<EOF
Expected regexp 'first' found in actual:
This the first line
This the second line
EOF
        _assert_file_contents err \
            "${_Prefix}E: Failed to validate contents of file actual"

        ( shtk_unittest_assert_file not-match:"second line" actual ) \
            >out 2>err \
            && fail "assert_file reported false for matching regexp"
        _assert_file_contents out <<EOF
Expected regexp 'second line' found in actual:
This the first line
This the second line
EOF
        _assert_file_contents err \
            "${_Prefix}E: Failed to validate contents of file actual"
    }


    shtk_unittest_add_test not_match__true
    not_match__true_test() {
        echo "This the first line" >actual
        echo "This the second line" >>actual

        ( shtk_unittest_assert_file not-match:fairst actual ) >out 2>err \
            || fail "assert_file reported true for not matching regexp"
        _assert_file_contents out ""
        _assert_file_contents err ""

        ( shtk_unittest_assert_file not-match:"second  line" actual ) \
            >out 2>err \
            || fail "assert_file reported true for not matching regexp"
        _assert_file_contents out ""
        _assert_file_contents err ""
    }


    shtk_unittest_add_test save__ok
    save__ok_test() {
        echo "This is the old file" >actual
        ( shtk_unittest_assert_file save:new actual ) >out 2>err \
            || fail "assert_file reported true for copied file"
        _assert_file_contents out ""
        _assert_file_contents err ""
        cmp -s actual new || fail "assert_file failed to save file"
    }


    shtk_unittest_add_test save__fail
    save__fail_test() {
        [ $(id -u) -ne 0 ] || skip "Cannot run with root privileges"

        mkdir protected
        chmod 555 protected

        echo "This is the old file" >actual
        ( shtk_unittest_assert_file save:"protected/new file" actual ) \
            >out 2>err \
            && fail "assert_file reported true for a failed copy"
        _assert_file_contents out ""
        _assert_file_contents err \
            "${_Prefix}E: Failed to save output to protected/new file" \
            "in call to shtk_unittest_assert_file"
        [ ! -f protected/new ] || fail "Output file was written but it should" \
            "not have been"
    }


    shtk_unittest_add_test unknown_spec_is_error
    unknown_spec_is_error_test() {
        touch actual
        ( shtk_unittest_assert_file unknown-spec actual ) >out 2>err \
            && fail "assert_file reported true for unknown spec"
        _assert_file_contents out ""
        _assert_file_contents err \
            "${_Prefix}E: Invalid file check specification in" \
            "shtk_unittest_assert_file; got unknown-spec"
    }
}


shtk_unittest_add_fixture assert_and_expect
assert_and_expect_fixture() {
    do_pass_test() {
        local func="${1}"; shift

        shtk_unittest_add_test subtest
        subtest_test() {
            echo "foo" >actual
            echo "bar" >>actual
            "${func}" inline:"foo\nbar\n" actual
            echo reached
        }

        ( _shtk_unittest_run_standalone_test subtest ) >out 2>err \
            || fail "${func} failed but should have passed"
        _assert_file_contents out <<EOF
reached
EOF
        _assert_file_contents err <<EOF
${_Prefix}I: Testing subtest...
${_Prefix}I: Testing subtest... PASSED
EOF
    }


    shtk_unittest_add_test assert__pass
    assert__pass_test() {
        do_pass_test assert_file
    }


    shtk_unittest_add_test expect__pass
    expect__pass_test() {
        do_pass_test expect_file
    }


    shtk_unittest_add_test assert__fail
    assert__fail_test() {
        shtk_unittest_add_test subtest
        subtest_test() {
            echo "foo" >actual
            assert_file empty actual
            echo not reached
        }

        ( _shtk_unittest_run_standalone_test subtest ) >out 2>err \
            && fail "assert_file passed but should have failed"
        _assert_file_contents out <<EOF
Expected actual to be empty; found:
foo
EOF
        _assert_file_contents err <<EOF
${_Prefix}I: Testing subtest...
${_Prefix}E: Failed to validate contents of file actual
${_Prefix}W: Testing subtest... FAILED
EOF
    }


    shtk_unittest_add_test expect__fail
    expect__fail_test() {
        shtk_unittest_add_test subtest
        subtest_test() {
            touch actual
            expect_file not-empty actual
            echo reached
            expect_file match:"foo" actual
            echo reached
        }

        ( _shtk_unittest_run_standalone_test subtest ) >out 2>err \
            && fail "expect_file passed but should have failed"
        _assert_file_contents out <<EOF
Expected actual to not be empty
reached
Expected regexp 'foo' not found in actual:
reached
EOF
        _assert_file_contents err <<EOF
${_Prefix}I: Testing subtest...
${_Prefix}W: Delayed failure: Failed to validate contents of file actual
${_Prefix}W: Delayed failure: Failed to validate contents of file actual
${_Prefix}W: Testing subtest... FAILED (2 delayed failures)
EOF
    }
}
