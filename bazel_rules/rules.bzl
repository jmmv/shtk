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

load(":versions.bzl", "versions")

def _shtk_build(ctx, mnemonic, main):
    src = ctx.attr.src[DefaultInfo].files.to_list()[0]
    out = ctx.actions.declare_file(ctx.attr.name)
    info = ctx.toolchains["//:toolchain_type"].shtkinfo

    ctx.actions.run(
        mnemonic = mnemonic,
        executable = info.path,
        arguments = ["build", "-m", main, "-o", out.path, src.short_path],
        inputs = [src],
        outputs = [out],
    )

    return out

def _shtk_binary_impl(ctx):
    out = _shtk_build(ctx, "ShtkBinary", "main")

    return [DefaultInfo(
        files = depset([out]),
        executable = out,
    )]

shtk_binary = rule(
    doc = """
Rule for creating an shtk binary.

The binaries created by this rule are runnable with "bazel run" as usual.
However, whether the binaries can be copied out of bazel-bin for installation
onto the system or not depends on the toolchain that was used to build them.

The input file to this rule should not be executable and should not carry
a shebang header.
""",
    implementation = _shtk_binary_impl,
    attrs = {
        "src": attr.label(
            doc = "Source file to \"compile\" with shtk.",
            mandatory = True,
            allow_single_file = True,
        ),
    },
    executable = True,
    toolchains = ["//:toolchain_type"],
)

def _shtk_test_impl(ctx):
    out = _shtk_build(ctx, "ShtkTest", "shtk_unittest_main")

    runfiles = ctx.runfiles(files = ctx.files.data)
    transitive_runfiles = []
    for target in ctx.attr.data:
        transitive_runfiles.append(target[DefaultInfo].default_runfiles)
    runfiles = runfiles.merge_all(transitive_runfiles)

    return [
        DefaultInfo(
            files = depset([out]),
            runfiles = runfiles,
            executable = out,
        ),
        RunEnvironmentInfo(
            environment = ctx.attr.env,
            inherited_environment = ctx.attr.env_inherit,
        ),
    ]

shtk_test = rule(
    doc = """
Rule for creating an shtk test.

The input file to this rule should not be executable and should not carry
a shebang header.
""",
    implementation = _shtk_test_impl,
    attrs = {
        "src": attr.label(
            doc = "Source file of the test.",
            mandatory = True,
            allow_single_file = True,
        ),
        "data": attr.label_list(
            doc = "Data files to place in the runfiles tree.",
            allow_files = True,
        ),
        "env": attr.string_dict(
            doc = "Environment variable name/value pairs to pass to the test.",
        ),
        "env_inherit": attr.string_list(
            doc = "Environment variables to inherit in the test.",
        ),
    },
    toolchains = ["//:toolchain_type"],
    test = True,
)
