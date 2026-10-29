% SPDX-License-Identifier: MIT
% Portable driver for the Apache-2.0 cases in suite/. No Logtalk is loaded.
% Each invocation runs in a fresh database and temporary working directory.
:- dynamic(conf_input/2).
:- dynamic(conf_output/2).
:- dynamic(conf_original_input/1).
:- dynamic(conf_original_output/1).

conf_execute(ID, R) :-
    conf_case(ID, Expected, Goal, Options, Condition),
    (call(Condition), conf_conditions(Options) ->
        conf_options_setup(Options),
        conf_check(Expected, Goal, R),
        conf_options_cleanup(Options)
    ; R = skipped_condition).

conf_conditions([]).
conf_conditions([condition(G)|Os]) :- !, call(G), conf_conditions(Os).
conf_conditions([_|Os]) :- conf_conditions(Os).
conf_options_setup([]).
conf_options_setup([setup(G)|Os]) :- !, call(G), conf_options_setup(Os).
conf_options_setup([_|Os]) :- conf_options_setup(Os).
conf_options_cleanup([]).
conf_options_cleanup([cleanup(G)|Os]) :- !, call(G), conf_options_cleanup(Os).
conf_options_cleanup([_|Os]) :- conf_options_cleanup(Os).

conf_check(E, G, R) :- catch(conf_expected(E, G, R), X, R = exception(X)).
conf_expected(true, G, R) :- !, (call(G) -> R=pass ; R=unexpected_failure).
conf_expected(false, G, R) :- !, (call(G) -> R=unexpected_success ; R=pass).
conf_expected(fail, G, R) :- !, conf_expected(false, G, R).
conf_expected(true(P), G, R) :- !,
    (call(G) -> (call(P) -> R=pass ; R=post_failed(P)) ; R=unexpected_failure).
conf_expected(exists(P), G, R) :- !,
    ((call(G),call(P)) -> R=pass ; R=no_matching_solution).
conf_expected(variant(A,B), G, R) :- !,
    conf_expected(true(conf_variant(A,B)), G, R).
conf_expected(subsumes(A,B), G, R) :- !,
    conf_expected(true(conf_subsumes(A,B)), G, R).
% ISO cannot portably observe whether a residual choice point exists.
% This check requires exactly one answer; that limitation is recorded in README.
conf_expected(deterministic, G, R) :- !,
    findall(1,G,L), (L==[1] -> R=pass ; R=answer_count(L)).
conf_expected(ball(B), G, R) :- !,
    catch((call(G) -> R=missing_ball ; R=missing_ball), X,
          (X=B -> R=pass ; R=wrong_ball(X))).
conf_expected(error(F), G, R) :- !,
    catch((call(G) -> R=missing_error ; R=missing_error), X,
          (X=error(F,_) -> R=pass ; R=wrong_error(F,X))).
conf_expected(E, _, _) :- throw(conf_unknown_expectation(E)).

conf_member(X,[X|_]).
conf_member(X,[_|Xs]) :- conf_member(X,Xs).
conf_memberchk(X,Xs) :- conf_member(X,Xs), !.
conf_forall(A,B) :- \+ (call(A), \+ call(B)).
conf_assertion(G) :- (call(G) -> true ; throw(conf_assertion_failed(G))).
conf_subsumes(A,B) :-
    copy_term(A-B,C-D), term_variables(D,Before), C=D,
    term_variables(Before,After), Before==After.
conf_variant(A,B) :- conf_subsumes(A,B), conf_subsumes(B,A).
% Only expectations explicitly using lgtunit's =~= are approximate.
conf_approximately_equal(A,B) :-
    number(A), number(B),
    D is abs(A-B), M is max(abs(A),abs(B)),
    (D < 0.0000000001 ; D < 0.00001*M).

% Adapter profile, not predicates under test. ISO-undefined STO cases are
% excluded by the inventory; the profile does not impose cyclic semantics.
conf_profile(coinduction,supported).
conf_profile(prolog_dialect,ooparts/prolog).
conf_dispatch(os,operating_system_type(unix)).
conf_suppress_text_output.

conf_file_path(Name,Name).
conf_fixture_write(X,S) :-
    (X==[] -> true
    ; atom(X) -> write(S,X)
    ; integer(X) -> put_code(S,X)
    ; X=[H|T], conf_fixture_write(H,S), conf_fixture_write(T,S)).
conf_create_text_file(Path,Contents) :-
    open(Path,write,S), conf_fixture_write(Contents,S), close(S).
conf_create_binary_file(Path,Bytes) :-
    open(Path,write,S,[type(binary)]), conf_write_bytes(Bytes,S), close(S).
conf_write_bytes([],_).
conf_write_bytes([B|Bs],S) :- put_byte(S,B), conf_write_bytes(Bs,S).
conf_remaining(S,Codes) :-
    get_code(S,C), (C =:= -1 -> Codes=[] ; Codes=[C|Cs], conf_remaining(S,Cs)).
