/* link_base.m - Ensure foundation library stuff is available.
   Copyright (C) 1998 Free Software Foundation, Inc.

   Written by:  Richard Frith-Macdonald <richard@brainstorm.co.uk>
   Date: April 1998

   This file is part of the GNUstep-Guile Library.

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
   Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
   */

#include <Foundation/Foundation.h>

/*
 *	Missing headers in libFoundation Foundation.h
 */
#if	defined(LIB_FOUNDATION_LIBRARY)
#  include	<Foundation/NSHost.h>
#endif

#include "private.h"



static void
gstep_base_numeric_constants()
{
  CNUM(NSAnchoredSearch);
  CNUM(NSBackwardsSearch);
  CNUM(NSCaseInsensitiveSearch);
  CNUM(NSLiteralSearch);
  CNUM(NSMaxXEdge);
  CNUM(NSMaxYEdge);
  CNUM(NSMinXEdge);
  CNUM(NSMinYEdge);
  CNUM(NSNotFound);
  CNUM(NSNotificationCoalescingOnName);
  CNUM(NSNotificationCoalescingOnSender);
  CNUM(NSNotificationNoCoalescing);
  CNUM(NSOrderedAscending);
  CNUM(NSOrderedDescending);
  CNUM(NSOrderedSame);
  CNUM(NSPostASAP);
  CNUM(NSPostNow);
  CNUM(NSPostWhenIdle);
}



static void
gstep_base_string_constants()
{
  CSTR(NSAMPMDesignation);
  CSTR(NSArgumentDomain);
  CSTR(NSCurrencyString);
  CSTR(NSCurrencySymbol);
  CSTR(NSDateFormatString);
  CSTR(NSDecimalDigits);
  CSTR(NSDecimalSeparator);
  CSTR(NSDefaultRunLoopMode);
  CSTR(NSFileAppendOnly);
  CSTR(NSFileCreationDate);
  CSTR(NSFileDeviceIdentifier);
  CSTR(NSFileExtensionHidden);
  CSTR(NSFileGroupOwnerAccountID);
  CSTR(NSFileGroupOwnerAccountName);
  CSTR(NSFileHFSCreatorCode);
  CSTR(NSFileHFSTypeCode);
  CSTR(NSFileHandleConnectionAcceptedNotification);
  CSTR(NSFileHandleNotificationDataItem);
  CSTR(NSFileHandleNotificationFileHandleItem);
  CSTR(NSFileHandleNotificationMonitorModes);
  CSTR(NSFileHandleReadCompletionNotification);
  CSTR(NSFileHandleReadToEndOfFileCompletionNotification);
  CSTR(NSFileImmutable);
  CSTR(NSFileModificationDate);
  CSTR(NSFileOwnerAccountID);
  CSTR(NSFileOwnerAccountName);
  CSTR(NSFilePosixPermissions);
  CSTR(NSFileReferenceCount);
  CSTR(NSFileSize);
  CSTR(NSFileSystemFreeNodes);
  CSTR(NSFileSystemFreeSize);
  CSTR(NSFileSystemNodes);
  CSTR(NSFileSystemNumber);
  CSTR(NSFileSystemSize);
  CSTR(NSFileType);
  CSTR(NSFileTypeBlockSpecial);
  CSTR(NSFileTypeCharacterSpecial);
  CSTR(NSFileTypeDirectory);
  CSTR(NSFileTypeRegular);
  CSTR(NSFileTypeSocket);
  CSTR(NSFileTypeSymbolicLink);
  CSTR(NSFileTypeUnknown);
  CSTR(NSGenericException);
  CSTR(NSGlobalDomain);
  CSTR(NSInconsistentArchiveException);
  CSTR(NSInternalInconsistencyException);
  CSTR(NSInternationalCurrencyString);
  CSTR(NSInvalidArgumentException);
  CSTR(NSMallocException);
  CSTR(NSMonthNameArray);
  CSTR(NSRangeException);
  CSTR(NSRegistrationDomain);
  CSTR(NSShortMonthNameArray);
  CSTR(NSShortTimeDateFormatString);
  CSTR(NSShortWeekDayNameArray);
  CSTR(NSThousandsSeparator);
  CSTR(NSTimeDateFormatString);
  CSTR(NSTimeFormatString);
  CSTR(NSWeekDayNameArray);

/*
*	Extra functionality of gstep-base
*/
#if	defined(GSTEP_BASE_VERSION)
  CSTR(GSFileHandleConnectCompletionNotification);
  CSTR(GSFileHandleNotificationError);
  CSTR(GSFileHandleWriteCompletionNotification);
#endif

/*
*	Missing functionality of libFoundation
*/
#if	!defined(LIB_FOUNDATION_LIBRARY)
  CSTR(NSBundleDidLoadNotification);
  CSTR(NSFileHandleOperationException);
  CSTR(NSConnectionDidDieNotification);
  CSTR(NSConnectionReplyMode);
  CSTR(NSLoadedClasses);
  CSTR(NSPortDidBecomeInvalidNotification);
  CSTR(NSShowNonLocalizedStrings);
  CSTR(NSUndoManagerCheckpointNotification);
  CSTR(NSUndoManagerDidOpenUndoGroupNotification);
  CSTR(NSUndoManagerDidRedoChangeNotification);
  CSTR(NSUndoManagerDidUndoChangeNotification);
  CSTR(NSUndoManagerWillCloseUndoGroupNotification);
  CSTR(NSUndoManagerWillRedoChangeNotification);
  CSTR(NSUndoManagerWillUndoChangeNotification);
#endif
}



