/* GuileSCM.h

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

#ifndef GUILE_S_C_M_H
#define GUILE_S_C_M_H 

#include <gnustep/guile/gstep_guile.h>

#include <Foundation/NSString.h>
#include <Foundation/NSValue.h>
#include <Foundation/NSConcreteNumber.h>
#include <Foundation/NSObject.h>

#include <objc/Object.h>
#include <objc/Protocol.h>

@interface GuileSCM : NSObject
{
    SCM value;
}

+ (void)initialize;
- (id)initWithSCM:(SCM)scm;
- (void)dealloc;

/* If scm is a procedure, this method returns an instance
   of GuileProcedure. */
+ (id)scmWithSCM:(SCM)scm;

+ (GuileSCM *)nilValue;
+ (SCM)nilSCMValue;

+ (void)decode:(SCM)datum ofType:(const char *)type to:(void *)buf;
+ (SCM)encode:(void *)datum ofType:(const char *)type;

+ (SCM)id2scm:(id)o;
+ (id)scm2id:(SCM)o;
+ (NSString *)scm2str:(SCM)o;
- (SCM)scmValue;

- (NSString *)description;
- (NSString *)descriptionWithLocale:(NSDictionary *)locale;

@end

@interface GuileSCM (Debugging)
+ (void) setDebugFlag: (int) flag;
@end
enum {
    GUILESCM_DEBUG_INIT_DEALLOC = 0x01,
    GUILESCM_DEBUG_MAPPER       = 0x02,
    GUILESCM_DEBUG_ALL          = 0xff
};

@interface GuileSCM (TypeConversions)	// Releated predicate of Scheme
- (id)initWithObject:(id)obj;				// objc-id?
- (id)initWithNil;					// objc-nil?
- (id)initWithBool:(BOOL)value;				// boolean?
- (id)initWithChar:(char)value;				// char?
- (id)initWithInt:(int)value;				// number? and integer?
- (id)initWithLong:(long)value;				// number? and integer?
- (id)initWithUnsignedLong:(unsigned long)value;	// number? and integer?
- (id)initWithDouble:(double)value;			// number? and real?
- (id)initWithString:(NSString *)value;			// string?
- (id)initWithCString:(char *)value;			// string?
- (id)initWithSymbolByString:(NSString *)value;		// symbol?
- (id)initWithSymbolByCString:(char *)value;		// symbol?
- (id)initWithEol;					// null?

+ (GuileSCM *)scmWithObject:(id)obj;
+ (GuileSCM *)scmWithNil;
+ (GuileSCM *)scmWithBool:(BOOL)value;
+ (GuileSCM *)scmWithChar:(char)value;
+ (GuileSCM *)scmWithInt:(int)value;
+ (GuileSCM *)scmWithLong:(long)value;
+ (GuileSCM *)scmWithUnsignedLong:(unsigned long)value;
+ (GuileSCM *)scmWithDouble:(double)value;
+ (GuileSCM *)scmWithString:(NSString *)value;
+ (GuileSCM *)scmWithCString:(char *)value;
+ (GuileSCM *)scmWithSymbolByString:(NSString *)value;
+ (GuileSCM *)scmWithSymbolByCString:(char *)value;
+ (GuileSCM *)scmWithEol;

- (id)objectValue;
- (BOOL)boolValue;
- (char)charValue;
- (unsigned char)unsignedCharValue;
- (short)shortValue;
- (unsigned short)unsignedShortValue;
- (int)intValue;
- (unsigned int)unsignedIntValue;
- (long)longValue;
- (unsigned long)unsignedLongValue;
- (long long)longLongValue;
- (unsigned long long)unsignedLongLongValue;
- (float)floatValue;
- (double)doubleValue;
- (NSString *)stringValue;
- (NSString *)symbolStringValue;
@end

@interface GuileSCM (TypePredicates)
- (NSString *)typeInfo;
			// Releated predicate of Scheme
			// (*) masked methods are not disjoint. 
- (BOOL)isBoolean;			// boolean?
- (BOOL)isSymbol;			// symbol?
- (BOOL)isChar;				// char?
- (BOOL)isVector;			// vector?
- (BOOL)isPair;				// pair?
- (BOOL)isNumber;			// number?
- (BOOL)isString;			// string?
- (BOOL)isProcedure;			// procedure?
- (BOOL)isList;				// list? (*)
- (BOOL)isInexact;			// inexact? (*)
- (BOOL)isExact;			// exact? (*)
- (BOOL)isNull;				// null?
- (BOOL)isObject;			// objc-id?
@end

@interface GuileSCM (EqualityPredicates)
- (BOOL) eqWith: b;
- (BOOL) eqvWith: b;
- (BOOL) equalWith: b;
- (BOOL) stringEqualWith: b;
@end

@interface GuileSCM(ListOperations)
+ cons: a and: b;
+ list: first, ...; // GUILE_EOA terminated. 
+ append: ls;
+ append: a and: b;
+ append: a and: b and: c;
+ append: a and: b and: c and: d;
+ reverse: list;
+ memq: x withList: ls;
+ memv: x withList: ls;
+ member: x withList: ls;
+ assq: x withList: ls;
+ assv: x withList: ls;
+ assoc: x withList: ls;
- consWith: b;
- appendWith: b;
- appendWith: b and: c;
- appendWith: b and: c and: d;
- reverse;
- listTailWithIndex: k;
- listRefWithIndex: k;
- (unsigned long) length;
- memq: x;
- memv: x;
- member: x;
- assq: x;
- assv: x;
- assoc: x;
@end


//  Methods translate id to SCM

@interface NSObject(GuileSCM)
+ (SCM)scmValue;
- (SCM)scmValue;
@end

@interface NSBoolNumber (GuileSCM)
- (SCM) scmValue;
@end

@interface NSUCharNumber (GuileSCM)
- (SCM) scmValue;
@end

@interface NSCharNumber (GuileSCM)
- (SCM) scmValue;
@end

@interface NSUShortNumber (GuileSCM)
- (SCM) scmValue;
@end

@interface NSShortNumber (GuileSCM)
- (SCM) scmValue;
@end

@interface NSUIntNumber (GuileSCM)
- (SCM) scmValue;
@end

@interface NSIntNumber (GuileSCM)
- (SCM) scmValue;
@end

@interface NSULongNumber (GuileSCM)
- (SCM) scmValue;
@end

@interface NSLongNumber (GuileSCM)
- (SCM) scmValue;
@end

@interface NSULongLongNumber (GuileSCM)
- (SCM) scmValue;
@end

@interface NSLongLongNumber (GuileSCM)
- (SCM) scmValue;
@end

@interface NSFloatNumber (GuileSCM)
- (SCM) scmValue;
@end

@interface NSDoubleNumber (GuileSCM)
- (SCM) scmValue;
@end

@interface NSString (GuileSCM)
- (SCM) scmValue;
@end

@interface Object(GuileSCM)
+ (SCM) scmValue;
#if defined(__GNUC__) && 0
- (SCM) scmValue;
#endif
@end

@interface Protocol(GuileSCM)
- (SCM) scmValue;
@end


@interface NSMutableDictionary(GuileSCM)
- (void)setLong: (long)l forKey: (NSObject *)aKey;
- (void)setDouble: (double)d forKey: (NSObject *)aKey;
- (void)setBool: (BOOL)b forKey: (NSObject *)aKey;
- (void)setCString: (char *)str forKey: (NSObject *)aKey;
@end

#endif /* Not def: GUILE_S_C_M_H */
