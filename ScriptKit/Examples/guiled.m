/* guilec.m --- sample program using GuileC
   Author: Masatake YAMATO 
   Use under term Of GNU General Public License Version2. 
   (See COPYING) */

#include <ScriptKit/Guile.h>
#include <Foundation/NSAutoreleasePool.h>

void
func (GuileInterpreter * interpreter)
{
  NSMutableDictionary * name_space = [[NSMutableDictionary alloc] init];
  GuileScript * script = [[GuileScript alloc] init];
  NSString * str;

  [name_space setLong: 3 forKey: @"a"];
  [name_space setLong: 4 forKey: @"b"];
  [script setUserDictionary: name_space];

  [script setDelegate: @"(display (+ a b)) (newline)"];
  
  [interpreter executeScript: script];

  [script release], script 	   = nil;
  [name_space release], name_space = nil;
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
