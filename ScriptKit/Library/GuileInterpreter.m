/* GuileInterpreter.h

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

/* GuileInterpreter.m created by dlehn on Mon 16-Jun-1997 */

#include <assert.h>
/* Because guile uses `id' as variable name sometime,
   while it is an Objective-C reserved keyword. */
#define id id_x_
#include <guile/gh.h>
#undef id
#include "GuileInterpreter.h"
//#include <gstep_guile.h>
// Needed for class list funcs
#include <objc/objc-api.h>
#include <Foundation/NSObjCRuntime.h>
#include <Foundation/NSMethodSignature.h>
#include <Foundation/NSValue.h>
#include <Foundation/NSUtilities.h>
#include <Foundation/NSString.h>
#include <Foundation/NSException.h>
#include <Foundation/NSDictionary.h>

#include <string.h>

static GuileInterpreter *currentInterpreter = nil;
// static NSLock *singleInterpreterLock = nil;

//xxxbegin
static void
gscm_2_str (out, len_out, objp)
     char ** out;
     int * len_out;
     SCM * objp;
{
  SCM_ASSERT (SCM_NIMP (*objp) && SCM_STRINGP (*objp), *objp, SCM_ARG3, "gscm_2_str");
  if (out)
    *out = SCM_CHARS (*objp);
  if (len_out)
    *len_out = SCM_LENGTH (*objp);
}
//xxxend

static BOOL proc_install = NO;

NSMutableDictionary * shared_let 	 = nil;
static char script_kit_lookup_n[] = "script-kit-lookup";
static SCM
script_kit_lookup_fn (SCM name)
{
  char *ctmp;
  NSString * key;
  int len;
  NSObject * value;
  
  gscm_2_str(&ctmp, &len, &name);
  key = [NSString stringWithCString: ctmp];
  
  if (YES == [key isEqual: GuileInterpreterKeyWord_Interpreter])
    {
      return gstep_id2scm (currentInterpreter, YES);
    }
  else if (YES == [key isEqual: GuileInterpreterKeyWord_Dictionary])
    {
      return gstep_id2scm (shared_let, YES);
    }
  else
    {
      assert (shared_let != nil);
      value = [shared_let objectForKey: key];
      return  [value scmValue];
    }
}


static char script_kit_update_n[] = "script-kit-update";
static SCM
script_kit_update_fn (SCM scm_name, SCM new_scm_value)
{
  char *ctmp;
  NSString * key;
  int len;
  id old_obj_value;
  id new_obj_value;

  gscm_2_str(&ctmp, &len, &scm_name);
  key = [NSString stringWithCString: ctmp];

  if ((YES == [key isEqual: GuileInterpreterKeyWord_Interpreter])
      || (YES == [key isEqual: GuileInterpreterKeyWord_Dictionary])
      || (YES == [key isEqual: GuileInterpreterKeyWord_Update]))
    {
      [NSException raise: 
		     NSInternalInconsistencyException
		   format: 
		     @"Don't update keyword"];
    }
  
  if (shared_let == nil)
    {
      [NSException raise: 
		     NSInternalInconsistencyException
		   format: 
		     @"let dictionary is not provided."];
    }
  
  old_obj_value = [shared_let objectForKey: key];
  if (old_obj_value == nil)
    {
      [NSException raise: 
		     NSInternalInconsistencyException
		   format: 
		     @"Cannot update variable that is not in let dictionary"];
    }

  new_obj_value = [GuileSCM scmWithSCM: new_scm_value];
  [shared_let setObject: new_obj_value forKey: key];
  return SCM_BOOL_T;
}

NSString * GuileInterpreterException = @"GuileInterpreterException";
NSString * GuileInterpreterExceptionTagKey = @"Tag";
NSString * GuileInterpreterExceptionThrownArgsKey = @"Thrown args";

/* KEY WORD IN SCRIPT */
NSString * GuileInterpreterKeyWord_Interpreter = @"guile-interpreter";
NSString * GuileInterpreterKeyWord_Dictionary  = @"guile-dictionary";
NSString * GuileInterpreterKeyWord_Update  = @"guile-update";


@implementation GuileInterpreter

+ (void) initialize
{
}

