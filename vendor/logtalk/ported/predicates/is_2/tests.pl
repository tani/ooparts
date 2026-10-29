% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/is_2/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

':-'('conf_suite_cleanup','conf_clean_text_input').
'variable'(V0).
'foo'(0,'foo').
'foo'(1,'foo'(1)).
'foo42'('foo42').
'conf_case'('predicates/is_2/tests.lgt:iso_is_2_01:44','true'('=='(V0,42)),'is'(V0,'+'(7,35)),[],'true').
'conf_case'('predicates/is_2/tests.lgt:iso_is_2_02:47','true'('=='(V0,14)),'is'(V0,'+'(0,'+'(3,11))),[],'true').
'conf_case'('predicates/is_2/tests.lgt:iso_is_2_03:50','true'('=='(V0,14.2)),'is'(V0,'+'(0,'+'(3.2,11))),[],'true').
'conf_case'('predicates/is_2/tests.lgt:iso_is_2_04:53','error'('instantiation_error'),','('variable'(V0),'is'(V1,'+'(77,V0))),[],'true').
'conf_case'('predicates/is_2/tests.lgt:iso_is_2_05:58','error'('type_error'('evaluable','/'('foo',0))),','('foo'(0,V0),'is'(V1,'+'(V0,77))),[],'true').
'conf_case'('predicates/is_2/tests.lgt:iso_is_2_06:63','true'('=='(V0,-7)),'is'(V0,'-'(7)),[],'true').
'conf_case'('predicates/is_2/tests.lgt:iso_is_2_07:66','true'('=='(V0,8)),'is'(V0,'-'('-'(3,11))),[],'true').
'conf_case'('predicates/is_2/tests.lgt:iso_is_2_08:69','true'('=='(V0,7.8)),'is'(V0,'-'('-'(3.2,11))),[],'true').
'conf_case'('predicates/is_2/tests.lgt:iso_is_2_09:72','error'('instantiation_error'),','('variable'(V0),'is'(V1,'-'(V0))),[],'true').
'conf_case'('predicates/is_2/tests.lgt:iso_is_2_10:77','error'('type_error'('evaluable','/'('foo',0))),','('foo'(0,V0),'is'(V1,'-'(V0))),[],'true').
'conf_case'('predicates/is_2/tests.lgt:iso_is_2_11:82','true'('=='(V0,-28)),'is'(V0,'-'(7,35)),[],'true').
'conf_case'('predicates/is_2/tests.lgt:iso_is_2_12:85','true'('=='(V0,6)),'is'(V0,'-'(20,'+'(3,11))),[],'true').
'conf_case'('predicates/is_2/tests.lgt:iso_is_2_13:88','true'('=='(V0,-14.2)),'is'(V0,'-'(0,'+'(3.2,11))),[],'true').
'conf_case'('predicates/is_2/tests.lgt:iso_is_2_14:91','error'('instantiation_error'),','('variable'(V0),'is'(V1,'-'(77,V0))),[],'true').
'conf_case'('predicates/is_2/tests.lgt:iso_is_2_15:96','error'('type_error'('evaluable','/'('foo',0))),','('foo'(0,V0),'is'(V1,'-'(V0,77))),[],'true').
'conf_case'('predicates/is_2/tests.lgt:iso_is_2_16:101','true'('=='(V0,245)),'is'(V0,'*'(7,35)),[],'true').
'conf_case'('predicates/is_2/tests.lgt:iso_is_2_17:104','true'('=='(V0,0)),'is'(V0,'*'(0,'+'(3,11))),[],'true').
'conf_case'('predicates/is_2/tests.lgt:iso_is_2_18:107','true'('conf_approximately_equal'(V0,21.3)),'is'(V0,'*'(1.5,'+'(3.2,11))),[],'true').
'conf_case'('predicates/is_2/tests.lgt:iso_is_2_19:110','error'('instantiation_error'),','('variable'(V0),'is'(V1,'*'(77,V0))),[],'true').
'conf_case'('predicates/is_2/tests.lgt:iso_is_2_20:115','error'('type_error'('evaluable','/'('foo',0))),','('foo'(0,V0),'is'(V1,'*'(V0,77))),[],'true').
'conf_case'('predicates/is_2/tests.lgt:iso_is_2_21:120','true'('=='(V0,0)),'is'(V0,'//'(7,35)),[],'true').
'conf_case'('predicates/is_2/tests.lgt:iso_is_2_22:124','true'('=='(V0,0.2)),'is'(V0,'/'(7.0,35)),[],'true').
'conf_case'('predicates/is_2/tests.lgt:iso_is_2_23:127','true'('=='(V0,10)),'is'(V0,'//'(140,'+'(3,11))),[],'true').
'conf_case'('predicates/is_2/tests.lgt:iso_is_2_24:131','true'('conf_approximately_equal'(V0,1.42)),'is'(V0,'/'(20.164,'+'(3.2,11))),[],'true').
'conf_case'('predicates/is_2/tests.lgt:iso_is_2_25:135','true'(';'('=='(V0,-2),'=='(V0,-3))),'is'(V0,'//'(7,-3)),[],'true').
'conf_case'('predicates/is_2/tests.lgt:iso_is_2_26:138','true'(';'('=='(V0,-2),'=='(V0,-3))),'is'(V0,'//'(-7,3)),[],'true').
'conf_case'('predicates/is_2/tests.lgt:iso_is_2_27:141','error'('instantiation_error'),','('variable'(V0),'is'(V1,'/'(77,V0))),[],'true').
'conf_case'('predicates/is_2/tests.lgt:iso_is_2_28:146','error'('type_error'('evaluable','/'('foo',0))),','('foo'(0,V0),'is'(V1,'/'(V0,77))),[],'true').
'conf_case'('predicates/is_2/tests.lgt:iso_is_2_29:151','error'('type_error'('evaluable','/'('foo',1))),','('foo'(1,V0),'is'(V1,'/'(77,V0))),[],'true').
'conf_case'('predicates/is_2/tests.lgt:iso_is_2_30:156','error'('evaluation_error'('zero_divisor')),','('='(V0,'is'(V1,'/'(3,0))),'call'(V0)),[],'true').
'conf_case'('predicates/is_2/tests.lgt:iso_is_2_31:160','error'('evaluation_error'('int_overflow')),','('current_prolog_flag'('max_integer',V0),'is'(V1,'+'(V0,1))),['condition'('current_prolog_flag'('bounded','true'))|[]],'true').
'conf_case'('predicates/is_2/tests.lgt:iso_is_2_32:163','error'('evaluation_error'('int_overflow')),','('current_prolog_flag'('max_integer',V0),'is'(V1,'-'('+'(V0,1),1))),['condition'('current_prolog_flag'('bounded','true'))|[]],'true').
'conf_case'('predicates/is_2/tests.lgt:iso_is_2_33:166','error'('evaluation_error'('int_overflow')),','('current_prolog_flag'('max_integer',V0),'is'(V1,'-'(-2,V0))),['condition'('current_prolog_flag'('bounded','true'))|[]],'true').
'conf_case'('predicates/is_2/tests.lgt:iso_is_2_34:170','error'('evaluation_error'('int_overflow')),','('current_prolog_flag'('max_integer',V0),'is'(V1,'*'(V0,2))),['condition'('current_prolog_flag'('bounded','true'))|[]],'true').
'conf_case'('predicates/is_2/tests.lgt:iso_is_2_35:173','error'('evaluation_error'('int_overflow')),','('current_prolog_flag'('max_integer',V0),','('is'(V1,'*'('float'(V0),2)),'is'(V2,'floor'(V1)))),['condition'('current_prolog_flag'('bounded','true'))|[]],'true').
