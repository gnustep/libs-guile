/* gstep_guile.m - interface between guile and GNUstep
   Copyright (C) 1998 Free Software Foundation, Inc.

   Written by:  Richard Frith-Macdonald <richard@brainstorm.co.uk>
   Date: April 1998

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

#include "private.h"

void (*print_for_guile)(id obj, SEL sel, SCM port) = NULL;

/*
 *	Lock for thread-safe retain/release of Object
 */
NSLock	*gstep_guile_object_lock = nil;

void
gstep_init()
{
  if (gstep_guile_object_lock == nil)
    {
#ifdef	HAVE_SCM_C_RESOLVE_MODULE
      SCM module = scm_c_resolve_module ("languages gstep-guile");
#endif
      gstep_guile_object_lock = [NSLock new];

#ifdef	HAVE_SCM_C_RESOLVE_MODULE
      module = scm_set_current_module (module);
#endif
      gstep_init_id();
      gstep_init_class();
      gstep_init_protocol();
      gstep_init_voidp();

      /*
       *	Create a variable 'gstep-nil' as a conveniance to users.
       */
      gh_define("gstep-nil", gstep_id2scm(nil, 0));
#ifdef	HAVE_SCM_C_EXPORT
      scm_c_export("gstep-nil", 0);
#endif

      scm_add_feature("gstep-init");
#ifdef	HAVE_SCM_C_RESOLVE_MODULE
      module = scm_set_current_module (module);
#endif
    }
}

