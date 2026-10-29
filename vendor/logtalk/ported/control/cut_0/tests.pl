% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/control/cut_0/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

':-'('twice'('!'),'write'('C ')).
':-'('twice'('true'),'write'('Moss ')).
'goal'(','('twice'(V0),'!')).
'goal'('write'('Three ')).
'conf_case'('control/cut_0/tests.lgt:iso_cut_0_01:43','true','!',[],'true').
'conf_case'('control/cut_0/tests.lgt:iso_cut_0_02:46','fail',';'(','('!','fail'),'true'),[],'true').
'conf_case'('control/cut_0/tests.lgt:iso_cut_0_03:49','true',';'(','('call'('!'),'fail'),'true'),[],'true').
'conf_case'('control/cut_0/tests.lgt:iso_cut_0_04:52','true'(V0),','('conf_set_text_output'(''),','('\\+'(','('twice'(V1),','('!',','('write'('Forwards '),'fail')))),'conf_text_output_assertion'('C Forwards ',V0))),[],'true').
'conf_case'('control/cut_0/tests.lgt:iso_cut_0_05:57','true'(V0),','('conf_set_text_output'(''),','('\\+'(','(';'('!','write'('No ')),','('write'('Cut disjunction '),'fail'))),'conf_text_output_assertion'('Cut disjunction ',V0))),[],'true').
'conf_case'('control/cut_0/tests.lgt:iso_cut_0_06:62','true'(V0),','('conf_set_text_output'(''),','('\\+'(','('twice'(V1),','(';'('write'('No '),'!'),','('write'('Cut '),'fail')))),'conf_text_output_assertion'('C No Cut Cut ',V0))),[],'true').
'conf_case'('control/cut_0/tests.lgt:iso_cut_0_07:67','true'(V0),','('conf_set_text_output'(''),','('\\+'(','('twice'(V1),';'(','('!','fail'),'write'('No ')))),'conf_text_output_assertion'('C ',V0))),[],'true').
'conf_case'('control/cut_0/tests.lgt:iso_cut_0_08:72','true'(V0),','('conf_set_text_output'(''),','('\\+'(','('twice'(V1),','('call'(V1),','('write'('Forwards '),'fail')))),'conf_text_output_assertion'('C Forwards Moss Forwards ',V0))),[],'true').
'conf_case'('control/cut_0/tests.lgt:iso_cut_0_09:77','true'(V0),','('conf_set_text_output'(''),','('\\+'(','('goal'(V1),','('call'(V1),','('write'('Forwards '),'fail')))),'conf_text_output_assertion'('C Forwards Three Forwards ',V0))),[],'true').
'conf_case'('control/cut_0/tests.lgt:iso_cut_0_10:82','true'(V0),','('conf_set_text_output'(''),','('\\+'(','('twice'(V1),','('\\+'('\\+'('!')),','('write'('Forwards '),'fail')))),'conf_text_output_assertion'('C Forwards Moss Forwards ',V0))),[],'true').
'conf_case'('control/cut_0/tests.lgt:iso_cut_0_11:87','true'(V0),','('conf_set_text_output'(''),','('\\+'(','('twice'(V1),','('once'('!'),','('write'('Forwards '),'fail')))),'conf_text_output_assertion'('C Forwards Moss Forwards ',V0))),[],'true').
'conf_case'('control/cut_0/tests.lgt:iso_cut_0_12:92','true'(V0),','('conf_set_text_output'(''),','('\\+'(','('twice'(V1),','('call'('!'),','('write'('Forwards '),'fail')))),'conf_text_output_assertion'('C Forwards Moss Forwards ',V0))),[],'true').
