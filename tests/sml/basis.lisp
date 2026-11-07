(uiop:define-package #:ooparts-tests/sml/basis
  (:use #:cl)
  (:import-from #:ooparts/test #:with-suite #:is)
  (:import-from #:ooparts/sml/compiler
    #:compile-source #:run-program #:lookup-value #:value-to-string)
  (:import-from #:ooparts/sml/runtime
    #:+unit+ #:+true+ #:+false+ #:sml-equal #:sml-list-values)
  (:export #:run-basis-tests))
(in-package #:ooparts-tests/sml/basis)

(defun %compile (source &optional basis)
  (if basis
      (compile-source source :source-name "<basis test>" :basis basis)
      (compile-source source :source-name "<basis test>")))

(defun %execute (source &optional basis)
  (run-program (%compile source basis) :basis basis))

(defun %basis (source &optional basis)
  (nth-value 1 (%execute source basis)))

(defun %binding (basis name)
  (multiple-value-bind (value present-p) (lookup-value basis name)
    (is present-p () "Expected an executed Basis binding for ~S." name)
    value))

(defun %check (expected value)
  (is (sml-equal expected value) ()
      "Expected SML value ~A, got ~A."
      (value-to-string expected) (value-to-string value)))

(defun %check-list (value expected)
  (multiple-value-bind (elements proper-p) (sml-list-values value)
    (is proper-p () "Expected a proper SML list, got ~S." value)
    (when proper-p
      (is (= (length expected) (length elements)) ()
          "Expected ~D SML list elements, got ~D."
          (length expected) (length elements))
      (loop for wanted in expected
            for actual in elements
            do (%check wanted actual)))))

(defun %factorial-output-test ()
  (let* ((output (make-string-output-stream))
         (source "fun fact 0=1 | fact n=n*fact(n-1);
                   print (concat [Int.toString (fact 10), \"\\n\"]);")
         (program (%compile source)))
    (ooparts/sml/compiler::%host-function program)
    (let ((*standard-output* output))
      (%check +unit+ (run-program program)))
    (is (string= (format nil "3628800~%") (get-output-stream-string output)) ()
        "The unqualified concat/Int.toString/print path produced wrong output.")))

(defun %scalar-structure-tests ()
  (let ((basis
          (%basis
           "val int=40;
            val typedInt:Int.int=int+2;
            val negative=Int.toString (~42);
            val positive=Int.toString 42;
            val bool=Bool.toString true;
            val boolFalse=Bool.toString false;
            val negated=Bool.not false;
            val retained=Bool.not true;
            val typedBool:Bool.bool=negated;
            val string=\"alias\";
            val typedString:String.string=string;")))
    (%check 42 (%binding basis "typedInt"))
    (%check "~42" (%binding basis "negative"))
    (%check "42" (%binding basis "positive"))
    (%check "true" (%binding basis "bool"))
    (%check "false" (%binding basis "boolFalse"))
    (%check +true+ (%binding basis "negated"))
    (%check +false+ (%binding basis "retained"))
    (%check +true+ (%binding basis "typedBool"))
    (%check "alias" (%binding basis "typedString"))))

(defun %list-structure-tests ()
  (let ((basis
          (%basis
           "val mapPairs=List.map (op +) [(1,2),(3,4)];
            val mapEmpty=List.map (fn x:int=>x+1) [];
            val lengthThree=List.length [7,8,9];
            val lengthEmpty=List.length [];
            val mapper=List.map (fn x:int=>x*2);
            val partialMapped=mapper [1,2,3];
            val left=List.foldl (op ::) [] [1,2,3];
            val right=List.foldr (op ::) [] [1,2,3];
            val leftEmpty=List.foldl (op ::) [0] [];
            val rightEmpty=List.foldr (op ::) [0] [];
            val sum=List.foldl (op +) 0;
            val partialSum=sum [1,2,3,4];
            val rightFolder=List.foldr (op +);
            val sumRightFrom=rightFolder 10;
            val partialRightSum=sumRightFrom [1,2,3];")))
    (%check-list (%binding basis "mapPairs") '(3 7))
    (%check-list (%binding basis "mapEmpty") nil)
    (%check 3 (%binding basis "lengthThree"))
    (%check 0 (%binding basis "lengthEmpty"))
    (%check-list (%binding basis "partialMapped") '(2 4 6))
    (%check-list (%binding basis "left") '(3 2 1))
    (%check-list (%binding basis "right") '(1 2 3))
    (%check-list (%binding basis "leftEmpty") '(0))
    (%check-list (%binding basis "rightEmpty") '(0))
    (%check 10 (%binding basis "partialSum"))
    (%check 16 (%binding basis "partialRightSum"))))

(defun %string-structure-tests ()
  (let ((basis
          (%basis
           "val joined=String.concat [\"alpha\",\"\",\"omega\"];
            val direct=concat [\"left\",\"right\"];
            val joinedEmpty=String.concat [];
            val exploded=String.explode \"A~\";
            val roundtripped=String.implode (String.explode \"roundtrip\");
            val implodedEmpty=String.implode [];
            val sized=String.size \"four\";
            val emptySize=String.size \"\";")))
    (%check "alphaomega" (%binding basis "joined"))
    (%check "leftright" (%binding basis "direct"))
    (%check "" (%binding basis "joinedEmpty"))
    (%check-list (%binding basis "exploded") (list #\A #\~))
    (%check "roundtrip" (%binding basis "roundtripped"))
    (%check "" (%binding basis "implodedEmpty"))
    (%check 4 (%binding basis "sized"))
    (%check 0 (%binding basis "emptySize"))))

(defun %character-conversion-tests ()
  (let ((basis
          (%basis
           "val maximum=ord(chr 255);
            val minimum=ord(chr 0);
            val decimalLiteral=ord #\"\\255\";
            val unicodeLiteral=ord #\"\\u00FF\";
            val validHandled=(ord(chr 65);1) handle Chr=>0;
            val tooLarge=(ord(chr 256);0) handle Chr=>1;
            val negative=(ord(chr ~1);0) handle Chr=>1;
            exception CharacterFailure=Chr;
            val copiedHandler=(ord(chr 256);0) handle CharacterFailure=>1;")))
    (dolist (entry (list (cons "maximum" 255) (cons "minimum" 0)
                         (cons "decimalLiteral" 255) (cons "unicodeLiteral" 255)
                         (cons "validHandled" 1) (cons "tooLarge" 1)
                         (cons "negative" 1) (cons "copiedHandler" 1)))
      (%check (cdr entry) (%binding basis (car entry))))
    (multiple-value-bind (result extended) (%execute "val later=ord(chr 255);" basis)
      (declare (ignore result))
      (%check 255 (%binding extended "later")))))

(defun %text-io-output-test ()
  (let* ((output (make-string-output-stream))
         (program (%compile "val plain=print \"core \";
                              val qualified=TextIO.print \"qualified\";")))
    (ooparts/sml/compiler::%host-function program)
    (multiple-value-bind (result basis)
        (let ((*standard-output* output))
          (run-program program))
      (%check +unit+ result)
      (%check +unit+ (%binding basis "plain"))
      (%check +unit+ (%binding basis "qualified")))
    (is (string= "core qualified" (get-output-stream-string output)) ()
        "Qualified TextIO.print did not share dynamically captured host output.")))

(defun run-basis-tests ()
  (with-suite ("ooparts-tests/sml/basis")
    (%factorial-output-test)
    (%scalar-structure-tests)
    (%list-structure-tests)
    (%string-structure-tests)
    (%character-conversion-tests)
    (%text-io-output-test))
  t)
