/* private.m - interface between guile and GNUstep
   Copyright (C) 1998 Free Software Foundation, Inc.

   Written by:  Richard Frith-Macdonald <richard@brainstorm.co.uk>
   Date: September 1998

   Based on guileobjc
   	Written by:  R. Andrew McCallum <mccallum@gnu.ai.mit.edu>
   	Date: April 1995

        Including modifications by
		Masatake YAMATO (masata-y@is.aist-nara.ac.jp)

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

#include	<Foundation/NSData.h>
#include	<objc/encoding.h>

#include "gstep_guile.h"
#include "private.h"

/*
 *	Define RISKY to permit automatic casting to/from voidp
 */
#define	RISKY	1

const char*
gstep_guile_check_type(const char* type)
{
    switch (*type) {
	case _C_ID:
	case _C_CLASS:
	case _C_SEL:
	case _C_CHR:
	case _C_UCHR:
	case _C_SHT:
	case _C_USHT:
	case _C_INT:
	case _C_UINT:
	case _C_LNG:
	case _C_ULNG:
	case _C_FLT:
	case _C_DBL:
	case _C_CHARPTR:
	case _C_PTR:
	    type = objc_skip_typespec(type);
	    return type;
	case _C_STRUCT_B:
	    type++;
	    if (*type == _C_STRUCT_E) {
		type = 0;		/* Empty struct are illegal */
	    }
	    while (type && *type && *type != _C_STRUCT_E) {
		type = gstep_guile_check_type(type);
	    }
	    if (type != 0 && *type == _C_STRUCT_E) {
		return ++type;
	    }
	    return 0;

	default:
	    return 0;
    }
}

const char*
gstep_guile_check_types(const char* type)
{
    if (*type == _C_VOID) {
	type++;
    }
    else {
	type = gstep_guile_check_type(type);
    }
    if (type) {
	if (*type != _C_ID && *type != _C_CLASS) {
	    type = 0;
	}
	else {
	    type++;
	    if (*type != _C_SEL) {
		type = 0;
	    }
	    else {
		type++;
		while (type && *type) {
		    type = gstep_guile_check_type(type);
		}
	    }
	}
    }
    return type;
}

