/* test_skit.m:
   Eiichi Takamori  <taka@ma1.seikyou.ne.jp>
   Masatake Yamato  <masata-y@is.aist-nara.ac.jp> */

#include <gstep_guile.h>
#include <guile/gh.h>
#include <Foundation/NSObject.h>
#include <Foundation/NSDictionary.h>
#include <Foundation/NSValue.h>
#include <Foundation/NSString.h>
#include <Foundation/NSException.h>
#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSArray.h>
#include <Foundation/NSSet.h>

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

#include "Guile.h"

char * message_cache = NULL;
void
print_header (char *msg)
{
  message_cache = msg;
  fprintf (stderr, 
	   "=======================================================\n%s\n", 
	   msg);
}

#define OK 1
#define ERROR 0
void 
print_result (int result, char *reason)
{
  if (result == OK)
    fprintf (stderr, "%s...%s\n", message_cache, "OK"); 
  else if (result == ERROR)
    {
      if (reason)
	fprintf (stderr, "%s...%s: %s\n", message_cache, "Error", reason);
      else
	fprintf (stderr, "%s...%s\n", message_cache, "Error");
    }
  message_cache = NULL;
}

/*
 * Testing the objc runtime sanity
 */
void
test_nx_constant_string()
{
  id target = @"STRING";
  print_header ("Testing the objc runtime sanity(-respondsToSelector:)");
  if (YES == [target respondsToSelector:@selector(stringValue)])
    {
      NS_DURING
	{
	  [target stringValue];
	  print_result(OK, NULL);
	}
      NS_HANDLER
	{
	  [target stringValue];
	  print_result(ERROR, NULL);
	}
      NS_ENDHANDLER;
    }
  else
    print_result(OK, NULL);
}

/*
 * test_guile_procedure_1
 * This test shows how to create a procedure from a lambda formula and how 
 * to invoke it.
 */
void
test_guile_procedure_1 (GuileInterpreter *i)
{
  /* Define a procedure using a lambda formula */
  int a = 1, b = 2, c = 3;
  NSString *sexp = @"(lambda (x y z) (+ x y z))";
  GuileProcedure *proc;
  GuileSCM *ret;
  
  print_header ("Testing GuileProcedure 1");
  
  /* Evaluate a string (sexp) and create a procedure. */
  proc = [GuileProcedure procWithExpression: sexp];

  /* Invoke the procedure */
  
  ret = [proc callWithObjects: [GuileSCM scmWithInt: a],
	      [GuileSCM scmWithInt: b],
	      [GuileSCM scmWithInt: c] , GUILE_EOA];
  if ((YES == [ret isNumber])
      &&((a + b + c) == [ret intValue]))
    print_result(OK, NULL);
  else
    {
      if (YES == [ret isNumber])
	fprintf(stderr, "%d + %d + %d != %d\n", a, b, c, [ret intValue]);
      else
	fprintf(stderr, "Result is not number!\n");
      print_result(ERROR, NULL);
    }
}

/*
 * test_guile_procedure_2
 * This test shows how to create a procedure objetive-c object from
 * another scheme procedure specified by the procedure name.
 */
void
test_guile_procedure_2 (GuileInterpreter *i)
{
  GuileProcedure *proc;
  GuileSCM *ret;
  id obj1, obj2, obj3;
  
  print_header ("Testing GuileProcedure 2");
  
  /* Create a procuedre object by a name of procedure. */
  proc = [GuileProcedure procWithExpression: @"list"];

  /* Objects passed to the procedure as argumetns */
  obj1 = [[[NSArray alloc] init] autorelease];
  obj2 = [[[NSDictionary alloc] init] autorelease];
  obj3 = [[[NSSet alloc] init] autorelease];

  /* Invoke */
  ret = [proc callWithObjects: obj1, obj2, obj3, GUILE_EOA];
  
  if ((YES == [ret isList]) 
      && ([ret length] == 3) 
      && (YES == [[[ret listRefWithIndex: [GuileSCM scmWithInt: 0]] objectValue]
		   isKindOfClass: [NSArray class]])
      && (YES == [[[ret listRefWithIndex: [GuileSCM scmWithInt: 1]] objectValue]
		   isKindOfClass: [NSDictionary class]])
      && (YES == [[[ret listRefWithIndex: [GuileSCM scmWithInt: 2]] objectValue]
		   isKindOfClass: [NSSet class]]))
    print_result(OK, NULL);
  else
    print_result(ERROR, NULL);
}

/*
 * test_gh evaluates same expression as test_guile_procedure_1 using
 * only gh interface.
 */
void
test_gh (GuileInterpreter *i)
{
  int a = 1, b = 2, c = 3;
  char *sexp = "(lambda (x y z) (+ x y z))";
  static SCM proc = SCM_BOOL_F;
  SCM ret;

  print_header ("Testing gh");
  
  if (proc == SCM_BOOL_F) {
    /* Create a procedure by evaluating a string, SEXP. */
    proc = gh_eval_str (sexp);
  }

  /* Invoke */
  ret = gh_call3 (proc, gh_int2scm (a), gh_int2scm(b), gh_int2scm(c));
  
  if ((gh_number_p (ret))
      && ((a + b + c) == gh_scm2int(ret)))
    print_result(OK, NULL);
  else
    {
      if (gh_number_p (ret))
	fprintf(stderr, "%d + %d + %d != %d\n", a, b, c, gh_scm2int(ret));
      else
	fprintf(stderr, "Result is not number!\n");
      print_result(ERROR, NULL);
    }
}

