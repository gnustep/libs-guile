GNUSTEP_LOCAL_ADDITIONAL_MAKEFILES = ../guile.make
include ../AppKit.make
include ../EOF.make

include $(GNUSTEP_MAKEFILES)/common.make

TOOL_NAME = guile-base
guile-base_OBJC_FILES = guile-base.m

ifneq ($(HAVE_APPKIT),no)
  APP_NAME = guile-gui
  guile-gui_OBJC_FILES = guile-gui.m
endif

ifneq ($(HAVE_EOF),no)
  TOOL_NAME += guile-gdl2
  guile-gdl2_OBJC_FILES = guile-gdl2.m
endif

include Makefile.preamble

include $(GNUSTEP_MAKEFILES)/tool.make

ifneq ($(HAVE_APPKIT),no)
  include $(GNUSTEP_MAKEFILES)/application.make
endif

