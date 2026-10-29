% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/keysort_2/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'conf_case'('predicates/keysort_2/tests.lgt:iso_keysort_2_01:34','true'('=='(V0,['-'(1,1)|['-'(1,1)|[]]])),'keysort'(['-'(1,1)|['-'(1,1)|[]]],V0),[],'true').
'conf_case'('predicates/keysort_2/tests.lgt:iso_keysort_2_02:37','true'('=='(V0,['-'(1,'a')|['-'(1,'z')|['-'(1,'a')|['-'(2,99)|['-'(2,44)|['-'(3,'f'(V1))|[]]]]]]])),'keysort'(['-'(2,99)|['-'(1,'a')|['-'(3,'f'(V1))|['-'(1,'z')|['-'(1,'a')|['-'(2,44)|[]]]]]]],V0),[],'true').
'conf_case'('predicates/keysort_2/tests.lgt:iso_keysort_2_03:40','true'('=='(V0,2)),'keysort'(['-'(V0,1)|['-'(1,1)|[]]],['-'(2,1)|['-'(1,1)|[]]]),[],'true').
'conf_case'('predicates/keysort_2/tests.lgt:iso_keysort_2_04:43','true',','('='(V0,['-'(1,2)|V0]),'keysort'(V0,V1)),['note'('STO')|[]],'true').
'conf_case'('predicates/keysort_2/tests.lgt:iso_keysort_2_05:53','true','keysort'(['-'(V0,V0)|[]],V0),[],','(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse')))),'true')).
'conf_case'('predicates/keysort_2/tests.lgt:iso_keysort_2_05:58','true','keysort'(['-'(V0,V0)|[]],V0),['note'('STO')|[]],','('\\+'(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse'))))),'true')).
