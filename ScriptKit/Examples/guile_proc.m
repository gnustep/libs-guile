/* guile_proc.m --- sample program using GuileProcedure
   Author: Masatake YAMATO 
   Use under term Of GNU General Public License Version2. 
   (See COPYING) */

#include <ScriptKit/Guile.h>
#include <Foundation/NSAutoreleasePool.h>

void
func (GuileInterpreter * interpreter)
{
  NSString * lambda    = @"(lambda (x y) (+ x y))";
  GuileProcedure *proc = [GuileProcedure procWithExpression: lambda];
  GuileSCM * result;
  
  result = [proc callWithObjects: 
		   [GuileSCM scmWithInt: 3], [GuileSCM scmWithInt: 4], GUILE_EOA];
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
