(uiop:define-package #:ooparts-tests/sml/parser
  (:use #:cl)
  (:import-from #:ooparts/test #:with-suite #:check)
  (:import-from #:ooparts/sml/source
    #:sml-syntax-error #:sml-error-span #:source-span-start #:source-span-end
    #:position-offset #:position-line #:position-column)
  (:import-from #:ooparts/sml/syntax
    #:ast-node-p #:ast-node-kind #:ast-ref #:ast-node-span #:ast-node-slots
    #:identifier-name)
  (:import-from #:ooparts/sml/parser
    #:initial-fixity-environment #:fixity-lookup #:infix-identifier-p
    #:parse-program #:parse-expression #:parse-declaration
    #:parse-structure-expression #:parse-signature-expression #:parse-specification)
  (:export #:run-parser-tests))
(in-package #:ooparts-tests/sml/parser)

(defun %parses (parser text)
  (let ((value (funcall parser text)))
    (check (ast-node-p value) "Parser returned a non-AST value for ~S." text)
    (%check-positioned value)
    value))

(defun %rejects (parser text)
  (handler-case
      (progn (funcall parser text)
             (check nil "Expected syntax rejection for ~S." text))
    (sml-syntax-error (condition)
      (let ((end (source-span-end (sml-error-span condition))))
        (check (and (plusp (position-line end)) (plusp (position-column end)))
               "Invalid diagnostic position for ~S." text))
      t)))

(defun %kind (value key expected)
  (let ((node (if key (ast-ref value key) value)))
    (check (and (ast-node-p node) (eq expected (ast-node-kind node)))
           "Expected ~S node, got ~S." expected node)))

(defun %check-positioned (value)
  (cond
    ((ast-node-p value)
     (check (and (eq :node (first value)) (= 4 (length value))
                 (listp (fourth value)))
            "AST is not a direct native-list term: ~S." value)
     (let* ((span (ast-node-span value))
            (start (source-span-start span))
            (end (source-span-end span)))
       (check (and (<= (position-offset start) (position-offset end))
                   (plusp (position-line start)) (plusp (position-column start)))
              "Invalid AST source span for ~S." value))
     (dolist (entry (ast-node-slots value))
       (%check-positioned (cdr entry))))
    ((consp value)
     (%check-positioned (car value))
     (%check-positioned (cdr value)))))

(defun %find-kind (value kind)
  (cond
    ((ast-node-p value)
     (if (eq kind (ast-node-kind value))
         value
         (dolist (entry (ast-node-slots value))
           (let ((found (%find-kind (cdr entry) kind)))
             (when found (return found))))))
    ((consp value)
     (or (%find-kind (car value) kind) (%find-kind (cdr value) kind)))))

(defun %expression-tests ()
  (dolist (text '("0" "~0xFF" "0w12" "0wxFF" "0.0" "3E~7"
                  "#\"a\"" "\"text\"" "x" "op +" "op =" "A.x" "A.+++"
                  "()" "{}" "{a = 1, 2 = 2}" "#label" "#1" "(1,2,3)"
                  "[1,2,3]" "(1;2;3)" "let val x=1 in x; x+1 end"
                  "fn x => x" "fn [] => 0 | x::xs => x"
                  "case xs of [] => 0 | x::_ => x"
                  "if p then x else y" "while p do work"
                  "raise E" "x handle E => 0" "x:int" "x:int list"
                  "f x y" "x + y * z" "x::y::zs" "p andalso q orelse r"
                  "#a {a = 1, b = 2}" "(fn x => x) 1"))
    (%parses #'parse-expression text))
  (let ((precedence (%parses #'parse-expression "a + b * c")))
    (%kind precedence nil :infix-expression)
    (check (equal "+" (identifier-name (ast-ref precedence :operator)))
           "Expected outer addition.")
    (%kind precedence :right :infix-expression))
  (let ((right (%parses #'parse-expression "a::b::c")))
    (%kind right nil :infix-expression)
    (%kind right :right :infix-expression))
  (let ((left (%parses #'parse-expression "a - b - c")))
    (%kind left nil :infix-expression)
    (%kind left :left :infix-expression)))

(defun %pattern-and-type-tests ()
  (dolist (text '("val _ = value"
                  "val 0 = x" "val ~0xF = x" "val 0w0 = x"
                  "val #\"x\" = c" "val \"x\" = s"
                  "val x = value" "val op + = addition"
                  "val A.Nil = value" "val A.Cons value = result"
                  "val true = value" "val nil = value" "val ref value = result"
                  "val op :: (x,xs) = result" "val x::xs = result"
                  "val () = value" "val {} = value"
                  "val (x,y) = pair" "val [x,y] = pair"
                  "val {a=x,b=y} = value" "val {a=x,...} = value"
                  "val {a,b:int,c as d} = value"
                  "val (x:int) = value" "val x as y = value"
                  "val op + as pair = value"
                  "val op x : int as y = value"
                  "val x : 'a = value" "val x : ''a = value"
                  "val x : {a:int,b:string} = value"
                  "val x : int * string * bool = value"
                  "val x : int -> string -> bool = value"
                  "val x : (int,string) map = value"
                  "val x : (int * string) = value"))
    (%parses #'parse-declaration text)))

(defun %value-binding-delimiter-tests ()
  (let* ((declaration (%parses #'parse-declaration "val same = [1] = [1];"))
         (binding (%find-kind declaration :value-binding))
         (pattern (ast-ref binding :pattern))
         (expression (ast-ref binding :expression)))
    (%kind pattern nil :identifier-pattern)
    (check (equal "same" (identifier-name (ast-ref pattern :identifier)))
           "List equality captured the wrong value-binding pattern.")
    (%kind expression nil :infix-expression)
    (check (equal "=" (identifier-name (ast-ref expression :operator)))
           "List equality was not parsed as the binding RHS.")
    (%kind expression :left :list-expression)
    (%kind expression :right :list-expression))
  (let* ((declaration (%parses #'parse-declaration "val same = 1 = 1;"))
         (binding (%find-kind declaration :value-binding))
         (pattern (ast-ref binding :pattern))
         (expression (ast-ref binding :expression)))
    (%kind pattern nil :identifier-pattern)
    (check (equal "same" (identifier-name (ast-ref pattern :identifier)))
           "Scalar equality captured the wrong value-binding pattern.")
    (%kind expression nil :infix-expression)
    (check (equal "=" (identifier-name (ast-ref expression :operator)))
           "Scalar equality was not parsed as the binding RHS.")
    (%kind expression :left :literal-expression)
    (%kind expression :right :literal-expression))
  (let* ((declaration (%parses #'parse-declaration "val x::xs = result;"))
         (binding (%find-kind declaration :value-binding))
         (pattern (ast-ref binding :pattern)))
    (%kind pattern nil :infix-pattern)
    (check (equal "::" (identifier-name (ast-ref pattern :operator)))
           "The declaration delimiter change disabled :: patterns.")
    (%kind pattern :left :identifier-pattern)
    (%kind pattern :right :identifier-pattern))
  (let* ((program (%parses #'parse-program
                          "datatype t = +++ of int * int; infixr 5 +++; val left +++ right = result;"))
         (binding (%find-kind program :value-binding))
         (pattern (ast-ref binding :pattern)))
    (%kind pattern nil :infix-pattern)
    (check (equal "+++" (identifier-name (ast-ref pattern :operator)))
           "The declaration delimiter change disabled symbolic constructor patterns.")
    (%kind pattern :left :identifier-pattern)
    (%kind pattern :right :identifier-pattern)))

(defun %declaration-tests ()
  (dolist (text '("" ";" "val x=1" "val x=1 and y=2"
                  "val 'a x = (fn y => y : 'a -> 'a)"
                  "val ('a,''a) f = fn x => x"
                  "val rec f = fn x => x" "val rec f=fn x=>x and g=fn y=>y"
                  "fun f 0 = 0 | f n = n"
                  "fun f x y = x | f z w = z and g x = x"
                  "fun op ++ x y = x" "fun x + y = x"
                  "fun (x + y) z = x"
                  "type t = int" "type 'a t = 'a list and u = int"
                  "datatype t = A | B of int" "datatype 'a t = A of 'a | B"
                  "datatype t = A and 'a u = B of 'a"
                  "datatype t = A of u withtype u = int"
                  "datatype t = datatype A.t"
                  "abstype t = A of int with fun get A = A | get B = B end"
                  "abstype t = A withtype u = int with type v=u end"
                  "exception E" "exception E of string and F"
                  "exception E = A.E and op F = op A.F"
                  "local val x=1 in val y=x end" "open A B.C"
                  "infix ++" "infix 9 ++ +" "infixr 0 ::" "nonfix + ++"
                  "val x=1 val y=2" "val x=1; val y=2"))
    (%parses #'parse-declaration text)))

(defun %factored-binding-tail-tests ()
  (let* ((declaration (%parses #'parse-declaration "val x = 1 and y = 2"))
         (value (first (ast-ref declaration :declarations)))
         (bindings (ast-ref value :bindings)))
    (%kind value nil :value-declaration)
    (check (= 2 (length bindings))
           "Factoring lost a VALUE binding from an AND group.")
    (check (equal '("x" "y")
                  (mapcar (lambda (binding)
                            (identifier-name
                             (ast-ref (ast-ref binding :pattern) :identifier)))
                          bindings))
           "Factoring changed VALUE binding order.")
    (check (equal '((4 9) (14 19))
                  (mapcar (lambda (binding)
                            (list (position-offset
                                   (source-span-start (ast-node-span binding)))
                                  (position-offset
                                   (source-span-end (ast-node-span binding)))))
                          bindings))
           "Factoring changed VALUE binding spans."))
  (let* ((declaration
           (%parses #'parse-declaration
                    "fun f 0 = 0 | f n = n and g x = let val z = x in z end"))
         (function (first (ast-ref declaration :declarations)))
         (bindings (ast-ref function :bindings)))
    (%kind function nil :function-declaration)
    (check (= 2 (length bindings))
           "Factoring lost a FUNCTION binding from an AND group.")
    (check (equal '(("f" 2) ("g" 1))
                  (mapcar (lambda (binding)
                            (list (identifier-name (ast-ref binding :name))
                                  (length (ast-ref binding :clauses))))
                          bindings))
           "Factoring changed clause ownership, names, or order.")
    (check (eq :let-expression
               (ast-node-kind
                (ast-ref (first (ast-ref (second bindings) :clauses))
                         :expression)))
           "The final function's nested LET was replayed into the wrong clause."))
  (let* ((declaration
           (%parses #'parse-declaration
                    "val rec f x = x and g y = f y"))
         (function (first (ast-ref declaration :declarations))))
    (%kind function nil :function-declaration)
    (check (eq :val-rec (ast-ref function :declaration-form))
           "Factoring changed VAL REC into an ordinary FUN group.")
    (check (= 2 (length (ast-ref function :bindings)))
           "VAL REC lost its second binding."))
  (let* ((declaration (%parses #'parse-declaration "val rec f = fn x => (x,x)"))
         (value (first (ast-ref declaration :declarations))))
    (%kind value nil :value-declaration)
    (check (ast-ref value :recursive-p)
           "Function-clause fallback changed the ordinary VAL REC marker."))
  (let* ((declaration
           (%parses #'parse-declaration
                    "datatype t = A | B of int and u = C"))
         (datatype (first (ast-ref declaration :declarations)))
         (bindings (ast-ref datatype :bindings)))
    (%kind datatype nil :datatype-declaration)
    (check (equal '(("t" ("A" "B")) ("u" ("C")))
                  (mapcar (lambda (binding)
                            (list (identifier-name (ast-ref binding :name))
                                  (mapcar (lambda (constructor)
                                            (identifier-name
                                             (ast-ref constructor :name)))
                                          (ast-ref binding :constructors))))
                          bindings))
           "Factoring changed datatype or constructor ownership and order.")
    (check (equal '((9 25) (30 35))
                  (mapcar (lambda (binding)
                            (list (position-offset
                                   (source-span-start (ast-node-span binding)))
                                  (position-offset
                                   (source-span-end (ast-node-span binding)))))
                          bindings))
           "Factoring changed exact datatype binding spans.")))

(defun %module-and-program-tests ()
  (%parses #'parse-structure-expression "A.B")
  (%parses #'parse-structure-expression "struct ; end")
  (%parses #'parse-structure-expression "struct val x=1 structure S=A end")
  (%parses #'parse-structure-expression
            "struct local structure S=A in structure T=S end end")
  (%parses #'parse-structure-expression "struct end : S")
  (%parses #'parse-structure-expression "struct end :> S")
  (%parses #'parse-structure-expression "F(A)")
  (%parses #'parse-structure-expression "F(val x=1; structure S=A)")
  (%parses #'parse-structure-expression "let structure S=A in F(S) end")
  (%parses #'parse-signature-expression "S")
  (%parses #'parse-signature-expression "sig type t val x:int end")
  (%parses #'parse-signature-expression "S where type t = int")
  (%parses #'parse-signature-expression
            "S where type 'a t = 'a list and type u = int")
  (dolist (text '("" ";" "val x:int" "val x:int and y:string"
                  "type t" "type 'a t and u" "eqtype t and 'a u"
                  "type t = int" "type 'a t = 'a list and u = int"
                  "datatype t = A | B of int"
                  "datatype 'a t = A of 'a and u = B"
                  "datatype t = datatype A.t"
                  "exception E" "exception E of string and F"
                  "structure S:sig type t end and T:U"
                  "include S" "include S where type t = int" "include A B C"
                  "type t type u sharing type t = u"
                  "structure S:sig type t end sharing S = S"
                  "type t; val x:t"))
    (%parses #'parse-specification text))
  (%parses #'parse-program
"signature S = sig type 'a t val empty:'a t end;
structure A : S = struct datatype 'a t = Nil structure B=A end;
structure C :> S = struct datatype t = datatype A.t end;
functor F (X : S) : S = struct type 'a t = 'a X.t val empty=X.empty end;
functor G (type t; val x:t) :> sig val x:t end = struct val x=x end;
structure D = F(A) and E = F(val z=1 structure X=A);
val result = D.empty;
1 + 2;")
  (%parses #'parse-program "signature S=sig end functor F(X:S)=X val x=1;")
  (%parses #'parse-program ";")
  (let ((program (%parses #'parse-program "val x=1; signature S=sig end;")))
    (%kind program nil :program)))

(defun %batch-eof-tests ()
  (let ((program (parse-program "" :allow-omitted-final-semicolon t)))
    (check (ast-node-p program) "Empty batch input did not produce an AST.")
    (%check-positioned program)
    (%kind program nil :program)
    (check (null (ast-ref program :topdeclarations))
           "Empty batch input invented a declaration or expression.")
    (let ((span (ast-node-span program)))
      (check (and (zerop (position-offset (source-span-start span)))
                  (zerop (position-offset (source-span-end span))))
             "Empty batch program does not have the zero-width EOF span.")))
  (multiple-value-bind (program fixities)
      (parse-program "infix 5 +++
val x = 1 +++ 2"
                     :allow-omitted-final-semicolon t)
    (%check-positioned program)
    (let* ((items (ast-ref program :topdeclarations))
           (component (first items)))
      (check (= 1 (length items))
             "Adjacent unterminated batch components split into sibling topdecs.")
      (%kind component nil :topdec-structure)
      (check (= 2 (length (ast-ref component :declarations)))
             "Batch EOF factoring lost an adjacent Core declaration.")
      (check (= 5 (third (fixity-lookup fixities "+++")))
             "Batch EOF factoring lost the threaded output fixity.")
      (check (not (null (%find-kind component :infix-expression)))
             "Batch EOF factoring lost the input fixity to the final declaration.")))
  (let* ((program (parse-program "signature S = sig end; val y = 1"
                                 :allow-omitted-final-semicolon t))
         (items (ast-ref program :topdeclarations)))
    (%check-positioned program)
    (check (= 2 (length items))
           "Semicolon plus final-EOF batch components were merged incorrectly: ~S"
           (mapcar #'ast-node-kind items))
    (%kind (second items) nil :topdec-structure)))

(defun %specification-sharing-tests ()
  (let* ((specification
           (%parses #'parse-specification
                    "structure A:sig type t val x:t end
                     structure B:sig type t val x:t end
                     sharing type A.t = B.t
                     val choose : A.t * B.t -> A.t"))
         (sequence (ast-ref specification :specification))
         (items (ast-ref sequence :specifications)))
    (%kind specification nil :type-sharing-specification)
    (%kind sequence nil :specification-sequence)
    (check (= 3 (length items))
           "Sharing followed by VAL dropped or added specification items.")
    (%kind (first items) nil :structure-specification)
    (%kind (second items) nil :structure-specification)
    (%kind (third items) nil :value-specification)
    (let* ((descriptions (ast-ref (third items) :descriptions))
           (choose (first descriptions))
           (type (ast-ref choose :type)))
      (check (= 1 (length descriptions))
             "The post-sharing VAL descriptions were split incorrectly.")
      (check (equal "choose" (identifier-name (ast-ref choose :name)))
             "The post-sharing value description was not CHOOSE.")
      (%kind type nil :function-type)
      (%kind type :domain :tuple-type)
      (check (= 2 (length (ast-ref (ast-ref type :domain) :types)))
             "The CHOOSE domain was not the original pair type.")))
  (let* ((specification
           (%parses #'parse-specification
                    "structure Left:sig type t end
                     structure Right:sig type t end
                     sharing Left = Right
                     val pick : Left.t * Right.t -> Right.t"))
         (sequence (ast-ref specification :specification))
         (items (ast-ref sequence :specifications)))
    (%kind specification nil :structure-sharing-specification)
    (%kind sequence nil :specification-sequence)
    (check (= 3 (length items))
           "Structure sharing incorrectly terminated its specification.")
    (%kind (third items) nil :value-specification))
  (let ((specification
          (%parses #'parse-specification
                   "type t
                    type u
                    sharing type t = u
                    val choose : t * u -> t;
                    structure A:sig type t end
                    structure B:sig type t end
                    sharing A = B
                    sharing type A.t = B.t;
                    val convert : A.t * B.t -> A.t
                    type v
                    sharing type t = v
                    val result : v")))
    (let ((node specification)
          (sharing-kinds nil))
      (loop while (member (ast-node-kind node)
                          '(:type-sharing-specification
                            :structure-sharing-specification))
            do (push (ast-node-kind node) sharing-kinds)
               (setf node (ast-ref node :specification)))
      (check (equal '(:type-sharing-specification
                      :structure-sharing-specification
                      :type-sharing-specification
                      :type-sharing-specification)
                    sharing-kinds)
             "Interleaved sharing clauses lost their source ordering.")
      (%kind node nil :specification-sequence)
      (let ((items (ast-ref node :specifications)))
        (check (equal '(:type-specification :type-specification
                        :value-specification
                        :structure-specification :structure-specification
                        :value-specification :type-specification
                        :value-specification)
                      (mapcar #'ast-node-kind items))
               "Specification groups changed item ordering around sharing.")
        (check (equal '("choose" "convert" "result")
                      (loop for item in items
                            when (eq :value-specification (ast-node-kind item))
                              append (mapcar (lambda (description)
                                               (identifier-name
                                                (ast-ref description :name)))
                                             (ast-ref item :descriptions))))
               "Values before, between, and after sharing were not retained."))))
  (%rejects #'parse-specification
            "sharing type A.t = B.t val choose : A.t * B.t -> A.t")
  (%rejects #'parse-specification
            "; sharing A = B val pick : int")
  (%rejects #'parse-specification
            "structure A:sig type t end sharing type A.t = B.t val"))

(defun %selector-tests ()
  (let* ((declaration (%parses #'parse-declaration "val getA=#a"))
         (binding (%find-kind declaration :value-binding))
         (selector (ast-ref binding :expression)))
    (%kind selector nil :selector-expression)
    (%kind selector :label :label)
    (check (equal "a" (ast-ref (ast-ref selector :label) :name))
           "Standalone selector lost its label."))
  (let* ((program (%parses #'parse-program
                           "val getA=#a; val selected=#a {a=1,b=2};"))
         (application (%find-kind program :application-expression)))
    (%kind application nil :application-expression)
    (%kind application :function :selector-expression)
    (%kind application :argument :record-expression)))

(defun %fixity-tests ()
  (let ((environment (initial-fixity-environment)))
    (destructuring-bind (name associativity precedence)
        (fixity-lookup environment "+")
      (check (equal "+" name) "Wrong initial fixity name.")
      (check (eq :left associativity) "Wrong initial + associativity.")
      (check (= 6 precedence) "Wrong initial + precedence.")))
  (let* ((identifier (ast-ref (%parses #'parse-expression "op +") :identifier))
         (qualified (ast-ref (%parses #'parse-expression "A.+") :identifier))
         (environment (initial-fixity-environment)))
    (check (infix-identifier-p environment identifier) "OP identifier lost its name.")
    (check (not (infix-identifier-p environment identifier t)) "OP alias stayed infix.")
    (check (not (infix-identifier-p environment qualified)) "Qualified name became infix."))
  (%parses #'parse-program "infixr 5 ++; val x = a ++ b ++ c;")
  (let ((scoped (%parses #'parse-expression
                         "let infixr 5 ++ in a ++ b ++ c end")))
    (check (%find-kind scoped :infix-expression)
           "LET-local fixity directive did not affect its expression."))
  (let ((outside (%parses #'parse-expression "a ++ b")))
    (%kind outside nil :application-expression))
  (let ((program (%parses #'parse-program
                          "structure S=struct infixr 5 ++ end; val y=a ++ b;")))
    (check (not (%find-kind program :infix-expression))
           "STRUCT-local fixity leaked into the following program."))
  (%parses #'parse-declaration "val f = op + ")
  (%kind (%parses #'parse-expression "a A.+ b") nil :application-expression)
  (%rejects #'parse-program "infix 4 <<; infixr 4 >>; val x=a << b >> c;")
  (%rejects #'parse-program "infix 4 <<; infixr 4 >>; val x=a >> b << c;"))

(defun %rejection-tests ()
  (dolist (text '("val rec x = 1" "val rec nil = fn () => ()"
                  "val (x,x) = (1,2)"
                  "val ('a,'a) f = fn x => x"
                  "val + as x = value" "val ~1.0 = value"
                  "val x : {a:int,a:string} = value"
                  "val {a=x,a=y} = value" "val 1.0 = value"
                  "datatype t = true" "datatype t = it"
                  "datatype t = A | A" "datatype t = datatype"
                  "datatype t = A of u withtype u = int and t = string"
                  "fun f x=x | g y=y" "fun f x=x | f y z=z"
                  "fun f x x=x" "fun f (x,x)=x"
                  "val get A = A | get B = B"
                  "nonfix" "infix 10 +"
                  "2 + while true do ()"))
    (%rejects (if (string= text "2 + while true do ()")
                  #'parse-expression #'parse-declaration)
              text))
  (%rejects #'parse-expression "{a=1,a=2}")
  (%rejects #'parse-expression "#[1,2]")
  (%rejects #'parse-specification "infix +")
  (%rejects #'parse-specification "nonfix +")
  (%rejects #'parse-specification "val = : int")
  (%rejects #'parse-specification "datatype t = op A")
  (%rejects #'parse-expression "let structure S=A in S end")
  (%rejects #'parse-expression "{0=1}")
  (%rejects #'parse-expression "{01=1}")
  (%rejects #'parse-declaration "type * = int")
  (%rejects #'parse-declaration "val op = = equal")
  (%rejects #'parse-declaration "val x=1 and x=2")
  (%rejects #'parse-declaration "val 'a x = let val 'a id = fn z=>z in id end")
  (%rejects #'parse-declaration "type t=int and t=string")
  (%rejects #'parse-declaration "exception E and E")
  (%rejects #'parse-declaration "datatype t=A and t=B")
  (%rejects #'parse-specification "datatype 'a t = A of 'b")
  (%rejects #'parse-signature-expression "S where type 'a t = 'b list")
  (%rejects #'parse-specification "val x:int and x:string")
  (%rejects #'parse-specification "type t and t")
  (%rejects #'parse-specification "datatype t = A | A")
  (%rejects #'parse-specification "exception E and E")
  (%rejects #'parse-specification "structure S:T and S:U")
  (%rejects #'parse-specification "type t sharing type t")
  (%rejects #'parse-program "signature S=sig end and S=sig end;")
  (%rejects #'parse-program "functor F(A:S)=A and F(B:S)=B;")
  (%rejects #'parse-program "structure S=A and S=B;")
  (%rejects #'parse-program "val x=1")
  (%rejects #'parse-program "")
  (%rejects #'parse-expression "1 )"))

(defun %diagnostic-tests ()
  (handler-case (progn (parse-expression "if true then") (check nil "Expected EOF failure."))
    (sml-syntax-error (condition)
      (let ((end (source-span-end (sml-error-span condition))))
        (check (= 12 (position-offset end)) "Wrong EOF offset.")
        (check (= 1 (position-line end)) "Wrong EOF line.")
        (check (= 13 (position-column end)) "Wrong EOF column.")))))

(defun %nested-match-tail-tests ()
  (let* ((expression
           (%parses #'parse-expression "case x of a => 1 | b => 2 | c => 3"))
         (match (ast-ref expression :match))
         (rules (ast-ref match :rules)))
    (check (= 3 (length rules))
           "Factored match tails changed the rule count.")
    (check (equal '(10 34)
                  (list (position-offset (source-span-start (ast-node-span match)))
                        (position-offset (source-span-end (ast-node-span match)))))
           "Factored match tails changed the whole match span.")
    (check (equal '((10 16) (19 25) (28 34))
                  (mapcar (lambda (rule)
                            (list (position-offset
                                   (source-span-start (ast-node-span rule)))
                                  (position-offset
                                   (source-span-end (ast-node-span rule)))))
                          rules))
           "Factored match tails changed rule order or exact rule spans."))
  (let* ((expression
           (%parses #'parse-expression
                    "case ds of []=>0 | x::xs=>case(a<b)of true=>x | false=>0"))
         (rules (ast-ref (ast-ref expression :match) :rules)))
    (check (= 2 (length rules))
           "The nested CASE did not retain its false alternative: ~S" expression)
    (let* ((inner-expression (ast-ref (second rules) :expression))
           (inner-rules (ast-ref (ast-ref inner-expression :match) :rules)))
      (%kind inner-expression nil :case-expression)
      (check (= 2 (length inner-rules))
             "The inner CASE lost its final alternative to its sibling match.")))
  (let* ((expression
           (%parses #'parse-expression
                    "case ds of []=>0 | x::xs=>(case(a<b)of true=>x) | false=>0"))
         (rules (ast-ref (ast-ref expression :match) :rules)))
    (check (= 3 (length rules))
           "Parentheses stopped preserving the outer sibling alternative.")
    (let ((inner-expression (ast-ref (second rules) :expression)))
      (%kind inner-expression nil :grouped-expression)
      (let ((inner (ast-ref inner-expression :expression)))
        (%kind inner nil :case-expression)
        (check (= 1 (length (ast-ref (ast-ref inner :match) :rules)))
               "The parenthesized inner CASE acquired an outer alternative.")))))

(defun %representation-tests ()
  (let ((transparent (%parses #'parse-structure-expression "A:S"))
        (opaque (%parses #'parse-structure-expression "A:>S")))
    (%kind transparent nil :constrained-structure)
    (%kind opaque nil :constrained-structure)
    (check (null (ast-ref transparent :opaque-p)) "Transparent constraint became opaque.")
    (check (ast-ref opaque :opaque-p) "Opaque constraint became transparent."))
  (let* ((declaration (%parses #'parse-declaration "datatype t = datatype A.t"))
         (replication (first (ast-ref declaration :declarations))))
    (%kind replication nil :datatype-replication))
  (let* ((declaration (%parses #'parse-declaration "val rec f = fn x=>x"))
         (binding (first (ast-ref declaration :declarations))))
    (%kind binding nil :value-declaration)
    (check (ast-ref binding :recursive-p) "VAL REC marker was lost."))
  (%kind (%parses #'parse-expression "[x]") nil :list-expression)
  (%kind (%parses #'parse-expression "()") nil :unit-expression)
  (%kind (%parses #'parse-expression "(x)") nil :grouped-expression)
  (let* ((program (%parses #'parse-program "1+2;"))
         (topdec (first (ast-ref program :topdeclarations))))
    (%kind topdec nil :toplevel-expression)
    (check (equal "it" (identifier-name (ast-ref topdec :binding-name)))
           "Expression Program does not bind IT."))
  (let* ((program (%parses #'parse-program
                           "signature S=sig end functor F(X:S)=X;"))
         (topdec (first (ast-ref program :topdeclarations))))
    (%kind topdec nil :topdec-sequence)))

(defun run-parser-tests ()
  (with-suite ("ooparts-tests/sml/parser")
    (%expression-tests)
    (%pattern-and-type-tests)
    (%value-binding-delimiter-tests)
    (%declaration-tests)
    (%factored-binding-tail-tests)
    (%module-and-program-tests)
    (%batch-eof-tests)
    (%specification-sharing-tests)
    (%selector-tests)
    (%fixity-tests)
    (%rejection-tests)
    (%diagnostic-tests)
    (%nested-match-tail-tests)
    (%representation-tests))
  t)
