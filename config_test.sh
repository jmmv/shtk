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

shtk_import config
shtk_import unittest


shtk_unittest_add_fixture is_valid
is_valid_fixture() {
    setup() {
        shtk_config_init VAR1 VAR3
    }


    shtk_unittest_add_test true
    true_test() {
        for var in VAR1 VAR3; do
            _shtk_config_is_valid "${var}" || fail "${var} not found"
        done
    }


    shtk_unittest_add_test false
    false_test() {
        for var in VAR11 VAR2 VAR; do
            if _shtk_config_is_valid "${var}"; then
                fail "${var} found but was not registered"
            fi
        done
    }
}


shtk_unittest_add_fixture has
has_fixture() {
    setup() {
        shtk_config_init TESTVAR
    }


    shtk_unittest_add_test true__empty
    true__empty_test() {
        shtk_config_set TESTVAR ""
        shtk_config_has TESTVAR || fail "Expected variable not found"
    }


    shtk_unittest_add_test true__not_empty
    true__not_empty_test() {
        shtk_config_set TESTVAR "foo"
        shtk_config_has TESTVAR || fail "Expected variable not found"
    }


    shtk_unittest_add_test false
    false_test() {
        if shtk_config_has TESTVAR; then
            fail "Unexpected variable found"
        fi
    }
}


shtk_unittest_add_fixture get
get_fixture() {
    setup() {
        shtk_config_init TESTVAR
    }


    shtk_unittest_add_test ok__empty
    ok__empty_test() {
        shtk_config_set TESTVAR ""
        [ -z "$(shtk_config_get TESTVAR)" ] || fail "Failed to query value"
    }


    shtk_unittest_add_test ok__not_empty
    ok__not_empty_test() {
        shtk_config_set TESTVAR some-value
        [ "$(shtk_config_get TESTVAR)" = some-value ] \
            || fail "Failed to query value"
    }


    shtk_unittest_add_test undefined_variable
    undefined_variable_test() {
        expect_command -s exit:1 \
            -e match:"Required configuration variable TESTVAR not set" \
            shtk_config_get TESTVAR
    }
}


shtk_unittest_add_fixture get_bool
get_bool_fixture() {
    setup() {
        shtk_config_init TESTVAR
    }


    shtk_unittest_add_test true
    true_test() {
        for value in yes Yes true True; do
            shtk_config_set TESTVAR "${value}"
            shtk_config_get_bool TESTVAR || fail "Expected true, but got false"
        done
    }


    shtk_unittest_add_test false
    false_test() {
        for value in no No false False; do
            shtk_config_set TESTVAR "${value}"
            if shtk_config_get_bool TESTVAR; then
                fail "Expected false, but got true"
            fi
        done
    }


    shtk_unittest_add_test undefined_variable
    undefined_variable_test() {
        if shtk_config_get_bool TESTVAR; then
            fail "Expected false, but got true"
        fi
    }


    shtk_unittest_add_test invalid_value
    invalid_value_test() {
        shtk_config_set TESTVAR not-a-boolean
        expect_command -s exit:1 \
            -e match:"Invalid boolean value in variable TESTVAR" \
            shtk_config_get_bool TESTVAR
    }
}


shtk_unittest_add_fixture get_default
get_default_fixture() {
    setup() {
        shtk_config_init TESTVAR
    }


    shtk_unittest_add_test defined__empty
    defined__empty_test() {
        shtk_config_set TESTVAR ""
        [ "$(shtk_config_get_default TESTVAR 'foo')" = "" ] \
            || fail "Did not fetch defined value"
    }


    shtk_unittest_add_test defined__not_empty
    defined__not_empty_test() {
        shtk_config_set TESTVAR "bar"
        [ "$(shtk_config_get_default TESTVAR 'foo')" = "bar" ] \
            || fail "Did not fetch defined value"
    }


    shtk_unittest_add_test default__empty
    default__empty_test() {
        [ "$(shtk_config_get_default TESTVAR '')" = "" ] \
            || fail "Did not fetch default value"
    }


    shtk_unittest_add_test default__not_empty
    default__not_empty_test() {
        [ "$(shtk_config_get_default TESTVAR 'foo')" = "foo" ] \
            || fail "Did not fetch default value"
    }
}


