/* gg_Object.m - interface between guile and GNUstep
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

#include <Foundation/NSMapTable.h>
#include <Foundation/NSMethodSignature.h>
#include <Foundation/NSAutoreleasePool.h>
#include <objc/objc-api.h>

#include "../config.h"
#include "gg_Object.h"
#include "private.h"


static NSMapTable	*objectMap = 0;

/*
 *	Catagory of the old 'Object' class for GNUstep-Guile
 */

@implementation Object (GNUstepGuile)
/*
 *	Class objects should never be released.
 */
+ (void) release
{
  return;
}
+ (id) retain
{
  return self;
}

- (NSMethodSignature*) methodSignatureForSelector: (SEL)aSelector
{
  NSMethodSignature	*sig;

  struct objc_method* mth =
            (object_is_instance(self) ?
                  class_get_instance_method(self->isa, aSelector)
                : class_get_class_method(self->isa, aSelector));
  sig = mth ? [NSMethodSignature signatureWithObjCTypes:mth->method_types]
                : nil;
  return sig;
}

- (void) printForGuile: (SCM)port
{
  CREATE_AUTORELEASE_POOL(pool);

  if (print_for_guile == NULL)
    {
      char	buf[BUFSIZ];

      sprintf(buf, " string=\"<%s: %lx>\"", object_get_class_name(self),
	(unsigned long)self);

      scm_display(gh_str02scm(buf), port);
    }
  else
    {
      print_for_guile(self, _cmd, port);
    }

  DESTROY(pool);
}

/*
 *	Object instances need to maintain retain counts in order to work
 *	with the gstep-guile memory allocation system.
 */
- (void) release
{
  [gstep_guile_object_lock lock];
  if (objectMap != 0)
    {
      int	*val;

      val = (int*)NSMapGet(objectMap, self);
      if (--*val > 0)
	{
	  [gstep_guile_object_lock unlock];
	  return;		/* retain count > 0	*/
	}
      objc_free(val);
      NSMapRemove(objectMap, self);
    } 
  [gstep_guile_object_lock unlock];
  [self free];
}

- (BOOL) respondsToSelector: (SEL)aSelector
{
  return __objc_responds_to(self, aSelector);
}

- (id) retain
{
  int	*val;

  [gstep_guile_object_lock lock];
  if (objectMap != 0)
    {
      objectMap = NSCreateMapTable(NSNonOwnedPointerMapKeyCallBacks,
                      NSNonOwnedPointerMapValueCallBacks, 0);
    }
  val = (int*)NSMapGet(objectMap, self);
  if (val == 0)
    {
      val = (int*)objc_malloc(sizeof(int));
      *val = 1;
      NSMapInsertKnownAbsent(objectMap, self, val);
    }
  else
    {
      ++*val;
    }
  [gstep_guile_object_lock unlock];
  return self;
}
@end

@implementation Protocol (GNUstepGuile)
/*
 *	Protocol instances should never be released.
 */
- (void) release
{
  return;
}
- (id) retain
{
  return self;
}
@end