static void
gstep_base_pointer_constants()
{
  CPTR(&NSIntHashCallBacks);
  CPTR(&NSIntMapKeyCallBacks);
  CPTR(&NSIntMapValueCallBacks);
  CPTR(&NSNonOwnedPointerHashCallBacks);
  CPTR(&NSNonOwnedPointerMapKeyCallBacks);
  CPTR(&NSNonOwnedPointerMapValueCallBacks);
  CPTR(&NSNonOwnedPointerOrNullMapKeyCallBacks);
  CPTR(&NSNonRetainedObjectHashCallBacks);
  CPTR(&NSNonRetainedObjectMapKeyCallBacks);
  CPTR(&NSObjectMapKeyCallBacks);
  CPTR(&NSObjectMapValueCallBacks);
  CPTR(&NSObjectHashCallBacks);
  CPTR(&NSOwnedPointerHashCallBacks);
  CPTR(&NSOwnedPointerMapKeyCallBacks);
  CPTR(&NSOwnedPointerMapValueCallBacks);
  CPTR(&NSPointerToStructHashCallBacks);
}



/*
 *	The macro 'CALL()' is used to call a function safely - doing
 *	any required autorelease stuff and exception handling.
 */
#define	CALL(OP) {\
    NSAutoreleasePool	*arp = [NSAutoreleasePool new];\
    SCM			s_name = SCM_UNDEFINED;\
    SCM			s_reason = SCM_UNDEFINED;\
\
    NS_DURING\
    {\
        OP;\
    }\
    NS_HANDLER\
    {\
	const char *name   = [[localException name] lossyCString];\
	const char *reason = [[localException reason] lossyCString];\
\
	s_name = gh_symbol2scm((char*)name);\
	s_reason = gh_str02scm((char*)reason);\
    }\
    NS_ENDHANDLER\
\
    [arp release];\
    if (s_name != SCM_UNDEFINED) {\
	scm_throw(s_name, s_reason);\
	return SCM_UNDEFINED;\
    }\
}\



/*
 *	Functions dealing with NSZones
 */

static char gstep_NSCreateZone_n[] = "NSCreateZone";

static SCM
gstep_NSCreateZone(SCM s, SCM g, SCM f)
{
  int	start;
  int	granularity;
  int	canFree;
  NSZone	*z;
  SCM	answer;

  SCM_ASSERT(gh_number_p(s), s, SCM_ARG1, gstep_NSCreateZone_n);
  SCM_ASSERT(gh_number_p(g), g, SCM_ARG2, gstep_NSCreateZone_n);
  SCM_ASSERT(gh_number_p(f), f, SCM_ARG3, gstep_NSCreateZone_n);

  start = gh_scm2int(s);
  granularity = gh_scm2int(g);
  canFree = gh_scm2int(f);
  CALL(z = NSCreateZone(start, granularity, canFree))
  /*
   *	Create a voidp object for the zone - specify lengthKnown=YES and
   *	length=0 so that it can't be written into as if it were arbitrary
   *	memory - it's only usable as a handle to be passed to things expecting
   *	an NSZone.
   */
  answer = gstep_voidp2scm((void*)z, NO, YES, 0);
  return answer;
}


static char gstep_NSDefaultMallocZone_n[] = "NSDefaultMallocZone";

static SCM
gstep_NSDefaultMallocZone()
{
  NSZone	*z;
  SCM	answer;

  CALL(z = NSDefaultMallocZone())
  answer = gstep_voidp2scm((void*)z, NO, YES, 0);
  return answer;
}

static char gstep_NSRecycleZone_n[] = "NSRecycleZone";

static SCM
gstep_NSRecycleZone(SCM s)
{
  NSZone	*z;

  SCM_ASSERT(gstep_voidp_p(s), s, SCM_ARG1, gstep_NSRecycleZone_n);
  z = (NSZone*)gstep_scm2voidp(s);
  CALL(NSRecycleZone(z))
  return SCM_UNDEFINED;
}

static char gstep_NSSetZoneName_n[] = "NSSetZoneName";

static SCM
gstep_NSSetZoneName(SCM s, SCM i)
{
  NSZone	*z;

  SCM_ASSERT(gstep_voidp_p(s), s, SCM_ARG1, gstep_NSSetZoneName_n);
  SCM_ASSERT(gstep_id_p(i), i, SCM_ARG2, gstep_NSSetZoneName_n);
  z = (NSZone*)gstep_scm2voidp(s);
  CALL(NSSetZoneName(z, gstep_scm2id(i)))
  return SCM_UNDEFINED;
}

static char gstep_NSShouldRetainWithZone_n[] = "NSShouldRetainWithZone";

static SCM
gstep_NSShouldRetainWithZone(SCM i, SCM s)
{
  NSZone	*z;
  int		rval;

  SCM_ASSERT(gstep_id_p(i), i, SCM_ARG1, gstep_NSShouldRetainWithZone_n);
  SCM_ASSERT(gstep_voidp_p(s), s, SCM_ARG2, gstep_NSShouldRetainWithZone_n);
  z = (NSZone*)gstep_scm2voidp(s);
  CALL(rval = NSShouldRetainWithZone(gstep_scm2id(i), z))
  if (rval) {
      return SCM_BOOL_T;
  }
  else {
      return SCM_BOOL_F;
  }
}

static char gstep_NSZoneCalloc_n[] = "NSZoneCalloc";

static SCM
gstep_NSZoneCalloc(SCM z, SCM n, SCM s)
{
  NSZone	*zone;
  unsigned	number;
  unsigned	size;
  void	*res;
  SCM		answer;

  SCM_ASSERT(gstep_voidp_p(z), z, SCM_ARG1, gstep_NSZoneCalloc_n);
  SCM_ASSERT(gh_number_p(n), n, SCM_ARG2, gstep_NSZoneCalloc_n);
  SCM_ASSERT(gh_number_p(s), s, SCM_ARG3, gstep_NSZoneCalloc_n);

  number = gh_scm2int(n);
  size = gh_scm2int(s);
  zone = (NSZone*)gstep_scm2voidp(z);
  CALL(res = NSZoneCalloc(zone, number, size))
  if (res == 0) {
      answer = gstep_voidp2scm(0, NO, YES, 0);
  }
  else {
      answer = gstep_voidp2scm(res, NO, YES, number*size);
  }
  return answer;
}

static char gstep_NSZoneFree_n[] = "NSZoneFree";

