% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/control/if_then_else_3/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'three'(3).
'conf_case'('control/if_then_else_3/tests.lgt:iso_if_then_else_3_01:34','true',';'('->'('true','true'),'fail'),[],'true').
'conf_case'('control/if_then_else_3/tests.lgt:iso_if_then_else_3_02:37','true',';'('->'('fail','true'),'true'),[],'true').
'conf_case'('control/if_then_else_3/tests.lgt:iso_if_then_else_3_03:40','false',';'('->'('true','fail'),'fail'),[],'true').
'conf_case'('control/if_then_else_3/tests.lgt:iso_if_then_else_3_04:43','false',';'('->'('fail','true'),'fail'),[],'true').
'conf_case'('control/if_then_else_3/tests.lgt:iso_if_then_else_3_05:46','true'('=='(V0,1)),';'('->'('true','='(V0,1)),'='(V0,2)),[],'true').
'conf_case'('control/if_then_else_3/tests.lgt:iso_if_then_else_3_06:49','true'('=='(V0,2)),';'('->'('fail','='(V0,1)),'='(V0,2)),[],'true').
'conf_case'('control/if_then_else_3/tests.lgt:iso_if_then_else_3_07:52','true'('=='(V0,[1|[2|[]]])),'findall'(V1,';'('->'('true',';'('='(V1,1),'='(V1,2))),'true'),V0),[],'true').
'conf_case'('control/if_then_else_3/tests.lgt:iso_if_then_else_3_08:55','true'('=='(V0,1)),';'('->'(';'('='(V0,1),'='(V0,2)),'true'),'true'),[],'true').
'conf_case'('control/if_then_else_3/tests.lgt:iso_if_then_else_3_09:58','true',';'(','('->'('!','fail'),'true'),'true'),[],'true').
