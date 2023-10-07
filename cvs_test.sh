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

shtk_import cvs
shtk_import unittest


one_time_setup() {
    which cvs >/dev/null 2>&1 || exit 77
}


# Creates a local CVS repository with a variety of modules.
#
# \param repository Path to the repository to create.
# \param ... Modules to create.
init_cvsroot() {
    local repository="${1}"; shift

    expect_command -o ignore -e ignore cvs -d "${repository}" init

    for module in "${@}"; do
        mkdir module
        cd module
        echo "first revision" >"file-in-${module}"
        cvs -d "${repository}" import -m "Import." "${module}" VENDOR_TAG \
            release_tag
        cd -
        rm -rf module
    done
}


shtk_unittest_add_fixture fetch
fetch_fixture() {
    setup() {
        MOCK_CVSROOT=":local:$(pwd)/cvsroot"
        init_cvsroot "${MOCK_CVSROOT}" src
    }


    teardown() {
        rm -rf "${MOCK_CVSROOT}"
    }


    shtk_unittest_add_test ok
    ok_test() {
        shtk_cvs_fetch "${MOCK_CVSROOT}" src "" first
        grep "first revision" first/file-in-src >/dev/null \
            || fail "Unexpected version found"

        cp -rf first second
        echo "second revision" >second/file-in-src
        ( cd second && cvs commit -m "Second commit." )

        shtk_cvs_fetch "${MOCK_CVSROOT}" src "" first
        grep "second revision" first/file-in-src >/dev/null \
            || fail "Unexpected version found"
    }
}


shtk_unittest_add_fixture checkout
checkout_fixture() {
    setup() {
        MOCK_CVSROOT=":local:$(pwd)/cvsroot"
    }


    teardown() {
        rm -rf "${MOCK_CVSROOT}"
    }


    shtk_unittest_add_test same_name
    same_name_test() {
        init_cvsroot "${MOCK_CVSROOT}" first second
        shtk_cvs_checkout "${MOCK_CVSROOT}" first "" $(pwd)/a/b/c/first
        [ -f a/b/c/first/file-in-first ] || fail "Files not checked out"
        if [ -f a/b/c/second/file-in-second ]; then
            fail "Unexpected module checked out"
        fi
    }


    shtk_unittest_add_test different_name
    different_name_test() {
        init_cvsroot "${MOCK_CVSROOT}" first second
        shtk_cvs_checkout "${MOCK_CVSROOT}" first "" $(pwd)/a/b/c/second
        [ -f a/b/c/second/file-in-first ] || fail "Files not checked out"
    }


    shtk_unittest_add_test already_exists
    already_exists_test() {
        mkdir -p usr/src
        expect_command -s exit:1 \
            -e match:"Cannot checkout into $(pwd)/usr/src.*exists" \
            shtk_cvs_checkout "${MOCK_CVSROOT}" src "" "$(pwd)/usr/src"
    }


    shtk_unittest_add_test permission_denied
    permission_denied_test() {
        [ "$(id -u)" -ne 0 ] || skip "Cannot run test as root"

        init_cvsroot "${MOCK_CVSROOT}" src
        mkdir usr
        chmod 555 usr
        expect_command -s exit:1 -e match:"Failed to create $(pwd)/usr/src" \
            shtk_cvs_checkout "${MOCK_CVSROOT}" src "" "$(pwd)/usr/src"
    }


    shtk_unittest_add_test cvs_fails
    cvs_fails_test() {
        init_cvsroot "${MOCK_CVSROOT}" src
        expect_command -s exit:1 -e match:"CVS checkout failed" \
            shtk_cvs_checkout "${MOCK_CVSROOT}" src "foo" "$(pwd)/usr/src"
    }
}


shtk_unittest_add_fixture update
update_fixture() {
    setup() {
        MOCK_CVSROOT=":local:$(pwd)/cvsroot"
    }


    teardown() {
        rm -rf "${MOCK_CVSROOT}"
    }


    shtk_unittest_add_test ok
    ok_test() {
        init_cvsroot "${MOCK_CVSROOT}" first second

        cvs -d "${MOCK_CVSROOT}" checkout first
        mv first copy
        cvs -d "${MOCK_CVSROOT}" checkout first

        shtk_cvs_update "${MOCK_CVSROOT}" "" first
        grep "first revision" first/file-in-first >/dev/null \
            || fail "Unexpected version found"

        echo "second revision" >copy/file-in-first
        ( cd copy && cvs commit -m "Second commit." )

        shtk_cvs_update "${MOCK_CVSROOT}" "" first
        grep "second revision" first/file-in-first >/dev/null \
            || fail "Unexpected version found"
    }


    shtk_unittest_add_test resume_checkout
    resume_checkout_test() {
        init_cvsroot "${MOCK_CVSROOT}" first

        cvs -d "${MOCK_CVSROOT}" checkout first
        mv first copy

        mkdir -p first/.cvs-checkout/first
        mv copy/CVS first/.cvs-checkout/first
        rm -rf copy

        shtk_cvs_update "${MOCK_CVSROOT}" "" first
        grep "first revision" first/file-in-first >/dev/null \
            || fail "Unexpected version found"
    }


    shtk_unittest_add_test does_not_exist
    does_not_exist_test() {
        expect_command -s exit:1 -e match:"Cannot update src; .*not exist" \
            shtk_cvs_update "${MOCK_CVSROOT}" "" src
    }


    shtk_unittest_add_test cvs_fails
    cvs_fails_test() {
        init_cvsroot "${MOCK_CVSROOT}" src
        cvs -d "${MOCK_CVSROOT}" checkout src
        expect_command -s exit:1 -e match:"CVS update failed" \
            shtk_cvs_update "${MOCK_CVSROOT}" "foo" src
    }
}
