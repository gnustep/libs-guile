/* SKInterpreter.h

   Copyright (C) 1999, 2000, 2003 Free Software Foundation, Inc.
   
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

/* SKInterpreter.h created by dlehn on Sat 21-Jun-1997 */
#ifndef S_K_INTERPRETER_H
#define S_K_INTERPRETER_H 

#include "ScriptKit.h"

#include <Foundation/NSObject.h>
#include <Foundation/NSDictionary.h>

#include <objc/encoding.h>

#ifndef	_C_BYREF
# define byref			
#endif

#ifndef	byref
# if (__GNUC__ > 2 || (__GNUC__ == 2 && __GNUC_MINOR__ <= 91))
#  define byref
# endif
#endif


@protocol SKInterpreter <NSObject>
+ (oneway void)initializeInterpreter;
- (id)executeScript:(in id)scr;
- (oneway void)executeScriptOneway:(in id)scr;
- (NSMutableDictionary *)userDictionary;
- (oneway void)setUserDictionary:(byref NSMutableDictionary *)dict;
@end

@interface SKInterpreter : NSObject <SKInterpreter>
{
    NSMutableDictionary *userDictionary;
}

@end

#endif /* Not def: S_K_INTERPRETER_H */
