/* gg_class.m - interface between guile and GNUstep
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

#include <objc/objc.h>
#include <objc/objc-api.h>
#include <objc/encoding.h>
#include <objc/Protocol.h>

extern void __objc_resolve_class_links();


#include <stdarg.h>

#include <Foundation/NSObject.h>
#include <Foundation/NSProxy.h>

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSException.h>
#include <Foundation/NSInvocation.h>
#include <Foundation/NSMapTable.h>
#include <Foundation/NSMethodSignature.h>
#include <Foundation/NSNotificationQueue.h>
#include <Foundation/NSRunLoop.h>
#include <Foundation/NSSet.h>
#include <Foundation/NSString.h>
#include <Foundation/NSData.h>

#include <string.h>		// #ifdef .. #endif

#include "private.h"



/*
 *	SMOB stuff for ObjectiveC classes defined by Guile
 *	These exist purely to ensure that Guile procedures which are used as
 *	Objective-C class methods are never garbage collected.
 */
typedef	struct {
  Module_t	objc_runtime_info;
  NSMapTable	*instance_methods;
  NSMapTable	*factory_methods;
} class_info;

int gstep_scm_tc16_class;
static NSMapTable *knownClasses = 0;
#define OBJC_CLASS_P(arg) ((SCM_TYP16(arg)) == gstep_scm_tc16_class)

static SCM equal_gstep_class (SCM s1, SCM s2);
static scm_sizet free_gstep_class (SCM obj);
static int print_gstep_class (SCM exp, SCM port, scm_print_state *pstate);
static SCM mark_gstep_class (SCM obj);

static SCM
mark_gstep_class (SCM obj)
{
  class_info	*cls;
  NSMapEnumerator enumerator;
  void		*key;
  SCM		item;

  if (SCM_GC8MARKP (obj))
    return SCM_BOOL_F;

  SCM_SETGC8MARK (obj);

  cls = (class_info*)gh_cdr(obj);

  enumerator = NSEnumerateMapTable(cls->instance_methods);
  while (NSNextMapEnumeratorPair(&enumerator, &key, (void **)(&item)))
    scm_gc_mark(item);

  enumerator = NSEnumerateMapTable(cls->factory_methods);
  while (NSNextMapEnumeratorPair(&enumerator, &key, (void **)(&item)))
    scm_gc_mark(item);

  return SCM_BOOL_F;
}

static SCM
equal_gstep_class (SCM s1, SCM s2)
{
  if (gh_cdr(s1) == gh_cdr(s2))
    return SCM_BOOL_T;
  else
    return SCM_BOOL_F;
}

static scm_sizet
free_gstep_class (SCM obj)
{
  fprintf(stderr, "HELP - Garbage collector attacks class!\n");
  return (scm_sizet)0;
}

static int
print_gstep_class (SCM exp, SCM port, scm_print_state *pstate)
{
  scm_display(gh_str02scm("#<gstep-class>"), port);

  return 1;
}



/*
 *	Structure to contain information to be passed to proc_wrapper() in
 *	order to execute a guile procedure.
 */
typedef	struct {
  SCM	proc;		/* The guile procedure to be executed.		*/
  SCM	receiver;	/* Receiving object (first arg of procedure)	*/
  SCM	selname;	/* Selector name (second arg of procedure)	*/
  SCM	argslist;	/* Remaining arguments to be passed.		*/
} proc_data;

static SCM
proc_wrapper(void* data, SCM jmpbuf)
{
  proc_data	*p = (proc_data*)data;

  return gh_call3(p->proc, p->receiver, p->selname, p->argslist);
}

SCM
proc_error(void *data, SCM tag, SCM throw_args)
{
  gh_display(tag);
  gh_display(throw_args);
  [NSException raise: NSGenericException
	      format: @"%s: guile threw an exception", (char*)data];
  return gh_bool2scm(0);
}

/*
 *	Internal forwarding routine to pass objc method invocations to guile.
 *	This uses the name of the receivers class to look up a 'class_info'
 *	entry in the 'knownClasses' map.  It then uses the name of the
 *	selector to look up a Guile procedure in on of the maps in that
 *	structure, and calls that procedure.
 */