/*
 * test_guile_script shows a simple usage of GuileScript, 
 * GuileInterpreter and GuileSCM.
 *
 * To evaluate a script using a GuileInterpreter, it 
 * requires two things.
 *
 * 1. script itself
 * 2. let dictionary
 *
 * Put the two things into an instance of GuileScript and pass it to
 * GuileInterpreter.
 *
 * GuileScript is a class that contains a string expression of a scheme 
 * script and the let dictionary.
 * The let dictionary is a table that releates objective-c objects to
 * names in the scheme script.
 * 
 * After evaluating, the GuileInterpreter returns a instance of GuileSCM
 * as the result of evaluating.
 */
void
test_guile_script (GuileInterpreter *i)
{
  GuileScript * s      = [[GuileScript alloc] init];
  NSMutableDictionary *let  = [[NSMutableDictionary alloc] initWithCapacity: 3];
  GuileSCM * result;

  print_header ("Testing GuileScript");

  /* Create a let dictionary */
  [let setObject: @"X" forKey: @"str0"];
  [let setObject: @"Y" forKey: @"str1"];
  [let setObject: @"Z" forKey: @"str2"];
  [s setUserDictionary: let];
  
  /* Put a script */
  [s setDelegate: 
       @"([] 'NSString stringWithCString: (string-append str0 str1 str2))"]; 
  /* Eval */
  result = [i executeScript: s];
  if (!strcmp([[result objectValue] cString], "XYZ"))
    {
      fprintf(stderr, "XYZ == %s\n", [[result objectValue] cString]);
      print_result(OK, NULL);      
    }
  else
    {
      fprintf(stderr, "XYZ != %s\n", [[result objectValue] cString]);
      print_result(ERROR, NULL);      
    }
  [let release], let = nil;
  [s release], s = nil;
}

/*
 * Evaluate a string as a script.
 */
void
test_guile_eval(GuileInterpreter *i)
{
  GuileSCM * result;
  print_header ("Testing [GuileInterpreter -eval:]");
  result = [i eval: @"(+ 1 2 3)"];
  if ((YES == [result isNumber])
      && (6 == [result intValue]))
    print_result(OK, NULL);
  else
    print_result(ERROR, NULL);
}

/*
 * Testing exception handling in the interactive mode and 
 * in the batch mode.
 */
void
test_exception(GuileInterpreter *i)
{
  BOOL flag = NO;
  NSString * script;
  script = @"(begin (define a ([] 'NSArray array)) ([] a objectAtIndex: 0))";
  /* print_header ("Testing an exception from the script in interactive mdoe");
  [i interactiveMode];
  [i eval: script]; */

  print_header ("Testing an exception from the script in batch mode");
  [i batchMode];
  NS_DURING
    {  
      [i eval: script];
    }
  NS_HANDLER
    {
      printf("An NSException is caught.\n");
      printf("Exception Name: %s\n", [[localException name] cString]);
      printf("Reason: %s\n",  [[localException reason] cString]);
      flag = YES;
    }
  NS_ENDHANDLER;
  if (flag == YES)
    print_result(OK, NULL);
  else
    print_result(ERROR, NULL);
}

/*
 * Testing invocation.
 */
void
test_invocation(GuileInterpreter *i)
{
  GuileSCM * result;
  GuileInvocation * inv ;

  print_header ("Testing GuileInvocation");
  inv = [GuileInvocation invocationWithArgc: 3];
  
  [inv setProcedure: @"list"];
  [inv setArgument: [NSArray array] atIndex: 1];
  [inv setArgument: [NSDictionary dictionary] atIndex: 2];
  [inv setArgument: [NSSet set] atIndex: 3];
  
  [inv invoke];
  result = [inv returnValue];
  printf ("Return value is %s\n", [[result description] cString]);

  if ((YES == [result isList]) 
      && ([result length] == 3) 
      && (YES == [[[result listRefWithIndex: [GuileSCM scmWithInt: 0]] objectValue]
		   isKindOfClass: [NSArray class]])
      && (YES == [[[result listRefWithIndex: [GuileSCM scmWithInt: 1]] objectValue]
		   isKindOfClass: [NSDictionary class]])
      && (YES == [[[result listRefWithIndex: [GuileSCM scmWithInt: 2]] objectValue]
		   isKindOfClass: [NSSet class]]))
    print_result(OK, NULL);
  else
    print_result(ERROR, NULL);
}

/*
 * Testing keyword.
 * You can refer the interpreter object and let user dictionary
 * from your script.
 */
