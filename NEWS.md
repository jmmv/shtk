Major changes between releases
==============================


Changes in version 1.8
----------------------

**STILL UNDER DEVELOPMENT; NOT RELEASED YET.**

* No changes recorded.


Changes in version 1.7
----------------------

**Released on 2017-02-17.**

* This is the first release with fixes for and confirmed to work with all
  of bash, dash, pdksh, and zsh.  We now have continuous integration runs
  for all these interpreters to ensure that this holds true in future
  releases.

* Added the `shtk_abort` function to terminate a script on fatal internal
  errors.

* Added the `shtk_cli_debug` function to log debug-level messages.

* Added the `shtk_cli_log_level` and `shtk_cli_set_log_level` functions to
  query and set the maximum log level.

* Added the `shtk_fs` module with the `shtk_fs_join_paths` and
  `shtk_fs_normalize_path` functions.

* Added the `shtk_hw` module with the `shtk_hw_ncpus` function.

* Fixed option parsing to detect missing arguments to options.

* Fixed pattern matching in `shtk_list_filter` so that it supports
  alternative branches.


Changes in version 1.6
----------------------

**Released on 2014-11-17.**

* Added the `unittest` module, a framework with which to implement robust
  test programs purely in shell.  This new module supports defining test
  programs as a collection of standalone test cases or test fixtures;
  supports assert-syle vs. expect-style checks; and provides advanced
  checks to simplify the implementation of tests cases for command-line
  utilities.  `unittest`-based test programs can be trivially plugged into
  the Kyua testing framework.

* Added manual pages for all public API functions.  See `shtk(3)` for an
  introduction and follow all linked pages for details.  All docstrings
  have been removed from the code in favor of the manual pages.

* Added the `shtk_config_include` function so that configuration files can
  source other files using relative (or absolute) paths.

* Removed `set -e` calls from shtk and from any generated scripts.  It is
  the user who should be enabling this feature if he chooses to because
  `set -e` may have suprising and inconsistent behavior in large scripts
  (and shtk can be defined as large).


Changes in version 1.5
----------------------

**Released on 2014-03-16.**

* Added a version module with helper functions to check if shtk is a given
  version or matches some constraints.  Useful to dynamically determine
  which functions to call in a script, if their need is optional.

* Added timeout support to `shtk_process_run`.  The new `-t` option to this
  function takes the number of seconds before forcibly killing the
  subprocess.


Changes in version 1.4
----------------------

**Released on 2013-12-30.**

* Added support for a user-defined `SHTK_MODULESPATH` variable.  This
  colon-separated, user-tunable variable lists the directories that contain
  modules.

* Added a `modulesdir` variable to `shtk.pc` so that third-party packages
  can install shtk-compliant modules into the shared directory.  This
  variable is also exposed by the `SHTK_CHECK` macro of `shtk.m4` as
  `SHTK_MODULESDIR`.

* Added a new `bool` module with a `shtk_bool_check` function to convert a
  string to a boolean.

* Added a new `cleanup` module to simplify the installation and automatic
  execution of termination handlers.

* Fixed the `config` module in Mac OS X 10.9 to respect default values of
  configuration variables.


Changes in version 1.3
----------------------

**Released on 2013-07-28.**

* Sources migrated to a GitHub project from the previous copy in the pkgsrc
  repository.  shtk is now a first-class package and includes a traditional
  build system based on Automake and Autoconf and also provides a
  pkg-config file and Autoconf macros to ease the integration with other
  packages.


Changes in version 1.2
----------------------

**Released on 2013-06-18.**

* Properly propagate errors returned by `cvs checkout` and `cvs update`.
  Problem reported by Nathan Arthur in private mail.


Changes in version 1.1
----------------------

**Released on 2013-03-08.**

* Added the `shtk_config_run_hook` function to invoke a hook in the context
  of a configuration file.


Changes in version 1.0
----------------------

**Released on 2012-08-15.**

* This is the first release of the shtk package.  The sources were located
  in the pkgsrc repository and shtk was only available as a pkgsrc package.
