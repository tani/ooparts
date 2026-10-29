% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/subsumes_term_2/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'conf_case'('predicates/subsumes_term_2/tests.lgt:iso_subsumes_term_2_01:34','true','conf_subsumes'('a','a'),[],'true').
'conf_case'('predicates/subsumes_term_2/tests.lgt:iso_subsumes_term_2_02:37','true','conf_subsumes'('f'(V0,V1),'f'(V2,V2)),[],'true').
'conf_case'('predicates/subsumes_term_2/tests.lgt:iso_subsumes_term_2_03:40','false','conf_subsumes'('f'(V0,V0),'f'(V1,V2)),[],'true').
'conf_case'('predicates/subsumes_term_2/tests.lgt:iso_subsumes_term_2_04:43','false','conf_subsumes'('g'(V0),'g'('f'(V0))),[],'true').
'conf_case'('predicates/subsumes_term_2/tests.lgt:iso_subsumes_term_2_05:46','false','conf_subsumes'(V0,'f'(V0)),[],'true').
'conf_case'('predicates/subsumes_term_2/tests.lgt:iso_subsumes_term_2_06:49','true',','('conf_subsumes'(V0,V1),'conf_subsumes'(V1,'f'(V0))),[],'true').
