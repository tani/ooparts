% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/functions/xor_2/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'variable'(V0).
'foo'(0,'foo').
'foo'(1,'foo'(1)).
'foo'(2,'foo'(1,2)).
'conf_case'('functions/xor_2/tests.lgt:iso_xor_2_01:34','true'('=='(V0,6)),'is'(V0,'xor'(10,12)),[],'true').
'conf_case'('functions/xor_2/tests.lgt:iso_xor_2_02:37','true'('=='(V0,130)),'is'(V0,'xor'(125,255)),[],'true').
'conf_case'('functions/xor_2/tests.lgt:iso_xor_2_03:40','true'('=='(V0,-6)),'is'(V0,'xor'(-10,12)),['note'('Implementation defined result')|[]],'true').
