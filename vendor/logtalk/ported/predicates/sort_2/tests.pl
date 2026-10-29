% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/sort_2/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'conf_case'('predicates/sort_2/tests.lgt:iso_sort_2_01:34','true'('=='(V0,[1|[]])),'sort'([1|[1|[]]],V0),[],'true').
'conf_case'('predicates/sort_2/tests.lgt:iso_sort_2_02:37','true'('=='(V0,[V1|[7.0|[8.0|[1|[2|['a'|['z'|['-'(V2)|['-'('a')|['+'(1,V3)|['+'(1,2)|[]]]]]]]]]]]])),'sort'(['+'(1,V3)|['z'|['a'|[V1|[1|[2|[V1|[1|[7.0|[8.0|['+'(1,V3)|['+'(1,2)|[8.0|['-'('a')|['-'(V2)|['a'|[]]]]]]]]]]]]]]]]],V0),[],'true').
'conf_case'('predicates/sort_2/tests.lgt:iso_sort_2_03:40','false','sort'([1|[1|[]]],[1|[1|[]]]),[],'true').
'conf_case'('predicates/sort_2/tests.lgt:iso_sort_2_04:49','true','sort'([V0|[]],V0),[],','(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse')))),'true')).
'conf_case'('predicates/sort_2/tests.lgt:iso_sort_2_04:54','true','sort'([V0|[]],V0),['note'('STO')|[]],','('\\+'(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse'))))),'true')).
'conf_case'('predicates/sort_2/tests.lgt:iso_sort_2_05:60','true'(';'('=='(V0,[V1|[V2|['f'(V1)|['f'(V2)|[]]]]]),'=='(V0,[V2|[V1|['f'(V2)|['f'(V1)|[]]]]]))),'sort'(['f'(V1)|[V1|[V1|['f'(V2)|['f'(V1)|[V2|[]]]]]]],V0),[],'true').