static retval_t
gstep_send_msg_to_guile(id rcv, SEL sel, ...)
{
  va_list	ap;
  Class		rclass;
  class_info	*cls;
  const char	*type;
  const char	*tmptype;
  const char	*rcvname;
  const char	*selname;
  char		*procname;
  retval_t	retframe;
  SCM		val = 0;
  SCM		proc = 0;
  SCM		receiver;
  SCM		argsList = SCM_EOL;
  SCM		argsEnd = 0;
  BOOL		rcvIsClass = gstep_guile_object_is_class(rcv);
  NSString	*meth;
  proc_data	data;
  typedef struct { id many[8];} __big;
  __big return_block (void* data)
    {
      return *(__big*)data;
    }
  char return_char (char data)
    {
      return data;
    }
  double return_double (double data)
    {
      return data;
    }
  float return_float (float data)
    {
      return data;
    }
  short return_short (short data)
    {
      return data;
    }
  retval_t apply_block(void* data)
    {
      void* args = __builtin_apply_args();
      return __builtin_apply((apply_t)return_block, args, sizeof(void*));
    }
  retval_t apply_char(char data)
    {
      void* args = __builtin_apply_args();
      return __builtin_apply((apply_t)return_char, args, sizeof(void*));
    }
  retval_t apply_float(float data)
    {
      void* args = __builtin_apply_args();
      return __builtin_apply((apply_t)return_float, args, sizeof(float));
    }
  retval_t apply_double(double data)
    {
      void* args = __builtin_apply_args();
      return __builtin_apply((apply_t)return_double, args, sizeof(double));
    }
  retval_t apply_short(short data)
    {
      void* args = __builtin_apply_args();
      return __builtin_apply((apply_t)return_short, args, sizeof(void*));
    }

  /*
   *	Get receiver object and it's class name.
   */
  receiver = gstep_id2scm(rcv, YES);
  rcvname = object_get_class_name(rcv);

  /*
   *	Get the method name and types from the selector
   */
  type = sel_get_type(sel);
  tmptype = type;
  selname = sel_get_name(sel);

  /*
   *	Build name for error logging purposes.
   */
  procname = objc_malloc(strlen(rcvname) + strlen(selname) + 5);
  strcpy(procname, "[");
  strcat(procname, rcvname);
  strcat(procname, " ");
  if (rcvIsClass)
    {
      strcat(procname, "+");
    }
  else
    {
      strcat(procname, "-");
    }
  strcat(procname, selname);
  strcat(procname, "]");

  /*
   *	Get SCM object for procedure with the method name.
   */
  if (rcvIsClass)
    {
      rclass = rcv;
    }
  else
    {
      rclass = (Class)rcv->class_pointer;
    }
  meth = [NSString stringWithCString: selname];
  while (proc == 0 && rclass != nil)
    {
      val = (SCM)NSMapGet(knownClasses, rclass->name);
      while (val == 0)
	{
	  rclass = rclass->super_class;
	  if (rclass == nil)
	    {
	      break;
	    }
	  val = (SCM)NSMapGet(knownClasses, rclass->name);
	}
      if (val != 0)
	{
	  cls = (class_info*)gh_cdr(val);
	  if (rcvIsClass)
	    {
	      proc = (SCM)NSMapGet(cls->factory_methods, meth);
	    }
	  else
	    {
	      proc = (SCM)NSMapGet(cls->instance_methods, meth);
	    }
	  if (proc == 0)
	    {
	      rclass = rclass->super_class;
	    }
	}
    }

  if (proc == 0)
    {
      [NSException raise: NSGenericException
		  format: @"no class info for method dispatch - %s",
			procname];
    }

  /*
   *	Now encode the method arguments into a list of Guile data items to
   *	be passed to the Guile procedure.
   */
  tmptype = objc_skip_argspec(tmptype);	/* skip return type	*/
  tmptype = objc_skip_argspec(tmptype);	/* skip receiver	*/
  tmptype = objc_skip_argspec(tmptype);	/* skip selector	*/

  va_start(ap, sel);
  /* Note that the va_arg type is the actual type after default promotion */
  while (*tmptype != '\0')
    {
      switch (*tmptype)
	{
	  case _C_ID:
	  case _C_CLASS:
	    val = gstep_id2scm(va_arg(ap, id), YES);
	    break;
	  case _C_SEL:
	    val = gh_str02scm((char*)sel_get_name(va_arg(ap, SEL)));
	    break;
	  case _C_CHR:
	    val = gh_long2scm(va_arg(ap, int));
	    break;
	  case _C_UCHR:
	    val = gh_ulong2scm(va_arg(ap, unsigned int));
	    break;
	  case _C_SHT:
	    val = gh_long2scm(va_arg(ap, int));
	    break;
	  case _C_USHT:
	    val = gh_ulong2scm(va_arg(ap, unsigned int));
	    break;
	  case _C_INT:
	    val = gh_long2scm(va_arg(ap, int));
	    break;
	  case _C_UINT:
	    val = gh_ulong2scm(va_arg(ap, unsigned int));
	    break;
	  case _C_LNG:
	    val = gh_long2scm(va_arg(ap, long));
	    break;
	  case _C_ULNG:
	    val = gh_ulong2scm(va_arg(ap, unsigned long));
	    break;
	  case _C_FLT:
	    val = gh_double2scm(va_arg(ap, double));
	    break;
	  case _C_DBL:
	    val = gh_double2scm(va_arg(ap, double));
	    break;
	  case _C_CHARPTR:
	    val = gh_str02scm(va_arg(ap, char*));
	    break;
	  case _C_PTR:
	    val = gstep_voidp2scm(va_arg(ap, void*), NO, NO, 0);
	    break;
	  case _C_STRUCT_B:
	    {
	      int size = objc_sizeof_type(tmptype);
	      {
		struct dummy {
		  char	val[size];
		} block;
		int	offset = 0;
	        char	*ptr = tmptype;

		block = va_arg(ap, struct dummy);
		val = gstep_guile_encode_item((void*)&block, &offset,
			      &ptr, NO, NO, nil, 0);
	      }
	    }
	    break;
	  default:
	    [NSException raise: NSInvalidArgumentException
			format: @"gstep_send_msg_to_guile - don't handle "
				@"that type yet - %s", procname]; break;
	}
      tmptype = objc_skip_argspec(tmptype);
      gh_defer_ints();
      if (argsEnd == 0)
	{
	  SCM_NEWCELL(argsEnd);
	  SCM_SETCAR(argsEnd, val);
	  SCM_SETCDR(argsEnd, SCM_EOL);
	  argsList = argsEnd;
	}
      else
	{
	  SCM	tmp;
	  SCM_NEWCELL(tmp);
	  SCM_SETCAR(tmp, val);
	  SCM_SETCDR(tmp, gh_cdr(argsEnd));
	  SCM_SETCDR(argsEnd, tmp);
	  argsEnd = tmp;
	}
      gh_allow_ints();
    }
  va_end(ap);

  /*
   *	Now call the guile procedure.
   */
  data.proc = proc;
  data.receiver = receiver;
  data.selname = gh_str02scm((char*)selname);
  data.argslist = argsList;

  /* FIXME: older versions of guile need scm_catch_body_t and
   * scm_catch_handler_t here.
   */
  val = gh_catch(SCM_BOOL_T, (scm_t_catch_body)proc_wrapper, (void*)&data,
		 (scm_t_catch_handler)proc_error, (void*)procname);

  /*
   *	Now decode the Guile return value into the correct ObjectiveC
   *	data type and return it.
   */
  switch (*type)
    {
      case _C_ID:
      case _C_CLASS:
	{
	  if (gstep_id_p(val) == 0)
	    [NSException raise: NSGenericException
			format: @"%s - return value is not an object",
			procname];
	  return((void*)gh_cdr(val));
	}
      case _C_SEL:
	{
	  char *s;
	  int l;
	  if (SCM_STRINGP(val) == 0)
	    [NSException raise: NSGenericException
			format: @"%s - return value is not a selector",
			procname];
	  gstep_scm2str(&s, &l, &val);
	  return((void*) sel_get_any_typed_uid(s));
	}
      case _C_CHR:
	if (SCM_INUMP(val) == 0)
	  [NSException raise: NSGenericException
		      format: @"%s - return values is not an integer",
			procname];
	return(apply_char((char) gh_scm2long(val)));
      case _C_UCHR:
	if (SCM_BOOL_F==val)
	  return(apply_char(NO));
	else if (SCM_BOOL_T==val)
	  return(apply_char(YES));
	else
	  {
	    if ((SCM_INUMP(val) && gh_scm2long(val) >= 0) == 0)
	      [NSException raise: NSGenericException
			  format: @"%s - return value is not an unsigned int",
			procname];
	    return(apply_char((unsigned char)gh_scm2long(val)));
	  }
      case _C_SHT:
	if (SCM_INUMP(val) == 0)
	  [NSException raise: NSGenericException
		      format: @"%s - return value is not an integer",
			procname];
	return(apply_short((short)gh_scm2long(val)));
      case _C_USHT:
	if ((SCM_INUMP(val) && gh_scm2long(val) >= 0) == 0)
	  [NSException raise: NSGenericException
		      format: @"%s - return value is not an unsigned int",
			procname];
	return(apply_short((unsigned short)gh_scm2long(val)));
      case _C_INT:
	if (SCM_INUMP(val) == 0)
	  [NSException raise: NSGenericException
		      format: @"%s - return value is not an integer",
			procname];
	return((void*) gh_scm2long(val));
      case _C_UINT:
	if ((SCM_INUMP(val) && gh_scm2long(val) >= 0) == 0)
	  [NSException raise: NSGenericException
		      format: @"%s - return value is not an unsigned int",
			procname];
	return((void*) gh_scm2long(val));
      case _C_LNG:
	if (SCM_INUMP(val) == 0)
	  [NSException raise: NSGenericException
		      format: @"%s - return value is not an integer",
			procname];
	return((void*) gh_scm2long(val));
      case _C_ULNG:
	if ((SCM_INUMP(val) && gh_scm2long(val) >= 0) == 0)
	  [NSException raise: NSGenericException
		      format: @"%s - return value is not an unsigned int",
			procname];
	return((void*) gh_scm2long(val));
      case _C_FLT:
	if (SCM_INUMP(val))
	  return(apply_float((float) gh_scm2long(val)));
	else
	  {
	    double d;	/* debugging */
	    d = gh_scm2double(val);
	    return(apply_float((float) d));
	  }
      case _C_DBL:
	if (SCM_INUMP(val))
	  return(apply_double((double) gh_scm2long(val)));
	else
	  return(apply_double((double) gh_scm2double(val)));
      case _C_CHARPTR:
	{
	  NSMutableData *d;
	  char *s;
	  int l;
	  if ((SCM_NIMP(val) && SCM_STRINGP(val)) == 0)
	    [NSException raise: NSGenericException
			format: @"%s - return value is not a string", procname];

	  s = gh_scm2newstr(val, &l);
	  d = [NSMutableData dataWithBytesNoCopy: s length: l];
	  return [d mutableBytes];
	}
      case _C_PTR:
	{
	  if ((SCM_NIMP(val) && OBJC_VOIDP_P(val)) == 0)
	    [NSException raise: NSGenericException
			format: @"%s return value is not a pointer", procname];
	  return ((voidp)gh_cdr(val))->ptr;
	}
      case _C_STRUCT_B:
	{
	  void	*datum = alloca(objc_sizeof_type(type));
	  int		offset = 0;

	  gstep_guile_decode_item(val, datum, &offset, &type);
	  return(apply_block(datum));
	}
      case _C_VOID:
	break;
      default:
	[NSException raise: NSGenericException
		    format: @"%s - don't handle that return type yet",
			procname];
    }
  retframe = alloca(sizeof(void*));
  return retframe;
}

