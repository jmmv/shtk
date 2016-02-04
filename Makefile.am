# Copyright 2013 Google Inc.
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

PHONY_TARGETS =

doc_DATA = AUTHORS COPYING NEWS README
noinst_DATA = INSTALL README
EXTRA_DIST = $(doc_DATA) INSTALL README man/README

dist_pkgdata_DATA  = base.subr
dist_pkgdata_DATA += bool.subr
dist_pkgdata_DATA += bootstrap.subr
dist_pkgdata_DATA += cleanup.subr
dist_pkgdata_DATA += cli.subr
dist_pkgdata_DATA += config.subr
dist_pkgdata_DATA += cvs.subr
dist_pkgdata_DATA += list.subr
dist_pkgdata_DATA += process.subr
dist_pkgdata_DATA += unittest.subr

unittest_pkgdatadir = $(pkgdatadir)/unittest
dist_unittest_pkgdata_DATA  = unittest/commands.subr
dist_unittest_pkgdata_DATA += unittest/files.subr
dist_unittest_pkgdata_DATA += unittest/operators.subr

pkgdata_DATA = version.subr
CLEANFILES = version.subr
EXTRA_DIST += version.subr.in
version.subr: $(srcdir)/version.subr.in
	$(AM_V_GEN)source=version.subr.in target=version.subr; $(BUILD_FILE)

BUILD_FILE = \
	mkdir -p "$$(dirname "$${target}")"; \
	sed -e 's,__SHTK_MODULESDIR__,$(pkgdatadir),g' \
	    -e 's,__SHTK_SHELL__,$(SHTK_SHELL),g' \
	    -e 's,__SHTK_TOOL__,$(exec_prefix)/bin/shtk,g' \
	    -e 's,__SHTK_VERSION__,$(PACKAGE_VERSION),g' \
	    <"$(srcdir)/$${source}" >"$${target}.tmp"; \
	mv "$${target}.tmp" "$${target}"
BUILD_SCRIPT = \
	$(BUILD_FILE); \
	chmod +x "$${target}"

bin_SCRIPTS = shtk
CLEANFILES += shtk
EXTRA_DIST += shtk.sh
shtk: $(srcdir)/shtk.sh
	$(AM_V_GEN)source=shtk.sh target=shtk; $(BUILD_SCRIPT)

man_MANS = man/shtk.1
CLEANFILES += man/shtk.1
EXTRA_DIST += man/shtk.1.in
man/shtk.1: $(srcdir)/man/shtk.1.in
	$(AM_V_GEN)target=man/shtk.1; source=$${target}.in; $(BUILD_FILE)

man_MANS += man/shtk_import.3
CLEANFILES += man/shtk_import.3
EXTRA_DIST += man/shtk_import.3.in
man/shtk_import.3: $(srcdir)/man/shtk_import.3.in
	$(AM_V_GEN)target=man/shtk_import.3; source=$${target}.in; \
	$(BUILD_FILE)

dist_man_MANS  = man/shtk.3
dist_man_MANS += man/shtk_bool.3
dist_man_MANS += man/shtk_bool_check.3
dist_man_MANS += man/shtk_cleanup.3
dist_man_MANS += man/shtk_cleanup_register.3
dist_man_MANS += man/shtk_cli.3
dist_man_MANS += man/shtk_cli_debug.3
dist_man_MANS += man/shtk_cli_dirname.3
dist_man_MANS += man/shtk_cli_error.3
dist_man_MANS += man/shtk_cli_info.3
dist_man_MANS += man/shtk_cli_log_level.3
dist_man_MANS += man/shtk_cli_progname.3
dist_man_MANS += man/shtk_cli_set_log_level.3
dist_man_MANS += man/shtk_cli_usage_error.3
dist_man_MANS += man/shtk_cli_warning.3
dist_man_MANS += man/shtk_config.3
dist_man_MANS += man/shtk_config_get.3
dist_man_MANS += man/shtk_config_get_bool.3
dist_man_MANS += man/shtk_config_get_default.3
dist_man_MANS += man/shtk_config_has.3
dist_man_MANS += man/shtk_config_include.3
dist_man_MANS += man/shtk_config_init.3
dist_man_MANS += man/shtk_config_load.3
dist_man_MANS += man/shtk_config_override.3
dist_man_MANS += man/shtk_config_run_hook.3
dist_man_MANS += man/shtk_config_set.3
dist_man_MANS += man/shtk_config_unset.3
dist_man_MANS += man/shtk_cvs.3
dist_man_MANS += man/shtk_cvs_checkout.3
dist_man_MANS += man/shtk_cvs_fetch.3
dist_man_MANS += man/shtk_cvs_update.3
dist_man_MANS += man/shtk_list.3
dist_man_MANS += man/shtk_list_contains.3
dist_man_MANS += man/shtk_list_filter.3
dist_man_MANS += man/shtk_process.3
dist_man_MANS += man/shtk_process_run.3
dist_man_MANS += man/shtk_unittest.3
dist_man_MANS += man/shtk_unittest_add_fixture.3
dist_man_MANS += man/shtk_unittest_add_test.3
dist_man_MANS += man/shtk_unittest_assert_command.3
dist_man_MANS += man/shtk_unittest_assert_equal.3
dist_man_MANS += man/shtk_unittest_assert_file.3
dist_man_MANS += man/shtk_unittest_assert_not_equal.3
dist_man_MANS += man/shtk_unittest_delayed_fail.3
dist_man_MANS += man/shtk_unittest_expect_command.3
dist_man_MANS += man/shtk_unittest_expect_equal.3
dist_man_MANS += man/shtk_unittest_expect_file.3
dist_man_MANS += man/shtk_unittest_expect_not_equal.3
dist_man_MANS += man/shtk_unittest_fail.3
dist_man_MANS += man/shtk_unittest_main.3
dist_man_MANS += man/shtk_unittest_set_expected_failure.3
dist_man_MANS += man/shtk_unittest_skip.3
dist_man_MANS += man/shtk_version.3
dist_man_MANS += man/shtk_version_at_least.3
dist_man_MANS += man/shtk_version_at_most.3
dist_man_MANS += man/shtk_version_is.3

