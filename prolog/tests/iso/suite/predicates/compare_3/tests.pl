% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/compare_3/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'conf_case'('predicates/compare_3/tests.lgt:iso_compare_3_01:34','true'('=='(V0,'<')),'compare'(V0,3,5),[],'true').
'conf_case'('predicates/compare_3/tests.lgt:iso_compare_3_02:37','true'('=='(V0,'=')),'compare'(V0,'d','d'),[],'true').
'conf_case'('predicates/compare_3/tests.lgt:iso_compare_3_03:40','true'('=='(V0,'<')),'compare'(V0,V0,'<'),[],'true').
'conf_case'('predicates/compare_3/tests.lgt:iso_compare_3_04:43','false','compare'('<','<','<'),[],'true').
'conf_case'('predicates/compare_3/tests.lgt:iso_compare_3_05:46','error'('type_error'('atom','+'(1,2))),'compare'('+'(1,2),3,3.0),[],'true').
'conf_case'('predicates/compare_3/tests.lgt:iso_compare_3_06:49','error'('domain_error'('order','>=')),'compare'('>=',3,3.0),[],'true').
