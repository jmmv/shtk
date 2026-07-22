#! __SHTK_SHELL__
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

# \file shtk.sh
# Entry point and main program logic.
#
# For simplicity reasons, we cannot rely on any of our own modules to
# implement this file.  Doing so, while possible, would complicate the
# creation of the final shtk script for no real advantage.


# Location of the shtk modules.
: ${SHTK_MODULESDIR:="__SHTK_MODULESDIR__"}


# Default shell to use when generating scripts.
: ${SHTK_SHELL:="__SHTK_SHELL__"}


# Version of the package.
SHTK_VERSION="__SHTK_VERSION__"


# Base name of the running script.
_ProgName="${0##*/}"


# Prints a runtime error and exits.
#
# \param ... The message to print.  Can be provided as multiple words and, in
#     that case, they are joined together by a single whitespace.
error() {
    echo "${_ProgName}: E: $*" 1>&2
    exit 1
}


# Prints an usage error and exits.
#
# \param ... The message to print.  Can be provided as multiple words and, in
#     that case, they are joined together by a single whitespace.
usage_error() {
    echo "${_ProgName}: E: $*" 1>&2
    echo "Type 'man ${_ProgName}' for help" 1>&2
    exit 1
}


# Validates that a shell path is suitable for use in a shebang.
#
# \param shell The interpreter path to validate.
_shtk_validate_shell() {
    local shell="${1}"; shift

    [ -f "${shell}" -a -r "${shell}" ] || error "Cannot open ${shell}"
    [ -x "${shell}" ] || error "Cannot execute ${shell}"

    local magic="$(dd if="${shell}" bs=2 count=1 2>/dev/null || true)"
    [ "${magic}" != '#!' ] \
        || error "Cannot use ${shell} as an interpreter because it is a script"
}


# Command to build a script that uses shtk libraries.
#
# \params ... Options and arguments to the command.
shtk_build() {
    local main=main
    local output=
    local shell="${SHTK_SHELL}"
    local OPTIND=1

    while getopts ':m:o:s:' arg "${@}"; do
        case "${arg}" in
            m)  # Main function name.
                main="${OPTARG}"
                ;;

            o)  # Output file.
                output="${OPTARG}"
                ;;

            s)  # Shell to use.
                shell="${OPTARG}"
                ;;

            :)
                usage_error "Missing argument to option -${OPTARG} in build"
                ;;

            \?)
                usage_error "Unknown option -${OPTARG} in build"
                ;;
        esac
    done
    shift $((${OPTIND} - 1))

    [ ${#} -eq 1 ] || usage_error "build takes one argument only"

    _shtk_validate_shell "${shell}"

    local input="${1}"; shift
    case "${input}" in
        *.sh)
            [ -n "${output}" ] || output="$(echo ${input} | sed -e 's,\.sh$,,')"
            ;;

        *)
            [ -n "${output}" ] || usage_error "Input file should" \
                "end in .sh or you must specify -o"
            ;;
    esac

    [ "${input}" = - -o -e "${input}" ] || error "Cannot open ${input}"

    # Note that we use the built-in value of SHTK_MODULESDIR unconditionally
    # instead of what the environment says to avoid possible side-effects that
    # would be easy to debug.
    sed -e "s,%%SHTK_MODULESDIR%%,__SHTK_MODULESDIR__,g" \
        -e "s,%%SHTK_SH%%,${shell},g" \
        "${SHTK_MODULESDIR}/bootstrap.subr" \
        | grep -v '^#[^!].*' | grep -v '^#$' >"${output}.tmp"
    if [ "${input}" = - ]; then
        cat >>"${output}.tmp"
    else
        cat -- "${input}" >>"${output}.tmp"
    fi
    [ -z "${main}" ] || echo "${main} \"\${@}\"" >>"${output}.tmp"
    chmod +x "${output}.tmp"
    if ! mv "${output}.tmp" "${output}"; then
        rm -f "${output}.tmp"
        error "Failed to create ${output}"
    fi
}


