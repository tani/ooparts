% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/control/disjunction_2/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

':-'('discontiguous'('/'('succeeds',1))).
':-'('discontiguous'('/'('fails',1))).
'three'(3).
'conf_case'('control/disjunction_2/tests.lgt:iso_disjunction_2_01:38','true',';'('true','fail'),[],'true').
'conf_case'('control/disjunction_2/tests.lgt:iso_disjunction_2_02:41','false',';'(','('!','fail'),'true'),[],'true').
'conf_case'('control/disjunction_2/tests.lgt:iso_disjunction_2_03:44','true',','('three'(V0),';'('!','call'(V0))),[],'true').
'conf_case'('control/disjunction_2/tests.lgt:iso_disjunction_2_04:49','true'('=='(V0,1)),';'(','('='(V0,1),'!'),'='(V0,2)),[],'true').
'conf_case'('control/disjunction_2/tests.lgt:iso_disjunction_2_05:52','true'('=='(V0,[1|[2|[]]])),'findall'(V1,';'('='(V1,1),'='(V1,2)),V0),[],'true').
