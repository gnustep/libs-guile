
all:
	#
	# Make sure you have run 'configure' before doing anything else.
	#
	# type '(cd Library; make)' to build Greg.
	# as root, type '(cd Library; make install)' to install Greg.
	# type '(cd Test; make)' to run some simple tests.
	# type '(cd Documentation; make)' to build the documentation.
	#

distclean:
	rm -f config.cache config.log config.status; \
	(cd Library; make distclean); \
	(cd Test; make distclean); \
	(cd Documentation; make distclean)

distrib:
	( \
	autoconf; \
	./configure; \
	(cd Documentation; make); \
	rm -f config.cache config.log config.status; \
	(cd Library; make distclean); \
	(cd Test; make distclean); \
	(cd Documentation; make distclean); \
	. GREG-VERSION; \
	mkdir /tmp/$$PACKAGE-$$VERSION; \
	tar -cf - . | (cd /tmp/$$PACKAGE-$$VERSION; tar -xf -); \
	cd /tmp; tar -cf $$PACKAGE-$$VERSION.tar $$PACKAGE-$$VERSION; \
	gzip $$PACKAGE-$$VERSION.tar; \
	rm -rf /tmp/$$PACKAGE-$$VERSION; \
	)
