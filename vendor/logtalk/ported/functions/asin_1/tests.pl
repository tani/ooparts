% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/functions/asin_1/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'variable'(V0).
'foo'(0,'foo').
'foo'(1,'foo'(1)).
'foo'(2,'foo'(1,2)).
'conf_case'('functions/asin_1/tests.lgt:iso_asin_1_01:38','true'('conf_approximately_equal'(V0,0.5235988)),'is'(V0,'asin'(0.5)),[],'true').
'conf_case'('functions/asin_1/tests.lgt:iso_asin_1_02:41','true'('conf_approximately_equal'(V0,3.1415927)),'is'(V0,'*'(2,'asin'(1))),[],'true').
'conf_case'('functions/asin_1/tests.lgt:iso_asin_1_03:44','error'('evaluation_error'('undefined')),'is'(V0,'asin'(2)),[],'true').
