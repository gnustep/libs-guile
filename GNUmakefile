GNUSTEP_INSTALLATION_DIR = $(GNUSTEP_SYSTEM_ROOT)

GNUSTEP_MAKEFILES = $(GNUSTEP_SYSTEM_ROOT)/Makefiles

include $(GNUSTEP_MAKEFILES)/common.make

PACKAGE_NAME=gnustep-guile
include Version

RPM_DISABLE_RELOCATABLE=YES
PACKAGE_NEEDS_CONFIGURE=YES

# 
# Pass it down to Greg
#
export INSTALL_ROOT_DIR

#
# The list of subproject directories
#
SUBPROJECTS = Library Greg Test ScriptKit 

-include GNUmakefile.preamble

-include GNUmakefile.local

include $(GNUSTEP_MAKEFILES)/aggregate.make

-include GNUmakefile.postamble

after-distclean::
	rm -f config.status config.log config.cache TAGS

# Things to do before installing
before-install::
	$(MKDIRS) $(INSTALL_ROOT_DIR)$(GNUSTEP_MAKEFILES)/Additional
	$(INSTALL_DATA) guile.make \
	  $(INSTALL_ROOT_DIR)$(GNUSTEP_MAKEFILES)/Additional

