/* link_gui.m - Ensure gdl2 library stuff is available.
   Copyright (C) 2003 Free Software Foundation, Inc.

   Written by:  David Ayers <d.ayers@inode.at>
   Based on link_gui by: Richard Frith-Macdonald <richard@brainstorm.co.uk>
   Date: Janurary 2003

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

#include "private.h"

#include	<Foundation/Foundation.h>

#if	HAVE_EOACCESS_EOACCESS_H
#include	<EOAccess/EOAccess.h>
#endif
#if	HAVE_EOCONTROL_EOCONTROL_H
#include	<EOControl/EOControl.h>
#endif
#if	HAVE_EOINTERFACE_EOINTERFACE_H
#include	<EOInterface/EOInterface.h>
#endif



static void
gstep_gdl2_numeric_constants()
{
#if	HAVE_EOCONTROL_EOCONTROL_H
  CNUM(EOObserverNumberOfPriorities);
#endif

}



static void
gstep_gdl2_string_constants()
{
}



static void
gstep_gdl2_selector_constants()
{
  NSAutoreleasePool *arp;
  arp = [NSAutoreleasePool new];

#if	HAVE_EOCONTROL_EOCONTROL_H
  CSEL(EOQualifierOperatorEqual);
  CSEL(EOQualifierOperatorNotEqual);
  CSEL(EOQualifierOperatorLessThan);
  CSEL(EOQualifierOperatorGreaterThan);
  CSEL(EOQualifierOperatorLessThanOrEqualTo);
  CSEL(EOQualifierOperatorGreaterThanOrEqualTo);
  CSEL(EOQualifierOperatorContains);
  CSEL(EOQualifierOperatorLike);
  CSEL(EOQualifierOperatorCaseInsensitiveLike);

  CSEL(EOCompareAscending);
  CSEL(EOCompareDescending);
  CSEL(EOCompareCaseInsensitiveAscending);
  CSEL(EOCompareCaseInsensitiveDescending);
#endif

  [arp release];
}



/*
 *	gstep_gdl2 functions
 */

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
 *	Now define functions from the gdl2 library.
 */
static void
gstep_gdl2_functions()
{
}



/*
 *	Ensure we have ALL the public classes of the foundation library
 *	linked in with us and available as guile variables.
 *	Make sure that there is an autorelease pool around to catch any
 *	temporary objects created in any class [+initialize] methods.
 */
static void
gstep_gdl2_classes()
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];

  /*EOAccess*/
#if	HAVE_EOACCESS_EOACCESS_H
  CCLS(EOAdaptor);
  CCLS(EOAdaptorChannel);
  CCLS(EOAdaptorContext);
  CCLS(EOAdaptorOperation);
  CCLS(EOAttribute);
  CCLS(EODatabase);
  CCLS(EODatabaseChannel);
  CCLS(EODatabaseContext);
  CCLS(EODatabaseDataSource);
  CCLS(EODatabaseOperation);
  CCLS(EOEntity);
  CCLS(EOJoin);
  CCLS(EOModel);
  CCLS(EOModelGroup);
  CCLS(EORelationship);
  CCLS(EOStoredProcedure);
  CCLS(EOSQLExpression);
  CCLS(EOSQLQualifier);

#endif

#if	HAVE_EOCONTROL_EOCONTROL_H
  /*EOControl*/
  CCLS(EOSortOrdering);
  CCLS(EOFetchSpecification);
  CCLS(EOGenericRecord);
  CCLS(EOClassDescription);
  CCLS(EOQualifier);
  CCLS(EOKeyValueQualifier);
  CCLS(EOKeyComparisonQualifier);
  CCLS(EOAndQualifier);
  CCLS(EOOrQualifier);
  CCLS(EONotQualifier);
  CCLS(EONull);
  CCLS(EOKeyValueArchiver);
  CCLS(EOKeyValueUnarchiver);
  CCLS(EOGlobalID);
  CCLS(EOKeyGlobalID);
  CCLS(EOUndoManager);
  CCLS(EOObjectStore);
  CCLS(EOCooperatingObjectStore);
  CCLS(EOObjectStoreCoordinator);
  CCLS(EOFault);
  CCLS(EOEditingContext);
  CCLS(EODataSource);
  CCLS(EODetailDataSource);
  CCLS(EOObserverCenter);
  CCLS(EODelayedObserver);
  CCLS(EODelayedObserverQueue);
  CCLS(EOObserverProxy);

#endif

  [arp release];
}



void
gstep_link_gdl2()
{
  static BOOL beenHere = NO;

  if (beenHere == NO)
    {
#ifdef  HAVE_SCM_C_RESOLVE_MODULE
      SCM module = scm_c_resolve_module ("languages gstep-guile");
#endif

      beenHere = YES;
#ifdef  HAVE_SCM_C_RESOLVE_MODULE
      module = scm_set_current_module (module);
#endif
      gstep_link_base();
      gstep_gdl2_numeric_constants();
      gstep_gdl2_string_constants();
      gstep_gdl2_selector_constants();
      gstep_gdl2_functions();
      gstep_gdl2_classes();

      scm_add_feature("link_gdl2");

#ifdef  HAVE_SCM_C_RESOLVE_MODULE
      module = scm_set_current_module (module);
#endif
    }
}


