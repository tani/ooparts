% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/not_1/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'conf_case'('predicates/not_1/tests.lgt:iso_not_1_01:34','false','\\+'('true'),[],'true').
'conf_case'('predicates/not_1/tests.lgt:iso_not_1_02:37','false','\\+'('!'),[],'true').
'conf_case'('predicates/not_1/tests.lgt:iso_not_1_03:40','true','\\+'(','('!','fail')),[],'true').
'conf_case'('predicates/not_1/tests.lgt:iso_not_1_04:43','true'('=='(V0,[1|[2|[]]])),'findall'(V1,','(';'('='(V1,1),'='(V1,2)),'\\+'(','('!','fail'))),V0),[],'true').
'conf_case'('predicates/not_1/tests.lgt:iso_not_1_05:46','true','\\+'('='(4,5)),[],'true').
'conf_case'('predicates/not_1/tests.lgt:iso_not_1_06:49','error'('type_error'('callable',3)),','('='(V0,'\\+'(3)),V0),[],'true').
'conf_case'('predicates/not_1/tests.lgt:iso_not_1_07:54','error'('instantiation_error'),','('='(V0,'\\+'(V1)),V0),[],'true').
'conf_case'('predicates/not_1/tests.lgt:iso_not_1_08:64','false','\\+'('='(V0,'f'(V0))),[],','(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse')))),'true')).
'conf_case'('predicates/not_1/tests.lgt:iso_not_1_08:69','false','\\+'('='(V0,'f'(V0))),['note'('STO')|[]],','('\\+'(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse'))))),'true')).
