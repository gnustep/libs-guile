/* gg_voidp.m - interface between guile and GNUstep
   Copyright (C) 1998 Free Software Foundation, Inc.

   Written by:  Richard Frith-Macdonald <richard@brainstorm.co.uk>
   Date: September 1998

   This file is part of the GNUstep-Guile Library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
   */

#include <stdarg.h>

#include <string.h>		// #ifdef .. #endif

#include "gstep_guile.h"
#include "private.h"



/*
 *	SMOB stuff for abstract pointers.
 *	These are to let Guile interact with Objective-C methods and functions
 *	which use or return pointers to void.
 */

int gstep_scm_tc16_voidp;

static SCM equal_gstep_voidp (SCM s1, SCM s2);
static scm_sizet free_gstep_voidp (SCM obj);
static int print_gstep_voidp (SCM exp, SCM port, scm_print_state *pstate);
static SCM mark_gstep_voidp (SCM obj);

static SCM 
mark_gstep_voidp (SCM obj)
{
  if (SCM_GC8MARKP (obj))
    {
      return SCM_BOOL_F;
     } 
  SCM_SETGC8MARK (obj);
  return SCM_BOOL_F;
}

static SCM  
equal_gstep_voidp (SCM s1, SCM s2)
{
  if (((voidp)gh_cdr(s1))->ptr == ((voidp)gh_cdr(s2))->ptr)
    {
      return SCM_BOOL_T;
    }
  else
    {
      return SCM_BOOL_F;
    }
}

static scm_sizet 
free_gstep_voidp (SCM obj)
{
  voidp	v = (voidp)gh_cdr(obj);

  if (v->isMallocMem)
    {
      objc_free(v->ptr);
    }
  objc_free(v);
  
  return (scm_sizet)0;
}

static int
print_gstep_voidp (SCM exp, SCM port, scm_print_state *pstate)
{
  scm_display(gh_str02scm("#<gstep-voidp 0x"), port);
  scm_intprint((long)((voidp)gh_cdr(exp))->ptr, 16, port);
  scm_display(gh_str02scm(">"), port);
  return 1;
}

SCM
gstep_voidp2scm(void* ptr, BOOL isMallocMem, BOOL lengthKnown, int len)
{
  voidp	v;
  SCM	answer;

  gh_defer_ints();
  v = (voidp)objc_malloc(sizeof(struct voidp_struct));
  v->ptr = ptr;
  v->len = len > 0 ? len : 0;
  v->lengthKnown = lengthKnown;
  v->isMallocMem = isMallocMem;
  SCM_NEWCELL(answer);
  SCM_SETCAR(answer, gstep_scm_tc16_voidp); 
  SCM_SETCDR(answer, (SCM)v); 
  gh_allow_ints();
  return answer;
}

void
gstep_voidp_set(SCM o, void *ptr, BOOL m, BOOL lenKnown, int len)
{
  if (SCM_NIMP(o) && OBJC_VOIDP_P(o))
    {
      voidp	p = (voidp)gh_cdr(o);

      if (p->isMallocMem && p->ptr != ptr && p->ptr != 0)
	{
	  objc_free(p->ptr);
	}
      p->ptr = ptr;
      p->isMallocMem = m;
      p->lengthKnown = lenKnown;
      p->len = (len > 0) ? len : 0;
    }
}

void*
gstep_scm2voidp (SCM o)
{
  if (SCM_NIMP(o) && OBJC_VOIDP_P(o))
    {
      return ((voidp)gh_cdr(o))->ptr;
    }
  else
    {
      return 0;
    }
}



static char gstep_voidp_p_n[] = "voidp?";

SCM
gstep_scm_voidp_p(SCM v)
{
  if (SCM_NIMP(v) && OBJC_VOIDP_P(v))
    {
      return SCM_BOOL_T;
    }
  return SCM_BOOL_F;
}

int
gstep_voidp_p (SCM val)
{
  return (gstep_scm_voidp_p (val) == SCM_BOOL_T) ? 1 : 0;
}



static char gstep_string_voidp_n[] = "string->voidp";

static SCM
gstep_string_voidp_fn(SCM str)
{
  char	*s;
  int	l;
  SCM	v;

  SCM_ASSERT(gh_string_p(str), str, SCM_ARG1, gstep_string_voidp_n);

  s = gh_scm2newstr(str, &l);
  v = gstep_voidp2scm(s, YES, YES, l);
}