void
test_keyword(GuileInterpreter *i)
{
  GuileSCM * result_interpreter;
  GuileSCM * result_dictionary;
  GuileSCM * result_update;

  print_header ("Testing Keyword");
  result_interpreter = [i eval: @"guile-interpreter"];
  result_dictionary= [i eval: @"guile-dictionary"];
  result_update = [i eval: @"guile-update"];

  if ((YES    == [result_interpreter isObject])
      && (i   == [result_interpreter objectValue])
      && (nil == [result_dictionary objectValue]))
    print_result(OK, NULL);
  else
    print_result(ERROR, NULL);	// TODO: Added to check the update macro
}

/*
 * Testing NSMutableDictionary GuileSCM category
 */
void
test_nsdict(GuileInterpreter *i)
{
  int a = 3, b = 14;
  char * x = "Script", * y = "Kit", *z = "ScriptKit";
  double c = 1.3, d = 0.9;
  GuileScript * s;
  NSMutableDictionary * dict;
  GuileSCM * result;
  BOOL result0, result1, result2, result3;

  print_header ("Testing NSMutableDictionary GuileSCM category");
  s = [[[GuileScript alloc] init] autorelease];
  dict = [NSMutableDictionary dictionary];

  /* Passing long values */
  [dict setLong: a forKey: @"a"];
  [dict setLong: b forKey: @"b"];
  [s setUserDictionary: dict];
  [s setDelegate: @"(+ a b)"];
  result     = [i executeScript: s];
  
  result0 = (a+b == [result intValue])? YES: NO;

  /* Passing c strings */
  [dict setCString: x forKey: @"x"];
  [dict setCString: y forKey: @"y"];
  [s setDelegate: @"(string-append x y)"];
  result     = [i executeScript: s];
  
  if (!strcmp(z, [[result stringValue] cString]))
    result1 = YES;
  else
    result1 = NO;

  /* Passing double values */
  [dict setDouble: c forKey: @"c"];
  [dict setDouble: d forKey: @"d"];

  /* Passing BOOL value.
     objc's BOOL value is translated into guile's boolean. */
  [dict setBool: YES forKey: @"flag"];
  [s setDelegate: @"(if flag (- c d) (+ c d))"];
  result     = [i executeScript: s];

  if ((c - d) == [result doubleValue])
    result2 = YES;
  else
    result2 = NO;

  [dict setBool: NO forKey: @"flag"];
  result     = [i executeScript: s];
  if ((c + d) == [result doubleValue])
    result3 = YES;
  else
    result3 = NO;
  
  if ((result3 == YES)
      && (result2 == YES)
      && (result1 == YES)
      && (result0 == YES))
    print_result(OK, NULL);
  else
    print_result(ERROR, NULL);
}

/*
 * Testing update macro
 */
void
test_update(GuileInterpreter * i)
{
  long a = 1, b = 2, c = 3;
  GuileScript * s      = [[GuileScript alloc] init];
  NSMutableDictionary *let  = [[NSMutableDictionary alloc] initWithCapacity: 6];
  int result;
  
  print_header ("Testing Update Macro");
  
  [let setObject: @"X" forKey: @"str0"];
  [let setObject: @"Y" forKey: @"str1"];
  [let setObject: @"Z" forKey: @"str2"];
  [let setLong: a forKey: @"i"];
  [let setLong: b forKey: @"j"];
  [let setLong: c forKey: @"k"];

  [s setUserDictionary: let];
  [s setDelegate: 
       @"(set! str0 i) (guile-update str0)"
       @"(set! str1 j) (guile-update str1)"
       @"(set! str2 k) (guile-update str2)"];
  [i executeScript: s];
  result = ((int)[[let objectForKey: @"str0"] longValue] +
	    (int)[[let objectForKey: @"str1"] longValue] +
	    (int)[[let objectForKey: @"str2"] longValue]);
  fprintf(stderr, "%d + %d + %d ?= %d\n", a, b, c, result);
  if (result == (a + b + c))
    print_result (OK, NULL);
  else
    print_result (ERROR, NULL);
}

/*
 * Testing repl
 */
void
test_repl(GuileInterpreter * i)
{
  NSString * prompt = @"guile test> ";
  print_header ("Testing interpreter repl");
  fprintf(stderr, "(Control D to leave from tests)\n");
  [i replWithPrompt: prompt];
  print_result (OK, NULL);
}

void
test_main (orig_argc, orig_argv)
     int orig_argc;
     char **orig_argv;
{
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
  GuileInterpreter * interp = [[GuileInterpreter alloc] init];

  [GuileInterpreter initializeInterpreter];

  test_nx_constant_string();
  test_gh (interp);
  test_guile_script (interp);
  test_guile_procedure_1 (interp);
  test_guile_procedure_2 (interp);
  test_guile_eval(interp);
  test_exception(interp);
  test_invocation(interp);
  test_keyword(interp);
  test_nsdict(interp);
  test_update(interp);
  test_repl(interp);
  
  [interp release], interp = nil;
  [pool release], pool 	   = nil;
}

int
main (argc, argv)
     int argc;
     char ** argv;
{
  gh_enter(argc, argv, test_main);
  return 0;
}	