static SCM
gstep_NSZoneFree(SCM z, SCM p)
{
  NSZone	*zone;
  void	*ptr;

  SCM_ASSERT(gstep_voidp_p(z), z, SCM_ARG1, gstep_NSZoneFree_n);
  SCM_ASSERT(gstep_voidp_p(p), p, SCM_ARG2, gstep_NSZoneFree_n);

  zone = (NSZone*)gstep_scm2voidp(z);
  ptr = gstep_scm2voidp(p);
  CALL(NSZoneFree(zone, ptr))
  return SCM_UNDEFINED;
}

static char gstep_NSZoneFromPointer_n[] = "NSZoneFromPointer";

static SCM
gstep_NSZoneFromPointer(SCM p)
{
  NSZone	*zone;
  void	*ptr;
  SCM		answer;

  SCM_ASSERT(gstep_voidp_p(p) || gstep_id_p(p), p, SCM_ARG1, gstep_NSZoneFromPointer_n);

  if (gstep_voidp_p(p)) {
      ptr = gstep_scm2voidp(p);
  }
  else {
      ptr = (void*)gstep_scm2id(p);
  }
  CALL(zone = NSZoneFromPointer(ptr))
  if (zone == 0) {
      answer = gstep_voidp2scm(0, NO, YES, 0);
  }
  else {
      answer = gstep_voidp2scm(zone, NO, YES, 0);
  }
  return answer;
}

static char gstep_NSZoneMalloc_n[] = "NSZoneMalloc";

static SCM
gstep_NSZoneMalloc(SCM z, SCM s)
{
  NSZone	*zone;
  unsigned	size;
  void	*res;
  SCM		answer;

  SCM_ASSERT(gstep_voidp_p(z), z, SCM_ARG1, gstep_NSZoneMalloc_n);
  SCM_ASSERT(gh_number_p(s), s, SCM_ARG2, gstep_NSZoneMalloc_n);

  size = gh_scm2int(s);
  zone = (NSZone*)gstep_scm2voidp(z);
  CALL(res = NSZoneMalloc(zone, size))
  if (res == 0) {
      answer = gstep_voidp2scm(0, NO, YES, 0);
  }
  else {
      answer = gstep_voidp2scm(res, NO, YES, size);
  }
  return answer;
}

static char gstep_NSZoneName_n[] = "NSZoneName";

static SCM
gstep_NSZoneName(SCM z)
{
  NSZone	*zone;
  id		obj;
  SCM		answer;

  SCM_ASSERT(gstep_voidp_p(z), z, SCM_ARG1, gstep_NSZoneName_n);

  zone = (NSZone*)gstep_scm2voidp(z);
  CALL(obj = NSZoneName(zone))
  answer = gstep_id2scm(obj, YES);
  return answer;
}

static char gstep_NSZoneRealloc_n[] = "NSZoneRealloc";

static SCM
gstep_NSZoneRealloc(SCM z, SCM p, SCM s)
{
  NSZone	*zone;
  void	*ptr;
  unsigned	size;
  void	*res;
  SCM		answer;

  SCM_ASSERT(gstep_voidp_p(z), z, SCM_ARG1, gstep_NSZoneRealloc_n);
  SCM_ASSERT(gstep_voidp_p(p), p, SCM_ARG2, gstep_NSZoneRealloc_n);
  SCM_ASSERT(gh_number_p(s), s, SCM_ARG3, gstep_NSZoneRealloc_n);

  ptr = gstep_scm2voidp(p);
  size = gh_scm2int(s);
  zone = (NSZone*)gstep_scm2voidp(z);
  CALL(res = NSZoneRealloc(zone, ptr, size))
  if (res == 0) {
      answer = gstep_voidp2scm(0, NO, YES, 0);
  }
  else {
      answer = gstep_voidp2scm(res, NO, YES, size);
  }
  return answer;
}



/*
 *	Functions dealing with NSHashTables
 */

static char gstep_NSAllHashTableObjects_n[] = "NSAllHashTableObjects";

static SCM
gstep_NSAllHashTableObjects(SCM i)
{
  NSHashTable	*t;
  id	result;

  SCM_ASSERT(gstep_voidp_p(i), i, SCM_ARG1, gstep_NSAllHashTableObjects_n);
  t = (NSHashTable*)gstep_scm2voidp(i);
  CALL(result = NSAllHashTableObjects(t))
  return gstep_id2scm(result, YES);
}

static char gstep_NSCompareHashTables_n[] = "NSCompareHashTables";

static SCM
gstep_NSCompareHashTables(SCM i0, SCM i1)
{
  NSHashTable	*t0;
  NSHashTable	*t1;
  int	result;

  SCM_ASSERT(gstep_voidp_p(i0), i0, SCM_ARG1, gstep_NSCompareHashTables_n);
  SCM_ASSERT(gstep_voidp_p(i1), i1, SCM_ARG2, gstep_NSCompareHashTables_n);
  t0 = (NSHashTable*)gstep_scm2voidp(i0);
  t1 = (NSHashTable*)gstep_scm2voidp(i1);
  CALL(result = NSCompareHashTables(t0, t1))
  return gh_long2scm(result);
}

static char gstep_NSCopyHashTableWithZone_n[] = "NSCopyHashTableWithZone";

static SCM
gstep_NSCopyHashTableWithZone(SCM i0, SCM i1)
{
  NSHashTable	*t;
  NSZone	*z;
  NSHashTable	*result;

  SCM_ASSERT(gstep_voidp_p(i0),i0, SCM_ARG1, gstep_NSCopyHashTableWithZone_n);
  SCM_ASSERT(gstep_voidp_p(i1),i1, SCM_ARG2, gstep_NSCopyHashTableWithZone_n);
  t = (NSHashTable*)gstep_scm2voidp(i0);
  z = (NSZone*)gstep_scm2voidp(i1);
  CALL(result = NSCopyHashTableWithZone(t, z))
  return gstep_voidp2scm(result, NO, YES, 0);
}

static char gstep_NSCountHashTable_n[] = "NSCountHashTable";

static SCM
gstep_NSCountHashTable(SCM i)
{
  NSHashTable	*t;
  int	result;

  SCM_ASSERT(gstep_voidp_p(i), i, SCM_ARG1, gstep_NSCountHashTable_n);
  t = (NSHashTable*)gstep_scm2voidp(i);
  CALL(result = NSCountHashTable(t))
  return gh_long2scm(result);
}

