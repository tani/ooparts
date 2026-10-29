% SPDX-License-Identifier: MIT
% Development-only converter. Checked-in .pl files require neither SWI nor Logtalk.
% SWI supplies a standards-aware reader here; it never loads Logtalk or runs tests.
:- use_module(library(lists)).
:- use_module(library(apply)).
:- op(600, xfy, ::).
:- op(600, fy, ::).
:- op(600, fy, ^^).
:- op(700, xfx, =~=).
:- initialization(main, main).

main :- current_prolog_flag(argv,Args),main(Args).

main([Root, Output]) :-
    set_prolog_flag(iso, true),
    make_directory_path(Output),
    findall(File, test_file(Root, File), Files0), sort(Files0, Files),
    findall(Case, (member(File, Files), port_file(Root, Output, File, Cases), member(Case, Cases)), All),
    atomic_list_concat([Output, '/cases.json'], Inventory),
    setup_call_cleanup(open(Inventory, write, S, [encoding(utf8)]),
        (json_value(S, All), nl(S)), close(S)).

test_file(Directory, File) :-
    directory_files(Directory, Names), member(Name, Names),
    \+ memberchk(Name, ['.', '..']), atomic_list_concat([Directory, '/', Name], Path),
    (exists_directory(Path) -> test_file(Path, File); Name == 'tests.lgt', File = Path).

port_file(Root, Output, File, Cases) :-
    setup_call_cleanup(open(File, read, In, [encoding(utf8)]), read_rows(In, [], Rows), close(In)),
    atom_concat(Root, Relative0, File), atom_concat('/', Relative, Relative0),
    atom_concat(Directory, '/tests.lgt', Relative),
    atomic_list_concat([Output, '/', Directory, '/tests.pl'], Port),
    file_directory_name(Port, Parent), make_directory_path(Parent),
    findall(Name, (member(row(_,_,Term), Rows), test_clause(Term,H,_,true),
                  H=..[test,Name|Args], member(Options,Args), is_list(Options), member(note('STO'),Options)), Undefined),
    setup_call_cleanup(open(Port, write, Out, [encoding(utf8)]),
        (format(Out, '% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>~n% SPDX-License-Identifier: Apache-2.0~n% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.~n% Source: LogtalkDotOrg/logtalk3, tests/prolog/~w~n% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.~n~n', [Relative]),
         forall((member(row(_,_,Term),Rows), helper_clause(Term,Clause)), write_clause(Out,Clause)),
         findall(Case,
            (member(row(Line,Conditions,Term),Rows),test_clause(Term,H,Body,Disabled),
             H=..[test,Name|Args],atom(Name),sub_atom(Name,0,4,_,iso_),
             test_arguments(Args,Expected0,Options0),
             standard_body(Name,Body,StandardBody),lower_goal(StandardBody,Goal), lower_expectation(Expected0,Expected),
             maplist(lower_goal,Conditions,LoweredConditions), conjunction(LoweredConditions,Condition),
             lower_options(Options0,Options),
             format(atom(ID),'~w:~w:~d',[Relative,Name,Line]),
             (memberchk(Name,Undefined)->Skip='ISO leaves STO/cyclic-term behavior undefined';Disabled==true,\+ implementation_defined_case(Name)->Skip='Disabled upstream: implementation-dependent or unspecified result';Skip=''),
             write_clause(Out,conf_case(ID,Expected,Goal,Options,Condition)),
             term_text(Goal,GoalText),term_text(Expected0,Original),term_text(Expected,Strict),
             term_text(Options,OptionText),term_text(Condition,CondText),
             atomic_list_concat([Directory,'/tests.pl'],Program),
             Case=_{id:ID,name:Name,suite:logtalk,source:Relative,line:Line,program:Program,
                    goal:GoalText,upstream_expected:Original,expected:Strict,options:OptionText,
                    condition:CondText,skip:Skip,upstream_disabled:Disabled}), Cases)), close(Out)).

read_rows(In, Stack, Rows) :-
    read_term(In, Term, [syntax_errors(error),double_quotes(codes),term_position(Position)]),
    stream_position_data(line_count, Position, Line),
    (Term==end_of_file -> (Stack=[]->Rows=[];throw(unbalanced_conditionals));
     (Term = (:- if(C)) -> Rows=Tail, Next=[C|Stack];
      Term = (:- elif(C)) -> Stack=[Previous|Rest], Next=[(\+Previous,C)|Rest],Rows=Tail;
      Term = (:- else) -> Stack=[Previous|Rest],Next=[\+Previous|Rest],Rows=Tail;
      Term = (:- endif) -> Stack=[_|Next],Rows=Tail;
      Next=Stack,Rows=[row(Line,Stack,Term)|Tail]), read_rows(In,Next,Tail)).

