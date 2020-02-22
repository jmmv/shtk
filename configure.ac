dnl Copyright 2013 Google Inc.
dnl All rights reserved.
dnl
dnl Redistribution and use in source and binary forms, with or without
dnl modification, are permitted provided that the following conditions are
dnl met:
dnl
dnl * Redistributions of source code must retain the above copyright
dnl   notice, this list of conditions and the following disclaimer.
dnl * Redistributions in binary form must reproduce the above copyright
dnl   notice, this list of conditions and the following disclaimer in the
dnl   documentation and/or other materials provided with the distribution.
dnl * Neither the name of Google Inc. nor the names of its contributors
dnl   may be used to endorse or promote products derived from this software
dnl   without specific prior written permission.
dnl
dnl THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
dnl "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
dnl LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
dnl A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
dnl OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
dnl SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
dnl LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
dnl DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
dnl THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
dnl (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
dnl OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

AC_INIT([Shell Toolkit], [1.7.1],
        [https://github.com/jmmv/shtk/issues/], [shtk], [])
AC_PREREQ([2.65])


AC_COPYRIGHT([Copyright 2013 Google Inc.])
AC_CONFIG_AUX_DIR([admin])
AC_CONFIG_FILES([Makefile])
AC_CONFIG_SRCDIR([shtk.sh])


AM_INIT_AUTOMAKE([1.9 foreign subdir-objects -Wall])


AC_PROG_LN_S


AC_ARG_VAR([SHTK_SHELL], [Location of the POSIX shell interpreter to use])
if test "${SHTK_SHELL}" = ""; then
    AC_PATH_PROGS(SHTK_SHELL, [bash sh])
else
    case ${SHTK_SHELL} in
    /*)
        ;;
    *)
        AC_MSG_ERROR([SHTK_SHELL must hold an absolute path])
        ;;
    esac
fi
if test "${SHTK_SHELL}" = ""; then
    AC_MSG_ERROR([No POSIX shell interpreter found; maybe set SHTK_SHELL?])
fi
AC_MSG_NOTICE([Using shell interpreter ${SHTK_SHELL}])


AC_PATH_PROG([KYUA], [kyua])
AM_CONDITIONAL([HAVE_KYUA], [test -n "${KYUA}"])


AC_SUBST(aclocaldir, \${datadir}/aclocal)
AC_SUBST(pkgconfigdir, \${libdir}/pkgconfig)
AC_SUBST(pkgtestsdir, \${testsdir}/shtk)
AC_SUBST(testsdir, \${exec_prefix}/tests)


AC_OUTPUT
