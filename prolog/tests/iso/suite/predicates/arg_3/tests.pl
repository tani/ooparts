% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/arg_3/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'conf_case'('predicates/arg_3/tests.lgt:iso_arg_3_01:34','true','arg'(1,'foo'('a','b'),'a'),[],'true').
'conf_case'('predicates/arg_3/tests.lgt:iso_arg_3_02:37','true'('=='(V0,'a')),'arg'(1,'foo'('a','b'),V0),[],'true').
'conf_case'('predicates/arg_3/tests.lgt:iso_arg_3_03:40','true'('=='(V0,'a')),'arg'(1,'foo'(V0,'b'),'a'),[],'true').
'conf_case'('predicates/arg_3/tests.lgt:iso_arg_3_04:43','true'('=='(V0,V1)),'arg'(1,'foo'(V1,'b'),V0),[],'true').
'conf_case'('predicates/arg_3/tests.lgt:iso_arg_3_05:46','false','arg'(1,'foo'('a','b'),'b'),[],'true').
'conf_case'('predicates/arg_3/tests.lgt:iso_arg_3_06:49','false','arg'(0,'foo'('a','b'),'foo'),[],'true').
'conf_case'('predicates/arg_3/tests.lgt:iso_arg_3_07:52','false','arg'(3,'foo'(3,4),V0),[],'true').
'conf_case'('predicates/arg_3/tests.lgt:iso_arg_3_08:55','error'('instantiation_error'),','('='(V0,'arg'(V1,'foo'('a','b'),'a')),'call'(V0)),[],'true').
'conf_case'('predicates/arg_3/tests.lgt:iso_arg_3_09:59','error'('instantiation_error'),','('='(V0,'arg'(1,V1,'a')),'call'(V0)),[],'true').
'conf_case'('predicates/arg_3/tests.lgt:iso_arg_3_10:63','error'('type_error'('compound','atom')),','('='(V0,'arg'(0,'atom',V1)),'call'(V0)),[],'true').
'conf_case'('predicates/arg_3/tests.lgt:iso_arg_3_11:67','error'('type_error'('compound',3)),','('='(V0,'arg'(0,3,V1)),'call'(V0)),[],'true').
'conf_case'('predicates/arg_3/tests.lgt:iso_arg_3_12:77','true','arg'(1,'foo'(V0),'u'(V0)),[],','(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse')))),'true')).
'conf_case'('predicates/arg_3/tests.lgt:iso_arg_3_12:82','true','arg'(1,'foo'(V0),'u'(V0)),['note'('STO')|[]],','('\\+'(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse'))))),'true')).
