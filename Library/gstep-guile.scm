;;; gstep_guile.scm - Scheme definitions for Objective-C interface
;   Copyright (C) 1995 R. Andrew McCallum
;
;   Written by:  R. Andrew McCallum <mccallum@gnu.ai.mit.edu>
;   Date: April 1995
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

; Modified by: Masatake YAMATO (masata-y@is.aist-nara.ac.jp)
; Modified by: Richard Frith-Macdonald (richard@brainstorm.co.uk)

(define-module (languages gstep-guile))

(if (not (feature? 'gstep-guile))
    (dynamic-call "gstep_init" (dynamic-link "libgstep_guile.so")))

;
; You need to load this file to define convenience procedures for
; using the gstep_guile library.
;

;;; These are macro versions that require less quoting of arguments.

;;; With this you can say (gstep-class NSObject) 
;;; instead of (gstep-lookup-class "NSObject")
(defmacro-public gstep-class (classname)
  `(gstep-lookup-class ',classname))

;;; With this you can say (gstep-protocol NSCoding) 
;;; instead of (gstep-lookup-protocol "NSCoding")
(defmacro-public gstep-protocol (protocolname)
  `(gstep-lookup-protocol (if (string? ',protocolname)
			  ',protocolname
			  (symbol->string ',protocolname))))

;;; With this you can say (gstep-send foo respondsTo: 'myMethod:)
;;; instead of (gstep-msg-send foo "respondsTo:" 'myMethod).

;; This is Andrew's original version. 
;; Spread out method notation was not supported.
(defmacro-public gstep-send0 (receiver method . args)
  `(gstep-msg-send ,receiver ',method ,@args))

;; This is Masatake's modifed version.
;; Spread out method notation is supported!
(defmacro-public gstep-send1 (receiver arglist)
  `(gstep-msg-send ,receiver ,@(gstep-gather-methods-and-args (car (cdr arglist)))))

;; Merging these two. 
(defmacro-public [] (receiver . arglist)
  `(if (gstep-spread-out-arglist? ',arglist)
       (begin (gstep-send1 ,receiver ',arglist))
       (begin (gstep-send0 ,receiver ,(car arglist) ,@(cdr arglist)))))

;;; Another version of the same thing but handling the use of an unquoted class
;;; name as the receiver
(defmacro-public gstep-send (receiver . arglist)
  `(if (gstep-spread-out-arglist? ',arglist)
       (begin (gstep-send1 (gstep-object ,receiver) ',arglist))
       (begin (gstep-send0 (gstep-object ,receiver) ,(car arglist) ,@(cdr arglist)))))

;;
;; Helper functions 
;;

(defmacro-public selector (sym)
    `(symbol->string ',sym))

;;
;;	NB. 'defined?' doesn't work within 'let'!
;;
(defmacro-public gstep-object (receiver)
  `(if (symbol? ',receiver)
	(if (defined? ',receiver)
	    ,receiver
            (gstep-lookup-class ',receiver))
	(let ((r ,receiver))
	    (if (string? r)
                (gstep-lookup-class r)
	        r))))

;; (gstep-spread-out-arglist? '(abc:efg: 1 2)) -> #f
;; (gstep-spread-out-arglist? '(abc: 1 efg: 2)) -> #t
(define-public (gstep-spread-out-arglist? arglist)
  (let ((target (car arglist))
	(rvalue #f)
	(count-colon (lambda (x)
		       (let ((n 0))
			 (for-each (lambda (y)
				    (if (eqv? y #\:)
					(set! n (+ n 1))))
				  x) 
			 n))))
    (if (symbol? target)
	(set! target (symbol->string target)))
    (set! target (string->list target))
    (case (count-colon target)
      ((0)
       (set! rvalue #f))
      ((1)
       (if (> (length arglist) 2)
	   (begin  (set! rvalue #t))
	   (begin  (set! rvalue #f)))
       ))
    rvalue))

;; (perform: sel withObject: foo withObject: bar)
;;                         V
;; ("perform:withObject:withObject:" sel  foo  bar)
(define-public (gstep-gather-methods-and-args arglist)
  (let ((methods '())
	(args '())
	(flag 'methods))
    (for-each (lambda (x)
		(if (eq? flag 'methods)
		    (begin 
		      (if (symbol? x)
			  (set! x (symbol->string x)))
		      (set! methods (cons x methods))
		      (set! flag 'args))
		    (begin
		      (set! args (cons x args))
		      (set! flag 'methods))))
	      arglist)
    (set! methods (reverse methods))
    (set! args (reverse args))
    (cons (list->string methods) args)))

;;
;; Bool handler(#f, #t <-> YES, NO)
;;
;; In <objc/gstep-api.h>, YES is defined 1, NO is define as 0.
;;
(define-public (gstep-bool->bool objcb)
  (if (eq? objcb 0)
      #f
      #t))
(define-public (bool->gstep-bool scmb)
  (if scmb
      1
      0))
(define-public (gstep-bool obj)
  (if (boolean? obj) 
      (bool->gstep-bool obj)
      (gstep-bool->bool obj)))

(define-public (gstep-bool? obj)
  (or (eq? obj 1)			; ???
      (eq? obj 0)))			
;;
;; NSString handler
;;
(define-public ($$ scmstr)
  ([] "NSString" stringWithCString: scmstr))
(define-public (gstep-nsstring->string objstr)
  ([] objstr cString))
(define-public (string->gstep-nsstring scmstr)
  ([] "NSString" stringWithCString: scmstr))
(define-public (gstep-nsstring obj)
  (if (string? obj)
      (string->gstep-nsstring obj)
      (gstep-nsstring->string obj)))
(define-public (gstep-nsstring? obj)
  (and (gstep-id? obj)
       (gstep-bool->bool (gstep-msg-send obj "isKindOfClass:" (gstep-lookup-class "NSString")))))


;;
;;	Stuff for handling ranges.
;;
(define-public (NSMakeRange location length)
    (list location length))
(define-public (NSRange-location range)
    (car range))
(define-public (NSRange-length range)
    (car (cdr range)))
(define-public (NSRange-setLocation! range location)
    (set-car! range location))
(define-public (NSRange-setLength! range length)
    (set-car! (cdr range) length))


;;
;;(provide 'gstep_guile)

