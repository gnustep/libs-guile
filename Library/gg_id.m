/* gg_id.m - interface between guile and GNUstep
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

#include <objc/objc.h>
#include <objc/objc-api.h>
#include <objc/encoding.h>
#include <objc/Protocol.h>

#include <stdarg.h>

#include <Foundation/NSObject.h>

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

#include "gstep_guile.h"
#include "private.h"

static SCM gstep_nil = 0;
static SCM gstep_get_nil_fn();



/*
 *	SMOB stuff for the Guile wrappers for ObjectiveC objects.
 */
int gstep_scm_tc16_id;
static NSMapTable *knownObjects = 0;

static SCM equal_gstep_id (SCM s1, SCM s2);
static scm_sizet free_gstep_id (SCM obj);
static int print_gstep_id (SCM exp, SCM port, scm_print_state *pstate);
static SCM mark_gstep_id (SCM obj);

static SCM 
mark_gstep_id (SCM obj)
{
  if (SCM_GC8MARKP (obj))
    return SCM_BOOL_F;
  
  SCM_SETGC8MARK (obj);
  return SCM_BOOL_F;
}

static SCM  
equal_gstep_id (SCM s1, SCM s2)
{
  if (gh_cdr(s1) == gh_cdr(s2))
    return SCM_BOOL_T;
  else
    return SCM_BOOL_F;
}

static scm_sizet 
free_gstep_id (SCM obj)
{
    id	o = (id)gh_cdr(obj);

    if (o != nil) {
	NSMapRemove(knownObjects, (void*)o);
	if ([o respondsTo: @selector(release)]) {
	    [o release];
	}
    }
    return (scm_sizet)0;
}

static int
print_gstep_id (SCM exp, SCM port, scm_print_state *pstate)
{
  id o;
  
  o = (id) gh_cdr(exp);	
  if (gstep_guile_object_is_class(o))
    scm_display(gh_str02scm("#<gstep-id (Class)"), port);
  else
    scm_display(gh_str02scm("#<gstep-id "), port);

  scm_display(gh_str02scm("0x"), port);
  scm_intprint((long)o, 16, port);

  scm_display(gh_str02scm(" "), port);
  
  if (o == nil)
    scm_display(gh_str02scm("nil"), port);
  else
    scm_display(gh_str02scm((char*)class_get_class_name([o class])), port);

  if ([o respondsTo:@selector(printForGuile:)])
    [o printForGuile:port];

  scm_display(gh_str02scm(">"), port);

  return 1;
}



/*
 *	Utility functions for Guile wrappers for ObjectiveC objects.
 */
void
gstep_fixup_id(SCM obj)
{
    id	o = (id)gh_cdr(obj);

    /*
     *	Fixup for the case where an object has been destroyed by the objc
     *	world and we need to adjust the guile world to reflect that.
     */
    if (o != nil) {
	NSMapRemove(knownObjects, (void*)o);
	SCM_SETCDR(obj, (SCM)nil); 
    }
}

SCM
gstep_id2scm(id o, BOOL shouldRetain)
{
    SCM	answer;

    /* Only ever make one copy of a nil object  */
    if (o == nil) {
	if (gstep_nil == 0) {
	    gh_defer_ints();
	    SCM_NEWCELL(answer);
	    SCM_SETCAR(answer, gstep_scm_tc16_id); 
	    SCM_SETCDR(answer, (SCM)o); 
	    gstep_nil = answer;
	    scm_permanent_object(gstep_nil); /* Don't garbage collect */
	    gh_allow_ints();
	}
	return gstep_nil;
    }

    gh_defer_ints();
    if (knownObjects == 0) {
	knownObjects = NSCreateMapTable(NSNonOwnedPointerMapKeyCallBacks,
                      NSNonOwnedPointerMapValueCallBacks, 0);
	answer = 0;
    }
    else {
	answer = (SCM)NSMapGet(knownObjects, (void*)o);
    }
    if (answer == 0) {
	SCM_NEWCELL(answer);
	SCM_SETCAR(answer, gstep_scm_tc16_id); 
	SCM_SETCDR(answer, (SCM)o); 
	NSMapInsertKnownAbsent(knownObjects, (void*)o, (void*)answer);
	if (shouldRetain && [o respondsTo: @selector(retain)]) {
	    [o retain];
	}
    }
    gh_allow_ints();

    return answer;
}