static char gstep_voidp_set_n[] = "voidp-set!";

static SCM
gstep_voidp_set_fn(SCM v, SCM o, SCM s)
{
  int	offset;
  int	length;
  voidp	obj;
  char	*ptr;

  SCM_ASSERT(SCM_NIMP(v)&&OBJC_VOIDP_P(v), v, SCM_ARG1, gstep_voidp_set_n);
  SCM_ASSERT(gh_number_p(o), o, SCM_ARG2, gstep_voidp_set_n);
  SCM_ASSERT(gh_string_p(s), s, SCM_ARG3, gstep_voidp_set_n);

  obj = (voidp)gh_cdr(v);
  offset = gh_scm2int(o);
  length = gh_scm2int(scm_string_length(s));
  if (offset < 0 || length < 0)
    {
      gstep_scm_error("bad offset or length", o);
    }
  if (obj->lengthKnown == YES && (offset + length > obj->len))
    {
      gstep_scm_error("bad offset plus length", o);
    }
  ptr = (char*)obj->ptr;
  gh_get_substr(s, &ptr[offset], 0, length);
  return v;
}



static char gstep_voidp_string_n[] = "voidp->string";

static SCM
gstep_voidp_string_fn(SCM v, SCM o, SCM l)
{
  int	offset;
  int	length;
  voidp obj;
  char	*ptr;
  SCM	answer;

  SCM_ASSERT(SCM_NIMP(v)&&OBJC_VOIDP_P(v), v, SCM_ARG1, gstep_voidp_string_n);
  SCM_ASSERT(gh_number_p(o), o, SCM_ARG2, gstep_voidp_string_n);
  SCM_ASSERT(gh_number_p(l), l, SCM_ARG3, gstep_voidp_string_n);

  obj = (voidp)gh_cdr(v);
  offset = gh_scm2int(o);
  length = gh_scm2int(l);
  if (offset < 0 || length < 0)
    {
      gstep_scm_error("bad offset or length", o);
    }
  if (obj->lengthKnown && (offset + length > obj->len))
    {
      gstep_scm_error("bad offset plus length", o);
    }
  ptr = (char*)obj->ptr;
  answer = gh_str2scm(&ptr[offset], length);
  return answer;
}



static char gstep_voidp_length_n[] = "voidp-length";

int
gstep_scm2voidplength(SCM v)
{
  if (gstep_voidp_p(v))
    {
      voidp obj = (voidp)gh_cdr(v);

      if (obj->lengthKnown)
	{
	  return obj->len;
	}
    }
  return -1;
}
 
static SCM
gstep_voidp_length_fn(SCM v)
{
  voidp obj;

  SCM_ASSERT(SCM_NIMP(v)&&OBJC_VOIDP_P(v), v, SCM_ARG1, gstep_voidp_length_n);
  obj = (voidp)gh_cdr(v);
  if (obj->lengthKnown)
    {
      return gh_int2scm(obj->len);
    }
  else
    {
      return SCM_UNDEFINED;
    }
}
 


static char gstep_voidp_lengthp_n[] = "voidp-length?";

static SCM
gstep_voidp_lengthp_fn(SCM v)
{
  voidp obj;

  SCM_ASSERT(SCM_NIMP(v)&&OBJC_VOIDP_P(v), v, SCM_ARG1, gstep_voidp_lengthp_n);
  obj = (voidp)gh_cdr(v);
  if (obj->lengthKnown)
    {
      return SCM_BOOL_T;
    }
  else
    {
      return SCM_BOOL_F;
    }
}
 


static char gstep_voidp_setlength_n[] = "voidp-set-length!";

static SCM
gstep_voidp_setlength_fn(SCM v, SCM l)
{
  voidp obj;
  int	length;

  SCM_ASSERT(SCM_NIMP(v)&&OBJC_VOIDP_P(v),v,SCM_ARG1,gstep_voidp_setlength_n);
  SCM_ASSERT(gh_number_p(l), l, SCM_ARG2, gstep_voidp_setlength_n);
  obj = (voidp)gh_cdr(v);
  length = gh_scm2int(l);
  if (l < 0)
    {
      obj->lengthKnown = NO;
    }
  else
    {
      obj->lengthKnown = YES;
      obj->len = length;
    }
  return v;
}
 


