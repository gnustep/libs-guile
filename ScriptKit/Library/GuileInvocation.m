/* GuileInvocation.m

   Copyright (C) 1999, 2003 Free Software Foundation, Inc.
   
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

#include "Guile.h"
#include <Foundation/NSArray.h>
#include <Foundation/NSException.h>

@implementation  GuileInvocation
- init
{
  [super init];
  proc 	    = nil;
  arguments = nil;
  result = nil;
  return self;
}
- initWithArgc: (int) c
{
  int n;
  [self init];
  arguments = [[NSMutableArray array] retain];
  for (n = 0; n < c; n++)
    {
      [arguments addObject: GUILE_EOA];
    }  
  return self ;
}
+ (GuileInvocation *) invocationWithArgc: (int)c
{
  return [[[GuileInvocation alloc] initWithArgc: c] autorelease];
}
- (void) dealloc
{
  if (proc != nil)
    {
      [proc release], proc = nil;
    }
  if (arguments != nil)
    {
      [arguments release], arguments = nil;
    }
  if (result != nil)
    {
      [result release], result = nil;
    }
  [super dealloc];
}
- (id) argumentAtIndex: (int)index
{
  if (0 == index)
    {
      return proc;
    }
  else
    {
      index--;
      return [arguments objectAtIndex: index];
    }  
}
- (GuileSCM *) returnValue
{
  return result;
}
- (GuileProcedure *) procedure
{
  return proc;
}
- (int) procedureArgc
{
  return [arguments count];
}
- (void) setArgument: (void*)buffer atIndex: (int)index
{
  if (index == 0)
    {
      [self setProcedure: (id)buffer];
    }
  else
    {
      [arguments replaceObjectAtIndex: --index withObject: (id)buffer];
    }
}
- (void) setProcedure: p
{
  if (nil != proc)
    {
      [proc release];
    } 
  
  if (YES == [p isKindOfClass: [GuileProcedure class]])
    {
      proc = [p retain];
    }
  else if (YES == [p isKindOfClass: [NSString class]])
    {
      proc = [[GuileProcedure procWithExpression: (NSString *)p] retain];
    }
  else
    {
      [NSException raise: 
		     NSInvalidArgumentException
		   format: 
		     @"proc is wrong wrong typed value."];
    }
}
- (void) invoke
{
  if (nil != result)
    {
      [result release], result = nil;
    }
  result = [[proc callWithArray: arguments] retain];
}
@end 
