;
; Testing creation of a new class and adding methods to an existing class.
;

(define called_name 0)
(define called_displayThisNumber 0)
(define called_test 0)
(define called_numb 0)
(define called_echo 0)
(define called_show 0)

;
; We define some procedures to try
;
(define (foo->test receiver method args)
	(set! called_test (+ called_test 1))
	(greg-dlog "In foo->test\n  Receiver is - ")
	(greg-dlog receiver)
	(greg-dlog "\n  Selector is - ")
	(greg-dlog method)
	(greg-dlog "\n")
)

(define (foo->numb receiver method args)
	(set! called_numb (+ called_numb 1))
	(greg-dlog "In foo->numb - returning 666\n")
	666)

(define (foo->echo: receiver method args)
	(set! called_echo (+ called_echo 1))
	(greg-dlog "In foo->echo:\n")
	(greg-dlog (car args))
        (car args))

(define (foo->show: receiver method args)
	(set! called_show (+ called_show 1))
	(greg-dlog "In foo->show:\n")
	(greg-dlog args))

(greg-testcase "Guile can define an Objective-C class" #t
(lambda ()
(gstep-new-class "foo" "NSObject"
    (list (cons "here"  "i") (cons "there" "i"))
    (list
	(list "test" "v@:" foo->test)
	(list "numb" "i@:" foo->numb)
	(list "echo:" "*@:*" foo->echo:)
	(list "show:" "v@:*" foo->show:))
    '())
#t
))

;
; Add 'test' as both instance and class method for NSString.
;
(greg-testcase "Guile can add methods to an Objective-C class" #t
(lambda ()
(gstep-class-methods "NSString" (list (list "test" "v@:" foo->test)))
(gstep-instance-methods "NSString" (list (list "test" "v@:" foo->test)))
#t
))

;
; Now try them
;
(greg-testcase "Guile can call a factory method added to a class" #t
(lambda ()
([] "NSString" test)
(= called_test 1)
))

(greg-testcase "Guile can call an instance method added to a class" #t
(lambda ()
([] ([] "NSString" new) test)
(= called_test 2)
))

;
; Play with an instance of 'foo'
;
(define xxx #f)

(greg-testcase "Guile can set an instance variable in an object" #t
(lambda ()
(set! xxx ([] "foo" new))

(greg-dlog "\n")
(greg-dlog (gstep-ivarnames xxx))
(gstep-set-ivar xxx "here" 777)
(gstep-set-ivar xxx "there" 888)
(greg-dlog "\n")
(greg-dlog (gstep-get-ivar xxx "here"))
(= (gstep-get-ivar xxx "here") 777)
))

(greg-testcase "Guile can read an instance variable from an object" #t
(lambda ()
(greg-dlog (gstep-get-ivar xxx "there"))
(= (gstep-get-ivar xxx "there") 888)
))

(greg-testcase "Guile can make method calls on newly created class" #t
(lambda ()
(greg-dlog "\n")
(greg-dlog ([] xxx test))
(= called_test 3)
))

;(greg-dlog "\n")
;(greg-dlog ([] xxx numb))
;(passfail (eq? called_numb 1) "method call to new class (2)")
;(greg-dlog "\n")
;(greg-dlog ([] xxx show: "Hello world."))
;(passfail (eq? called_show 1) "method call to new class (3)")
;(greg-dlog "\n")
;(greg-dlog ([] xxx echo: "Testing."))
;(passfail (eq? called_echo 1) "method call to new class (4)")
;(greg-dlog "\n")

