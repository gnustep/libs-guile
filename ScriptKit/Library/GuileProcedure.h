/* GuileProcedure.h

   Copyright (C) 1999, 2003 Free Software Foundation, Inc.
   
   Author: Eiichi TAKAMORI<taka@ma1.seikyou.ne.jp>
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

/* GuileProcedure encapsulates a procedure of Scheme.
   The ability of this class is sama as that of GuileScript.
   -- eiichi */

#ifndef GUILEPROCEDURE_H_
#define GUILEPROCEDURE_H_

#include <Foundation/NSString.h>
#include <Foundation/NSObject.h>

#include "GuileSCM.h"

@class NSArray;

@interface GuileProcedure: GuileSCM
- initWithExpression: (NSString *)sexp;
+ (GuileProcedure *) procWithExpression: (NSString *)sexp;

- (GuileSCM *) callWithObjects: firstObj, ...; // GUILE_EOA terminated.
- (GuileSCM *) callWithObjects: (id*)objects count: (unsigned)n;

/* GUILE_EOA in array is translated as nil.
   So you can pass a nil to the procedure. */
- (GuileSCM *) callWithArray: (NSArray *)array;
@end
#endif  /* Not: GUILEPROCEDURE_H_ */
