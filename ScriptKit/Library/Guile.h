/* Guile.h

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

/* Guile.h created by dlehn on Wed 18-Jun-1997 */

#ifndef SK_GUILE_H
#define SK_GUILE_H 

#include <gstep_guile.h>

#include <ScriptKit/ScriptKit.h>
#include <ScriptKit/GuileSCM.h>
#include <ScriptKit/GuileProcedure.h>
#include <ScriptKit/GuileInterpreter.h>
#include <ScriptKit/GuileInvocation.h>
#include <ScriptKit/GuileScript.h>

#if BUILD_libScriptKit_DLL
#  define SK_EXPORT  __declspec(dllexport)
#  define SK_DECLARE __declspec(dllexport)
#elif libScriptKit_ISDLL
#  define SK_EXPORT  extern __declspec(dllimport)
#  define SK_DECLARE __declspec(dllimport)
#else
#  define SK_EXPORT extern
#  define SK_DECLARE
#endif

/* VA ARGS terminator.
   See:
   [GuileProcedure -callWithObjects:]
   [GuileSCM(ListOperations) +list:] */
SK_EXPORT id Guile_end_of_arguments();
#define GUILE_EOA Guile_end_of_arguments()

#endif /* Not def: SK_GUILE_H */