/*
 *	Utility procedure to create class-method mapping information for
 *	calling Guile procedures as method implementations.
 */
static SCM
gstep_class_info(Class objcClass, Module_t module)
{
  class_info	*cls;
  SCM		wrap;

  gh_defer_ints();
  if (knownClasses == 0)
    {
      knownClasses = NSCreateMapTable(NSNonOwnedPointerMapKeyCallBacks,
		    NSNonOwnedPointerMapValueCallBacks, 0);
    }
  else if (module == 0)
    {
      wrap = (SCM)NSMapGet(knownClasses, objcClass->name);
      if (wrap != 0)
	{
	  gh_allow_ints();
	  return wrap;
	}
    }

  /*
   *	Create class information structure to hold info about new class.
   */
  cls = objc_malloc(sizeof(class_info));
  cls->objc_runtime_info = module;
  cls->instance_methods = NSCreateMapTable(NSObjectMapKeyCallBacks,
		    NSNonOwnedPointerMapValueCallBacks, 0);
  cls->factory_methods = NSCreateMapTable(NSObjectMapKeyCallBacks,
		    NSNonOwnedPointerMapValueCallBacks, 0);

  /*
   *	Create Gstep-Guile class wrapper to pass back into Guile.
   *	This smob is responsible for ensuring that the Guile procedures
   *	representing the methods of the class are never garbage collected.
   */
  SCM_NEWCELL(wrap);
  SCM_SETCAR(wrap, gstep_scm_tc16_class);
  SCM_SETCDR(wrap, (SCM)cls);
  scm_permanent_object(wrap);	/* Don't let class be garbage collected. */

  /*
   *	Insert info about our new class into lookup table so that
   *	gstep_send_msg_to_guile() can perform lookups.
   */
  NSMapInsert(knownClasses, objcClass->name, (void*)wrap);

  gh_allow_ints();
  return wrap;
}

