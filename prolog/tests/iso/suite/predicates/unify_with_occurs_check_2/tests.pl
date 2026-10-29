% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/unify_with_occurs_check_2/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'conf_case'('predicates/unify_with_occurs_check_2/tests.lgt:iso_unify_with_occurs_check_2_01:34','true','unify_with_occurs_check'(1,1),[],'true').
'conf_case'('predicates/unify_with_occurs_check_2/tests.lgt:iso_unify_with_occurs_check_2_02:37','true'('=='(V0,1)),'unify_with_occurs_check'(V0,1),[],'true').
'conf_case'('predicates/unify_with_occurs_check_2/tests.lgt:iso_unify_with_occurs_check_2_03:40','true'('=='(V0,V1)),'unify_with_occurs_check'(V0,V1),[],'true').
'conf_case'('predicates/unify_with_occurs_check_2/tests.lgt:iso_unify_with_occurs_check_2_04:43','true','unify_with_occurs_check'(V0,V1),[],'true').
'conf_case'('predicates/unify_with_occurs_check_2/tests.lgt:iso_unify_with_occurs_check_2_05:46','true'('=='('-'(V0,V1),'-'('abc','abc'))),','('unify_with_occurs_check'(V0,V1),'unify_with_occurs_check'(V0,'abc')),[],'true').
'conf_case'('predicates/unify_with_occurs_check_2/tests.lgt:iso_unify_with_occurs_check_2_06:49','true'('=='('-'(V0,V1),'-'('def','def'))),'unify_with_occurs_check'('f'(V0,'def'),'f'('def',V1)),[],'true').
'conf_case'('predicates/unify_with_occurs_check_2/tests.lgt:iso_unify_with_occurs_check_2_07:52','false','unify_with_occurs_check'(1,2),[],'true').
'conf_case'('predicates/unify_with_occurs_check_2/tests.lgt:iso_unify_with_occurs_check_2_08:55','false','unify_with_occurs_check'(1,1.0),[],'true').
'conf_case'('predicates/unify_with_occurs_check_2/tests.lgt:iso_unify_with_occurs_check_2_09:58','false','unify_with_occurs_check'('g'(V0),'f'('f'(V0))),[],'true').
'conf_case'('predicates/unify_with_occurs_check_2/tests.lgt:iso_unify_with_occurs_check_2_10:61','false','unify_with_occurs_check'('f'(V0,1),'f'('a'(V0))),[],'true').
'conf_case'('predicates/unify_with_occurs_check_2/tests.lgt:iso_unify_with_occurs_check_2_11:64','false','unify_with_occurs_check'('f'(V0,V1,V0),'f'('a'(V0),'a'(V1),V1,2)),[],'true').
'conf_case'('predicates/unify_with_occurs_check_2/tests.lgt:iso_unify_with_occurs_check_2_12:67','false','unify_with_occurs_check'(V0,'a'(V0)),[],'true').
'conf_case'('predicates/unify_with_occurs_check_2/tests.lgt:iso_unify_with_occurs_check_2_13:70','false','unify_with_occurs_check'('f'(V0,1),'f'('a'(V0),2)),[],'true').
'conf_case'('predicates/unify_with_occurs_check_2/tests.lgt:iso_unify_with_occurs_check_2_14:73','false','unify_with_occurs_check'('f'(1,V0,1),'f'(2,'a'(V0),2)),[],'true').
'conf_case'('predicates/unify_with_occurs_check_2/tests.lgt:iso_unify_with_occurs_check_2_15:76','false','unify_with_occurs_check'('f'(1,V0),'f'(2,'a'(V0))),[],'true').
'conf_case'('predicates/unify_with_occurs_check_2/tests.lgt:iso_unify_with_occurs_check_2_16:79','false','unify_with_occurs_check'('f'(V0,V1,V0,1),'f'('a'(V0),'a'(V1),V1,2)),[],'true').