+ (oneway void) initializeInterpreter
{
  gstep_init();
  gh_eval_str("(if (not (defined? 'use-modules)) (primitive-load-path \"ice-9/boot-9.scm\"))");

  gh_eval_str("(use-modules (languages gstep-guile))");
  if (!proc_install)
    {
      scm_make_gsubr(script_kit_lookup_n, 1, 0, 0, script_kit_lookup_fn);
      scm_make_gsubr(script_kit_update_n, 2, 0, 0, script_kit_update_fn);
    }
}

+ (void) scmError: (NSString *)message args: (SCM)args
{ 
    SCM errsym;
    SCM str;

    errsym = gh_car (scm_intern ("error", 5));
    str = gh_str02scm ((char*)[message cString]);
    scm_throw (errsym, gh_cons (str, args));
}

- (id) init
{
  self = [super init];
  if (self)
    {
      batch_mode = YES;
    }
  return self;
}

- (void) dealloc
{
    [super dealloc];
}

static SCM
eval_str_wrapper (void *data, SCM jmpbuf)
{
/*   gh_eval_t real_eval_proc = (gh_eval_t) (* ((gh_eval_t *) data)); */

  char *scheme_code = (char *) data;
  return gh_eval_str (scheme_code);
}

/* Print a guile exception */
SCM
gopenstep_interactive_handler (void *data, SCM tag, SCM throw_args)
{
    scm_write(gh_str02scm("gopenstep error:\n\ttag => "), 
	      scm_current_output_port());
    scm_display (tag, scm_current_output_port ());
    scm_newline (scm_current_output_port ());
    
    scm_write(gh_str02scm("\targs => "), scm_current_output_port());
    scm_display (throw_args, scm_current_output_port ());
    scm_newline (scm_current_output_port ());

    return SCM_BOOL_F;
}

/* Translate a guile exception into a NSException. */
SCM
gopenstep_batch_handler (void *data, SCM tag, SCM throw_args)
{
  NSString * script = (NSString *)data;
  NSMutableDictionary * dict;
  NSException * e;
  
  dict = [[[NSMutableDictionary alloc] initWithCapacity: 2] autorelease];
  [dict setObject: [GuileSCM scmWithSCM: tag]
	forKey: GuileInterpreterExceptionTagKey];
  [dict setObject: [GuileSCM scmWithSCM: throw_args]
	forKey: GuileInterpreterExceptionThrownArgsKey];
    
  e = [NSException exceptionWithName: GuileInterpreterException
		   reason: script
		   userInfo: dict];
  [e raise];
}

static void 
add_let_entry(NSMutableString * script, NSString * entry, id value)
{

  [script appendString: @"("];
  [script appendString: entry];
  [script appendString: @" "];
  [script appendString: @"(script-kit-lookup \""];
  [script appendString: entry];
  [script appendString: @"\")"];
  [script appendString: @")"];
}

