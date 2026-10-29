% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/findall_3/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'f'(V0,1).
'f'(V0,2).
'four'(4).
'conf_case'('predicates/findall_3/tests.lgt:iso_findall_3_01:40','true'('=='(V0,[1|[2|[]]])),'findall'(V1,';'('='(V1,1),'='(V1,2)),V0),[],'true').
'conf_case'('predicates/findall_3/tests.lgt:iso_findall_3_02:43','variant'(V0,['+'(1,V1)|[]]),'findall'('+'(V2,V3),'='(V2,1),V0),[],'true').
'conf_case'('predicates/findall_3/tests.lgt:iso_findall_3_03:46','true'('=='(V0,[])),'findall'(V1,'fail',V0),[],'true').
'conf_case'('predicates/findall_3/tests.lgt:iso_findall_3_04:49','true'('=='(V0,[1|[1|[]]])),'findall'(V1,';'('='(V1,1),'='(V1,1)),V0),[],'true').
'conf_case'('predicates/findall_3/tests.lgt:iso_findall_3_05:52','false','findall'(V0,';'('='(V0,2),'='(V0,1)),[1|[2|[]]]),[],'true').
'conf_case'('predicates/findall_3/tests.lgt:iso_findall_3_06:55','true'('=='('-'(V0,V1),'-'(1,2))),'findall'(V0,';'('='(V0,1),'='(V0,2)),[V0|[V1|[]]]),[],'true').
'conf_case'('predicates/findall_3/tests.lgt:iso_findall_3_07:58','error'('instantiation_error'),'findall'(V0,V1,V2),[],'true').
'conf_case'('predicates/findall_3/tests.lgt:iso_findall_3_08:61','error'('type_error'('callable',4)),','('four'(V0),'findall'(V1,V0,V2)),[],'true').
