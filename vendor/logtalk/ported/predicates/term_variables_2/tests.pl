% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/term_variables_2/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'quick_check'('iso_term_variables_2_01','twice'('+'('term'))).
'quick_check'('iso_term_variables_2_02','chain'('+'('term'))).
':-'('twice'(V0),','('term_variables'(V0,V1),','('term_variables'(V0,V2),'=='(V1,V2)))).
':-'('chain'(V0),','('term_variables'(V0,V1),','('term_variables'(V1,V2),'=='(V1,V2)))).
'conf_case'('predicates/term_variables_2/tests.lgt:iso_term_variables_2_03:40','true'('=='(V0,[])),'term_variables'('t',V0),[],'true').
'conf_case'('predicates/term_variables_2/tests.lgt:iso_term_variables_2_04:43','true'('=='(V0,[V1|[V2|[V3|[V4|[]]]]])),'term_variables'('-'('+'(V1,'/'('*'(V2,V3),V2)),V4),V0),[],'true').
'conf_case'('predicates/term_variables_2/tests.lgt:iso_term_variables_2_05:46','error'('type_error'('list',[V0|[V1|'a']])),'term_variables'('t',[V2|[V3|'a']]),[],'true').
'conf_case'('predicates/term_variables_2/tests.lgt:iso_term_variables_2_06:49','true',','(','('='(V0,'+'(V1,V2)),','('='(V2,'*'(V3,V1)),'term_variables'(V0,V4))),','('conf_assertion'('=='(V4,[V1|[V3|[]]])),','('conf_assertion'('=='(V2,'*'(V3,V1))),'conf_assertion'('=='(V0,'+'(V1,'*'(V3,V1))))))),[],'true').
'conf_case'('predicates/term_variables_2/tests.lgt:iso_term_variables_2_07:55','true',','(','('='(V0,'*'(V1,V2)),','('='(V3,'+'(V2,V0)),'term_variables'(V3,V4))),','('conf_assertion'('=='(V4,[V2|[V1|[]]])),','('conf_assertion'('=='(V0,'*'(V1,V2))),'conf_assertion'('=='(V3,'+'(V2,'*'(V1,V2))))))),[],'true').
'conf_case'('predicates/term_variables_2/tests.lgt:iso_term_variables_2_08:61','true',','('term_variables'('+'('+'(V0,V1),V1),[V1|V2]),','('conf_assertion'('=='(V0,V1)),'conf_assertion'('=='(V2,[V1|[]])))),[],'true').
'conf_case'('predicates/term_variables_2/tests.lgt:iso_term_variables_2_09:72','subsumes'([V0|[V1|[]]],V2),'term_variables'('+'(V3,V2),V2),[],','(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse')))),'true')).
'conf_case'('predicates/term_variables_2/tests.lgt:iso_term_variables_2_09:77','subsumes'([V0|[V1|[]]],V2),'term_variables'('+'(V3,V2),V2),['note'('STO')|[]],','('\\+'(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse'))))),'true')).
