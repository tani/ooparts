(uiop:define-package #:ooparts/curses/model
  (:use #:cl)
  (:export #:cell #:make-cell #:cell-text #:cell-attrs #:cell-pair #:cell-width #:copy-cell
           #:window #:make-window #:window-p #:window-rows #:window-cols #:window-y #:window-x
           #:window-cy #:window-cx #:window-parent #:window-data #:window-dy #:window-dx
           #:window-attrs #:window-pair #:window-background #:window-scroll-p #:window-top
           #:window-bottom #:window-delay #:window-keypad-p #:window-notimeout-p
           #:window-leave-p #:window-immediate-p #:window-pad-p #:window-dirty
           #:window-sync-p #:window-deleted-p #:window-children #:window-viewport
           #:screen #:make-screen #:screen-rows #:screen-cols #:screen-input #:screen-output
           #:screen-terminal #:screen-standard #:screen-desired #:screen-physical
           #:screen-ended-p #:screen-mode #:screen-echo-p #:screen-nl-p #:screen-unget
           #:screen-escdelay #:screen-profile #:screen-force-p #:screen-windows
           #:screen-colors #:screen-pairs #:screen-color-p #:screen-cursor #:screen-mouse-mask
           #:screen-mouse-events #:screen-mouse-interval #:screen-paste-p
           #:screen-saved-mode #:screen-shell-mode #:screen-tabsize
           #:at #:blank-cell #:mark #:character-width #:text-width #:cell-equal-p))
(in-package #:ooparts/curses/model)

(defstruct cell (text " ") (attrs 0) (pair 0) (width 1))
(defun blank-cell () (make-cell))
(defstruct (window (:constructor %make-window))
  rows cols (y 0) (x 0) (cy 0) (cx 0) parent data (dy 0) (dx 0)
  (attrs 0) (pair 0) (background (blank-cell)) (scroll-p nil) (top 0) bottom
  (delay -1) (keypad-p nil) (notimeout-p nil) (leave-p nil) (immediate-p nil)
  (pad-p nil) dirty (sync-p nil) (deleted-p nil) children viewport)
(defun make-window (&key rows cols (y 0) (x 0) parent (dy 0) (dx 0) pad-p)
  (let ((data (unless parent (make-array (list rows cols)))))
    (when data (dotimes (r rows) (dotimes (c cols) (setf (aref data r c) (blank-cell)))))
    (let ((win (%make-window :rows rows :cols cols :y y :x x :parent parent
                            :data data :dy dy :dx dx :pad-p pad-p :bottom (1- rows)
                            :dirty (make-array rows :initial-element t))))
      (when parent (push win (window-children parent))) win)))
(defun at (win y x)
  (if (window-parent win)
      (at (window-parent win) (+ y (window-dy win)) (+ x (window-dx win)))
      (aref (window-data win) y x)))
(defun (setf at) (value win y x)
  (if (window-parent win)
      (setf (at (window-parent win) (+ y (window-dy win)) (+ x (window-dx win))) value)
      (setf (aref (window-data win) y x) value)))
(defun mark (win y)
  (setf (aref (window-dirty win) y) t)
  (when (and (window-sync-p win) (window-parent win))
    (mark (window-parent win) (+ y (window-dy win)))))
(defstruct screen rows cols input output terminal standard desired physical
  (ended-p nil) (mode :cbreak) (echo-p nil) (nl-p t) unget (escdelay 30)
  (profile :xterm) (force-p t) windows
  (colors (make-hash-table)) (pairs (make-hash-table)) (color-p nil) (cursor 1)
  (mouse-mask 0) mouse-events (mouse-interval 200) (paste-p nil) saved-mode shell-mode
  (tabsize 8))
(defun cell-equal-p (a b)
  (and a b (string= (cell-text a) (cell-text b)) (= (cell-attrs a) (cell-attrs b))
       (= (cell-pair a) (cell-pair b)) (= (cell-width a) (cell-width b))))

(defun character-width (char)
  "Deterministic terminal width policy: combining marks 0, East Asian wide 2.
Emoji presentation sequences and ambiguous-width characters are not inferred."
  (let ((n (char-code char)))
    (cond ((or (< n 32) (<= 127 n 159)) -1)
          ((or (<= #x300 n #x36f) (<= #x1ab0 n #x1aff) (<= #x1dc0 n #x1dff)
               (<= #x20d0 n #x20ff) (<= #xfe00 n #xfe0f) (<= #xfe20 n #xfe2f)
               (<= #xe0100 n #xe01ef) (= n #x200d)) 0)
          ((or (<= #x1100 n #x115f) (<= #x2329 n #x232a)
               (<= #x2e80 n #xa4cf) (<= #xac00 n #xd7a3) (<= #xf900 n #xfaff)
               (<= #xfe10 n #xfe19) (<= #xfe30 n #xfe6f) (<= #xff01 n #xff60)
               (<= #xffe0 n #xffe6) (<= #x1f300 n #x1faff) (<= #x20000 n #x3fffd)) 2)
          (t 1))))
(defun text-width (text) (loop for char across text sum (max 0 (character-width char))))
