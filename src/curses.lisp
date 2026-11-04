;;; Public facade for the dependency-free VT100/xterm Curses implementation.
(uiop:define-package #:ooparts/curses
  (:use #:cl)
  (:use-reexport #:ooparts/curses/api #:ooparts/curses/terminfo #:ooparts/curses/extras
                 #:ooparts/curses/panel #:ooparts/curses/menu #:ooparts/curses/form))
(in-package #:ooparts/curses)
