
GNUSTEP_INSTALLATION_DIR = $(GNUSTEP_SYSTEM_ROOT)

# Load our own local GUILE flags, then set GUILE_MAKE_LOADED to yes in
# order to prevent the xxx/System/Makefiles/Additional/guile.make from
# being loaded, as it defines some flags which conflict with our own,
# defined in ../config.mak.  We should really be loading the local
# guile.make here, but we can't do that without having ScriptKit
# depend on the top-level configure (maybe we shouldn't care about
# that), which is why this trick is used.
include ../config.mak
GUILE_MAKE_LOADED = yes

include $(GNUSTEP_SYSTEM_ROOT)/Makefiles/common.make

LIBRARY_NAME = libScriptKit
TEST_TOOL_NAME = test_skit

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

libScriptKit_DLL_DEF=libScriptKit.def

include Makefile.preamble

include $(GNUSTEP_SYSTEM_ROOT)/Makefiles/library.make
include $(GNUSTEP_SYSTEM_ROOT)/Makefiles/test-tool.make

include Makefile.postamble
