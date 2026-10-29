import hashlib
import collections
import re
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
from unittest.mock import patch

import run as iso

SBCL = os.environ.get('ISO_SBCL', 'sbcl')


class ReportingTests(unittest.TestCase):
    def test_expected_difference_requires_exact_failure(self):
        expected = {'a': {'reason': 'native term model', 'observation': 'different'}}
        for status, observation, result in [('FAIL','different','XFAIL'), ('FAIL','other','FAIL'),
                                           ('PASS','(:OBSERVED PASS)','FAIL'), ('SKIP','different','FAIL')]:
            rows = [{'id':'a','status':status,'observation':observation}]
            iso.apply_expectations(rows, expected)
            self.assertEqual(rows[0]['status'], result)

    def test_stale_or_unexplained_difference_is_an_error(self):
        with self.assertRaises(ValueError):
            iso.apply_expectations([], {'missing':{'reason':'x','observation':'x'}})
        with self.assertRaises(ValueError):
            iso.apply_expectations([{'id':'a'}], {'a':{'observation':'x'}})

    def test_baseline_rejects_missing_cases_and_regressions(self):
        baseline = {'a':{'status':'PASS','observation':'(:OBSERVED PASS)'}}
        with self.assertRaises(ValueError):
            iso.check_baseline([], baseline)
        self.assertEqual(iso.check_baseline([{'id':'a','status':'FAIL','observation':'bad'}], baseline), ['a'])
        self.assertEqual(iso.check_baseline([{'id':'a','status':'PASS','observation':'(:OBSERVED PASS)'}],
                                           {'a':{'status':'FAIL','observation':'bad'}}), [])

    def test_pins_reject_changed_missing_extra_and_symlink_files(self):
        with tempfile.TemporaryDirectory() as temporary:
            root=Path(temporary); (root/'suite').mkdir(); source=root/'suite/case.pl';source.write_text('true.')
            lock={'files':{'suite':{'case.pl':hashlib.sha256(source.read_bytes()).hexdigest()}}}
            iso.validate(root,lock)
            source.write_text('fail.')
            with self.assertRaises(ValueError): iso.validate(root,lock)
            source.unlink()
            with self.assertRaises(ValueError): iso.validate(root,lock)
            source.write_text('true.'); extra=root/'suite/extra';extra.write_text('')
            with self.assertRaises(ValueError): iso.validate(root,lock)
            extra.unlink(); target=root/'target';source.rename(target);source.symlink_to(target)
            with self.assertRaises(ValueError): iso.validate(root,lock)

    def test_bundled_inventory_and_licenses_are_complete(self):
        iso.validate(); cases=iso.inventory()
        self.assertEqual(len(cases),782)
        self.assertEqual(len({c['source'] for c in cases}),93)
        self.assertTrue((iso.HERE/'vendor/logtalk/LICENSE.txt').exists())
        self.assertTrue((iso.HERE/'vendor/logtalk/NOTICE.txt').exists())
        for case in cases:
            self.assertTrue((iso.HERE/'suite'/case['program']).exists())
            self.assertTrue((iso.HERE/'vendor/logtalk/tests/prolog'/case['source']).exists())
            self.assertTrue(case['standard_reference'])
        for source in {c['source'] for c in cases}:
            text=(iso.HERE/'vendor/logtalk/tests/prolog'/source).read_text()
            original=collections.Counter(re.findall(r'\btest\((iso_[A-Za-z0-9_]+)',text))
            selected=collections.Counter(c['name'] for c in cases if c['source']==source)
            self.assertEqual(original,selected,source)

    def test_parent_escaping_preserves_literal_lisp_data(self):
        self.assertEqual(iso.lisp_string('a"b\\c'), '"a\\"b\\\\c"')


