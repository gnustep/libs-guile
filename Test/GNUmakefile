GNUSTEP_MAKEFILES = $(GNUSTEP_SYSTEM_ROOT)/Makefiles

include $(GNUSTEP_MAKEFILES)/common.make

# The application to be compiled
ifneq ($(GUI_LIB),nil)
  APP_NAME = gui
  gui_OBJC_FILES = gui.m
endif

#The tool to be compiled
TOOL_NAME = go

go_OBJC_FILES = go.m

-include Makefile.preamble

-include GNUmakefile.local

include $(GNUSTEP_MAKEFILES)/tool.make
ifneq ($(GUI_LIB),nil)
include $(GNUSTEP_MAKEFILES)/application.make
endif
-include Makefile.postamble