static char gstep_NSCreateHashTable_n[] = "NSCreateHashTable";

static SCM
gstep_NSCreateHashTable(SCM i0, SCM i1)
{
  NSHashTableCallBacks	*c;
  int		s;
  NSHashTable	*result;

  SCM_ASSERT(gstep_voidp_p(i0), i0, SCM_ARG1, gstep_NSCreateHashTable_n);
  SCM_ASSERT(gh_number_p(i1), i1, SCM_ARG2, gstep_NSCreateHashTable_n);
  c = (NSHashTableCallBacks*)gstep_scm2voidp(i0);
  s = gh_scm2long(i1);
  CALL(result = NSCreateHashTable(*c, s))
  return gstep_voidp2scm(result, NO, YES, 0);
}

static char gstep_NSCreateHashTableWithZone_n[] = "NSCreateHashTableWithZone";

static SCM
gstep_NSCreateHashTableWithZone(SCM i0, SCM i1, SCM i2)
{
  NSHashTableCallBacks	*c;
  int		s;
  NSZone	*z;
  NSHashTable	*result;

  SCM_ASSERT(gstep_voidp_p(i0),i0,SCM_ARG1,gstep_NSCreateHashTableWithZone_n);
  SCM_ASSERT(gh_number_p(i1), i1, SCM_ARG2,gstep_NSCreateHashTableWithZone_n);
  SCM_ASSERT(gstep_voidp_p(i2),i2,SCM_ARG3,gstep_NSCreateHashTableWithZone_n);
  c = (NSHashTableCallBacks*)gstep_scm2voidp(i0);
  s = gh_scm2long(i1);
  z = gstep_scm2voidp(i2);
  CALL(result = NSCreateHashTableWithZone(*c, s, z))
  return gstep_voidp2scm(result, NO, YES, 0);
}

static char gstep_NSEnumerateHashTable_n[] = "NSEnumerateHashTable";

static SCM
gstep_NSEnumerateHashTable(SCM i)
{
  NSHashTable	*t;
  NSHashEnumerator	*result;

  SCM_ASSERT(gstep_voidp_p(i), i, SCM_ARG1, gstep_NSEnumerateHashTable_n);
  t = (NSHashTable*)gstep_scm2voidp(i);
  result = (NSHashEnumerator*)objc_malloc(sizeof(*result));
  CALL(*result = NSEnumerateHashTable(t))
  return gstep_voidp2scm(result, YES, YES, 0);
}

static char gstep_NSFreeHashTable_n[] = "NSFreeHashTable";

static SCM
gstep_NSFreeHashTable(SCM i)
{
  NSHashTable	*t;

  SCM_ASSERT(gstep_voidp_p(i), i, SCM_ARG1, gstep_NSFreeHashTable_n);
  t = (NSHashTable*)gstep_scm2voidp(i);
  CALL(NSFreeHashTable(t))
  return SCM_UNDEFINED;
}

static char gstep_NSHashGet_n[] = "NSHashGet";

static SCM
gstep_NSHashGet(SCM i0, SCM i1)
{
  NSHashTable	*t;
  void	*p;

  SCM_ASSERT(gstep_voidp_p(i0), i0, SCM_ARG1, gstep_NSHashGet_n);
  SCM_ASSERT(gstep_voidp_p(i1), i1, SCM_ARG2, gstep_NSHashGet_n);
  t = (NSHashTable*)gstep_scm2voidp(i0);
  p = gstep_scm2voidp(i1);
  CALL(p = NSHashGet(t, p))
  return gstep_voidp2scm(p, NO, YES, 0);
}

static char gstep_NSHashInsert_n[] = "NSHashInsert";

static SCM
gstep_NSHashInsert(SCM i0, SCM i1)
{
  NSHashTable	*t;
  void	*p;

  SCM_ASSERT(gstep_voidp_p(i0), i0, SCM_ARG1, gstep_NSHashInsert_n);
  SCM_ASSERT(gstep_voidp_p(i1), i1, SCM_ARG2, gstep_NSHashInsert_n);
  t = (NSHashTable*)gstep_scm2voidp(i0);
  p = gstep_scm2voidp(i1);
  CALL(NSHashInsert(t, p))
  return SCM_UNDEFINED;
}

static char gstep_NSHashInsertIfAbsent_n[] = "NSHashInsertIfAbsent";

static SCM
gstep_NSHashInsertIfAbsent(SCM i0, SCM i1)
{
  NSHashTable	*t;
  void	*p;

  SCM_ASSERT(gstep_voidp_p(i0), i0, SCM_ARG1, gstep_NSHashInsertIfAbsent_n);
  SCM_ASSERT(gstep_voidp_p(i1), i1, SCM_ARG2, gstep_NSHashInsertIfAbsent_n);
  t = (NSHashTable*)gstep_scm2voidp(i0);
  p = gstep_scm2voidp(i1);
  CALL(NSHashInsertIfAbsent(t, p))
  return SCM_UNDEFINED;
}

static char gstep_NSHashInsertKnownAbsent_n[] = "NSHashInsertKnownAbsent";

static SCM
gstep_NSHashInsertKnownAbsent(SCM i0, SCM i1)
{
  NSHashTable	*t;
  void	*p;

  SCM_ASSERT(gstep_voidp_p(i0),i0, SCM_ARG1, gstep_NSHashInsertKnownAbsent_n);
  SCM_ASSERT(gstep_voidp_p(i1),i1, SCM_ARG2, gstep_NSHashInsertKnownAbsent_n);
  t = (NSHashTable*)gstep_scm2voidp(i0);
  p = gstep_scm2voidp(i1);
  CALL(NSHashInsertKnownAbsent(t, p))
  return SCM_UNDEFINED;
}

static char gstep_NSHashRemove_n[] = "NSHashRemove";

