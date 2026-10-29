(uiop:define-package #:ooparts/prolog/src/library/standard-library
  (:use #:cl)
  (:import-from #:ooparts/prolog/src/api/state
    #:*standard-predicates* #:*iso-standard-predicates*)
  (:import-from #:ooparts/prolog/src/kernel/engine
    #:predicate-key)
  (:import-from #:ooparts/prolog/src/kernel/instructions
    #:call #:fail #:true)
  (:import-from #:ooparts/prolog/src/kernel/model
    #:*term-model* #:$cons #:$nil #:make-predicate)
  (:import-from #:ooparts/prolog/src/syntax/compiler
    #:compile-predicate)
  (:import-from #:ooparts/prolog/src/kernel/protocol)
  (:import-from #:ooparts/prolog/src/adapters/builtins)
  (:import-from #:ooparts/prolog/src/adapters/term-ops #:iso-empty-list #:iso-list-cons)
  (:export #:install-standard-predicate))
(in-package #:ooparts/prolog/src/library/standard-library)


(defun library-term (term)
  ;; Only explicit list literals change representation. Instruction/application
  ;; spines remain ordinary host lists in both compilations.
  (cond ((eq term '$nil) (iso-empty-list))
        ((and (consp term) (eq (car term) '$cons))
         (iso-list-cons (library-term (second term)) (library-term (third term))))
        ((consp term) (mapcar #'library-term term))
        (t term)))
(defun install-standard-predicate-for-model (clauses)
  "Compile ordinary clauses into the shared, protected base library."
  (let ((key (predicate-key (caar clauses))))
    (setf (gethash (cons (string-upcase (symbol-name (car key))) (cdr key))
                   (if (eq *term-model* :iso) *iso-standard-predicates* *standard-predicates*))
          (make-predicate :clauses clauses :code (compile-predicate clauses)
                          :adapter-context
                          (member (string-upcase (symbol-name (car key)))
                                  '("OPEN" "CLOSE" "HALT" "NL" "FLUSH_OUTPUT"
                                    "AT_END_OF_STREAM" "GET_CHAR" "GET_CODE"
                                    "PEEK_CHAR" "PEEK_CODE" "GET_BYTE" "PEEK_BYTE"
                                    "PUT_CHAR" "PUT_CODE" "PUT_BYTE" "ATOM_LENGTH"
                                    "ATOM_CHARS" "NUMBER_CHARS" "SUB_ATOM" "RETRACTALL"
                                    "@<" "@=<" "@>" "@>=" "SETOF" "READ" "READ_TERM"
                                    "WRITE" "WRITEQ" "WRITE_CANONICAL" "WRITE_TERM")
                                  :test #'string=)))))

(defun install-standard-predicate (clauses)
  (dolist (*term-model* '(:native :iso))
    (install-standard-predicate-for-model (library-term clauses))))

(eval-when (:load-toplevel :execute)
  (clrhash *standard-predicates*)
  (clrhash *iso-standard-predicates*)
  (dolist (clauses
           '((((|\\+| ?goal) (call ?goal) ! fail)
              ((|\\+| ?goal)))
             (((once ?goal) (call ?goal) !))
             (((repeat)) ((repeat) (repeat)))
             (((nonvar ?x) (|\\+| (var ?x))))
             (((number ?x) (integer ?x)) ((number ?x) (float ?x)))
             (((callable ?x) (atom ?x)) ((callable ?x) (compound ?x)))
             (((ground ?x) (term_variables ?x $nil)))
             (((|\\=| ?x ?y) (|\\+| (= ?x ?y))))
             (((|\\==| ?x ?y) (|\\+| (== ?x ?y))))))
    (install-standard-predicate clauses)))

;;; Adapter wrappers are ordinary clauses; only explicit-stream operations
;;; and argument validation require the host boundary.
(eval-when (:load-toplevel :execute)
  (dolist (clauses
           '((((open ?file ?mode ?stream) (open ?file ?mode ?stream $nil)))
             (((close ?stream) (close ?stream $nil)))
             (((halt) (halt 0)))
             (((nl) (current_output ?stream) (nl ?stream)))
             (((nl ?stream) (put_code ?stream 10)))
             (((flush_output) (current_output ?stream) (flush_output ?stream)))
             (((at_end_of_stream) (current_input ?stream) (at_end_of_stream ?stream)))
             (((atom_length ?atom ?length)
               (%output_nonnegative ?length) (atom_codes ?atom ?codes)
               (%list_length ?codes 0 ?length)))
             (((%list_length $nil ?n ?n))
              ((%list_length ($cons ?head ?tail) ?n ?length)
               (is ?next (+ ?n 1)) (%list_length ?tail ?next ?length)))
             (((sub_atom ?atom ?before ?length ?after ?sub)
               (%sub_atom_arguments ?atom ?before ?length ?after ?sub)
               (atom_concat ?prefix ?rest ?atom)
               (atom_concat ?sub ?suffix ?rest)
               (atom_length ?prefix ?before)
               (atom_length ?sub ?length)
               (atom_length ?suffix ?after)))))
    (install-standard-predicate clauses))
  (dolist (name '(get_char get_code peek_char peek_code get_byte peek_byte
                 put_char put_code put_byte))
    (install-standard-predicate
     (list (list (list name '?value)
                 (list (if (member name '(put_char put_code put_byte))
                           'current_output 'current_input) '?stream)
                 (list name '?stream '?value))))))

;;; Graph copying remains internal to FINDALL. RETRACTALL only needs the
;;; database boundary to ensure an empty dynamic predicate is observable.
(eval-when (:load-toplevel :execute)
  (dolist (clauses
           '((((copy_term ?term ?copy) (findall ?term true ($cons ?copy $nil))))
             (((retractall ?head) (%ensure_dynamic ?head) (%retractall ?head)))
             (((%retractall ?head) (%retract_head ?head) fail)
              ((%retractall ?head)))))
    (install-standard-predicate clauses)))

(eval-when (:load-toplevel :execute)
  (dolist (clauses
           '((((atom_chars ?atom ?chars)
               (%chars_arguments atom ?atom ?chars)
               (or (-> (var ?atom)
                       (and (%chars_codes ?chars ?codes) (atom_codes ?atom ?codes)))
                   (and (atom_codes ?atom ?codes) (%chars_codes ?chars ?codes)))))
             (((number_chars ?number ?chars)
               (%chars_arguments number ?number ?chars)
               (or (-> (ground ?chars)
                       (and (%chars_codes ?chars ?codes) (number_codes ?number ?codes)))
                   (and (number_codes ?number ?codes) (%chars_codes ?chars ?codes)))))
             (((%chars_codes $nil $nil))
              ((%chars_codes ($cons ?char ?chars) ($cons ?code ?codes))
               (char_code ?char ?code) (%chars_codes ?chars ?codes)))))
    (install-standard-predicate clauses)))

(eval-when (:load-toplevel :execute)
  (dolist (clauses
           '((((@< ?a ?b) (compare < ?a ?b)))
             (((@> ?a ?b) (compare > ?a ?b)))
             (((@=< ?a ?b) (compare ?order ?a ?b) (|\\==| ?order >)))
             (((@>= ?a ?b) (compare ?order ?a ?b) (|\\==| ?order <)))
             (((setof ?template ?goal ?set) (bagof ?template ?goal ?bag) (sort ?bag ?set)))))
    (install-standard-predicate clauses)))

(eval-when (:load-toplevel :execute)
  (dolist (clauses
           '((((read ?term) (current_input ?stream) (read ?stream ?term)))
             (((read ?stream ?term) (read_term ?stream ?term $nil)))
             (((read_term ?term ?options) (current_input ?stream) (read_term ?stream ?term ?options)))
             (((write_term ?term ?options) (current_output ?stream) (write_term ?stream ?term ?options)))))
    (install-standard-predicate clauses))
  (dolist (name '(write writeq write_canonical))
    (install-standard-predicate (list (list (list name '?term) '(current_output ?stream) (list name '?stream '?term))))
    (install-standard-predicate (list (list (list name '?stream '?term)
      (list 'write_term '?stream '?term
            (case name (write '$nil)
              (writeq '($cons (quoted true) ($cons (numbervars true) $nil)))
              (write_canonical '($cons (quoted true) ($cons (ignore_ops true) $nil))))))))))
