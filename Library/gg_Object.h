/* gg_Object.h - interface between guile and old Object stuff
   Copyright (C) 1998, 2003 Free Software Foundation, Inc.

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

#ifndef __gg_Object_h_INCLUDE
#define __gg_Object_h_INCLUDE 

#ifndef	__gstep_guile_h_INCLUDE
#include	"gstep_guile.h"
#endif

#include	<objc/Object.h>
#include	<objc/Protocol.h>

/*
 *	The [-printForGuile:]  method is responsible for what goes in
 *	the #<...> when Scheme prints the object.
 *
 *	The +retain, +release, -retain, -release methods are needed in
 *	order for Objecxt to cooperate with gstep-guile memory management.
 *
 *	The -methodSignatureForSelector: method is needed in order for the
 *	library to determine what types of argument should be passed.
 */

@interface Object (GNUstepGuile)
+ (void) release;
+ (id) retain;
- (NSMethodSignature*) methodSignatureForSelector: (SEL)aSelector;
- (void) printForGuile: (SCM)port;
- (void) release;
- (id) retain;
@end

@interface Protocol (GNUstepGuile)
- (void) release;
- (id) retain;
@end

#endif /* __gg_Object_h_INCLUDE */
