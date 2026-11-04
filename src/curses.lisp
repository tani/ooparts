;;; Public facade for the dependency-free VT100/xterm Curses implementation.
(uiop:define-package #:ooparts/curses
  (:use #:cl)
  (:use-reexport #:ooparts/curses/api))
(in-package #:ooparts/curses)
