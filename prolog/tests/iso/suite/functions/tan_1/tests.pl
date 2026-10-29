% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/functions/tan_1/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'variable'(V0).
'foo'(0,'foo').
'foo'(1,'foo'(1)).
'foo'(2,'foo'(1,2)).
'conf_case'('functions/tan_1/tests.lgt:iso_tan_1_01:38','true'('conf_approximately_equal'(V0,0.5463)),'is'(V0,'tan'(0.5)),[],'true').
