% Identical source and search order in both engines. No CLP or host callbacks.
bench(queens, N) :- findall(Q, queens([1,2,3,4,5,6,7,8], [], Q), Qs), blength(Qs, N).
bench(tak, R) :- tak(16, 10, 4, R).
bench(reverse, R) :- range(1200, Xs), nrev(Xs, Ys), blength(Ys, R).
bench(qsort, R) :- numbers(2000, Xs), qsort(Xs, Ys), blength(Ys, R).
bench(graph, N) :- findall(Y, route(0, 10, Y), Ys), blength(Ys, N).
bench(differentiate, N) :- expr(8, E), deriv(E, x, D), nodes(D, N).

blength(Xs, N) :- blength(Xs, 0, N).
blength([], N, N).
blength([_|Xs], A, N) :- B is A+1, blength(Xs, B, N).
bappend([], Ys, Ys).
bappend([X|Xs], Ys, [X|Zs]) :- bappend(Xs, Ys, Zs).
range(0, []) :- !.
range(N, [N|Xs]) :- M is N-1, range(M, Xs).
numbers(0, []) :- !.
numbers(N, [X|Xs]) :- X is (N*7919) mod 2003, M is N-1, numbers(M, Xs).
nrev([], []).
nrev([X|Xs], Ys) :- nrev(Xs, Zs), bappend(Zs, [X], Ys).
qsort([], []).
qsort([X|Xs], Ys) :- partition(Xs, X, L, H), qsort(L, LS), qsort(H, HS), bappend(LS, [X|HS], Ys).
partition([], _, [], []).
partition([X|Xs], P, [X|Ls], Hs) :- X =< P, !, partition(Xs, P, Ls, Hs).
partition([X|Xs], P, Ls, [X|Hs]) :- partition(Xs, P, Ls, Hs).
selectq(X, [X|Xs], Xs).
selectq(X, [Y|Xs], [Y|Ys]) :- selectq(X, Xs, Ys).
queens([], Qs, Qs).
queens(Xs, Placed, Qs) :- selectq(Q, Xs, Rest), safe(Q, Placed, 1), queens(Rest, [Q|Placed], Qs).
safe(_, [], _).
safe(Q, [X|Xs], D) :- Q =\= X+D, Q =\= X-D, E is D+1, safe(Q, Xs, E).
tak(X, Y, Z, R) :- X =< Y, !, R = Z.
tak(X, Y, Z, R) :- A is X-1, tak(A,Y,Z,U), B is Y-1, tak(B,Z,X,V), C is Z-1, tak(C,X,Y,W), tak(U,V,W,R).
route(X, 0, X) :- !.
route(X, D, Y) :- edge(X, Z), E is D-1, route(Z, E, Y).
expr(0, x) :- !.
expr(N, mul(add(A, 1), add(A, 2))) :- M is N-1, expr(M, A).
deriv(x, x, 1) :- !.
deriv(add(A,B), X, add(DA,DB)) :- !, deriv(A,X,DA), deriv(B,X,DB).
deriv(mul(A,B), X, add(mul(DA,B),mul(A,DB))) :- !, deriv(A,X,DA), deriv(B,X,DB).
deriv(_, _, 0).
nodes(add(A,B), N) :- !, nodes(A,X), nodes(B,Y), N is X+Y+1.
nodes(mul(A,B), N) :- !, nodes(A,X), nodes(B,Y), N is X+Y+1.
nodes(_, 1).
