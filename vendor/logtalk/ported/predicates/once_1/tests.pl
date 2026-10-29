% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/once_1/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'variable'(V0).
'three'(3).
'conf_case'('predicates/once_1/tests.lgt:iso_once_1_01:34','true','once'('!'),[],'true').
'conf_case'('predicates/once_1/tests.lgt:iso_once_1_02:37','true'('=='(V0,[1|[2|[]]])),'findall'(V1,','('once'('!'),';'('='(V1,1),'='(V1,2))),V0),[],'true').
'conf_case'('predicates/once_1/tests.lgt:iso_once_1_03:40','deterministic','once'('repeat'),[],'true').
'conf_case'('predicates/once_1/tests.lgt:iso_once_1_04:43','false','once'('fail'),[],'true').
'conf_case'('predicates/once_1/tests.lgt:iso_once_1_05:52','true','once'('='(V0,'f'(V0))),[],','(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse')))),'true')).
'conf_case'('predicates/once_1/tests.lgt:iso_once_1_05:57','true','once'('='(V0,'f'(V0))),['note'('STO')|[]],','('\\+'(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse'))))),'true')).
