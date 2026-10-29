% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/functions/bitwise_complement_1/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'variable'(V0).
'foo'(0,'foo').
'foo'(1,'foo'(1)).
'foo'(2,'foo'(1,2)).
'conf_case'('functions/bitwise_complement_1/tests.lgt:iso_bitwise_complement_1_01:34','true'('=='(V0,10)),'is'(V0,'\\'('\\'(10))),[],'true').
'conf_case'('functions/bitwise_complement_1/tests.lgt:iso_bitwise_complement_1_02:37','true'('=='(V0,10)),'is'(V0,'\\'('\\'(10))),[],'true').
'conf_case'('functions/bitwise_complement_1/tests.lgt:iso_bitwise_complement_1_03:40','true'('=='(V0,-11)),'is'(V0,'\\'(10)),['note'('Implementation defined result')|[]],'true').
'conf_case'('functions/bitwise_complement_1/tests.lgt:iso_bitwise_complement_1_04:44','error'('instantiation_error'),','('variable'(V0),'is'(V1,'\\'(V0))),[],'true').
