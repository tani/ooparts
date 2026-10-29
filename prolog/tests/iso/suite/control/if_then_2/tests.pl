% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/control/if_then_2/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'three'(3).
'conf_case'('control/if_then_2/tests.lgt:iso_if_then_2_01:34','true','->'('true','true'),[],'true').
'conf_case'('control/if_then_2/tests.lgt:iso_if_then_2_02:37','false','->'('true','fail'),[],'true').
'conf_case'('control/if_then_2/tests.lgt:iso_if_then_2_03:40','false','->'('fail','true'),[],'true').
'conf_case'('control/if_then_2/tests.lgt:iso_if_then_2_04:43','true'('=='(V0,1)),'->'('true','='(V0,1)),[],'true').
'conf_case'('control/if_then_2/tests.lgt:iso_if_then_2_05:46','true'('=='(V0,1)),'->'(';'('='(V0,1),'='(V0,2)),'true'),[],'true').
'conf_case'('control/if_then_2/tests.lgt:iso_if_then_2_06:49','true'('=='(V0,[1|[2|[]]])),'findall'(V1,'->'('true',';'('='(V1,1),'='(V1,2))),V0),[],'true').
