
;   basic02.scm - Tests of calling Objective-C methods from Guile
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
;	Define some variables for communication between testcases
;
(define array #f)
(define d #f)
(define filehandle #f)
(define n #f)
(define number #f)
(define r1 #f)
(define r2 #f)
(define s #f)
(define u #f)
(define v #f)

;
;	Now do some testing of calling Objective-C methods from Guile
;
(greg-testcase "NSMutableArray supports addition and removal of objects" #t
(lambda ()
  (set! array ([] "NSMutableArray" arrayWithCapacity: 3))
  (set! number ([] "NSNumber" numberWithInt: 999))
  ([] array addObject: ([] "NSString" stringWithCString: "first element"))
  ([] array addObject: number)
  ([] array addObject: ([] "NSNumber" numberWithInt: 123))
  ([] array removeObject: number)

  (eq? ([] array count) 2)
))

(greg-testcase "NSString supports finding a substring" #t
(lambda ()
  (set! r1 ([] ([] "NSString" stringWithCString: "Hello world")
	      rangeOfString: ([] "NSString" stringWithCString: "worl")))
  (set! r2 (NSMakeRange 6 4))

  (and (eq? (NSRange-location r1) (NSRange-location r2))
	 (eq? (NSRange-length r1) (NSRange-length r2)))
))

(greg-testcase "NSString range checking raises an exception" #t
(lambda ()
  (catch #t
    (lambda ()
      (set! r2 (NSMakeRange 6 4))
      (define s ([] "NSString" stringWithCString: "Hello"))
      ([] s substringWithRange: r2)
      #f
    )
    (lambda key
      (greg-dlog "Caught expected exception -" key)
      #t
    )
  )
))

