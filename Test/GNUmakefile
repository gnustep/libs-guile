GNUSTEP_LOCAL_ADDITIONAL_MAKEFILES = ../guile.make
include ../AppKit.make
include ../EOF.make

include $(GNUSTEP_MAKEFILES)/common.make

# The application to be compiled
ifneq ($(strip $(HAVE_APPKIT)),no)
  APP_NAME = gui
  gui_OBJC_FILES = gui.m
endif

#The tools to be compiled
TOOL_NAME = go
ifneq ($(strip $(HAVE_EOF)),no)
  TOOL_NAME += gdl2
  gdl2_OBJC_FILES = gdl2.m
endif

go_OBJC_FILES = go.m

-include Makefile.preamble

-include GNUmakefile.local

include $(GNUSTEP_MAKEFILES)/tool.make
ifneq ($(HAVE_APPKIT),no)
  include $(GNUSTEP_MAKEFILES)/application.make
endif
-include Makefile.postamble
