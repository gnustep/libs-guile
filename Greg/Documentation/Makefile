
#
#  Makefile for Greg documentation.
#  
#  Copyright (C) 1998 Free Software Foundation, Inc.
#
#  Written by:	Richard Frith-Macdonald <richard@brainstorm.co.uk>
#
#  This file is part of the GNUstep Base Library.
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Library General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the GNU
#  Library General Public License for more details.
#
#  You should have received a copy of the GNU Library General Public
#  License along with this library; if not, write to the Free
#  Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#

all:	info html dvi

gregdoc.texi:	gregdoc
	sed -e 's,@email{\([^}]*\)},<\1>,g' gregdoc \
        | sed -e 's#@uref{\([^,}]*,\)\([^}]*\)}#@emph{\2}#g' \
        | sed -e 's,@uref{\([^}]*\)},@emph{\1},g' \
        | sed -e 's,@url{\([^}]*\)},@emph{\1},g' > gregdoc.texi

dvi:	gregdoc.texi
	texi2dvi gregdoc.texi

html:	gregdoc
	texi2html -split_chapter -expandinfo gregdoc

info:	gregdoc
	makeinfo -D NO-TEXI2HTML -o gregdoc.info gregdoc


clean:
	rm -f gregdoc.aux gregdoc.cp gregdoc.cps gregdoc.dvi \
	gregdoc.fn gregdoc.ky gregdoc.log gregdoc.pg \
	gregdoc.texi gregdoc.toc gregdoc.tp gregdoc.vr

distclean:	clean

reallyclean:	distclean
	rm -f gregdoc *.html

