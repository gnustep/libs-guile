
/*
 *	`gdl2' loads "gstep_guile.scm" by itself because there is no
 *      definition for `require' in scheme files in the guile-1.2.  
 *
 *	If given a '-c' argument, we execute the next argument as a guile
 *	expression, otherwise we go into interactive mode.
 */

#include	<Foundation/NSProcessInfo.h>
#include	<Foundation/NSString.h>

#include "gstep_guile.h"
#include <guile/gh.h>

void gdl2_main (int argc, char ** argv);

char *gstep_guile_introduction_scm_code = \
"(display \"Welcome to the gdl2 driver\\n\") \
 (display \"Type '(quit)' to exit\\n\") " ;

char *gstep_guile_set_prompt_scm_code = \
"(if (equal? (version) \"1.0\") (set! the-prompt-string \"gdl2> \") \
(set-repl-prompt! \"gdl2> \"))";

int
main(int argc, char **argv, char ** envp)
{
#if	defined(LIB_FOUNDATION_LIBRARY) || defined(GS_PASS_ARGUMENTS)
    [NSProcessInfo initializeWithArguments: argv
				     count: argc
			       environment: envp];
#endif
    gh_enter(argc, argv, gdl2_main);
    return 0;
}	

void
gdl2_main(int argc, char **argv)
{
    gstep_init();
    gstep_link_base();
    gstep_link_gdl2();
    scm_set_program_arguments (argc, argv, argv[0]);

    /* Load gstep_guile.scm. */
    gh_eval_str("(if (not (defined? 'use-modules)) (primitive-load-path \"ice-9/boot-9.scm\"))");
  
    if (argc > 2 && strcmp(argv[1], "-c") == 0) {
	gh_eval_str(argv[2]);
    }
    else {
	/* Display the introduction */
	gh_eval_str(gstep_guile_introduction_scm_code);

	/* Set the prompt. */
	gh_eval_str(gstep_guile_set_prompt_scm_code);

	/* Go go! */ 
	gh_eval_str("(top-repl)");
    }
}
