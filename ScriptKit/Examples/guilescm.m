/* guilec.m --- sample program using GuileC
   Author: Masatake YAMATO 
   Use under term Of GNU General Public License Version2. 
   (See COPYING) */

#include <ScriptKit/Guile.h>
#include <Foundation/NSAutoreleasePool.h>

void
func (GuileInterpreter * interpreter)
{
  GuileScript * script = [[GuileScript alloc] init];
  GuileSCM * result;

  [script setDelegate: @"(+ 3 4)"];
  result = [interpreter executeScript: script];

  fprintf(stderr, "%d\n", [result intValue]);
  [script release], script 	   = nil;
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
