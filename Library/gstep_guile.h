/* gstep_guile.h - interface between guile and GNUstep
   Copyright (C) 1998 Free Software Foundation, Inc.

   Written by:  Richard Frith-Macdonald <richard@brainstorm.co.uk>
   Date: April 1998

   Heavily based on guileobjc
   	Written by:  R. Andrew McCallum <mccallum@gnu.ai.mit.edu>
   	Date: April 1995

        Including modifications by
		Masatake YAMATO (masata-y@is.aist-nara.ac.jp)

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


#ifndef __gstep_guile_h_INCLUDE
#define __gstep_guile_h_INCLUDE 

#include <Foundation/NSObject.h>
#include <Foundation/NSString.h>

/*
 *	In the declaration of `scm_setuid@guile-1.[0-2]/libguile/posix.h'
 *	`id' is used.  This is an objc key word, so to avoid a syntax error,
 *	there are `define' and `undef' instructions around the next `include'
 *	instruction.
 */
#define id id0 
# include <guile/gh.h>
#undef id
#define id id

/*
 *	Initialize the GUILE/Objective-C interface.
 */
extern void gstep_init();

extern void gstep_link_base();	/* Use Foundation stuff.	*/
extern void gstep_link_gui();	/* Use AppKit stuff.		*/



/*
 *	Make new SCM for id
 *	If there is already a SCM for this id, return that one rather than
 *	creating a new one - thus ensuring that there is only one SCM for
 *	each objc object.
 *	If the 'shouldRetain' flag is false - this method assumes that the
 *	object has already been retained and does not need to be retained
 *	for use within Guile.
 */
extern SCM gstep_id2scm(id o, BOOL shouldRetain);

/*
 *	Convert id object to nil without releasing the original.
 */
extern void gstep_fixup_id(SCM o);

/*
 *	Get the id from a SCM
 */
extern id gstep_scm2id(SCM o);

/*
 *	Test whether a scheme object is an objective-c object.
 */
extern SCM gstep_scm_id_p(SCM o);
extern int gstep_id_p(SCM o);



/*
 *	Make new SCM for voidp
 *	If 'malloced' is true - the memory pointed to will be freed when the
 *	scheme object is garbage collected.
 *	If 'lenKnown' is true - 'len' is recorded and the system can do some
 *	range checking when transferring data to/from the voidp.
 */
extern SCM gstep_voidp2scm(void *ptr, BOOL malloced, BOOL lenKnown, int len);

/*
 *	Like gstep_voidp2scm(), but modifies an existing item.
 */
extern void gstep_voidp_set(SCM old, void *ptr, BOOL m, BOOL lenKnown, int len);

/*
 *	Get the void pointer from a SCM
 */
extern void *gstep_scm2voidp(SCM o);
extern int gstep_scm2voidplength(SCM o);

/*
 *	Test whether a scheme object is a pointer to abstract memory.
 */
extern SCM gstep_scm_voidp_p(SCM o);
extern int gstep_voidp_p(SCM o);



/*
 *	'gstep_id_smob' is a table containing print, mark, free, and
 *	equal functions.
 *	Guile uses these functions to handle an objc id.
 */
extern struct scm_smobfuns gstep_id_smob; 

/*
 *	'gstep_scm_tc16_id' is a key used to select `gstep_id_smob' in
 *	the smob tables.
 *
 *	Each scm object which contains an objc id in its CDR slot,
 *	contains this integer value in its CAR slot.
 */
extern int gstep_scm_tc16_id;

/*
 *	Similar methods information for 'class' and 'voipd' items.
 */
extern struct scm_smobfuns gstep_class_smob; 
extern int gstep_scm_tc16_class;
extern struct scm_smobfuns gstep_voidp_smob; 
extern int gstep_scm_tc16_voidp;



/*
 *	The [-printForGuile:]  method is responsible for what goes in
 *	the #<...> when Scheme prints the object.
 *	The default implementation for NSObject uses [-description] to obtain
 *	text to print, while the default for Object prints nothing.
 */
@interface NSObject (GNUstepGuile)
- (void) printForGuile: (SCM)port;
@end

/*
 *	Give value to the next pointer to a function, and you can replace
 *	the default print method for Object and NSObject with your own function.
 *	NB. Your function needs to be able to work where 'obj' is derived from
 *	Object or NSObject.
 */
extern void (*print_for_guile)(id obj, SEL sel, SCM port);

#endif /* __gstep_guile_h_INCLUDE */
