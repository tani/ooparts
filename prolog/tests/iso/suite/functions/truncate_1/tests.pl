% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/functions/truncate_1/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'variable'(V0).
'foo'(0,'foo').
'foo'(1,'foo'(1)).
'conf_case'('functions/truncate_1/tests.lgt:iso_truncate_1_01:34','true'('=='(V0,0)),'is'(V0,'truncate'(-0.5)),[],'true').
'conf_case'('functions/truncate_1/tests.lgt:iso_truncate_1_02:37','error'('type_error'('evaluable','/'('foo',0))),','('foo'(0,V0),'is'(V1,'truncate'(V0))),[],'true').
