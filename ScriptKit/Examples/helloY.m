/* helloY.m --- hello user with ScriptKit 
   Author: Masatake YAMATO 
   Use under term Of GNU General Public License Version2. 
   (See COPYING) */

#include <ScriptKit/Guile.h>
#include <Foundation/NSAutoreleasePool.h>

#include <Foundation/NSPathUtilities.h>

void
func (GuileInterpreter * interpreter)
{
  GuileScript * script = [[GuileScript alloc] init];
  NSString * str;

  str = [@"hello, " stringByAppendingString: NSUserName()];
  str = [str stringByAppendingString: @"\n"];
  str = [@"(display \"" stringByAppendingString: str];
  str = [str stringByAppendingString: @"\")"];
  [script setDelegate: str];
  
  [interpreter executeScript: script];

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