static char gstep_voidp_mallocp_n[] = "voidp-malloc?";

static SCM
gstep_voidp_mallocp_fn(SCM v)
{
  voidp obj;

  SCM_ASSERT(SCM_NIMP(v)&&OBJC_VOIDP_P(v),v,SCM_ARG1,gstep_voidp_mallocp_n);
  obj = (voidp)gh_cdr(v);
  if (obj->isMallocMem)
    {
      return SCM_BOOL_T;
    }
  else
    {
      return SCM_BOOL_F;
    }
}
 


static char gstep_voidp_setmalloc_n[] = "voidp-set-malloc!";

static SCM
gstep_voidp_setmalloc_fn(SCM v, SCM b)
{
  voidp obj;

  SCM_ASSERT(SCM_NIMP(v)&&OBJC_VOIDP_P(v),v,SCM_ARG1,gstep_voidp_setmalloc_n);
  SCM_ASSERT(gh_boolean_p(b), b, SCM_ARG2, gstep_voidp_setmalloc_n);
  obj = (voidp)gh_cdr(v);
  if (b == SCM_BOOL_T)
    {
      obj->isMallocMem = YES;
    }
  else
    {
      obj->isMallocMem = NO;
    }
  return v;
}
 

static char gstep_voidp_nil_n[] = "voidp-nil";

static SCM
gstep_voidp_nil_fn()
{
  return gstep_voidp2scm(0, NO, YES, 0);
}


static char gstep_id_voidp_n[] = "gstep-id->voidp";

static SCM
gstep_id_voidp_fn(SCM o)
{
  return gstep_voidp2scm(gstep_scm2id(o), NO, YES, 0);
}


static char gstep_voidp_id_n[] = "voidp->gstep-id";

static SCM
gstep_voidp_id_fn(SCM o)
{
  return gstep_id2scm(gstep_scm2voidp(o), YES);
}



static char gstep_voidp_list_n[] = "voidp->list";

static SCM
gstep_voidp_list_fn(SCM v, SCM t, SCM l)
{
  SCM	answer = 0;
  SCM	end;
  voidp obj;
  char	*type;
  int	offset = 0;
  int	align;
  int	count;
  int	i;

  SCM_ASSERT(SCM_NIMP(v)&&OBJC_VOIDP_P(v),v,SCM_ARG1,gstep_voidp_list_n);
  SCM_ASSERT(gh_string_p(t), t, SCM_ARG2, gstep_voidp_list_n);
  SCM_ASSERT(gh_number_p(l), l, SCM_ARG3, gstep_voidp_list_n);
  obj = (voidp)gh_cdr(v);
  count = gh_scm2int(l);
  if (count <= 0)
    {
      gstep_scm_error("list length bad", l);
    }
  type = gh_scm2newstr(t, 0);
  if (gstep_guile_check_type(type) == 0)
    {
      free(type);
      gstep_scm_error("bad type spec", t);
    }

  align = objc_alignof_type(type); /* pad to alignment */

  if (obj->lengthKnown)
    {
      int	total;

      total = ROUND(objc_sizeof_type(type), align)
	* (count-1) + objc_sizeof_type(type);
      if (total > obj->len)
	{
	  free(type);
	  gstep_scm_error("list size too large", l);
	}
    }

  for (i = 0; i < count; i++)
    {
      const char	*tmptype = type;
      void	*where;
      SCM	tmp;
      SCM	val;
      int	pos = 0;

      offset = ROUND(offset, align);
      where = obj->ptr + offset;
      offset += objc_sizeof_type(type);

      val = gstep_guile_encode_item(where, &pos, &tmptype, NO, NO, nil, 0);
      gh_defer_ints();
      if (answer == 0)
	{
	  SCM_NEWCELL(tmp);
	  SCM_SETCAR(tmp, val); 
	  SCM_SETCDR(tmp, SCM_EOL);
	  answer = tmp;
	  end = tmp;
	}
      else
	{
	  SCM_NEWCELL(tmp);
	  SCM_SETCAR(tmp, val); 
	  SCM_SETCDR(tmp, gh_cdr(end));
	  SCM_SETCDR(end, tmp);
	  end = tmp;
	}
      gh_allow_ints();
    }
  free(type);
  return answer;
}

