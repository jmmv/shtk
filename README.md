The Shell Toolkit
=================

The Shell Toolkit, or shtk for short, is an **application toolkit**
for programmers writing POSIX-compliant shell scripts.

shtk provides a **collection of reusable modules** that work on a wide
variety of operating systems and shell interpreters.  These modules are all
ready to be used by calling the provided `shtk_import` primitive and
"compiling" the shell scripts into their final form using the `shtk(1)`
utility.

shtk is purely written in the shell scripting language so there are **no
dependencies** to be installed.

shtk is **known to be compatible with at least bash, dash, pdksh and zsh**,
and continuous integration tests prove this to be the case.

shtk is licensed under a **[liberal BSD 3-clause license](LICENSE)**.


Download
--------

The latest version of shtk is 1.7 and was released on February 17th, 2017.

Download: [sthk-1.7](../../releases/tag/shtk-1.7).

See the [release notes](NEWS.md) for information about the changes in this
and all previous releases.


Installation
------------

You are encouraged to install binary packages for your operating system
wherever available:

* FreeBSD 10.0 and above: install the `shtk` package with `pkg install
  shtk`.

* NetBSD with pkgsrc: install the `pkgsrc/devel/shtk` package.

Should you want to build and install shtk from the source tree provided in
this repository, follow the instructions in the
[INSTALL.md file](INSTALL.md).


Documentation
-------------

shtk is fully documented in manual pages, all of which are stored in the
[`man`](man) subdirectory.  Once you have built and installed `shtk`,
simply type `man 1 shtk` to open the manual page for the `shtk`
command-line utility and type `man 3 shtk` to open the introductory page to
the API reference manual.  The `SEE ALSO` sections will guide you through
the rest of the documentation.

You can access pre-built versions of the documentation online by visiting:

> <https://shtk.jmmv.dev/>


Support
-------

Please use the
[shtk-discuss mailing list](https://groups.google.com/forum/#!forum/shtk-discuss)
for any support inquiries.
