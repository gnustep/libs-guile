GNUSTEP_INSTALLATION_DIR = $(GNUSTEP_SYSTEM_ROOT)

include $(GNUSTEP_MAKEFILES)/common.make

PACKAGE_NAME = gnustep-guile
include Version

RPM_DISABLE_RELOCATABLE=YES
PACKAGE_NEEDS_CONFIGURE=YES
CVS_MODULE_NAME = guile

# 
# Pass it down to Greg
#
export INSTALL_ROOT_DIR

#
# The list of subproject directories
#
SUBPROJECTS = Greg Library Tools Test ScriptKit

-include GNUmakefile.preamble

-include GNUmakefile.local

include $(GNUSTEP_MAKEFILES)/aggregate.make

-include GNUmakefile.postamble

# Compatibility with gnustep-make <= 1.2.0
ifeq ($(MKINSTALLDIRS),)
 MKINSTALLDIRS = $(MKDIRS)
endif

after-distclean::
	rm -f config.status config.log config.cache TAGS

before-install::
	$(MKINSTALLDIRS) $(INSTALL_ROOT_DIR)$(GNUSTEP_MAKEFILES)/Additional
	$(INSTALL_DATA) guile.make \
	  $(INSTALL_ROOT_DIR)$(GNUSTEP_MAKEFILES)/Additional

config.status:
	./configure

before-all:: config.status
