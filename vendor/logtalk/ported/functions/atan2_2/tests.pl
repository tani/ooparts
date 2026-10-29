% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/functions/atan2_2/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'variable'(V0).
'foo'(0,'foo').
'foo'(1,'foo'(1)).
'foo'(2,'foo'(1,2)).
'conf_case'('functions/atan2_2/tests.lgt:iso_atan2_2_01:38','true'('conf_approximately_equal'(V0,1.5707963)),'is'(V0,'atan2'(1,0)),[],'true').
'conf_case'('functions/atan2_2/tests.lgt:iso_atan2_2_02:41','true'('conf_approximately_equal'(V0,3.1415927)),'is'(V0,'atan2'(0,-1)),[],'true').
'conf_case'('functions/atan2_2/tests.lgt:iso_atan2_2_03:44','error'('evaluation_error'('undefined')),'is'(V0,'atan2'(0,0)),[],'true').
