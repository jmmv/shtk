# rules_shtk: Examples of usage with Bazel

This directory contains examples on how to use the
[rules_shtk rules](../bazel_rules) with Bazel.

Each subdirectory contained here provides one specific example scenario.
They all share the same `WORKSPACE.bazel` from this directory though.

The examples are the following in order of "complexity":

*   `binary`: Simple usage of `shtk_binary`.
*   `test`: Simple usage of `shtk_test` to perform end-to-end testing of
    a binary written in C.
