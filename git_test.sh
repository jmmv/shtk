# Copyright 2025 Julio Merino
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

shtk_import git
shtk_import unittest


one_time_setup() {
    which git >/dev/null 2>&1 || exit 77
}


# Creates a local git repository with a commit in a variety of branches.
#
# \param repo Path to the repository to create.
# \param master Name of the master branch to create.
# \param ... Name of the other branches to create.
init_git_repo() {
    local repo="${1}"; shift
    local master="${1}"; shift

    assert_command -o ignore -e ignore \
        git config --global user.email "fake@example.com"
    assert_command -o ignore -e ignore \
        git config --global user.name "Fake User"

    assert_command -o ignore -e ignore mkdir -p "${repo}"
    assert_command -o ignore -e ignore git init --bare -b "${master}" "${repo}"

    for branch in "${master}" "${@}"; do
        assert_command -o ignore -e ignore git init -b "${branch}" tmp
        echo "file in ${branch}" >tmp/file
        assert_command -o ignore -e ignore -w tmp git add file
        assert_command -o ignore -e ignore -w tmp git commit -m message file
        assert_command -o ignore -e ignore -w tmp git remote add origin "${repo}"
        assert_command -o ignore -e ignore -w tmp git push origin "${branch}"
        rm -rf tmp
    done
}


shtk_unittest_add_fixture fetch
fetch_fixture() {
    setup() {
        MOCK_GITREPO="$(pwd)/git"
        init_git_repo "${MOCK_GITREPO}" master other
    }


    teardown() {
        rm -rf "${MOCK_GITREPO}"
    }


    shtk_unittest_add_test master_branch
    master_branch_test() {
        shtk_git_fetch "${MOCK_GITREPO}" master dir
        assert_file inline:"file in master\n" dir/file

        cp -rf dir dir2
        echo "second revision" >dir2/file
        assert_command -o ignore -e ignore -w dir2 git commit -a -m message
        assert_command -o ignore -e ignore -w dir2 git push
        rm -rf dir2

        shtk_git_fetch "${MOCK_GITREPO}" master dir
        assert_file inline:"second revision\n" dir/file
    }


    shtk_unittest_add_test other_branch
    other_branch_test() {
        shtk_git_fetch "${MOCK_GITREPO}" other dir
        assert_file inline:"file in other\n" dir/file

        cp -rf dir dir2
        echo "second revision" >dir2/file
        assert_command -o ignore -e ignore -w dir2 git commit -a -m message
        assert_command -o ignore -e ignore -w dir2 git push
        rm -rf dir2

        shtk_git_fetch "${MOCK_GITREPO}" other dir
        assert_file inline:"second revision\n" dir/file
    }


    shtk_unittest_add_test switch_branches
    switch_branches_test() {
        shtk_git_fetch "${MOCK_GITREPO}" master dir
        assert_file inline:"file in master\n" dir/file

        shtk_git_fetch "${MOCK_GITREPO}" other dir
        assert_file inline:"file in other\n" dir/file
    }
}


shtk_unittest_add_fixture clone
clone_fixture() {
    setup() {
        MOCK_GITREPO="$(pwd)/git"
    }


    teardown() {
        rm -rf "${MOCK_GITREPO}"
    }


    shtk_unittest_add_test master_branch
    master_branch_test() {
        init_git_repo "${MOCK_GITREPO}" master other
        shtk_git_clone "${MOCK_GITREPO}" master $(pwd)/a/b/c/clone
        [ -f a/b/c/clone/file ] || fail "Files not checked out"
        assert_file inline:"file in master\n" a/b/c/clone/file
    }


    shtk_unittest_add_test other_branch
    other_branch_test() {
        init_git_repo "${MOCK_GITREPO}" master other
        shtk_git_clone "${MOCK_GITREPO}" other $(pwd)/a/b/c/clone
        [ -f a/b/c/clone/file ] || fail "Files not checked out"
        assert_file inline:"file in other\n" a/b/c/clone/file
    }


    shtk_unittest_add_test already_exists
    already_exists_test() {
        mkdir -p usr/src
        assert_command -s exit:1 \
            -e match:"Cannot clone into $(pwd)/usr/src.*exists" \
            shtk_git_clone "${MOCK_GITREPO}" master "$(pwd)/usr/src"
    }


    shtk_unittest_add_test permission_denied
    permission_denied_test() {
        [ "$(id -u)" -ne 0 ] || skip "Cannot run test as root"

        init_git_repo "${MOCK_GITREPO}" master
        mkdir usr
        chmod 555 usr
        assert_command -s exit:1 -e match:"could not create" \
            shtk_git_clone "${MOCK_GITREPO}" master "$(pwd)/usr/src"
    }


    shtk_unittest_add_test git_fails
    git_fails_test() {
        init_git_repo "${MOCK_GITREPO}" master
        assert_command -s exit:1 -e match:"git clone failed" \
            shtk_git_clone "${MOCK_GITREPO}" non-existent "$(pwd)/usr/src"
    }
}


shtk_unittest_add_fixture update
update_fixture() {
    setup() {
        MOCK_GITREPO="$(pwd)/git"
    }


    teardown() {
        rm -rf "${MOCK_GITREPO}"
    }


    shtk_unittest_add_test ok
    ok_test() {
        init_git_repo "${MOCK_GITREPO}" master

        assert_command -o ignore -e ignore git clone "${MOCK_GITREPO}" tmp

        shtk_git_update master tmp
        assert_file inline:"file in master\n" tmp/file

        echo "second revision" >tmp/file
        assert_command -o ignore -e ignore -w tmp git commit -m iterate file
        assert_command -o ignore -e ignore -w tmp git push
        assert_command -o ignore -e ignore -w tmp git reset --hard HEAD^1

        assert_file inline:"file in master\n" tmp/file
        shtk_git_update master tmp
        assert_file inline:"second revision\n" tmp/file
    }


    shtk_unittest_add_test does_not_exist
    does_not_exist_test() {
        assert_command -s exit:1 -e match:"Cannot update tmp; .*not exist" \
            shtk_git_update master tmp
    }


    shtk_unittest_add_test git_fails
    git_fails_test() {
        init_git_repo "${MOCK_GITREPO}" master
        assert_command -o ignore -e ignore git clone "${MOCK_GITREPO}" tmp
        assert_command -s exit:1 -e match:"git update failed" \
            shtk_git_update non-existent tmp
    }
}
