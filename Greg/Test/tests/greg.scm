
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

