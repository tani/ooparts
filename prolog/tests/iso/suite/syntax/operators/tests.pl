% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/syntax/operators/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

':-'('op'(100,'fx','fx')).
':-'('op'(100,'xf','xf')).
':-'('op'(100,'xfx','xfx')).
':-'('op'(100,'fy','fy')).
':-'('op'(100,'yf','yf')).
':-'('op'(100,'xfy','xfy')).
':-'('op'(100,'yfx','yfx')).
':-'('conf_suite_cleanup','conf_clean_text_input').
'conf_case'('syntax/operators/tests.lgt:iso_operators_01:52','error'('syntax_error'(V0)),','('conf_set_text_input'('fx fx 1. '),'read'(V1)),[],'true').
'conf_case'('syntax/operators/tests.lgt:iso_operators_02:56','true',','('conf_set_text_input'('fx (fx 1). '),'read'(V0)),[],'true').
'conf_case'('syntax/operators/tests.lgt:iso_operators_03:60','error'('syntax_error'(V0)),','('conf_set_text_input'('1 xf xf. '),'read'(V1)),[],'true').
'conf_case'('syntax/operators/tests.lgt:iso_operators_04:64','true',','('conf_set_text_input'('(1 xf) xf. '),'read'(V0)),[],'true').
'conf_case'('syntax/operators/tests.lgt:iso_operators_05:68','error'('syntax_error'(V0)),','('conf_set_text_input'('1 xfx 2 xfx 3. '),'read'(V1)),[],'true').
'conf_case'('syntax/operators/tests.lgt:iso_operators_06:72','true',','('conf_set_text_input'('(1 xfx 2) xfx 3. '),'read'(V0)),[],'true').
'conf_case'('syntax/operators/tests.lgt:iso_operators_07:76','true',','('conf_set_text_input'('1 xfx (2 xfx 3). '),'read'(V0)),[],'true').
'conf_case'('syntax/operators/tests.lgt:iso_operators_08:80','true'('=='(V0,V1)),','('conf_set_text_input'('fy fy 1. fy (fy 1). '),','('read'(V0),'read'(V1))),[],'true').
'conf_case'('syntax/operators/tests.lgt:iso_operators_09:84','true'('=='(V0,V1)),','('conf_set_text_input'(['1 xfy  2 xfy 3. '|['1 xfy (2 xfy 3). '|[]]]),','('read'(V0),'read'(V1))),[],'true').
'conf_case'('syntax/operators/tests.lgt:iso_operators_10:88','true'('=='(V0,V1)),','('conf_set_text_input'(['1 xfy  2 yfx 3. '|['1 xfy (2 yfx 3). '|[]]]),','('read'(V0),'read'(V1))),[],'true').
'conf_case'('syntax/operators/tests.lgt:iso_operators_11:92','true'('=='(V0,V1)),','('conf_set_text_input'('fy 2 yf. fy (2 yf). '),','('read'(V0),'read'(V1))),[],'true').
'conf_case'('syntax/operators/tests.lgt:iso_operators_12:96','true'('=='(V0,V1)),','('conf_set_text_input'('1 yf yf. (1 yf) yf. '),','('read'(V0),'read'(V1))),[],'true').
'conf_case'('syntax/operators/tests.lgt:iso_operators_13:100','true'('=='(V0,V1)),','('conf_set_text_input'([' 1 yfx 2  yfx 3. '|['(1 yfx 2) yfx 3. '|[]]]),','('read'(V0),'read'(V1))),[],'true').
'conf_case'('syntax/operators/tests.lgt:iso_operators_14:106','true'('=='(V0,'-'(1,2))),','('conf_set_text_input'('-(1,2). '),'read'(V0)),[],'true').
'conf_case'('syntax/operators/tests.lgt:iso_operators_15:110','true',','('conf_set_text_input'('- (1,2). '),','('read'(V0),'conf_assertion'('=='(V0,'-'(','(1,2)))))),[],'true').
