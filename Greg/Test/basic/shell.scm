;
;	Start up a shell to talk to.
;
(greg-child "/bin/sh" "-i")

(greg-testcase "A shell will echo hello" #t
(lambda ()
  (greg-send "echo hello\n")
  (greg-recv ("^hello" #t))
))

