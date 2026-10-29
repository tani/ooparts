#!/usr/bin/env python3
"""Differential tests against pinned C, plus independent exhaustive models.
Requires GCC, Python, and SBCL. Does not call external Python packages.
"""
import argparse,subprocess,random,itertools,json,time,os,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def read_cnf(p):
 n=0;nums=[]
 for line in p.read_text().splitlines():
  if not line.strip() or line.lstrip().startswith('c'):continue
  if line.startswith('p'):n=int(line.split()[2]);continue
  nums.extend(map(int,line.split()))
 cs=[];c=[]
 for x in nums:
  if x:c.append(x)
  else:cs.append(c);c=[]
 assert not c,p
 return n,cs

def php(pigeons,holes):
 v=lambda p,h:p*holes+h+1
 return pigeons*holes,[[v(p,h) for h in range(holes)] for p in range(pigeons)]+[[-v(p,h),-v(q,h)] for h in range(holes) for p in range(pigeons) for q in range(p)]

def brute(n,clauses):
 return any(all(any(bool(bits & (1<<(abs(x)-1)))==(x>0) for x in c) for c in clauses) for bits in range(1<<n))

def main():
 parser=argparse.ArgumentParser();parser.add_argument('--sbcl',default=os.environ.get('SBCL','sbcl'));parser.add_argument('--random',type=int,default=1000);args=parser.parse_args()
 build=ROOT/'tests/build';build.mkdir(exist_ok=True)
 subprocess.run(['gcc','-w','-O3',str(ROOT/'tests/reference.c'),'-lm','-o',str(build/'reference')],check=True)
 subprocess.run(['gcc','-w','-O3','-DMATCH_ALLOCATOR',str(ROOT/'tests/reference.c'),'-lm','-o',str(build/'reference-arena')],check=True)
 cases=[];rng=random.Random(20261029)
 def add(name,n,c,limit=-1):cases.append(dict(name=name,n=n,clauses=c,limit=limit))
 for p in sorted((ROOT/'tests/upstream-cnfs').glob('*.cnf')):
  n,c=read_cnf(p);add(p.name,n,c,5000)
 for i in range(args.random):
  n=rng.randrange(1,13);m=rng.randrange(0,7*n)
  c=[[rng.choice([-1,1])*rng.randrange(1,n+1) for _ in range(rng.choices([0,1,2,3,4],[1,4,20,70,5])[0])] for _ in range(m)]
  add('random-'+str(i),n,c)
 for n in [25,40,60,80,100,125]:
  for j in range(4):
   c=[]
   for _ in range(int(4.26*n)):
    c.append([v*rng.choice([-1,1]) for v in rng.sample(range(1,n+1),3)])
   add(f'3sat-{n}-{j}',n,c,5000)
 for p in range(5,11):
  n,c=php(p,p-1);add(f'php-{p}',n,c,5000)
 for n,c in [(0,[]),(1,[[1]]),(1,[[1],[-1]]),(2,[[1,2],[-1,2],[1,-2],[-1,-2]])]:
  for lim in [0,1,2]:add(f'limit-{n}-{len(c)}-{lim}',n,c,lim)
 text=''.join(f'{c["n"]} {len(c["clauses"])} {c["limit"]}\n'+''.join(' '.join(map(str,cl))+' 0\n' for cl in c['clauses']) for c in cases)
 (build/'cases.txt').write_text(text)
 start=time.monotonic();c_run=subprocess.run([str(build/'reference')],input=text,text=True,capture_output=True,check=True,timeout=180);c_time=time.monotonic()-start
 (build/'c-results.txt').write_text(c_run.stdout)
 arena_run=subprocess.run([str(build/'reference-arena')],input=text,text=True,capture_output=True,check=True,timeout=180)
 (build/'arena-results.txt').write_text(arena_run.stdout)
 start=time.monotonic();l_run=subprocess.run([args.sbcl,'--noinform','--script',str(ROOT/'tests/batch.lisp'),str(build/'cases.txt')],text=True,capture_output=True,timeout=300);l_time=time.monotonic()-start
 (build/'lisp-results.txt').write_text(l_run.stdout);(build/'lisp-stderr.txt').write_text(l_run.stderr)
 if l_run.returncode:
  print(l_run.stderr[-6000:]);print(l_run.stdout[-2000:]);raise RuntimeError('Lisp failed')
 cs=[list(map(int,line.split())) for line in c_run.stdout.splitlines() if line and line[0].isdigit()]
 ls=[list(map(int,line.split())) for line in l_run.stdout.splitlines() if line and line[0].isdigit()]
 assert len(cs)==len(cases),(len(cs),len(cases))
 assert len(ls)==len(cases),(len(ls),len(cases))
 arena=[list(map(int,line.split())) for line in arena_run.stdout.splitlines()]
 assert len(arena)==len(cases)
 checked=0;maxstats=[0]*9;stock_differences=[]
 for case,a,b,matched in zip(cases,cs,ls,arena):
  assert matched==b,(case['name'],'matched allocator',matched,b)
  assert a[1]==b[1],(case['name'],'stock result',a,b)
  if a!=b:stock_differences.append(dict(case=case['name'],columns=[i for i,(x,y) in enumerate(zip(a,b)) if x!=y]))
  for i in range(9):maxstats[i]=max(maxstats[i],a[3+i])
  if a[1]==10:
   model=set(a[12:]);assert all(any(lit in model for lit in clause) for clause in case['clauses']),case['name']
  if case['n']<=12 and case['limit']<0:
   assert a[1]==(10 if brute(case['n'],case['clauses']) else 20),case['name'];checked+=1
 report=dict(stock_allocator_trace_differences=stock_differences,matched_allocator_exact=True,cases=len(cases),exhaustive_checks=checked,identical=['status','conflicts','decisions','propagations','ticks','reductions','restarts','mode switches','rephasings','eliminations','vivifications','model'],max_counters=dict(zip(['decisions','propagations','ticks','reductions','restarts','switches','rephasings','eliminations','vivifications'],maxstats)),c_batch_seconds=c_time,lisp_batch_seconds=l_time,timing_note='Lisp includes process startup/ASDF loading; not an isolated speed benchmark')
 (ROOT/'tests/results.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))
if __name__=='__main__':main()
