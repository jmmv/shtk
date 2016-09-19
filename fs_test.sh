# Copyright 2016 Google Inc.
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

shtk_import fs
shtk_import unittest


shtk_unittest_add_test join_paths__one
join_paths__one_test() {
    assert_equal / "$(shtk_fs_join_paths /)"
    assert_equal ./foo "$(shtk_fs_join_paths foo)"
    assert_equal /bar "$(shtk_fs_join_paths /bar)"
}


shtk_unittest_add_test join_paths__many
join_paths__many_test() {
    assert_equal /bin/ls "$(shtk_fs_join_paths /bin ls)"
    assert_equal /bin/ls "$(shtk_fs_join_paths /bin ./ls)"
    assert_equal /usr/local/bin/f "$(shtk_fs_join_paths /usr local /bin ./f)"
}


shtk_unittest_add_test join_paths__empty_components
join_paths__empty_components_test() {
    assert_equal /bin/ls "$(shtk_fs_join_paths '' /bin '' ls)"
    assert_equal /bin/ls "$(shtk_fs_join_paths '' bin '' ls '')"
}


shtk_unittest_add_test normalize_path__root
normalize_path__root_test() {
    assert_equal / "$(shtk_fs_normalize_path /)"
    assert_equal / "$(shtk_fs_normalize_path ////)"
    assert_equal / "$(shtk_fs_normalize_path //.)"
    assert_equal / "$(shtk_fs_normalize_path //.//)"
}


shtk_unittest_add_test normalize_path__absolute
normalize_path__absolute_test() {
    assert_equal /foo "$(shtk_fs_normalize_path /foo)"
    assert_equal /foo "$(shtk_fs_normalize_path ///foo//)"
    assert_equal /foo/bar/baz "$(shtk_fs_normalize_path //.//foo/bar/baz/.)"
}


shtk_unittest_add_test normalize_path__relative_unprefixed
normalize_path__relative_unprefixed_test() {
    assert_equal ./foo "$(shtk_fs_normalize_path foo)"
    assert_equal ./foo "$(shtk_fs_normalize_path foo//)"
    assert_equal ./foo/bar/baz "$(shtk_fs_normalize_path foo/bar/baz/.)"
}


shtk_unittest_add_test normalize_path__relative_prefixed
normalize_path__relative_prefixed_test() {
    assert_equal ./foo "$(shtk_fs_normalize_path ./foo)"
    assert_equal ./foo "$(shtk_fs_normalize_path .//foo//)"
    assert_equal ./foo/bar/baz "$(shtk_fs_normalize_path .///foo/bar/baz/.)"
}


shtk_unittest_add_test normalize_path__dotdot_untouched
normalize_path__dotdot_untouched_test() {
    assert_equal /foo/../tmp "$(shtk_fs_normalize_path //foo/.././tmp)"
}