static SCM
gstep_NSHashRemove(SCM i0, SCM i1)
{
  NSHashTable	*t;
  void	*p;

  SCM_ASSERT(gstep_voidp_p(i0), i0, SCM_ARG1, gstep_NSHashRemove_n);
  SCM_ASSERT(gstep_voidp_p(i1), i1, SCM_ARG2, gstep_NSHashRemove_n);
  t = (NSHashTable*)gstep_scm2voidp(i0);
  p = gstep_scm2voidp(i1);
  CALL(NSHashRemove(t, p))
  return SCM_UNDEFINED;
}

static char gstep_NSNextHashEnumeratorItem_n[] = "NSNextHashEnumeratorItem";

static SCM
gstep_NSNextHashEnumeratorItem(SCM i)
{
  void	*p;

  SCM_ASSERT(gstep_voidp_p(i), i, SCM_ARG1, gstep_NSNextHashEnumeratorItem_n);
  p = gstep_scm2voidp(i);
  CALL(p = NSNextHashEnumeratorItem(p))
  return gstep_voidp2scm(p, NO, YES, 0);
}

static char gstep_NSResetHashTable_n[] = "NSResetHashTable";

static SCM
gstep_NSResetHashTable(SCM i)
{
  NSHashTable	*t;

  SCM_ASSERT(gstep_voidp_p(i), i, SCM_ARG1, gstep_NSResetHashTable_n);
  t = (NSHashTable*)gstep_scm2voidp(i);
  CALL(NSResetHashTable(t))
  return SCM_UNDEFINED;
}

static char gstep_NSStringFromHashTable_n[] = "NSStringFromHashTable";

static SCM
gstep_NSStringFromHashTable(SCM i)
{
  NSHashTable	*t;
  id	result;

  SCM_ASSERT(gstep_voidp_p(i), i, SCM_ARG1, gstep_NSStringFromHashTable_n);
  t = (NSHashTable*)gstep_scm2voidp(i);
  CALL(result = NSStringFromHashTable(t))
  return gstep_id2scm(result, YES);
}



/*
 *	Functions dealing with NSMapTables
 */

static char gstep_NSAllMapTableKeys_n[] = "NSAllMapTableKeys";

static SCM
gstep_NSAllMapTableKeys(SCM i)
{
  NSMapTable	*t;
  id	result;

  SCM_ASSERT(gstep_voidp_p(i), i, SCM_ARG1, gstep_NSAllMapTableKeys_n);
  t = (NSMapTable*)gstep_scm2voidp(i);
  CALL(result = NSAllMapTableKeys(t))
  return gstep_id2scm(result, YES);
}

static char gstep_NSAllMapTableValues_n[] = "NSAllMapTableValues";

static SCM
gstep_NSAllMapTableValues(SCM i)
{
  NSMapTable	*t;
  id	result;

  SCM_ASSERT(gstep_voidp_p(i), i, SCM_ARG1, gstep_NSAllMapTableValues_n);
  t = (NSMapTable*)gstep_scm2voidp(i);
  CALL(result = NSAllMapTableValues(t))
  return gstep_id2scm(result, YES);
}

static char gstep_NSCompareMapTables_n[] = "NSCompareMapTables";

static SCM
gstep_NSCompareMapTables(SCM i0, SCM i1)
{
  NSMapTable	*t0;
  NSMapTable	*t1;
  int	result;

  SCM_ASSERT(gstep_voidp_p(i0), i0, SCM_ARG1, gstep_NSCompareMapTables_n);
  SCM_ASSERT(gstep_voidp_p(i1), i1, SCM_ARG2, gstep_NSCompareMapTables_n);
  t0 = (NSMapTable*)gstep_scm2voidp(i0);
  t1 = (NSMapTable*)gstep_scm2voidp(i1);
  CALL(result = NSCompareMapTables(t0, t1))
  return gh_long2scm(result);
}

static char gstep_NSCopyMapTableWithZone_n[] = "NSCopyMapTableWithZone";

static SCM
gstep_NSCopyMapTableWithZone(SCM i0, SCM i1)
{
  NSMapTable	*t;
  NSZone	*z;
  NSMapTable	*result;

  SCM_ASSERT(gstep_voidp_p(i0),i0, SCM_ARG1, gstep_NSCopyMapTableWithZone_n);
  SCM_ASSERT(gstep_voidp_p(i1),i1, SCM_ARG2, gstep_NSCopyMapTableWithZone_n);
  t = (NSMapTable*)gstep_scm2voidp(i0);
  z = (NSZone*)gstep_scm2voidp(i1);
  CALL(result = NSCopyMapTableWithZone(t, z))
  return gstep_voidp2scm(result, NO, YES, 0);
}

static char gstep_NSCountMapTable_n[] = "NSCountMapTable";

static SCM
gstep_NSCountMapTable(SCM i)
{
  NSMapTable	*t;
  int	result;

  SCM_ASSERT(gstep_voidp_p(i), i, SCM_ARG1, gstep_NSCountMapTable_n);
  t = (NSMapTable*)gstep_scm2voidp(i);
  CALL(result = NSCountMapTable(t))
  return gh_long2scm(result);
}

static char gstep_NSCreateMapTable_n[] = "NSCreateMapTable";

static SCM
gstep_NSCreateMapTable(SCM i0, SCM i1, SCM i2)
{
  NSMapTableKeyCallBacks	*k;
  NSMapTableValueCallBacks	*v;
  int		s;
  NSMapTable	*result;

  SCM_ASSERT(gstep_voidp_p(i0), i0, SCM_ARG1, gstep_NSCreateMapTable_n);
  SCM_ASSERT(gstep_voidp_p(i1), i1, SCM_ARG2, gstep_NSCreateMapTable_n);
  SCM_ASSERT(gh_number_p(i1), i1, SCM_ARG3, gstep_NSCreateMapTable_n);
  k = (NSMapTableKeyCallBacks*)gstep_scm2voidp(i0);
  v = (NSMapTableValueCallBacks*)gstep_scm2voidp(i1);
  s = gh_scm2long(i2);
  CALL(result = NSCreateMapTable(*k, *v, s))
  return gstep_voidp2scm(result, NO, YES, 0);
}

static char gstep_NSCreateMapTableWithZone_n[] = "NSCreateMapTableWithZone";

