/*
 *	A trivial replacement for the Guile shell - but with the
 *	Objective-C runtime and the base and gdl2 library linked in so
 *	that we can test things 
 */

#include <gstep_guile.h>
#include <guile/gh.h>

static void
inner_main(void* colsure, int argc, char **argv)
{
  gstep_init();
  gstep_link_base();
  gstep_link_gdl2();
  scm_shell(argc, argv);
}

int
main(int argc, char** argv)
{
#if	defined(LIB_FOUNDATION_LIBRARY) || defined(GS_PASS_ARGUMENTS)
  [NSProcessInfo initializeWithArguments: argv
				   count: argc
			     environment: envp];
#endif
  scm_boot_guile (argc, argv, inner_main, 0);
  return 0;
}	

