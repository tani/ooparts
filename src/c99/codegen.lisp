(uiop:define-package #:ooparts/c99/codegen
  (:use #:cl)
  (:export #:emit-assembly))
(in-package #:ooparts/c99/codegen)

(defun %target (target)
  (unless (member target '(:x86-64-linux :x86-64-macos
                            :aarch64-linux :aarch64-macos))
    (error "Unsupported target: ~S" target))
  target)

(defun emit-assembly (ast &key (target :x86-64-linux))
  "Emit textual assembler for a constant-returning function on one of four ABIs."
  (%target target)
  (destructuring-bind (kind name integer) ast
    (unless (and (eq kind :function) (stringp name) (integerp integer)
                 (<= -2147483648 integer 2147483647))
      (error "Unsupported C99 IR: ~S" ast))
    (let* ((macos (member target '(:x86-64-macos :aarch64-macos)))
           (arm (member target '(:aarch64-linux :aarch64-macos)))
           (symbol (concatenate 'string (if macos "_" "") name))
           (bits (ldb (byte 32 0) integer)))
      (with-output-to-string (out)
        (format out ".text~%.globl ~A~%" symbol)
        (unless macos (format out ".type ~A, @function~%" symbol))
        (format out "~A:~%" symbol)
        (if arm
            (progn
              (format out "    movz w0, #~D~%" (ldb (byte 16 0) bits))
              (format out "    movk w0, #~D, lsl #16~%" (ldb (byte 16 16) bits)))
            (format out "    movl $~D, %eax~%" bits))
        (format out "    ret~%")
        (unless macos (format out ".size ~A, .-~A~%" symbol symbol))))))
