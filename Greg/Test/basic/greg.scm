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

