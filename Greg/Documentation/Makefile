

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
	makeinfo -D NO-TEXI2HTML --no-header -o gregdoc.info gregdoc


clean:
	rm -f gregdoc.aux gregdoc.cp gregdoc.cps gregdoc.dvi \
	gregdoc.fn gregdoc.info gregdoc.ky gregdoc.log gregdoc.pg \
	gregdoc.texi gregdoc.toc gregdoc.tp gregdoc.vr

distclean:	clean

reallyclean:	distclean
	rm -f gregdoc *.html

