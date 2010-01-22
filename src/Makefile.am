# Makefile.am for openvas-security-scanner/src

yncludedir = @yncludedir@/openvas-security-scanner

client_DATA =			\
	openvas-security-scanner.ycp

ynclude_DATA =			\
	helps.ycp		\
	wizards.ycp		\
	dialogs.ycp		\
	complex.ycp

desktop_DATA =			\
	openvas-security-scanner.desktop

module_DATA =			\
	OpenvasSecurityScanner.ycp

# create a symlink for local build, #145327
openvas-security-scanner:
	ln -sf . $@
ycpchook = openvas-security-scanner

EXTRA_DIST = $(client_DATA) $(ynclude_DATA) $(module_DATA) $(desktop_DATA)

include $(top_srcdir)/Makefile.am.common