/*
 *	Internal routine for adding methods to a class.
 */
static SCM
gstep_add_methods(Class dest, SCM mlist, BOOL instance)
{
#ifdef objc_EXPORT
  objc_EXPORT
#else
  extern
#endif
  objc_mutex_t __objc_runtime_mutex;
  MethodList		*ml = 0;
  SCM			classn = gh_str02scm((char*)dest->name);
  SCM			tmp;
  int			count;
  class_info		*cls;
  SCM			wrap;
  BOOL			ok = YES;

  wrap = gstep_class_info(dest, 0);
  cls = (class_info*)gh_cdr(wrap);

  if (mlist == SCM_EOL)
    {
      return wrap;		/* Nothing to do.	*/
    }

  for (tmp = mlist; tmp != SCM_EOL; tmp = gh_cdr(tmp))
    {
      SCM	list = gh_car(tmp);
      SCM	val;
      char	*type;
      int	len;

      if (list == 0 || gstep_guile_list_length(list) != 3)
	{
	  gstep_scm_error("wrong number of items in method specification",
	      classn);
	}
      val = gh_car(list);
      if ((SCM_NIMP(val) && SCM_STRINGP(val)) == 0)
	{
	  gstep_scm_error("method name is not a string", classn);
	}
      val = gh_cadr(list);
      if ((SCM_NIMP(val) && SCM_STRINGP(val)) == 0)
	{
	  gstep_scm_error("method type is not a string", classn);
	}
      gstep_scm2str(&type, &len, &val);
      if (gstep_guile_check_types(type) == 0)
	{
	  gstep_scm_error("method type is not legal", classn);
	}
      val = gh_caddr(list);
      if (SCM_NIMP(val) && SCM_SYMBOLP(val))
	{
	  val = scm_symbol_to_string(val);
	}
      if (SCM_NIMP(val) && SCM_STRINGP(val))
	{
	  char *name = gh_scm2newstr(val, 0);
	  val = gh_lookup((char*)name);
	  free(name);
	}
      if (gh_procedure_p(val) == 0)
	{
	  gstep_scm_error("method implementation is not a procedure", classn);
	}
    }

  /*
   *	Build method info from list.
   */
  {
    CREATE_AUTORELEASE_POOL(arp);

    NS_DURING
      {
	count = gstep_guile_list_length(mlist);
	if (count > 0)
	  {
	    int	extra = sizeof(struct objc_method) * (count - 1);

	    ml = objc_calloc(1, sizeof(MethodList) + extra);
	    ml->method_count = count;
	    count = 0;
	    for (tmp = mlist; tmp != SCM_EOL; tmp = gh_cdr(tmp))
	      {
		SCM	mname = gh_caar(tmp);
		SCM	mtype = gh_cadar(tmp);
		SCM	mimp = gh_car(gh_cddar(tmp));
		NSMethodSignature	*sig;
		char	*types = gh_scm2newstr(mtype, 0);
		char	*mtypes;

		sig = [NSMethodSignature signatureWithObjCTypes: types];
		free(types);
  #if	defined(GNUSTEP_BASE_VERSION)
		types = (char*)[sig methodType];
  #elif	defined(LIB_FOUNDATION_LIBRARY)
		types = (char*)[sig types];
  #else
  #include "DON'T KNOW HOW TO GET METHOD SIGNATURE INFO"
  #endif
		mtypes = objc_malloc(strlen(types)+1);
		strcpy(mtypes, types);
		ml->method_list[count].method_name=(SEL)gh_scm2newstr(mname, 0);
		ml->method_list[count].method_types=mtypes;
		ml->method_list[count].method_imp=(IMP)gstep_send_msg_to_guile;
		if (SCM_NIMP(mimp) && SCM_SYMBOLP(mimp))
		  {
		    mimp = scm_symbol_to_string(mimp);
		  }
		if (SCM_NIMP(mimp) && SCM_STRINGP(mimp))
		  {
		    char *name = gh_scm2newstr(mimp, 0);
		    mimp = gh_lookup((char*)name);
		    free(name);
		  }
		scm_protect_object(mimp);	// Protect from GC
		if (instance == YES)
		  {
		    NSMapInsert(cls->instance_methods,
		      [NSString stringWithCString:
			(char*)ml->method_list[count].method_name],
			(void*)mimp);
		  }
		else
		  {
		    NSMapInsert(cls->factory_methods,
		      [NSString stringWithCString:
			(char*)ml->method_list[count].method_name],
			(void*)mimp);
		  }
		count++;
	      }
	  }
      }
    NS_HANDLER
      {
	ok = NO;
      }
    NS_ENDHANDLER
    DESTROY(arp);
  }

  if (ok == NO)
    {
      return gstep_id2scm(nil, 0);		/* Error! */
    }
  if (instance == NO)
    {
      dest = (Class)dest->class_pointer;	/* Use meta class.	*/
    }
  objc_mutex_lock(__objc_runtime_mutex);
  class_add_method_list(dest, ml);
  objc_mutex_unlock(__objc_runtime_mutex);
  return wrap;
}



