#! /bin/sh
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

set -e -x

readonly SHELL_NAME="${1}"; shift
readonly REQUIRED_TOOLS="${1}"; shift

required_cvs=false
for tool in ${REQUIRED_TOOLS}; do
    if ! which "${tool}" >/dev/null 2>&1; then
        echo "Expected tool ${tool} is not installed" 1>&2
        exit 1
    fi
    case "${tool}" in
        cvs) required_cvs=true ;;
    esac
done
if [ "${required_cvs}" = false ]; then
    if which "${tool}" >/dev/null 2>&1; then
        echo "Unexpected tool ${tool} is installed" 1>&2
        exit 1
    fi
fi

autoreconf -isv

shell_path="$(which ${SHELL_NAME})"
if [ ${?} -ne 0 ]; then
    echo "Failed to resolve path to shell ${SHELL_NAME}" 1>&2
    exit 1
fi
./configure SHTK_SHELL="${shell_path}"

ret=0
make distcheck DISTCHECK_CONFIGURE_FLAGS="SHTK_SHELL='${shell_path}'" \
    || ret="${?}"
if [ ${ret} -ne 0 ]; then
    {
        echo "make distcheck failed!"
        log="$(find . -name test-suite.log)"
        if [ -f "${log}" ]; then
            echo "Contents of ${log}:"
            cat "${log}"
        fi
    } 1>&2
    exit ${ret}
fi
