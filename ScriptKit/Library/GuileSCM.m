/* GuileSCM.m

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

/* GuileSCM.m created by dlehn on Wed 18-Jun-1997 */

#include "../config.h"
#include "Guile.h"
#include <Foundation/NSObjCRuntime.h>
#include <Foundation/NSException.h>

#include <objc/objc.h>
#include <objc/objc-api.h>
#include <guile/gh.h>

#include <gstep_guile.h>

#define DEBUG_PRINT(FLAG, X...) \
	if (GuileSCM_debug_flag & (FLAG)) printf (X)
#define DEBUG_INIT_DEALLOC(X...)	DEBUG_PRINT (GUILESCM_DEBUG_INIT_DEALLOC, X)
#define DEBUG_MAPPER(X...)		DEBUG_PRINT (GUILESCM_DEBUG_MAPPER, X)

static int GuileSCM_debug_flag = 0;
static GuileSCM *GuileSCM_nil = nil;

static void GuileSCM_mapper_init ();
static void GuileSCM_mapper_add (SCM scm, id guilescm);
static void GuileSCM_mapper_remove (SCM scm);

@implementation GuileSCM
+ (void)initialize
{
    GuileSCM_mapper_init ();
}

/* this is root of init */
- (id)initWithSCM: (SCM)scm
{
  self = [super init] ;
  if(self)
    {
      DEBUG_INIT_DEALLOC ("GuileSCM init: %p\n", self);
      value = scm;
      GuileSCM_mapper_add (scm, self);
    }
  return self;
}
- (void) dealloc
{
  SCM	scm = value;
  GuileSCM_mapper_remove (scm);
  DEBUG_INIT_DEALLOC ("GuileSCM dealloc: %p\n", self);
  [super dealloc];
}

+ (id)scmWithSCM:(SCM)scm
{
  if (gh_procedure_p(scm))
    return [[[GuileProcedure alloc] initWithSCM:scm] autorelease];
  else
    return [[[self alloc] initWithSCM:scm] autorelease];
}

- (SCM)scmValue
{
    return value;
}

+ (GuileSCM *)nilValue
{
    if( GuileSCM_nil == nil ) {
      GuileSCM_nil = [[GuileSCM alloc] initWithSCM:gstep_id2scm(nil, NO)];
    }
    return GuileSCM_nil;
}

+ (SCM)nilSCMValue
{
    return gstep_id2scm (nil, NO);
}

+ (SCM)id2scm:(id)o
{
	return gstep_id2scm(o,NO);
}

// only pass a SCM with smob car == scm_tc16_OpenStep
+ (id)scm2id:(SCM)scm
{
	// return gstep_guile_scm2id(scm);
	// I think that gstep_guile_scm2id have a problem.

	 return (id) gh_cdr(scm);
}

+ (NSString *)scm2str:(SCM)scm
{
    NSString *ret_str;
    char *str;
    int len;

    // How do you think about exception?
    if (!(SCM_NIMP (scm) && (SCM_STRINGP (scm) || SCM_SYMBOLP(scm))))
      {
	[NSException raise: NSInvalidArgumentException
		     format: @"Can't convert to string"];
	/* TODO: I think any typed object should be converted to a string. 
	   - masatake
	 e.g.
	 17(int) -> @"17".
	 3.14(float) -> @"3.14".
	 ... */
      }

    /* protect str from GC while we copy off its data */
    scm_protect_object (scm);

    str = SCM_CHARS (scm);
    len = SCM_LENGTH (scm);

    ret_str = [NSString stringWithCString:str length:len];

    scm_unprotect_object (scm);

    return ret_str;
}

#define constFlag  (1<<1)
#define inFlag     (1<<2)
#define inoutFlag  (1<<3)
#define outFlag    (1<<4)
#define bycopyFlag (1<<5)
#define byrefFlag  (1<<6)
#define onewayFlag (1<<7)

