# rules_shtk: Bazel rules for shtk

This directory contains Bazel rules to build shtk scripts and run shtk tests
from Bazel.

You can find examples under [bazel_examples](../bazel_examples/).

## Set up

To get started, add the following entry to your `MODULE.bazel`:

```python
bazel_dep(name = "rules_shtk", version = "1.7.0")
```

Then, update your `WORKSPACE.bazel` file to load one or more shtk toolchains.
You can choose between:

*   `shtk_dist`, which downloads the version of shtk corresponding to the
    rules and builds it.  This is typically what you will want to use,
    especially if all you care about is building tests.

    ```python
    load("@rules_shtk//:repositories.bzl", "shtk_dist")

    # Use the shtk release that matches these rules (if these rules are version
    # 1.7.0, then this uses shtk 1.7).
    shtk_dist()
    ```

*   `shtk_system`, which discovers an shtk toolchain installed on the
    system.  Use this if you will want to install the built scripts.

    ```python
    load("@rules_shtk//:repositories.bzl", "shtk_system")

    # Auto-discover the system-provided shtk by looking for shtk(1) in the PATH.
    shtk_system()

    # Auto-discover the system-provided shtk by looking for shtk(1) in the PATH
    # but ensure that it provides a minimum shtk version.
    shtk_system(min_version = "1.7")

    # Load a system-provided shtk from the given location.
    shtk_system(shtk_path = "/usr/local/bin/shtk")
    ```

## Usage

Define binaries like this:

```python
load("@rules_shtk//:rules.bzl", "shtk_binary")

shtk_binary(
    name = "hello",
    src = "hello.sh",
)
```

And tests like this:

```python
load("@rules_shtk//:rules.bzl", "shtk_test")

shtk_test(
    name = "hello_test",
    src = "hello_test.sh",
    data = [":hello"],
)
```