static SCM
gstep_NSCreateMapTableWithZone(SCM i0, SCM i1, SCM i2, SCM i3)
{
  NSMapTableKeyCallBacks	*k;
  NSMapTableValueCallBacks	*v;
  int		s;
  NSZone	*z;
  NSMapTable	*result;

  SCM_ASSERT(gstep_voidp_p(i0),i0,SCM_ARG1,gstep_NSCreateMapTableWithZone_n);
  SCM_ASSERT(gstep_voidp_p(i1),i1,SCM_ARG2,gstep_NSCreateMapTableWithZone_n);
  SCM_ASSERT(gh_number_p(i2), i2, SCM_ARG3,gstep_NSCreateMapTableWithZone_n);
  SCM_ASSERT(gstep_voidp_p(i3),i3,SCM_ARG4,gstep_NSCreateMapTableWithZone_n);
  k = (NSMapTableKeyCallBacks*)gstep_scm2voidp(i0);
  v = (NSMapTableValueCallBacks*)gstep_scm2voidp(i1);
  s = gh_scm2long(i2);
  z = gstep_scm2voidp(i3);
  CALL(result = NSCreateMapTableWithZone(*k, *v, s, z))
  return gstep_voidp2scm(result, NO, YES, 0);
}

static char gstep_NSEnumerateMapTable_n[] = "NSEnumerateMapTable";

static SCM
gstep_NSEnumerateMapTable(SCM i)
{
  NSMapTable	*t;
  NSMapEnumerator	*result;

  SCM_ASSERT(gstep_voidp_p(i), i, SCM_ARG1, gstep_NSEnumerateMapTable_n);
  t = (NSMapTable*)gstep_scm2voidp(i);
  result = (NSMapEnumerator*)objc_malloc(sizeof(*result));
  CALL(*result = NSEnumerateMapTable(t))
  return gstep_voidp2scm(result, YES, YES, 0);
}

static char gstep_NSFreeMapTable_n[] = "NSFreeMapTable";

static SCM
gstep_NSFreeMapTable(SCM i)
{
  NSMapTable	*t;

  SCM_ASSERT(gstep_voidp_p(i), i, SCM_ARG1, gstep_NSFreeMapTable_n);
  t = (NSMapTable*)gstep_scm2voidp(i);
  CALL(NSFreeMapTable(t))
  return SCM_UNDEFINED;
}

static char gstep_NSMapGet_n[] = "NSMapGet";

static SCM
gstep_NSMapGet(SCM i0, SCM i1)
{
  NSMapTable	*t;
  void	*p;

  SCM_ASSERT(gstep_voidp_p(i0), i0, SCM_ARG1, gstep_NSMapGet_n);
  SCM_ASSERT(gstep_voidp_p(i1), i1, SCM_ARG2, gstep_NSMapGet_n);
  t = (NSMapTable*)gstep_scm2voidp(i0);
  p = gstep_scm2voidp(i1);
  CALL(p = NSMapGet(t, p))
  return gstep_voidp2scm(p, NO, YES, 0);
}

static char gstep_NSMapInsert_n[] = "NSMapInsert";

static SCM
gstep_NSMapInsert(SCM i0, SCM i1, SCM i2)
{
  NSMapTable	*t;
  void	*k;
  void	*v;

  SCM_ASSERT(gstep_voidp_p(i0), i0, SCM_ARG1, gstep_NSMapInsert_n);
  SCM_ASSERT(gstep_voidp_p(i1), i1, SCM_ARG2, gstep_NSMapInsert_n);
  SCM_ASSERT(gstep_voidp_p(i2), i2, SCM_ARG3, gstep_NSMapInsert_n);
  t = (NSMapTable*)gstep_scm2voidp(i0);
  k = gstep_scm2voidp(i1);
  v = gstep_scm2voidp(i2);
  CALL(NSMapInsert(t, k, v))
  return SCM_UNDEFINED;
}

static char gstep_NSMapInsertIfAbsent_n[] = "NSMapInsertIfAbsent";

static SCM
gstep_NSMapInsertIfAbsent(SCM i0, SCM i1, SCM i2)
{
  NSMapTable	*t;
  void	*k;
  void	*v;

  SCM_ASSERT(gstep_voidp_p(i0), i0, SCM_ARG1, gstep_NSMapInsertIfAbsent_n);
  SCM_ASSERT(gstep_voidp_p(i1), i1, SCM_ARG2, gstep_NSMapInsertIfAbsent_n);
  SCM_ASSERT(gstep_voidp_p(i2), i2, SCM_ARG3, gstep_NSMapInsertIfAbsent_n);
  t = (NSMapTable*)gstep_scm2voidp(i0);
  k = gstep_scm2voidp(i1);
  v = gstep_scm2voidp(i2);
  CALL(NSMapInsertIfAbsent(t, k, v))
  return SCM_UNDEFINED;
}

static char gstep_NSMapInsertKnownAbsent_n[] = "NSMapInsertKnownAbsent";

static SCM
gstep_NSMapInsertKnownAbsent(SCM i0, SCM i1, SCM i2)
{
  NSMapTable	*t;
  void	*k;
  void	*v;

  SCM_ASSERT(gstep_voidp_p(i0),i0, SCM_ARG1, gstep_NSMapInsertKnownAbsent_n);
  SCM_ASSERT(gstep_voidp_p(i1),i1, SCM_ARG2, gstep_NSMapInsertKnownAbsent_n);
  SCM_ASSERT(gstep_voidp_p(i2),i2, SCM_ARG3, gstep_NSMapInsertKnownAbsent_n);
  t = (NSMapTable*)gstep_scm2voidp(i0);
  k = gstep_scm2voidp(i1);
  v = gstep_scm2voidp(i2);
  CALL(NSMapInsertKnownAbsent(t, k, v))
  return SCM_UNDEFINED;
}

static char gstep_NSMapMember_n[] = "NSMapMember";