static void 
add_let_script(NSMutableString * script, NSString * entry, NSString * value)
{
  [script appendString: @"("];
  [script appendString: entry];
  [script appendString: @" "];
  [script appendString: value];
  [script appendString: @")"];
}
- (oneway void) setUserDictionary: (NSMutableDictionary *)dict
{
  /* We should not use shared_let and currentInterpreter
     Because using shared_let means we can use only one
     interpreter at a time. */

  // DIL not the best way to do this
  //  Only allows one script to run at a time.
  //  Would be better to execute script in env with dict var
  //  set.
  shared_let = dict;
  [super setUserDictionary: dict];
}
- (NSString *) generateRealScript: (id<SKScript>)scr
{
  char *c_script;
  NSMutableString * script = nil;

  if (scr == nil)
    {
      return nil;
    }

  /* Make a script
     ...adding let...
     */
  [self setUserDictionary: [scr userDictionary]];
  script = [[[NSMutableString alloc] init] autorelease];
  [script appendString: @"(let* ( "];
  // [script appendString: @"(letrec ( "];
    
  add_let_script(script,
		 GuileInterpreterKeyWord_Update,
                 @"(begin "
                 @"(defmacro script-kit-update-macro (name) `(script-kit-update (symbol->string ',name) ,name))"
		 @"script-kit-update-macro)");

  if ((userDictionary != nil) && [userDictionary count] != 0)
    {
      NSEnumerator * keys = [userDictionary keyEnumerator];
      NSObject * elt;
      NSString * key;
      while ((key = [keys nextObject]))
	{
	  add_let_entry(script, 
			key, 
			[userDictionary objectForKey:key]);
	}
    }

  /* Add key word */
  add_let_entry(script, 
		GuileInterpreterKeyWord_Interpreter,
		currentInterpreter);
  add_let_entry(script, 
		GuileInterpreterKeyWord_Dictionary,
		userDictionary);

  
  [script appendString: @") "];

  [script appendString: [scr stringValue]];

  [script appendString: @")"];

  return script;
}
- (id) executeScript: (id<SKScript>)scr
{
  SCM ret;
  char *c_script;
  NSString * script = nil;

  script   = [self generateRealScript: scr];
  c_script = (char *)[script cString];
  // [singleInterpreterLock lock];
  currentInterpreter = self;

  if (YES == [self isInBatchMode])
    {
      // Raise NSException
      NS_DURING
	{
	  ret = gh_catch (SCM_BOOL_T, 
			  (scm_catch_body_t) eval_str_wrapper, 
			  c_script, 
			  (scm_catch_handler_t) gopenstep_batch_handler, 
			  // Pass a script as nsstring to the handler
			  script); 
	}
      NS_HANDLER
	{
	  [localException raise];
	}
      NS_ENDHANDLER;
    }
  else			// interactive
    {
      // Only print message
      ret = gh_catch (SCM_BOOL_T, 
		      (scm_catch_body_t) eval_str_wrapper, 
		      c_script, 
		      (scm_catch_handler_t) gopenstep_interactive_handler, 
		      // Pass a script as cstring to the handler
		      c_script);
    }
  // [singleInterpreterLock unlock];

  /* -scmWithSCM: accepts not only objc id but any type of variable.*/
  return [GuileSCM scmWithSCM: ret];
}

- (oneway void) executeScriptOneway: (id<SKScript>)scr
{
  [self executeScript:scr];
}

- (void) replWithPrompt: (NSString *)prompt
{
  NSString *script_kit_set_prompt_scm_code = [NSString stringWithFormat:@"(if (equal? (version) \"1.0\") (set! the-prompt-string \"%@\") (set-repl-prompt! \"%@\"))", prompt, prompt];

  /* Set the prompt. */
  gh_eval_str((char *)[script_kit_set_prompt_scm_code cString]);
  [self interactiveMode];
  [self eval: @"(top-repl)"];
}

- (void) repl
{
  [self replWithPrompt:@"guile>"];
}

//
- (void) interactiveMode
{
  batch_mode = NO;
}
- (void) batchMode
{
  batch_mode = YES;
}
- (BOOL) isInBatchMode
{
  if (YES == batch_mode)
    return YES;
  else 
    return NO;
}
- (BOOL) isInInteractiveMode
{
  if (YES == batch_mode)
    return NO;
  else
    return YES;
}

// 
- (GuileSCM *) eval: (NSString *)sexp
{
  return [self eval: sexp inUserDictionary: nil];
}
- (GuileSCM *)eval: (NSString *)sexp 
  inUserDictionary: (NSMutableDictionary *)d
{
  GuileScript * s      = [[GuileScript alloc] init];
  GuileSCM * result    = nil;
  [s setUserDictionary: d];
  [s setDelegate: sexp];
  result = [self executeScript: s];
  [s release], s = nil;
  return result;
}

- (GuileSCM *) loadFile: (NSString *)filename
{
  SCM result = gh_eval_file ((char *)[filename cString]);
  return [GuileSCM scmWithSCM: result];
}

- (GuileSCM *) define: (NSString *)name withValue: (GuileSCM *)val
{
  SCM result = gh_define((char *)[name cString], [val scmValue]);
  return [GuileSCM scmWithSCM: result];
}

- (GuileSCM * ) lookup: (NSString *)name
{
  SCM result = gh_lookup ((char *)[name cString]);
  return [GuileSCM scmWithSCM: result];
}

- (void) display: (GuileSCM *) guile_scm
{
  gh_display ([guile_scm scmValue]);
}

- (void) write: (GuileSCM *) guile_scm
{
  gh_write ([guile_scm scmValue]);
}

- (void) newline
{
  gh_newline ();
}

@end