+ (void)decode:(SCM)datum ofType:(const char *)type to:(void *)buf
{
    char *tptr = (char *)type;
    int flags = 0;
    switch (*tptr) {
        case 'r':
            flags |= constFlag;
            break;
        case 'n':
            flags |= inFlag;
            break;
        case 'N':
            flags |= inoutFlag;
            break;
        case 'o':
            flags |= outFlag;
            break;
        case 'O':
            flags |= bycopyFlag;
            break;
        case 'R':
            flags |= byrefFlag;
            break;
        case 'V':
            flags |= onewayFlag;
            break;
    }
    if( flags != 0 )
        tptr++;
    switch (*tptr) {
        case '@':
        case '#':
            *(id*)buf = [GuileSCM scm2id:datum];
            break;
        case 'c':
            *(char*)buf = (char) gh_scm2char(datum);
            break;
        case 'C':
            *(unsigned char*)buf = (unsigned char) gh_scm2ulong(datum);
            break;
        case 's':
            *(short*)buf = (short) gh_scm2long(datum);
            break;
        case 'S':
            *(unsigned short*)buf = (unsigned short) gh_scm2ulong(datum);
            break;
        case 'i':
            *(int*)buf = (int) gh_scm2int(datum);
            break;
        case 'I':
            *(unsigned int*)buf = (unsigned int) gh_scm2ulong(datum);
            break;
        case 'l':
            *(long*)buf = (long) gh_scm2long(datum);
            break;
        case 'L':
            *(unsigned long*)buf = (unsigned long) gh_scm2ulong(datum);
            break;
        case 'q':
            *(long long*)buf = (long long) gh_scm2long(datum);
            break;
        case 'Q':
            *(unsigned long long*)buf = (unsigned long long) gh_scm2ulong(datum);
            break;
        case 'f':
            *(float*)buf = (float) gh_scm2double(datum);
            break;
        case 'd':
            *(double*)buf = gh_scm2double(datum);
            break;
        case ':': {
            NSString *str = [GuileSCM scm2str:datum];
            *(SEL*)buf = NSSelectorFromString(str);
            break;
        }
        case '*': {
            NSString *str = [GuileSCM scm2str:datum];
            *(char**)buf = (char*)[str cString];
            break;
        }
        default:
            [GuileInterpreter scmError:@"don't handle that datum type yet" args:datum];
    }
    return;
}


// DIL add DO support!
// guileobjc hackers, Steal this code! 
+ (SCM)encode:(void *)datum ofType:(const char *)type
{
    switch (*type) {
        case '@':
        case '#':
            return [*(id*)datum scmValue];
            break;
        case 'c':
            return gh_char2scm(*(char*)datum);
            break;
        case 'C':
            return gh_ulong2scm((unsigned long) *(unsigned char*)datum);
            break;
        case 's':
            return gh_long2scm((long) *(short*)datum);
            break;
        case 'S':
            return gh_ulong2scm((unsigned long) *(unsigned short*)datum);
            break;
        case 'i':
            return gh_int2scm(*(int*)datum);
            break;
        case 'I':
            return gh_ulong2scm((unsigned long) *(unsigned int*)datum);
            break;
        case 'l':
            return gh_long2scm(*(long*)datum);
            break;
        case 'L':
            return gh_ulong2scm(*(unsigned long*)datum);
            break;
        case 'f':
            return gh_double2scm((double) *(float*)datum);
            break;
        case 'd':
            return gh_double2scm(*(double*)datum);
            break;
        case '*':
            return gh_str02scm(*(char**)datum);
            break;
        default:
            [GuileInterpreter scmError:@"don't handle that return type yet" args:SCM_UNDEFINED];
            return SCM_UNDEFINED;
            break;
    }
}

- (NSString *)description
{
  // what to do?
  return [self descriptionWithLocale: nil];
}

