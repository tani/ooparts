% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/syntax/comments/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

':-'('conf_suite_cleanup','conf_clean_text_input').
'conf_case'('syntax/comments/tests.lgt:iso_line_comment_01:34','true'('=='(V0,'end_of_file')),','('conf_set_text_input'('% abc\n'),'read'(V0)),[],'true').
'conf_case'('syntax/comments/tests.lgt:iso_line_comment_02:38','true'('=='('-'(V0,V1),'-'('a','end_of_file'))),','('conf_set_text_input'('% abc\na.\n% def\n'),','('read'(V0),'read'(V1))),[],'true').
'conf_case'('syntax/comments/tests.lgt:iso_block_comment_01:42','true'('=='(V0,'end_of_file')),','('conf_set_text_input'('/* abc\ndef\n*/\n'),'read'(V0)),[],'true').
'conf_case'('syntax/comments/tests.lgt:iso_block_comment_02:46','true'('=='('-'(V0,V1),'-'('a','end_of_file'))),','('conf_set_text_input'('/* abc */\na.\n/* def */\n'),','('read'(V0),'read'(V1))),[],'true').
'conf_case'('syntax/comments/tests.lgt:iso_block_comment_03:50','true'('=='('-'(V0,V1),'-'('a','end_of_file'))),','('conf_set_text_input'('/* /* */\na.\n/* /* */\n'),','('read'(V0),'read'(V1))),[],'true').
'conf_case'('syntax/comments/tests.lgt:iso_block_comment_04:54','error'('syntax_error'(V0)),','('conf_set_text_input'('/* */ */\n'),'read'(V1)),[],'true').
'conf_case'('syntax/comments/tests.lgt:iso_block_comment_05:58','error'('syntax_error'(V0)),','('conf_set_text_input'('/* \n'),'read'(V1)),[],'true').
