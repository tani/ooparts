(uiop:define-package #:ooparts/prolog/tests/adapters/collection
  (:use #:cl #:prolog)
  (:import-from #:ooparts/prolog/tests/support/assertions #:check)
  (:export #:run-collection-tests))
(in-package #:ooparts/prolog/tests/adapters/collection)

(defun run-collection-tests ()
  (let ((*package* (find-package :ooparts/prolog/tests/adapters/collection)))
    (dolist (model '(:native :iso))
      (let ((*database* (make-database :term-model model)))
        (load-prolog-string
         "item(2). item(1). item(2).
          absent(_) :- fail.
          collected(L) :- findall(X,item(X),L).
          empty(L) :- findall(X,absent(X),L).
          nested(L) :- findall(X,collected(X),L).
          compounds(L) :- findall(pair(X,[X]),item(X),L).
          count([],0).
          count([_|Xs],N) :- count(Xs,M), N is M+1.
          counted(N) :- collected(L), count(L,N).
          picked(X) :- item(X), X>1.
          picks(L) :- findall(X,picked(X),L).
          stopped(X) :- item(X), X>1, !.
          stops(L) :- findall(X,stopped(X),L).
          failed_cut(X) :- item(X), !, X>2.
          failed_cuts(L) :- findall(X,failed_cut(X),L).
          templates(L) :- findall(pair(X,X),true,L).
          recursive(0,a) :- !.
          recursive(N,L) :- M is N-1, findall(X,recursive(M,X),L).")
        (dolist (gc '(nil 1))
          (dolist (case '(("collected(L), L==[2,1,2]." t)
                          ("collected([2,1,2])." t)
                          ("collected([1,2,2])." nil)
                          ("empty(L), L==[]." t)
                          ("empty([])." t)
                          ("nested(L), L==[[2,1,2]]." t)
                          ("compounds(L), L==[pair(2,[2]),pair(1,[1]),pair(2,[2])]." t)
                          ("collected([_|T]), T==[1,2]." t)
                          ("counted(3)." t)
                          ("picks([2,2])." t)
                          ("stops([2])." t)
                          ("failed_cuts([])." t)
                          ("templates([pair(A,B)]), A==B, var(A)." t)
                          ("recursive(3,[[[a]]])." t)))
            (check (eql (not (null (query (parse-prolog-string (first case)) :gc-threshold gc)))
                        (second case))
                   (format nil "FINDALL ~A GC=~A: ~A" model gc (first case)))))))))