aclocal_DATA = shtk.m4
EXTRA_DIST += shtk.m4

pkgconfig_DATA = shtk.pc
CLEANFILES += shtk.pc
EXTRA_DIST += shtk.pc.in
shtk.pc: $(srcdir)/shtk.pc.in Makefile
	$(AM_V_GEN)source=shtk.pc.in target=shtk.pc; $(BUILD_FILE)

dist_pkgtests_DATA = Kyuafile

unittest_testsdir = $(pkgtestsdir)/unittest
dist_unittest_tests_DATA = unittest/Kyuafile

BUILD_TEST = \
	$(mkdir_p) "$$(dirname $${name})"; \
	SHTK_MODULESDIR=$(abs_srcdir) SHTK_MODULESPATH=$(abs_builddir) \
	    $(builddir)/shtk build -m shtk_unittest_main -o "$${name}" \
	    "$(srcdir)/$${name}.sh"

pkgtests_SCRIPTS = base_test
CLEANFILES += base_test
EXTRA_DIST += base_test.sh
base_test: $(srcdir)/base_test.sh shtk
	$(AM_V_GEN)name=base_test; $(BUILD_TEST)

pkgtests_SCRIPTS += bool_test
CLEANFILES += bool_test
EXTRA_DIST += bool_test.sh
bool_test: $(srcdir)/bool_test.sh shtk
	$(AM_V_GEN)name=bool_test; $(BUILD_TEST)

pkgtests_SCRIPTS += cleanup_test
CLEANFILES += cleanup_test
EXTRA_DIST += cleanup_test.sh
cleanup_test: $(srcdir)/cleanup_test.sh shtk
	$(AM_V_GEN)name=cleanup_test; $(BUILD_TEST)

pkgtests_SCRIPTS += cli_test
CLEANFILES += cli_test
EXTRA_DIST += cli_test.sh
cli_test: $(srcdir)/cli_test.sh shtk
	$(AM_V_GEN)name=cli_test; $(BUILD_TEST)

pkgtests_SCRIPTS += config_test
CLEANFILES += config_test
EXTRA_DIST += config_test.sh
config_test: $(srcdir)/config_test.sh shtk
	$(AM_V_GEN)name=config_test; $(BUILD_TEST)

pkgtests_SCRIPTS += cvs_test
CLEANFILES += cvs_test
EXTRA_DIST += cvs_test.sh
cvs_test: $(srcdir)/cvs_test.sh shtk
	$(AM_V_GEN)name=cvs_test; $(BUILD_TEST)

pkgtests_SCRIPTS += list_test
CLEANFILES += list_test
EXTRA_DIST += list_test.sh
list_test: $(srcdir)/list_test.sh shtk
	$(AM_V_GEN)name=list_test; $(BUILD_TEST)

pkgtests_SCRIPTS += process_test
CLEANFILES += process_test
EXTRA_DIST += process_test.sh
process_test: $(srcdir)/process_test.sh shtk
	$(AM_V_GEN)name=process_test; $(BUILD_TEST)