static char gstep_lookup_class_n[] = "gstep-lookup-class";

static SCM
gstep_lookup_class_fn (SCM classname)
{
  if (SCM_NIMP(classname) && SCM_SYMBOLP(classname))
    {
      classname = scm_symbol_to_string(classname);
    }
  if (SCM_NIMP(classname) && SCM_STRINGP(classname))
    {
      char	*name;
      int	len;
      id	class;

      name = gh_scm2newstr(classname, &len);
      class = (id) objc_lookup_class(name);
      free(name);
      return gstep_id2scm(class, NO);
    }
  else
    {
      gstep_scm_error("not a symbol or string", classname);
      return gstep_id2scm(nil, NO);
    }
}


static char gstep_classnames_n[] = "gstep-classnames";

static SCM
gstep_classnames_fn()
{
  void	*enum_state = NULL;
  Class	class;
  SCM	answer;

  answer = SCM_EOL;
  while ((class = objc_next_class(&enum_state)))
    {
      answer = scm_cons(scm_makfrom0str(class -> name), answer);
    }
  return answer;
}



static char gstep_new_class_n[] = "gstep-new-class";
/*
 *	Procedure to create a new class!
 */
static SCM
gstep_new_class_fn(SCM classn, SCM supern, SCM ilist, SCM mlist, SCM clist)
{
  extern void	__objc_exec_class(void*);
  Module_t	module;
  Symtab_t	symtab;
  Class		new_class;
  char		*cname = 0;
  char		*sname = 0;
  id		sclass = nil;
  SCM		tmp;
  int		ivarsize = 0;
  int		num_ivars = 0;

  for (tmp = ilist; tmp != SCM_EOL; tmp = gh_cdr(tmp))
    {
      SCM	name = gh_caar(tmp);
      SCM	type = gh_cdar(tmp);
      char	*ptr;
      int	len;

      if ((SCM_NIMP(name) && SCM_STRINGP(name)) == 0)
	{
	  gstep_scm_error("variable name is not a string", classn);
	}
      if ((SCM_NIMP(type) && SCM_STRINGP(type)) == 0)
	{
	  gstep_scm_error("variable type is not a string", classn);
	}
      gstep_scm2str(&ptr, &len, &type);
      if (gstep_guile_check_type(ptr) == 0)
	{
	  gstep_scm_error("variable type is not legal", classn);
	}
      num_ivars++;
    }

  /*
   *	Get the name for the new class and check that it isn't already in use.
   */
  if (SCM_NIMP(classn) && SCM_SYMBOLP(classn))
    {
      classn = scm_symbol_to_string(classn);
    }
  if (SCM_NIMP(classn) && SCM_STRINGP(classn))
    {
      cname = gh_scm2newstr(classn, 0);
      if (objc_lookup_class(cname) != nil)
	{
	  free(cname);
	  gstep_scm_error("the named class already exists", classn);
	}
    }
  else
    {
      gstep_scm_error("not a symbol or string", classn);
    }

  /*
   *	Get the super class to use and check that it is based on NSObject.
   */
  if (SCM_NIMP(supern) && SCM_SYMBOLP(supern))
    {
      supern = scm_symbol_to_string(supern);
    }
  if (SCM_NIMP(supern) && SCM_STRINGP(supern))
    {
      Class	want1 = [NSObject class];
      Class	want2 = [NSProxy class];
      Class	class;

      sname = gh_scm2newstr(supern, 0);
      sclass = objc_lookup_class(sname);

      class = sclass;
      while (class != nil)
	{
	  if (class == want1 || class == want2)
	    {
	      break;
	    }
	  class = class_get_super_class(class);
	}

      if (class == nil)
	{
	  free(cname);
	  free(sname);
	  gstep_scm_error("the superclass isn't based on NSObject or NSProxy",
	    supern);
	}
    }
  else
    {
      gstep_scm_error("not a symbol or string", supern);
    }

  module = objc_calloc(1, sizeof(Module));
  module->version = OBJC_VERSION;
  module->size = sizeof(*module);
  module->name = objc_malloc(strlen(cname) + 13);
  strcpy((char*)module->name, "Gstep-Guile-");
  strcat((char*)module->name, cname);
  module->symtab = objc_calloc(2, sizeof(Symtab));

  symtab = module->symtab;
  symtab->sel_ref_cnt = 0;
  symtab->refs = 0;
  symtab->cls_def_cnt = 1;	/* We are defining a single class.	*/
  symtab->cat_def_cnt = 0;
  symtab->defs[1] = 0;	/* Nul terminate the list.		*/
  symtab->defs[0] = objc_calloc(2, sizeof(struct objc_class));

  /*
   *	Build class structure.
   */
  new_class = (Class)symtab->defs[0];
  new_class->class_pointer = &new_class[1];
  new_class->super_class = (Class)sname;
  new_class->class_pointer->super_class = (Class)sname;
  new_class->name = cname;
  new_class->class_pointer->name = cname;
  new_class->version = 0;
  new_class->class_pointer->version = 0;
  new_class->info = _CLS_CLASS;
  new_class->class_pointer->info = _CLS_META;

  ivarsize = ((Class)sclass)->instance_size;
  if (num_ivars > 0) {
      struct objc_ivar	*ivar;

      new_class->ivars = (struct objc_ivar_list*)
	objc_malloc(sizeof(struct objc_ivar_list)
	+ (num_ivars-1)*sizeof(struct objc_ivar));
      new_class->ivars->ivar_count = num_ivars;
      ivar = new_class->ivars->ivar_list;

      for (tmp = ilist; tmp != SCM_EOL; tmp = gh_cdr(tmp))
	{
	  SCM	name = gh_caar(tmp);
	  SCM	type = gh_cdar(tmp);
	  int	align;

	  ivar->ivar_name = gh_scm2newstr(name, 0);
	  ivar->ivar_type = gh_scm2newstr(type, 0);

	  align = objc_alignof_type(ivar->ivar_type); /* pad to alignment */
	  ivarsize = ROUND(ivarsize, align);
	  ivar->ivar_offset = ivarsize;
	  ivarsize += objc_sizeof_type(ivar->ivar_type);
	  ivar++;
	}
  }
  new_class->instance_size = ivarsize;
  new_class->class_pointer->instance_size
    = ((Class)sclass)->class_pointer->instance_size;

  /*
   *	Insert our new class into the runtime.
   */
  __objc_exec_class(module);
  __objc_resolve_class_links();
  free(sname);

  /*
   *	Add methods to our new class.
   */
  gstep_add_methods(new_class, clist, NO);
  return gstep_add_methods(new_class, mlist, YES);
}

