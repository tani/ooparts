(uiop:define-package #:ooparts/sat/storage
  (:use #:cl)
  (:use-reexport
   #+(and sbcl x86-64 (not ooparts-portable-sat)) #:ooparts/sat/storage/native
   #-(and sbcl x86-64 (not ooparts-portable-sat)) #:ooparts/sat/storage/portable))
(in-package #:ooparts/sat/storage)