id
gstep_scm2id (SCM o)
{
    if (SCM_NIMP(o) && OBJC_ID_P(o)) {
	return (id)gh_cdr(o);
    }
    else {
	return nil;
    }
}


static char gstep_id_p_n[] = "gstep-id?";

SCM
gstep_scm_id_p (SCM obj) 
{
  if (SCM_NIMP(obj) && OBJC_ID_P(obj)) 
    return SCM_BOOL_T; 
  else
    return SCM_BOOL_F;    
}

int
gstep_id_p (SCM val)
{
  return (gstep_scm_id_p (val) == SCM_BOOL_T) ? 1 : 0;
}


static char gstep_ivarnames_n[] = "gstep-ivarnames";

static SCM 
gstep_ivarnames_fn (SCM receiver)
{
    Class	class;
    id		self = nil;
    struct objc_ivar_list	*ivars;
    SCM	item = SCM_EOL;

    if (SCM_NIMP(receiver) && OBJC_ID_P(receiver)) {
	self = (id)gh_cdr(receiver);
	if (!self) {
	    return receiver;	/* objc nil */
	}
    }
    if (self == nil) {
	gstep_scm_error("not an object", receiver);
    }

    if (gstep_guile_object_is_class(self))
	class = self;
    else
	class = self->class_pointer;

    while (class != nil) {
	int	i;

	ivars = class->ivars;
	class = class->super_class;
	if (ivars) {
	    for (i = 0; i < ivars->ivar_count; i++) {
		const char*	name = ivars->ivar_list[i].ivar_name;

		item = scm_cons(scm_makfrom0str(name), item);
	    }
	}
    }
    return item;
}


static char gstep_get_ivar_n[] = "gstep-get-ivar";

static SCM 
gstep_get_ivar_fn (SCM receiver, SCM ivarname)
{
    char	*name;
    Class	class;
    id		self = nil;
    struct objc_ivar_list	*ivars;
    struct objc_ivar		*ivar = 0;
    SCM	item;
    int		offset;
    const char	*type;

    if (SCM_NIMP(receiver) && OBJC_ID_P(receiver)) {
	self = (id)gh_cdr(receiver);
	if (!self) {
	    return receiver;	/* objc nil */
	}
	if (gstep_guile_object_is_class(self)) {
	    self = nil;
	}
    }
    if (self == nil) {
	gstep_scm_error("not an object instance", receiver);
    }

    if (SCM_NIMP(ivarname) && SCM_SYMBOLP(ivarname)) {
	ivarname = scm_symbol_to_string(ivarname);
    }
    if (SCM_NIMP(ivarname) && SCM_STRINGP(ivarname)) {
	int	len;

	name = gh_scm2newstr(ivarname, &len);
    }
    else {
	gstep_scm_error("not a symbol or string", ivarname);
    }

    class = self->class_pointer;
    while (class != nil && ivar == 0) {
	ivars = class->ivars;
	class = class->super_class;
	if (ivars) {
	    int	i;

	    for (i = 0; i < ivars->ivar_count; i++) {
		if (strcmp(ivars->ivar_list[i].ivar_name, name) == 0) {
		    ivar = &ivars->ivar_list[i];
		    break;
		}
	    }
	}
    }
    free(name);
    if (ivar == 0) {
	gstep_scm_error("not defined for object", ivarname);
    }

    offset = ivar->ivar_offset;
    type = ivar->ivar_type;

    item = gstep_guile_encode_item((void*)self, &offset, &type, NO, NO, nil, 0);
    return item;
}



static char gstep_ptr_ivar_n[] = "gstep-ptr-ivar";

