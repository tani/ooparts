% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/term_comparison/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'conf_case'('predicates/term_comparison/tests.lgt:iso_term_comparison_01:34','true','@=<'(1.0,1),[],'true').
'conf_case'('predicates/term_comparison/tests.lgt:iso_term_comparison_02:37','true','@<'(1.0,1),[],'true').
'conf_case'('predicates/term_comparison/tests.lgt:iso_term_comparison_03:40','false','\\=='(1,1),[],'true').
'conf_case'('predicates/term_comparison/tests.lgt:iso_term_comparison_04:43','true','@=<'('aardvark','zebra'),[],'true').
'conf_case'('predicates/term_comparison/tests.lgt:iso_term_comparison_05:46','true','@=<'('short','short'),[],'true').
'conf_case'('predicates/term_comparison/tests.lgt:iso_term_comparison_06:49','true','@=<'('short','shorter'),[],'true').
'conf_case'('predicates/term_comparison/tests.lgt:iso_term_comparison_07:52','false','@>='('short','shorter'),[],'true').
'conf_case'('predicates/term_comparison/tests.lgt:iso_term_comparison_08:55','false','@<'('foo'('a','b'),'north'('a')),[],'true').
'conf_case'('predicates/term_comparison/tests.lgt:iso_term_comparison_09:58','true','@>'('foo'('b'),'foo'('a')),[],'true').
'conf_case'('predicates/term_comparison/tests.lgt:iso_term_comparison_10:61','true','@<'('foo'('a',V0),'foo'('b',V1)),[],'true').
'conf_case'('predicates/term_comparison/tests.lgt:iso_term_comparison_11:64','true',';'('->'('@<'('foo'(V0,'a'),'foo'(V1,'b')),'true'),'true'),[],'true').
'conf_case'('predicates/term_comparison/tests.lgt:iso_term_comparison_12:70','true','@=<'(V0,V0),[],'true').
'conf_case'('predicates/term_comparison/tests.lgt:iso_term_comparison_13:73','true','=='(V0,V0),[],'true').
'conf_case'('predicates/term_comparison/tests.lgt:iso_term_comparison_14:76','true',';'('->'('@=<'(V0,V1),'true'),'true'),[],'true').
'conf_case'('predicates/term_comparison/tests.lgt:iso_term_comparison_15:82','false','=='(V0,V1),[],'true').
'conf_case'('predicates/term_comparison/tests.lgt:iso_term_comparison_16:85','true','\\=='(V0,V1),[],'true').
'conf_case'('predicates/term_comparison/tests.lgt:iso_term_comparison_17:88','false','=='(V0,V1),[],'true').
'conf_case'('predicates/term_comparison/tests.lgt:iso_term_comparison_18:91','true',';'('->'('@=<'(V0,V1),'true'),'true'),[],'true').
'conf_case'('predicates/term_comparison/tests.lgt:iso_term_comparison_19:97','true',';'('->'('@=<'('foo'(V0,'a'),'foo'(V1,'b')),'true'),'true'),[],'true').
