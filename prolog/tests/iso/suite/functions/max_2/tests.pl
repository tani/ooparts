% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/functions/max_2/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'variable'(V0).
'foo'(0,'foo').
'foo'(1,'foo'(1)).
'foo'(2,'foo'(1,2)).
'conf_case'('functions/max_2/tests.lgt:iso_max_2_01:37','true'('=='(V0,3)),'is'(V0,'max'(2,3)),[],'true').
'conf_case'('functions/max_2/tests.lgt:iso_max_2_02:40','true','catch'(','('is'(V0,'max'(2.0,3)),';'('=='(V0,3),'=='(V0,3.0))),V1,'='(V1,'error'('evaluation_error'('undefined'),V2))),[],'true').
'conf_case'('functions/max_2/tests.lgt:iso_max_2_03:47','true','catch'(','('is'(V0,'max'(2,3.0)),'=='(V0,3.0)),V1,'='(V1,'error'('evaluation_error'('undefined'),V2))),[],'true').
'conf_case'('functions/max_2/tests.lgt:iso_max_2_04:54','true','catch'(','('is'(V0,'max'(0,0.0)),';'('=='(V0,0),'=='(V0,0.0))),V1,'='(V1,'error'('evaluation_error'('undefined'),V2))),[],'true').
