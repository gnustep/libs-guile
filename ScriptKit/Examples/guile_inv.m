/* guilec.m --- sample program using GuileC
   Author: Masatake YAMATO 
   Use under term Of GNU General Public License Version2. 
   (See COPYING) */

#include <ScriptKit/Guile.h>
#include <Foundation/NSAutoreleasePool.h>

void
func (GuileInterpreter * interpreter)
{
  GuileInvocation * inv;
  GuileProcedure *proc = [GuileProcedure procWithExpression: 
					   @"(lambda (x y) (+ x y))"];
  GuileSCM * result;
  
  inv =  [GuileInvocation invocationWithArgc: 2];
  [inv setProcedure: proc];
  [inv setArgument: [GuileSCM scmWithInt: 3] atIndex: 1];
  [inv setArgument: [GuileSCM scmWithInt: 4] atIndex: 2];
  [inv invoke];
  result = [inv returnValue];
  fprintf(stderr, "%d\n", [result intValue]);
}

void
test_main (int orig_argc, char ** orig_argv)
{
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
  [GuileInterpreter initializeInterpreter];
  func ([[[GuileInterpreter alloc] init] autorelease]);
  [pool release], pool 	   = nil;
}

int
main (int argc, char ** argv)
{
  gh_enter(argc, argv, test_main);
  return 0;
}	