static char gstep_class_methods_n[] = "gstep-class-methods";
/*
 *	Procedure to add class methods to a class.
 */
static SCM
gstep_class_methods_fn(SCM classn, SCM mlist)
{
  char	*cname;
  Class	dest;

  if (SCM_NIMP(classn) && SCM_SYMBOLP(classn))
    {
      classn = scm_symbol_to_string(classn);
    }
  if (SCM_NIMP(classn) && SCM_STRINGP(classn))
    {
      cname = gh_scm2newstr(classn, 0);
      dest = objc_lookup_class(cname);
      free(cname);
      if (dest == nil)
	{
	  gstep_scm_error("the named class does not exists", classn);
	}
    }
  else
    {
      gstep_scm_error("not a symbol or string", classn);
    }

  return gstep_add_methods(dest, mlist, NO);
}

static char gstep_instance_methods_n[] = "gstep-instance-methods";
/*
 *	Procedure to add instance methods to a class.
 */
static SCM
gstep_instance_methods_fn(SCM classn, SCM mlist)
{
  char	*cname;
  Class	dest;

  if (SCM_NIMP(classn) && SCM_SYMBOLP(classn))
    {
      classn = scm_symbol_to_string(classn);
    }
  if (SCM_NIMP(classn) && SCM_STRINGP(classn))
    {
      cname = gh_scm2newstr(classn, 0);
      dest = objc_lookup_class(cname);
      free(cname);
      if (dest == nil)
	{
	  gstep_scm_error("the named class does not exists", classn);
	}
    }
  else
    {
      gstep_scm_error("not a symbol or string", classn);
    }

  return gstep_add_methods(dest, mlist, YES);
}



