
GNUSTEP_MAKEFILES = $(GNUSTEP_SYSTEM_ROOT)/Makefiles

include $(GNUSTEP_MAKEFILES)/common.make

#
# The list of subproject directories
#
SUBPROJECTS = Library Greg Test ScriptKit Documentation

-include GNUmakefile.preamble

-include GNUmakefile.local

include $(GNUSTEP_MAKEFILES)/aggregate.make

-include GNUmakefile.postamble

after-distclean::
	rm -f config.status config.log config.cache TAGS
