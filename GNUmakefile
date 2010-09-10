
ifeq ($(GNUSTEP_MAKEFILES),)
 GNUSTEP_MAKEFILES := $(shell gnustep-config --variable=GNUSTEP_MAKEFILES 2>/dev/null)
  ifeq ($(GNUSTEP_MAKEFILES),)
    $(warning )
    $(warning Unable to obtain GNUSTEP_MAKEFILES setting from gnustep-config!)
    $(warning Perhaps gnustep-make is not properly installed,)
    $(warning so gnustep-config is not in your PATH.)
    $(warning )
    $(warning Your PATH is currently $(PATH))
    $(warning )
  endif
endif

ifeq ($(GNUSTEP_MAKEFILES),)
  $(error You need to set GNUSTEP_MAKEFILES before compiling!)
endif

include $(GNUSTEP_MAKEFILES)/common.make

PACKAGE_NAME = gnustep-guile
include Version

RPM_DISABLE_RELOCATABLE=YES
PACKAGE_NEEDS_CONFIGURE=YES
CVS_MODULE_NAME = guile


SUBPROJECTS = Library Tools Test ScriptKit

include $(GNUSTEP_MAKEFILES)/aggregate.make


# Compatibility with gnustep-make <= 1.2.0
ifeq ($(MKINSTALLDIRS),)
 MKINSTALLDIRS = $(MKDIRS)
endif

after-distclean::
	rm -f config.status config.log config.cache TAGS \
		AppKit.make EOF.make

before-install::
	$(MKINSTALLDIRS) $(DESTDIR)$(GNUSTEP_MAKEFILES)/Additional
	$(INSTALL_DATA) guile.make $(DESTDIR)$(GNUSTEP_MAKEFILES)/Additional

config.status:
	./configure

before-all:: config.status
