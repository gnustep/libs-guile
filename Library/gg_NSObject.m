/* gg_NSObject.m - interface between guile and GNUstep
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

#include "gstep_guile.h"
#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSProxy.h>

/*
 *	Catagory of the 'NSObject' class for GNUstep-Guile
 */
@implementation NSObject (GNUstepGuile)

- (void) printForGuile: (SCM)port
{
  CREATE_AUTORELEASE_POOL(pool);

  if (print_for_guile == NULL)
    {
      scm_display(gh_str02scm(" string=\""), port);
      scm_display(gh_str02scm((char *)[[self description] cString]), port); 
      scm_display(gh_str02scm("\""), port);
    }
  else
    {
      print_for_guile(self, _cmd, port);
    }
  DESTROY(pool);
}

@end

