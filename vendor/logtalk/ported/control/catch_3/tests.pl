% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/control/catch_3/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

':-'('foo'(V0),','('is'(V1,'*'(V0,2)),'throw'('test'(V1)))).
':-'('bar'(V0),','('='(V0,V1),'throw'(V1))).
':-'('coo'(V0),'throw'(V0)).
':-'('car'(V0),','('='(V0,1),'throw'(V0))).
':-'('g',','('catch'('p',V0,'write'('h2')),'coo'('c'))).
'p'.
':-'('p','throw'('b')).
':-'('q',','('catch'(';'('true','throw'('err')),V0,'write'(V0)),'fail')).
'r'(1).
':-'('conf_suite_cleanup','conf_clean_text_output').
'one'(1).
'conf_case'('control/catch_3/tests.lgt:iso_catch_3_01:63','true'('=='(V0,10)),'catch'('foo'(5),'test'(V0),'true'),[],'true').
'conf_case'('control/catch_3/tests.lgt:iso_catch_3_02:66','true'('=='(V0,3)),'catch'('bar'(3),V0,'true'),[],'true').
'conf_case'('control/catch_3/tests.lgt:iso_catch_3_03:72','true','catch'('true',V0,3),[],'true').
'conf_case'('control/catch_3/tests.lgt:iso_catch_3_04:75','ball'('bla'),','('catch'('true',V0,'write'('demoen')),'throw'('bla')),[],'true').
'conf_case'('control/catch_3/tests.lgt:iso_catch_3_05:79','true'('=='(V0,1)),'catch'('car'(V1),V0,'true'),[],'true').
'conf_case'('control/catch_3/tests.lgt:iso_catch_3_06:82','fail','catch'('number_chars'(V0,['1'|['a'|['0'|[]]]]),'error'('syntax_error'(V1),V2),'fail'),[],'true').
'conf_case'('control/catch_3/tests.lgt:iso_catch_3_07:85','true'('=='(V0,'c')),','('conf_suppress_text_output',','('catch'('g',V0,'write'('h1')),'nl')),[],'true').
'conf_case'('control/catch_3/tests.lgt:iso_catch_3_08:89','subsumes'('error'('instantiation_error',V0),V1),'catch'('coo'(V2),V1,'true'),[],'true').
