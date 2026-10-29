% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/functions/floor_1/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'variable'(V0).
'foo'(0,'foo').
'foo'(1,'foo'(1)).
'conf_case'('functions/floor_1/tests.lgt:iso_floor_1_01:34','true'('=='(V0,7)),'is'(V0,'floor'(7.4)),[],'true').
'conf_case'('functions/floor_1/tests.lgt:iso_floor_1_02:37','true'('=='(V0,-1)),'is'(V0,'floor'(-0.4)),[],'true').
