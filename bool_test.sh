# Copyright 2013 Google Inc.
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

shtk_import bool


atf_test_case check__true
check__true_body() {
    for value in yes Yes YES true True TRUE 1; do
        shtk_bool_check "${value}" || atf_fail "${value} is not true"
    done
}


atf_test_case check__false
check__false_body() {
    for value in no No NO false False FALSE 0; do
        if shtk_bool_check "${value}"; then
            atf_fail "${value} is not false"
        fi
    done
}


atf_test_case check__error__default_message
check__error__default_message_body() {
    for value in 'yes ' ' no' 'foo'; do
        if ( shtk_bool_check "${value}" ) >out 2>err; then
            atf_fail "'${value}' not detected as invalid"
        fi
        atf_check -o empty cat out
        atf_check -o match:"E: Invalid boolean value '${value}'" cat err
    done
}


atf_test_case check__error__custom_message
check__error__custom_message_body() {
    for value in 'yes ' ' no' 'foo'; do
        if ( shtk_bool_check "${value}" "WRONG ${value}") >out 2>err; then
            atf_fail "'${value}' not detected as invalid"
        fi
        atf_check -o empty cat out
        atf_check -o match:"E: WRONG ${value}" cat err
    done
}


atf_init_test_cases() {
    atf_add_test_case check__true
    atf_add_test_case check__false
    atf_add_test_case check__error__default_message
    atf_add_test_case check__error__custom_message
}
