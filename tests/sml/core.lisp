(uiop:define-package #:ooparts-tests/sml/core
  (:use #:cl)
  (:import-from #:ooparts/test #:with-suite #:is #:signals)
  (:import-from #:ooparts/curry #:lambda/c)
  (:import-from #:ooparts/sml/compiler
    #:compile-source #:compiled-code #:run-program #:lookup-value #:value-type
    #:value-to-string)
  (:import-from #:ooparts/sml/types #:sml-type-error)
  (:import-from #:ooparts/sml/elaborate
    #:sml-elaboration-error #:elaboration-error-kind)
  (:import-from #:ooparts/sml/source
    #:sml-source-error #:sml-error-span #:source-text #:source-span-source)
  (:import-from #:ooparts/sml/runtime
    #:+unit+ #:+true+ #:+false+ #:+match-exception+ #:+bind-exception+
    #:make-sml-word
    #:sml-equal #:sml-constructed-p #:sml-constructed-name
    #:sml-constructed-payload #:constructor-identity
    #:make-sml-record #:sml-record-p #:sml-record-field #:sml-record-fields
    #:make-sml-list #:sml-list-values #:sml-reference-contents
    #:sml-raise #:sml-raise-value)
  (:export #:run-core-tests))
(in-package #:ooparts-tests/sml/core)

(defun %compile (source &optional basis)
  (if basis
      (compile-source source :source-name "<core test>" :basis basis)
      (compile-source source :source-name "<core test>")))

(defun %execute (source &optional basis)
  (let ((program (%compile source basis)))
    ;; Finish host compilation before a test binds the SML output stream.
    ;; The cached host function is then reused by the ordinary public runner.
    (ooparts/sml/compiler::%host-function program)
    (run-program program :basis basis)))

(defun %value (source &optional basis)
  (nth-value 0 (%execute source basis)))

(defun %basis (source &optional basis)
  (nth-value 1 (%execute source basis)))

(defun %binding (basis name)
  (multiple-value-bind (value present-p) (lookup-value basis name)
    (is present-p () "Expected an executed binding for ~S." name)
    value))

(defun %check-equal (expected value)
  (is (sml-equal expected value) ()
      "Expected SML value ~A, got ~A."
      (value-to-string expected) (value-to-string value)))

(defun %check-record (value fields)
  (is (sml-record-p value) () "Expected an SML record, got ~S." value)
  (is (= (length fields) (length (sml-record-fields value))) ()
      "Wrong SML record field count for ~S." value)
  (dolist (field fields)
    (%check-equal (cdr field) (sml-record-field value (car field)))))

(defun %check-list (value expected)
  (multiple-value-bind (elements proper-p) (sml-list-values value)
    (is proper-p () "Expected a proper SML list, got ~S." value)
    (when proper-p
      (is (= (length expected) (length elements)) ()
          "Expected ~D SML list elements, got ~D."
          (length expected) (length elements))
      (loop for wanted in expected
            for actual in elements
            do (%check-equal wanted actual)))))

(defun %capture-raise (thunk)
  (handler-case
      (progn
        (funcall thunk)
        (is nil () "Expected an uncaught SML exception.")
        nil)
    (sml-raise (condition) condition)))

(defun %check-word-range-error (source)
  (handler-case
      (progn
        (%compile source)
        (is nil () "Expected a Word literal range error for ~S." source))
    (sml-elaboration-error (condition)
      (is (eq :range (elaboration-error-kind condition)) ()
          "Expected :RANGE for ~S, got ~S." source
          (elaboration-error-kind condition))
      (let ((span (sml-error-span condition))
            (message (princ-to-string condition)))
        (is span () "A Word literal range error has no source span.")
        (when span
          (is (string= source (source-text (source-span-source span))) ()
              "The range error points into the wrong source."))
        (is (search "32-bit" message) ()
            "The range diagnostic omits the configured width: ~A" message)
        (is (search "4294967295" message) ()
            "The range diagnostic omits the upper bound: ~A" message)))))

(defun %function-tests ()
  (let ((program (%compile "val x=2; x+3;")))
    (let ((code (compiled-code program)))
      (is (and (consp code) (eq 'lambda/c (first code))) ()
          "The compiled result is not an inspectable Curry function: ~S" code))
    (multiple-value-bind (value basis) (run-program program)
      (%check-equal 5 value)
      (%check-equal 2 (%binding basis "x"))
      (%check-equal 5 (%binding basis "it"))
      (is (string= "5" (value-to-string value)))
      (%check-equal 10 (%value "it*2;" basis))))

  (let ((basis
          (%basis
           "val id=fn x=>x;
            val twice=fn f=>fn x=>f (f x);
            val inc=fn x=>x+1;
            val three=twice inc 1;
            val make=fn x=>fn y=>fn z=>x*100+y*10+z;
            val partial=make 4;
            val almost=partial 5;
            val answer=almost 6;")))
    (%check-equal 3 (%binding basis "three"))
    (%check-equal 456 (%binding basis "answer"))
    ;; OLD-BINDING lookup must preserve the already curried function as well.
    (%check-equal 478 (%value "partial 7 8;" basis)))

  (let ((basis
          (%basis
           "fun fact 0=1 | fact n=n*fact(n-1);
            val rec fib=fn 0=>0 | 1=>1 | n=>fib(n-1)+fib(n-2);
            val answer=(fact 6,fib 10);")))
    (%check-record (%binding basis "answer")
                   (list (cons "1" 720) (cons "2" 55)))))

(defun %old-binding-tests ()
  (let* ((old (%basis "val x=10; val addx=fn y=>x+y;"))
         (new
           (%basis
            "val alias=addx;
             val x=100;
             val apply=fn f=>fn n=>f n;
             val lifted=apply alias;
             val direct=alias 5;
             val indirect=lifted 6;"
            old)))
    (%check-equal 100 (%binding new "x"))
    (%check-equal 15 (%binding new "direct"))
    (%check-equal 16 (%binding new "indirect"))
    ;; Shadowing ADDX later cannot retarget either lexical closure.
    (let ((latest (%basis "val addx=fn y=>0; val answer=alias 7;" new)))
      (%check-equal 17 (%binding latest "answer"))
      (%check-equal 18 (%value "lifted 8;" latest)))))

(defun %capture-factory-tests ()
  (let ((basis
          (%basis
           "fun apply (f,x) = f x;
            val directPlus = apply (op +, (1,2));
            val directScalar = apply (fn x => x+2, 3);
            val directRecord = apply (fn {a,b} => a+b, {a=3,b=4});
            fun makeAdder x = fn y => x+y;
            val partial = makeAdder 4;
            val partialPlus = partial 5;
            fun outer n = let
              val seed = 10
              fun inner x = if n=0 then seed+x else outer (n-1) + x
            in inner n end;
            val nested = outer 2;
            fun even 0 = true | even n = odd (n-1)
            and odd 0 = false | odd n = even (n-1);
            val mutual = even 11;
            val rec first = fn n => if n=0 then 0 else 1 + first (n-1);
            val rec second = fn n => if n=0 then first 42 else second (n-1);
            val directRecursion = first 100;
            val crossRecursion = second 100;
            val shadowed = let val x=5 in let val x=7 in (fn y=>x+y) end end 2;
            val cell = ref 8;
            val alias = cell;
            val _ = alias := 9;
            val aliased = !cell;")))
    (%check-equal 3 (%binding basis "directPlus"))
    (%check-equal 5 (%binding basis "directScalar"))
    (%check-equal 7 (%binding basis "directRecord"))
    (%check-equal 9 (%binding basis "partialPlus"))
    (%check-equal 13 (funcall (%binding basis "partial") 9))
    (%check-equal 13 (%binding basis "nested"))
    (%check-equal +false+ (%binding basis "mutual"))
    (%check-equal 100 (%binding basis "directRecursion"))
    (%check-equal 42 (%binding basis "crossRecursion"))
    (%check-equal 9 (%binding basis "shadowed"))
    (%check-equal 9 (%binding basis "aliased"))
    (is (eq (%binding basis "cell") (%binding basis "alias")) ()
        "A reference and its captured alias did not share the runtime cell."))
  ;; A pair-argument function cannot be partially applied as a curried one.
  (signals sml-type-error
    (%compile "fun apply (f,x) = f x; val invalid = apply (op +);"))
  (signals sml-type-error
    (%compile "fun outer n = let fun inner x = n+x in inner end;
               val invalid = outer true 1;")))

(defun %named-function-clause-tests ()
  (let ((basis
          (%basis
           "val k = 100;
            fun biased 0 = k | biased n = n + k;
            val lexical = (biased 0, biased 2);
            fun fan 0 0 0 = 10
              | fan 0 0 z = z
              | fan 0 y 0 = y
              | fan x y z = x + y + z;
            val fallThrough = (fan 0 0 7, fan 0 6 0, fan 2 3 4);
            fun zero 0 = 0 | zero _ = 9;
            val zeroResult = zero 0;
            fun empty 0 = [] | empty _ = [9];
            val emptyResult = empty 0;
            fun falseValue 0 = false | falseValue _ = true;
            val falseResult = falseValue 0;
            fun unitValue 0 = () | unitValue _ = raise Fail \"clause failure\";
            val unitResult = unitValue 0;
            fun make 0 y = fn () => y | make x y = fn () => x + y;
            val firstClosure = make 0 5;
            val secondClosure = make 0 8;
            val thirdClosure = make 2 3;
            val closures =
              (firstClosure (), secondClosure (), firstClosure (), thirdClosure ());
            fun descend 0 = 0 | descend n = 1 + descend (n - 1);
            fun even 0 = true | even n = odd (n - 1)
            and odd 0 = false | odd n = even (n - 1);
            val rec first = fn 0 => 0 | n => 1 + second (n - 1)
            and second = fn 0 => 0 | n => 1 + first (n - 1);
            val recursive = (descend 30, even 22, first 6);")))
    (%check-record (%binding basis "lexical") '(("1" . 100) ("2" . 102)))
    (%check-record (%binding basis "fallThrough")
                   '(("1" . 7) ("2" . 6) ("3" . 9)))
    (%check-equal 0 (%binding basis "zeroResult"))
    (%check-list (%binding basis "emptyResult") nil)
    (%check-equal +false+ (%binding basis "falseResult"))
    (%check-equal +unit+ (%binding basis "unitResult"))
    ;; Each activation's native pattern frame must remain with its own closure.
    (%check-record (%binding basis "closures")
                   '(("1" . 5) ("2" . 8) ("3" . 5) ("4" . 5)))
    (%check-record (%binding basis "recursive")
                   (list (cons "1" 30) (cons "2" +true+) (cons "3" 6))))
  (let* ((old (%basis "val k=10; fun f 0=k | f n=n+k; val a=f 2;"))
         (new (%basis
               "val alias=f;
                val k=100;
                val b=f 3;
                val f=fn n=>0;
                val c=alias 4;
                val direct=f 9;" old)))
    (%check-equal 12 (%binding old "a"))
    (%check-equal 100 (%binding new "k"))
    (%check-equal 13 (%binding new "b"))
    (%check-equal 14 (%binding new "c"))
    (%check-equal 0 (%binding new "direct"))))

(defun %ordered-clause-continuation-execution-test ()
  (let ((basis
          (%basis
           "val additions = ref 0;
            fun pendingSum 0 = 0
              | pendingSum n =
                  let val result = pendingSum (n - 1)
                  in additions := !additions + 1; result + n end;
            val normalResult = pendingSum 1024;
            val normalAdditions = !additions;
            val _ = additions := 0;
            exception Stop;
            fun committedBase 0 = raise Stop
              | committedBase _ = 100;
            fun unwind 0 = committedBase 0
              | unwind n =
                  let val result = unwind (n - 1)
                  in additions := !additions + 1; result + n end;
            val exceptionalResult = unwind 1024 handle Stop => ~1;
            val exceptionalAdditions = !additions;")))
    (%check-equal 524800 (%binding basis "normalResult"))
    (%check-equal 1024 (%binding basis "normalAdditions"))
    (%check-equal -1 (%binding basis "exceptionalResult"))
    (%check-equal 0 (%binding basis "exceptionalAdditions"))))

(defun %sml-or-tail-normalization-tests ()
  (let ((basis
          (%basis
           "val results =
              (case 0 of 0 => 0 | _ => 9,
               case 0 of 0 => false | _ => true,
               case 0 of 0 => () | _ => raise Fail \"wrong\",
               case 0 of 0 => \"\" | _ => \"wrong\",
               case 0 of 0 => [] | _ => [9],
               case 1 of 0 => 0 | 1 => 7 | _ => 9);")))
    ;; Host NIL is only a native-rule non-match, never one of these results.
    (%check-record (%binding basis "results")
                   (list (cons "1" 0) (cons "2" +false+) (cons "3" +unit+)
                         (cons "4" "") (cons "5" (make-sml-list nil))
                         (cons "6" 7))))
  (let* ((depth #+sbcl 6000000 #-sbcl 250000)
         ;; The old SBCL heap failure occurred below six million calls.  Use
         ;; the same substantive recursion on other hosts without imposing
         ;; this implementation-tailored stress timing on them.
         (basis
           (%basis
            (format nil
                    "fun caseLoop left = case left of 0 => 0
                       | _ => caseLoop (left - 1);
                     fun clauseLoop 0 = 0
                       | clauseLoop left = clauseLoop (left - 1);
                     val answers = (caseLoop ~D, clauseLoop ~D);"
                    depth depth))))
    (%check-record (%binding basis "answers") '(("1" . 0) ("2" . 0)))))

(defun %pattern-tests ()
  (let ((basis
          (%basis
           "val pick=fn 0=>10 | 1=>11 | n=>n+20;
            val answers=(pick 0,pick 1,pick 2);")))
    (%check-record (%binding basis "answers")
                   (list (cons "1" 10) (cons "2" 11) (cons "3" 22))))

  (let ((condition
          (%capture-raise
           (lambda () (%execute "(fn 0=>0 | 1=>1) 2;")))))
    (is (eq +match-exception+ (sml-raise-value condition)) ()
        "An exhausted match did not raise the pervasive Match exception."))

  (let ((condition
          (%capture-raise
           (lambda () (%execute "val (x,0)=(1,2);")))))
    (is (eq +bind-exception+ (sml-raise-value condition)) ()
        "A failed top-level value pattern did not raise Bind.")))

(defun %record-and-list-tests ()
  (let ((basis
          (%basis
           "val pair=(3,\"four\");
            val recd={b=2,a=1};
            val selected=(#1 pair,#2 pair,#a recd,#b recd);
            val getA=#a;
            val selectedStandalone=getA recd;
            val destructured=let val {a,b}=recd in a*10+b end;")))
    (%check-record (%binding basis "pair")
                   (list (cons "1" 3) (cons "2" "four")))
    (%check-record (%binding basis "recd")
                   (list (cons "a" 1) (cons "b" 2)))
    (%check-record (%binding basis "selected")
                   (list (cons "1" 3) (cons "2" "four")
                         (cons "3" 1) (cons "4" 2)))
    (%check-equal 1 (%binding basis "selectedStandalone"))
    (%check-equal 12 (%binding basis "destructured")))

  (let ((basis
          (%basis
           "val xs=1::2::[3,4];
            val tail=case xs of _::_::rest=>rest | _=>nil;
            val empty=[];
            val same=xs=[1,2,3,4];
            val different=xs<>[1,2];")))
    (%check-list (%binding basis "xs") '(1 2 3 4))
    (%check-equal (make-sml-list '(1 2 3 4)) (%binding basis "xs"))
    (%check-list (%binding basis "tail") '(3 4))
    (%check-list (%binding basis "empty") nil)
    (%check-equal +true+ (%binding basis "same"))
    (%check-equal +true+ (%binding basis "different"))))

(defun %datatype-tests ()
  (let ((basis
          (%basis
           "datatype color=Red | RGB of int;
            val a=Red;
            val b=RGB 7;
            val same=RGB 7=RGB 7;
            val distinct=Red<>RGB 0;
            val decoded=case b of Red=>0 | RGB n=>n;")))
    (%check-equal +true+ (%binding basis "same"))
    (%check-equal +true+ (%binding basis "distinct"))
    (%check-equal 7 (%binding basis "decoded"))
    (let ((a (%binding basis "a"))
          (b (%binding basis "b")))
      (is (sml-constructed-p a))
      (is (sml-constructed-p b))
      (is (not (eq (constructor-identity a) (constructor-identity b))) ()
          "Different constructors of one datatype shared an identity.")
      (is (string= "RGB" (sml-constructed-name b)))
      (%check-equal 7 (sml-constructed-payload b)))

    (let* ((replicated
             (%basis
              "datatype shade=datatype color;
               val copied=RGB 7;
               val same=b=copied;
               val decoded=case copied of Red=>0 | RGB n=>n;"
              basis))
           (original (%binding basis "b"))
           (copy (%binding replicated "copied")))
      (is (eq (constructor-identity original) (constructor-identity copy)) ()
          "Datatype replication did not preserve constructor identity.")
      (%check-equal +true+ (%binding replicated "same"))
      (%check-equal 7 (%binding replicated "decoded")))

    ;; Generativity is about type identity, not the generated identity spelling.
    (signals sml-type-error
      (%compile "datatype color=Red | RGB of int; val bad=b=RGB 7;" basis)))

  (let ((basis
          (%basis
           "abstype box=Box of int
            with
              val make=Box
              val get=fn Box n=>n
            end;
            val answer=get(make 41);")))
    (%check-equal 41 (%binding basis "answer"))
    ;; BOX was available to the implementation declarations, not to clients.
    (signals sml-type-error (%compile "Box 1;" basis))))

(defun %control-and-mutation-tests ()
  (let ((basis
          (%basis
           "val log=ref [];
            val mark=fn n=>(log := n :: ! log; true);
            val a=false andalso mark 1;
            val b=true orelse mark 2;
            val c=true andalso mark 3;
            val d=false orelse mark 4;
            val computed=let val x=4 val y=5 in x+y; x*y; x*y+y end;
            val flags=(a,b,c,d);")))
    (%check-equal 25 (%binding basis "computed"))
    (%check-record (%binding basis "flags")
                   (list (cons "1" +false+) (cons "2" +true+)
                         (cons "3" +true+) (cons "4" +true+)))
    (%check-list (sml-reference-contents (%binding basis "log")) '(4 3)))

  (let ((basis
          (%basis
           "val r=ref 0;
            val unitResult=while ! r < 4 do r := ! r + 1;
            val assigned=(r := 9);
            val answer=(r := 9; ! r);")))
    (%check-equal +unit+ (%binding basis "unitResult"))
    (%check-equal +unit+ (%binding basis "assigned"))
    (%check-equal 9 (%binding basis "answer"))
    (%check-equal 9 (sml-reference-contents (%binding basis "r")))))

(defun %exception-tests ()
  (let ((basis
          (%basis
           "exception E of int;
            exception F=E;
            exception G of int;
            val left=E 7;
            val alias=F 7;
            val other=G 7;
            val caught=(raise E 7) handle G _=>0 | F n=>n+1;
            val notCaptured=(raise G 9) handle F _=>0 | G n=>n;")))
    (%check-equal 8 (%binding basis "caught"))
    (%check-equal 9 (%binding basis "notCaptured"))
    (let ((left (%binding basis "left"))
          (alias (%binding basis "alias"))
          (other (%binding basis "other")))
      (is (eq (constructor-identity left) (constructor-identity alias)) ()
          "An exception alias acquired a fresh identity.")
      (is (not (eq (constructor-identity left) (constructor-identity other))) ()
          "Independent exception declarations shared an identity."))))

(defun %failed-commit-tests ()
  (let* ((basis (%basis "val cell=ref 0;"))
         (cell (%binding basis "cell"))
         (program
           (%compile "exception Stop; cell := 9; val fresh=42; raise Stop;"
                     basis))
         (condition
           (%capture-raise (lambda () (run-program program :basis basis)))))
    (is (sml-constructed-p (sml-raise-value condition)))
    (when (sml-constructed-p (sml-raise-value condition))
      (is (string= "Stop" (sml-constructed-name (sml-raise-value condition))))
      (%check-equal +unit+ (sml-constructed-payload (sml-raise-value condition))))
    (%check-equal 9 (sml-reference-contents cell))
    (is (not (nth-value 1 (lookup-value basis "fresh"))) ()
        "A declaration before an uncaught exception was dynamically committed.")
    (is (not (nth-value 1 (value-type basis "fresh"))) ()
        "A declaration before an uncaught exception was statically committed.")
    (is (not (nth-value 1 (lookup-value basis "Stop"))) ()
        "An exception constructor from the failed program was committed.")
    ;; A later successful program still observes the shared reference object.
    (%check-equal 9 (%value "(! cell) + 0;" basis))))

(defun %static-and-scheme-tests ()
  (dolist (source '("val f=fn x=>x x;"
                    "val wrong:int=\"text\";"
                    "val f=fn x=>x+1; val bad=f true;"
                    "missing+1;"))
    (signals sml-type-error (%compile source)))

  (let ((basis
          (%basis
           "val id=fn x=>x;
            val intResult=id 7;
            val boolResult=id true;")))
    (%check-equal 7 (%binding basis "intResult"))
    (%check-equal +true+ (%binding basis "boolResult"))
    (multiple-value-bind (text present-p) (value-type basis "id")
      (is present-p () "No principal type was committed for ID.")
      (when present-p
        (is (search "forall" text) () "ID was not rendered as a scheme: ~S" text)
        (is (search "->" text) () "ID lost its function type: ~S" text))))

  ;; Expansive bindings are not generalized, either locally or in an old basis.
  (signals sml-type-error
    (%compile "val r=ref []; val ints=r := [1]; val bad=r := [\"text\"];"))
  (let* ((basis (%basis "val r=ref [];"))
         (reference (%binding basis "r"))
         (specialized (%basis "r := [1,2];" basis)))
    (%check-list (sml-reference-contents reference) '(1 2))
    (signals sml-type-error
      (%compile "val bad=\"text\" :: ! r;" specialized))))

(defun %output-preservation-test ()
  (let* ((basis (%basis "val cell=ref 0;"))
         (cell (%binding basis "cell"))
         (output (make-string-output-stream))
         (program (%compile "exception Stop; print \"kept\"; cell := 11; raise Stop;"
                            basis)))
    (ooparts/sml/compiler::%host-function program)
    (let ((*standard-output* output))
      (%capture-raise (lambda () (run-program program :basis basis))))
    (is (string= "kept" (get-output-stream-string output)) ()
        "Output before an uncaught exception was rolled back.")
    (%check-equal 11 (sml-reference-contents cell))))

(defun %declaration-and-equality-tests ()
  (let ((basis
          (%basis
           "type pair=int*bool;
            val checked:pair=(1,true);
            infix 6 ++;
            fun x ++ y=x+y;
            val applied=3 ++ 4;
            val ref n=ref 5;
            val unitEqual=({}=());")))
    (%check-record (%binding basis "checked")
                   (list (cons "1" 1) (cons "2" +true+)))
    (%check-equal 7 (%binding basis "applied"))
    (%check-equal 5 (%binding basis "n"))
    (%check-equal +true+ (%binding basis "unitEqual"))
    (signals sml-type-error (%compile "val bad=(1.0=1.0);" basis))
    (signals sml-type-error
      (%compile "datatype realBox=R of real; val bad=(R 1.0=R 2.0);" basis)))

  (let ((basis
          (%basis
           "local val hidden=1 type secret=int in val shown=2 end;")))
    (%check-equal 2 (%binding basis "shown"))
    (signals sml-type-error (%compile "hidden;" basis))
    (signals sml-type-error (%compile "val bad:secret=1;" basis))))

(defun %primitive-arithmetic-tests ()
  (let ((basis
          (%basis
           "val quotient=0w7 div 0w2;
            val remainder=0w7 mod 0w2;
            val wrappedAdd=0w4294967295+0w1;
            val wrappedSubtract=0w0-0w1;
            val wrappedMultiply=0w4294967295*0w2;
            val zero=0w0;
            val maximum=0w4294967295;
            val divZero=(0w7 div 0w0; false) handle Div=>true;
            val modZero=(0w7 mod 0w0; false) handle Div=>true;
            val intQuotient = ~7 div 2;
            val intRemainder = ~7 mod 2;
            val negativeDivisorQuotient=7 div ~2;
            val negativeDivisorRemainder=7 mod ~2;
            val divDefault=fn x=>x div 2;
            val modDefault=fn x=>x mod 2;
            val addDefault=fn x=>x+x;
            val subtractDefault=fn x=>x-1;
            val multiplyDefault=fn x=>x*x;
            val absDefault=fn x=>abs x;
            val negateDefault=fn x => ~x;
            val orderedDefault=fn x=>x<1;
            val integerAbs=abs ~7;
            val integerNegation = ~7;
            val realAbs=abs ~1.5;
            val realNegation = ~1.5;
            val realDivision=4.0 / 2.0;")))
    (dolist (entry (list (cons "quotient" 3) (cons "remainder" 1)
                         (cons "wrappedAdd" 0)
                         (cons "wrappedSubtract" 4294967295)
                         (cons "wrappedMultiply" 4294967294)
                         (cons "zero" 0) (cons "maximum" 4294967295)))
      (%check-equal (make-sml-word (cdr entry))
                    (%binding basis (car entry))))
    (dolist (name '("divZero" "modZero"))
      (%check-equal +true+ (%binding basis name)))
    (dolist (entry (list (cons "intQuotient" -4) (cons "intRemainder" 1)
                         (cons "negativeDivisorQuotient" -4)
                         (cons "negativeDivisorRemainder" -1)
                         (cons "integerAbs" 7) (cons "integerNegation" -7)))
      (%check-equal (cdr entry) (%binding basis (car entry))))
    (dolist (name '("divDefault" "modDefault" "addDefault" "subtractDefault"
                    "multiplyDefault" "absDefault" "negateDefault"))
      (multiple-value-bind (type present-p) (value-type basis name)
        (is present-p () "No committed type for ~A." name)
        (when present-p
          (is (and (search "int#SML-INT-TYPE" type)
                   (not (search "real#" type))
                   (not (search "word#" type))
                   (search "->" type))
              () "Wrong default overload type for ~A: ~A" name type))))
    (multiple-value-bind (type present-p) (value-type basis "orderedDefault")
      (is present-p)
      (when present-p
        (is (and (search "int#SML-INT-TYPE" type)
                 (search "bool#SML-BOOL-TYPE" type)
                 (not (search "word#" type))
                 (search "->" type)))))
    (%check-equal 2 (%value "divDefault 5;" basis))
    (is (= 1.5d0 (%binding basis "realAbs")))
    (is (= -1.5d0 (%binding basis "realNegation")))
    (is (= 2.0d0 (%binding basis "realDivision"))))
  (signals sml-type-error (%compile "val bad=abs 0w1;"))
  (signals sml-type-error (%compile "val bad = ~ 0w1;"))
  (%check-word-range-error "val bad=0w4294967296;")
  (%check-word-range-error
   "val bad=0w340282366920938463463374607431768211456;")
  (%check-word-range-error
   "val bad=case 0w0 of 0w4294967296=>0 | _=>1;"))

(defun %reference-equality-tests ()
  (let ((basis
          (%basis
           "datatype box=Box of real ref;
            val r=ref 1.0;
            val alias=r;
            val same=r=r;
            val fresh=r=ref 1.0;
            val aliasSame=r=alias;
            val changed=(alias := 2.0; !r);
            val f=ref (fn x:int=>x);
            val functionSame=f=f;
            val functionFresh=f=ref (fn x:int=>x);
            val xs=[r,ref 3.0];
            val listSame=xs=xs;
            val listFresh=xs=[ref 2.0,ref 3.0];
            val b=Box r;
            val boxSame=b=b;
            val boxFresh=b=Box(ref 2.0);
            val integerControl=1=1;")))
    (dolist (name '("same" "aliasSame" "functionSame" "listSame" "boxSame"
                    "integerControl"))
      (%check-equal +true+ (%binding basis name)))
    (dolist (name '("fresh" "functionFresh" "listFresh" "boxFresh"))
      (%check-equal +false+ (%binding basis name)))
    (is (= 2.0d0 (%binding basis "changed")) ()
        "Mutating a real-reference alias did not update the original cell."))
  (signals sml-type-error (%compile "val bad=1.0=1.0;"))
  (signals sml-type-error
    (%compile "val f=fn x:int=>x; val bad=f=f;")))

(defun %primitive-shadowing-tests ()
  (let ((basis
          (%basis
           "datatype bool=B;
            val source=B;
            val typedBool:bool=B;
            val branch=if true then 1 else 2;
            datatype int=I;
            val integerSource=I;
            val typedInt:int=I;
            val number=1+2;
            datatype word=W;
            val wordSource=W;
            val typedWord:word=W;
            val wordResult=0w4294967295+0w1;
            datatype 'a list=L of 'a;
            val typedList:bool list=L source;
            val listCase=case typedList of L B=>5;
            val numbers=[1,2,3];
            val extracted=case numbers of h::_=>h | nil=>0;")))
    (%check-equal 1 (%binding basis "branch"))
    (%check-equal 3 (%binding basis "number"))
    (%check-equal (make-sml-word 0) (%binding basis "wordResult"))
    (%check-equal 5 (%binding basis "listCase"))
    (%check-equal 1 (%binding basis "extracted"))
    (dolist (name '("typedBool" "typedInt" "typedWord" "typedList"))
      (%binding basis name)))
  (dolist (source
           '("datatype bool=B; val bad=if B then 1 else 2;"
             "datatype int=I; val bad=I+I;"
             "datatype word=W; val bad=0w1+W;"
             "datatype 'a list=L of 'a; val bad:int list=[1,2];"))
    (signals sml-type-error (%compile source))))

(defun %batch-eof-tests ()
  (signals sml-source-error (%compile ""))
  (let ((basis
          (nth-value
           1 (run-program
              (compile-source "" :source-name "<empty batch test>"
                                 :allow-omitted-final-semicolon t)))))
    (multiple-value-bind (value present-p) (lookup-value basis "it")
      (declare (ignore value))
      (is (not present-p) ()
          "An empty batch program invented an interactive binding.")))
  (%check-equal
   1 (%binding
      (nth-value
       1 (run-program
          (compile-source "val x=1" :allow-omitted-final-semicolon t)))
      "x")))

(defun %literal-tests ()
  (let ((basis
          (%basis
           "val zero=0.00000000000e123213213123213123123;
            val negativeZero= ~0.0e123213213123213123123;
            val exponent=2e3;
            val precise=3.2121212121212121212121212121;")))
    (is (= 0.0d0 (%binding basis "zero")) ()
        "A zero significand must not require an enormous host exponent.")
    (is (= 0.0d0 (%binding basis "negativeZero")) ())
    (is (= 2000.0d0 (%binding basis "exponent")) ())
    (is (< 3.21212121212121d0 (%binding basis "precise") 3.212121212121213d0)
        () "Ordinary decimal precision changed while handling a zero exponent.")))

(defun %recursive-value-syntax-tests ()
  (let ((basis
          (%basis
           "val rec ((((((((x)))))))) = fn () => ();
            val rec rec y = fn () => ();")))
    (dolist (name '("x" "y")) (%binding basis name)))
  (let ((basis
          (%basis
           "val a = fn x => x
            val a = 1
            and rec b = fn x => a(b(c(d(e(f(g x))))))
            and c : 'a -> 'a as d : 'a -> 'a = fn x => x
            and rec e as f as g = fn x => x
            and h : 'b -> 'b : 'b -> 'b = fn x => x;")))
    (dolist (name '("b" "c" "d" "e" "f" "g" "h"))
      (%binding basis name)))
  (let* ((output (make-string-output-stream))
         (source "local
                    val x = \"Hello, world!\\n\"
                    val x = \"BUG\\n\" and rec f = fn () => print x
                  in val _ = f () end;
                  local
                    val x = \"BUG\\n\"
                    val x = \"Hello, world!\\n\" and rec f = fn y => print y
                  in val _ = f x end;")
         (program (%compile source))
         (basis nil))
    (ooparts/sml/compiler::%host-function program)
    (let ((*standard-output* output))
      (setf basis (nth-value 1 (run-program program))))
    (is (string= (format nil "Hello, world!~%Hello, world!~%")
                 (get-output-stream-string output)) ()
        "Mixed VAL REC bindings closed over the wrong declaration environment.")
    basis))

(defun %declaration-type-scope-tests ()
  (%basis "signature U = sig datatype 'a t = T of 'a ref end;")
  (dolist (source '("type t = 'a * 'b;"
                    "datatype foo = Foo of 'a;"
                    "exception E of 'a;"))
    (signals sml-elaboration-error (%compile source)))
  (let ((basis
          (%basis
           "val 'a f = fn x =>
              let
                exception E of 'a
                fun g (E y) = y | g _ = raise Fail \"bug\"
              in g (E x) end;
            val result = f 13;")))
    (%check-equal 13 (%binding basis "result"))
    (multiple-value-bind (f-type present-p) (value-type basis "f")
      (is present-p () "A local exception erased the function's scheme.")
      (when present-p
        (is (search "forall" f-type) ()
            "A local exception function was not generalized: ~S" f-type)
        (is (search "->" f-type) ()
            "A local exception function lost its arrow type: ~S" f-type)))
    (let ((text-basis (%basis "val textResult = f \"text\";" basis)))
      (%check-equal "text" (%binding text-basis "textResult"))))
  (let ((basis
          (%basis
           "val 'a f = fn x => let type t = 'a val y:t=x in y end;
            val captured = f 17;")))
    (%check-equal 17 (%binding basis "captured")))
  (let ((basis
          (%basis
           "local
              fun localIdentity x = x
            in
              fun exportedIdentity x = (localIdentity 0; x)
            end;
            val boolResult = exportedIdentity true;
            val intResult = exportedIdentity 1;")))
    (%check-equal +true+ (%binding basis "boolResult"))
    (%check-equal 1 (%binding basis "intResult"))))

(defun %check-static-rejection (source)
  (handler-case
      (progn
        (%compile source)
        (is nil () "Expected static elaboration rejection for:~%~A" source))
    (sml-elaboration-error (condition)
      (is (eq :static (elaboration-error-kind condition)) ()
          "Expected static elaboration rejection, got ~S: ~A"
          (elaboration-error-kind condition) condition))))

(defun %weak-nominal-lifetime-tests ()
  (let ((condition
          (handler-case
              (progn
                (%compile "val r = ref NONE;
                           datatype t = T;
                           val _ = r := SOME T;")
                nil)
            (sml-elaboration-error (condition) condition))))
    (is condition () "A weak reference escaped into a later datatype identity.")
    (when condition
      (is (eq :static (elaboration-error-kind condition)) ()
          "Weak nominal lifetime rejection was not a static elaboration error.")))
  (let ((basis
          (%basis
           "val r = ref NONE;
            val alias = r;
            val _ = alias := SOME 1;
            val answer = case !r of SOME n => n | NONE => 0;
            val id = fn x => x;
            val intId = id 1;
            val boolId = id true;")))
    (%check-equal 1 (%binding basis "answer"))
    (%check-equal 1 (%binding basis "intId"))
    (%check-equal +true+ (%binding basis "boolId")))
  (let ((basis
          (%basis
           "datatype t = T;
            val r = ref NONE;
            val alias = r;
            val _ = alias := SOME T;
            val accepted = case !r of SOME T => true | NONE => false;")))
    (%check-equal +true+ (%binding basis "accepted"))
    "A weak alias must retain a nominal identity that already exists.")
  ;; The datatype alone does not constrain F.  The body's typed application
  ;; does, after the local-prefix checkpoint has already completed its list.
  (%check-static-rejection
   "local
      val f = let val f = (fn x => x) (fn x => x) in f end
      datatype t = A
      val g = fn x => let val d = #1 x
                          val k = #2 x
                          val s = f (d,k)
                          val _ = if true then (d,k) else x
                      in s end
    in
      val a : t * t = g (A,A)
    end;")
  (%check-static-rejection
   "local
      val f = (fn x => x) (fn x => x)
      datatype t = A
      val g = f
    in
      local val h = g in val rejected : t -> t = h end
    end;")
  (let ((basis
          (%basis
           "datatype t = A;
            local
              val f = (fn x => x) (fn x => x)
              datatype u = datatype t
              val g = f
            in
              val h : t -> t = g
              val result = h A
            end;")))
    (%check-equal (%binding basis "A") (%binding basis "result"))
    (%check-equal (%binding basis "A")
                  (%binding (%basis "val again = h A;" basis) "again"))
    "Datatype replication retains the already visible nominal identity.")
  (let ((basis
          (%basis
           "local
              datatype t = A
              val f = (fn x => x) (fn x => x)
              val g = f
            in
              local val h : t -> t = g in val result = h A end
            end;
            val A = result;")))
    (%binding basis "A")
    "A nominal introduced before the weak binding remains a legal alias."))

(defun %nested-match-tail-execution-test ()
  (let ((basis
          (%basis
           "fun select (a,b,ds) =
              case ds of
                [] => 0
              | x::xs => case (a < b) of true => x | false => 0;
            val trueBranch = select (1,2,[9]);
            val falseBranch = select (2,1,[9]);")))
    (%check-equal 9 (%binding basis "trueBranch"))
    (%check-equal 0 (%binding basis "falseBranch"))))

(defun %wide-match-execution-test ()
  (let* ((source
           (with-output-to-string (output)
             (write-string "fun select x = case x of " output)
             (dotimes (index 600)
               (format output "~D => ~D~:[ | ~;~]" index index (= index 599)))
             (write-string " | _ => ~1; val answers = (select 599, select 600);" output)))
         (basis (%basis source)))
    (%check-record (%binding basis "answers") '(("1" . 599) ("2" . -1)))))

(defun %wide-function-clause-execution-test ()
  ;; Keep every named clause's matcher out of one growing host code component.
  (let* ((source
           (with-output-to-string (output)
             (write-string "fun select " output)
             (dotimes (index 600)
               (format output "~D = ~D | select " index index))
             (write-string "_ = ~1; " output)
             (write-string "val answers = (select 599, select 600);" output)))
         (basis (%basis source)))
    (%check-record (%binding basis "answers") '(("1" . 599) ("2" . -1)))))

(defun %wide-overload-streaming-test ()
  ;; Overload nodes in earlier batches must share cells with the final match
  ;; argument and result types, rather than acquiring fresh defaults.
  (let* ((source
           (with-output-to-string (output)
             (write-string "datatype choice = " output)
             (format output "~{C~D~^ | ~}" (loop for index below 65 collect index))
             (write-string "; fun widen (x, y) = case y of " output)
             (dotimes (index 65)
               (format output "C~D => ~A~:[ | ~;~]" index
                       (if (zerop index) "x + x" "raise Fail \"wide\"")
                       (= index 64)))
             (write-string "; val answer = widen (21, C0);" output)))
         (basis (%basis source)))
    (%check-equal 42 (%binding basis "answer"))
    (signals sml-type-error
      (%compile "val bad = widen (\"text\", C0);" basis))
    (let ((basis
            (%basis
             (concatenate
              'string source
              "fun classify (x, (y:real), c) = case c of
                 C0 => x < x
               | C64 => y < y
               | _ => false;
               val answers = (classify (0, 1.0, C0), classify (0, 1.0, C64));"))))
      (%check-record (%binding basis "answers")
                     (list (cons "1" +false+) (cons "2" +false+)))
      (signals sml-type-error
        (%compile "val bad = classify (C0, 1.0, C0);" basis)))))

(defun %deep-continuation-tests ()
  (let ((basis
          (%basis
           "val mutations = ref 0;
            val rec descend = fn 0 => 0
              | n =>
                  let val result = descend (n - 1)
                  in mutations := !mutations + 1; result + 1 end;
            val depth = descend 20000;
            val observed = !mutations;
            fun even 0 = true | even n = not (odd (n - 1))
            and odd 0 = false | odd n = not (even (n - 1));
            val mutual = even 20000;
            fun accumulate 0 total = total
              | accumulate n total = accumulate (n - 1) (total + 1);
            val partiallyApplied = accumulate 250000;
            val tailCount = partiallyApplied 0;
            exception Boom;
            val catches = ref 0;
            val rec unwind = fn 0 => raise Boom
              | n => (unwind (n - 1) handle Boom =>
                           (catches := !catches + 1; raise Boom));
            val caught = unwind 1000 handle Boom => !catches;")))
    (%check-equal 20000 (%binding basis "depth"))
    (%check-equal 20000 (%binding basis "observed"))
    (%check-equal +true+ (%binding basis "mutual"))
    (%check-equal 250000 (%binding basis "tailCount"))
    (%check-equal 1000 (%binding basis "caught")))
  (let* ((basis
           (%basis
            "exception Boom;
             val r = ref 0;
             val rec callWithHandler = fn xs =>
               (List.map (fn _ => (r := !r + 1; raise Boom)) xs
                handle Boom => [9]);
             val result = callWithHandler [1,2];
             val sum = List.foldl op+ 0 result;"))
         (program (%compile "print (Int.toString (!r) ^ \" \" ^ Int.toString sum ^ \"\\n\");" basis))
         (output (make-string-output-stream)))
    (ooparts/sml/compiler::%host-function program)
    (let ((*standard-output* output))
      (run-program program :basis basis))
    (is (string= (format nil "1 9~%") (get-output-stream-string output)) ()
        "A Basis callback lost a nested handler's mutation or result."))
  (let ((basis
          (%basis
           "val cells = ref [];
            fun capture 0 = ()
              | capture n = (cells := (fn () => n) :: !cells; capture (n - 1));
            val completed = capture 3;
            val captured = List.map (fn thunk => thunk ()) (!cells);")))
    (%check-equal +unit+ (%binding basis "completed"))
    (%check-list (%binding basis "captured") '(1 2 3))))

(defun run-core-tests ()
  (with-suite ("ooparts-tests/sml/core")
    (%batch-eof-tests)
    (%recursive-value-syntax-tests)
    (%declaration-type-scope-tests)
    (%weak-nominal-lifetime-tests)
    (%deep-continuation-tests)
    (%literal-tests)
    (%function-tests)
    (%old-binding-tests)
    (%capture-factory-tests)
    (%named-function-clause-tests)
    (%ordered-clause-continuation-execution-test)
    (%sml-or-tail-normalization-tests)
    (%pattern-tests)
    (%nested-match-tail-execution-test)
    (%wide-match-execution-test)
    (%wide-overload-streaming-test)
    (%wide-function-clause-execution-test)
    (%record-and-list-tests)
    (%datatype-tests)
    (%control-and-mutation-tests)
    (%exception-tests)
    (%failed-commit-tests)
    (%static-and-scheme-tests)
    (%output-preservation-test)
    (%declaration-and-equality-tests)
    (%primitive-arithmetic-tests)
    (%reference-equality-tests)
    (%primitive-shadowing-tests))
  t)
