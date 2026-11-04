"""Verify the numerical gate rejects missing execution, behavior, and process errors."""
import copy
import importlib.util
from pathlib import Path
import sys
import unittest

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools'))
spec = importlib.util.spec_from_file_location('curses_coverage', ROOT / 'tools/curses/coverage.py')
coverage = importlib.util.module_from_spec(spec)
spec.loader.exec_module(coverage)


class CoverageGate(unittest.TestCase):
    def setUp(self):
        self.report = {'process_exit_code': 0, 'unexpected_features': [],
                       'api': {'percent': 100, 'exercised_percent': 100},
                       'features': {'percent': 100}}

    def test_independent_thresholds(self):
        for key, metric in [('api', 'percent'), ('api', 'exercised_percent'), ('features', 'percent')]:
            with self.subTest(metric=metric, key=key):
                d = copy.deepcopy(self.report)
                d[key][metric] = 98.99
                self.assertFalse(coverage.meets_threshold(d, 99))
                d[key][metric] = 99
                self.assertTrue(coverage.meets_threshold(d, 99))

    def test_process_failure(self):
        self.report['process_exit_code'] = 1
        self.assertFalse(coverage.meets_threshold(self.report, 99))

    def test_unregistered_scenarios(self):
        self.report['unexpected_features'] = ['unregistered']
        self.assertFalse(coverage.meets_threshold(self.report, 99))


if __name__ == '__main__':
    unittest.main()
