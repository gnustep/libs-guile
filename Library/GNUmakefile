#
#   GNUmakefile
#
#   Main makefile for the GNUstep-Guile interface library
#
#   Copyright (C) 1998 Free Software Foundation, Inc.
#
#   Author:  Richard Frith-Macdonald <richard@brainstorm.co.uk>
#
#   This file is part of the GNUstep project.
#
#   This library is free software; you can redistribute it and/or
#   modify it under the terms of the GNU General Public License
#   as published by the Free Software Foundation; either version 2
#   of the License, or (at your option) any later version.
#
#   You should have received a copy of the GNU General Public
#   License along with this library; see the file COPYING.LIB.
#   If not, write to the Free Software Foundation,
#   59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

GNUSTEP_LOCAL_ADDITIONAL_MAKEFILES = ../guile.make
include ../AppKit.make
include ../EOF.make

include $(GNUSTEP_MAKEFILES)/common.make

include ../Version

LIBRARY_NAME = libgstep_guile libgg_base

libgg_base_OBJC_FILES = link_base.m

ifneq ($(strip $(HAVE_APPKIT)),no)
  LIBRARY_NAME += libgg_gui
  libgg_gui_OBJC_FILES = link_gui.m
endif

ifneq ($(strip $(HAVE_EOF)),no)
  LIBRARY_NAME += libgg_gdl2
  libgg_gdl2_OBJC_FILES = link_gdl2.m
endif

# The Objective-C source files to be compiled
libgstep_guile_OBJC_FILES =	gstep_guile.m \
				gg_Object.m \
				gg_NSObject.m \
				gg_class.m \
				gg_id.m \
				gg_protocol.m \
				gg_voidp.m \
				private.m

libgstep_guile_HEADER_FILES_DIR = .
libgstep_guile_HEADER_FILES_INSTALL_DIR = GNUstepGuile

libgstep_guile_HEADER_FILES = \
	gstep_guile.h gg_Object.h

SCHEME_FILES = \
	gstep-guile.scm

include Makefile.preamble

-include GNUmakefile.local

include $(GNUSTEP_MAKEFILES)/library.make

include Makefile.postamble

include CompatibilityHeaders.make

