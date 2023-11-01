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

load(":toolchains.bzl", "shtk_toolchain")
load(":versions.bzl", "versions")

"""Version of shtk to use by these rules."""
SHTK_VERSION = "1.7"

"""Checksum of the distfile that provides SHTK_VERSION."""
SHTK_SHA256 = "9386b7dbf1a28361eaf56dd1712385abdbdf3a02f03e17ccbf5579bf22695e27"

def _shtk_autoconf_toolchain_impl(repository_ctx):
    shtk_path = repository_ctx.attr.shtk_path
    if not shtk_path:
        shtk_path = str(repository_ctx.which("shtk"))
    if not shtk_path:
        fail("shtk cannot be found in the PATH")

    result = repository_ctx.execute([shtk_path, "version"])
    if result.return_code != 0:
        fail("Failed to query shtk version; stdout: {}; stderr: {}".format(
            result.stdout,
            result.stderr,
        ))
    version = result.stdout.rstrip().split(" ")[1]

    if versions.lt(version, repository_ctx.attr.min_version):
        fail("Repository requires shtk >= {} but {} provides {}".format(
            repository_ctx.attr.min_version,
            shtk_path,
            version,
        ))

    repository_ctx.template(
        "BUILD.bazel",
        repository_ctx.path(Label("@rules_shtk//:toolchain.BUILD.tpl")),
        {
            "%{shtk_path}": shtk_path,
            "%{version}": version,
        },
    )

_shtk_autoconf_toolchain = repository_rule(
    implementation = _shtk_autoconf_toolchain_impl,
    attrs = {
        "shtk_path": attr.string(
            doc = "Path to the shtk(1) binary if a specific one is desired.",
        ),
        "min_version": attr.string(
            doc = "Minimum version of shtk(1) needed.",
        ),
    },
    configure = True,
)

def shtk_system(min_version = SHTK_VERSION):
    """Discovers and registers the system-installed shtk toolchain.

    This causes Bazel to look for shtk(1) in the path and makes it available
    for use.

    Given that the toolchain is provided by the system, any scripts built by
    Bazel using this toolchain can be copied out of bazel-bin and placed
    elsewhere.

    Args:
        min_version: The minimum version of shtk that we expect.  If the
            detected version is too old, this rule fails.
    """
    _shtk_autoconf_toolchain(name = "shtk_autoconf", min_version = min_version)
    native.register_toolchains("@shtk_autoconf//:toolchain")

def _shtk_dist_toolchain_impl(repository_ctx):
    version = repository_ctx.attr.version
    url = "https://github.com/jmmv/shtk/releases/download/shtk-{}/shtk-{}.tar.gz".format(version, version)

    repository_ctx.download_and_extract(
        url,
        "shtk.tar.gz",
        sha256 = repository_ctx.attr.sha256,
    )

    result = repository_ctx.execute(
        [
            repository_ctx.which("sh"),
            "-c",
            "prefix=\"$(pwd)/local\" && cd {} && ./configure --prefix \"${{prefix}}\" && make install".format(
                str(repository_ctx.path("shtk.tar.gz/shtk-" + version)),
            ),
        ],
    )
    if result.return_code != 0:
        fail("build failed: " + result.stdout + result.stderr)

    repository_ctx.template(
        "BUILD.bazel",
        repository_ctx.path(Label("@rules_shtk//:toolchain.BUILD.tpl")),
        {
            "%{shtk_path}": str(repository_ctx.path("local")) + "/bin/shtk",
            "%{version}": version,
        },
    )

_shtk_dist_toolchain = repository_rule(
    implementation = _shtk_dist_toolchain_impl,
    attrs = {
        "version": attr.string(),
        "sha256": attr.string(),
    },
)

def shtk_dist():
    """Registers a released shtk toolchain.

    This will cause Bazel to download the shtk version that corresponds to these
    rules (rules_shtk 1.7.0 pull shtk 1.7), build this toolchain, and make it
    available for use.

    The toolchain is built under Bazel's external hierarchy and is ephemeral.
    Therefore, you should not copy scripts built with this toolchain out of the
    bazel-bin directory because they will not work correctly.
    """
    repository = "shtk_dist_" + versions.canonicalize(SHTK_VERSION)
    _shtk_dist_toolchain(name = repository, version = SHTK_VERSION, sha256 = SHTK_SHA256)
    native.register_toolchains("@{}//:toolchain".format(repository))