static SCM
gstep_NSMapMember(SCM i0, SCM i1, SCM i2, SCM i3)
{
  NSMapTable	*t;
  void	*k;
  void	*ok;
  void	*ov;
  int		result;

  SCM_ASSERT(gstep_voidp_p(i0), i0, SCM_ARG1, gstep_NSMapMember_n);
  SCM_ASSERT(gstep_voidp_p(i1), i1, SCM_ARG2, gstep_NSMapMember_n);
  SCM_ASSERT(gstep_voidp_p(i2), i2, SCM_ARG3, gstep_NSMapMember_n);
  SCM_ASSERT(gstep_voidp_p(i3), i3, SCM_ARG4, gstep_NSMapMember_n);
  t = (NSMapTable*)gstep_scm2voidp(i0);
  k = gstep_scm2voidp(i1);
  CALL(result = NSMapMember(t, k, &ok, &ov))
  if (result == YES) {
      gstep_voidp_set(i2, ok, NO, YES, 0);
      gstep_voidp_set(i3, ov, NO, YES, 0);
  }
  return gh_scm2long(result);
}

static char gstep_NSMapRemove_n[] = "NSMapRemove";

static SCM
gstep_NSMapRemove(SCM i0, SCM i1)
{
  NSMapTable	*t;
  void	*p;

  SCM_ASSERT(gstep_voidp_p(i0), i0, SCM_ARG1, gstep_NSMapRemove_n);
  SCM_ASSERT(gstep_voidp_p(i1), i1, SCM_ARG2, gstep_NSMapRemove_n);
  t = (NSMapTable*)gstep_scm2voidp(i0);
  p = gstep_scm2voidp(i1);
  CALL(NSMapRemove(t, p))
  return SCM_UNDEFINED;
}

static char gstep_NSNextMapEnumeratorPair_n[] = "NSNextMapEnumeratorPair";

static SCM
gstep_NSNextMapEnumeratorPair(SCM i0, SCM i1, SCM i2)
{
  void	*p;
  void	*k;
  void	*v;
  int		result;

  SCM_ASSERT(gstep_voidp_p(i0),i0, SCM_ARG1, gstep_NSNextMapEnumeratorPair_n);
  SCM_ASSERT(gstep_voidp_p(i1),i1, SCM_ARG2, gstep_NSNextMapEnumeratorPair_n);
  SCM_ASSERT(gstep_voidp_p(i2),i2, SCM_ARG3, gstep_NSNextMapEnumeratorPair_n);
  p = gstep_scm2voidp(i0);
  CALL(result = NSNextMapEnumeratorPair(p, &k, &v))
  if (result == YES) {
      gstep_voidp_set(i1, k, NO, YES, 0);
      gstep_voidp_set(i2, v, NO, YES, 0);
  }
  return gh_scm2long(result);
}

static char gstep_NSResetMapTable_n[] = "NSResetMapTable";

static SCM
gstep_NSResetMapTable(SCM i)
{
  NSMapTable	*t;

  SCM_ASSERT(gstep_voidp_p(i), i, SCM_ARG1, gstep_NSResetMapTable_n);
  t = (NSMapTable*)gstep_scm2voidp(i);
  CALL(NSResetMapTable(t))
  return SCM_UNDEFINED;
}

static char gstep_NSStringFromMapTable_n[] = "NSStringFromMapTable";

static SCM
gstep_NSStringFromMapTable(SCM i)
{
  NSMapTable	*t;
  id	result;

  SCM_ASSERT(gstep_voidp_p(i), i, SCM_ARG1, gstep_NSStringFromMapTable_n);
  t = (NSMapTable*)gstep_scm2voidp(i);
  CALL(result = NSStringFromMapTable(t))
  return gstep_id2scm(result, YES);
}



/*
 *	Now define functions from the base library.
 */