test_clause((Head :- Body), Head, Body, false) :- compound(Head), functor(Head,test,_).
test_clause((-Head :- Body), Head, Body, true) :- compound(Head), functor(Head,test,_).
test_arguments([],true,[]).
test_arguments([Expected],Expected,[]).
test_arguments([Expected,Options],Expected,Options).

helper_clause((:- Declaration), (:- Single)) :-
    Declaration=..[Kind,PI],memberchk(Kind,[dynamic,multifile,discontiguous]),
    (is_list(PI)->member(Indicator,PI);Indicator=PI),Single=..[Kind,Indicator].
helper_clause((:- op(P,F,N)), (:- op(P,F,N))).
helper_clause((Head :- Body), (Renamed :- Lowered)) :-
    callable(Head),\+functor(Head,test,_),\+Head = -_,\+Head = (:-_),
    rename_helper(Head,Renamed),lower_goal(Body,Lowered).
helper_clause(Head,Renamed) :-
    callable(Head),\+Head = (_:-_),\+Head = (:-_),\+Head = -_,\+functor(Head,test,_),
    rename_helper(Head,Renamed).
rename_helper(setup,conf_suite_setup) :- !.
rename_helper(cleanup,conf_suite_cleanup) :- !.
rename_helper(Head,Head).

conjunction([],true).
conjunction([G|Gs],(G,T)) :- conjunction(Gs,T).
lower_options([],[]).
lower_options([O|Os],[N|Ns]) :-
    (O=..[K,G],memberchk(K,[condition,setup,cleanup])->lower_goal(G,L),N=..[K,L];N=O),
    lower_options(Os,Ns).

% Strict profile: Logtalk accepts common non-ISO exception variants. Retain
% the standard (first, unqualified) alternative; record both in cases.json.
lower_expectation(errors([Formal|_]),error(Formal)) :- !.
lower_expectation(true(Post),true(Lowered)) :- !,lower_goal(Post,Lowered).
lower_expectation(exists(Post),exists(Lowered)) :- !,lower_goal(Post,Lowered).
lower_expectation(E,E).

% Only goal positions are lowered; braces and lists inside data are preserved.
lower_goal(V,V) :- var(V),!.
lower_goal({G},L) :- !,lower_goal(G,L).
lower_goal(^^assertion(G),conf_assertion(L)) :- !,lower_goal(G,L).
lower_goal(^^G,L) :- !,G=..[Name|Args],atom_concat(conf_,Name,PortName),L=..[PortName|Args].
lower_goal(current_logtalk_flag(K,V),conf_profile(K,V)) :- !.
lower_goal(A::G,L) :- !,(memberchk(A,[list,lgtunit])->lower_goal(G,L);L=conf_dispatch(A,G)).
lower_goal((A,B),(C,D)) :- !,lower_goal(A,C),lower_goal(B,D).
lower_goal((A;B),(C;D)) :- !,lower_goal(A,C),lower_goal(B,D).
lower_goal((A->B),(C->D)) :- !,lower_goal(A,C),lower_goal(B,D).
lower_goal(\+A,\+B) :- !,lower_goal(A,B).
lower_goal(once(A),once(B)) :- !,lower_goal(A,B).
lower_goal(call(A),call(B)) :- nonvar(A),!,lower_goal(A,B).
lower_goal(forall(A,B),conf_forall(C,D)) :- !,lower_goal(A,C),lower_goal(B,D).
lower_goal(catch(A,E,B),catch(C,E,D)) :- !,lower_goal(A,C),lower_goal(B,D).
lower_goal(findall(T,A,L),findall(T,B,L)) :- !,lower_goal(A,B).
lower_goal(bagof(T,A,L),bagof(T,B,L)) :- !,lower_goal(A,B).
lower_goal(setof(T,A,L),setof(T,B,L)) :- !,lower_goal(A,B).
lower_goal(A^B,A^C) :- !,lower_goal(B,C).
lower_goal(assertion(A),conf_assertion(B)) :- !,lower_goal(A,B).
lower_goal(variant(A,B),conf_variant(A,B)) :- !.
lower_goal(subsumes_term(A,B),conf_subsumes(A,B)) :- !.
lower_goal(A =~= B,conf_approximately_equal(A,B)) :- !.
lower_goal(member(A,B),conf_member(A,B)) :- !.
lower_goal(memberchk(A,B),conf_memberchk(A,B)) :- !.
lower_goal(G,G).

