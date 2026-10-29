% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/char_code_2/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'conf_case'('predicates/char_code_2/tests.lgt:iso_char_code_2_01:38','true'('=='(V0,97)),'char_code'('a',V0),[],'true').
'conf_case'('predicates/char_code_2/tests.lgt:iso_char_code_2_02:41','true'('=='(V0,V1)),','('char_code'(V0,99),'atom_codes'(V1,[99|[]])),[],'true').
'conf_case'('predicates/char_code_2/tests.lgt:iso_char_code_2_03:44','true'('=='(V0,'c')),'char_code'(V0,99),[],'true').
'conf_case'('predicates/char_code_2/tests.lgt:iso_char_code_2_04:47','true',','('catch'('char_code'(V0,163),V1,'true'),';'('->'('var'(V1),'true'),'conf_subsumes'('error'('representation_error'('character_code'),V2),V1))),[],'true').
'conf_case'('predicates/char_code_2/tests.lgt:iso_char_code_2_05:55','true','char_code'('b',98),[],'true').
'conf_case'('predicates/char_code_2/tests.lgt:iso_char_code_2_06:58','error'('type_error'('character','ab')),'char_code'('ab',V0),[],'true').
'conf_case'('predicates/char_code_2/tests.lgt:iso_char_code_2_07:61','error'('instantiation_error'),'char_code'(V0,V1),[],'true').
