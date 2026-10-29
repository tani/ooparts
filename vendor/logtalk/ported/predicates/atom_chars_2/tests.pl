% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/atom_chars_2/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'conf_case'('predicates/atom_chars_2/tests.lgt:iso_atom_chars_2_01:34','true'('=='(V0,[])),'atom_chars'('',V0),[],'true').
'conf_case'('predicates/atom_chars_2/tests.lgt:iso_atom_chars_2_02:37','true'('=='(V0,['['|[']'|[]]])),'atom_chars'([],V0),[],'true').
'conf_case'('predicates/atom_chars_2/tests.lgt:iso_atom_chars_2_03:40','true'('=='(V0,[''''|[]])),'atom_chars'('''',V0),[],'true').
'conf_case'('predicates/atom_chars_2/tests.lgt:iso_atom_chars_2_04:43','true'('=='(V0,['a'|['n'|['t'|[]]]])),'atom_chars'('ant',V0),[],'true').
'conf_case'('predicates/atom_chars_2/tests.lgt:iso_atom_chars_2_05:46','true'('=='(V0,'sop')),'atom_chars'(V0,['s'|['o'|['p'|[]]]]),[],'true').
'conf_case'('predicates/atom_chars_2/tests.lgt:iso_atom_chars_2_06:49','true'('=='(V0,['o'|['r'|['t'|['h'|[]]]]])),'atom_chars'('North',['N'|V0]),[],'true').
'conf_case'('predicates/atom_chars_2/tests.lgt:iso_atom_chars_2_07:52','false','atom_chars'('soap',['s'|['o'|['p'|[]]]]),[],'true').
'conf_case'('predicates/atom_chars_2/tests.lgt:iso_atom_chars_2_08:55','error'('instantiation_error'),'atom_chars'(V0,V1),[],'true').
