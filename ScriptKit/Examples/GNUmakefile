
include ../config.mak
GUILE_MAKE_LOADED = yes

include $(GNUSTEP_MAKEFILES)/common.make

TEST_TOOL_NAME = hello helloX helloY \
                 guilev guiled guilescm guilescm2 guile_proc guile_inv \
                 exception

hello_OBJC_FILES = hello.m
helloX_OBJC_FILES = helloX.m
helloY_OBJC_FILES = helloY.m
guilev_OBJC_FILES = guilev.m
guiled_OBJC_FILES = guiled.m
guilescm_OBJC_FILES = guilescm.m
exception_OBJC_FILES = exception.m
guile_proc_OBJC_FILES = guile_proc.m
guile_inv_OBJC_FILES = guile_inv.m
guilescm2_OBJC_FILES = guilescm2.m

-include Makefile.preamble

include $(GNUSTEP_MAKEFILES)/test-tool.make

-include Makefile.postamble