% Both relative orders of distinct variables are implementation dependent.
% Upstream places the alternative after a committed IF and never reaches it.
% ISO 8.14.1.1 NOTE 2 leaves input consumed on an error undefined.
% Require the syntax error itself, without prescribing the remaining stream.
standard_body(iso_read_term_3_05,(Setup,(_,^^text_input_assertion(_,Assertion))),
              (Setup,catch((read(_),fail),error(syntax_error(_),_),Assertion=true))) :- !.
standard_body(iso_setof_3_17,(A->B;C),(A,(B;C))) :- !.
standard_body(_,Body,Body).

% Documented ooparts/prolog choices, not portable ISO-mandated numerical values.
implementation_defined_case(iso_bitwise_and_2_04).
implementation_defined_case(iso_bitwise_complement_1_03).
implementation_defined_case(iso_bitwise_left_shift_2_03).
implementation_defined_case(iso_bitwise_or_2_04).
implementation_defined_case(iso_bitwise_right_shift_2_03).
implementation_defined_case(iso_xor_2_03).

write_clause(S,Clause) :- term_text(Clause,Text),format(S,'~w~n',[Text]).
term_text(Term, Text) :-
    term_variables(Term, Variables),
    with_output_to(string(Text), (prolog_term(Term, Variables), write('.'))).
prolog_term(Var, Variables) :- var(Var), !, variable_index(Var, Variables, 0, N), format('V~d', [N]).
prolog_term([], _) :- !, write('[]').
prolog_term([H|T], Variables) :- !,
    write('['), prolog_term(H, Variables), write('|'), prolog_term(T, Variables), write(']').
prolog_term(Number, _) :- number(Number), !, write(Number).
prolog_term(Atom, _) :- atom(Atom), !, quoted_atom(Atom).
prolog_term(Term, Variables) :-
    Term =.. [Name|Args], quoted_atom(Name), write('('), prolog_args(Args, Variables), write(')').
prolog_args([A], Variables) :- !, prolog_term(A, Variables).
prolog_args([A|Args], Variables) :- prolog_term(A, Variables), write(','), prolog_args(Args, Variables).
variable_index(V, [H|T], N, Index) :- (V==H -> Index=N; M is N+1, variable_index(V,T,M,Index)).
quoted_atom(Atom) :-
    put_char('\''), atom_codes(Atom, Codes), maplist(atom_character, Codes), put_char('\'').
atom_character(39) :- !, write('\'\'').
atom_character(92) :- !, write('\\\\').
atom_character(10) :- !, write('\\n').
atom_character(13) :- !, write('\\r').
atom_character(9) :- !, write('\\t').
atom_character(C) :- put_code(C).

make_directory_path(D) :- (exists_directory(D)->true;file_directory_name(D,P),make_directory_path(P),make_directory(D)).
json_value(S, Dict) :- is_dict(Dict),!,dict_pairs(Dict,_,Pairs),put_char(S, '{'), json_pairs(S,Pairs),put_char(S, '}').
json_value(S, object(Pairs)) :- !, put_char(S, '{'), json_pairs(S, Pairs), put_char(S, '}').
json_value(S, List) :- is_list(List), !, put_char(S, '['), json_items(S, List), put_char(S, ']').
json_value(S, Number) :- number(Number), !, write(S, Number).
json_value(S, Text) :-
    (atom(Text) -> atom_codes(Text, Codes); string_codes(Text, Codes)),
    put_char(S, '"'), maplist(json_character(S), Codes), put_char(S, '"').
json_pairs(_, []).
json_pairs(S, [K-V|Pairs]) :-
    json_value(S, K), put_char(S, ':'), json_value(S, V),
    (Pairs=[] -> true; put_char(S, ','), json_pairs(S, Pairs)).
json_items(_, []).
json_items(S, [V|Items]) :-
    json_value(S, V), (Items=[] -> true; put_char(S, ','), json_items(S, Items)).
json_character(S, 34) :- !, write(S, '\\"').
json_character(S, 92) :- !, write(S, '\\\\').
json_character(S, 10) :- !, write(S, '\\n').
json_character(S, 13) :- !, write(S, '\\r').
json_character(S, 9) :- !, write(S, '\\t').
json_character(S, Code) :- Code < 32, !, format(S, '\\u~|~`0t~16r~4+', [Code]).
json_character(S, Code) :- put_code(S, Code).
