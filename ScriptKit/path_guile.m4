dnl path_guile.m4
dnl
dnl Copyright (C) 1999 Free Software Foundation, Inc.
dnl Copyright (C) 1998 GYVE Development Team
dnl
dnl Author: Eiichi Takamori <taka@ma1.seikyou.ne.jp>
dnl
dnl This file is a spinoff of the GYVE vector based drawing editor.  
dnl
dnl This program is free software; you can redistribute it and/or modify
dnl it under the terms of the GNU General Public License as published by
dnl the Free Software Foundation; either version 2, or (at your option)
dnl any later version.
dnl
dnl This program is distributed in the hope that it will be useful,
dnl but WITHOUT ANY WARRANTY; without even the implied warranty of
dnl MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
dnl GNU General Public License for more details.
dnl
dnl You should have received a copy of the GNU General Public License
dnl along with this program; if not, write to the Free Software
dnl Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
dnl
dnl As a special exception, the Free Software Foundation gives unlimited
dnl permission to copy, distribute and modify the configure scripts that
dnl are the output of Autoconf.  You need not follow the terms of the GNU
dnl General Public License when using or distributing such scripts, even
dnl though portions of the text of Autoconf appear in them.  The GNU
dnl General Public License (GPL) does govern all other use of the material
dnl that constitutes the Autoconf program.
dnl
dnl Certain portions of the Autoconf source text are designed to be copied
dnl (in certain cases, depending on the input) into the output of
dnl Autoconf.  We call these the "data" portions.  The rest of the Autoconf
dnl source text consists of comments plus executable code that decides which
dnl of the data portions to output in any given case.  We call these
dnl comments and executable code the "non-data" portions.  Autoconf never
dnl copies any of the non-data portions into its output.
dnl
dnl This special exception to the GPL applies to versions of Autoconf
dnl released by the Free Software Foundation.  When you make and
dnl distribute a modified version of Autoconf, you may extend this special
dnl exception to the GPL to apply to your modified version as well, *unless*
dnl your modified version has the potential to copy into its output some
dnl of the text that was the non-data portion of the version that you started
dnl with.  (In other words, unless your change moves or copies text from
dnl the non-data portions to the data portions.)  If your modification has
dnl such potential, you must delete any notice of this special exception
dnl to the GPL from your modified version.
dnl
dnl 
dnl ------------------------------------------------------------------
dnl
dnl AC_PATH_GUILE()
dnl Test for Guile and define several variables.
dnl Side effects:
dnl   AC_SUBST(GUILE)		path to "guile", eg. /usr/local/bin/guile
dnl				or null string if guile is not installed
dnl   AC_SUBST(GUILE_VERSION)   guile version, eg. 1.3
dnl   AC_SUBST(GUILE_CONFIG) 	path to "guile-config", eg. /usr/local/bin/guile-config
dnl				or null string if build-guile is not found
dnl   AC_SUBST(GUILE_CFLAGS)	cflags for guile
dnl   AC_SUBST(GUILE_LIBS)	libs for guile
dnl
AC_DEFUN(AC_PATH_GUILE,
[AC_ARG_WITH(guile-prefix, [  --with-guile-prefix=PFX	Prefix where Guile is installed (optional)],
	guile_prefix="$withval", guile_prefix=/usr/local)

ac_path_guile_dummy_path=""

AC_ARG_WITH(guile-exec-prefix, [  --with-guile-exec-prefix=PFX	Exec prefix where Guile is installed (optional)],
	guile_exec_prefix="$withval", guile_exec_prefix="$guile_prefix")

ac_path_guile_dummy_path="$guile_exec_prefix:$PATH"
AC_PATH_PROG(GUILE, guile,,
	$ac_path_guile_dummy_path)
if test -n "$GUILE"; then
  AC_CACHE_CHECK(for guile version, ac_cv_misc_guile_version, [
	changequote(<<, >>)
	ac_cv_misc_guile_version=`$GUILE --version | grep '^Guile [0-9]' | sed -e 's/^Guile \([0-9][0-9.a-zA-Z]*\).*$/\1/'`
	changequote([, ])
  ])
  GUILE_VERSION="$ac_cv_misc_guile_version"

  AC_PATH_PROG(GUILE_CONFIG, guile-config,,
	$ac_path_guile_dummy_path)

  if test -n "$GUILE_CONFIG"; then
    AC_CACHE_CHECK(for guile cflags, ac_cv_misc_guile_cflags, [
	ac_cv_misc_guile_cflags="-I`$GUILE_CONFIG info includedir`"
    ])
    GUILE_CFLAGS="$ac_cv_misc_guile_cflags"

    AC_CACHE_CHECK(for guile libs, ac_cv_misc_guile_libs, [
	ac_cv_misc_guile_libs="-L$guile_exec_prefix/lib `$GUILE_CONFIG link`"
    ])
    GUILE_LIBS="$ac_cv_misc_guile_libs"

  else
    dnl hmm you are using old stock guile-1.2
    dnl yanked from guile-1.2 configure.in and modified

    ac_save_LIBS="$LIBS"
    ac_save_LDFLAGS="$LDFLAGS"

    LIBS=""
    LDFLAGS="-L$guile_exec_prefix/lib $LDFLAGS"

    AC_CHECK_LIB(m,sin)
    AC_CHECK_FUNC(gethostbyname)
    if test $ac_cv_func_gethostbyname = no; then
	AC_CHECK_LIB(nsl, gethostbyname)
    fi
    AC_CHECK_FUNC(connect)
    if test $ac_cv_func_connect = no; then
	AC_CHECK_LIB(socket, connect)
    fi

    AC_CHECK_LIB(dl,dlopen)
    if test $ac_cv_lib_dl_dlopen = no; then
	AC_CHECK_LIB(dld,dld_link)
	if test $ac_cv_lib_dld_dld_link = no; then
	    AC_CHECK_FUNCS(shl_load)
	fi
    fi

    AC_CHECK_LIB(qthreads,main)
    if test $ac_cv_lib_qthreads_main = no; then
	AC_CHECK_LIB(qt, qt_null)
    fi

    AC_CHECK_LIB(guile, scm_newsmob)
    if test $ac_cv_lib_guile_scm_newsmob = no; then
	AC_MSG_ERROR(Could not find guile library)
    fi

    GUILE_CFLAGS="-I$guile_prefix/include"
    GUILE_LIBS="-L$guile_exec_prefix/lib $LIBS"

    LIBS="$ac_save_LIBS"
    LDFLAGS="$ac_save_LDFLAGS"
  fi
fi
AC_SUBST(GUILE)
AC_SUBST(GUILE_VERSION)
AC_SUBST(GUILE_CONFIG)
AC_SUBST(GUILE_CFLAGS)
AC_SUBST(GUILE_LIBS)
])
