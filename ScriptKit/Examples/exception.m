/* exception.m --- 
   Author: Masatake YAMATO 
   Use under term Of GNU General Public License Version2. 
   (See COPYING) */

#include <ScriptKit/Guile.h>
#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSException.h>

void
func (GuileInterpreter * interpreter)
{
  NSString * script1, * script2;
  script1 = @"(define ARRAY ([] 'NSArray array)) ([] ARRAY objectAtIndex: 0)";
  script2 = @"(define LIST (list 1 2)) (list-ref LIST 2)";
  
  NS_DURING
    {
      [interpreter eval: script1];
    }
  NS_HANDLER
    {
      printf("The 1st NSException is caught.\n");
      printf("Exception Name: %s\n", [[localException name] cString]);
      printf("Reason: %s\n",  [[localException reason] cString]);
    }
  NS_ENDHANDLER;

  NS_DURING
    {
      [interpreter eval: script2];
    }
  NS_HANDLER
    {
      printf("The 2nd NSException is caught.\n");
      printf("Exception Name: %s\n", [[localException name] cString]);
      printf("Reason: %s\n",  [[localException reason] cString]);
    }
  NS_ENDHANDLER;
  
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
