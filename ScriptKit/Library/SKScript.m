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

/* SKScript.m created by dlehn on Sat 21-Jun-1997 */

#include <Foundation/NSString.h>

#include "ScriptKit.h" 
#include "GuileSCM.h"

@implementation SKScript

+ (void) initialize
{
  if( self == [SKScript class] )
    {
      [self setVersion:0];
    }
}

- (id) init
{
  self = [super init];
  if (self)
    {
      dictionary = nil;
      interpreter = nil;
      delegate = nil;
      // selector = [[NSString stringWithString:@"stringValue"] selectorValue];
      // selector = [[[[NSString alloc] initWithString:@"stringValue"] autorelease] selectorValue];
      selector = @selector(stringValue);// jet
    };
  return self;
}

- (void) dealloc
{
  [delegate release], delegate       = nil;
  [interpreter release], interpreter = nil;
  [dictionary release], dictionary   = nil;
  [super dealloc];
}

- (id <SKInterpreter>) interpreter
{
  return interpreter;
}

- (void) setInterpreter: (id <SKInterpreter>)intr
{
  if (interpreter != intr)
    {
      [interpreter release];
      interpreter = [intr retain];
    }
}

- (NSMutableDictionary *) userDictionary;
{
  return dictionary;
}

- (void) setUserDictionary: (NSMutableDictionary *)dict
{
  if (dictionary != dict)
    {
      [dictionary release];
      dictionary = [dict retain];
    }
}

- (id) delegate;
{
    return delegate;
}

- (void) setDelegate: (id)del
{
  if (delegate != del)
    {
      [delegate release];
      delegate = [del retain];
    }
}

- (SEL) selector
{
  return selector;
}

- (oneway void) setSelector: (SEL)sel
{
  selector = sel;
}

- (id) execute: (id)sender
{
  id ret;
  if( [self hasValidDelegate] )
    {
      ret = [interpreter executeScript:self];
      return ret;
    }
  else
    {
      return nil;
    }
}

- (oneway void) executeOneway: (id)sender
{
  if( [self hasValidDelegate] )
    {
      [interpreter executeScriptOneway:self];
    }
}

- (BOOL) hasValidDelegate
{
  return ([delegate respondsToSelector:@selector(stringValue)] ||
	  [delegate respondsToSelector:@selector(string)]);
}

// should only be called if [self hasValidDelegate] == YES
- (NSString *) stringValue
{
  NSString *str = nil;

  if ([delegate isKindOf: [NSString class]])
    str = delegate;
  else if ([delegate respondsToSelector:@selector(stringValue)])
    /* OLD Code:
       else if (0 && [delegate respondsToSelector:@selector(stringValue)])
       
       Eiichi wrote:
       If the delegate is an instance of NXConstantString,
       [delegate respondsToSelector:@selector(stringValue)]
       returns YES. But when invokeing [delegate stringValue],
       an exception, NXConstantString does not recognize stringValue 
       is thrown. I think its a bug of -respondsToXXX in the gcc 
       2.7.2.3 or the libobjects.
       (The original memo is written in Japanese.
       Translation to English by Masatake)

       In Change of gcc-2.8.1:
       ---
       Mon Mar 17 17:00:14 1997  Scott Christley <scottc@net-community.com>

       * objc/sendmsg.c: (__objc_responds_to): 
       Install dispatch table if needed before checking if method is 
       implemented.
       ---

       So the bug is in the gcc-2.7.2.3. 
       I've tested a following mini program on sparc-sun-solaris2.6.
       int main()
       {
         if (YES == [@"A" respondsToSelector:@selector(stringValue)])
           {
             fprintf(stderr, "YES\n");
           }
         else
           {
	     fprintf(stderr, "NO\n");
	   }
	 return 0;
       }
            
       "NO" is printed. So the bug is fixed in gcc-2.8.1.
       We should test the program on the other OS'.
       (Masatake) */
    str = [delegate stringValue];
  else if ( 0 && [delegate respondsToSelector:@selector(string)] )
    str = [delegate perform:@selector (string)];
  return str;
}

@end
