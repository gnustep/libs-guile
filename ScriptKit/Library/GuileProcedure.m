/* GuileProcedure.m

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

/* Because guile uses `id' as variable name sometime,
   while it is an Objective-C reserved keyword. */
#define id id_x_
#include <guile/gh.h>
#undef id
#include "Guile.h"
#include <Foundation/NSException.h>
#include <Foundation/NSArray.h>

static void * end_of_arguments_mark = NULL;
id Guile_end_of_arguments()
{
  if (!end_of_arguments_mark)
    end_of_arguments_mark = [[NSObject alloc] init];
  return end_of_arguments_mark;
}


@implementation GuileProcedure
- initWithExpression: (NSString *) sexp
{
  SCM	proc = gh_eval_str ((char*) [sexp cString]);
  if (!gh_procedure_p(proc))
    {
      [self release], self = nil;
      [NSException raise: NSInvalidArgumentException
		   format: @"SEXP, the argument is not procedure."];
      /* FIXME: Which is better throwing the exception or returning nil ? */
    }
  return [self initWithSCM: proc];
}

+ (GuileProcedure *) procWithExpression: (NSString *) sexp
{
  return [[[self alloc] initWithExpression: sexp] autorelease];
}

- callWithObjects: firstObject, ...
{
  SCM		proc = value;
  SCM		args = SCM_EOL;
  id		arg;
  va_list	ap;
  SCM		ret;
  void * eoa = GUILE_EOA;

  va_start (ap, firstObject);
  arg = firstObject;
  while (arg != eoa)
    {
      if (arg == nil)
	args = gh_cons([GuileSCM nilSCMValue], args);
      else
	args = gh_cons ([arg scmValue], args);
      arg = va_arg (ap, id);
    }
  va_end (ap);
  args = gh_reverse (args);

  ret = gh_apply (proc, args);

  return [GuileSCM scmWithSCM: ret];
}

- callWithObjects: (id*)objects count: (unsigned) n
{
  SCM		proc = value;
  SCM		args = SCM_EOL;
  id		arg;
  int		i;
  SCM		ret;

  for (i = 0; i < n; i++)
    {
      arg = objects[i];
      args = gh_cons ([arg scmValue], args);
    }
  args = gh_reverse (args);

  ret = gh_apply (proc, args);

  return [GuileSCM scmWithSCM: ret];
}
- (GuileSCM *) callWithArray: (NSArray *)array
{
  int n;
  SCM proc = value;
  int i;
  id arg;
  SCM args = SCM_EOL;
  SCM ret;
  void * eoa = GUILE_EOA;

  if (nil == array)
    {
      n = 0;
    }
  else
    {
      n = [array count];
    }

  for (i = 0; i < n; i++)
    {
      arg = [array objectAtIndex: i];
      if (arg == eoa)
	{
	  arg = nil;
	}
      args = gh_cons ([arg scmValue], args);
    }
  args = gh_reverse (args);

  ret = gh_apply (proc, args);

  return [GuileSCM scmWithSCM: ret];
}
@end