shtk_unittest_add_fixture set
set_fixture() {
    setup() {
        shtk_config_init TESTVAR
    }


    shtk_unittest_add_test ok
    ok_test() {
        shtk_config_set TESTVAR some-value
        expect_equal some-value "${shtk_config_var_TESTVAR}"
    }


    shtk_unittest_add_test unknown_variable
    unknown_variable_test() {
        expect_command -s exit:1 \
            -e match:"Unknown configuration variable TESTVAR2" \
            shtk_config_set TESTVAR2
    }
}


shtk_unittest_add_fixture unset
unset_fixture() {
    setup() {
        shtk_config_init TESTVAR
    }


    shtk_unittest_add_test ok
    ok_test() {
        shtk_config_var_TESTVAR=some-value
        shtk_config_unset TESTVAR
        [ "${shtk_config_var_TESTVAR-unset}" = unset ] \
            || fail "Failed to unset variable"
    }


    shtk_unittest_add_test unknown_variable
    unknown_variable_test() {
        expect_command -s exit:1 \
            -e match:"Unknown configuration variable TESTVAR2" \
            shtk_config_unset TESTVAR2
    }
}


shtk_unittest_add_test load__filter_variables
load__filter_variables_test() {
    shtk_config_init Z VAR1 EMPTY

    cat >test.conf <<EOF
A=foo
Z=bar
VAR1="some text"
VAR2="some other text"
EOF

    shtk_config_load $(pwd)/test.conf \
        || fail "Failed to load test configuration"

    [ "${shtk_config_var_Z}" = bar ] || \
        fail "Z not found in configuration"
    [ "${shtk_config_var_VAR1}" = "some text" ] || \
        fail "VAR1 not found in configuration"

    [ "${shtk_config_var_EMPTY-has_not_been_set}" = has_not_been_set ] || \
        fail "Undefined variable set, but should not have been"

    [ "${shtk_config_var_A-unset}" = unset ] || \
        fail "A set in configuration, but not expected"
    [ "${shtk_config_var_VAR2-unset}" = unset ] || \
        fail "VAR2 set in configuration, but not expected"
}


shtk_unittest_add_test load__respect_existing
load__respect_existing_test() {
    shtk_config_init VAR1 V2

    shtk_config_set VAR1 "value 1"
    shtk_config_set V2 "value-2"
    shtk_config_load /dev/null || fail "Failed to load empty configuration"
    shtk_config_has VAR1 || fail "VAR1 was undefined on load"
    shtk_config_has V2 || fail "V2 was undefined on load"
}


shtk_unittest_add_test load__allow_undefine
load__allow_undefine_test() {
    shtk_config_init UNDEFINE

    cat >test.conf <<EOF
UNDEFINE=
EOF

    shtk_config_set UNDEFINE "remove me"
    shtk_config_load $(pwd)/test.conf \
        || fail "Failed to load test configuration"
    if shtk_config_has UNDEFINE; then
        fail "Undefine attempt from configuration did not work"
    fi
}


shtk_unittest_add_test load__current_directory
load__current_directory_test() {
    shtk_config_init A

    cat >test.conf <<EOF
A=foo
EOF

    shtk_config_load test.conf || fail "Failed to load test configuration"

    [ "${shtk_config_var_A}" = foo ] || \
        fail "A not found in configuration"
}


shtk_unittest_add_test load__missing_file
load__missing_file_test() {
    expect_command -s exit:1 \
        -e match:"Configuration file missing.conf does not exist" \
        shtk_config_load missing.conf
}


shtk_unittest_add_test load__invalid_file
load__invalid_file_test() {
    echo "this file is invalid" >invalid.conf
    expect_command -s exit:1 \
        -e match:"Failed to load configuration file invalid.conf" \
        shtk_config_load invalid.conf
}


shtk_unittest_add_test include__absolute
include__absolute_test() {
    shtk_config_init A B

    mkdir -p dir1/dir2/dir3
    cat >dir1/dir2/dir3/test3.conf <<EOF
A=from-file-3
B=from-file-3
shtk_config_include ../test2.conf
EOF
    cat >dir1/dir2/test2.conf <<EOF
A=from-file-2
B=from-file-2
shtk_config_include $(pwd)/dir1/test1.A.conf
shtk_config_include ../test1.B.conf
EOF
    cat >dir1/test1.A.conf <<EOF
A=from-file-1.A
B=from-file-1.A
shtk_config_include test0.conf
EOF
    cat >dir1/test0.conf <<EOF
A=from-file-0
B=from-file-0
EOF
    cat >dir1/test1.B.conf <<EOF
B=from-file-1.B
EOF

    shtk_config_load dir1/dir2/dir3/test3.conf \
        || fail "Failed to load test configuration"

    expect_equal from-file-0 "${shtk_config_var_A}"
    expect_equal from-file-1.B "${shtk_config_var_B}"
}


