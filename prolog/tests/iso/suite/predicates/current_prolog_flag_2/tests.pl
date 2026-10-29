% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/current_prolog_flag_2/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

':-'('discontiguous'('/'('succeeds',1))).
':-'('discontiguous'('/'('fails',1))).
':-'('discontiguous'('/'('throws',2))).
'conf_case'('predicates/current_prolog_flag_2/tests.lgt:iso_current_prolog_flag_2_01:42','true','current_prolog_flag'('debug','off'),[],'true').
'conf_case'('predicates/current_prolog_flag_2/tests.lgt:iso_current_prolog_flag_2_02:45','true'(';'('=='(V0,'true'),'=='(V0,'false'))),'current_prolog_flag'('bounded',V0),[],'true').
'conf_case'('predicates/current_prolog_flag_2/tests.lgt:iso_current_prolog_flag_2_03:48','true',';'('->'('current_prolog_flag'('bounded','true'),','('current_prolog_flag'('max_integer',V0),'integer'(V0))),'true'),[],'true').
'conf_case'('predicates/current_prolog_flag_2/tests.lgt:iso_current_prolog_flag_2_04:55','true',';'('->'('current_prolog_flag'('bounded','true'),','('current_prolog_flag'('min_integer',V0),'integer'(V0))),'true'),[],'true').
'conf_case'('predicates/current_prolog_flag_2/tests.lgt:iso_current_prolog_flag_2_05:62','true'(';'('=='(V0,'down'),'=='(V0,'toward_zero'))),'current_prolog_flag'('integer_rounding_function',V0),[],'true').
'conf_case'('predicates/current_prolog_flag_2/tests.lgt:iso_current_prolog_flag_2_06:65','true'(';'('=='(V0,'on'),'=='(V0,'off'))),'current_prolog_flag'('char_conversion',V0),[],'true').
'conf_case'('predicates/current_prolog_flag_2/tests.lgt:iso_current_prolog_flag_2_07:68','true'(';'('=='(V0,'on'),'=='(V0,'off'))),'current_prolog_flag'('debug',V0),[],'true').
'conf_case'('predicates/current_prolog_flag_2/tests.lgt:iso_current_prolog_flag_2_08:71','true',','('current_prolog_flag'('max_arity',V0),';'('->'('=='(V0,'unbounded'),'true'),','('integer'(V0),'>'(V0,0)))),[],'true').
'conf_case'('predicates/current_prolog_flag_2/tests.lgt:iso_current_prolog_flag_2_09:78','true'(';'('=='(V0,'error'),';'('=='(V0,'fail'),'=='(V0,'warning')))),'current_prolog_flag'('unknown',V0),[],'true').
'conf_case'('predicates/current_prolog_flag_2/tests.lgt:iso_current_prolog_flag_2_10:81','true'(';'('=='(V0,'chars'),';'('=='(V0,'codes'),'=='(V0,'atom')))),'current_prolog_flag'('double_quotes',V0),[],'true').
'conf_case'('predicates/current_prolog_flag_2/tests.lgt:iso_current_prolog_flag_2_11:84','error'('type_error'('atom',5)),'current_prolog_flag'(5,V0),[],'true').
