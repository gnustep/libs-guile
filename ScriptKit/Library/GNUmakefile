-include ../config.mak

GNUSTEP_INSTALLATION_DIR = $(GNUSTEP_SYSTEM_ROOT)

include $(GNUSTEP_SYSTEM_ROOT)/Makefiles/common.make

# The library to be compiled
LIBRARY_NAME=libScriptKit
TEST_TOOL_NAME=test_skit

# The Objective-C source files to be compiled
libScriptKit_OBJC_FILES =  \
		GuileSCM.m \
		GuileProcedure.m \
		GuileInterpreter.m \
		GuileInvocation.m \
		GuileScript.m \
	 	SKInterpreter.m \
		SKScript.m

test_skit_OBJC_FILES = test_skit.m

libScriptKit_HEADER_FILES_DIR = .
libScriptKit_HEADER_FILES_INSTALL_DIR = /ScriptKit

libScriptKit_HEADER_FILES = \
		Guile.h \
		GuileInterpreter.h \
		GuileInvocation.h \
		GuileSCM.h \
		GuileProcedure.h \
		GuileScript.h \
		SKInterpreter.h \
		SKScript.h \
		ScriptKit.h

test_skit_HEADER_FILES_DIR = .

-include Makefile.preamble

include $(GNUSTEP_SYSTEM_ROOT)/Makefiles/library.make
include $(GNUSTEP_SYSTEM_ROOT)/Makefiles/test-tool.make

-include Makefile.postamble

# I need this.  test-tool.make bug?		eiichi
# internal-testtool-install::
