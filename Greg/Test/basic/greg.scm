
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

;
;	Test that all possible exits from greg-testcase work as expected.
;

(greg-testcase "We can return an expected pass" #t
(lambda ()
  (greg-recv ("^PASS: We can return an expected pass" #t))
))

(greg-testcase "We can return an expected fail" #t
(lambda ()
  (greg-recv ("^XFAIL: We can return an expected fail" #t))
))

(greg-testcase "We can return an unexpected pass" #t
(lambda ()
  (greg-recv ("^UPASS: We can return an unexpected pass" #t))
))

(greg-testcase "We can return an unexpected fail" #t
(lambda ()
  (greg-recv ("^FAIL: We can return an unexpected fail" #t))
))

(greg-testcase "We can return an unresolved" #t
(lambda ()
  (greg-recv ("^UNRESOLVED: We can return an unresolved" #t))
))

(greg-testcase "We can throw an expected pass" #t
(lambda ()
  (greg-recv ("^PASS: We can throw an expected pass" #t))
))

(greg-testcase "We can throw an expected fail" #t
(lambda ()
  (greg-recv ("^XFAIL: We can throw an expected fail" #t))
))

(greg-testcase "We can throw an unexpected pass" #t
(lambda ()
  (greg-recv ("^UPASS: We can throw an unexpected pass" #t))
))

(greg-testcase "We can throw an unexpected fail" #t
(lambda ()
  (greg-recv ("^FAIL: We can throw an unexpected fail" #t))
))

(greg-testcase "We can throw an untested" #t
(lambda ()
  (greg-recv ("^UNTESTED: We can throw an untested" #t))
))

(greg-testcase "We can throw an unsupported" #t
(lambda ()
  (greg-recv ("^UNSUPPORTED: We can throw an unsupported" #t))
))

(greg-testcase "We can throw an unresolved" #t
(lambda ()
  (greg-recv ("^UNRESOLVED: We can throw an unresolved" #t))
))

;
;	Now do it all again with strict posix
;
(set! greg-posix #t)

(greg-testcase "We can return an expected pass" #t
(lambda ()
  (greg-recv ("^PASS: We can return an expected pass" #t))
))

(greg-testcase "We can't return an expected fail" #t
(lambda ()
  (greg-recv ("^FAIL: We can't return an expected fail" #t))
))

(greg-testcase "We can't return an unexpected pass" #t
(lambda ()
  (greg-recv ("^PASS: We can't return an unexpected pass" #t))
))

(greg-testcase "We can return an unexpected fail" #t
(lambda ()
  (greg-recv ("^FAIL: We can return an unexpected fail" #t))
))

(greg-testcase "We can return an unresolved" #t
(lambda ()
  (greg-recv ("^UNRESOLVED: We can return an unresolved" #t))
))

(greg-testcase "We can throw an expected pass" #t
(lambda ()
  (greg-recv ("^PASS: We can throw an expected pass" #t))
))

(greg-testcase "We can't throw an expected fail" #t
(lambda ()
  (greg-recv ("^FAIL: We can't throw an expected fail" #t))
))

(greg-testcase "We can't throw an unexpected pass" #t
(lambda ()
  (greg-recv ("^PASS: We can't throw an unexpected pass" #t))
))

(greg-testcase "We can throw an unexpected fail" #t
(lambda ()
  (greg-recv ("^FAIL: We can throw an unexpected fail" #t))
))

(greg-testcase "We can throw an untested" #t
(lambda ()
  (greg-recv ("^UNTESTED: We can throw an untested" #t))
))

(greg-testcase "We can throw an unsupported" #t
(lambda ()
  (greg-recv ("^UNSUPPORTED: We can throw an unsupported" #t))
))

(greg-testcase "We can throw an unresolved" #t
(lambda ()
  (greg-recv ("^UNRESOLVED: We can throw an unresolved" #t))
))

