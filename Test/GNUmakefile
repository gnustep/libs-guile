include $(GNUSTEP_SYSTEM_ROOT)/Makefiles/common.make

# The application to be compiled
ifneq ($(GUI_LIB),nil)
  APP_NAME = gui
  gui_OBJC_FILES = gui.m
endif

#The tool to be compiled
TOOL_NAME = go

go_OBJC_FILES = go.m

-include Makefile.preamble

include $(GNUSTEP_SYSTEM_ROOT)/Makefiles/tool.make
ifneq ($(GUI_LIB),nil)
include $(GNUSTEP_SYSTEM_ROOT)/Makefiles/application.make
endif
-include Makefile.postamble
