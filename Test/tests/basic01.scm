
;   basic01.scm - Tests for use of pointers in gstep-guile
;   Copyright (C) 1998 Free SoftwareFoundation, Inc.
;
;   Written by:  Richard Frith-Macdonald <richard@brainstorm.co.uk>
;   Date: May 1998
;
;   This file is part of the GNUstep project.
;
;   This library is free software; you can redistribute it and/or
;   modify it under the terms of the GNU Library General Public
;   License as published by the Free Software Foundation; either
;   version 2 of the License, or (at your option) any later version.
;   
;   This library is distributed in the hope that it will be useful,
;   but WITHOUT ANY WARRANTY; without even the implied warranty of
;   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;   Library General Public License for more details.
;
;   You should have received a copy of the GNU Library General Public
;   License along with this library; if not, write to the Free
;   Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.



;
;  Define some variables to bhe used to pass information between testcases.
;
  (define d0 #f)
  (define l0 #f)
  (define l1 #f)
  (define s0 #f)
  (define s1 #f)
  (define v0 #f)
  (define v1 #f)

;
;  Now we have the testcases for the basic functionality of 'voidp'
;

(greg-testcase "Creation of a voidp from a Guile string is OK" #t
(lambda ()
  (set! s0 "This is a test string")
  (set! v0 (string->voidp s0))
  (voidp? v0)
))

(greg-testcase "A voidp created from a Guile string has a length" #t
(lambda ()
  (voidp-length? v0);
))

(greg-testcase "A voidp created from a Guile string was by malloc" #t
(lambda ()
  (voidp-malloc? v0);
))

(greg-testcase "A voidp created from a Guile string has it's length" #t
(lambda ()
  (eq? (voidp-length v0) (string-length s0))
))

(greg-testcase "Creation of a Guile string from a voidp is OK" #t
(lambda ()
  (set! s1 (voidp->string v0 0 (voidp-length v0)))
  (string? s1)
))

(greg-testcase "string => voidp => string gives identical string" #t
(lambda ()
  (string=? s0 s1)
))

(greg-testcase "We can do a partial overwrite of a voidp" #t
(lambda ()
  (voidp-set! v0 10 "TEST")
  (set! s1 (voidp->string v0 0 (voidp-length v0)))
  (string=? s1 "This is a TEST string")
))

(greg-testcase "We can extract a substring from a voidp" #t
(lambda ()
  (set! s1 (voidp->string v0 10 4))
  (string=? s1 "TEST")
))

(greg-testcase "Creation of a voidp from a Guile list is OK" #t
(lambda ()
  (set! v0 (list->voidp '(65 66 67 68 69) "c"))
  (voidp? v0)
))

(greg-testcase "Creation of a Guile list from a voidp is OK" #t
(lambda ()
  (set! l0 (voidp->list v0 "c" 5))
  (greg-dlog l0)
  (list? l0)
))

(greg-testcase "We can create an NSData object from a Guile string" #t
(lambda ()
  (set! s0 "This is a test string")
  (set! l0 (string-length s0))
  (set! v0 (string->voidp s0))
  (set! d0 ([] "NSData" dataWithBytesNoCopy: v0 length: l0))
  ;
  ;; Having given the buffer malloced to hold the string to the NSData object
  ;; we must tell v0 not to attempt to free the buffer when it is destroyed.
  ;
  (voidp-set-malloc! v0 #f)
  (and (gstep-id? d0) (not (eq? d0 gstep-nil)))
))

(greg-testcase "We can create a Guile string from an NSData object" #t
(lambda ()
  (set! l1 ([] d0 length))
  (set! v1 ([] d0 bytes))
  (set! s1 (voidp->string v1 0 l1))
  (string=? s0 s1)
))

(greg-testcase "Giving away memory allocated to a voidp is ok" #t
(lambda ()
  ;
  ;; Now we redefine v0 and do and cause garbage-collection to take place
  ;; to make sure that the memory management as worked ok.  If this crashes
  ;; the test should be unresolved - 'cos we don't know what went wrong.
  ;
  (set! v0 #f)
  (set! d0 #f)
  (gc)
  #t
))

