#
#  Main Makefile for Greg (GNUstep REGrestation testing framework in Guile)
#  
#  Copyright (C) 1998, 2001 Free Software Foundation, Inc.
#
#  Written by:	Richard Frith-Macdonald <rfm@gnu.org>
#  Modified by: Nicola Pero <n.pero@mi.flashnet.it>
#
#  This file is part of Greg (part of the GNUstep project)
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2.1 of the License, or (at your option) any later version.
#  
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#  
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#


#
#  Greg MUST be installed before use so that Guile can load the modules from
#  it's standard locations.
#
all: config.status library documentation
	@echo "You must now install Greg in order to use it"

config.status:
	./configure
	$(MAKE) clean

library: 
	(cd Library; $(MAKE));

test:
	(cd Test; $(MAKE) check);

check:
	(cd Test; $(MAKE) check);

documentation:
	(cd Documentation; $(MAKE))

install: all
	(cd Library; $(MAKE) install); \
	(cd Documentation; $(MAKE) install);

#
# The clean and distclean targets have `-' because if `make distclean'
# has been run in a subdirectory, then it is possible that not even the 
# makefile will be found in that subdirectory.  We interpret the fact 
# the makefile is not there as meaning the directory is already distclean.
#
clean:
	-(cd Library; $(MAKE) clean)
	-(cd Test; $(MAKE) clean)
	-(cd Documentation; $(MAKE) clean)

distclean:
	rm -f config.cache config.log config.status config.mak \
	      Documentation/gregdoc.texi;
	-(cd Library; $(MAKE) distclean); 
	-(cd Test; $(MAKE) distclean); 
	-(cd Documentation; $(MAKE) distclean)

distrib:
	( \
	autoconf; \
	./configure; \
	(cd Documentation; $(MAKE)); \
	rm -f config.cache config.log config.status config.mak; \
	(cd Library; $(MAKE) distclean); \
	(cd Test; $(MAKE) distclean); \
	(cd Documentation; $(MAKE) distclean); \
	. GREG-VERSION; \
	mkdir /tmp/greg-$$VERSION; \
	tar -cf - . | (cd /tmp/greg-$$VERSION; tar -xf -); \
	cd /tmp; \
	rm -rf greg-$$VERSION/CVS greg-$$VERSION/*/CVS; \
	tar -cf greg-$$VERSION.tar greg-$$VERSION; \
	gzip greg-$$VERSION.tar; \
	rm -rf /tmp/greg-$$VERSION; \
	)
