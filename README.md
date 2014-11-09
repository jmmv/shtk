# The Shell Toolkit

The Shell Toolkit, or `shtk` for short, is an **application toolkit**
for programmers writing POSIX-compliant shell scripts.

`shtk` provides a **collection of reusable modules** that work on a wide
variety of operating systems and shell interpreters.  These modules are
all ready to be used by calling the provided `shtk_import` primitive and
"compiling" the shell scripts into their final form using the `shtk(1)`
utility.

`shtk` is purely written in the shell scripting language so there are
**no dependencies** to be installed.

## Download

The latest version of `shtk` is 1.5 and was released on March 16th, 2014.

Download: [sthk-1.5](../../releases/tag/shtk-1.5).

## Installation

You are encouraged to install binary packages for your operating system
wherever available:

* FreeBSD 10.0 and above: install the `shtk` package with `pkg install
  shtk`.

* NetBSD with pkgsrc: install the `pkgsrc/devel/shtk` package.

Should you want to build and install `shtk` from the source tree provided
in this repository, follow the instructions in the
[INSTALL file](INSTALL).

## Documentation

`shtk` is fully documented in manual pages, all of which are stored in the
[`man`](man) subdirectory.  Once you have built and installed `shtk`,
simply type `man 1 shtk` to open the manual page for the `shtk`
command-line utility and type `man 3 shtk` to open the introductory page to
the API reference manual.  The `SEE ALSO` sections will guide you through
the rest of the documentation.

As a quick introduction, here are the modules supplied by `shtk`:

* `bool`: Utilities to manipulate boolean values.
* `cleanup`: Utilities to install "at-exit" handlers.
* `cli`: Utilities to implement clean and consistent command-line
  interfaces, including logging primitives.
* `config`: Configuration file parser.
* `cvs`: Utilities to interact with the CVS version control system.
* `list`: Utilities to manipulate lists represented as a collection of
  arguments.
* `process`: Utilities to execute external processes.
* `unittest`: Framework to implement unit- and integration-test test
  programs.
* `version`: Utilities to check the in-use version of `shtk`.

## Support

Please use the
[shtk-discuss mailing list](https://groups.google.com/forum/#!forum/shtk-discuss)
for any support inquiries.
