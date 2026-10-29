(uiop:define-package #:ooparts/prolog/tests/adapters/iso-terms
  (:use #:cl #:prolog)
  (:import-from #:ooparts/prolog/tests/support/assertions #:check #:value-of)
  (:export #:run-iso-term-tests))
(in-package #:ooparts/prolog/tests/adapters/iso-terms)

(defun text-query (text database gc)
  (query (parse-prolog-string text :database database :package *package*)
         :database database :gc-threshold gc))

(defun run-iso-term-tests ()
  (let ((*package* (find-package :ooparts/prolog/tests/adapters/iso-terms)))
    (check (eq :native (database-term-model (make-database))))
    (check (handler-case (progn (make-database :term-model :bad) nil) (error () t)))
    (dolist (gc '(nil 1 8 4096))
      ;; Deliberately leave the ambient database native. Explicit :DATABASE
      ;; must govern parsing, compilation, callbacks and resumed cursors.
      (let* ((*database* (make-database)) (db (make-database :term-model :iso)))
        (check (equal (parse-prolog-string "[a,b]. []." :database db)
                      '(($cons a ($cons b $nil)) $nil)))
        (dolist (text
                 '("f(a) \\= [f,a], [] \\== nil, atom([]), compound([a])."
                   "[a|b] == '.'(a,b), [a,b] == '.'(a,'.'(b,[]))."
                   "'$cons' \\== '.', '$nil' \\== [], '$cons'(a,b) \\= [a|b]."
                   "functor([X|Y],'.',2), arg(1,[X|Y],A), arg(2,[X|Y],B), A==X, B==Y."
                   "T =.. ['.',X,Y], T == [X|Y], T =.. L, L == ['.',X,Y]."
                   "functor(T,'.',2), T = [a|b], T =.. ['.',a,b]."
                   "atom_codes([],[91,93]), atom_chars([],['[',']']), atom_codes(nil,[110,105,108])."
                   "atom_chars(abc,[a|T]), T == [b,c], number_chars(12,['1','2'])."
                   "term_variables(f(X,[Y,X]),L), L == [X,Y]."
                   "copy_term(f(X,[X]),f(Y,[Z])), Y==Z, X \\== Y."
                   "findall([X],(X=a;X=b),[[a],[b]]), findall(X,fail,[])."
                   "bagof(X,(X=b;X=a),[b,a]), setof(X,(X=b;X=a;X=b),[a,b])."
                   "keysort([2-a,1-b,2-c],[1-b,2-a,2-c]), sort([b,a,b],[a,b])."
                   "catch((T =.. [foo|bar]),error(type_error(list,[foo|bar]),_),true)."
                   "X=[a|X], copy_term(X,Y), arg(2,Y,T), T==Y."
                   "catch(sort([a|b],_),error(type_error(list,_),_),true)."))
          (check (text-query text db gc) text))
        (load-prolog-string
         ":- dynamic(p/1). app([],L,L). app([X|Xs],Ys,[X|Zs]):-app(Xs,Ys,Zs). token --> [a], [b]. empty --> []."
         :database db :package *package*)
        (check (text-query "app([a],[b],[a,b]), assertz(p([X,X])), clause(p([A,B]),true), A==B, retract(p([_,_])), \\+p(_)." db gc)
               "static and dynamic clauses retain strict list representation and sharing")
        (check (query '((token ($cons a ($cons b $nil)) $nil) (empty $nil $nil))
                      :database db :gc-threshold gc) "textual DCG list lowering")
        (let ((*database* db) (offset 5))
          (---> (bridge ?n) '(?x) (do (lisp ?n (+ ?x offset))))
          (check (query '((phrase (bridge ?n) ($cons 7 $nil)) (= ?n 12)) :gc-threshold gc)
                 "DCG macro and callback use the strict database")
          (check (prolog (phrase (bridge ?n) ($cons 7 $nil))
                         (lisp (return-from prolog (= ?n 12))))
                 "inline PHRASE retains lexical callbacks")
          (<-- (fact ($cons a $nil)))
          (table 'fact 1)
          (let ((cursor (make-query '((fact ?x)) :gc-threshold gc)))
            (unwind-protect
                 (progn (check (equal '($cons a $nil) (value-of '?x (next-solution cursor))))
                        (collect-query-garbage cursor)
                        (check (not (nth-value 1 (next-solution cursor)))))
              (close-query cursor))))
        (let ((out (make-string-output-stream)))
          (query '((set_prolog_flag write_syntax prolog)) :database db)
          (check (query (list (list 'write_canonical out '($cons 1 ($cons 2 $nil)))) :database db))
          (check (string= "'.'(1,'.'(2,[]))" (get-output-stream-string out)))
          (query '((set_prolog_flag write_syntax lisp)) :database db)
          (query (list (list 'writeq out '($cons a $nil))) :database db)
          (let ((text (get-output-stream-string out)))
            (check (and (search "($CONS " text) (search " $NIL)" text))
                   "strict list markers print uppercase without escapes"))
          (close out))
        (dolist (text '("($cons a $nil)" "($cons OOPARTS/PROLOG/ATOMS::$cons $nil)"))
          (with-input-from-string (in text)
            (check (query (list (list 'read in '?x)
                               (list 'functor '?x '$cons 2))
                          :database db :gc-threshold gc) "Lisp reader recognizes explicit strict list symbols")))
        (let ((ring (list '$cons 'a nil)))
          (setf (third ring) ring)
          (dolist (term (list (first (parse-prolog-string "f('Case','a b','123','$cons','$nil')."
                                                         :database db :package *package*))
                             ring))
            (let ((out (make-string-output-stream)))
              (query (list (list 'writeq out term)) :database db :gc-threshold gc)
              (with-input-from-string (in (get-output-stream-string out))
                (check (query (list (list 'read in term)) :database db :gc-threshold gc)
                       "strict Lisp output preserves atom spelling, marker collisions and cycles"))
              (close out))))
        (clear-database db)
        (check (text-query "atom_chars(ab,[a,b]), copy_term([a],[a])." db gc)
               "clearing preserves the correct shared library")
        (check (equal '((f a) (f a) nil) (parse-prolog-string "f(a). [f,a]. [].")))
        (check (query '((atom_chars ab (a b)))) "native library remains selected")))))