- (NSString *)descriptionWithLocale:(NSDictionary *)locale
{
  static SCM write2str = SCM_BOOL_F;
  char *tmpstr;
  NSString *ret;
  
  if (write2str == SCM_BOOL_F)
    {
      write2str = gh_eval_str ("(lambda (x) (call-with-output-string (lambda (port) (write x port))))");
      scm_protect_object (write2str);
    }
  
  tmpstr = gh_scm2newstr (gh_call1 (write2str, value), NULL);
  
  ret = [[[super description] stringByAppendingString: @" "]
	   stringByAppendingString: [NSString stringWithCString: tmpstr]];
  free (tmpstr);
  return ret;
}

@end



///
///	Debugging
///

@implementation GuileSCM (Debugging)
+ (void) setDebugFlag: (int) flag
{
    GuileSCM_debug_flag = flag;
}
@end



///
///	SCM <-> GuileSCM mapper
///
#include <Foundation/NSMapTable.h>
static NSMapTable * map_SCM_to_GuileSCM;

/*
 * Key side call backs
 */
// is this ok?
#define _OBJECTS_NOT_A_SCM_MARKER (const void *) SCM_UNDEFINED

/* Callbacks for SCM */
static unsigned map_SCM_hash(NSMapTable * table, SCM i);        /* hash */
static BOOL map_SCM_is_equal(NSMapTable * table, SCM i, SCM j); /* isEqual */
static void map_SCM_retain(NSMapTable * table, SCM i);          /* retain  */ 
static void map_SCM_release(NSMapTable * table, SCM i);         /* release */
static NSString * map_SCM_describe(NSMapTable * table, SCM i);  /* describe */

static NSMapTableKeyCallBacks map_callbacks_for_SCM =
{
  (unsigned (*)(NSMapTable *, const void *))map_SCM_hash,
  (BOOL     (*)(NSMapTable *, const void *, const void *))map_SCM_is_equal,
  (void     (*)(NSMapTable *, const void *))map_SCM_retain,
  (void     (*)(NSMapTable *, void *))map_SCM_release,
  (NSString *(*)(NSMapTable *, const void *))map_SCM_describe,
  _OBJECTS_NOT_A_SCM_MARKER
};

static unsigned
map_SCM_hash(NSMapTable * table, SCM i) 
{
  return (unsigned) i;
}

static BOOL
map_SCM_is_equal(NSMapTable * table, SCM i, SCM j)
{
  return (i == j)? YES: NO;
}

static void map_SCM_retain
(NSMapTable * table, SCM i)
{
  return ;
}

static void
map_SCM_release(NSMapTable * table, SCM i)
{
  return;
}

static NSString *
map_SCM_describe(NSMapTable * table, SCM i)
{
  /* FIXME: Code this. */
  return nil;
}

/* 
 * guile SMOB 
 */
static int scm_tc16_mapper_dummy;
static SCM mark_mapper_dummy (SCM mapper_dummy);

static SCM
mark_mapper_dummy (SCM mapper_dummy)
{
  NSMapEnumerator  en;
  SCM             scm;
  id         guilescm;
  DEBUG_MAPPER ("mapper: start marking\n");

  SCM_SETGC8MARK (mapper_dummy);

  en = NSEnumerateMapTable (map_SCM_to_GuileSCM);
  while (NSNextMapEnumeratorPair(&en, (void**) &scm, (void**)&guilescm))
    {
      scm_gc_mark (scm);
      DEBUG_MAPPER ("mapper: marked SCM 0x%lx\n", (unsigned long) scm);
    }
  DEBUG_MAPPER ("mapper: done marking\n");

  return SCM_BOOL_F;
}

/*
 * Map interface 
 */
