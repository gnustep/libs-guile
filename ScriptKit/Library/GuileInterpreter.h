/* GuileInterpreter.h

   Copyright (C) 1999 Free Software Foundation, Inc.
   Copyright (C) 1997, 1998 David I. Lehn
   
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

/* GuileInterpreter.h created by dlehn on Mon 16-Jun-1997 */
#ifndef GUILE_INTERPRETER_H
#define GUILE_INTERPRETER_H 
#include <ScriptKit/Guile.h>

@class NSString;

extern NSString * GuileInterpreterException;
extern NSString * GuileInterpreterExceptionTagKey;
extern NSString * GuileInterpreterExceptionThrownArgsKey;

extern NSString * GuileInterpreterKeyWord_Interpreter;
extern NSString * GuileInterpreterKeyWord_Dictionary;
extern NSString * GuileInterpreterKeyWord_Update;

@interface GuileInterpreter : SKInterpreter
{
  BOOL batch_mode;
}

+ (void)initialize;

+ (void)scmError:(NSString *)message args:(SCM)args;

- (id)init;
- (void)dealloc;

- (void)replWithPrompt:(NSString *)prompt;
- (void)repl;

- (void)interactiveMode;
- (void)batchMode;
- (BOOL)isInBatchMode;
- (BOOL)isInInteractiveMode;

- (GuileSCM *)eval: (NSString *) sexp;
- (GuileSCM *)eval: (NSString *) sexp 
  inUserDictionary: (NSMutableDictionary *)d;
- (GuileSCM *)loadFile: (NSString *) filename;
- (GuileSCM *)define: (NSString *) name withValue: (GuileSCM *) val;
- (GuileSCM *)lookup: (NSString *) name;

- (void)display: (GuileSCM *) val;
- (void)write: (GuileSCM *) val;
- (void)newline;
/* Useful for debugging */
- (NSString *)generateRealScript: (id<SKScript>)scr;
@end

#endif /* Not def: GUILE_INTERPRETER_H */