static SCM 
gstep_ptr_ivar_fn (SCM receiver, SCM ivarname)
{
    char	*name;
    Class	class;
    id		self = nil;
    struct objc_ivar_list	*ivars;
    struct objc_ivar		*ivar = 0;
    int		offset;
    const char	*type;
    void	*addr;

    if (SCM_NIMP(receiver) && OBJC_ID_P(receiver)) {
	self = (id)gh_cdr(receiver);
	if (!self) {
	    return gstep_voidp2scm(0, NO, YES, 0);	// nul pointer
	}
	if (gstep_guile_object_is_class(self)) {
	    self = nil;
	}
    }
    if (self == nil) {
	gstep_scm_error("not an object instance", receiver);
    }

    if (SCM_NIMP(ivarname) && SCM_SYMBOLP(ivarname)) {
	ivarname = scm_symbol_to_string(ivarname);
    }
    if (SCM_NIMP(ivarname) && SCM_STRINGP(ivarname)) {
	int	len;

	name = gh_scm2newstr(ivarname, &len);
    }
    else {
	gstep_scm_error("not a symbol or string", ivarname);
    }

    class = self->class_pointer;
    while (class != nil && ivar == 0) {
	ivars = class->ivars;
	class = class->super_class;
	if (ivars) {
	    int	i;

	    for (i = 0; i < ivars->ivar_count; i++) {
		if (strcmp(ivars->ivar_list[i].ivar_name, name) == 0) {
		    ivar = &ivars->ivar_list[i];
		    break;
		}
	    }
	}
    }
    free(name);
    if (ivar == 0) {
	gstep_scm_error("not defined for object", ivarname);
    }

    offset = ivar->ivar_offset;
    addr = ((void*)self)+offset;
    type = ivar->ivar_type;

    return gstep_voidp2scm(addr, NO, YES, objc_sizeof_type(type));
}


static char gstep_set_ivar_n[] = "gstep-set-ivar";

static SCM 
gstep_set_ivar_fn (SCM receiver, SCM ivarname, SCM value)
{
    char	*name;
    Class	class;
    id		self = nil;
    struct objc_ivar_list	*ivars;
    struct objc_ivar		*ivar = 0;
    int		offset;
    const char	*type;

    if (SCM_NIMP(receiver) && OBJC_ID_P(receiver)) {
	self = (id)gh_cdr(receiver);
	if (!self) {
	    return receiver;	/* objc nil */
	}
	if (gstep_guile_object_is_class(self)) {
	    self = nil;
	}
    }
    if (self == nil) {
	gstep_scm_error("not an object instance", receiver);
    }

    if (SCM_NIMP(ivarname) && SCM_SYMBOLP(ivarname)) {
	ivarname = scm_symbol_to_string(ivarname);
    }
    if (SCM_NIMP(ivarname) && SCM_STRINGP(ivarname)) {
	int	len;

	name = gh_scm2newstr(ivarname, &len);
    }
    else {
	gstep_scm_error("not a symbol or string", ivarname);
    }

    class = self->class_pointer;
    while (class != nil && ivar == 0) {
	ivars = class->ivars;
	class = class->super_class;
	if (ivars) {
	    int	i;

	    for (i = 0; i < ivars->ivar_count; i++) {
		if (strcmp(ivars->ivar_list[i].ivar_name, name) == 0) {
		    ivar = &ivars->ivar_list[i];
		    break;
		}
	    }
	}
    }
    if (ivar == 0) {
	gstep_scm_error("not defined for object", ivarname);
    }

    offset = ivar->ivar_offset;
    type = ivar->ivar_type;

    if (gstep_guile_decode_item(value, (void*)self, &offset, &type))
	return SCM_BOOL_T;
    else
	return SCM_BOOL_F;
}


static char gstep_msg_send_n[] = "gstep-msg-send";

@interface	Hack
{
@public
    Class	isa;
}
@end

static int
get_number_of_arguments (const char *type)
{
  int i = 0;
  while (*type)
    {
      type = objc_skip_argspec (type);
      i += 1;
    }
  return i - 1;
}

