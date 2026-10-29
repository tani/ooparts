;;; Run from the repository root after recording results.sexp.
(in-package #:cl-user)
(defun median (values)
  (let* ((sorted (sort (copy-list values) #'<)) (n (length sorted)))
    (if (oddp n) (nth (floor n 2) sorted)
        (/ (+ (nth (1- (/ n 2)) sorted) (nth (/ n 2) sorted)) 2))))
(let ((groups (make-hash-table :test 'equal)) (order nil))
  (with-open-file (stream "benchmarks/prolog/type-declarations/results.sexp")
    (loop for row = (read stream nil nil) while row do
      (let ((key (list (getf row :case) (getf row :variant))))
        (unless (gethash key groups) (push key order))
        (push row (gethash key groups)))))
  (with-open-file (stream "benchmarks/prolog/type-declarations/results.csv"
                          :direction :output :if-exists :supersede)
    (format stream "case,variant,samples,compile_ms,run_ms,run_min_ms,run_max_ms,export_ms,run_MiB,export_MiB,answers~%")
    (dolist (key (nreverse order))
      (let ((rows (gethash key groups)))
        (flet ((med (property) (median (mapcar (lambda (row) (getf row property)) rows))))
          (format stream "~A,~A,~D,~,3F,~,3F,~,3F,~,3F,~,3F,~,3F,~,3F,~D~%"
                  (first key) (second key) (length rows) (med :compile-ms) (med :run-ms)
                  (reduce #'min rows :key (lambda (row) (getf row :run-ms)))
                  (reduce #'max rows :key (lambda (row) (getf row :run-ms)))
                  (med :export-ms) (/ (med :run-bytes) 1048576d0)
                  (/ (med :export-bytes) 1048576d0) (getf (first rows) :answers)))))))