BOOL
gstep_guile_decode_item(SCM list, void* datum, int *position, const char** typespec)
{
  const char	*type = *typespec;
  int		offset = *position;
  BOOL		inStruct = NO;

  if (*type == _C_STRUCT_B)
    {
      inStruct = YES;
      while (*type != _C_STRUCT_E && *type++ != '=');
      if (*type == _C_STRUCT_E)
	{
	  *typespec = type;
	  return YES;
	}
    }

  do
    {
      int	align = objc_alignof_type(type); /* pad to alignment */
      void	*where;
      SCM	val;

      offset = ROUND(offset, align);
      where = datum + offset;
      offset += objc_sizeof_type(type);

      if (inStruct)
	{
	  val = gh_car(list);
	  list = gh_cdr(list);
	}
      else
	{
	  val = list;
	}

      switch (*type)
	{
	  case _C_ID:
	  case _C_CLASS:
	    if (SCM_NIMP(val) && OBJC_ID_P(val))
	      {
		*(id*)where = gstep_scm2id(val);
	      }
#ifdef	RISKY
	    else if (SCM_NIMP(val) && OBJC_VOIDP_P(val))
	      {
		*(id*)where = (id)gstep_scm2voidp(val);
	      }
#endif
	    else
	      return NO;
	    break;

	  case _C_SEL:
	    {
	      char	*s;
	      int	l;

	      if (SCM_STRINGP(val))
		{
		  gstep_scm2str(&s, &l, &val);
		  *(SEL*)where = sel_get_any_typed_uid(s);
		}
	      else
		return NO;
	      break;
	    }

	  case _C_CHR:
	    if (SCM_INUMP(val))
	      *(char*)where = (char) gh_scm2long(val);
	    else
	      return NO;
	    break;

	  case _C_UCHR:
	    if (SCM_BOOL_F == val)
	      *(unsigned char*)where = NO;
	    else if (SCM_BOOL_T==val)
	      *(unsigned char*)where = YES;
	    else  if (SCM_INUMP(val) && gh_scm2long(val) >= 0)
	      *(unsigned char*)where = (unsigned char)gh_scm2long(val);
	    else
	      return NO;
	    break;

	  case _C_SHT:
	    if (gh_number_p(val))
	      *(short*)where = (short) gh_scm2long(val);
	    else
	      return NO;
	    break;

	  case _C_USHT:
	    if (gh_number_p(val) && gh_scm2long(val) >= 0)
	      *(unsigned short*)where = (unsigned short) gh_scm2long(val);
	    else
	      return NO;
	    break;

	  case _C_INT:
	    if (gh_number_p(val))
	      *(int*)where = (int) gh_scm2long(val);
	    else
	      return NO;
	    break;

	  case _C_UINT:
	    if (gh_number_p(val) && gh_scm2long(val) >= 0)
	      *(unsigned int*)where = (unsigned int) gh_scm2long(val);
	    else
	      return NO;
	    break;

	  case _C_LNG:
	    if (gh_number_p(val))
	      *(long*)where = (long) gh_scm2long(val);
	    else
	      return NO;
	    break;

	  case _C_ULNG:
	    if (gh_number_p(val) && gh_scm2long(val) >= 0)
	      *(unsigned long*)where = (unsigned long) gh_scm2long(val);
	    else
	      return NO;
	    break;

	  case _C_FLT:
	    if (gh_number_p(val))
	      *(float*)where = (float) gh_scm2double(val);
	    else
	      return NO;
	    break;

	  case _C_DBL:
	    if (gh_number_p(val))
	      *(double*)where = (double) gh_scm2double(val);
	    else
	      return NO;
	    break;

	  case _C_CHARPTR:
	    if (gh_string_p(val))
	      {
		NSMutableData	*d;
		char		*s;
		int		l;

		s = gh_scm2newstr(val, &l);
		d = [NSMutableData dataWithBytesNoCopy: s length: l];
		*(char**)where = (char*)[d mutableBytes];
	      }
#ifdef	RISKY
	    else if (SCM_NIMP(val) && OBJC_VOIDP_P(val))
	      {
		*(char**)where = (char*)gstep_scm2voidp(val);
	      }
#endif
	    else
	      return NO;
	    break;

	  case _C_PTR:
	    if (SCM_NIMP(val) && OBJC_VOIDP_P(val))
	      {
		*(void**)where = gstep_scm2voidp(val);
	      }
#ifdef	RISKY
	    else if (SCM_NIMP(val) && OBJC_ID_P(val))
	      {
		*(void**)where = gstep_scm2id(val);
	      }
	    else if (gh_string_p(val))
	      {
		NSMutableData	*d;
		char		*s;
		int		l;

		s = gh_scm2newstr(val, &l);
		d = [NSMutableData dataWithBytesNoCopy: s length: l];
		*(void**)where = [d mutableBytes];
	      }
#endif
	    else
	      return NO;
	    break;

	  case _C_STRUCT_B:
	    if (gh_list_p(val))
	      {
		if (gstep_guile_decode_item(val, datum, &offset, &type) == NO)
		  return NO;
	      }
	    else
	      return NO;
	    break;

	  default:
	    return NO;
	}

      type = objc_skip_typespec(type); /* skip component */
    }
  while (inStruct && *type != _C_STRUCT_E);

  *typespec = type;
  *position = offset;
  return YES;
}