static void
GuileSCM_mapper_init ()
{
  SCM	mapper_dummy;
#if	GUILE_MAKE_SMOB_TYPE
  scm_tc16_mapper_dummy = scm_make_smob_type ("mapper_dummy", 0);
  scm_set_smob_mark(scm_tc16_mapper_dummy, mark_mapper_dummy);
  scm_set_smob_free(gstep_scm_tc16_class, 0);
  scm_set_smob_print(gstep_scm_tc16_class, 0);
  scm_set_smob_equalp(gstep_scm_tc16_class, 0);
#else
  static scm_smobfuns mapper_dummy_smob = 
  {
    mark_mapper_dummy, 
    0, 
    0, 
    0
  };

  scm_tc16_mapper_dummy = scm_newsmob (&mapper_dummy_smob);
#endif
  
  SCM_NEWCELL(mapper_dummy);
  SCM_SETCAR (mapper_dummy, scm_tc16_mapper_dummy);
  SCM_SETCDR (mapper_dummy, 0);
  scm_protect_object (mapper_dummy);

  map_SCM_to_GuileSCM = NSCreateMapTable(map_callbacks_for_SCM,
					 NSNonOwnedPointerMapValueCallBacks,
					 16);
}

static void
GuileSCM_mapper_add (SCM scm, id guilescm)
{
  DEBUG_MAPPER ("mapper: added SCM 0x%lx for GuileSCM %p\n",
		(unsigned long) scm, 
		guilescm);
  NSMapInsert (map_SCM_to_GuileSCM, (void *) scm, guilescm);  
}

static void
GuileSCM_mapper_remove (SCM scm)
{
  DEBUG_MAPPER ("mapper: removed SCM 0x%lx\n", (unsigned long) scm);
  NSMapRemove (map_SCM_to_GuileSCM, (void *) scm);
}



///
///	Type conversions
///

@implementation GuileSCM (TypeConversions)
- initWithObject: (id) obj
{
  return [self initWithSCM: gstep_id2scm (obj, YES)];
}
- initWithNil
{
  [self dealloc];
  return [GuileSCM nilValue];
}
- initWithBool: (BOOL) x
{
  return [self initWithSCM: gh_bool2scm (x)];
}
- initWithChar: (char) x
{
  return [self initWithSCM: gh_char2scm (x)];
}
- initWithInt: (int) x
{
  return [self initWithSCM: gh_int2scm (x)];
}
- initWithLong: (long) x
{
  return [self initWithSCM: gh_long2scm (x)];
}
- initWithUnsignedLong: (unsigned long) x
{
  return [self initWithSCM: gh_ulong2scm (x)];
}
- initWithDouble: (double) x
{
  return [self initWithSCM: gh_double2scm (x)];
}
- initWithString: (NSString *) x
{
  return [self initWithSCM: gh_str2scm ((char *) [x cString], [x length])];
}
- initWithCString: (char *) x
{
  return [self initWithSCM: gh_str02scm (x)];
}
- initWithSymbolByString: (NSString *) x
{
  return [self initWithSCM: gh_symbol2scm ((char *) [x cString])];
}
- initWithSymbolByCString: (char *) x
{
  return [self initWithSCM: gh_symbol2scm (x)];
}
- initWithEol
{
  return [self initWithSCM: SCM_EOL];
}

+ (GuileSCM *) scmWithObject: (id) obj
{
  return [self scmWithSCM: gstep_id2scm (obj, YES)];
}
+ (GuileSCM *) scmWithNil
{
  return [GuileSCM nilValue];
}
+ (GuileSCM *) scmWithBool: (BOOL) v
{
  return [self scmWithSCM: gh_bool2scm (v)];
}
+ (GuileSCM *) scmWithChar: (char) v
{
  return [self scmWithSCM: gh_char2scm (v)];
}
+ (GuileSCM *) scmWithInt: (int) v
{
  return [self scmWithSCM: gh_int2scm (v)];
}
+ (GuileSCM *) scmWithLong: (long) v
{
  return [self scmWithSCM: gh_long2scm (v)];
}
+ (GuileSCM *) scmWithUnsignedLong: (unsigned long) v
{
  return [self scmWithSCM: gh_ulong2scm (v)];
}
+ (GuileSCM *) scmWithDouble: (double) v
{
  return [self scmWithSCM: gh_double2scm (v)];
}
+ (GuileSCM *) scmWithString: (NSString *) v
{
  return [self scmWithSCM: gh_str2scm ((char *) [v cString], [v length])];
}
+ (GuileSCM *) scmWithCString: (char *) v
{
  return [self scmWithSCM: gh_str02scm (v)];
}
+ (GuileSCM *) scmWithSymbolByString: (NSString *) v
{
  return [self scmWithSCM: gh_symbol2scm ((char *) [v cString])];
}
+ (GuileSCM *) scmWithSymbolByCString: (char *) v
{
  return [self scmWithSCM: gh_symbol2scm (v)];
}
+ (GuileSCM *) scmWithEol
{
  return [self scmWithSCM: SCM_EOL];
}

