(uiop:define-package #:ooparts-tests/sml/modules/native
  (:use #:cl)
  (:import-from #:ooparts/test #:with-suite #:is)
  (:import-from #:ooparts/sml/compiler
    #:compile-source #:run-program #:lookup-value #:lookup-type #:value-to-string
    #:make-initial-basis)
  (:import-from #:ooparts/sml/elaborate
    #:sml-elaboration-error #:elaboration-error-kind)
  (:import-from #:ooparts/sml/types #:sml-type-error)
  (:import-from #:ooparts/sml/source #:sml-source-error)
  (:import-from #:ooparts/sml/runtime
    #:sml-equal #:sml-reference-contents #:constructor-identity #:sml-raise)
  (:export #:run-module-tests))
(in-package #:ooparts-tests/sml/modules/native)

(defun %compile (source &optional basis batchp)
  (compile-source source
                  :source-name "<native module test>"
                  :basis (or basis (make-initial-basis))
                  :allow-omitted-final-semicolon batchp))

(defun %execute (source &optional basis batchp)
  (run-program (%compile source basis batchp) :basis basis))

(defun %basis (source &optional basis batchp)
  (nth-value 1 (%execute source basis batchp)))

(defun %value (source &optional basis batchp)
  (nth-value 0 (%execute source basis batchp)))

(defun %binding (basis name)
  (multiple-value-bind (value presentp) (lookup-value basis name)
    (is presentp () "Expected an executed module binding ~S." name)
    value))

(defun %check (expected value)
  (is (sml-equal expected value) ()
      "Expected ~A, got ~A." (value-to-string expected) (value-to-string value)))

(defun %rejects-source (source &optional basis batchp)
  (handler-case
      (progn (%compile source basis batchp)
             (is nil () "Expected source rejection for:~%~A" source))
    (sml-type-error () (is t))
    (sml-source-error () (is t))))

(defun %rejects-condition (condition-class source &optional basis batchp)
  (handler-case
      (progn (%compile source basis batchp)
             (is nil () "Expected ~S rejection for:~%~A" condition-class source))
    (error (condition)
      (is (typep condition condition-class) ()
          "Expected ~S, got ~S: ~A~%~A"
          condition-class (type-of condition) condition source))))

(defun %rejects-module (source &optional basis)
  (handler-case
      (progn (%compile source basis)
             (is nil () "Expected module rejection for:~%~A" source))
    (error (condition)
      (is (and (typep condition 'sml-elaboration-error)
               (eq (elaboration-error-kind condition) :module))
          () "Expected a module elaboration error, got ~S: ~A~%~A"
          (type-of condition) condition source))))

(defun %namespace-and-scope-tests ()
  (let ((basis
          (%basis
           "structure S = struct
              datatype color = Red | RGB of int
              type t = int
              val x = 41
              structure N = struct
                val y = x + 1
                exception E of string
                val r = ref 3
              end
            end;
            structure A = S;
            structure N = S.N;
            open S;
            val answer = x + A.x + S.N.y;
            val copied = RGB 8;
            N.r := !N.r + 2;
            val contents = !A.N.r;")))
    (%check 124 (%binding basis "answer"))
    (is (sml-equal (%binding basis "A.Red") (%binding basis "S.Red")))
    (%check 5 (%binding basis "contents"))
    (%check 5 (sml-reference-contents (%binding basis "N.r")))
    (is (string= "RGB(8)" (value-to-string (%binding basis "copied")))))
  (%rejects-source "S.color.Red;")
  (let* ((first (%basis "structure S=struct val old=1 type t=int end;"))
         (second (%basis "structure S=struct val current=2 end;" first)))
    (%check 2 (%binding second "S.current"))
    (multiple-value-bind (value presentp) (lookup-value second "S.old")
      (declare (ignore value))
      (is (not presentp) () "Empty rebinding retained a stale qualified value."))
    (%rejects-source "val x:S.t=1;" second))
  (let ((basis (%basis "structure A=struct val r=ref 1 end;
                        structure B=A;
                        B.r := 7;
                        val got = !A.r;")))
    (%check 7 (%binding basis "got"))
    (is (sml-equal (%binding basis "A.r") (%binding basis "B.r")))
    (is (eq (%binding basis "A.r") (%binding basis "B.r"))))
  (let ((basis (%basis "structure A=struct structure N=struct val x=7 end end;
                        open A;
                        val answer=N.x;")))
    (%check 7 (%binding basis "answer")))
  (let ((basis (%basis "structure S=let
                          val x=4
                          structure P=struct val hidden=8 end
                        in struct val y=P.hidden+x end end;
                        structure T=struct
                          local structure P=struct val hidden=5 end
                          in structure Q=struct val y=P.hidden+1 end end
                        end;
                        val answer=S.y+T.Q.y;")))
    (%check 18 (%binding basis "answer"))
    (%rejects-source "P.hidden;" basis)
    (%rejects-source "T.P.hidden;" basis)))

(defun %signature-view-tests ()
  (let ((basis
          (%basis
           "signature SIG = sig
              type t
              val x : t
              val inc : t -> t
              structure N : sig val y : int end
            end;
            structure S : SIG = struct
              type t = int
              val x = 3
              fun inc x = x + 1
              val hidden = 99
              structure N = struct val y=4 val z=9 end
            end;
            val answer = S.inc S.x + S.N.y;")))
    (%check 8 (%binding basis "answer"))
    (%rejects-source "S.hidden;" basis)
    (%rejects-source "S.N.z;" basis))
  (let ((basis
          (%basis
           "signature CELL = sig
              type t
              val fresh : int -> t
              val read : t -> int
            end;
            structure C :> CELL = struct
              datatype private = P
              datatype t = D of int
              val secret = 5
              fun fresh x = D (x + secret)
              fun read (D n) = n
            end;
            val answer = C.read (C.fresh 4);")))
    (%check 9 (%binding basis "answer"))
    (%rejects-source "D 1;" basis)
    (%rejects-source "C.secret;" basis))
  (let ((basis (%basis "signature R=sig val r:int ref end;
                        structure S:R=struct val r=ref 1 val hidden=2 end;
                        structure T=S;
                        S.r:=12;
                        val answer = !T.r;")))
    (%check 12 (%binding basis "answer"))
    (is (eq (%binding basis "S.r") (%binding basis "T.r")))
    (%rejects-source "S.hidden;" basis))
  (let ((basis (%basis "signature X=sig exception E of int end;
                        structure A:X=struct exception E of int end;
                        val answer=(raise A.E 4) handle A.E n=>n;")))
    (%check 4 (%binding basis "answer")))
  (%rejects-source
   "signature X=sig exception E of int end;
    structure A:X=struct exception E of string end;")
  (%rejects-source
   "signature S=sig val x:int end;
    structure A:S=struct end;")
  (%rejects-source
   "signature S=sig val x:int end;
    structure A:S=struct val x=true end;")
  (%rejects-source
   "signature S=sig datatype t=A end;
    structure A:S=struct datatype t=A of int end;")
  (%rejects-source
   "signature S=sig datatype t=A of int end;
    structure A:S=struct val A=0 datatype t=B end;")
  (%rejects-source
   "signature S=sig datatype t=A of bool end;
    structure A:S=struct datatype t=A of int end;")
  (%rejects-source
   "signature S=sig val id:'a->'a end;
    structure A:S=struct val id=fn x:int=>x end;")
  (let ((basis (%basis "signature S=sig val f:int->int end;
                        structure A:S=struct val f=fn x=>x end;
                        val answer=A.f 3;")))
    (%check 3 (%binding basis "answer")))
  (%rejects-source
   "signature S=sig eqtype t end;
    structure A:S=struct type t=real end;")
  (let ((basis (%basis "signature E=sig eqtype t end;
                        structure A:E=struct type t=int end;
                        val x:A.t=1;")))
    (%check 1 (%binding basis "x"))))

(defun %where-sharing-and-replication-tests ()
  (%rejects-source "signature Bad=sig type 'a t end where type t=int;")
  ;; The tests use only the existing native Core list operations.
  (let ((basis
          (%basis
           "signature S = sig
              type 'a t
              val x : int t
            end where type 'a t = 'a list;
            structure A:S=struct
              type 'a t = 'a list
              val x = [1,2,3]
            end;
            val answer=case A.x of _::n::_=>n | _=>0;")))
    (%check 2 (%binding basis "answer")))
  (let ((basis
          (%basis
           "signature S = sig
              structure A:sig type t val x:t end
              structure B:sig type t val x:t end
              sharing type A.t = B.t
              val choose : A.t * B.t -> A.t
            end;
            structure Q:S=struct
              structure A=struct type t=int val x=1 end
              structure B=struct type u=int type t=u val x=2 end
              fun choose (a,b)=a
            end;
            val answer=Q.choose(Q.A.x,Q.B.x);")))
    (%check 1 (%binding basis "answer")))
  (%rejects-source
   "signature S=sig
      structure A:sig type t val x:t end
      structure B:sig type t val x:t end
      sharing type A.t=B.t
    end;
    structure Q:S=struct
      structure A=struct type t=int val x=1 end
      structure B=struct type t=bool val x=true end
    end;")
  (%rejects-source
   "signature S=sig
      structure A:sig type t end
      structure B:sig type t end
      sharing A=B
    end;
    structure Q:S=struct
      structure A=struct type t=int end
      structure B=struct type t=bool end
    end;")
  (let ((basis
          (%basis
           "structure A=struct datatype t=A | B of int end;
            structure B=struct datatype u=datatype A.t end;
            structure C=struct exception E of int end;
            structure D=struct
              exception F=C.E
              fun f ()=raise F 2
              fun g ()=f() handle F n=>n+3
            end;
            val replicated=B.B 8;
            val handled=D.g();")))
    (%check 5 (%binding basis "handled"))
    (is (string= "B(8)" (value-to-string (%binding basis "replicated"))))))

(defun %functor-tests ()
  (let ((basis
          (%basis
           "signature ARG=sig type t val x:t end;
            functor F(A:ARG)=struct
              type u=A.t list
              val x=A.x
              val id=fn x:A.t=>x
            end;
            structure P=struct type t=int val x=4 val extra=true end;
            structure Q=F(P);
            val answer=Q.id Q.x;")))
    (%check 4 (%binding basis "answer"))
    (multiple-value-bind (value presentp) (lookup-value basis "Q.extra")
      (declare (ignore value))
      (is (not presentp) () "An actual-argument extra field escaped the formal view.")))
  (let ((basis
          (%basis
           "functor Apply(val x:int)=struct val y=x+1 end;
            structure A=Apply(val x=41);
            functor Empty()=struct val y=9 end;
            structure E=Empty();
            val answer=A.y+E.y;")))
    (%check 51 (%binding basis "answer")))
  (let ((basis
          (%basis
           "functor F()=struct
              datatype t=T of int
              val make=T
              val get=fn T n=>n
            end;
            structure A=F();
            structure B=F();
            val tagA=A.make 3;
            val tagB=B.make 4;
            val answer=A.get tagA+B.get tagB;")))
    (%check 7 (%binding basis "answer"))
    (is (not (eq (constructor-identity (%binding basis "tagA"))
                 (constructor-identity (%binding basis "tagB")))))
    (%rejects-source "val bad=B.get(A.make 1);" basis))
  (let ((basis
          (%basis
           "signature P=sig type t val construct:int->t val read:t->int end;
            functor F(A:P):P=struct
              datatype t=Box of int
              val construct=Box
              val read=fn Box n=>n+A.read(A.construct 1)
            end;
            structure A=struct
              datatype t=A of int
              val construct=A
              val read=fn A n=>n
            end;
            structure S=F(A);
            val answer=S.read(S.construct 6);")))
    (%check 7 (%binding basis "answer")))
  (let ((basis (%basis "functor F() :> sig type t val make:int->t val read:t->int end = struct
                          datatype t=T of int
                          val make=T
                          val read=fn T n=>n
                        end;
                        structure A=F();
                        val answer=A.read(A.make 5);")))
    (%check 5 (%binding basis "answer"))
    (%rejects-source "T 1;" basis)))

(defun %rollback-fixity-and-batch-tests ()
  (let* ((basis (%basis "val r=ref 0; structure S=struct val x=1 end;"))
         (reference (%binding basis "r"))
         (program (%compile "r:=9; structure T=struct val x=2 end; raise Option;" basis)))
    (handler-case
        (progn (run-program program)
               (is nil () "Expected the rollback test's uncaught exception."))
      (sml-raise () (is t)))
    (%check 9 (sml-reference-contents reference))
    (%rejects-source "T.x;" basis)
    (%rejects-source "r:=4; S.missing;" basis)
    (%check 9 (sml-reference-contents reference)))
  (let ((basis (%basis "infix 6 +++;
                        fun x +++ y = x+y;
                        val q=let infix 5 *** in 2 end;
                        val answer=2 +++ 3;")))
    (%check 5 (%binding basis "answer"))
    (%check 2 (%binding basis "q")))
  (let* ((right (%basis "infixr 5 @@;
                         val op @@ = fn (x,y)=>x-y;
                         val answer=8@@3@@2;"))
         (nonfix (%basis "infix 6 +++;
                          val op +++ = fn (x,y)=>x+y;
                          nonfix +++;" right)))
    (%check 7 (%binding right "answer"))
    (%check 5 (%value "+++ (2,3);" nonfix)))
  (let ((basis (%basis "val q=let infix 6 +++ in 2 end;")))
    (%rejects-source "val bad=2 +++ 3;" basis))
  (%rejects-source "val x=1")
  (let ((basis (%basis "val x=1" nil t)))
    (%check 1 (%binding basis "x")))
  (%rejects-source "val x=" nil t))

(defun %opaque-signature-boundary-tests ()
  ;; Finding 1(a): the expected abbreviation remains int, while an abstract
  ;; specification realized by an abbreviation receives a fresh abstract name.
  (let ((basis
          (%basis
           "signature Sig = sig type t = int val x : t type u val y : u end;
            structure S1 :> Sig =
              struct type t = int val x = 3 type u = real val y = 3.0 end;
            val ok = S1.x + 1;")))
    (%check 4 (%binding basis "ok"))
    (%rejects-condition 'ooparts/sml/types:type-name-unification-error
                        "val bad = S1.y + 1.5;" basis)
    ;; Compilation and execution must not destructively update the committed
    ;; realization stored in the preceding persistent basis.
    (let ((later (%basis "structure Unrelated = struct val z = 8 end;" basis)))
      (%check 4 (%binding later "ok"))
      (%check 8 (%binding later "Unrelated.z"))))
  ;; Finding 1(b): each opaque application gets a distinct expected name even
  ;; though the actual definition is the same int abbreviation.
  (let ((basis
          (%basis
           "structure A = struct type t = int end;
            functor f() :> sig type t end = A;
            structure B = f(); structure C = f();
            val ok : B.t -> B.t = fn x => x;")))
    (%rejects-condition 'ooparts/sml/types:type-name-unification-error
                        "val bad : B.t -> C.t = fn x => x;" basis))
  ;; Finding 1(c): datatype replication is rigid, not opaque-generative; its
  ;; exported constructor retains the outer datatype and constructor identity.
  (let ((basis
          (%basis
           "datatype d = D of int;
            signature S = sig datatype t = datatype d val mk : int -> t end;
            structure A :> S = struct datatype t = datatype d val mk = D end;
            val original : d = A.mk 1;
            val outer = D 2;
            val sealed = A.D 2;
            val fetched = case sealed of D n => n;")))
    (%check 2 (%binding basis "fetched"))
    (%check (%binding basis "outer") (%binding basis "sealed"))
    (is (eq (constructor-identity (%binding basis "outer"))
            (constructor-identity (%binding basis "sealed")))))
  ;; Distinct and shared bound specifications are intentionally independent of
  ;; how many actual specifications map to one underlying datatype name.
  (let ((basis
          (%basis
           "datatype d = D of int;
            functor Separate() :> sig type t type u val left : t val right : u end =
              struct datatype t = datatype d; datatype u = datatype d;
                     val left = D 0 val right = D 1 end;
            structure S = Separate();")))
    (%rejects-condition 'ooparts/sml/types:type-name-unification-error
                        "val bad : S.t -> S.u = fn x => x;" basis))
  (let ((basis
          (%basis
           "datatype d = D of int;
            functor Shared() :>
              sig type t type u sharing type t = u val x : t val y : u end =
              struct datatype t = datatype d; datatype u = datatype d;
                     val x = D 0 val y = D 0 end;
            structure Q = Shared();
            val shared : Q.t = Q.y;")))
    (%check (%binding basis "Q.x") (%binding basis "shared"))))

(defun %rigid-and-named-signature-tests ()
  ;; Finding 2: a replication of pervasive int is rigid in the signature.  The
  ;; valid control must retain int arithmetic in the compiled functor body.
  (let ((basis
          (%basis
           "signature T = sig datatype t = datatype int val v : t end;
            functor F(A : T) = struct val n = A.v + 1 end;
            structure P = struct datatype t = datatype int val v = 41 end;
            structure Q = F(P);
            val answer = Q.n;")))
    (%check 42 (%binding basis "answer")))
  (%rejects-module
   "signature T = sig datatype t = datatype int val v : t end;
    functor F(A : T) = struct val n = A.v + 1 end;
    structure P = struct datatype t = K of int val v = K 41 end;
    structure Q = F(P);
    val z = Q.n;")
  ;; Finding 3: sibling occurrences and INCLUDE each instantiate bound names
  ;; apart, so independently typed components do not constrain one another.
  (let ((basis
          (%basis
           "signature S = sig type t val f : t -> t end;
            signature A = sig structure X : S structure Y : S end;
            structure P : A = struct
              structure X = struct type t = int val f = fn x => x + 1 end
              structure Y = struct type t = bool val f = fn x => not x end
            end;
            val xi = P.X.f 4;
            val yb = P.Y.f false;
            signature I = sig include S structure Z : S end;
            structure Q : I = struct
              type t = int val f = fn x => x + 2
              structure Z = struct type t = bool val f = fn x => not x end
            end;
            val qi = Q.f 4;
            val qb = Q.Z.f true;")))
    (%check 5 (%binding basis "xi"))
    (is (string= "true" (value-to-string (%binding basis "yb"))))
    (%check 6 (%binding basis "qi"))
    (is (string= "false" (value-to-string (%binding basis "qb")))))
  ;; Associated constructor identities are renamed with each occurrence too.
  (let ((basis
          (%basis
           "signature DS = sig datatype t = A val v : t end;
            signature Pair = sig structure X : DS structure Y : DS end;
            structure P : Pair = struct
              structure X = struct datatype t = A val v = A end
              structure Y = struct datatype t = A val v = A end
            end;
            val xv = P.X.v; val yv = P.Y.v;")))
    (is (not (eq (constructor-identity (%binding basis "xv"))
                 (constructor-identity (%binding basis "yv")))))
    (%rejects-condition 'ooparts/sml/types:type-name-unification-error
                        "val bad : P.X.t = P.Y.v;" basis)))

(defun %open-namespace-regression-tests ()
  ;; Finding 4: the value, type and structure named M/T remain in independent
  ;; namespaces.  Only M's components are opened; aliases still share fields.
  (let ((basis
          (%basis
           "structure M = struct type q = int val x = 1 end;
            val M = 99;
            type M = int;
            structure T = struct open M end;
            structure U = T;
            val answer = M + T.x + U.x;
            val typed : U.q = 5;")))
    (%check 101 (%binding basis "answer"))
    (%check 5 (%binding basis "typed"))
    (multiple-value-bind (value presentp) (lookup-value basis "T")
      (declare (ignore value))
      (is (not presentp) () "OPEN leaked the structure path as a value."))
    (multiple-value-bind (text presentp scheme) (lookup-type basis "T")
      (declare (ignore text scheme))
      (is (not presentp) () "OPEN leaked the structure path as a type.")))
  (%rejects-condition 'sml-elaboration-error
                      "structure M = struct val x = 1 end;
                       val M = 99;
                       structure T = struct open M end;
                       val bad = T + 1;"))

(defun %equality-refinement-and-sharing-tests ()
  ;; Finding 5: specification equality, not the actual datatype's attribute,
  ;; determines equality after opaque sealing.
  (%rejects-condition 'ooparts/sml/types:equality-type-error
                      "signature S = sig type t val f : unit -> t end;
                       structure A :> S = struct datatype t = T fun f () = T end;
                       val bad = A.f () = A.f ();")
  (let ((basis
          (%basis
           "signature S = sig eqtype t val f : unit -> t end;
            structure A :> S = struct datatype t = T fun f () = T end;
            val answer = if A.f () = A.f () then 1 else 0;")))
    (%check 1 (%binding basis "answer")))
  ;; Finding 6: equality and outer-basis RHS side conditions are checked.  The
  ;; positive controls distinguish them from parse/unbound-primitive failures.
  (%rejects-condition 'ooparts/sml/types:equality-type-error
                      "signature S = sig eqtype t end where type t = real;")
  (%rejects-condition 'sml-elaboration-error
                      "signature U = sig type u type t end where type t = u;")
  (%rejects-module
   "datatype d = D;
    signature Bad = sig datatype t = datatype d end where type t = int;")
  (let ((basis
          (%basis
           "type u = int;
            signature U = sig type u type t val x : t end where type t = int;
            signature V = sig type t val x : t end where type t = u;
            signature W = sig type t type s val x : t val y : s end
              where type t = int and type s = bool;
            structure A : U = struct type u = bool type t = int val x = 3 end;
            structure B : V = struct type t = int val x = 4 end;
            structure C : W = struct type t = int type s = bool val x = 5 val y = true end;
            val answer = A.x + B.x + C.x;")))
    (%check 12 (%binding basis "answer")))
  ;; Finding 7: both source orders promote every participant, including t and
  ;; value schemes elaborated before the sharing specification.
  (dolist (sharing (list "sharing type t = u" "sharing type u = t"))
    (let ((basis
            (%basis
             (format nil "signature ARG = sig type t eqtype u ~A val v : t end;
                          functor F(A : ARG) = struct val eq = (A.v = A.v) end;
                          functor G(A : ARG) = struct val eq = (A.v = A.v) end;
                          structure P = struct type t = int type u = int val v = 7 end;
                          structure Q = F(P);
                          structure R = G(P);
                          val answer = if Q.eq andalso R.eq then 1 else 0;"
                     sharing))))
      (%check 1 (%binding basis "answer"))))
  ;; Derived structure sharing has the same canonical equality class, also
  ;; when an equality participant arrives after two non-equality participants.
  ;; Its derived type-sharing form cannot silently accept abbreviation specs.
  (%rejects-module
   "signature Bad = sig
      structure A : sig type t = int end
      structure B : sig type t = int end
      sharing A = B end;")
  (dolist (sharing (list "sharing A = B" "sharing B = A" "sharing A = B = C"))
    (let ((basis
            (%basis
             (format nil "signature ARG = sig
                            structure A : sig type t val v : t end
                            structure B : sig eqtype t end
                            structure C : sig eqtype t end
                            ~A end;
                          functor F(X : ARG) = struct val eq = (X.A.v = X.A.v) end;
                          structure P = struct
                            structure A = struct type t = int val v = 9 end
                            structure B = struct type t = int end
                            structure C = struct type t = int end
                          end;
                          structure Q = F(P);
                          val answer = if Q.eq then 1 else 0;"
                     sharing))))
      (%check 1 (%binding basis "answer"))))
  ;; Opaque realization changes static projection only.  Aliases execute no
  ;; module expression again and preserve the identical committed ref cell.
  (let* ((first
           (%basis
            "signature R = sig type t val r : t ref val get : unit -> t
                              val set : t -> unit val make : int -> t end;
             structure A :> R = struct type t = int val r = ref 1
                                       fun get () = !r fun set x = r := x fun make x = x end;
             structure B = A;
             A.set (A.make 7);
             val initial = !B.r;"))
         (cell (%binding first "A.r"))
         (second (%basis "val later = A.get();" first)))
    (%check 7 (%binding first "initial"))
    (%check 7 (%binding second "later"))
    (%check 7 (sml-reference-contents cell))
    (is (eq cell (%binding second "A.r")))
    (is (eq cell (%binding second "B.r")))))

(defun %ordinary-module-semantic-regression-tests ()
  ;; A constructor satisfying a VAL specification is projected as a variable,
  ;; while constructor specifications retain their constructor identity.
  (let ((basis
          (%basis
           "structure E : sig val Exn : exn end = struct exception Exn end;
            local open E in val Exn = Exn end;
            val exception_value = Exn;
            structure D :> sig type t val A : t end = struct datatype t = A end;
            local open D in val A = A end;
            val datatype_value = A;
            structure C : sig datatype t = A end = struct datatype t = A end;
            val constructor_value = C.A;")))
    (%binding basis "exception_value")
    (%check (%binding basis "D.A") (%binding basis "datatype_value"))
    (%check (%binding basis "C.A") (%binding basis "constructor_value")))

  ;; Rigid scheme matching operates on occurrence-local copies.  Opaque views
  ;; retain a well-formed polymorphic scheme and can be instantiated repeatedly.
  (let ((basis
          (%basis
           "structure S :> sig
              type ('a,'b) t
              val f : ('a,'b) t -> ('b,'a) t
              val mk : 'a * 'b -> ('a,'b) t
              val read : ('a,'b) t -> 'b * 'a
            end = struct
              type ('a,'b) t = 'b * 'a
              fun f (x,y) = (y,x)
              fun mk (a,b) = (b,a)
              fun read (x,y) = (x,y)
            end;
            val pair = S.f (S.mk (5,true));
            val answer = case S.read pair of (n,flag) => if flag then n else 0;
            signature Id = sig val id : 'a -> 'a end;
            structure I :> Id = struct fun id x = x end;
            structure J :> Id = struct fun id x = x end;
            val integer = I.id 9;
            val string = J.id \"fresh\";
            val again = I.id 10;")))
    (%check 5 (%binding basis "answer"))
    (%check 9 (%binding basis "integer"))
    (%check 10 (%binding basis "again"))
    (%check "fresh" (%binding basis "string")))

  ;; Type sharing accepts arity-matched aliases only after their nominal
  ;; dependencies are realized.  Structure sharing covers every pair while
  ;; ignoring components absent from either participant.
  (let ((basis
          (%basis
           "signature Alias = sig
              type 'a t
              type 'a s = 'a t
              sharing type s = t
            end;
            signature A = sig type t end;
            signature B = sig type s structure A : A where type t = s end;
            signature C = sig
              structure A : A
              structure B : B
              sharing type A.t = B.s = B.A.t
            end;
            functor F (structure A : sig type t end
                       structure B : sig type u end
                       structure C : sig type t end
                       structure D : sig type u end
                       sharing A = B = C = D) = struct
              val atoc : A.t -> C.t = fn x => x
              val btod : B.u -> D.u = fn x => x
            end;
            val answer = 11;")))
    (%check 11 (%binding basis "answer")))
  (%rejects-module
   "signature Concrete = sig type t = int end;
    signature Bad = sig
      structure S1 : Concrete
      structure S2 : Concrete
      sharing type S1.t = S2.t
    end;")

  ;; Nominal matching precedes every dependent alias comparison, including
  ;; projected entries introduced by a parent's flattened structure view.
  (let ((basis
          (%basis
           "signature T = sig
              type s
              structure V : sig type v end where type v = s
            end;
            structure U : T = struct
              type s = int
              structure V = struct type v = s end
            end;
            val answer = 12;")))
    (%check 12 (%binding basis "answer")))

  ;; A DATATYPE WHERE TYPE refinement requires a nominal result of the same
  ;; arity.  Primitive ref/int are valid TyNames; functions and rows are not.
  (%rejects-module
   "signature Bad = sig datatype t = T end where type t = int * int;")
  (%rejects-module
   "signature Bad = sig datatype ('a,'b) t = T of 'a -> 'b end
      where type ('a,'b) t = 'a -> 'b;")
  (%rejects-module
   "signature Bad = sig datatype t = T of unit end where type t = unit;")
  (let ((basis
          (%basis
           "signature Refinement = sig datatype 'a t = T of 'a ref end
              where type 'a t = 'a ref;
            signature Integral = sig datatype t = T of int end where type t = int;
            val answer = 13;")))
    (%check 13 (%binding basis "answer")))

  ;; A constructor-bearing datatype spec cannot be met by an abbreviation at
  ;; another path; genuine datatype replication remains nominal and valid.
  (%rejects-module
   "structure S : sig eqtype t structure Z : sig datatype u = U end end = struct
      structure Z = struct datatype u = U end
      datatype t = datatype Z.u
      structure Z = struct
        type u = Z.u
        datatype z = datatype Z.u
      end
    end;")
  (let ((basis
          (%basis
           "datatype d = D of int;
            structure R : sig datatype t = D of int end =
              struct datatype t = datatype d end;
            val answer = case R.D 14 of D n => n;")))
    (%check 14 (%binding basis "answer")))

  ;; WHERE follows nominal identities through aliases, but never erases a
  ;; specified arity.  Weak mutable state cannot prove a universal signature.
  (%basis
   "signature Alias = sig type t type s = t end where type s = int;
    signature Dependent = sig
      type s
      structure U : sig type 'a t type u = (int * real) t end where type 'a t = s
    end where type U.u = int;")
  (%rejects-module "signature Bad = sig type 'a t end where type t = int;")
  (%rejects-module
   "structure S : sig val f : 'a option -> 'a option end = struct
      val f = let val r = ref NONE in fn z => (!r before (r := z)) end
    end;")
  (%basis
   "structure S : sig val f : 'a option -> 'a option end =
      struct fun f z = z end;"))

(defun %nominal-lifetime-boundary-tests ()
  (dolist
      (source
       (list
        "local
           val f = let val f = (fn x => x) (fn x => x) in f end
           structure T = struct datatype t = A end
           val g = fn x => let val d = #1 x
                               val k = #2 x
                               val s = f (d,k)
                               val _ = if true then (d,k) else x
                           in s end
         in
           val a : T.t * T.t = g (T.A,T.A)
         end;"
        "structure Outer = struct
           local
             val f = (fn x => x) (fn x => x)
             structure T = struct datatype t = A end
             val g = f
           in
             structure U = struct val rejected : T.t -> T.t = g end
           end
         end;"
        "structure S = let
           val f = (fn x => x) (fn x => x)
           structure T = struct datatype t = A end
           val g = f
         in
           struct val rejected : T.t -> T.t = g end
         end;"))
    (let ((condition
            (handler-case
                (progn (%compile source) nil)
              (sml-elaboration-error (condition) condition))))
      (is condition () "A module-local weak variable acquired a later nominal identity:~%~A" source)
      (when condition
        (is (eq :static (elaboration-error-kind condition)) ()
            "Module-local nominal lifetime rejection was not static: ~A" condition))))
  (let ((basis
          (%basis
           "structure S = let
              structure T = struct datatype t = A end
              val f = (fn x => x) (fn x => x)
              val g = f
            in
              struct val h : T.t -> T.t = g val A = T.A end
            end;
            val result = S.h S.A;")))
    (%check (%binding basis "S.A") (%binding basis "result")))
  (let ((basis
          (%basis
           "structure Old = struct datatype t = A end;
            local
              val f = (fn x => x) (fn x => x)
              structure Alias = struct datatype t = datatype Old.t end
              val g = f
            in
              structure S = struct
                val h : Old.t -> Old.t = g
                val result = h Old.A
              end
            end;
            val result = S.result;")))
    (%check (%binding basis "Old.A") (%binding basis "result"))))

(defun %generation-uniqueness-tests ()
  ;; Own and nested generation lists share these identities through aliases.
  ;; Deduplication must preserve their first-seen order without confusing a
  ;; nominal identity with its source spelling or with an opaque realization.
  (let ((basis
          (%basis
           "structure Plant = struct
              datatype species = Sprout
              structure Graft = struct datatype cutting = datatype species end
              structure Alias = Graft
            end;
            structure Same = Plant;
            val original = Plant.Sprout;
            val aliased = Plant.Alias.Sprout;
            val copied = Same.Graft.Sprout;
            val result = case copied of Plant.Sprout => 42;
            signature S = sig eqtype t val A : t end;
            structure Revealed = struct datatype t = A end;
            structure Opaque :> S = Revealed;
            structure OpaqueAlias = Opaque;
            val opaqueSame = Opaque.A = OpaqueAlias.A;")))
    (is (eq (constructor-identity (%binding basis "original"))
            (constructor-identity (%binding basis "aliased"))))
    (is (eq (constructor-identity (%binding basis "original"))
            (constructor-identity (%binding basis "copied"))))
    (%check 42 (%binding basis "result"))
    (%check ooparts/sml/runtime:+true+ (%binding basis "opaqueSame"))
    (%rejects-condition 'sml-type-error "val bad = Revealed.A = Opaque.A;" basis)
    (%rejects-condition 'sml-type-error "val bad = Revealed.A = Plant.Sprout;" basis)))

(defun %nested-formal-root-tests ()
  (let ((basis
          (%basis
           "structure Set = struct datatype Set = S end;
            signature FINMAPEQ = sig type map val dom : map -> Set.Set end;
            functor FinMapEq () = struct datatype map = M fun dom m = Set.S end;
            signature TOOLS = sig structure FinMapEq : FINMAPEQ end;
            functor Tools () : TOOLS = struct structure FinMapEq = FinMapEq() end;
            functor Basics (structure Tools : TOOLS) =
              struct structure Tools = Tools end;
            functor KitCompiler () = struct
              structure Tools = Tools()
              structure Basics = Basics(structure Tools = Tools)
            end;
            structure K = KitCompiler();")))
    (%binding basis "K.Basics.Tools.FinMapEq.dom")))

(defun run-module-tests ()
  (with-suite ("ooparts-tests/sml/modules/native")
    (%namespace-and-scope-tests)
    (%signature-view-tests)
    (%where-sharing-and-replication-tests)
    (%functor-tests)
    (%rollback-fixity-and-batch-tests)
    (%opaque-signature-boundary-tests)
    (%rigid-and-named-signature-tests)
    (%open-namespace-regression-tests)
    (%equality-refinement-and-sharing-tests)
    (%ordinary-module-semantic-regression-tests)
    (%nominal-lifetime-boundary-tests)
    (%generation-uniqueness-tests)
    (%nested-formal-root-tests)))
