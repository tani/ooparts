(uiop:define-package #:ooparts-tests/prolog/adapters/iso-compatibility
  (:use #:cl #:ooparts/prolog)
  (:import-from #:ooparts-tests/prolog/support/assertions #:check #:value-of)
  (:import-from #:ooparts-tests/prolog/adapters/builtins #:iso-error-p)
  (:import-from #:ooparts/prolog/syntax/compiler #:add-clause)
  (:import-from #:ooparts/prolog/adapters/term-ops #:iso-atom)
  (:export #:run-iso-compatibility-tests))
(in-package #:ooparts-tests/prolog/adapters/iso-compatibility)

(defun textual-query (text &optional (gc 1))
  (query (list (first (parse-prolog-string text))) :gc-threshold gc))

(defun run-current-predicate-tests ()
  (dolist (model '(:native :iso))
    (dolist (gc '(nil 1 8 4096))
      (let ((*database* (make-database :term-model model)))
        (load-prolog-string
         ":- dynamic(empty/0). :- dynamic(item/1).
          item(a). item(b). item(a,b). 'Case'(a). case(a).")
        (dolist (text '("current_predicate(empty/0)."
                        "findall(1,current_predicate(item/1),[1])."
                        "N=item,A=1,current_predicate(N/A)."
                        "\\+current_predicate(missing/0)."
                        "\\+current_predicate(item/0)."
                        "\\+current_predicate(atom/1)."
                        "current_predicate('Case'/1),current_predicate(case/1),\\+current_predicate('CASE'/1)."
                        "findall(A,current_predicate(item/A),L),L=[_,_],sort(L,[1,2])."
                        "findall(N,current_predicate(N/1),L),L=[_,_,_],sort(L,['Case',case,item])."
                        "current_predicate(I),I==item/2."
                        "catch((current_predicate(item / -1),fail),error(type_error(predicate_indicator,item / -1),current_predicate/1),true)."
                        "catch((current_predicate(item/bad),fail),error(type_error(predicate_indicator,item/bad),current_predicate/1),true)."
                        "\\+current_predicate(later/0),assertz(later),current_predicate(later/0)."
                        "retractall(item(_)),current_predicate(item/1)."
                        "abolish(item/1),\\+current_predicate(item/1),current_predicate(item/2)."
                        "abolish(later/0),\\+current_predicate(later/0)."))
          (check (textual-query text gc) text))
        (clear-database)
        (check (null (textual-query "current_predicate(empty/0)." gc))
               "ground predicate lookup observes database clearing")
        ;; Lisp symbol identities are distinct, while generated atoms bridge by
        ;; spelling. Ground lookup must preserve both rules and answer counts.
        (let ((left (make-symbol "LOOKUP-BRIDGE"))
              (right (make-symbol "LOOKUP-BRIDGE"))
              (other (make-symbol "LOOKUP-BRIDGE"))
              (atom (iso-atom "lookup-bridge")))
          (add-clause (list left) nil nil)
          (add-clause (list right) nil nil)
          (flet ((lookup (name)
                   (query (list (list 'current_predicate (list '/ name 0))) :gc-threshold gc)))
            (check (= 1 (length (lookup left))) "ground lookup retains Lisp symbol identity")
            (check (null (lookup other)) "same spelling alone does not equate Lisp symbols")
            (check (= 2 (length (lookup atom))) "generated atom lookup retains all matching symbols")
            (add-clause (list atom) nil nil)
            (check (= 2 (length (lookup left))) "Lisp lookup also finds a generated atom definition")
            (check (= 3 (length (lookup atom))) "exact generated atom hit retains bridged alternatives")))))))

(defun run-iso-compatibility-tests ()
 (let ((*package* (find-package :ooparts-tests/prolog/adapters/iso-compatibility)))
  (run-current-predicate-tests)
  (dolist (gc '(nil 1 8 4096))
    (let ((*database* (make-database)))
      (load-prolog-string ":- discontiguous(empty/1). :- multifile(shared/1). fixed(a). :- dynamic(changing/1). changing(a). :- dynamic('Case'/1). 'Case'(a). case(a).")
      (check (textual-query "current_predicate(empty/1),current_predicate(shared/1)." gc)
             "declaration-only procedures exist")
      (check (null (textual-query "empty(X);shared(X)." gc)) "empty declared procedures fail without existence errors")
      (dolist (goal '("asserta(fixed(b))" "assertz(fixed(b))" "retract(fixed(a))"
                      "retractall(fixed(X))" "abolish(fixed/1)"))
        (check (textual-query (format nil "catch((~A,fail),error(permission_error(modify,static_procedure,fixed/1),_),true)." goal) gc)
               "Prolog text procedures are static by default"))
      (check (textual-query "catch((clause(fixed(X),B),fail),error(permission_error(access,private_procedure,fixed/1),_),true)." gc)
             "static Prolog text procedures are private by default")
      (check (textual-query "assertz(changing(b)),clause(changing(b),true),retract(changing(a))." gc)
             "dynamic source procedures remain public and writable")
      (check (textual-query "catch((assertz(case(b)),fail),error(permission_error(modify,static_procedure,case/1),_),true),assertz('Case'(b))." gc)
             "quoted predicate case distinguishes declaration properties")
      (dolist (text '("north(a) @< foo(a,b)." "a(z,z) @< z(a,a,a)."
                      "f(a,z) @< f(b,a)." "100.0 @< -100." "z @< f(a)."
                      "sort(['a','A'],['A','a'])."))
        (check (textual-query text gc) "ISO order uses type, arity, functor and arguments"))
      (check (textual-query "sort([f(a,b),north(a),3,-1,9.0], [9.0,-1,3,north(a),f(a,b)])." gc)
             "SORT shares ISO term order")
      (clear-database)
      (<-- (fixed a))
      (check (query '((assertz (fixed b)) (clause (fixed b) true)) :gc-threshold gc)
             "clearing source metadata preserves native Lisp definition behavior"))
    (let ((*database* (make-database)))
      (load-prolog-string ":-dynamic(cat/0). :-dynamic(dog/0). :-dynamic(implicit/1). pick(a). pick(b). cat. dog :- true. implicit(X) :- X, call(X).")
      (dolist (text '("number_chars(15,['0',x,f])."
                      "number_codes(15,[48,120,102])."
                      "number_chars(3.3,['3','.','3','E','+','0'])."
                      "number_codes(33.0,[51,46,51,69,43,48,49])."
                      "number_chars(12,['1',X]),X=='2'."
                      "number_chars(12,['1'|Xs]),Xs==['2']."
                      "number_codes(12,[49,X]),X==50."
                      "number_codes(12,[49|Xs]),Xs==[50]."
                      "current_predicate(pick/A),A==1."
                      "current_predicate(N/1),N==pick."))
        (check (textual-query text gc) "number parsing/output modes and partial predicate indicators"))
      (dolist (case '(("number_chars(1,[a])" "syntax_error(number)")
                      ("number_codes(1,[97])" "syntax_error(number)")
                      ("number_codes(foo,[49])" "type_error(number,foo)")
                      ("atom_chars(X,[a,f(b)])" "type_error(character,f(b))")
                      ("number_chars(X,['4',2])" "type_error(character,2)")
                      ("current_predicate(4)" "type_error(predicate_indicator,4)")
                      ("current_predicate(dog)" "type_error(predicate_indicator,dog)")
                      ("current_predicate(0/dog)" "type_error(predicate_indicator,0/dog)")
                      ("clause(absent(X),5)" "type_error(callable,5)")
                      ("clause(pick(X),5)" "type_error(callable,5)")
                      ("current_input(fred)" "domain_error(stream,fred)")
                      ("current_output(fred)" "domain_error(stream,fred)")
                      ("get_char(not/stream,C)" "domain_error(stream_or_alias,not/stream)")
                      ("stream_property(not/stream,P)" "domain_error(stream,not/stream)")
                      ("open(missing,read,S,[eof(action)])" "domain_error(stream_option,eof(action))")
                      ("call((fail,1))" "type_error(callable,(fail,1))")
                      ("call((1;true))" "type_error(callable,(1;true))")
                      ("once(3)" "type_error(callable,3)")
                      ("\\+(3)" "type_error(callable,3)")
                      ("call((once(3),true))" "type_error(callable,3)")
                      ("setof(X,X^(true;4),S)" "type_error(callable,(true;4))")))
        (check (textual-query (format nil "catch((~A,fail),error(~A,_),true)." (first case) (second case)) gc)
               "ISO argument validation retains the full formal error"))
      (check (textual-query "catch(call((assertz(unwanted_effect),1)),error(type_error(callable,(assertz(unwanted_effect),1)),_),true),\\+ current_predicate(unwanted_effect/0)." gc)
             "meta goal conversion rejects invalid bodies before side effects")
      (dolist (text '("call((!,fail;true))."
                      "G=(!,fail;true),call(G)."
                      "call(';',(true->fail),X=1)."
                      "call((true->fail;X=1))."))
        (check (null (textual-query text gc)) "runtime control retains transparent branches"))
      (check (= 2 (length (textual-query "pick(X),call(!)." gc))) "CALL cut remains opaque to its caller")
      (check (= 2 (length (textual-query "call((X=a;X=b))." gc))) "meta disjunction preserves alternatives")
      (check (textual-query "clause(cat,true),clause(dog,true),clause(cat(),true)." gc)
             "zero-arity clause heads accept atom and list spellings")
      (check (textual-query "clause(implicit(X),B),B == (call(X),call(X))." gc)
             "clause variable goals reflect as CALL/1 with sharing")
      (check (textual-query "asserta((meta(X):-X,call(X))),meta(true)." gc)
             "assertions store variable goals without executing them")
      (check (textual-query "assertz(zero),retract(zero),clause(zero(),_) -> fail ; true." gc)
             "atom-headed zero-arity retraction removes the clause")
      (check (textual-query "assertz(cycle(X,X)),X=f(X),clause(cycle(X,Y),true),X==Y." gc)
             "clause copying retains cyclic argument graphs")
      (check (textual-query "catch((clause(atom(X),B),fail),error(permission_error(access,private_procedure,atom/1),_),true)." gc))
      (check (textual-query "catch((retract((atom(X):-true)),fail),error(permission_error(modify,static_procedure,atom/1),_),true)." gc))
      (check (textual-query "X is 1^(-1),X==1,Y is (-1)^(-3),Y == -1,Z is 0**0.0,Z==1.0." gc))
      (check (textual-query "catch((X is 2^(-1),fail),error(type_error(float,2),_),true)." gc))
      (check (textual-query "current_prolog_flag(max_arity,unbounded)." gc))
      (dolist (text '("catch((arg(0,a,X),fail),error(type_error(compound,a),_),true)."
                      "catch((arg(1,42,X),fail),error(type_error(compound,42),_),true)."
                      "catch((op(-30,xfy,a),fail),error(domain_error(operator_priority,-30),_),true)."
                      "catch((op(30,xfy,0),fail),error(type_error(list,0),_),true)."
                      "catch((op(500,xfy,'{}'),fail),error(permission_error(create,operator,'{}'),_),true)."
                      "catch((op(1000,xfy,'|'),fail),error(permission_error(create,operator,'|'),_),true)."
                      "catch((op(0,xfx,','),fail),error(permission_error(modify,operator,','),_),true)."))
        (check (textual-query text gc) "ISO validation errors retain class and culprit"))
      (check (textual-query "catch(op(300,xfy,[new_op,'{}']),_,true),\\+ current_op(_,_,new_op)." gc)
             "rejected OP lists do not partially change the operator table")
      (dolist (text '("op(300,xfy,conf_op),catch((op(400,yf,conf_op),fail),error(permission_error(create,operator,conf_op),_),true),current_op(300,xfy,conf_op),\\+current_op(_,yf,conf_op)."
                      "op(0,yfx,conf_op),op(300,xf,conf_op),catch((op(400,yfx,conf_op),fail),error(permission_error(create,operator,conf_op),_),true),current_op(300,xf,conf_op)."
                      "op(0,yf,conf_op),op(300,xfy,conf_op),op(400,xfx,conf_op),current_op(400,xfx,conf_op),\\+current_op(_,xfy,conf_op)."
                      "op(0,xfy,conf_op),\\+current_op(_,xfx,conf_op),op(300,fx,conf_op),op(400,fy,conf_op),\\+current_op(_,fx,conf_op),current_op(400,fy,conf_op)."
                      "op(300,xfy,conf_op),current_op(400,fy,conf_op),current_op(300,xfy,conf_op),op(0,fx,conf_op),current_op(300,xfy,conf_op)."
                      "catch((op(300,xfy,[]),fail),error(permission_error(create,operator,[]),_),true)."
                      "catch((op(300,xfy,[[]]),fail),error(permission_error(create,operator,[]),_),true)."
                      "catch(op(300,xfy,[conf_new,[]]),_,true),\\+current_op(_,_,conf_new)."
                      "op(0,yfx,conf_op),op(300,yf,conf_op),catch(op(400,xfy,[conf_new,conf_op]),_,true),\\+current_op(_,_,conf_new),current_op(300,yf,conf_op)."))
        (check (textual-query text gc) "OP validates conflicts atomically and replaces/removes a fixity group"))
      (check (textual-query "op(1100,xfy,'|'),current_op(1100,xfy,'|'),op(0,xfy,'|')." gc))))
  (dolist (gc '(nil 1 8 4096))
    (uiop:with-temporary-file (:pathname path :stream stream :direction :output
                              :element-type '(unsigned-byte 8))
      (close stream)
      (let ((*database* (make-database)))
        (query '((set_prolog_flag read_syntax prolog)))
        (dolist (byte '("ty" "1.5" "-1" "256" "f(a)"))
          (check (textual-query
                  (format nil "open('~A',write,S,[type(binary)]),catch((put_byte(S,~A),fail),error(type_error(byte,~A),_),true),close(S)." path byte byte) gc)
                 "PUT_BYTE rejects every non-byte with the byte type and original culprit"))
        (check (textual-query
                (format nil "open('~A',write,S,[type(binary)]),catch((put_byte(S,_),fail),error(instantiation_error,_),true),put_byte(S,0),put_byte(S,255),close(S),open('~A',read,T,[type(binary)]),get_byte(T,0),get_byte(T,255),get_byte(T,-1),close(T)." path path) gc)
               "PUT_BYTE preserves instantiation errors and writes boundary bytes"))))
  (let ((*database* (make-database)))
    (let ((vm (make-query nil))
          (terms (list 100.0d0 -100 1/2 #C(1 2) 'a "opaque" '(1 . a) '(1 2) '(f a) '(a a b))))
      (unwind-protect
           (let ((ordered (stable-sort terms (lambda (a b) (< (ooparts/prolog/adapters/term-relations:iso-term-compare vm a b) 0)))))
             (check (loop for tail on ordered always
                      (loop for b in (cdr tail) always
                        (minusp (ooparts/prolog/adapters/term-relations:iso-term-compare vm (car tail) b))))
                    "ISO and Lisp extension classes form a transitive mixed order"))
        (close-query vm)))
    (check (equal '((- 1 2) (- (|,| 1 2)) (f |:-| |;| (|:-| |:-| . |:-|)))
                  (parse-prolog-string "-(1,2). - (1,2). f(:-, ;, [:-, :-|:-])."))
           "layout distinguishes prefix application from functional notation"))
  (dolist (gc '(nil 1 8 4096))
    (with-input-from-string (stream "p(X,X,_,Y). p(X,X,_,Y).")
      (let ((*standard-input* stream) (*database* (make-database)))
        (query '((set_prolog_flag read_syntax prolog)))
        (let* ((answer (first (query '((read_term ?term ((variables ?vars) (variable_names ?names) (singletons ?singletons)))
                                      (read ?other)) :gc-threshold gc)))
               (term (value-of '?term answer)) (vars (value-of '?vars answer))
               (names (value-of '?names answer)) (singletons (value-of '?singletons answer)))
          (check (and (= 5 (length term)) (eq (second term) (third term))
                      (= 3 (length vars)) (eq (first vars) (second term))
                      (eq (second vars) (fourth term)) (eq (third vars) (fifth term)))
                 "Prolog reader variables and VARIABLES option share bindings")
          (check (and (equal '("X" "Y") (mapcar (lambda (p) (symbol-name (second p))) names))
                      (eq (third (first names)) (second term))
                      (= 1 (length singletons)) (eq (third (first singletons)) (fifth term)))
                 "Prolog reader variable names and singleton options use =/2 terms")
          (check (not (eq (second term) (second (value-of '?other answer))))
                 "separate reads create fresh variables"))))
    (with-input-from-string (stream "a. 'A'. []. end_of_file.")
      (let ((*standard-input* stream) (*database* (make-database)))
        (query '((set_prolog_flag read_syntax prolog)))
        (check (textual-query "read(a),read('A'),read([]),read(end_of_file),read(end_of_file)." gc)
               "Prolog reading preserves atom case and distinguishes actual EOF"))))
  (with-input-from-string (stream "p(a). (p a)")
    (let ((*standard-input* stream) (*database* (make-database)))
      (query '((set_prolog_flag read_syntax prolog)))
      (check (textual-query "read(p(a)),set_prolog_flag(read_syntax,lisp),read(p(a)).")
             "read syntax can switch at term boundaries")))
  (let ((*database* (make-database)))
    (check (query '((current_prolog_flag read_syntax lisp))) "default reader remains S-expression based")
    (check (iso-error-p '((set_prolog_flag read_syntax invalid)) "domain_error")))))