- (id) objectValue
{
  return gstep_scm2id (value);
}
- (BOOL) boolValue
{
  return gh_scm2bool (value);
}
- (char) charValue
{
  return gh_scm2char (value);
}
- (unsigned char) unsignedCharValue
{
  return (unsigned char) gh_scm2char (value);
}
- (short) shortValue
{
  return (short) gh_scm2int (value);
}
- (unsigned short) unsignedShortValue
{
  return (unsigned short) gh_scm2int (value);
}
- (int) intValue
{
  return gh_scm2int (value);
}
- (unsigned int) unsignedIntValue
{
  return (unsigned int) gh_scm2int (value);
}
- (long) longValue
{
  return gh_scm2long (value);
}
- (unsigned long) unsignedLongValue
{
  return gh_scm2ulong (value);
}
- (long long) longLongValue
{
  abort ();	// not yet implemented
  return 0;
}
- (unsigned long long) unsignedLongLongValue
{
  abort ();
  return 0;
}
- (float) floatValue
{
  return (float) gh_scm2double (value);
}
- (double) doubleValue
{
  return gh_scm2double (value);
}
- (NSString *)stringValue;
{
  id		str;
  char	*tmp;
  int		len;
    
  tmp = gh_scm2newstr (value, &len);
  str = [NSString stringWithCString: tmp length: len];
  free (tmp);
  return str;
}
- (NSString *)symbolStringValue;
{
  id		str;
  char	*tmp;
  int		len;
    
  tmp = gh_symbol2newstr (value, &len);
  str = [NSString stringWithCString: tmp length: len];
  free (tmp);
  return str;
}
@end				// GuileSCM (TypeConversions)



///
///	Type predicates
///

@implementation GuileSCM (TypePredicates)
- (NSString *)typeInfo
{
  return [NSString stringWithFormat:@"%d\tbool\n%d\tsym\n%d\tch\n%d\tvec\n%d\tpair\n%d\tnum\n%d\tstr\n%d\tproc\n%d\tlist\n%d\tinex\n%d\tex",
		   gh_boolean_p(value),
		   gh_symbol_p(value),
		   gh_char_p(value),
		   gh_vector_p(value),
		   gh_pair_p(value),
		   gh_number_p(value),
		   gh_string_p(value),
		   gh_procedure_p(value),
		   gh_list_p(value),
		   gh_inexact_p(value),
		   gh_exact_p(value)
	   ];
}

- (BOOL)isObject
{
  return gstep_id_p (value);
}
- (BOOL)isBoolean
{
  return gh_boolean_p (value);
}
- (BOOL)isSymbol
{
  return gh_symbol_p (value);
}
- (BOOL)isChar
{
  return gh_char_p (value);
}
- (BOOL)isVector
{
  return gh_vector_p (value);
}
- (BOOL)isPair
{
  return gh_pair_p (value);
}
- (BOOL)isNumber
{
  return gh_number_p (value);
}
- (BOOL)isString
{
  return gh_string_p (value);
}
- (BOOL)isProcedure
{
  return gh_procedure_p (value);
}
- (BOOL)isList
{
  return gh_list_p (value);
}
- (BOOL)isInexact
{
  return gh_inexact_p (value);
}
- (BOOL)isExact
{
  return gh_exact_p (value);
}
- (BOOL)isNull
{
  return gh_null_p (value);
}
@end				// GuileSCM (TypePredicates)



