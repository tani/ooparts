;;; Generated namespace declarations; see tools/curry/generate-cl.py.
(uiop:define-package #:ooparts/curry/user
  (:use #:cl)
  (:import-from #:ooparts/curry #:curry #:uncurried-function)
  (:import-from #:ooparts/curry/catalog #:*cl-functions*)
  (:shadow
    #:* #:+ #:- #:/ #:/= #:1+ #:1-
    #:< #:<= #:= #:> #:>= #:abort #:abs
    #:acons #:acos #:acosh #:add-method #:adjoin #:adjust-array #:adjustable-array-p
    #:allocate-instance #:alpha-char-p #:alphanumericp #:append #:apply #:apropos #:apropos-list
    #:aref #:arithmetic-error-operands #:arithmetic-error-operation #:array-dimension #:array-dimensions #:array-displacement #:array-element-type
    #:array-has-fill-pointer-p #:array-in-bounds-p #:array-rank #:array-row-major-index #:array-total-size #:arrayp #:ash
    #:asin #:asinh #:assoc #:assoc-if #:assoc-if-not #:atan #:atanh
    #:atom #:bit #:bit-and #:bit-andc1 #:bit-andc2 #:bit-eqv #:bit-ior
    #:bit-nand #:bit-nor #:bit-not #:bit-orc1 #:bit-orc2 #:bit-vector-p #:bit-xor
    #:boole #:both-case-p #:boundp #:break #:broadcast-stream-streams #:butlast #:byte
    #:byte-position #:byte-size #:caaaar #:caaadr #:caaar #:caadar #:caaddr
    #:caadr #:caar #:cadaar #:cadadr #:cadar #:caddar #:cadddr
    #:caddr #:cadr #:car #:cdaaar #:cdaadr #:cdaar #:cdadar
    #:cdaddr #:cdadr #:cdar #:cddaar #:cddadr #:cddar #:cdddar
    #:cddddr #:cdddr #:cddr #:cdr #:ceiling #:cell-error-name #:cerror
    #:change-class #:char #:char-code #:char-downcase #:char-equal #:char-greaterp #:char-int
    #:char-lessp #:char-name #:char-not-equal #:char-not-greaterp #:char-not-lessp #:char-upcase #:char/=
    #:char< #:char<= #:char= #:char> #:char>= #:character #:characterp
    #:cis #:class-name #:class-of #:clear-input #:clear-output #:close #:clrhash
    #:code-char #:coerce #:compile #:compile-file #:compile-file-pathname #:compiled-function-p #:compiler-macro-function
    #:complement #:complex #:complexp #:compute-applicable-methods #:compute-restarts #:concatenate #:concatenated-stream-streams
    #:conjugate #:cons #:consp #:constantly #:constantp #:continue #:copy-alist
    #:copy-list #:copy-pprint-dispatch #:copy-readtable #:copy-seq #:copy-structure #:copy-symbol #:copy-tree
    #:cos #:cosh #:count #:count-if #:count-if-not #:decode-float #:decode-universal-time
    #:defclass #:defgeneric #:define-condition #:defmethod #:defstruct #:defun #:delete
    #:delete-duplicates #:delete-file #:delete-if #:delete-if-not #:delete-package #:denominator #:deposit-field
    #:describe #:describe-object #:digit-char #:digit-char-p #:directory #:directory-namestring #:disassemble
    #:documentation #:dpb #:dribble #:echo-stream-input-stream #:echo-stream-output-stream #:ed #:eighth
    #:elt #:encode-universal-time #:endp #:enough-namestring #:ensure-directories-exist #:ensure-generic-function #:eq
    #:eql #:equal #:equalp #:error #:eval #:evenp #:every
    #:exp #:export #:expt #:fboundp #:fceiling #:fdefinition #:ffloor
    #:fifth #:file-author #:file-error-pathname #:file-length #:file-namestring #:file-position #:file-string-length
    #:file-write-date #:fill #:fill-pointer #:find #:find-all-symbols #:find-class #:find-if
    #:find-if-not #:find-method #:find-package #:find-restart #:find-symbol #:finish-output #:first
    #:flet #:float #:float-digits #:float-precision #:float-radix #:float-sign #:floatp
    #:floor #:fmakunbound #:force-output #:format #:fourth #:fresh-line #:fround
    #:ftruncate #:funcall #:function #:function-keywords #:function-lambda-expression #:functionp #:gcd
    #:gensym #:gentemp #:get #:get-decoded-time #:get-dispatch-macro-character #:get-internal-real-time #:get-internal-run-time
    #:get-macro-character #:get-output-stream-string #:get-properties #:get-setf-expansion #:get-universal-time #:getf #:gethash
    #:graphic-char-p #:hash-table-count #:hash-table-p #:hash-table-rehash-size #:hash-table-rehash-threshold #:hash-table-size #:hash-table-test
    #:host-namestring #:identity #:imagpart #:import #:initialize-instance #:input-stream-p #:inspect
    #:integer-decode-float #:integer-length #:integerp #:interactive-stream-p #:intern #:intersection #:invalid-method-error
    #:invoke-debugger #:invoke-restart #:invoke-restart-interactively #:isqrt #:keywordp #:labels #:lambda
    #:last #:lcm #:ldb #:ldb-test #:ldiff #:length #:lisp-implementation-type
    #:lisp-implementation-version #:list #:list* #:list-all-packages #:list-length #:listen #:listp
    #:load #:load-logical-pathname-translations #:log #:logand #:logandc1 #:logandc2 #:logbitp
    #:logcount #:logeqv #:logical-pathname #:logical-pathname-translations #:logior #:lognand #:lognor
    #:lognot #:logorc1 #:logorc2 #:logtest #:logxor #:long-site-name #:lower-case-p
    #:machine-instance #:machine-type #:machine-version #:macro-function #:macroexpand #:macroexpand-1 #:make-array
    #:make-broadcast-stream #:make-concatenated-stream #:make-condition #:make-dispatch-macro-character #:make-echo-stream #:make-hash-table #:make-instance
    #:make-instances-obsolete #:make-list #:make-load-form #:make-load-form-saving-slots #:make-package #:make-pathname #:make-random-state
    #:make-sequence #:make-string #:make-string-input-stream #:make-string-output-stream #:make-symbol #:make-synonym-stream #:make-two-way-stream
    #:makunbound #:map #:map-into #:mapc #:mapcan #:mapcar #:mapcon
    #:maphash #:mapl #:maplist #:mask-field #:max #:member #:member-if
    #:member-if-not #:merge #:merge-pathnames #:method-combination-error #:method-qualifiers #:min #:minusp
    #:mismatch #:mod #:muffle-warning #:name-char #:namestring #:nbutlast #:nconc
    #:nintersection #:ninth #:no-applicable-method #:no-next-method #:not #:notany #:notevery
    #:nreconc #:nreverse #:nset-difference #:nset-exclusive-or #:nstring-capitalize #:nstring-downcase #:nstring-upcase
    #:nsublis #:nsubst #:nsubst-if #:nsubst-if-not #:nsubstitute #:nsubstitute-if #:nsubstitute-if-not
    #:nth #:nthcdr #:null #:numberp #:numerator #:nunion #:oddp
    #:open #:open-stream-p #:output-stream-p #:package-error-package #:package-name #:package-nicknames #:package-shadowing-symbols
    #:package-use-list #:package-used-by-list #:packagep #:pairlis #:parse-integer #:parse-namestring #:pathname
    #:pathname-device #:pathname-directory #:pathname-host #:pathname-match-p #:pathname-name #:pathname-type #:pathname-version
    #:pathnamep #:peek-char #:phase #:plusp #:position #:position-if #:position-if-not
    #:pprint #:pprint-dispatch #:pprint-fill #:pprint-indent #:pprint-linear #:pprint-newline #:pprint-tab
    #:pprint-tabular #:prin1 #:prin1-to-string #:princ #:princ-to-string #:print #:print-not-readable-object
    #:print-object #:probe-file #:proclaim #:provide #:random #:random-state-p #:rassoc
    #:rassoc-if #:rassoc-if-not #:rational #:rationalize #:rationalp #:read #:read-byte
    #:read-char #:read-char-no-hang #:read-delimited-list #:read-from-string #:read-line #:read-preserving-whitespace #:read-sequence
    #:readtable-case #:readtablep #:realp #:realpart #:reduce #:reinitialize-instance #:rem
    #:remhash #:remove #:remove-duplicates #:remove-if #:remove-if-not #:remove-method #:remprop
    #:rename-file #:rename-package #:replace #:require #:rest #:restart-name #:revappend
    #:reverse #:room #:round #:row-major-aref #:rplaca #:rplacd #:sbit
    #:scale-float #:schar #:search #:second #:set #:set-difference #:set-dispatch-macro-character
    #:set-exclusive-or #:set-macro-character #:set-pprint-dispatch #:set-syntax-from-char #:seventh #:shadow #:shadowing-import
    #:shared-initialize #:short-site-name #:signal #:signum #:simple-bit-vector-p #:simple-condition-format-arguments #:simple-condition-format-control
    #:simple-string-p #:simple-vector-p #:sin #:sinh #:sixth #:sleep #:slot-boundp
    #:slot-exists-p #:slot-makunbound #:slot-missing #:slot-unbound #:slot-value #:software-type #:software-version
    #:some #:sort #:special-operator-p #:sqrt #:stable-sort #:standard-char-p #:store-value
    #:stream-element-type #:stream-error-stream #:stream-external-format #:streamp #:string #:string-capitalize #:string-downcase
    #:string-equal #:string-greaterp #:string-left-trim #:string-lessp #:string-not-equal #:string-not-greaterp #:string-not-lessp
    #:string-right-trim #:string-trim #:string-upcase #:string/= #:string< #:string<= #:string=
    #:string> #:string>= #:stringp #:sublis #:subseq #:subsetp #:subst
    #:subst-if #:subst-if-not #:substitute #:substitute-if #:substitute-if-not #:subtypep #:svref
    #:sxhash #:symbol-function #:symbol-name #:symbol-package #:symbol-plist #:symbol-value #:symbolp
    #:synonym-stream-symbol #:tailp #:tan #:tanh #:tenth #:terpri #:third
    #:translate-logical-pathname #:translate-pathname #:tree-equal #:truename #:truncate #:two-way-stream-input-stream #:two-way-stream-output-stream
    #:type-error-datum #:type-error-expected-type #:type-of #:typep #:unbound-slot-instance #:unexport #:unintern
    #:union #:unread-char #:unuse-package #:update-instance-for-different-class #:update-instance-for-redefined-class #:upgraded-array-element-type #:upgraded-complex-part-type
    #:upper-case-p #:use-package #:use-value #:user-homedir-pathname #:values #:values-list #:vector
    #:vector-pop #:vector-push #:vector-push-extend #:vectorp #:warn #:wild-pathname-p #:write
    #:write-byte #:write-char #:write-line #:write-sequence #:write-string #:write-to-string #:y-or-n-p
    #:yes-or-no-p #:zerop)
  (:export #:enter #:*curried-readtable* #:curry #:uncurried-function))
(in-package #:ooparts/curry/user)

;; Qualify bootstrap code: this package deliberately replaces CL function names.
(cl:eval-when (:compile-toplevel :load-toplevel :execute)
  (cl:dolist (entry *cl-functions*)
    (cl:destructuring-bind (name required) entry
      (cl:let ((public (cl:intern name (cl:find-package :ooparts/curry/user)))
               (wrapper (cl:find-symbol (cl:concatenate 'cl:string name "/C") :ooparts/curry)))
        (cl:setf (cl:fdefinition public) (cl:fdefinition wrapper))
        (ooparts/curry/core::%record-wrapper public (cl:find-symbol name :cl) required)
        (cl:eval `(cl:declaim (cl:ftype (cl:function (cl:&rest cl:t) cl:*) ,public)))
        (cl:eval `(cl:define-setf-expander ,public (cl:&rest forms cl:&environment environment)
                    (cl:get-setf-expansion (cl:cons ',(cl:find-symbol name :cl) forms) environment))))))
  (cl:dolist (name '("DEFUN" "FLET" "LABELS" "LAMBDA" "DEFGENERIC" "DEFMETHOD"
                    "DEFCLASS" "DEFSTRUCT" "DEFINE-CONDITION"))
    (cl:let ((public (cl:intern name (cl:find-package :ooparts/curry/user)))
             (wrapper (cl:find-symbol (cl:concatenate 'cl:string name "/C") :ooparts/curry)))
      (cl:setf (cl:macro-function public)
               (cl:lambda (form environment)
                 (cl:macroexpand-1 (cl:cons wrapper (cl:cdr form)) environment)))))
  ;; Preserve standard type and class meanings for names that are also functions.
  (cl:dolist (name '("ATOM" "BIT" "CHARACTER" "COMPLEX" "CONS" "EQL" "FLOAT"
                    "FUNCTION" "LIST" "MEMBER" "MOD" "NOT" "NULL" "STRING" "VALUES" "VECTOR"))
    (cl:let ((public (cl:intern name (cl:find-package :ooparts/curry/user)))
             (native (cl:find-symbol name :cl)))
      (cl:eval `(cl:deftype ,public (cl:&rest parameters)
                  (cl:if parameters (cl:cons ',native parameters) ',native)))
      ))
  (cl:setf (cl:macro-function 'function)
           (cl:lambda (form environment)
             (cl:declare (cl:ignore environment))
             (cl:let ((argument (cl:second form)))
               (cl:if (cl:and (cl:consp argument) (cl:eq (cl:car argument) 'lambda))
                      (cl:cons 'ooparts/curry:lambda/c (cl:cdr argument))
                      (cl:list 'cl:function argument)))))
  (cl:do-external-symbols (native :cl)
    (cl:export (cl:list (cl:find-symbol (cl:symbol-name native) :ooparts/curry/user))
               :ooparts/curry/user)))

(cl:defvar *curried-readtable* (cl:copy-readtable cl:nil))
(cl:set-dispatch-macro-character
 #\# #\'
 (cl:lambda (stream sub-character numeric-argument)
   (cl:declare (cl:ignore sub-character))
   (cl:when numeric-argument (cl:error "A numeric prefix is invalid for #'."))
   (cl:let ((form (cl:read stream cl:t cl:nil cl:t)))
     (cl:if (cl:and (cl:consp form) (cl:eq (cl:car form) 'lambda))
            (cl:cons 'ooparts/curry:lambda/c (cl:cdr form))
            (cl:list 'cl:function form))))
 *curried-readtable*)

(cl:defun enter ()
  "Select the curried user package and its readtable in the current dynamic scope."
  (cl:setf cl:*package* (cl:find-package :ooparts/curry/user)
           cl:*readtable* *curried-readtable*)
  cl:*package*)
