% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/not_unifiable_2/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'conf_case'('predicates/not_unifiable_2/tests.lgt:iso_not_unifiable_2_01:34','false','\\='(1,1),[],'true').
'conf_case'('predicates/not_unifiable_2/tests.lgt:iso_not_unifiable_2_02:37','false','\\='(V0,1),[],'true').
'conf_case'('predicates/not_unifiable_2/tests.lgt:iso_not_unifiable_2_03:40','false','\\='(V0,V1),[],'true').
'conf_case'('predicates/not_unifiable_2/tests.lgt:iso_not_unifiable_2_04:43','false','\\='(V0,V1),[],'true').
'conf_case'('predicates/not_unifiable_2/tests.lgt:iso_not_unifiable_2_05:46','false','\\='('f'(V0,'def'),'f'('def',V1)),[],'true').
'conf_case'('predicates/not_unifiable_2/tests.lgt:iso_not_unifiable_2_06:49','true','\\='(1,2),[],'true').
'conf_case'('predicates/not_unifiable_2/tests.lgt:iso_not_unifiable_2_07:52','true','\\='(1,1.0),[],'true').
'conf_case'('predicates/not_unifiable_2/tests.lgt:iso_not_unifiable_2_08:55','true','\\='('g'(V0),'f'('f'(V0))),[],'true').
'conf_case'('predicates/not_unifiable_2/tests.lgt:iso_not_unifiable_2_09:58','true','\\='('f'(V0,1),'f'('a'(V0))),[],'true').
'conf_case'('predicates/not_unifiable_2/tests.lgt:iso_not_unifiable_2_10:61','true','\\='('f'(V0,V1,V0),'f'('a'(V0),'a'(V1),V1,2)),[],'true').
'conf_case'('predicates/not_unifiable_2/tests.lgt:iso_not_unifiable_2_11:70','false','\\='(V0,'a'(V0)),[],','(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse')))),'true')).
'conf_case'('predicates/not_unifiable_2/tests.lgt:iso_not_unifiable_2_12:73','true','\\='('f'(V0,1),'f'('a'(V0),2)),[],','(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse')))),'true')).
'conf_case'('predicates/not_unifiable_2/tests.lgt:iso_not_unifiable_2_13:76','true','\\='('f'(1,V0,1),'f'(2,'a'(V0),2)),[],','(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse')))),'true')).
'conf_case'('predicates/not_unifiable_2/tests.lgt:iso_not_unifiable_2_14:79','true','\\='('f'(1,V0),'f'(2,'a'(V0))),[],','(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse')))),'true')).
'conf_case'('predicates/not_unifiable_2/tests.lgt:iso_not_unifiable_2_15:82','true','\\='('f'(V0,V1,V0,1),'f'('a'(V0),'a'(V1),V1,2)),[],','(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse')))),'true')).
'conf_case'('predicates/not_unifiable_2/tests.lgt:iso_not_unifiable_2_11:87','false','\\='(V0,'a'(V0)),['note'('STO')|[]],','('\\+'(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse'))))),'true')).
'conf_case'('predicates/not_unifiable_2/tests.lgt:iso_not_unifiable_2_12:91','true','\\='('f'(V0,1),'f'('a'(V0),2)),['note'('STO')|[]],','('\\+'(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse'))))),'true')).
'conf_case'('predicates/not_unifiable_2/tests.lgt:iso_not_unifiable_2_13:95','true','\\='('f'(1,V0,1),'f'(2,'a'(V0),2)),['note'('STO')|[]],','('\\+'(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse'))))),'true')).
'conf_case'('predicates/not_unifiable_2/tests.lgt:iso_not_unifiable_2_14:99','true','\\='('f'(1,V0),'f'(2,'a'(V0))),['note'('STO')|[]],','('\\+'(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse'))))),'true')).
'conf_case'('predicates/not_unifiable_2/tests.lgt:iso_not_unifiable_2_15:103','true','\\='('f'(V0,V1,V0,1),'f'('a'(V0),'a'(V1),V1,2)),['note'('STO')|[]],','('\\+'(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse'))))),'true')).