///
///	Equality predicates
///

@implementation GuileSCM (EqualityPredicates)
- (BOOL) eqWith: b;
{
  return gh_eq_p (value, [b scmValue]);
}
- (BOOL) eqvWith: b;
{
  return gh_eqv_p (value, [b scmValue]);
}
- (BOOL) equalWith: b;
{
  return gh_equal_p (value, [b scmValue]);
}
- (BOOL) stringEqualWith: b;
{
  return gh_string_equal_p (value, [b scmValue]);
}
@end				// GuileSCM(EqualityPredicates)



//
//	List operations
//

@implementation GuileSCM(ListOperations)
+ cons: a and: b
{
  return [GuileSCM scmWithSCM: gh_cons ([a scmValue], [b scmValue])];
}
+ list: first, ...
{
  SCM		args = SCM_EOL;
  va_list	va;
  id		tmp;
  id            eoa = GUILE_EOA;
  va_start (va, first);
  for (tmp = first; tmp != eoa ; tmp = va_arg (va, id)) {
    args = gh_cons ([tmp scmValue], args);
  }
  va_end (va);
  args = gh_reverse (args);
  return [GuileSCM scmWithSCM: args];
}
+ append: ls
{
  return [GuileSCM scmWithSCM: gh_append ([ls scmValue])];
}
+ append: a and: b
{
  return [GuileSCM scmWithSCM: gh_append2 ([a scmValue], [b scmValue])];
}
+ append: a and: b and: c
{
  return [GuileSCM scmWithSCM: gh_append3 ([a scmValue], [b scmValue], [c scmValue])];
}
+ append: a and: b and: c and: d
{
  return [GuileSCM scmWithSCM: gh_append4 ([a scmValue], [b scmValue], [c scmValue], [d scmValue])];
}
+ reverse: ls
{
  return [GuileSCM scmWithSCM: gh_reverse ([ls scmValue])];
}
+ memq: x withList: ls
{
  return [GuileSCM scmWithSCM: gh_memq ([x scmValue], [ls scmValue])];
}
+ memv: x withList: ls
{
  return [GuileSCM scmWithSCM: scm_memv ([x scmValue], [ls scmValue])];
}
+ member: x withList: ls
{
  return [GuileSCM scmWithSCM: scm_member ([x scmValue], [ls scmValue])];
}
+ assq: x withList: ls
{
  return [GuileSCM scmWithSCM: gh_assq ([x scmValue], [ls scmValue])];
}
+ assv: x withList: ls
{
  return [GuileSCM scmWithSCM: gh_assv ([x scmValue], [ls scmValue])];
}
+ assoc: x withList: ls
{
  return [GuileSCM scmWithSCM: gh_assoc ([x scmValue], [ls scmValue])];
}

- consWith: b;
{
  return [GuileSCM cons: self and: b];
}
- appendWith: b;
{
  return [GuileSCM append: self and: b];
}
- appendWith: b and: c;
{
  return [GuileSCM append: self and: b and: c];
}
- appendWith: b and: c and: d;
{
  return [GuileSCM append: self and: b and: c and: d];
}
- reverse
{
  return [GuileSCM reverse: self];
}
- listTailWithIndex: k
{
  return [GuileSCM scmWithSCM: gh_list_tail ([self scmValue], [k scmValue])];
}
- listRefWithIndex: k
{
  return [GuileSCM scmWithSCM: gh_list_ref ([self scmValue], [k scmValue])];
}
- (unsigned long) length
{
  return gh_length ([self scmValue]);
}
- memq: x
{
  return [GuileSCM memq: x withList: self];
}
- memv: x
{
  return [GuileSCM memv: x withList: self];
}
- member: x
{
  return [GuileSCM member: x withList: self];
}
- assq: x
{
  return [GuileSCM assq: x withList: self];
}
- assv: x
{
  return [GuileSCM assv: x withList: self];
}
- assoc: x
{
  return [GuileSCM assoc: x withList: self];
}
@end				// GuileSCM(ListOperations)