pkgtests_SCRIPTS += shtk_test
CLEANFILES += shtk_test
EXTRA_DIST += shtk_test.sh
shtk_test: $(srcdir)/shtk_test.sh shtk
	$(AM_V_GEN)name=shtk_test; $(BUILD_TEST)

pkgtests_SCRIPTS += unittest_inttest
CLEANFILES += unittest_inttest
EXTRA_DIST += unittest_inttest.sh
unittest_inttest: $(srcdir)/unittest_inttest.sh
	$(AM_V_GEN)source=unittest_inttest.sh; target=unittest_inttest; \
	    $(BUILD_SCRIPT)

pkgtests_SCRIPTS += unittest_test
CLEANFILES += unittest_test
EXTRA_DIST += unittest_test.sh
unittest_test: $(srcdir)/unittest_test.sh shtk
	$(AM_V_GEN)name=unittest_test; $(BUILD_TEST)

unittest_tests_SCRIPTS = unittest/commands_test
CLEANFILES += unittest/commands_test
EXTRA_DIST += unittest/commands_test.sh
unittest/commands_test: $(srcdir)/unittest/commands_test.sh shtk
	$(AM_V_GEN)name=unittest/commands_test; $(BUILD_TEST)

unittest_tests_SCRIPTS += unittest/files_test
CLEANFILES += unittest/files_test
EXTRA_DIST += unittest/files_test.sh
unittest/files_test: $(srcdir)/unittest/files_test.sh shtk
	$(AM_V_GEN)name=unittest/files_test; $(BUILD_TEST)

unittest_tests_SCRIPTS += unittest/operators_test
CLEANFILES += unittest/operators_test
EXTRA_DIST += unittest/operators_test.sh
unittest/operators_test: $(srcdir)/unittest/operators_test.sh shtk
	$(AM_V_GEN)name=unittest/operators_test; $(BUILD_TEST)

pkgtests_SCRIPTS += version_test
CLEANFILES += version_test
EXTRA_DIST += version_test.sh
version_test: $(srcdir)/version_test.sh shtk
	$(AM_V_GEN)name=version_test; $(BUILD_TEST)

if HAVE_KYUA
CHECK_ENVIRONMENT  = PATH=$(abs_top_builddir):$${PATH}
CHECK_ENVIRONMENT += SHTK_MODULESDIR=$(abs_top_srcdir)
CHECK_ENVIRONMENT += SHTK_MODULESPATH=$(abs_top_builddir)
INSTALLCHECK_ENVIRONMENT  = PATH=$(prefix)/bin:$${PATH}
INSTALLCHECK_ENVIRONMENT += SHTK_MODULESPATH=

# Allow the caller to override the configuration file to passed to our
# test runs below.
KYUA_TEST_CONFIG_FILE = none

check-local: check-kyua
PHONY_TARGETS += check-kyua
check-kyua:
	@failed=no; \
	$(CHECK_ENVIRONMENT) $(TESTS_ENVIRONMENT) \
	    $(KYUA) --config='$(KYUA_TEST_CONFIG_FILE)' test \
	    --kyuafile='$(top_srcdir)/Kyuafile' --build-root='$(top_builddir)' \
	    || failed=yes; \
	if [ "$${failed}" = yes ]; then \
	    $(CHECK_ENVIRONMENT) $(KYUA) --config='$(KYUA_TEST_CONFIG_FILE)' \
	        report --results-file='$(abs_top_srcdir)' \
	        --verbose --results-filter=broken,failed; \
	    exit 1; \
	fi

installcheck-local: installcheck-kyua
PHONY_TARGETS += installcheck-kyua
installcheck-kyua:
	@failed=no; \
	cd $(pkgtestsdir) && $(INSTALLCHECK_ENVIRONMENT) $(TESTS_ENVIRONMENT) \
	    $(KYUA) --config='$(KYUA_TEST_CONFIG_FILE)' test || failed=yes; \
	if [ "$${failed}" = yes ]; then \
	    cd $(pkgtestsdir) && $(INSTALLCHECK_ENVIRONMENT) \
	        $(KYUA) --config='$(KYUA_TEST_CONFIG_FILE)' report \
	        --verbose --results-filter=broken,failed; \
	    exit 1; \
	fi
else  # HAVE_KYUA
PHONY_TARGETS += missing-kyua
missing-kyua:
	@echo "WARNING: kyua not found; no tests run"

check-local: missing-kyua
installcheck-local: missing-kyua
endif  # HAVE_KYUA

PHONY_TARGETS += clean-all
clean-all:
	GIT="$(GIT)" $(SH) $(srcdir)/admin/clean-all.sh

.PHONY: $(PHONY_TARGETS)