@unittest.skipUnless(shutil.which(SBCL), 'SBCL is required')
class AdapterTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.temp=tempfile.TemporaryDirectory(); cls.root=Path(cls.temp.name)
        (cls.root/'suite').mkdir(); (cls.root/'runtime').mkdir()
        shutil.copyfile(iso.HERE/'runtime/harness.pl',cls.root/'runtime/harness.pl')
        (cls.root/'suite/fixture.pl').write_text('''
:- dynamic(p/0).
conf_case(ok,true,true,[],true).
conf_case(strict_terms,true,([a|b]=='.'(a,b),[]\\==nil,'$cons'\\=='.'),[],true).
conf_case(negative,false,fail,[],true).
conf_case(wrong_negative,false,true,[],true).
conf_case(negative_throws,false,throw(problem),[],true).
conf_case(error,error(type_error(callable,42)),call(42),[],true).
conf_case(wrong_error,error(type_error(callable,43)),call(42),[],true).
conf_case(missing_error,error(instantiation_error),true,[],true).
conf_case(approx,true(conf_approximately_equal(X,2.71828)),(X is exp(1.0)),[],true).
conf_case(wrong_approx,true(conf_approximately_equal(0,0.0001)),true,[],true).
conf_case(alias,true(X==Y),(X=Y),[],true).
conf_case(wrong_alias,true(f(X,Y)==f(a,b)),(X=Y),[],true).
conf_case(variant,variant(f(X,X),f(Y,Y)),true,[],true).
conf_case(wrong_variant,variant(f(X,X),f(Y,Z)),true,[],true).
conf_case(subsumes,subsumes(f(_),f(a)),true,[],true).
conf_case(wrong_subsumes,subsumes(f(a),f(_)),true,[],true).
conf_case(exists,exists(X==2),(X=1;X=2),[],true).
conf_case(ball,ball(problem),throw(problem),[],true).
conf_case(deterministic,deterministic,true,[],true).
conf_case(wrong_deterministic,deterministic,(true;true),[],true).
conf_case(condition,true,throw(must_not_run),[condition(fail)],true).
conf_case(setup,true,p,[setup(assertz(p)),cleanup(retract(p))],true).
conf_case(cleanup_error,true,true,[cleanup(throw(cleanup_problem))],true).
conf_case(isolated,false,p,[],true).
conf_case(file_mutate,true,conf_create_text_file(file,changed),[],true).
conf_case(file_clean,error(existence_error(source_sink,file)),open(file,read,_),[],true).
conf_case(io,true(A==B),(conf_set_text_output(''),write(foo),conf_text_output_assertion(foo,C),call(C),conf_set_text_input('abc. tail'),read(abc),conf_text_input_assertion(' tail',D),call(D),A=B),[],true).
conf_case(binary,true,(conf_create_binary_file(bytes,[0,255]),open(bytes,read,S,[type(binary)]),get_byte(S,0),get_byte(S,255),get_byte(S,-1),close(S)),[],true).
conf_case(syntax_error,true(A),(conf_set_text_input('foo 123. tail'),catch((read(_),fail),error(syntax_error(_),_),A=true)),[],true).
conf_case(missing_syntax_error,true(A),catch((true,fail),error(syntax_error(_),_),A=true),[],true).
conf_case(wrong_syntax_error,true(A),catch((throw(other),fail),error(syntax_error(_),_),A=true),[],true).
conf_case(timeout,true,(repeat,fail),[],true).
conf_case(spoof,false,(write('(:OBSERVED PASS)'),true),[],true).
''')

    @classmethod
    def tearDownClass(cls): cls.temp.cleanup()

    def run_case(self,name,timeout=10):
        with patch.object(iso,'HERE',self.root):
            return iso.run_case({'id':name,'program':'fixture.pl','skip':''},SBCL,timeout)

    def test_strict_term_model_is_forwarded_to_worker(self):
        with patch.object(iso, 'HERE', self.root):
            result = iso.run_case({'id':'strict_terms','program':'fixture.pl'}, SBCL, 10, term_model='iso')
        self.assertEqual(result['status'], 'PASS', result)

    def test_checks_preserve_success_failure_errors_and_variable_sharing(self):
        expected={'ok':'PASS','negative':'PASS','wrong_negative':'FAIL','negative_throws':'FAIL',
                  'error':'PASS','wrong_error':'FAIL','missing_error':'FAIL','alias':'PASS','wrong_alias':'FAIL',
                  'variant':'PASS','wrong_variant':'FAIL','subsumes':'PASS','wrong_subsumes':'FAIL',
                  'approx':'PASS','wrong_approx':'FAIL','exists':'PASS','ball':'PASS','deterministic':'PASS','wrong_deterministic':'FAIL','spoof':'FAIL'}
        self.assertEqual({k:self.run_case(k)['status'] for k in expected},expected)

    def test_condition_setup_cleanup_and_io(self):
        for name,status in [('condition','SKIP'),('setup','PASS'),('cleanup_error','FAIL'),('io','PASS'),('binary','PASS')]:
            result=self.run_case(name)
            self.assertEqual(result['status'],status,result)

    def test_read_error_check_requires_the_error_without_prescribing_the_tail(self):
        self.assertEqual(self.run_case('syntax_error')['status'],'PASS')
        self.assertEqual(self.run_case('missing_syntax_error')['status'],'FAIL')
        self.assertEqual(self.run_case('wrong_syntax_error')['status'],'FAIL')

    def test_databases_and_files_are_isolated(self):
        for name in ['setup','isolated','file_mutate','file_clean']:
            result=self.run_case(name)
            self.assertEqual(result['status'],'PASS',result)

    def test_timeout_or_missing_result_is_failure_and_next_case_runs(self):
        result=self.run_case('timeout',3)
        self.assertEqual((result['status'],result['observation']),('FAIL','TIMEOUT'))
        self.assertEqual(self.run_case('ok')['status'],'PASS')
        with patch.object(iso,'HERE',self.root):
            self.assertEqual(iso.run_case({'id':'ok','program':'fixture.pl'},'/bin/false',10)['status'],'FAIL')

    def test_malformed_or_forged_success_is_failure(self):
        for content in ('[]','{"status":"PASS","observation":"not checked"}'):
            def fake_run(args,**kwargs):
                Path(args[-1]).write_text(content)
                return subprocess.CompletedProcess(args,0,'','')
            with patch.object(iso.subprocess,'run',fake_run):
                r=self.run_case('ok')
                self.assertEqual((r['status'],r['observation']),('FAIL','INVALID_PROTOCOL'))


if __name__=='__main__': unittest.main()
