GNUSTEP_INSTALLATION_DIR = $(GNUSTEP_SYSTEM_ROOT)

GNUSTEP_LOCAL_ADDITIONAL_MAKEFILES = ../guile.make
include ../AppKit.make

include $(GNUSTEP_MAKEFILES)/common.make

TOOL_NAME = guile-base
guile-base_OBJC_FILES = guile-base.m

ifneq ($(HAVE_APPKIT),no)
  APP_NAME = guile-gui
  guile-gui_OBJC_FILES = guile-gui.m
endif

include Makefile.preamble

include $(GNUSTEP_SYSTEM_ROOT)/Makefiles/tool.make

ifneq ($(HAVE_APPKIT),no)
  include $(GNUSTEP_SYSTEM_ROOT)/Makefiles/application.make
endif

