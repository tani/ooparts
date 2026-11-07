;;;; Optional, per-case MLton regression runner.
;;;;
;;;; This file deliberately has no compiler-system load in the parent process.
;;;; tools/sml/mlton-worker.lisp loads the public SML compiler in a fresh child
;;;; only for an explicitly classified case selected for execution.

(require :asdf)

(defpackage #:ooparts/tools/sml/mlton
  (:use #:cl)
  (:export #:main))

(in-package #:ooparts/tools/sml/mlton)

(defparameter +mlton-revision+ "5fe943391e539a502699327a6266b6e8e97939e1")
(defparameter +mlton-regression-tree+ "d3c35781496aa17015cfdf4a6a4afb6c0f8bb380")
(defparameter +nonzero-marker+
  (map '(simple-array (unsigned-byte 8) (*)) #'char-code
       (format nil "Nonzero exit status.~%")))
(defparameter +usage+
  "Usage: sbcl --script tools/sml/mlton.lisp [OPTIONS]

Enumerate the pinned MLton regression corpus, or execute explicitly classified
cases through OOPArts in one isolated child process per case.  With neither
--list nor --execute, the action is --list.  Execution is never implicit in an
existing OOPArts regression command.

Actions:
  --help                    Show this help and exit without loading the compiler.
  --list                    Inventory only (the default).
  --execute                 Execute selected, explicitly applicable+supported cases.

Selection and assessment:
  --corpus DIRECTORY        MLton checkout (default: build/mlton).
  --suite SUITE             normal, modules, fail, nonterminate, or all; repeatable.
                            Default: normal.  The four collections are distinct.
  --case PATH               Exact regression-relative .sml path; repeatable.
                            Examples: example.sml, modules/example.sml,
                            fail/example.sml, nonterminate/example.sml.
                            Nonselected discoveries remain
                            visible as NOT-SELECTED in output and the report.
                            This pinned checkout has no regression/modules/
                            directory: module-language cases are in normal/*.sml.
                            An explicit absent collection is SUITE-MISSING.
  --assessments FILE        Read an assessment data file; repeatable.  Required
                            with --execute.  Assessments never derive support or
                            applicability from filenames or compiler conditions.

Oracle and process configuration (repeat selectors in precedence order):
  --oracle-selector NAME    Consider <case>.<NAME>.ok after <case>.ok and after
                            every earlier selector.  The last existing readable
                            file wins.  Overrides are gated by readable base .ok.
                            No object representation, OS, or architecture is
                            inferred.  Example ordered Linux declaration:
                              --oracle-selector linux
                              --oracle-selector arm64
                              --oracle-selector arm64-linux
  --lisp PROGRAM            Lisp executable for children (default: sbcl).
  --timeout SECONDS         Positive per-case child timeout; expiration is TIMEOUT,
                            never successful source rejection or execution.

Generated paths (must be relative; no absolute path or '..' is accepted):
  --output-directory DIR    Directory below build/sml (default: mlton).
  --report FILE             Report below that output directory (default: report.sexp).
                            Captures, requests, responses and worker logs also stay
                            below the output directory; corpus files are read-only.

Assessment format (one UTF-8 form per file):
  (:assessment-version 1
   :cases
   ((:path \"example.sml\"
     :language (\"SML '97\") :basis (\"Core\") :target (\"linux\" \"arm64\")
     :extensions () :applicable t :supported t
     :notes \"Domain-reviewed for this declared target.\")))

:language must be a nonempty list of strings; :basis, :target and :extensions
are lists of strings (possibly empty).  :applicable is T or NIL; :supported is
T, NIL or :UNKNOWN.  All are explicit review decisions.  A missing assessment
is UNCLASSIFIED, false applicability is NOT-APPLICABLE, and absent/unknown
support is UNSUPPORTED; none is a pass or an executable negative example.

The optional assessment :allow-omitted-final-semicolon takes only T or NIL,
defaulting to NIL (strict SML '97).  T explicitly selects MLton's batch EOF
convention: only a complete final declaration or interactive expression may
end at EOF without its final semicolon.  Other errors remain errors, and
source/oracle bytes are never changed.  The report records this grammar mode.

Fail assessments may specify :rejection as :SYNTAX, :ELABORATION, :BOTH,
:REPRESENTATION, or NIL (the default).  NIL accepts only genuine syntax or
static elaboration rejection; :BOTH admits either of those, never representation.
:REPRESENTATION requires SML-ELABORATION-ERROR with deliberate kind :RANGE.
The optional :expected-unbound-identifiers is a list of exact, case-sensitive
source names (including dotted long identifiers), defaulting to NIL.  With a
NIL/:ELABORATION/:BOTH expectation, only those reviewed bad source names can
turn a fail case's MISSING-PREREQUISITE into PASS.  Missing required Basis or
library identifiers never qualify.  Generic zero-answer elaboration is
COMPILER-ERROR; an unbound diagnostic without an exact normalized name is
UNKNOWN-PREREQUISITE.  Neither is a negative pass.  Unknown assessment keys or
malformed values are errors.

Normal/modules need a strict byte-matching .ok except when a .nonterm sidecar
is present, in which case the source is host-compiled but not executed.
Every nonterminate case is likewise host-compiled but never executed, whether
or not it has a sidecar: :compile-only is T and :execution is NOT-ATTEMPTED.
Neither compile-only route requires output oracle bytes.  Missing .ok after an
ordinary execution yields NO-ORACLE, not empty expected output.
Fail cases pass only on a classified deliberate source rejection, never on a
crash, timeout, or unbound required identifier.
An identified uncaught SML exception appends exactly 'Nonzero exit status.\\n'
as bytes to the non-Windows capture before comparison.  Workers exiting badly
are WORKER-ERROR, not SML nonzero status.  No EOL/whitespace normalization occurs.

Exit status: 0 for inventory, or when every selected execution passes; 1 when
any selected execution is not PASS; 2 for usage/configuration/guard failures.
The report enumerates all discovered cases and all outcome/classification counters.
An absent selected suite is SUITE-MISSING and makes --execute nonzero.
")

(defun %fail (control &rest arguments)
  (error "MLton runner: ~?" control arguments))

(defun %safe-read (stream &optional (eof-error-p t) eof-value)
  (let ((*read-eval* nil)
        (*package* (find-package :cl-user)))
    (read stream eof-error-p eof-value)))

(defun %read-one-form (path)
  "Read exactly one host-data form without READ-EVAL."
  (with-open-file (input path :direction :input :external-format :utf-8)
    (let ((end (gensym "END")))
      (let ((form (%safe-read input t nil)))
        (unless (eq end (%safe-read input nil end))
          (%fail "more than one form in ~A" path))
        form))))

(defun %write-form (path form)
  (ensure-directories-exist path)
  (with-open-file (output path :direction :output :if-exists :supersede
                               :if-does-not-exist :create :external-format :utf-8)
    (let ((*print-readably* t)
          (*print-pretty* t)
          (*print-circle* t))
      (write form :stream output)
      (terpri output))))

(defun %trim (string)
  (string-trim '(#\Space #\Tab #\Newline #\Return) string))

(defun %one-value (arguments option)
  (unless arguments
    (%fail "~A requires an argument" option))
  (first arguments))

(defun %positive-integer (string option)
  (let ((value (handler-case (parse-integer string :junk-allowed nil)
                 (error () (%fail "invalid ~A value ~S; expected a positive integer"
                                  option string)))))
    (unless (plusp value)
      (%fail "~A requires a positive integer, not ~S" option string))
    value))

(defun %suite (name)
  (cond ((string= name "normal") :normal)
        ((string= name "modules") :modules)
        ((string= name "fail") :fail)
        ((string= name "nonterminate") :nonterminate)
        (t (%fail "unknown suite ~S; expected normal, modules, fail, nonterminate, or all"
                  name))))

(defun %valid-selector-p (string)
  (and (plusp (length string))
       (every (lambda (character)
                (or (alphanumericp character)
                    (find character "-._" :test #'char=)))
              string)
       (not (member string '("." "..") :test #'string=))))

(defun %parse-options (arguments)
  (let ((options (list :help nil :execute nil :list nil :suites nil :cases nil
                       :assessments nil :oracle-selectors nil :corpus nil
                       :output-directory nil :report nil :lisp "sbcl" :timeout nil)))
    (loop while arguments
          for option = (pop arguments)
          do
             (cond
               ((string= option "--help")
                (setf (getf options :help) t)
                (return))
               ((string= option "--execute") (setf (getf options :execute) t))
               ((string= option "--list") (setf (getf options :list) t))
               ((string= option "--suite")
                (let ((value (%one-value arguments option)))
                  (pop arguments)
                  (if (string= value "all")
                      (setf (getf options :suites)
                            (append (getf options :suites)
                                    '(:normal :modules :fail :nonterminate)))
                      (setf (getf options :suites)
                            (append (getf options :suites) (list (%suite value)))))))
               ((string= option "--case")
                (let ((value (%one-value arguments option)))
                  (pop arguments)
                  (when (zerop (length value)) (%fail "--case cannot be empty"))
                  (setf (getf options :cases)
                        (append (getf options :cases) (list value)))))
               ((string= option "--assessments")
                (let ((value (%one-value arguments option)))
                  (pop arguments)
                  (setf (getf options :assessments)
                        (append (getf options :assessments) (list value)))))
               ((string= option "--oracle-selector")
                (let ((value (%one-value arguments option)))
                  (pop arguments)
                  (unless (%valid-selector-p value)
                    (%fail "unsafe oracle selector ~S; use only letters, digits, ., _, -"
                           value))
                  (setf (getf options :oracle-selectors)
                        (append (getf options :oracle-selectors) (list value)))))
               ((member option '("--corpus" "--output-directory" "--report" "--lisp" "--timeout")
                        :test #'string=)
                (let ((value (%one-value arguments option)))
                  (pop arguments)
                  (cond
                    ((string= option "--corpus") (setf (getf options :corpus) value))
                    ((string= option "--output-directory")
                     (setf (getf options :output-directory) value))
                    ((string= option "--report") (setf (getf options :report) value))
                    ((string= option "--lisp") (setf (getf options :lisp) value))
                    ((string= option "--timeout")
                     (setf (getf options :timeout)
                           (%positive-integer value option))))))
               (t (%fail "unknown option ~S (try --help)" option))))
    options))

(defun %repository-root ()
  (truename
   (merge-pathnames "../../" (uiop:pathname-directory-pathname *load-truename*))))

(defun %safe-relative-path (value label directoryp)
  "Generated paths are deliberately confined without resolving nonexistent paths."
  (when (zerop (length value))
    (%fail "~A cannot be empty" label))
  (let ((pathname (handler-case (parse-namestring value)
                    (error () (%fail "invalid ~A pathname ~S" label value)))))
    (labels ((bad-component-p (component)
               (member component '(:up :back :wild :wild-inferiors) :test #'eq)))
      (when (or (eq (first (pathname-directory pathname)) :absolute)
                (some #'bad-component-p (pathname-directory pathname))
                (eq :wild (pathname-name pathname))
                (eq :wild (pathname-type pathname))
                (member (pathname-name pathname) '("." "..") :test #'equal)
                (and (not directoryp) (null (pathname-name pathname))))
        (%fail "~A must be a relative path without '.', '..', wildcards, or backtracking: ~S"
               label value)))
    (if directoryp (uiop:ensure-directory-pathname pathname) pathname)))

(defun %generated-paths (options root)
  (let* ((base (merge-pathnames "build/sml/" root))
         (output (%safe-relative-path (or (getf options :output-directory) "mlton")
                                      "--output-directory" t))
         (report (%safe-relative-path (or (getf options :report) "report.sexp")
                                      "--report" nil))
         (output-directory (merge-pathnames output base))
         (report-path (merge-pathnames report output-directory))
         (cases-directory (merge-pathnames "cases/" output-directory)))
    (ensure-directories-exist (merge-pathnames "placeholder" base))
    (ensure-directories-exist report-path)
    (ensure-directories-exist (merge-pathnames "placeholder" cases-directory))
    (let ((base-true (truename base))
          (output-true (truename output-directory))
          (cases-true (truename cases-directory))
          (report-parent (truename (uiop:pathname-directory-pathname report-path))))
      (dolist (path (list output-true cases-true report-parent))
        (unless (uiop:subpathp path base-true)
          (%fail "generated paths must remain below ~A, not ~A" base-true path)))
      (values base-true output-true
              (merge-pathnames (file-namestring report-path) report-parent)
              cases-true))))

(defun %git (corpus arguments)
  (multiple-value-bind (output error-output status)
      (uiop:run-program (append (list "git" "-C" (namestring corpus)) arguments)
                        :output :string :error-output :string :ignore-error-status t)
    (unless (zerop status)
      (%fail "git ~{~A ~}failed in ~A (status ~D): ~A~A"
             arguments corpus status output error-output))
    (%trim output)))

(defun %guard-corpus (corpus)
  (let ((head (%git corpus '("--no-optional-locks" "rev-parse" "--verify" "HEAD"))))
    (unless (string= head +mlton-revision+)
      (%fail "MLton HEAD is ~A, expected pinned ~A" head +mlton-revision+)))
  (let ((tree (%git corpus (list "--no-optional-locks" "rev-parse"
                                 (concatenate 'string +mlton-revision+ ":regression")))))
    (unless (string= tree +mlton-regression-tree+)
      (%fail "MLton regression tree is ~A, expected ~A"
             tree +mlton-regression-tree+)))
  (let ((status (%git corpus '("--no-optional-locks" "status" "--porcelain=v1"
                               "--untracked-files=all" "--" "regression"))))
    (unless (zerop (length status))
      (%fail "MLton regression checkout is not clean; refusing to use it:~%~A" status)))
  t)

(defstruct (regression-case (:conc-name rc-))
  suite path source selected assessment)

(defun %suite-directory (suite regression)
  (ecase suite
    (:normal regression)
    (:modules (merge-pathnames "modules/" regression))
    (:fail (merge-pathnames "fail/" regression))
    (:nonterminate (merge-pathnames "nonterminate/" regression))))

(defun %suite-relative-path (suite pathname)
  (let ((name (file-namestring pathname)))
    (ecase suite
      (:normal name)
      (:modules (concatenate 'string "modules/" name))
      (:fail (concatenate 'string "fail/" name))
      (:nonterminate (concatenate 'string "nonterminate/" name)))))

(defun %discover-cases (corpus suites exact-cases)
  (let* ((regression (merge-pathnames "regression/" corpus))
         (missing-suites nil)
         (cases
           (loop for suite in '(:normal :modules :fail :nonterminate)
                 when (member suite suites :test #'eq)
                   append
                   (let ((directory (%suite-directory suite regression)))
                     (if (uiop:directory-exists-p directory)
                         (loop for source in (uiop:directory-files directory "*.sml")
                               for path = (%suite-relative-path suite source)
                               collect
                               (make-regression-case
                                :suite suite :path path :source source
                                :selected (or (null exact-cases)
                                              (member path exact-cases :test #'string=))))
                         (progn (push suite missing-suites) nil))))))
    (setf cases (sort cases #'string< :key #'rc-path))
    (dolist (selected exact-cases)
      (unless (find selected cases :key #'rc-path :test #'string=)
        (%fail "--case did not name a discovered .sml file in the selected suites: ~S"
               selected)))
    (values cases (nreverse missing-suites))))

(defun %proper-list-p (form)
  (handler-case (integerp (list-length form))
    (type-error () nil)))

(defun %plist-form-p (form)
  (and (%proper-list-p form)
       (evenp (length form))
       (loop for (key nil) on form by #'cddr always (keywordp key))))

(defun %string-list-p (value)
  (and (%proper-list-p value) (every #'stringp value)))

(defun %present-key-p (plist key)
  (loop for (candidate nil) on plist by #'cddr thereis (eq candidate key)))

(defun %validate-plist-keys (plist allowed path kind)
  (let ((seen (make-hash-table :test #'eq)))
    (loop for (key nil) on plist by #'cddr
          do (when (gethash key seen)
               (%fail "duplicate ~A key ~S in ~A" kind key path))
             (setf (gethash key seen) t)
             (unless (member key allowed :test #'eq)
               (%fail "unknown ~A key ~S in ~A" kind key path)))))

(defun %load-assessment-file (path table)
  (let ((form (%read-one-form path)))
    (unless (and (%plist-form-p form)
                 (eql 1 (getf form :assessment-version))
                 (%present-key-p form :cases)
                 (listp (getf form :cases)))
      (%fail "invalid assessment envelope in ~A" path))
    (%validate-plist-keys form '(:assessment-version :cases :description)
                          path "assessment-envelope")
    (when (and (%present-key-p form :description)
               (not (stringp (getf form :description))))
      (%fail "assessment :description must be a string in ~A" path))
    (dolist (assessment (getf form :cases))
      (unless (%plist-form-p assessment)
        (%fail "assessment in ~A is not a plist: ~S" path assessment))
      (%validate-plist-keys assessment
                            '(:path :language :basis :target :extensions
                              :applicable :supported :allow-omitted-final-semicolon
                              :rejection :expected-unbound-identifiers :notes)
                            path "assessment")
      (dolist (key '(:path :language :basis :target :extensions :applicable :supported))
        (unless (%present-key-p assessment key)
          (%fail "assessment ~S in ~A lacks required ~S" assessment path key)))
      (let ((case-path (getf assessment :path))
            (language (getf assessment :language))
            (basis (getf assessment :basis))
            (target (getf assessment :target))
            (extensions (getf assessment :extensions))
            (applicable (getf assessment :applicable))
            (supported (getf assessment :supported))
            (allow-omitted (getf assessment :allow-omitted-final-semicolon))
            (rejection (getf assessment :rejection))
            (expected-unbound (getf assessment :expected-unbound-identifiers))
            (notes (getf assessment :notes)))
        (unless (and (stringp case-path) (plusp (length case-path)))
          (%fail "invalid assessment :path in ~A" path))
        (unless (and (%string-list-p language) language)
          (%fail "assessment ~A requires nonempty :language string list" case-path))
        (unless (and (%string-list-p basis) (%string-list-p target)
                     (%string-list-p extensions))
          (%fail "assessment ~A requires :basis/:target/:extensions string lists" case-path))
        (unless (member applicable '(t nil) :test #'eq)
          (%fail "assessment ~A :applicable must be T or NIL" case-path))
        (unless (member supported '(t nil :unknown) :test #'eq)
          (%fail "assessment ~A :supported must be T, NIL, or :UNKNOWN" case-path))
        (unless (member allow-omitted '(t nil) :test #'eq)
          (%fail "assessment ~A :allow-omitted-final-semicolon must be T or NIL"
                 case-path))
        (unless (member rejection '(nil :syntax :elaboration :both :representation)
                        :test #'eq)
          (%fail "assessment ~A :rejection must be NIL, :SYNTAX, :ELABORATION, :BOTH, or :REPRESENTATION"
                 case-path))
        (unless (%string-list-p expected-unbound)
          (%fail "assessment ~A :expected-unbound-identifiers must be a string list"
                 case-path))
        (unless (or (null notes) (stringp notes))
          (%fail "assessment ~A :notes must be a string when present" case-path))
        (when (gethash case-path table)
          (%fail "duplicate assessment for ~A" case-path))
        (setf (gethash case-path table) assessment)))
    table))

(defun %attach-assessments (cases paths)
  (let ((table (make-hash-table :test #'equal)))
    (dolist (path paths table)
      (%load-assessment-file path table))
    (dolist (case cases table)
      (setf (rc-assessment case) (gethash (rc-path case) table)))
    table))

(defun %classification (case)
  (let ((assessment (rc-assessment case)))
    (cond ((null assessment) :unclassified)
          ((null (getf assessment :applicable)) :not-applicable)
          ((eq t (getf assessment :supported)) :eligible)
          (t :unsupported))))

(defun %sidecar (source type &optional selector)
  (make-pathname :name (if selector
                           (format nil "~A.~A" (pathname-name source) selector)
                           (pathname-name source))
                 :type type :defaults source))

(defun %readable-binary-file-p (path)
  (handler-case
      (with-open-file (input path :direction :input :element-type '(unsigned-byte 8))
        (declare (ignore input))
        t)
    (file-error () nil)))

(defun %select-oracle (case selectors)
  "Mirror MLton's base gate and ordered last-readable-override chain."
  (let ((base (%sidecar (rc-source case) "ok")))
    (when (%readable-binary-file-p base)
      (let ((selected base))
        (dolist (selector selectors selected)
          (let ((candidate (%sidecar (rc-source case) "ok" selector)))
            (when (%readable-binary-file-p candidate)
              (setf selected candidate))))))))

(defun %artifact-stem (case index)
  (with-output-to-string (output)
    (format output "~4,'0D-" index)
    (loop for character across (rc-path case)
          do (write-char (if (or (alphanumericp character)
                                 (find character ".-" :test #'char=))
                             character #\_)
                         output))))

(defun %artifact (directory stem suffix)
  (merge-pathnames (concatenate 'string stem suffix) directory))

(defun %wait-child (process timeout)
  (if (null timeout)
      (values :exited (uiop:wait-process process))
      (let ((deadline (+ (get-internal-real-time)
                         (* timeout internal-time-units-per-second))))
        (loop
          (unless (uiop:process-alive-p process)
            (return (values :exited (uiop:wait-process process))))
          (when (>= (get-internal-real-time) deadline)
            (uiop:terminate-process process :urgent t)
            (uiop:wait-process process)
            (return (values :timeout nil)))
          (sleep 0.05)))))

(defun %response-valid-p (response case)
  (let ((assessment (rc-assessment case)))
    (and (%plist-form-p response)
         (eql 1 (getf response :response-version))
         (equal (rc-path case) (getf response :case))
         (eq (getf assessment :rejection) (getf response :rejection))
         (equal (getf assessment :expected-unbound-identifiers)
                (getf response :expected-unbound-identifiers))
         (keywordp (getf response :terminal)))))

(defun %append-nonzero-marker (path)
  ;; Never insert a separator: unterminated SML output joins this marker,
  ;; exactly as in the non-Windows upstream runner.
  (with-open-file (output path :direction :output :if-exists :append
                               :if-does-not-exist :create
                               :element-type '(unsigned-byte 8))
    (write-sequence +nonzero-marker+ output)))

(defun %compare-binary (expected actual)
  "Return comparison data; no character decoding or EOL normalization occurs."
  (handler-case
      (with-open-file (left expected :direction :input :element-type '(unsigned-byte 8))
        (with-open-file (right actual :direction :input :element-type '(unsigned-byte 8))
          (loop for offset from 0
                for expected-byte = (read-byte left nil :eof)
                for actual-byte = (read-byte right nil :eof)
                do
                   (cond
                     ((and (eq :eof expected-byte) (eq :eof actual-byte))
                      (return (list :status :equal :bytes offset)))
                     ((or (eq :eof expected-byte) (eq :eof actual-byte)
                          (/= expected-byte actual-byte))
                      (return (list :status :mismatch :offset offset
                                    :expected-byte expected-byte
                                    :actual-byte actual-byte)))))))
    (file-error (condition)
      (list :status :oracle-error :message (princ-to-string condition)))))

(defun %report-pathname (path root)
  (enough-namestring path root))

(defun %base-case-report (case index options regression)
  ;; The retained README defines nonterminate/ as compile-but-do-not-run.  This
  ;; input policy does not depend on a sidecar or on observing attempted output.
  (let* ((assessment (rc-assessment case))
         (compile-only (or (eq :nonterminate (rc-suite case))
                           (and (probe-file (%sidecar (rc-source case) "nonterm")) t)))
         (oracle (%select-oracle case (getf options :oracle-selectors))))
    (list :suite (rc-suite case) :path (rc-path case) :index index
          :selected (and (rc-selected case) t)
          :classification (%classification case)
          :assessment-present (and assessment t)
          :applicable (and assessment (getf assessment :applicable))
          :supported (and assessment (getf assessment :supported))
          :source-mode (if (and assessment
                                (getf assessment :allow-omitted-final-semicolon))
                           :mlton-batch-eof
                           :sml97-strict)
          :rejection (and assessment (getf assessment :rejection))
          :expected-unbound-identifiers
          (and assessment (getf assessment :expected-unbound-identifiers))
          :prerequisites (and assessment
                              (list :language (getf assessment :language)
                                    :basis (getf assessment :basis)
                                    :target (getf assessment :target)
                                    :extensions (getf assessment :extensions)))
          :notes (and assessment (getf assessment :notes))
          :compile-only compile-only
          :oracle (and oracle (%report-pathname oracle regression)))))

(defun %display-result (report)
  (format t "~&~A ~A ~A~@[ oracle=~A~]~%"
          (string-upcase (symbol-name (getf report :outcome)))
          (string-downcase (symbol-name (getf report :suite)))
          (getf report :path)
          (getf report :oracle)))

(defun %frontend-rejection-category (response)
  (let ((frontend (getf response :parse/elaboration)))
    (and (%plist-form-p frontend)
         (getf frontend :rejection-category))))

(defun %matching-source-rejection-p (case response)
  "True only for an assessed fail case with the reviewed condition category."
  (and (eq :fail (rc-suite case))
       (eq :eligible (%classification case))
       (let ((expected (getf (rc-assessment case) :rejection))
             (actual (%frontend-rejection-category response)))
         (case expected
           ((nil) (member actual '(:syntax :elaboration) :test #'eq))
           (:syntax (eq :syntax actual))
           (:elaboration (eq :elaboration actual))
           (:both (member actual '(:syntax :elaboration) :test #'eq))
           (:representation (eq :representation actual))
           (otherwise nil)))))

(defun %matching-unbound-rejection-p (case response)
  "Recognize only a source-reviewed unbound name, not a missing library name."
  (and (eq :fail (rc-suite case))
       (eq :eligible (%classification case))
       (member (getf (rc-assessment case) :rejection)
               '(nil :elaboration :both) :test #'eq)
       (eq :elaboration (%frontend-rejection-category response))
       (let ((frontend (getf response :parse/elaboration)))
         (and (%plist-form-p frontend)
              (let ((identifier (getf frontend :unbound-identifier)))
                (and (stringp identifier)
                     (member identifier
                             (getf (rc-assessment case)
                                   :expected-unbound-identifiers)
                             :test #'string=)))))))

(defun %run-case (base case options regression cases-directory generated-root)
  (let* ((index (getf base :index))
         (stem (%artifact-stem case index))
         (request-path (%artifact cases-directory stem ".request.sexp"))
         (response-path (%artifact cases-directory stem ".response.sexp"))
         (worker-stdout (%artifact cases-directory stem ".worker.stdout"))
         (worker-stderr (%artifact cases-directory stem ".worker.stderr"))
         (output-path (%artifact cases-directory stem ".output"))
         (script (merge-pathnames "tools/sml/mlton-worker.lisp" (%repository-root))))
    (setf (getf base :output) (%report-pathname output-path generated-root)
          (getf base :worker-stdout) (%report-pathname worker-stdout generated-root)
          (getf base :worker-stderr) (%report-pathname worker-stderr generated-root))
    ;; Truncate every capture before launch so a failed earlier phase can never
    ;; expose a previous invocation's output as this case's observation.
    (with-open-file (output output-path :direction :output :if-exists :supersede
                                        :if-does-not-exist :create
                                        :element-type '(unsigned-byte 8))
      (declare (ignore output)))
    (%write-form request-path
                 (list :request-version 1 :case (rc-path case)
                       :suite (rc-suite case)
                       :allow-omitted-final-semicolon
                       (and (getf (rc-assessment case)
                                  :allow-omitted-final-semicolon)
                            t)
                       :rejection (getf (rc-assessment case) :rejection)
                       :expected-unbound-identifiers
                       (getf (rc-assessment case) :expected-unbound-identifiers)
                       :source (namestring (rc-source case))
                       :working-directory (namestring regression)
                       :output (namestring output-path)
                       :nonterm (getf base :compile-only)))
    (let* ((command (list (getf options :lisp) "--script" (namestring script)
                          (namestring request-path) (namestring response-path)))
           (process
             (handler-case
                 (uiop:launch-program command :input :interactive
                                      :output worker-stdout :if-output-exists :supersede
                                      :error-output worker-stderr
                                      :if-error-output-exists :supersede)
               (error (condition)
                 (return-from %run-case
                   (append base (list :outcome :worker-error
                                      :worker (list :status :launch-error
                                                    :message (princ-to-string condition)))))))))
      (multiple-value-bind (wait-status code)
          (%wait-child process (getf options :timeout))
        (when (eq wait-status :timeout)
          (return-from %run-case
            (append base (list :outcome :timeout
                               :worker (list :status :timeout :exit-code nil)))))
        (unless (and (integerp code) (zerop code))
          (return-from %run-case
            (append base (list :outcome :worker-error
                               :worker (list :status :bad-exit :exit-code code)))))
        (let ((response
                (handler-case (%read-one-form response-path)
                  (error (condition)
                    (return-from %run-case
                      (append base (list :outcome :worker-error
                                         :worker (list :status :invalid-response
                                                       :exit-code code
                                                       :message (princ-to-string condition)))))))))
          (unless (%response-valid-p response case)
            (return-from %run-case
              (append base (list :outcome :worker-error
                                 :worker (list :status :invalid-response :exit-code code)))))
          (let ((terminal (getf response :terminal)))
            (case terminal
              (:missing-prerequisite
               (return-from %run-case
                 (append base
                         (list :outcome (if (%matching-unbound-rejection-p case response)
                                            :pass :missing-prerequisite)
                               :worker (list :status :exited :exit-code code)
                               :phases response))))
              ((:input-error :unknown-prerequisite :compiler-error
                :host-compilation-error :execution-error)
               (return-from %run-case
                 (append base (list :outcome terminal :worker
                                    (list :status :exited :exit-code code)
                                    :phases response))))
              (:accepted
               ;; The worker stops immediately after frontend acceptance only
               ;; for a fail case, so this is an unexpected negative acceptance.
               (return-from %run-case
                 (append base (list :outcome :unexpected-acceptance :worker
                                    (list :status :exited :exit-code code)
                                    :phases response))))
              (:source-rejected
               (return-from %run-case
                 (append base
                         (list :outcome (if (%matching-source-rejection-p case response)
                                            :pass :unexpected-rejection)
                               :worker (list :status :exited :exit-code code)
                               :phases response))))
              (:compiled
               (return-from %run-case
                 (append base
                         (list :outcome (if (getf base :compile-only)
                                            :pass :host-compilation-error)
                               :worker (list :status :exited :exit-code code)
                               :oracle-comparison (list :status :not-applicable
                                                        :reason :compile-only)
                               :phases response))))
              ((:executed :sml-nonzero)
               (when (eq terminal :sml-nonzero)
                 (when (uiop:os-windows-p)
                   (return-from %run-case
                     (append base (list :outcome :unsupported-host
                                        :worker (list :status :exited :exit-code code)
                                        :phases response))))
                 (handler-case (%append-nonzero-marker output-path)
                   (file-error (condition)
                     (return-from %run-case
                       (append base (list :outcome :output-error
                                          :message (princ-to-string condition)
                                          :worker (list :status :exited :exit-code code)
                                          :phases response))))))
               (let ((oracle (%select-oracle case (getf options :oracle-selectors))))
                 (unless oracle
                   (return-from %run-case
                     (append base (list :outcome :no-oracle
                                        :worker (list :status :exited :exit-code code)
                                        :oracle-comparison (list :status :missing)
                                        :phases response))))
                 (let ((comparison (%compare-binary oracle output-path)))
                   (return-from %run-case
                     (append base
                             (list :outcome (case (getf comparison :status)
                                              (:equal :pass)
                                              (:mismatch :mismatch)
                                              (otherwise :oracle-error))
                                   :worker (list :status :exited :exit-code code)
                                   :oracle-comparison comparison
                                   :phases response))))))
              (otherwise
               (return-from %run-case
                 (append base (list :outcome :worker-error
                                    :worker (list :status :unknown-terminal
                                                  :terminal terminal :exit-code code)
                                    :phases response)))))))))))

(defun %inventory-result (base case execute)
  (let ((classification (getf base :classification)))
    (append base
            (list :outcome
                  (cond
                    ((not (rc-selected case)) :not-selected)
                    ((eq classification :unclassified) :unclassified)
                    ((eq classification :not-applicable) :not-applicable)
                    ((eq classification :unsupported) :unsupported)
                    ((not execute) :not-executed)
                    (t (%fail "internal error: executable case reached inventory path")))))))

(defun %field-counts (reports field)
  (let ((table (make-hash-table :test #'eq)))
    (dolist (report reports)
      (incf (gethash (getf report field) table 0)))
    (sort (loop for value being the hash-keys of table using (hash-value count)
                collect (cons value count))
          #'string< :key (lambda (entry) (symbol-name (car entry))))))

(defun %outcome-counts (reports)
  (%field-counts reports :outcome))

(defun %summary (reports)
  (let ((selected (count-if (lambda (report) (getf report :selected)) reports))
        (passed (count-if (lambda (report)
                            (and (getf report :selected) (eq :pass (getf report :outcome))))
                          reports)))
    (list :discovered (length reports) :selected selected :passed passed
          :nonpass-selected (- selected passed))))

(defun main (&rest arguments)
  (handler-case
      (let* ((options (%parse-options arguments))
             (root (%repository-root)))
        (when (getf options :help)
          (write-string +usage+)
          (return-from main 0))
        (when (and (getf options :list) (getf options :execute))
          (%fail "--list and --execute are mutually exclusive"))
        (when (and (getf options :execute) (null (getf options :assessments)))
          (%fail "--execute requires at least one --assessments file"))
        (when (and (getf options :execute) (uiop:os-windows-p))
          (%fail "execution currently implements the non-Windows raw-output protocol only"))
        (multiple-value-bind (generated-root output-directory report-path cases-directory)
            (%generated-paths options root)
          (declare (ignore output-directory))
          (let* ((corpus (uiop:ensure-directory-pathname
                          (parse-namestring (or (getf options :corpus)
                                                (namestring (merge-pathnames "build/mlton/" root))))))
                 (suites (remove-duplicates (or (getf options :suites) '(:normal))
                                            :test #'eq :from-end t))
                 (exact-cases (remove-duplicates (getf options :cases)
                                                 :test #'string= :from-end t))
                 (execute (getf options :execute)))
            (unless (uiop:directory-exists-p corpus)
              (%fail "MLton corpus directory does not exist: ~A" corpus))
            (setf corpus (uiop:ensure-directory-pathname (truename corpus)))
            (%guard-corpus corpus)
            (let ((regression (merge-pathnames "regression/" corpus)))
              (multiple-value-bind (cases missing-suites)
                  (%discover-cases corpus suites exact-cases)
                (dolist (suite missing-suites)
                  (format t "~&SUITE-MISSING ~A (directory absent in pinned checkout)~%"
                          (string-downcase (symbol-name suite))))
                (%attach-assessments cases (getf options :assessments))
                (let ((reports
                        (loop for case in cases
                              for index from 0
                              for base = (%base-case-report case index options regression)
                              for result = (if (and execute (rc-selected case)
                                                    (eq :eligible (%classification case)))
                                               (%run-case base case options regression
                                                          cases-directory generated-root)
                                               (%inventory-result base case execute))
                              do (%display-result result)
                              collect result)))
                  (%guard-corpus corpus)
                  (let* ((summary (append (%summary reports)
                                          (list :missing-suites (length missing-suites))))
                         (report
                           (list :report-version 1
                                 :tool "optional-mlton-runner"
                                 :mode (if execute :execute :inventory)
                                 :mlton-revision +mlton-revision+
                                 :mlton-regression-tree +mlton-regression-tree+
                                 :license "HPND; see LICENSE and doc/license/ in the pinned checkout"
                                 :configuration
                                 (list :corpus (namestring corpus)
                                       :lisp (getf options :lisp)
                                       :suites suites :cases exact-cases
                                       :assessments (getf options :assessments)
                                       :oracle-selectors (getf options :oracle-selectors)
                                       :timeout (getf options :timeout)
                                       :post-run-clean-guard t)
                                 :summary summary
                                 :missing-suites missing-suites
                                 :outcomes (%outcome-counts reports)
                                 :classifications (%field-counts reports :classification)
                                 :cases reports)))
                    (%write-form report-path report)
                    (format t "~&REPORT ~A~%SUMMARY ~S~%"
                            (%report-pathname report-path root) summary)
                    (if (or (not execute)
                            (and (null missing-suites)
                                 (zerop (getf summary :nonpass-selected))))
                        0 1))))))))
    (error (condition)
      (format *error-output* "~&~A~%" condition)
      2)))

(uiop:quit (apply #'main (uiop:command-line-arguments)))