static void
gstep_base_functions()
{
  CFUN(gstep_NSCreateZone_n, 3, 0, 0, gstep_NSCreateZone);
  CFUN(gstep_NSDefaultMallocZone_n, 0, 0, 0, gstep_NSDefaultMallocZone);
  CFUN(gstep_NSRecycleZone_n, 1, 0, 0, gstep_NSRecycleZone);
  CFUN(gstep_NSSetZoneName_n, 2, 0, 0, gstep_NSSetZoneName);
  CFUN(gstep_NSShouldRetainWithZone_n, 2, 0, 0, gstep_NSShouldRetainWithZone);
  CFUN(gstep_NSZoneCalloc_n, 3, 0, 0, gstep_NSZoneCalloc);
  CFUN(gstep_NSZoneFree_n, 2, 0, 0, gstep_NSZoneFree);
  CFUN(gstep_NSZoneFromPointer_n, 1, 0, 0, gstep_NSZoneFromPointer);
  CFUN(gstep_NSZoneMalloc_n, 2, 0, 0, gstep_NSZoneMalloc);
  CFUN(gstep_NSZoneName_n, 1, 0, 0, gstep_NSZoneName);
  CFUN(gstep_NSZoneRealloc_n, 3, 0, 0, gstep_NSZoneRealloc);


  CFUN(gstep_NSAllHashTableObjects_n, 1, 0, 0, gstep_NSAllHashTableObjects);
  CFUN(gstep_NSCompareHashTables_n, 2, 0, 0, gstep_NSCompareHashTables);
  CFUN(gstep_NSCopyHashTableWithZone_n, 2, 0, 0, gstep_NSCopyHashTableWithZone);
  CFUN(gstep_NSCountHashTable_n, 1, 0, 0, gstep_NSCountHashTable);
  CFUN(gstep_NSCreateHashTable_n, 2, 0, 0, gstep_NSCreateHashTable);
  CFUN(gstep_NSCreateHashTableWithZone_n, 3, 0, 0, gstep_NSCreateHashTableWithZone);
  CFUN(gstep_NSEnumerateHashTable_n, 1, 0, 0, gstep_NSEnumerateHashTable);
  CFUN(gstep_NSFreeHashTable_n, 1, 0, 0, gstep_NSFreeHashTable);
  CFUN(gstep_NSHashGet_n, 2, 0, 0, gstep_NSHashGet);
  CFUN(gstep_NSHashInsert_n, 2, 0, 0, gstep_NSHashInsert);
  CFUN(gstep_NSHashInsertIfAbsent_n, 2, 0, 0, gstep_NSHashInsertIfAbsent);
  CFUN(gstep_NSHashInsertKnownAbsent_n, 2, 0, 0, gstep_NSHashInsertKnownAbsent);
  CFUN(gstep_NSHashRemove_n, 2, 0, 0, gstep_NSHashRemove);
  CFUN(gstep_NSNextHashEnumeratorItem_n, 1, 0, 0, gstep_NSNextHashEnumeratorItem);
  CFUN(gstep_NSResetHashTable_n, 1, 0, 0, gstep_NSResetHashTable);
  CFUN(gstep_NSStringFromHashTable_n, 1, 0, 0, gstep_NSStringFromHashTable);


  CFUN(gstep_NSAllMapTableKeys_n, 1, 0, 0, gstep_NSAllMapTableKeys);
  CFUN(gstep_NSAllMapTableValues_n, 1, 0, 0, gstep_NSAllMapTableValues);
  CFUN(gstep_NSCompareMapTables_n, 2, 0, 0, gstep_NSCompareMapTables);
  CFUN(gstep_NSCopyMapTableWithZone_n, 2, 0, 0, gstep_NSCopyMapTableWithZone);
  CFUN(gstep_NSCountMapTable_n, 1, 0, 0, gstep_NSCountMapTable);
  CFUN(gstep_NSCreateMapTable_n, 3, 0, 0, gstep_NSCreateMapTable);
  CFUN(gstep_NSCreateMapTableWithZone_n, 4, 0, 0, gstep_NSCreateMapTableWithZone);
  CFUN(gstep_NSEnumerateMapTable_n, 1, 0, 0, gstep_NSEnumerateMapTable);
  CFUN(gstep_NSFreeMapTable_n, 1, 0, 0, gstep_NSFreeMapTable);
  CFUN(gstep_NSMapGet_n, 2, 0, 0, gstep_NSMapGet);
  CFUN(gstep_NSMapInsert_n, 3, 0, 0, gstep_NSMapInsert);
  CFUN(gstep_NSMapInsertIfAbsent_n, 3, 0, 0, gstep_NSMapInsertIfAbsent);
  CFUN(gstep_NSMapInsertKnownAbsent_n, 3, 0, 0, gstep_NSMapInsertKnownAbsent);
  CFUN(gstep_NSMapMember_n, 4, 0, 0, gstep_NSMapMember);
  CFUN(gstep_NSMapRemove_n, 2, 0, 0, gstep_NSMapRemove);
  CFUN(gstep_NSNextMapEnumeratorPair_n, 3, 0, 0, gstep_NSNextMapEnumeratorPair);
  CFUN(gstep_NSResetMapTable_n, 1, 0, 0, gstep_NSResetMapTable);
  CFUN(gstep_NSStringFromMapTable_n, 1, 0, 0, gstep_NSStringFromMapTable);
}



/*
 *	Ensure we have ALL the public classes of the foundation library
 *	linked in with us and available as guile variables.
 *	Make sure that there is an autorelease pool around to catch any
 *	temporary objects created in any class [+initialize] methods.
 */
static void
gstep_base_classes()
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];

  CCLS(NSArchiver);
  CCLS(NSArray);
  CCLS(NSAssertionHandler);
  CCLS(NSBundle);
  CCLS(NSCalendarDate);
  CCLS(NSCharacterSet);
  CCLS(NSCoder);
  CCLS(NSConditionLock);
  CCLS(NSCountedSet);
  CCLS(NSData);
  CCLS(NSDate);
  CCLS(NSDictionary);
  CCLS(NSDirectoryEnumerator);
  CCLS(NSDistributedLock);
  CCLS(NSEnumerator);
  CCLS(NSException);
  CCLS(NSFileHandle);
  CCLS(NSFileManager);
  CCLS(NSHost);
  CCLS(NSInvocation);
  CCLS(NSLock);
  CCLS(NSMethodSignature);
  CCLS(NSMutableArray);
  CCLS(NSMutableCharacterSet);
  CCLS(NSMutableData);
  CCLS(NSMutableDictionary);
  CCLS(NSMutableSet);
  CCLS(NSMutableString);
  CCLS(NSNotification);
  CCLS(NSNotificationCenter);
  CCLS(NSNotificationQueue);
  CCLS(NSNumber);
  CCLS(NSNull);
  CCLS(NSObject);
  CCLS(NSPipe);
  CCLS(NSProcessInfo);
  CCLS(NSRecursiveLock);
  CCLS(NSRunLoop);
  CCLS(NSScanner);
  CCLS(NSSet);
  CCLS(NSString);
  CCLS(NSTask);
  CCLS(NSThread);
  CCLS(NSTimeZone);
  CCLS(NSTimeZoneDetail);
  CCLS(NSTimer);
  CCLS(NSUnarchiver);
  CCLS(NSUserDefaults);
  CCLS(NSValue);
/*
*	Class differences with libFoundation
*/
#if	defined(LIB_FOUNDATION_LIBRARY)
  CCLS(NSZone);
#else
  CCLS(NSAttributedString);
  CCLS(NSConnection);
  CCLS(NSDeserializer);
  CCLS(NSDistantObject);
  CCLS(NSMutableAttributedString);
  CCLS(NSPort);
  CCLS(NSPortCoder);
  CCLS(NSProxy);
  CCLS(NSSerializer);
#endif
  [arp release];
}



void
gstep_link_base()
{
  static BOOL	beenHere = NO;

  if (beenHere == NO)
    {
#ifdef  HAVE_SCM_C_RESOLVE_MODULE
      SCM module = scm_c_resolve_module ("languages gstep-guile");
#endif

      beenHere = YES;
#ifdef  HAVE_SCM_C_RESOLVE_MODULE
      module = scm_set_current_module (module);
#endif
      gstep_init();
      gstep_base_numeric_constants();
      gstep_base_string_constants();
      gstep_base_functions();
      gstep_base_classes();
#ifdef  HAVE_SCM_C_RESOLVE_MODULE
      module = scm_set_current_module (module);
#endif
    }
}

