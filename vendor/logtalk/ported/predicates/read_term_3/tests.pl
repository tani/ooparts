% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/read_term_3/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

':-'('conf_suite_cleanup',','('conf_clean_text_input',','('conf_clean_binary_input','conf_clean_text_output'))).
':-'('max_min_integer_as_atom'(V0,V1,V2),';'('->'('current_prolog_flag'('bounded','true'),','('current_prolog_flag'(V0,V1),','('number_codes'(V1,V3),'atom_codes'(V2,V3)))),','('='(V1,0),'='(V2,'0')))).
'conf_case'('predicates/read_term_3/tests.lgt:iso_read_term_3_01:38','true'(V0),','('conf_set_text_input'('term1. term2. ...'),','('read'(V1),','('=='(V1,'term1'),'conf_text_input_assertion'(' term2. ...',V0)))),[],'true').
'conf_case'('predicates/read_term_3/tests.lgt:iso_read_term_3_02:44','true'(V0),','('conf_set_text_input'('in','term1. term2. ...'),','('read'('in','term1'),'conf_text_input_assertion'('in',' term2. ...',V0))),[],'true').
'conf_case'('predicates/read_term_3/tests.lgt:iso_read_term_3_03:49','true',','('conf_set_text_input'('in',['foo(A+Roger,A+_). '|['term2. ...'|[]]]),','('read_term'('in',V0,['variables'(V1)|['variable_names'(V2)|['singletons'(V3)|[]]]]),','('conf_text_input_assertion'('in',' term2. ...',V4),','('conf_assertion'('conf_variant'(V0,'foo'('+'(V5,V6),'+'(V5,V7)))),','('='(V0,'foo'('+'(V5,V6),'+'(V5,V7))),','('conf_assertion'('=='(V1,[V5|[V6|[V7|[]]]])),','('conf_assertion'('=='(V2,['='('A',V5)|['='('Roger',V6)|[]]])),','('conf_assertion'('=='(V3,['='('Roger',V6)|[]])),'conf_assertion'(V4))))))))),[],'true').
'conf_case'('predicates/read_term_3/tests.lgt:iso_read_term_3_04:60','true'(V0),','('conf_set_text_input'('3.1.  term2. ...'),','('\\+'('read'(4.1)),'conf_text_input_assertion'('  term2. ...',V0))),[],'true').
'conf_case'('predicates/read_term_3/tests.lgt:iso_read_term_3_05:65','true'(V0),','('conf_set_text_input'('foo 123. term2. ...'),'catch'(','('read'(V1),'fail'),'error'('syntax_error'(V2),V3),'='(V0,'true'))),[],'true').
'conf_case'('predicates/read_term_3/tests.lgt:iso_read_term_3_06:70','true',','('conf_set_text_input'('3.1'),'catch'('read'(V0),'error'('syntax_error'(V1),V2),'true')),[],'true').
