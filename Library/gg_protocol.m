/* gg_protocol.m - interface between guile and GNUstep */

#include <stdlib.h>
#include <objc/runtime.h>

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSSet.h>
#include <Foundation/NSString.h>

#include "private.h"

static char gstep_protocolnames_n[] = "gstep-protocolnames";

static SCM
gstep_protocolnames_fn()
{
  int class_count;
  Class *classes;
  SCM answer = SCM_EOL;
  NSMutableSet *seen;
  CREATE_AUTORELEASE_POOL(arp);

  class_count = objc_getClassList(NULL, 0);
  if (class_count <= 0)
    {
      DESTROY(arp);
      return answer;
    }

  classes = malloc(sizeof(Class) * class_count);
  if (classes == NULL)
    {
      DESTROY(arp);
      gstep_scm_error("could not allocate class list", SCM_EOL);
      return SCM_EOL;
    }

  seen = [NSMutableSet setWithCapacity: 64];
  class_count = objc_getClassList(classes, class_count);
  while (class_count-- > 0)
    {
      unsigned int i;
      unsigned int protocol_count = 0;
      Protocol **protocols = class_copyProtocolList(classes[class_count],
                                                    &protocol_count);

      for (i = 0; i < protocol_count; i++)
        {
          const char *name = protocol_getName(protocols[i]);
          NSString *nsname = [NSString stringWithCString: name];

          if ([seen containsObject: nsname] == NO)
            {
              [seen addObject: nsname];
              answer = scm_cons(gh_str02scm((char*)name), answer);
            }
        }
      free(protocols);
    }

  free(classes);
  DESTROY(arp);
  return answer;
}

static char gstep_lookup_protocol_n[] = "gstep-lookup-protocol";

static SCM
gstep_lookup_protocol_fn (SCM protocolname)
{
  char *name;
  Protocol *protocol;

  if (SCM_NIMP(protocolname) && SCM_SYMBOLP(protocolname))
    {
      protocolname = scm_symbol_to_string(protocolname);
    }
  if ((SCM_NIMP(protocolname) && SCM_STRINGP(protocolname)) == 0)
    {
      gstep_scm_error("not a symbol or string", protocolname);
      return SCM_UNDEFINED;
    }

  name = gh_scm2newstr(protocolname, 0);
  protocol = objc_getProtocol(name);
  free(name);

  return gstep_id2scm((id)protocol, NO);
}

void
gstep_init_protocol()
{
  CFUN(gstep_lookup_protocol_n, 1, 0, 0, gstep_lookup_protocol_fn);
  CFUN(gstep_protocolnames_n, 0, 0, 0, gstep_protocolnames_fn);
}
