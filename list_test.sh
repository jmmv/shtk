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

shtk_import list
shtk_import unittest


shtk_unittest_add_test contains__yes
contains__yes_test() {
    items="bar foo baz"
    shtk_list_contains foo ${items} || fail "Element not found in list"
}


shtk_unittest_add_test contains__no
contains__no_test() {
    items="bar foo baz"
    shtk_list_contains fo ${items} && fail "Element found in list"
}


shtk_unittest_add_test filter__no_items
filter__no_items_test() {
    expect_equal "" "$(shtk_list_filter '*')"
}


shtk_unittest_add_test filter__no_results
filter__no_results_test() {
    items="abc a1 foo a2 a3 bar"
    expect_equal "" "$(shtk_list_filter '*a' ${items})"
}


shtk_unittest_add_test filter__some_results
filter__some_results_test() {
    items="abc a1 foo a2 a3 bar"
    expect_equal "a1 a2 a3" "$(shtk_list_filter 'a[0-9]*' ${items})"
    expect_equal "foo a3" "$(shtk_list_filter 'a3|foo' ${items})"
}
