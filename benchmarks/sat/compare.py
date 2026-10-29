#!/usr/bin/env python3
"""Warm-process C / pre-refactor / current Lisp benchmarks. Run from any directory.
Requires GCC, SBCL, Python 3. Input parsing/model checks are outside timing.
"""
from pathlib import Path
import os,sys,subprocess,json,statistics,time,math,platform,hashlib,argparse
ROOT=Path(__file__).resolve().parent
REPO=ROOT.parents[1]
LIB=REPO
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--baseline',type=Path,required=True,help='checkout of the pre-refactor OOPArts SAT port')
parser.add_argument('--sbcl',default=os.environ.get('SBCL','sbcl'))
parser.add_argument('--output',type=Path,default=REPO/'build/sat/benchmark/results.json')
args=parser.parse_args()
BASELINE=args.baseline.resolve()
SBCL=args.sbcl
BUILD=REPO/'build/sat/benchmark'
BUILD.mkdir(parents=True,exist_ok=True)
NAMES=['status','conflicts','decisions','propagations','ticks','reductions','restarts','switches','rephasings','eliminations','vivifications','model_hash','maximum_variable']
def parse_cnf(path):
 n=0;nums=[]
 for line in path.read_text().splitlines():
  if not line.strip() or line.lstrip().startswith('c'):continue
  if line.startswith('p'):n=int(line.split()[2]);continue
  nums+=list(map(int,line.split()))
 c=[];cs=[]
 for v in nums:
  if v:c.append(v)
  else:cs.append(c);c=[]
 assert not c;return n,cs

def existing_cases():
 # Reuse the fixed-seed differential corpus already delivered by the port.
 # The three generated inputs are also saved in cases.txt for exact replay.
 sys.path.insert(0,str(REPO/'tools/sat'))
 from differential import php
 cases=[]
 def add(name,n,cs):cases.append(dict(name=name,n=n,clauses=cs,limit=-1))
 add('binary-chain-4096',4096,[[1]]+[[-v,v+1] for v in range(1,4096)])
 for name in ['sqrt1042441.cnf','add16.cnf','ph6.cnf','add32.cnf','add64.cnf','add128.cnf','prime65537.cnf']:
  add(name,*parse_cnf(REPO/'vendor/satch/test'/name))
 n,cs=php(7,6);add('pigeonhole-7-6',n,cs)
 # Standalone seeded 3-SAT near the phase transition, independently generated.
 import random
 rng=random.Random(20261029)
 for n in [80,125]:
  cs=[[v*rng.choice([-1,1]) for v in rng.sample(range(1,n+1),3)] for _ in range(int(4.26*n))]
  add('random-3sat-'+str(n),n,cs)
 return cases

def build():
 subprocess.run(['gcc','-O3','-w',str(ROOT/'warm.c'),str(ROOT/'reference.c'),'-lm','-o',str(BUILD/'bench-c')],check=True)
 subprocess.run(['gcc','-O3','-w','-DMATCH_ALLOCATOR',str(ROOT/'warm.c'),str(ROOT/'reference.c'),'-lm','-o',str(BUILD/'bench-c-arena')],check=True)

class Server:
 def __init__(self,name,args):
  self.name=name
  err=(BUILD/(name+'-stderr.log')).open('w')
  affinity=min(os.sched_getaffinity(0))
  self.p=subprocess.Popen(args,stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=err,text=True,bufsize=1,preexec_fn=lambda:os.sched_setaffinity(0,{affinity}))
  while True:
   line=self.p.stdout.readline()
   if not line:raise RuntimeError(name+' failed during startup; see stderr')
   if line.strip()=='READY':break
 def run(self,i,reps):
  self.p.stdin.write(f'{i} {reps}\n');self.p.stdin.flush()
  line=self.p.stdout.readline()
  if not line:raise RuntimeError(self.name+' stopped; see stderr')
  v=line.split()
  assert len(v)==22,(self.name,line)
  return dict(repetitions=int(v[0]),solve_cpu=float(v[1]),total_cpu=float(v[2]),solve_wall=float(v[3]),total_wall=float(v[4]),solve_cons_bytes=int(v[5]),total_cons_bytes=int(v[6]),gc_build_solve_cpu=float(v[7]),digest=int(v[8]),signature=dict(zip(NAMES,map(int,v[9:]))))
 def close(self):
  if self.p.poll() is None:self.p.stdin.write('-1 0\n');self.p.stdin.flush();self.p.communicate(timeout=10)

