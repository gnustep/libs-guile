
;   Copyright (C) 1998 Free Software Foundation, Inc.
;
;   Written by:  Richard Frith-Macdonald <rfm@gnu.org>
;   Date: April 1998
;
; This file is part of the Greg package - part of the GNUstep project.
;
; This library is free software; you can redistribute it and/or
; modify it under the terms of the GNU Lesser General Public
; License as published by the Free Software Foundation; either
; version 2.1 of the License, or (at your option) any later version.
; 
; This library is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
; Lesser General Public License for more details.
; 
; You should have received a copy of the GNU Lesser General Public
; License along with this library; if not, write to the Free Software
; Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
;

(greg-testcase "We can return an expected pass" #t
(lambda ()
  #t
))


(greg-testcase "We can return an expected fail" #f
(lambda ()
  #f
))


(greg-testcase "We can return an unexpected pass" #f
(lambda ()
  #t
))


(greg-testcase "We can return an unexpected fail" #t
(lambda ()
  #f
))


(greg-testcase "We can return an unresolved" #t
(lambda ()
  "xxx"
))


(greg-testcase "We can throw an expected pass" #t
(lambda ()
  (throw 'pass)
))


(greg-testcase "We can throw an expected fail" #f
(lambda ()
  (throw 'fail)
))


(greg-testcase "We can throw an unexpected pass" #f
(lambda ()
  (throw 'pass)
))


(greg-testcase "We can throw an unexpected fail" #t
(lambda ()
  (throw 'fail)
))


(greg-testcase "We can throw an untested" #t
(lambda ()
  (throw 'untested)
))


(greg-testcase "We can throw an unsupported" #t
(lambda ()
  (throw 'unsupported)
))


(greg-testcase "We can throw an unresolved" #t
(lambda ()
  (throw 'unresolved)
))


(set! greg-posix #t)

(greg-testcase "We can return an expected pass" #t
(lambda ()
  #t
))


(greg-testcase "We can't return an expected fail" #f
(lambda ()
  #f
))


(greg-testcase "We can't return an unexpected pass" #f
(lambda ()
  #t
))


(greg-testcase "We can return an unexpected fail" #t
(lambda ()
  #f
))


(greg-testcase "We can return an unresolved" #t
(lambda ()
  "xxx"
))


(greg-testcase "We can throw an expected pass" #t
(lambda ()
  (throw 'pass)
))


(greg-testcase "We can't throw an expected fail" #f
(lambda ()
  (throw 'fail)
))


(greg-testcase "We can't throw an unexpected pass" #f
(lambda ()
  (throw 'pass)
))


(greg-testcase "We can throw an unexpected fail" #t
(lambda ()
  (throw 'fail)
))


(greg-testcase "We can throw an untested" #t
(lambda ()
  (throw 'untested)
))


(greg-testcase "We can throw an unsupported" #t
(lambda ()
  (throw 'unsupported)
))


(greg-testcase "We can throw an unresolved" #t
(lambda ()
  (throw 'unresolved)
))