SCM
gstep_guile_encode_item(void* datum, int *position, const char** typespec, BOOL isAlloc, BOOL isInit, id recv, SCM wrap)
{
  const char	*type = *typespec;
  int		offset = *position;
  SCM		ret = SCM_UNDEFINED;
  SCM		end = 0;
  BOOL		inStruct = NO;

  if (*type == _C_STRUCT_B)
    {
      inStruct = YES;
      while (*type != _C_STRUCT_E && *type++ != '=');
      if (*type == _C_STRUCT_E)
	{
	  *typespec = type;
	  return SCM_UNDEFINED;
	}
    }

  do
    {
      int	align = objc_alignof_type (type); /* pad to alignment */
      SCM	val;
      void	*where;

      offset = ROUND(offset, align);
      where = datum + offset;
      offset += objc_sizeof_type(type);

      switch (*type)
	{
	  case _C_ID:
	  case _C_CLASS:
	    if (recv != nil && *(id*)where == recv)
	      {
		val = wrap;
	      }
	    else
	      {
		if (isAlloc || isInit)
		  {
		    /*
		     *	If this is a special case of an object
		     *	returned by 'alloc', 'init, 'copy', or 'new', then
		     *	we don't need to retain it since it already
		     *	has a retain count of 1.
		     */
		    if (inStruct == YES)
		      {
			/*
			 *	This should really never happen -
			 *	if it does then someone has flouted the
			 *	coding conventions and created a 'new',
			 *	'init', or 'alloc' method which returns
			 *	a structure!
			 */
			val = gstep_id2scm(*(id*)where, YES);
		      }
		    else
		      {
			val = gstep_id2scm(*(id*)where, NO); 
			if (isInit)
			  {
			    /*
			     *	If an init method has replaced our
			     *	original object - it will have released
			     *	the original - so we must tidy up the
			     *	Guile wrapper for it.
			     */
			    gstep_fixup_id(wrap);
			  }
		      }
		  }
		else
		  {
		    val = gstep_id2scm(*(id*)where, YES); 
		  }
	      }
	    break;

	  case _C_SEL:
	    val = gh_str02scm((char*)sel_get_name(*(SEL *)where));
	    break;

	  case _C_CHR:
	    val = gh_long2scm((long) *(char*)where);
	    break;

	  case _C_UCHR:
	    val = gh_ulong2scm((unsigned long) *(unsigned char*)where);
	    break;

	  case _C_SHT:
	    val = gh_long2scm((long) *(short*)where);
	    break;

	  case _C_USHT:
	    val = gh_ulong2scm((unsigned long) *(unsigned short*)where);
	    break;

	  case _C_INT:
	    val = gh_long2scm((long) *(int*)where);
	    break;

	  case _C_UINT:
	    val = gh_ulong2scm((unsigned long)*(unsigned int*)where);
	    break;

	  case _C_LNG:
	    val = gh_long2scm(*(long*)where);
	    break;

	  case _C_ULNG:
	    val = gh_ulong2scm(*(unsigned long*)where);
	    break;

	  case _C_FLT:
	    val = gh_double2scm((double) *(float*)where);
	    break;

	  case _C_DBL:
	    val = gh_double2scm(*(double*)where);
	    break;

	  case _C_CHARPTR:
	    val = gh_str02scm(*(char**)where);
	    break;

	  case _C_PTR:
	    val = gstep_voidp2scm(*(void**)where, NO, NO, 0);
	    break;

	  case _C_VOID:
	    val = SCM_UNDEFINED;
	    break;

	  case _C_STRUCT_B:
	    val =
	      gstep_guile_encode_item(datum, &offset, &type, NO, NO, nil, 0);
	    if (val == (SCM)0)
	      return val;
	    break;

	  default:
	    return (SCM)0;
	}

      if (inStruct)
	{
	  gh_defer_ints();
	  if (end == 0)
	    {
	      SCM_NEWCELL(end);
	      SCM_SETCAR(end, val); 
	      SCM_SETCDR(end, SCM_EOL);
	      ret = end;
	    }
	  else
	    {
	      SCM	tmp;
	      SCM_NEWCELL(tmp);
	      SCM_SETCAR(tmp, val); 
	      SCM_SETCDR(tmp, gh_cdr(end));
	      SCM_SETCDR(end, tmp);
	      end = tmp;
	    }
	  gh_allow_ints();
	}
      else
	{
	  ret = val;
	}
      type = (char*)objc_skip_typespec(type); /* skip component */
    } while (inStruct && *type != _C_STRUCT_E);
  *typespec = type;
  *position = offset;
  return ret;
}

int
gstep_guile_list_length(SCM list)
{
  int	l = 0;

  while (list != SCM_EOL)
    {
      l++;
      list = gh_cdr(list);
    }
  return l;
}

/* But, metaclasses return YES too? */
BOOL
gstep_guile_object_is_class(id object)
{
  if (object != nil 
#if NeXT_runtime
      && CLS_ISMETA(((Class)object)->isa))
#else
      && CLS_ISMETA(((Class)object)->class_pointer))
#endif
    return YES;
  else
    return NO;
}

/* 
 * Functions stolen from gscm.c 
 */
void
gstep_scm_error(char *message, SCM args)
{
  SCM errsym;
  SCM str;

  errsym = gh_car(scm_intern ("error", 5));
  str = scm_makfrom0str (message);
  scm_throw (errsym, scm_cons (str, args));
}

void
gstep_scm2str(char **out, int *len_out, SCM *objp)
{
  SCM_ASSERT (SCM_NIMP (*objp) && SCM_STRINGP (*objp), *objp, SCM_ARG3, 
	      "gstep_scm2str");
  if (out)
    *out = SCM_CHARS (*objp);
  if (len_out)
    *len_out = SCM_LENGTH (*objp);
}

