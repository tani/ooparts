% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/functions/bitwise_left_shift_2/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'variable'(V0).
'foo'(0,'foo').
'foo'(1,'foo'(1)).
'foo'(2,'foo'(1,2)).
'conf_case'('functions/bitwise_left_shift_2/tests.lgt:iso_bitwise_left_shift_2_01:34','true'('=='(V0,64)),'is'(V0,'<<'(16,2)),[],'true').
'conf_case'('functions/bitwise_left_shift_2/tests.lgt:iso_bitwise_left_shift_2_02:37','true'('=='(V0,76)),'is'(V0,'<<'(19,2)),[],'true').
'conf_case'('functions/bitwise_left_shift_2/tests.lgt:iso_bitwise_left_shift_2_03:40','true'('=='(V0,-64)),'is'(V0,'<<'(-16,2)),['note'('Implementation defined result')|[]],'true').
'conf_case'('functions/bitwise_left_shift_2/tests.lgt:iso_bitwise_left_shift_1_04:44','error'('instantiation_error'),','('variable'(V0),'is'(V1,'<<'(77,V0))),[],'true').
'conf_case'('functions/bitwise_left_shift_2/tests.lgt:iso_bitwise_left_shift_2_05:49','error'('type_error'('evaluable','/'('foo',0))),','('foo'(0,V0),'is'(V1,'<<'(V0,2))),[],'true').
'conf_case'('functions/bitwise_left_shift_2/tests.lgt:iso_bitwise_left_shift_2_06:55','error'('type_error'('integer',1.0)),'is'(V0,'<<'(1.0,2)),[],'true').
