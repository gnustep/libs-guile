/* SKInterpreter.m

   Copyright (C) 1999, 2003 Free Software Foundation, Inc.
   
   Author: David I. Lehn<dlehn@vt.edu>
   Maintainer: Masatake YAMATO<masata-y@is.aist-nara.ac.jp>

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

/* SKInterpreter.m created by dlehn on Sat 21-Jun-1997 */

#include "ScriptKit.h"

const char * 
script_kit_version()
{
  return SCRIPT_KIT_VERSION;
}

@implementation SKInterpreter

- (id) init
{
  self = [super init];
  if (self)
    {
      userDictionary = nil;
    }
  return self;
}

- (void) dealloc
{
  [userDictionary release];
  [super dealloc];
}

+ (oneway void) initializeInterpreter
{
}

- (id) executeScript: (id)scr
{
  return [self shouldNotImplement:_cmd];
}

- (oneway void) executeScriptOneway: (id)scr
{
  [self shouldNotImplement:_cmd];
}

- (NSMutableDictionary *) userDictionary
{
  return userDictionary;
}

- (oneway void) setUserDictionary: (NSMutableDictionary *)dict
{
  [userDictionary autorelease];
  userDictionary = [dict retain];
}

@end
