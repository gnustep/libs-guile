/* link_gui.m - Ensure gui library stuff is available.
   Copyright (C) 1998 Free Software Foundation, Inc.

   Written by:  Richard Frith-Macdonald <richard@brainstorm.co.uk>
   Date: July 1998

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

#include "../config.h"

#if	HAVE_APPKIT_APPKIT_H

#include "gstep_guile.h"

#include	<Foundation/Foundation.h>
#include	<AppKit/AppKit.h>



static void
gstep_gui_numeric_constants()
{
#define	CNUM(X) gh_define(#X, gh_long2scm(X))

}



static void
gstep_gui_string_constants()
{
#define	CSTR(X) gh_define(#X, gstep_id2scm(X, NO))

}



/*
 *	gstep_gui functions
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
 *	Now define functions from the gui library.
 */
static void
gstep_gui_functions()
{
}



/*
 *	Ensure we have ALL the public classes of the foundation library
 *	linked in with us and available as guile variables.
 *	Make sure that there is an autorelease pool around to catch any
 *	temporary objects created in any class [+initialize] methods.
 */
static void
gstep_gui_classes()
{
    NSAutoreleasePool	*arp = [NSAutoreleasePool new];
#define	CCLS(X) gh_define(#X, gstep_id2scm([X class], NO))

    CCLS(NSActionCell);
    CCLS(NSApplication);
    CCLS(NSBitmapImageRep);
    CCLS(NSBox);
    CCLS(NSBrowser);
    CCLS(NSBrowserCell);
    CCLS(NSBundle);
    CCLS(NSButton);
    CCLS(NSButtonCell);
    CCLS(NSCStringText);
    CCLS(NSCachedImageRep);
    CCLS(NSCell);
    CCLS(NSClipView);
    CCLS(NSCoder);
    CCLS(NSColor);
    CCLS(NSColorList);
    CCLS(NSColorPanel);
    CCLS(NSColorPicker);
    CCLS(NSColorWell);
    CCLS(NSControl);
    CCLS(NSCursor);
    CCLS(NSCustomImageRep);
    CCLS(NSDataLink);
    CCLS(NSDataLinkManager);
    CCLS(NSDataLinkPanel);
    CCLS(NSEPSImageRep);
    CCLS(NSEvent);
    CCLS(NSFont);
    CCLS(NSFontManager);
    CCLS(NSFontPanel);
    CCLS(NSForm);
    CCLS(NSFormCell);
    CCLS(NSHelpPanel);
    CCLS(NSImage);
    CCLS(NSImageRep);
    CCLS(NSImageView);
    CCLS(NSMatrix);
    CCLS(NSMenu);
    CCLS(NSMenuItem);
    CCLS(NSOpenPanel);
    CCLS(NSPageLayout);
    CCLS(NSPanel);
    CCLS(NSPasteboard);
    CCLS(NSPopUpButton);
    CCLS(NSPrintInfo);
    CCLS(NSPrintOperation);
    CCLS(NSPrintPanel);
    CCLS(NSPrinter);
    CCLS(NSResponder);
    CCLS(NSSavePanel);
    CCLS(NSScreen);
    CCLS(NSScrollView);
    CCLS(NSScroller);
    CCLS(NSSelection);
    CCLS(NSSlider);
    CCLS(NSSliderCell);
    CCLS(NSSpellChecker);
    CCLS(NSSpellServer);
    CCLS(NSSplitView);
    CCLS(NSText);
    CCLS(NSTextField);
    CCLS(NSTextFieldCell);
    CCLS(NSTextView);
    CCLS(NSView);
    CCLS(NSWindow);
    CCLS(NSWorkspace);
    [arp release];
}



void
gstep_link_gui()
{
    gstep_gui_numeric_constants();
    gstep_gui_string_constants();
    gstep_gui_functions();
    gstep_gui_classes();
}

#else
void
gstep_link_gui()
{
}
#endif

