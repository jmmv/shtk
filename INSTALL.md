Installation instructions
=========================

shtk uses the GNU Automake and GNU Autoconf utilities as its build system.
These are used only when building the package from the source code tree.
If you want to install shtk from a prebuilt package provided by your
operating system, you do not need to read this document.

For the impatient:

    $ ./configure
    $ make
    $ make check
    Gain root privileges
    # make install
    Drop root privileges
    $ make installcheck

Or alternatively, install as a regular user into your home directory:

    $ ./configure --prefix ~/local
    $ make
    $ make check
    $ make install
    $ make installcheck


Dependencies
------------

To build and use shtk successfully you need:

* A POSIX-compliant shell.  Any of bash, dash, pdksh and zsh are known to
  be supported.  Old and broken shells are explicitly not supported.

Optionally, if you want to build and run the tests (recommended), you need:

* pkg-config.
* Kyua 0.6 or greater.

If you are building shtk from the code on the repository, you will also
need the following tools:

* GNU Autoconf.
* GNU Automake.


Regenerating the build system
-----------------------------

This is not necessary if you are building from a formal release
distribution file.

On the other hand, if you are building shtk from code extracted from the
repository, you must first regenerate the files used by the build system.
You will also need to do this if you modify `configure.ac`, `Makefile.am`
or any of the other build system files.  To do this, simply run:

    $ autoreconf -i -s


General build procedure
-----------------------

To build and install the source package, you must follow these steps:

1. Configure the sources to adapt to your operating system.  This is done
   using the `configure` script located on the sources' top directory, and
   it is usually invoked without arguments unless you want to change the
   installation prefix.  More details on this procedure are given on a
   later section.

2. Build the sources to generate the binaries and scripts.  Simply run
   `make` on the sources' top directory after configuring them.  No
   problems should arise.

3. Install the library by running `make install'` You may need to become
   root to issue this step.

4. Issue any manual installation steps that may be required.  These are
   described later in their own section.

5. Check that the installed library works by running `make installcheck`.
   You do not need to be root to do this.


Configuration flags
-------------------

The most common, standard flags given to `configure` are:

* `--prefix=directory`:
  **Possible values:** Any path.
  **Default:** `/usr/local`.

  Specifies where the library (scripts and all associated files) will be
  installed.

* `--help`:

  Shows information about all available flags and exits immediately,
  without running any configuration tasks.

The following environment variables are specific to shtk's `configure`
script:

* `SHTK_SHELL`:
  **Possible values:** absolute path to a shell interpreter.
  **Default:** autodetected; typically `bash` or `sh`.

  Specifies the absolute path to the shell interpreter to be used by shtk.


Run the tests!
--------------

Lastly, after a successful installation (and assuming you have Kyua
installed in your system), you should periodically run the tests from the
final location to ensure things remain stable.  Do so as follows:

    $ kyua test -k /usr/local/tests/shtk/Kyuafile

And if you see any tests fail, do not hesitate to report them in:

    https://github.com/jmmv/shtk/issues/

Thank you!
