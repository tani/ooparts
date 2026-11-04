(require :asdf)
(asdf:load-system "ooparts/readline")
(loop for line = (ooparts/readline:readline "> ") while line do
  (when (string= line "quit") (return))
  (format t "You entered: ~S~%" line))
