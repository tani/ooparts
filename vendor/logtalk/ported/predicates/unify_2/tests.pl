% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/unify_2/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'conf_case'('predicates/unify_2/tests.lgt:iso_unify_2_01:34','true','='(1,1),[],'true').
'conf_case'('predicates/unify_2/tests.lgt:iso_unify_2_02:37','true'('=='(V0,1)),'='(V0,1),[],'true').
'conf_case'('predicates/unify_2/tests.lgt:iso_unify_2_03:40','true'('=='(V0,V1)),'='(V0,V1),[],'true').
'conf_case'('predicates/unify_2/tests.lgt:iso_unify_2_04:43','true','='(V0,V1),[],'true').
'conf_case'('predicates/unify_2/tests.lgt:iso_unify_2_05:46','true'(','('=='(V0,'abc'),'=='(V1,'abc'))),','('='(V0,V1),'='(V0,'abc')),[],'true').
'conf_case'('predicates/unify_2/tests.lgt:iso_unify_2_06:49','true'(','('=='(V0,'def'),'=='(V1,'def'))),'='('f'(V0,'def'),'f'('def',V1)),[],'true').
'conf_case'('predicates/unify_2/tests.lgt:iso_unify_2_07:52','false','='(1,2),[],'true').
'conf_case'('predicates/unify_2/tests.lgt:iso_unify_2_08:55','false','='(1,1.0),[],'true').
'conf_case'('predicates/unify_2/tests.lgt:iso_unify_2_09:58','false','='('g'(V0),'f'('f'(V0))),[],'true').
'conf_case'('predicates/unify_2/tests.lgt:iso_unify_2_10:61','false','='('f'(V0,1),'f'('a'(V0))),[],'true').
'conf_case'('predicates/unify_2/tests.lgt:iso_unify_2_11:64','false','='('f'(V0,V1,V0),'f'('a'(V0),'a'(V1),V1,2)),[],'true').
'conf_case'('predicates/unify_2/tests.lgt:iso_unify_2_12:73','true','='(V0,'a'(V0)),[],','(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse')))),'true')).
'conf_case'('predicates/unify_2/tests.lgt:iso_unify_2_13:76','false','='('f'(V0,1),'f'('a'(V0),2)),[],','(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse')))),'true')).
'conf_case'('predicates/unify_2/tests.lgt:iso_unify_2_14:79','false','='('f'(1,V0,1),'f'(2,'a'(V0),2)),[],','(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse')))),'true')).
'conf_case'('predicates/unify_2/tests.lgt:iso_unify_2_15:82','false','='('f'(1,V0),'f'(2,'a'(V0))),[],','(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse')))),'true')).
'conf_case'('predicates/unify_2/tests.lgt:iso_unify_2_16:85','false','='('f'(V0,V1,V0,1),'f'('a'(V0),'a'(V1),V1,2)),[],','(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse')))),'true')).
'conf_case'('predicates/unify_2/tests.lgt:iso_unify_2_17:88','true',','('='(V0,[1|[2|[3|V0]]]),','('='(V1,[1|[2|[3|[1|[2|[3|V1]]]]]]),'=='(V0,V1))),[],','(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse')))),'true')).
'conf_case'('predicates/unify_2/tests.lgt:iso_unify_2_12:93','true','='(V0,'a'(V0)),['note'('STO')|[]],','('\\+'(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse'))))),'true')).
'conf_case'('predicates/unify_2/tests.lgt:iso_unify_2_13:97','false','='('f'(V0,1),'f'('a'(V0),2)),['note'('STO')|[]],','('\\+'(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse'))))),'true')).
'conf_case'('predicates/unify_2/tests.lgt:iso_unify_2_14:101','false','='('f'(1,V0,1),'f'(2,'a'(V0),2)),['note'('STO')|[]],','('\\+'(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse'))))),'true')).
'conf_case'('predicates/unify_2/tests.lgt:iso_unify_2_15:105','false','='('f'(1,V0),'f'(2,'a'(V0))),['note'('STO')|[]],','('\\+'(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse'))))),'true')).
'conf_case'('predicates/unify_2/tests.lgt:iso_unify_2_16:109','false','='('f'(V0,V1,V0,1),'f'('a'(V0),'a'(V1),V1,2)),['note'('STO')|[]],','('\\+'(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse'))))),'true')).
'conf_case'('predicates/unify_2/tests.lgt:iso_unify_2_17:113','true',','('='(V0,[1|[2|[3|V0]]]),','('='(V1,[1|[2|[3|[1|[2|[3|V1]]]]]]),'='(V0,V1))),['note'('STO')|[]],','('\\+'(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse'))))),'true')).
