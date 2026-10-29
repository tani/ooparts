% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/functor_3/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'conf_case'('predicates/functor_3/tests.lgt:iso_functor_3_01:38','true','functor'('foo'('a','b','c'),'foo',3),[],'true').
'conf_case'('predicates/functor_3/tests.lgt:iso_functor_3_02:41','true'('=='('-'(V0,V1),'-'('foo',3))),'functor'('foo'('a','b','c'),V0,V1),[],'true').
'conf_case'('predicates/functor_3/tests.lgt:iso_functor_3_03:44','variant'(V0,'foo'(V1,V2,V3)),'functor'(V0,'foo',3),[],'true').
'conf_case'('predicates/functor_3/tests.lgt:iso_functor_3_04:47','true'('=='(V0,'foo')),'functor'(V0,'foo',0),[],'true').
'conf_case'('predicates/functor_3/tests.lgt:iso_functor_3_05:50','true'('=='('-'(V0,V1),'-'('mats',2))),'functor'('mats'(V0,V1),V0,V1),[],'true').
'conf_case'('predicates/functor_3/tests.lgt:iso_functor_3_06:53','false','functor'('foo'('a'),'foo',2),[],'true').
'conf_case'('predicates/functor_3/tests.lgt:iso_functor_3_07:56','false','functor'('foo'('a'),'fo',1),[],'true').
'conf_case'('predicates/functor_3/tests.lgt:iso_functor_3_08:59','true'('=='('-'(V0,V1),'-'(1,0))),'functor'(1,V0,V1),[],'true').
'conf_case'('predicates/functor_3/tests.lgt:iso_functor_3_09:62','true'('=='(V0,1.1)),'functor'(V0,1.1,0),[],'true').
'conf_case'('predicates/functor_3/tests.lgt:iso_functor_3_10:65','true','functor'([V0|V1],'.',2),[],'true').
'conf_case'('predicates/functor_3/tests.lgt:iso_functor_3_11:68','true','functor'([],[],0),[],'true').
'conf_case'('predicates/functor_3/tests.lgt:iso_functor_3_12:73','error'('instantiation_error'),','('='(V0,'functor'(V1,V2,3)),'call'(V0)),[],'true').
'conf_case'('predicates/functor_3/tests.lgt:iso_functor_3_13:76','error'('instantiation_error'),','('='(V0,'functor'(V1,'foo',V2)),'call'(V0)),[],'true').
'conf_case'('predicates/functor_3/tests.lgt:iso_functor_3_14:79','error'('type_error'('integer','a')),','('='(V0,'functor'(V1,'foo','a')),'call'(V0)),[],'true').
'conf_case'('predicates/functor_3/tests.lgt:iso_functor_3_15:82','error'('type_error'('atom',1.5)),','('='(V0,'functor'(V1,1.5,1)),'call'(V0)),[],'true').
'conf_case'('predicates/functor_3/tests.lgt:iso_functor_3_16:85','error'('type_error'('atomic','foo'('a'))),','('='(V0,'functor'(V1,'foo'('a'),1)),'call'(V0)),[],'true').
'conf_case'('predicates/functor_3/tests.lgt:iso_functor_3_17:88','error'('representation_error'('max_arity')),','('current_prolog_flag'('max_arity',V0),','('is'(V1,'+'(V0,1)),'functor'(V2,'foo',V1))),['condition'('\\+'('current_prolog_flag'('max_arity','unbounded')))|[]],'true').
'conf_case'('predicates/functor_3/tests.lgt:iso_functor_3_18:91','error'('domain_error'('not_less_than_zero',-1)),','('='(V0,'functor'(V1,'foo',-1)),'call'(V0)),[],'true').
