% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/functions/round_1/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'variable'(V0).
'foo'(0,'foo').
'foo'(1,'foo'(1)).
'conf_case'('functions/round_1/tests.lgt:iso_round_1_01:34','true'('=='(V0,8)),'is'(V0,'round'(7.5)),[],'true').
'conf_case'('functions/round_1/tests.lgt:iso_round_1_02:37','true'('=='(V0,8)),'is'(V0,'round'(7.6)),[],'true').
'conf_case'('functions/round_1/tests.lgt:iso_round_1_03:40','true'('=='(V0,-1)),'is'(V0,'round'(-0.6)),[],'true').
'conf_case'('functions/round_1/tests.lgt:iso_round_1_04:43','error'('instantiation_error'),','('variable'(V0),'is'(V1,'round'(V0))),[],'true').
