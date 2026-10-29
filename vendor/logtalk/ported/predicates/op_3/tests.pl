% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/op_3/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'o'(1).
'o'(2).
'o'(3).
':-'('conf_suite_cleanup','conf_clean_text_input').
'conf_case'('predicates/op_3/tests.lgt:iso_op_3_01:41','true',','('op'(30,'xfy','++'),','('current_op'(30,'xfy','++'),'op'(0,'xfy','++'))),[],'true').
'conf_case'('predicates/op_3/tests.lgt:iso_op_3_02:45','true',','(','('op'(30,'xfy','++'),'op'(0,'xfy','++')),'\\+'('current_op'(V0,'xfy','++'))),[],'true').
'conf_case'('predicates/op_3/tests.lgt:iso_op_3_03:49','error'('type_error'('integer','max')),'op'('max','xfy','++'),[],'true').
'conf_case'('predicates/op_3/tests.lgt:iso_op_3_04:52','error'('domain_error'('operator_priority',-30)),'op'(-30,'xfy','++'),[],'true').
'conf_case'('predicates/op_3/tests.lgt:iso_op_3_05:55','error'('domain_error'('operator_priority',1201)),'op'(1201,'xfy','++'),[],'true').
'conf_case'('predicates/op_3/tests.lgt:iso_op_3_06:58','error'('instantiation_error'),'op'(30,V0,'++'),[],'true').
'conf_case'('predicates/op_3/tests.lgt:iso_op_3_07:61','error'('domain_error'('operator_specifier','yfy')),'op'(30,'yfy','++'),[],'true').
'conf_case'('predicates/op_3/tests.lgt:iso_op_3_08:64','error'('type_error'('list',0)),'op'(30,'xfy',0),[],'true').
'conf_case'('predicates/op_3/tests.lgt:iso_op_3_09:67','true',','(','('op'(30,'xfy','++'),'op'(40,'xfx','++')),','('current_op'(40,'xfx','++'),'op'(0,'xfx','++'))),[],'true').
'conf_case'('predicates/op_3/tests.lgt:iso_op_3_10:76','true','true',[],','(','('conf_profile'('prolog_dialect',V0),';'('=='(V0,'eclipse'),';'('=='(V0,'sicstus'),';'('=='(V0,'swi'),';'('=='(V0,'trealla'),';'('=='(V0,'yap'),'=='(V0,'xvm'))))))),'true')).
'conf_case'('predicates/op_3/tests.lgt:iso_op_3_10:79','error'('permission_error'('create','operator','++')),','('op'(30,'xfy','++'),'op'(50,'yf','++')),[],','('\\+'(','('conf_profile'('prolog_dialect',V0),';'('=='(V0,'eclipse'),';'('=='(V0,'sicstus'),';'('=='(V0,'swi'),';'('=='(V0,'trealla'),';'('=='(V0,'yap'),'=='(V0,'xvm')))))))),'true')).
'conf_case'('predicates/op_3/tests.lgt:iso_op_3_11:85','error'('permission_error'('create','operator',[])),'op'(500,'xfy',[]),[],'true').
'conf_case'('predicates/op_3/tests.lgt:iso_op_3_12:88','error'('permission_error'('create','operator',[])),'op'(500,'xfy',[[]|[]]),[],'true').
'conf_case'('predicates/op_3/tests.lgt:iso_op_3_13:91','error'('permission_error'('create','operator','{}')),'op'(500,'xfy','{}'),[],'true').
'conf_case'('predicates/op_3/tests.lgt:iso_op_3_14:94','error'('permission_error'('create','operator','{}')),'op'(500,'xfy',['{}'|[]]),[],'true').
'conf_case'('predicates/op_3/tests.lgt:iso_op_3_15:97','error'('permission_error'('create','operator','|')),'op'(1000,'xfy','|'),[],'true').
'conf_case'('predicates/op_3/tests.lgt:iso_op_3_16:100','error'('permission_error'('create','operator','|')),'op'(1000,'xfy',['|'|[]]),[],'true').
'conf_case'('predicates/op_3/tests.lgt:iso_op_3_17:103','error'('permission_error'('create','operator','|')),'op'(1000,'fx','|'),[],'true').
'conf_case'('predicates/op_3/tests.lgt:iso_op_3_18:108','true',','('op'(333,'xfy',['abc'|['abc'|['abc'|[]]]]),'current_op'(333,'xfy','abc')),[],'true').
'conf_case'('predicates/op_3/tests.lgt:iso_op_3_19:112','error'('permission_error'('modify','operator',',')),'op'(0,'xfx',','),[],'true').
'conf_case'('predicates/op_3/tests.lgt:iso_op_3_20:127','true'(V0),','('conf_set_text_output'(''),';'(','('op'(555,'fx','o'),','('o'(V1),','('write'('o'(V1)),','('nl',','('op'(555,'xf','o'),'fail'))))),'conf_text_output_assertion'('o 1\r\no 2\r\no 3\r\n',V0))),[],','(','('conf_dispatch'('os','operating_system_type'('windows')),','('\\+'('conf_profile'('prolog_dialect','b')),','('\\+'('conf_profile'('prolog_dialect','gnu')),','('\\+'('conf_profile'('prolog_dialect','ji')),','('\\+'('conf_profile'('prolog_dialect','sicstus')),','('\\+'('conf_profile'('prolog_dialect','swi')),'\\+'('conf_profile'('prolog_dialect','xsb')))))))),'true')).
'conf_case'('predicates/op_3/tests.lgt:iso_op_3_20:140','true'(V0),','('conf_set_text_output'(''),';'(','('op'(555,'fx','o'),','('o'(V1),','('write'('o'(V1)),','('nl',','('op'(555,'xf','o'),'fail'))))),'conf_text_output_assertion'('o 1\no 2\no 3\n',V0))),[],','('\\+'(','('conf_dispatch'('os','operating_system_type'('windows')),','('\\+'('conf_profile'('prolog_dialect','b')),','('\\+'('conf_profile'('prolog_dialect','gnu')),','('\\+'('conf_profile'('prolog_dialect','ji')),','('\\+'('conf_profile'('prolog_dialect','sicstus')),','('\\+'('conf_profile'('prolog_dialect','swi')),'\\+'('conf_profile'('prolog_dialect','xsb'))))))))),'true')).
'conf_case'('predicates/op_3/tests.lgt:iso_op_3_21:157','true',','('op'(1105,'xfy','|'),','('current_op'(V0,V1,'|'),','('=='(V0,1105),'=='(V1,'xfy')))),[],','('\\+'('current_op'(V2,V3,'|')),'true')).
'conf_case'('predicates/op_3/tests.lgt:iso_op_3_21:165','true',','('current_op'(V0,V1,'|'),','('>='(V0,1001),';'('=='(V1,'xfy'),';'('=='(V1,'xfx'),'=='(V1,'yfx'))))),[],','('\\+'('\\+'('current_op'(V2,V3,'|'))),'true')).
'conf_case'('predicates/op_3/tests.lgt:iso_op_3_22:175','true',','('op'(0,'xfy','|'),'\\+'('current_op'(V0,'xfy','|'))),[],'true').