conf_text_codes(Text,Codes) :-
    conf_create_text_file('conf-expected.txt',Text),
    open('conf-expected.txt',read,S), conf_remaining(S,Codes), close(S).
conf_check_text_file(Path,Expected) :-
    open(Path,read,S), conf_remaining(S,Actual), close(S),
    conf_text_codes(Expected,Codes), conf_assertion(Actual==Codes).
conf_clean_file(_).

conf_save_input :-
    (conf_original_input(_) -> true ; current_input(S),assertz(conf_original_input(S))).
conf_save_output :-
    (conf_original_output(_) -> true ; current_output(S),assertz(conf_original_output(S))).
conf_set_text_input(Text) :-
    conf_save_input, conf_create_text_file('conf-input.txt',Text),
    open('conf-input.txt',read,S),assertz(conf_input(default,S)),set_input(S).
conf_set_text_input(Alias,Text) :-
    conf_create_text_file(Alias,Text),open(Alias,read,S,[alias(Alias)]),
    assertz(conf_input(Alias,S)).
conf_clean_text_input :-
    (conf_original_input(S) -> catch(set_input(S),_,true) ; true),
    conf_close_inputs.
conf_close_inputs :-
    (retract(conf_input(_,S)) -> catch(close(S),_,true),conf_close_inputs ; true).
conf_set_text_output(Text) :-
    conf_save_output,open('conf-output.txt',write,S),conf_fixture_write(Text,S),
    assertz(conf_output(default,S)),set_output(S).
conf_set_text_output(Alias,Text) :-
    open(Alias,write,S,[alias(Alias)]),conf_fixture_write(Text,S),assertz(conf_output(Alias,S)).
conf_clean_text_output :-
    (conf_original_output(S) -> catch(set_output(S),_,true) ; true),
    conf_close_outputs.
conf_close_outputs :-
    (retract(conf_output(_,S)) -> catch(close(S),_,true),conf_close_outputs ; true).
conf_text_output_assertion(Expected,Assertion) :-
    conf_text_output_assertion(default,Expected,Assertion).
conf_text_output_assertion(Alias,Expected,Assertion) :-
    conf_output(Alias,S),flush_output(S),
    (Alias==default -> Path='conf-output.txt' ; Path=Alias),
    open(Path,read,In),conf_remaining(In,Actual),close(In),
    conf_text_codes(Expected,Codes),Assertion=(Actual==Codes).
conf_check_text_output(Expected) :-
    conf_text_output_assertion(Expected,A),conf_assertion(A).
conf_check_text_output(Alias,Expected) :-
    conf_text_output_assertion(Alias,Expected,A),conf_assertion(A).
conf_text_input_assertion(Expected,Assertion) :-
    conf_text_input_assertion(default,Expected,Assertion).
conf_text_input_assertion(Alias,Expected,Assertion) :-
    conf_input(Alias,S),conf_remaining(S,Actual),
    conf_text_codes(Expected,Codes),Assertion=(Actual==Codes).
conf_check_text_input(Expected) :-
    conf_text_input_assertion(Expected,A),conf_assertion(A).
conf_check_text_input(Alias,Expected) :-
    conf_text_input_assertion(Alias,Expected,A),conf_assertion(A).
conf_closed_input_stream(S,Options) :-
    conf_create_text_file('conf-closed-input.txt',''),
    open('conf-closed-input.txt',read,S,Options),close(S).
conf_closed_output_stream(S,Options) :-
    open('conf-closed-output.txt',write,S,Options),close(S).

conf_clean_binary_input :- conf_clean_text_input.
conf_clean_binary_output :- conf_clean_text_output.
conf_set_binary_output(Bytes) :-
    conf_save_output,open('conf-output.txt',write,S,[type(binary)]),
    conf_write_bytes(Bytes,S),assertz(conf_output(default,S)),set_output(S).
conf_set_binary_output(Alias,Bytes) :-
    open(Alias,write,S,[type(binary),alias(Alias)]),conf_write_bytes(Bytes,S),
    assertz(conf_output(Alias,S)).
conf_binary_remaining(S,Bytes) :-
    get_byte(S,B), (B =:= -1 -> Bytes=[] ; Bytes=[B|Bs],conf_binary_remaining(S,Bs)).
conf_binary_output_assertion(Bytes,Assertion) :-
    conf_binary_output_assertion(default,Bytes,Assertion).
conf_binary_output_assertion(Alias,Bytes,Assertion) :-
    conf_output(Alias,S),flush_output(S),
    (Alias==default -> Path='conf-output.txt' ; Path=Alias),
    open(Path,read,In,[type(binary)]),conf_binary_remaining(In,Actual),close(In),
    Assertion=(Actual==Bytes).
conf_text_output_contents(Chars) :-
    conf_output(default,S),flush_output(S),
    open('conf-output.txt',read,In),conf_remaining(In,Codes),close(In),
    conf_codes_chars(Codes,Chars).
conf_codes_chars([],[]).
conf_codes_chars([C|Cs],[A|As]) :- char_code(A,C),conf_codes_chars(Cs,As).