shtk_unittest_add_test include__relative
include__relative_test() {
    shtk_config_init A B

    mkdir -p dir1/dir2/dir3
    cat >dir1/dir2/dir3/test3.conf <<EOF
A=from-file-3
B=from-file-3
shtk_config_include ../test2.conf
EOF
    cat >dir1/dir2/test2.conf <<EOF
A=from-file-2
B=from-file-2
shtk_config_include ../test1.A.conf
shtk_config_include ../test1.B.conf
EOF
    cat >dir1/test1.A.conf <<EOF
A=from-file-1.A
B=from-file-1.A
shtk_config_include test0.conf
EOF
    cat >dir1/test0.conf <<EOF
A=from-file-0
B=from-file-0
EOF
    cat >dir1/test1.B.conf <<EOF
B=from-file-1.B
EOF

    shtk_config_load dir1/dir2/dir3/test3.conf \
        || fail "Failed to load test configuration"

    expect_equal from-file-0 "${shtk_config_var_A}"
    expect_equal from-file-1.B "${shtk_config_var_B}"
}


shtk_unittest_add_test override__ok_before_load
override__ok_before_load_test() {
    shtk_config_init VAR1 VAR2

    cat >test.conf <<EOF
VAR1="override me"
VAR2="do not override me"
EOF

    shtk_config_override "VAR1=new value"
    shtk_config_load test.conf || fail "Failed to load test configuration"

    [ "${shtk_config_var_VAR1}" = "new value" ] || fail "Override failed"
    [ "${shtk_config_var_VAR2}" = "do not override me" ] \
        || fail "Overrode more than one variable"
}


shtk_unittest_add_test override__not_ok_after_load
override__not_ok_after_load_test() {
    shtk_config_init VAR1 VAR2

    cat >test.conf <<EOF
VAR1="override me"
VAR2="do not override me"
EOF

    shtk_config_load test.conf || fail "Failed to load test configuration"
    shtk_config_override "VAR1=new value"

    [ "${shtk_config_var_VAR1}" = "override me" ] \
        || fail "Override succeeded, but it should not have"
    [ "${shtk_config_var_VAR2}" = "do not override me" ] \
        || fail "Overrode more than one variable"
}


shtk_unittest_add_test override__invalid_format
override__invalid_format_test() {
    for arg in foo =bar ''; do
        expect_command \
            -s exit:1 -e match:"Invalid configuration override ${arg}" \
            shtk_config_override "${arg}"
    done
}


shtk_unittest_add_test override__unknown_variable
override__unknown_variable_test() {
    shtk_config_init Z VAR1
    expect_command \
        -s exit:1 -e match:"Unknown configuration variable A" \
        shtk_config_override "A=b"
    expect_command \
        -s exit:1 -e match:"Unknown configuration variable VAR2" \
        shtk_config_override "VAR2=d"
}


shtk_unittest_add_test run_hook__ok
run_hook__ok_test() {
    shtk_config_init VAR1 VAR2 VAR3
    shtk_config_set VAR1 "first"
    shtk_config_set VAR3 "third"

    test_hook() {
        echo "ARGS=${*}"
        echo "VAR1=${VAR1:-unset}"
        echo "VAR2=${VAR2:-unset}"
        echo "VAR3=${VAR3:-unset}"
    }

    cat >expout <<EOF
ARGS=arg1 arg2
VAR1=first
VAR2=unset
VAR3=third
EOF
    VAR1=ignore-this; VAR2=ignore-this; VAR3=ignore-this
    expect_command -o file:expout shtk_config_run_hook test_hook arg1 arg2
}


shtk_unittest_add_test run_hook__fail
run_hook__fail_test() {
    shtk_config_init VAR1
    shtk_config_set VAR1 "first"

    test_hook() {
        echo "VAR1=${VAR1:-unset}"
        false
    }

    expect_command \
        -s exit:1 -o inline:"VAR1=first\n" \
        -e match:"The hook test_hook returned an error" \
        shtk_config_run_hook test_hook
}
