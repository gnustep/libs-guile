/* GuileInvocation.h

   Copyright (C) 1999 Free Software Foundation, Inc.
   Copyright (C) 1997, 1998 David I. Lehn
   
   Author: Masatake YAMATO<masata-y@is.aist-nara.ac.jp>

   This file is part of the ScriptKit Library.

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
   Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA. */

/* GuileInvocation = GuileProcedure + arguments + result buffer.
   -- masatake */
#ifndef GUILE_INVOCATION_H
#define GUILE_INVOCATION_H 

#include <Foundation/NSObject.h>
@class NSArray, NSMutableArray;
@class GuileProcedure, GuileSCM;

@interface GuileInvocation: NSObject
{
  GuileProcedure * proc;
  NSMutableArray * arguments;
  GuileSCM * result;
}
+ (GuileInvocation *)invocationWithArgc: (int)c;
- initWithArgc: (int) c;
/* 0 -> proc */
- (id)argumentAtIndex: (int)index;
- (GuileSCM *)returnValue;
- (GuileProcedure *)procedure;
- (int)procedureArgc;

/* buffer must be an id typed value. */
/* 0 -> proc */
- (void) setArgument: (void*)buffer atIndex: (int)index;
/* p: GuileProcedure or NSString */
- (void) setProcedure: p;
- (void) invoke; 
@end 

#endif /* Not def: GUILE_INVOCATION_H */