static SCM
gstep_msg_send_fn (SCM receiver, SCM method, SCM args_list)
{
  id self;
  char *method_name;
  const char *method_types;
  SEL selector;
  int args_list_len;
  SCM next_arg;
  SCM ret = SCM_UNDEFINED;
  Method_t m;
  NSAutoreleasePool *arp;
  NSMethodSignature *signature;

  /* Get the receiver */
  if (SCM_NIMP(receiver))
    {
      if (SCM_SYMBOLP(receiver))
	{
	  receiver = scm_symbol_to_string(receiver);
	}
      if (SCM_STRINGP(receiver))
	{
	  char	*name;
	  int	len;
	  id	class;

	  name = gh_scm2newstr(receiver, &len);
	  class = (id) objc_lookup_class(name);
	  free(name);
	  if (class == nil)
	    {
	      gstep_scm_error("not a symbol or string", receiver);
	    }
	  else
	    {
	      receiver = gstep_id2scm(class, NO);
	    }
	}
    }
  if (SCM_NIMP(receiver) && OBJC_ID_P(receiver))
    {
      self = (id)gh_cdr(receiver);
      if (!self)
	return receiver;	/* objc nil */
    }
  else
    {
      SCM_ASSERT (0, receiver, SCM_ARG1, gstep_msg_send_n);
    }

  /* Get the selector */
  if (SCM_NIMP(method) && SCM_SYMBOLP(method))
    {
      method = scm_symbol_to_string(method);
    }
  if (SCM_NIMP(method) && SCM_STRINGP(method))
    {
      int method_name_len;
      gstep_scm2str(&method_name, &method_name_len, &method);
    }
  else
    {
      SCM_ASSERT (0, method, SCM_ARG2, gstep_msg_send_n);
    }

  selector = sel_get_any_typed_uid(method_name);
  
  if (!selector)
    {
    /*
     *	If no selector, we may have a proxy object that can return a
     *  method signature to be used in creating a selector - so try that.
     */
      selector = sel_get_uid(method_name);
      if (selector)
	{
	  arp = [NSAutoreleasePool new];
	  NS_DURING
	    {
	      signature = [self methodSignatureForSelector: selector];
	      if (signature == nil) {
		NSLog(@"did not find signature for selector '%s' ..",
		      method_name);
		selector = 0;
	      }
	      else {
		method_types = [signature methodType];
		selector = sel_register_typed_name(method_name, method_types);
	      }
	    }
	  NS_HANDLER
	    {
	      selector = 0;
	    }
	  NS_ENDHANDLER
	  [arp release];
	}
	if (selector == 0)
	  {
	    gstep_scm_error("no such selector", method);
	    return SCM_BOOL_F;
	  }
    }

  /* Try to get the actual method to be invoked so we can get the return
     type correct in case there are multiple implementations of the method
     with different return types */
  m = (gstep_guile_object_is_class(self)
	    ?class_get_class_method(((Hack*)self)->isa, selector)
	    :class_get_instance_method(((Hack*)self)->isa, selector));

  if (m != METHOD_NULL)
    {
      selector = m->method_name;
      method_types = m->method_types;
    }
  else
    method_types = sel_get_type(selector);

  if (!method_types)
    {
      gstep_scm_error("no method_types with this selector", method);
      return SCM_BOOL_F;
    }

  /* Check the number of arguments */
  args_list_len = scm_ilength(args_list);
  if (args_list_len + 2 != get_number_of_arguments(method_types))
    {
      gstep_scm_error("wrong number of arguments", method);
      return SCM_BOOL_F;
    }

  next_arg = args_list;
  {
    SCM	s_name = SCM_UNDEFINED;
    SCM	s_reason = SCM_UNDEFINED;
    NSInvocation	*invocation = nil;
    int			count;
    void		*data;
    const char		*type;

    arp = [NSAutoreleasePool new];
    NS_DURING
      {
	signature = [self methodSignatureForSelector: selector];
	if (signature == nil) {
	  signature = [NSMethodSignature signatureWithObjCTypes: method_types];
	}
	if (signature == nil) {
	  NSLog(@"did not find signature for selector '%@' ..",
		NSStringFromSelector(selector));
	  return SCM_BOOL_F;
	}
	invocation = [NSInvocation invocationWithMethodSignature: signature];
	[invocation setTarget: self];
	[invocation setSelector: selector];

	for (count = 2; count < [signature numberOfArguments]; count++)
	  {
	    int		offset = 0;

#if	defined(GNUSTEP_BASE_VERSION)
	    type = [signature getArgumentTypeAtIndex: count];
#elif	defined(LIB_FOUNDATION_LIBRARY)
	    type = ([signature argumentInfoAtIndex:count]).type;
#else
#include "DON'T KNOW HOW TO GET METHOD SIGNATURE INFO"
#endif
	    data = alloca(objc_sizeof_type(type));
	    SCM_ASSERT(gstep_guile_decode_item(gh_car(next_arg), data, &offset,
			&type), gh_car(next_arg), count, gstep_msg_send_n);
	    [invocation setArgument: data atIndex: count];

	    next_arg = gh_cdr(next_arg);
	    if (next_arg == SCM_UNDEFINED)
	      {
		gstep_scm_error("argument missing from", method);
		/* return SCM_BOOL_F; */
	      }
	  }

	[invocation invoke];

	type = [signature methodReturnType];
	if (*type != _C_VOID)
	  {
	    BOOL	allocFlag = NO;
	    BOOL	initFlag = NO;
	    int		offset = 0;

	    data = alloca([signature methodReturnLength]);
	    [invocation getReturnValue: data];

	    if ((strncmp(method_name, "new", 3) == 0)
		|| (strncmp(method_name, "copy", 4) == 0)
		|| (strncmp(method_name, "mutableCopy", 11) == 0)
		|| (strncmp(method_name, "alloc", 5) == 0)) {
		/*
		 *	If we get an object returned by a 'new...', 'copy...',
		 *	'mutableCopy...', or 'alloc...' method, then we don't
		 *	need to retain it as it already has a retain count of 1.
		 */
		allocFlag = YES;
	    }
	    if (strncmp(method_name, "init", 4) == 0) {
		/*
		 *	Init is a special case - it normally returns its
		 *	receiver (in which case we won't create a new scheme
		 *	object anyway) but MAY return another object.  If it
		 *	does return another object, we should be the owner
		 *	of that new object, so we need to refrain from
		 *	retaining it.
		 */
		initFlag = YES;
	    }
	    ret = gstep_guile_encode_item(data, &offset, &type, allocFlag,
		initFlag, self, receiver);
	    if (ret == (SCM)0)
		gstep_scm_error("don't handle that return type yet",
			method);
	  }
      }
    NS_HANDLER
      {
	const char *name   = [[localException name] cString];
	const char *reason = [[localException reason] cString];

	s_name = gh_symbol2scm((char*)name);
	s_reason = gh_str02scm((char*)reason);
      }
    NS_ENDHANDLER

    [arp release], arp = nil;
    if (s_name != SCM_UNDEFINED)
      {
	scm_throw(s_name, s_reason);
      }
  }
  return ret;
}



