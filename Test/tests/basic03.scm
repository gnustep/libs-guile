
;   basic03.scm - Tests of macros and procedures from gstep-guile module
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

(begin

(define r "")
(define cls "")
(define obj "")
(define prt "")
(define result "")

(greg-testcase "gstep-class can lookup NSObject" #t
(lambda ()
  (set! cls (gstep-class NSObject))
  (not (eq? cls gstep-nil))
))

(greg-testcase "gstep-protocol can lookup NSCoding" #t
(lambda ()
  (set! prt (gstep-protocol NSCoding))
  (not (eq? prt gstep-nil))
))

(greg-testcase "selector converts a symbol to a string" #t
(lambda ()
  (string=? "description" (selector description))
))

(greg-testcase "(gstep-bool->bool 1) returns #t" #t
(lambda ()
  (set! result (gstep-bool->bool 1))
  (and (boolean? result) result)
))

(greg-testcase "(gstep-bool->bool 0) returns #f" #t
(lambda ()
  (set! result (gstep-bool->bool 0))
  (and (boolean? result) (not result))
))

(greg-testcase "(bool->gstep-bool #t) returns 1" #t
(lambda ()
  (eq? (bool->gstep-bool #t) 1)
))

(greg-testcase "(bool->gstep-bool #f) returns 0" #t
(lambda ()
  (eq? (bool->gstep-bool #f) 0)
))

(greg-testcase "(gstep-bool #t) returns 1" #t
(lambda ()
  (eq? (gstep-bool #t) 1)
))

(greg-testcase "(gstep-bool #f) returns 0" #t
(lambda ()
  (eq? (gstep-bool #f) 0)
))

(greg-testcase "(gstep-bool 1) returns #t" #t
(lambda ()
  (set! result (gstep-bool 1))
  (and (boolean? result) result)
))

(greg-testcase "(gstep-bool 0) returns #f" #t
(lambda ()
  (set! result (gstep-bool 0))
  (and (boolean? result) (not result))
))

(greg-testcase "(gstep-bool? 0) returns #t" #t
(lambda ()
  (set! result (gstep-bool? 0))
  (and (boolean? result) result)
))

(greg-testcase "(gstep-bool? 1) returns #t" #t
(lambda ()
  (set! result (gstep-bool? 1))
  (and (boolean? result) result)
))

(greg-testcase "(gstep-bool? \"x\") returns #f" #t
(lambda ()
  (set! result (gstep-bool? "x"))
  (and (boolean? result) (not result))
))

(set! cls ([] "NSString" class))

(greg-testcase "$$ creates an NSString" #t
(lambda ()
  (set! result ($$ "hello"))
  (set! result ([] result isKindOfClass: cls))
  (gstep-bool->bool result)
))

(greg-testcase "string->gstep-nsstring creates an NSString" #t
(lambda ()
  (set! result ([] (string->gstep-nsstring "hello") isKindOfClass: cls))
  (gstep-bool->bool result)
))

(greg-testcase "gstep-nsstring->string gives us a string" #t
(lambda ()
  (set! obj ($$ "hello"))
  (string=? (gstep-nsstring->string obj) "hello")
))

(greg-testcase "gstep-nsstring? returns #t for an NSString object" #t
(lambda ()
  (set! obj ($$ "hello"))
  (gstep-nsstring? obj)
))

(greg-testcase "gstep-nsstring? returns #f for a string object" #t
(lambda ()
  (not (gstep-nsstring? "test"))
))

(greg-testcase "gstep-nsstring converts a string to an NSString" #t
(lambda ()
  (set! result ([] (gstep-nsstring "hello") isKindOfClass: cls))
  (gstep-bool->bool result)
))

(greg-testcase "gstep-nsstring converts an NSString to a string" #t
(lambda ()
  (set! obj ($$ "hello"))
  (string=? (gstep-nsstring obj) "hello")
))

(set! r '())
(greg-testcase "NSMakeRange builds expected list" #t
(lambda ()
  (set! r (NSMakeRange 5 6))
  (equal? r '(5 6))
))

(greg-testcase "NSRange-location extracts expected value" #t
(lambda ()
  (eq? (NSRange-location r) 5)
))

(greg-testcase "NSRange-length extracts expected length" #t
(lambda ()
  (eq? (NSRange-length r) 6)
))

(greg-testcase "NSRange-setLocation! works as expected" #t
(lambda ()
  (NSRange-setLocation! r 1)
  (equal? r '(1 6))
))

(greg-testcase "NSRange-setLength! works as expected" #t
(lambda ()
  (NSRange-setLength! r 9)
  (equal? r '(1 9))
))

)
