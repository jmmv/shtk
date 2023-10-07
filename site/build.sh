# Copyright 2023 Julio Merino
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

shtk_import cli

set -eu

build_distdocs() {
    local outdir="${1}"; shift

    pandoc INSTALL.md >"${outdir}/install.html.frag"
}

build_docs() {
    local outdir="${1}"; shift

    shtk_cli_info "Converting mandoc to HTML..."
    echo "<ul>" >>"${outdir}/docs.html.frag"
    for src in man/*.[0-9]; do
        dest="${src#man/}.html"
        mandoc -Thtml -Ofragment -Oman=%N.%S.html "${src}" \
            >"${outdir}/${dest}.frag"
        echo "<li><a href=\"${dest}\">${dest}</a></li>" \
            >>"${outdir}/docs.html.frag"
    done
    echo "</ul>" >>"${outdir}/docs.html.frag"
}

build_fragments() {
    local outdir="${1}"; shift
    local version="${1}"; shift
    local site_id="${1}"; shift

    shtk_cli_info "Processing fragments..."
    for src in "${outdir}"/*.frag; do
        dest="${src%.frag}"

        docs_active=
        install_active=
        case "${src}" in
            */index.html*) ;;
            */install.html*) install_active="active" ;;
            *) docs_active="active" ;;
        esac

        local name="${dest#${outdir}/}"
        local page_id="$(echo "https://shtk.jmmv.dev/${name}" | base64 -w0)"

        cat site/header.html.in "${src}" site/footer.html.in \
            | sed -e "s,@DOCS_ACTIVE@,${docs_active},g" \
                  -e "s,@INSTALL_ACTIVE@,${install_active},g" >"${dest}" \
                  -e "s,@SHTK_VERSION@,${version},g" \
                  -e "s,@SITE_ID@,${site_id},g" \
                  -e "s,@PAGE_ID@,${page_id},g" \
                  >"${dest}"
    done
}

main() {
    local site_id=
    local outdir=site-out
    local version=0.0

    while getopts ':o:s:v:' arg "${@}"; do
        case "${arg}" in
            o)  # Output directory.
                outdir="${OPTARG}"
                ;;

            s)  # Site id for analytics.
                site_id="${OPTARG}"
                ;;

            v)  # Version to embed in the documentation.
                version="${OPTARG}"
                ;;

            :)
                shtk_cli_error "Missing argument to option -${OPTARG} in build"
                ;;

            \?)
                shtk_cli_error "Unknown option -${OPTARG} in build"
                ;;
        esac
    done
    shift $((${OPTIND} - 1))

    [ ${#} -eq 0 ] || shtk_cli_error "build takes zero arguments"

    rm -rf "${outdir}"
    mkdir "${outdir}"

    cp site/CNAME "${outdir}"/
    cp site/*.frag "${outdir}"/
    cp site/styles.css "${outdir}"/

    build_distdocs "${outdir}"

    build_docs "${outdir}"

    build_fragments "${outdir}" "${version}" "${site_id}"

    rm "${outdir}"/*.frag
}