static char gstep_get_nil_n[] = "gstep-get-nil";

static SCM
gstep_get_nil_fn()
{
    return gstep_id2scm(nil, NO);
}



void
gstep_init_id()
{
#if	GUILE_MAKE_SMOB_TYPE
  gstep_scm_tc16_id = scm_make_smob_type ("gg_id", 0);
  scm_set_smob_mark(gstep_scm_tc16_id, mark_gstep_id);
  scm_set_smob_free(gstep_scm_tc16_id, free_gstep_id);
  scm_set_smob_print(gstep_scm_tc16_id, print_gstep_id);
  scm_set_smob_equalp(gstep_scm_tc16_id, equal_gstep_id);
#else
  static struct scm_smobfuns gstep_id_smob = {
    mark_gstep_id,
    free_gstep_id,
    print_gstep_id,
    equal_gstep_id
  };

  gstep_scm_tc16_id = scm_newsmob (&gstep_id_smob);
#endif

  /*
   *	Stuff to do with id's
   */
  scm_make_gsubr(gstep_id_p_n, 1, 0, 0, gstep_scm_id_p);
  scm_make_gsubr(gstep_get_nil_n, 0, 0, 0, gstep_get_nil_fn);
  scm_make_gsubr(gstep_msg_send_n, 2, 0, 1, gstep_msg_send_fn);
  scm_make_gsubr(gstep_ivarnames_n, 1, 0, 0, gstep_ivarnames_fn);
  scm_make_gsubr(gstep_get_ivar_n, 2, 0, 0, gstep_get_ivar_fn);
  scm_make_gsubr(gstep_ptr_ivar_n, 2, 0, 0, gstep_ptr_ivar_fn);
  scm_make_gsubr(gstep_set_ivar_n, 3, 0, 0, gstep_set_ivar_fn);

}

