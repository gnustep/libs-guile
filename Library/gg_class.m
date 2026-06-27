/* gg_class.m - interface between guile and GNUstep
   Copyright (C) 1998 Free Software Foundation, Inc.

   This file is part of the GNUstep-Guile Library.
 */

#include <stdlib.h>
#include <objc/runtime.h>

#include "private.h"

int gstep_scm_tc16_class;

static SCM
mark_gstep_class (SCM obj)
{
  return SCM_BOOL_F;
}

static SCM
equal_gstep_class (SCM s1, SCM s2)
{
  return gh_cdr(s1) == gh_cdr(s2) ? SCM_BOOL_T : SCM_BOOL_F;
}

static size_t
free_gstep_class (SCM obj)
{
  return 0;
}

static int
print_gstep_class (SCM exp, SCM port, scm_print_state *pstate)
{
  scm_display(gh_str02scm("#<gstep-class>"), port);
  return 1;
}

static SCM
class_name_to_string (SCM classname)
{
  if (SCM_NIMP(classname) && SCM_SYMBOLP(classname))
    {
      return scm_symbol_to_string(classname);
    }
  if (SCM_NIMP(classname) && SCM_STRINGP(classname))
    {
      return classname;
    }

  gstep_scm_error("not a symbol or string", classname);
  return SCM_BOOL_F;
}

static char gstep_lookup_class_n[] = "gstep-lookup-class";

static SCM
gstep_lookup_class_fn (SCM classname)
{
  SCM name_string = class_name_to_string(classname);
  char *name = gh_scm2newstr(name_string, 0);
  id class = (id)objc_lookUpClass(name);

  free(name);
  return gstep_id2scm(class, NO);
}

static char gstep_classnames_n[] = "gstep-classnames";

static SCM
gstep_classnames_fn(void)
{
  int count;
  Class *classes;
  SCM answer = SCM_EOL;

  count = objc_getClassList(NULL, 0);
  if (count <= 0)
    {
      return answer;
    }

  classes = malloc(sizeof(Class) * count);
  if (classes == NULL)
    {
      gstep_scm_error("could not allocate class list", SCM_EOL);
      return SCM_EOL;
    }

  count = objc_getClassList(classes, count);
  while (count-- > 0)
    {
      answer = scm_cons(gh_str02scm((char*)class_getName(classes[count])),
                        answer);
    }

  free(classes);
  return answer;
}

static SCM
unsupported_dynamic_class_api (void)
{
  gstep_scm_error("Scheme-defined Objective-C classes are not supported with this runtime", SCM_EOL);
  return SCM_BOOL_F;
}

static char gstep_new_class_n[] = "gstep-new-class";

static SCM
gstep_new_class_fn(SCM classn, SCM supern, SCM ilist, SCM mlist, SCM clist)
{
  return unsupported_dynamic_class_api();
}

static char gstep_class_methods_n[] = "gstep-class-methods";

static SCM
gstep_class_methods_fn(SCM classn, SCM mlist)
{
  return unsupported_dynamic_class_api();
}

static char gstep_instance_methods_n[] = "gstep-instance-methods";

static SCM
gstep_instance_methods_fn(SCM classn, SCM mlist)
{
  return unsupported_dynamic_class_api();
}

void
gstep_init_class()
{
  gstep_scm_tc16_class = scm_make_smob_type ("gg_class", 0);
  scm_set_smob_mark(gstep_scm_tc16_class, mark_gstep_class);
  scm_set_smob_free(gstep_scm_tc16_class, free_gstep_class);
  scm_set_smob_print(gstep_scm_tc16_class, print_gstep_class);
  scm_set_smob_equalp(gstep_scm_tc16_class, equal_gstep_class);

  CFUN(gstep_lookup_class_n, 1, 0, 0, gstep_lookup_class_fn);
  CFUN(gstep_classnames_n, 0, 0, 0, gstep_classnames_fn);
  CFUN(gstep_new_class_n, 5, 0, 0, gstep_new_class_fn);
  CFUN(gstep_class_methods_n, 2, 0, 0, gstep_class_methods_fn);
  CFUN(gstep_instance_methods_n, 2, 0, 0, gstep_instance_methods_fn);
}