static char gstep_list_voidp_n[] = "list->voidp";

static SCM
gstep_list_voidp_fn(SCM l, SCM t)
{
  SCM	obj;
  void	*ptr;
  char	*type;
  int	offset = 0;
  int	total;
  int	align;
  int	count;

  SCM_ASSERT(gh_list_p(l),l,SCM_ARG1,gstep_list_voidp_n);
  SCM_ASSERT(gh_string_p(t), t, SCM_ARG2, gstep_list_voidp_n);
  if ((count = gstep_guile_list_length(l)) == 0)
    {
      gstep_scm_error("list length bad", l);
    }
  type = gh_scm2newstr(t, 0);
  if (gstep_guile_check_type(type) == 0)
    {
      free(type);
      gstep_scm_error("bad type spec", t);
    }

  align = objc_alignof_type(type); /* pad to alignment */

  total = ROUND(objc_sizeof_type(type), align)
    * (count-1) + objc_sizeof_type(type);
  ptr = (void*)objc_malloc(total);
  obj = gstep_voidp2scm(ptr, YES, YES, total);

  while (l != SCM_EOL)
    {
      const char	*tmptype = type;
      void	*where;
      int	pos = 0;

      offset = ROUND(offset, align);
      where = ptr + offset;
      offset += objc_sizeof_type(type);

      if (gstep_guile_decode_item(gh_car(l), where, &pos, &tmptype) == NO)
	{
	  free(type);
	  return SCM_UNDEFINED;
	}
      l = gh_cdr(l);
    }
  return obj;
}



void
gstep_init_voidp()
{
#if	GUILE_MAKE_SMOB_TYPE
  gstep_scm_tc16_voidp = scm_make_smob_type ("gg_voidp", 0);
  scm_set_smob_mark(gstep_scm_tc16_voidp, mark_gstep_voidp);
  scm_set_smob_free(gstep_scm_tc16_voidp, free_gstep_voidp);
  scm_set_smob_print(gstep_scm_tc16_voidp, print_gstep_voidp);
  scm_set_smob_equalp(gstep_scm_tc16_voidp, equal_gstep_voidp);
#else
  static struct scm_smobfuns gstep_voidp_smob = {
    mark_gstep_voidp,
    free_gstep_voidp,
    print_gstep_voidp,
    equal_gstep_voidp
  };

  gstep_scm_tc16_voidp = scm_newsmob (&gstep_voidp_smob);
#endif

  /*
   *	Plain voidp functions.
   */
  scm_make_gsubr(gstep_string_voidp_n, 1, 0, 0, gstep_string_voidp_fn);
  scm_make_gsubr(gstep_voidp_p_n, 1, 0, 0, gstep_scm_voidp_p);
  scm_make_gsubr(gstep_voidp_nil_n, 0, 0, 0, gstep_voidp_nil_fn);
  scm_make_gsubr(gstep_voidp_set_n, 3, 0, 0, gstep_voidp_set_fn);
  scm_make_gsubr(gstep_voidp_string_n, 3, 0, 0, gstep_voidp_string_fn);
  scm_make_gsubr(gstep_voidp_length_n, 1, 0, 0, gstep_voidp_length_fn);
  scm_make_gsubr(gstep_voidp_lengthp_n, 1, 0, 0, gstep_voidp_lengthp_fn);
  scm_make_gsubr(gstep_voidp_setlength_n, 2, 0, 0, gstep_voidp_setlength_fn);
  scm_make_gsubr(gstep_voidp_mallocp_n, 1, 0, 0, gstep_voidp_mallocp_fn);
  scm_make_gsubr(gstep_voidp_setmalloc_n, 2, 0, 0, gstep_voidp_setmalloc_fn);
  scm_make_gsubr(gstep_voidp_list_n, 3, 0, 0, gstep_voidp_list_fn);
  scm_make_gsubr(gstep_list_voidp_n, 2, 0, 0, gstep_list_voidp_fn);

  /*
   *	Convert between voidp and id
   */
  scm_make_gsubr(gstep_voidp_id_n, 1, 0, 0, gstep_voidp_id_fn);
  scm_make_gsubr(gstep_id_voidp_n, 1, 0, 0, gstep_id_voidp_fn);
}

