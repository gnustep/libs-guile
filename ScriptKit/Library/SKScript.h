/* SKScript.h

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

/* SKScript.h created by dlehn on Sat 21-Jun-1997 */
#ifndef S_K_SCRIPT_H
#define S_K_SCRIPT_H 

#include "SKInterpreter.h"

#include <Foundation/NSDictionary.h>
#include <Foundation/NSObject.h>
#include <objc/objc-api.h>

@protocol SKScript <NSObject>

- (id <SKInterpreter>)interpreter;
- (oneway void)setInterpreter:(id <SKInterpreter>)intr;

- (NSMutableDictionary *)userDictionary;
- (oneway void)setUserDictionary:(NSMutableDictionary *)dict;

- (id)delegate;
- (oneway void)setDelegate:(id)del;

- (SEL)selector;
- (oneway void)setSelector:(SEL)sel;

- (BOOL)hasValidDelegate;
- (NSString *)stringValue;

- (id)execute:(id)sender;
- (oneway void)executeOneway:(id)sender;

@end

@interface SKScript : NSObject <SKScript>
{
    NSMutableDictionary *dictionary;
    id <SKInterpreter> interpreter;
    id delegate;
    SEL selector;
}

@end

#endif /* Not def: S_K_SCRIPT_H */
