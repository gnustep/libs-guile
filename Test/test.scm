
(display "\nLoading 'greg' framework...\n\n")
(use-modules (ice-9 greg))
(display "\nRunning basic tests...\n\n")
(set! greg-tools (list "tests"))
(greg-test-run)
(display "\nTests complete.\n\n")
(display "\nThere should be a log in 'tests.log'\n")

