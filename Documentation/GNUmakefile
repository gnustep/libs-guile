
GNUSTEP_MAKEFILES = $(GNUSTEP_SYSTEM_ROOT)/Makefiles

include $(GNUSTEP_MAKEFILES)/common.make

include ../Version

# The application to be compiled
DOCUMENT_NAME = gstep_guile

DOCUMENT_TEXT_NAME = README NEWS INSTALL

# The texinfo source files to be used
gstep_guile_TEXI_FILES = install.texi news.texi gstep_guile.texi

README_TEXI_FILES = version.texi
README_TEXT_MAIN = readme.texi

INSTALL_TEXT_MAIN = install.texi
INSTALL_TEXI_FILES = version.texi

NEWS_TEXT_MAIN = news.texi
NEWS_TEXI_FILES = version.texi

-include Makefile.preamble

-include GNUmakefile.local

include $(GNUSTEP_MAKEFILES)/documentation.make

-include Makefile.postamble
