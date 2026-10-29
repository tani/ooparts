% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/univ_2/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'list_of'(0,V0,[]).
':-'('list_of'(V0,V1,[V1|V2]),','('>'(V0,0),','('is'(V3,'-'(V0,1)),'list_of'(V3,V1,V2)))).
'conf_case'('predicates/univ_2/tests.lgt:iso_univ_2_01:34','true','=..'('foo'('a','b'),['foo'|['a'|['b'|[]]]]),[],'true').
'conf_case'('predicates/univ_2/tests.lgt:iso_univ_2_02:37','true'('=='(V0,'foo'('a','b'))),'=..'(V0,['foo'|['a'|['b'|[]]]]),[],'true').
'conf_case'('predicates/univ_2/tests.lgt:iso_univ_2_03:40','true'('=='(V0,['foo'|['a'|['b'|[]]]])),'=..'('foo'('a','b'),V0),[],'true').
'conf_case'('predicates/univ_2/tests.lgt:iso_univ_2_04:43','true'(','('=='(V0,'a'),'=='(V1,'b'))),'=..'('foo'(V0,'b'),['foo'|['a'|[V1|[]]]]),[],'true').
'conf_case'('predicates/univ_2/tests.lgt:iso_univ_2_05:46','true','=..'(1,[1|[]]),[],'true').
'conf_case'('predicates/univ_2/tests.lgt:iso_univ_2_06:49','fail','=..'('foo'('a','b'),['foo'|['b'|['a'|[]]]]),[],'true').
'conf_case'('predicates/univ_2/tests.lgt:iso_univ_2_07:52','error'('instantiation_error'),'=..'(V0,V1),[],'true').
'conf_case'('predicates/univ_2/tests.lgt:iso_univ_2_08:55','error'('instantiation_error'),'=..'(V0,['foo'|['a'|V1]]),[],'true').
'conf_case'('predicates/univ_2/tests.lgt:iso_univ_2_09:58','error'('type_error'('list',['foo'|'bar'])),'=..'(V0,['foo'|'bar']),[],'true').
'conf_case'('predicates/univ_2/tests.lgt:iso_univ_2_10:61','error'('instantiation_error'),'=..'(V0,[V1|['bar'|[]]]),[],'true').
'conf_case'('predicates/univ_2/tests.lgt:iso_univ_2_11:64','error'('type_error'('atom',3)),'=..'(V0,[3|[1|[]]]),[],'true').
'conf_case'('predicates/univ_2/tests.lgt:iso_univ_2_12:67','error'('type_error'('atom',1.1)),'=..'(V0,[1.1|['foo'|[]]]),[],'true').
'conf_case'('predicates/univ_2/tests.lgt:iso_univ_2_13:70','error'('type_error'('atom','a'('b'))),'=..'(V0,['a'('b')|[1|[]]]),[],'true').
'conf_case'('predicates/univ_2/tests.lgt:iso_univ_2_14:73','error'('type_error'('list',4)),'=..'(V0,4),[],'true').
'conf_case'('predicates/univ_2/tests.lgt:iso_univ_2_15:82','true','=..'('f'(V0),['f'|['u'(V0)|[]]]),[],','(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse')))),'true')).
'conf_case'('predicates/univ_2/tests.lgt:iso_univ_2_15:87','true','=..'('f'(V0),['f'|['u'(V0)|[]]]),['note'('STO')|[]],','('\\+'(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse'))))),'true')).