void
gstep_init_class()
{
#if	GUILE_MAKE_SMOB_TYPE
  gstep_scm_tc16_class = scm_make_smob_type ("gg_class", 0);
  scm_set_smob_mark(gstep_scm_tc16_class, mark_gstep_class);
  scm_set_smob_free(gstep_scm_tc16_class, free_gstep_class);
  scm_set_smob_print(gstep_scm_tc16_class, print_gstep_class);
  scm_set_smob_equalp(gstep_scm_tc16_class, equal_gstep_class);
#else
  static struct scm_smobfuns gstep_class_smob = {
    mark_gstep_class,
    free_gstep_class,
    print_gstep_class,
    equal_gstep_class
  };

  gstep_scm_tc16_class = scm_newsmob (&gstep_class_smob);
#endif

  /*
   *	Stuff to do with classes
   */
  CFUN(gstep_lookup_class_n, 1, 0, 0, gstep_lookup_class_fn);
  CFUN(gstep_classnames_n, 0, 0, 0, gstep_classnames_fn);
  CFUN(gstep_new_class_n, 5, 0, 0, gstep_new_class_fn);
  CFUN(gstep_class_methods_n, 2, 0, 0, gstep_class_methods_fn);
  CFUN(gstep_instance_methods_n, 2, 0, 0, gstep_instance_methods_fn);
}

