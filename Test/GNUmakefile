GNUSTEP_INSTALLATION_DIR = $(GNUSTEP_SYSTEM_ROOT)

GNUSTEP_LOCAL_ADDITIONAL_MAKEFILES = ../guile.make
include ../AppKit.make

include $(GNUSTEP_MAKEFILES)/common.make

# The application to be compiled
ifneq ($(HAVE_APPKIT),no)
  ifneq (yes,no)
    APP_NAME = gui
    gui_OBJC_FILES = gui.m
  endif
endif

#The tool to be compiled
TOOL_NAME = go

go_OBJC_FILES = go.m

-include Makefile.preamble

-include GNUmakefile.local

include $(GNUSTEP_MAKEFILES)/tool.make
ifneq ($(HAVE_APPKIT),no)
  include $(GNUSTEP_MAKEFILES)/application.make
endif
-include Makefile.postamble