def main():
 baseline_header = '(require :asdf)\n(let ((*compile-verbose* nil) (*load-verbose* nil))\n'
 for path in [BASELINE/'sat/load.lisp', BASELINE/'sat/tests/stats.lisp']:
  baseline_header += '  (load '+json.dumps(str(path))+')\n'
 baseline_header += ')\n'
 body=(ROOT/'warm.lisp').read_text().split(';;; Benchmark protocol follows.\n',1)[1]
 body=body.replace('ooparts-tests/sat/stats:test-statistics','ooparts/sat/impl::test-statistics')
 (BUILD/'baseline.lisp').write_text(baseline_header+body)
 build();cases=existing_cases()
 text=str(len(cases))+'\n'+''.join(f'{c["n"]} {len(c["clauses"])} -1\n'+''.join(' '.join(map(str,cl))+' 0\n' for cl in c['clauses']) for c in cases)
 (BUILD/'cases.txt').write_text(text)
 c=Server('c',[str(BUILD/'bench-c'),str(BUILD/'cases.txt')])
 old=Server('before',[SBCL,'--noinform','--script',str(BUILD/'baseline.lisp'),str(BUILD/'cases.txt')])
 new=Server('after',[SBCL,'--noinform','--script',str(ROOT/'warm.lisp'),str(BUILD/'cases.txt')])
 ao=Server('audit-before',[str(BUILD/'bench-c-arena'),str(BUILD/'cases.txt')]);an=Server('audit-after',[str(BUILD/'bench-c-arena'),str(BUILD/'cases.txt')])
 def lrun(server,audit,i,reps):
  x=server.run(i,reps);a=audit.run(i,reps)
  assert x['digest']==a['digest'],(cases[i]['name'],server.name,'trace mismatch',x['signature'],a['signature'])
  return x
 records=[]
 def summary(groups):
  s={'repetitions_per_group':groups[0]['repetitions'],'signature':groups[-1]['signature']}
  for key in ['solve_cpu','total_cpu','solve_wall','total_wall','solve_cons_bytes','total_cons_bytes','gc_build_solve_cpu']:
   values=[g[key]/g['repetitions'] for g in groups];s[key]=statistics.median(values)
   if key.endswith(('cpu','wall')):s[key+'_range']=[min(values),max(values)]
  return s
 try:
  for i,case in enumerate(cases):
   print(f'[{i+1}/{len(cases)}] {case["name"]}',flush=True)
   c.run(i,1);lrun(old,ao,i,1);lrun(new,an,i,1)
   cp=c.run(i,1);op=lrun(old,ao,i,1);np=lrun(new,an,i,1)
   def reps(p,target):return max(1,min(10000,math.ceil(target/max(p['solve_cpu'],p['total_cpu']/4,1e-7))))
   cr,orr,nr=reps(cp,.08),reps(op,.15),reps(np,.15)
   cg=[];og=[];ng=[]
   for r in range(5):
    if r%2:
     ng.append(lrun(new,an,i,nr));og.append(lrun(old,ao,i,orr));cg.append(c.run(i,cr))
    else:
     cg.append(c.run(i,cr));og.append(lrun(old,ao,i,orr));ng.append(lrun(new,an,i,nr))
   cs,os_,ns=summary(cg),summary(og),summary(ng)
   row=dict(name=case['name'],variables=case['n'],clauses=len(case['clauses']),c=cs,before=os_,after=ns,
    speedup=os_['solve_cpu']/ns['solve_cpu'],before_over_c=os_['solve_cpu']/cs['solve_cpu'],after_over_c=ns['solve_cpu']/cs['solve_cpu'],
    full_api_speedup=os_['total_cpu']/ns['total_cpu'],exact_audit=True,c_raw=cg,before_raw=og,after_raw=ng)
   records.append(row)
   print(f'  CPU solve: C {cs["solve_cpu"]*1000:.3f}ms / before {os_["solve_cpu"]*1000:.3f}ms / after {ns["solve_cpu"]*1000:.3f}ms; {row["speedup"]:.2f}x faster',flush=True)
   (BUILD/'partial.json').write_text(json.dumps(records,indent=2)+'\n')
 finally:
  for server in [c,old,new,ao,an]:server.close()
 geom=lambda key:math.exp(statistics.mean(math.log(x[key]) for x in records))
 result=dict(environment=dict(cpu=next(x.split(':',1)[1].strip() for x in Path('/proc/cpuinfo').read_text().splitlines() if x.startswith('model name')),platform=platform.platform(),gcc=subprocess.check_output(['gcc','--version'],text=True).splitlines()[0],sbcl=subprocess.check_output([SBCL,'--version'],text=True).strip(),affinity_cpu=min(os.sched_getaffinity(0)),groups=5,c_flags='-O3 -DNDEBUG, separate translation units, no LTO'),
  summary=dict(geometric_mean_speedup=geom('speedup'),before_over_c_geomean=geom('before_over_c'),after_over_c_geomean=geom('after_over_c'),full_api_speedup_geomean=geom('full_api_speedup'),min_speedup=min(x['speedup'] for x in records),max_speedup=max(x['speedup'] for x in records)),
  method='Warm processes, one pinned CPU, five alternating timed batches. Process CPU medians per solve; no conflict limit. Startup, compilation, parsing, model queries, statistics and IPC excluded. GC inside timed phases included. Both Lisp implementations audited against separate matched-allocator C servers for every iteration; all trace and model digests must match. Allocation counts are cumulative Lisp managed-heap allocations, excluding native arenas.',cases=records,
  source_sha256={label:{n:hashlib.sha256((directory/n).read_bytes()).hexdigest() for n in files}
    for label,directory,files in [
     ('before',BASELINE,['sat/src/runtime.lisp','sat/src/translated.lisp','sat/src/api.lisp']),
     ('after',REPO,['src/sat/runtime.lisp','src/sat/layout.lisp','src/sat/engine.lisp','src/sat/low-level.lisp'])]},
  harness_sha256={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in [ROOT/'compare.py',ROOT/'warm.lisp',ROOT/'warm.c',ROOT/'reference.c']},
  baseline_tree=subprocess.check_output(['git','-C',str(BASELINE),'write-tree'],text=True).strip())
 args.output.parent.mkdir(parents=True,exist_ok=True)
 args.output.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result['summary'],indent=2),flush=True)

if __name__=='__main__':main()
