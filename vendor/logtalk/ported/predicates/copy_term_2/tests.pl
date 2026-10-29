% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/copy_term_2/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'conf_case'('predicates/copy_term_2/tests.lgt:iso_copy_term_2_01:34','true','copy_term'(V0,V1),[],'true').
'conf_case'('predicates/copy_term_2/tests.lgt:iso_copy_term_2_02:37','true','copy_term'(V0,3),[],'true').
'conf_case'('predicates/copy_term_2/tests.lgt:iso_copy_term_2_03:40','true','copy_term'(V0,'a'),[],'true').
'conf_case'('predicates/copy_term_2/tests.lgt:iso_copy_term_2_04:43','true'('=='(V0,'a')),'copy_term'('+'('a',V0),'+'(V0,'b')),[],'true').
'conf_case'('predicates/copy_term_2/tests.lgt:iso_copy_term_2_05:46','true','copy_term'(V0,V1),[],'true').
'conf_case'('predicates/copy_term_2/tests.lgt:iso_copy_term_2_06:49','true'('=='(V0,V1)),'copy_term'('+'('+'(V2,V2),V3),'+'('+'(V0,V1),V1)),[],'true').
'conf_case'('predicates/copy_term_2/tests.lgt:iso_copy_term_2_07:52','false','copy_term'('a','b'),[],'true').
'conf_case'('predicates/copy_term_2/tests.lgt:iso_copy_term_2_08:55','false',','('copy_term'('+'('a',V0),'+'(V0,'b')),'copy_term'('+'('a',V0),'+'(V0,'b'))),[],'true').
'conf_case'('predicates/copy_term_2/tests.lgt:iso_copy_term_2_09:64','true','copy_term'('demoen'(V0,V0),'demoen'(V1,'f'(V1))),[],','(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse')))),'true')).
'conf_case'('predicates/copy_term_2/tests.lgt:iso_copy_term_2_09:69','true','copy_term'('demoen'(V0,V0),'demoen'(V1,'f'(V1))),['note'('STO')|[]],','('\\+'(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse'))))),'true')).
'conf_case'('predicates/copy_term_2/tests.lgt:iso_copy_term_2_10:77','true'(','('=='(V0,V1),'=='(V2,V3))),','('='(V4,'a'(V0,V2)),','('='(V5,'a'(V6,V7)),','('copy_term'(V4,V5),'='(V4,'a'(V1,V3))))),[],'true').
'conf_case'('predicates/copy_term_2/tests.lgt:iso_copy_term_2_11:83','true'(','('\\=='(V0,V1),','('\\=='(V0,V2),','('\\=='(V3,V2),'\\=='(V3,V1))))),','('='(V4,'a'(V0,V3)),','('='(V5,'a'(V1,V2)),'copy_term'(V4,V5))),[],'true').
