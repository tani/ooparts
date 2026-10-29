;;; Compile the complete implementation with normal SBCL diagnostics enabled.
;;; Nothing is muffled. All compiler notes and warnings make this test fail.
(require :asdf)
(declaim (sb-ext:unmuffle-conditions sb-ext:compiler-note))
(defvar *compile-audit-rows* nil)
(defvar *compile-audit-diagnostics* nil)
(defparameter *compile-audit-root* (truename (merge-pathnames "../../" (uiop:pathname-directory-pathname *load-truename*))))
(asdf:load-asd (merge-pathnames "ooparts.asd" *compile-audit-root*))
;; External dependencies retain their own compiler policies. Audit every SAT
;; module, including the selected storage backend, without rebuilding them.
(asdf:load-system "bordeaux-threads")
(sb-int:encapsulate 'compile-file 'ooparts/sat/low-level-compile-audit
 (lambda (original &rest args)
  (let ((notes 0) (warnings 0) (results nil))
   (handler-bind
       ((sb-ext:compiler-note
          (lambda (condition)
           (incf notes)
           (push (list (namestring (pathname (first args))) :note (princ-to-string condition))
                 *compile-audit-diagnostics*)))
        (warning
          (lambda (condition)
           (incf warnings)
           (push (list (namestring (pathname (first args))) :warning (princ-to-string condition))
                 *compile-audit-diagnostics*))))
    (setf results (multiple-value-list (apply original args))))
   (push (list (enough-namestring (pathname (first args)) *compile-audit-root*) notes warnings)
         *compile-audit-rows*)
   (values-list results))))
(unwind-protect (asdf:load-system "ooparts/sat/cli"
                                 :force (lambda (name) (uiop:string-prefix-p "ooparts/" name)))
 (sb-int:unencapsulate 'compile-file 'ooparts/sat/low-level-compile-audit))
(let ((notes (reduce #'+ *compile-audit-rows* :key #'second))
      (warnings (reduce #'+ *compile-audit-rows* :key #'third)))
 (with-open-file (out (merge-pathnames "tests/sat/reports/compiler-diagnostics.json" *compile-audit-root*)
                      :direction :output :if-exists :supersede)
  (format out "{~%  ~S: ~D,~%  ~S: ~D,~%  ~S: [~%" "notes" notes "warnings" warnings "files")
  (loop for row in (reverse *compile-audit-rows*) for i from 0 do
   (when (plusp i) (format out ",~%"))
   (destructuring-bind (file n w) row
    (format out "    {~S: ~S, ~S: ~D, ~S: ~D}" "file" file "notes" n "warnings" w)))
  (format out "~%  ]~%}~%"))
 (format t "Compiler audit: ~D files, ~D notes, ~D warnings.~%" (length *compile-audit-rows*) notes warnings)
 (when (or (plusp notes) (plusp warnings))
  (error "Compiler diagnostics remain: ~S" (reverse *compile-audit-diagnostics*))))
