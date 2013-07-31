# Sources for openvas-security-scanner

module_DATA = \
  modules/OpenvasSecurityScanner.rb

client_DATA = \
  clients/openvas-security-scanner.rb

yncludedir = @yncludedir@/openvas-security-scanner
ynclude_DATA = \
  include/openvas-security-scanner/wizards.rb \
  include/openvas-security-scanner/dialogs.rb \
  include/openvas-security-scanner/complex.rb \
  include/openvas-security-scanner/helps.rb

scrconf_DATA = \
  scrconf/openvas-security-scanner.scr

desktop_DATA = \
  desktop/openvas-security-scanner.desktop

EXTRA_DIST = $(module_DATA) $(client_DATA) $(ynclude_DATA) $(scrconf_DATA) $(desktop_DATA)

include $(top_srcdir)/Makefile.am.common