///
///	scmValue
///

@implementation NSObject(GuileSCM)
+ (SCM)scmValue
{
  return gstep_id2scm (self, YES);
}
- (SCM)scmValue
{
  return gstep_id2scm (self, YES);
}
@end

@implementation NSBoolNumber (GuileSCM)
- (SCM) scmValue
{
  return gh_bool2scm ([self boolValue]);
}
@end

@implementation NSUCharNumber (GuileSCM)
- (SCM) scmValue
{
  return gh_char2scm ((char) [self unsignedCharValue]);
}
@end

@implementation NSCharNumber (GuileSCM)
- (SCM) scmValue
{
  return gh_char2scm ([self charValue]);
}
@end

@implementation NSUShortNumber (GuileSCM)
- (SCM) scmValue
{
  return gh_ulong2scm ([self unsignedShortValue]);
}
@end

@implementation NSShortNumber (GuileSCM)
- (SCM) scmValue
{
  return gh_long2scm ([self shortValue]);
}
@end

@implementation NSUIntNumber (GuileSCM)
- (SCM) scmValue
{
  return gh_ulong2scm ([self unsignedIntValue]);
}
@end

@implementation NSIntNumber (GuileSCM)
- (SCM) scmValue
{
  return gh_long2scm ([self intValue]);
}
@end

@implementation NSULongNumber (GuileSCM)
- (SCM) scmValue
{
  return gh_ulong2scm ([self unsignedLongValue]);
}
@end

@implementation NSLongNumber (GuileSCM)
- (SCM) scmValue
{
  return gh_long2scm ([self longValue]);
}
@end

@implementation NSULongLongNumber (GuileSCM)
- (SCM) scmValue
{
  return gh_ulong2scm ((unsigned long) [self unsignedLongLongValue]);
}
@end

@implementation NSLongLongNumber (GuileSCM)
- (SCM) scmValue
{
  return gh_long2scm ((long) [self longLongValue]);
}
@end

@implementation NSFloatNumber (GuileSCM)
- (SCM) scmValue
{
  return gh_double2scm ((double) [self floatValue]);
}
@end

@implementation NSDoubleNumber (GuileSCM)
- (SCM) scmValue
{
  return gh_double2scm ([self doubleValue]);
}
@end

@implementation NSString (GuileSCM)
- (SCM) scmValue
{
  return gh_str2scm ((char *) [self cString], [self length]);
}
@end

@implementation Object(GuileSCM)
+ (SCM) scmValue
{
  return gstep_id2scm (self, YES);
}
#if defined(__GNUC__) && 0
- (SCM)scmValue;
{
  return gstep_id2scm (self, YES);
}
#endif
@end

@implementation Protocol(GuileSCM)
- (SCM) scmValue
{
 return gstep_id2scm (self, YES); 
}
@end


@implementation NSMutableDictionary(GuileSCM)
- (void)setLong: (long)l forKey: (NSObject *)aKey
{
  [self setObject: [GuileSCM scmWithLong: l] forKey: aKey];
}
- (void)setDouble: (double)d forKey: (NSObject *)aKey
{
  [self setObject: [GuileSCM scmWithDouble: d] forKey: aKey];
}
- (void)setBool: (BOOL)b forKey: (NSObject *)aKey
{
  [self setObject: [GuileSCM scmWithBool: b] forKey: aKey];
}
- (void)setCString: (char *)str forKey: (NSObject *)aKey
{
  [self setObject: [GuileSCM scmWithCString: str] forKey: aKey];
}
@end
