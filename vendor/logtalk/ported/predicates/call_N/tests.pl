% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/call_N/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'two'(2).
'call_n_maplist'(V0,[]).
':-'('call_n_maplist'(V0,[V1|V2]),','('call'(V0,V1),'call_n_maplist'(V0,V2))).
'three'(3).
'variable'(V0).
'goal'('two',V0).
'conf_case'('predicates/call_N/tests.lgt:iso_call_N_01:44','true','call'('integer',3),[],'true').
'conf_case'('predicates/call_N/tests.lgt:iso_call_N_02:47','true'('=='(V0,'c')),'call'('functor'(V0,'c'),0),[],'true').
'conf_case'('predicates/call_N/tests.lgt:iso_call_N_03:50','true'('=='(V0,'prolog')),'call'('call'('call'('atom_concat','pro'),'log'),V0),[],'true').
'conf_case'('predicates/call_N/tests.lgt:iso_call_N_04:53','variant'(V0,['-'(1,V1)|['-'(V2,2)|[]]]),'findall'('-'(V3,V4),'call'(';','='(V3,1),'='(V4,2)),V0),[],'true').
'conf_case'('predicates/call_N/tests.lgt:iso_call_N_05:56','false','call'(';','->'('true','fail'),'='(V0,1)),[],'true').
'conf_case'('predicates/call_N/tests.lgt:iso_call_N_06:59','true','call_n_maplist'('>'(3),[1|[2|[]]]),[],'true').
'conf_case'('predicates/call_N/tests.lgt:iso_call_N_07:62','false','call_n_maplist'('>'(3),[1|[2|[3|[]]]]),[],'true').
'conf_case'('predicates/call_N/tests.lgt:iso_call_N_08:65','true'('=='(V0,[])),'call_n_maplist'('='(V1),V0),[],'true').
