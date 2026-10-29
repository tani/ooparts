% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/abolish_1/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

':-'('dynamic'('/'('insect',1))).
'insect'('ant').
'insect'('bee').
':-'('dynamic'('/'('foo',1))).
':-'('foo'(V0),','('call'(V0),'call'(V0))).
':-'('foo'(V0),'->'('call'(V0),'call'(V0))).
':-'('bar'(V0),'true').
'conf_case'('predicates/abolish_1/tests.lgt:iso_abolish_1_01:47','true','abolish'('/'('foo',2)),[],'true').
'conf_case'('predicates/abolish_1/tests.lgt:iso_abolish_1_02:50','error'('instantiation_error'),'abolish'('/'('foo',V0)),[],'true').
'conf_case'('predicates/abolish_1/tests.lgt:iso_abolish_1_03:53','error'('type_error'('predicate_indicator','foo')),'abolish'('foo'),[],'true').
'conf_case'('predicates/abolish_1/tests.lgt:iso_abolish_1_04:57','error'('type_error'('predicate_indicator','foo'(V0))),'abolish'('foo'(V0)),[],'true').
'conf_case'('predicates/abolish_1/tests.lgt:iso_abolish_1_05:61','error'('permission_error'('modify','static_procedure','/'('abolish',1))),'abolish'('/'('abolish',1)),[],'true').