# Builds and executes a source script.
#
# \param main Name of the function that implements the entry point.
# \param shell Path to the shell interpreter to use.
# \param input Path to the source script.
# \params ... Arguments to pass to the script.
_shtk_execute() {
    local main="${1}"; shift
    local shell="${1}"; shift
    local input="${1}"; shift

    local pattern="${TMPDIR:-/tmp}/shtk.XXXXXX"
    local tempdir
    tempdir="$(mktemp -d "${pattern}" 2>/dev/null)"
    [ -d "${tempdir}" ] || error "Failed to create temporary directory"
    trap "rm -rf '${tempdir}'" EXIT HUP INT TERM

    local name="${input##*/}"
    local output="${tempdir}/${name%.sh}"

    shtk_build -m "${main}" -o "${output}" -s "${shell}" -- "${input}" \
        || error "Failed to build script"

    local exit_code=0
    "${output}" "${@}" || exit_code="${?}"

    rm -rf "${tempdir}"
    trap - EXIT HUP INT TERM

    return "${exit_code}"
}


# Command to run a script that uses shtk libraries.
#
# \params ... Options and arguments to the command.
shtk_run() {
    local main=main
    local shell="${SHTK_SHELL}"
    local OPTIND=1

    while getopts ':m:s:' arg "${@}"; do
        case "${arg}" in
            m)  # Main function name.
                main="${OPTARG}"
                ;;

            s)  # Shell to use.
                shell="${OPTARG}"
                ;;

            :)
                usage_error "Missing argument to option -${OPTARG} in run"
                ;;

            \?)
                usage_error "Unknown option -${OPTARG} in run"
                ;;
        esac
    done
    shift $((${OPTIND} - 1))

    [ ${#} -ge 1 ] || usage_error "run requires an input file"

    _shtk_validate_shell "${shell}"

    local input="${1}"; shift
    [ "${input}" != - ] || usage_error "run does not accept standard input"
    [ -f "${input}" -a -r "${input}" ] || error "Cannot open ${input}"

    _shtk_execute "${main}" "${shell}" "${input}" "${@}"
}


# Command to run scripts that use the shtk unittest library.
#
# \params ... Options and arguments to the command.
shtk_test() {
    local main=shtk_unittest_main
    local shell="${SHTK_SHELL}"
    local OPTIND=1

    while getopts ':m:s:' arg "${@}"; do
        case "${arg}" in
            m)  # Main function name.
                main="${OPTARG}"
                ;;

            s)  # Shell to use.
                shell="${OPTARG}"
                ;;

            :)
                usage_error "Missing argument to option -${OPTARG} in test"
                ;;

            \?)
                usage_error "Unknown option -${OPTARG} in test"
                ;;
        esac
    done
    shift $((${OPTIND} - 1))

    [ ${#} -ge 1 ] || usage_error "test requires at least one input file"

    _shtk_validate_shell "${shell}"

    local input
    for input in "${@}"; do
        [ "${input}" != - ] \
            || usage_error "test does not accept standard input"
        [ -f "${input}" -a -r "${input}" ] || error "Cannot open ${input}"
    done

    local exit_code=0
    for input in "${@}"; do
        _shtk_execute "${main}" "${shell}" "${input}" || exit_code=1
    done
    return "${exit_code}"
}


# Gets version information about shtk.
shtk_version() {
    [ ${#} -eq 0 ] || usage_error "version does not take any arguments"

    echo "shtk ${SHTK_VERSION}"
}


# Entry point to the program.
#
# \param ... Command-line arguments to be processed.
#
# \return An exit code to be returned to the user.
shtk_main() {
    [ ${#} -ge 1 ] || usage_error "No command specified"

    local exit_code=0

    local command="${1}"; shift
    case "${command}" in
        build|run|test|version)
            "shtk_${command}" "${@}" || exit_code="${?}"
            ;;

        *)
            usage_error "Unknown command ${command}"
            ;;
    esac

    return "${exit_code}"
}


shtk_main "${@}"
