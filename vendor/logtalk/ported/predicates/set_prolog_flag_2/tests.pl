% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/set_prolog_flag_2/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'conf_case'('predicates/set_prolog_flag_2/tests.lgt:iso_set_prolog_flag_2_01:38','true',','('set_prolog_flag'('unknown','fail'),'current_prolog_flag'('unknown','fail')),[],'true').
'conf_case'('predicates/set_prolog_flag_2/tests.lgt:iso_set_prolog_flag_2_02:42','error'('instantiation_error'),'set_prolog_flag'(V0,'off'),[],'true').
'conf_case'('predicates/set_prolog_flag_2/tests.lgt:iso_set_prolog_flag_2_03:45','error'('type_error'('atom',5)),'set_prolog_flag'(5,'decimals'),[],'true').
'conf_case'('predicates/set_prolog_flag_2/tests.lgt:iso_set_prolog_flag_2_04:48','error'('domain_error'('prolog_flag','date')),'set_prolog_flag'('date','July 1999'),[],'true').
'conf_case'('predicates/set_prolog_flag_2/tests.lgt:iso_set_prolog_flag_2_05:51','error'('domain_error'('flag_value','+'('debug','trace'))),'set_prolog_flag'('debug','trace'),[],'true').
