#!/usr/bin/env python3
"""Exact ASCII/binary proof comparison + independent RUP verification."""
import argparse,os,subprocess,sys,json
from pathlib import Path
from differential import ROOT,php,add_lisp_arguments,lisp_command,options
parser=argparse.ArgumentParser(description=__doc__);add_lisp_arguments(parser)
parser.add_argument('--build-dir',type=Path,default=ROOT/'build/sat')
parser.add_argument('--report',type=Path,default=ROOT/'tests/sat/reports/proof-results.json')
args=parser.parse_args()
build=args.build_dir.resolve();build.mkdir(parents=True,exist_ok=True)
subprocess.run(['gcc','-O3',str(ROOT/'tests/sat/proof-reference.c'),'-lm','-o',str(build/'proof-reference')],check=True)
def rup(database,clause):
 assignment={}
 for lit in clause:
  v=abs(lit);val=lit<0
  if v in assignment and assignment[v]!=val:return True
  assignment[v]=val
 while True:
  changed=False
  for c in database:
   if any(assignment.get(abs(lit))==(lit>0) for lit in c):continue
   unassigned=[lit for lit in c if abs(lit) not in assignment]
   if not unassigned:return True
   if len(unassigned)==1:
    lit=unassigned[0];assignment[abs(lit)]=lit>0;changed=True
  if not changed:return False

def verify(clauses,proof):
 database=[tuple(sorted(set(c))) for c in clauses];added=0
 for line in proof.splitlines():
  tokens=line.split();deletion=tokens[0]=='d';tokens=tokens[1:] if deletion else tokens
  assert tokens[-1]=='0';clause=tuple(sorted(set(map(int,tokens[:-1]))))
  if deletion:
   if clause in database:database.remove(clause)
  else:
   assert rup(database,clause),clause;database.append(clause);added+=1
 assert () in database
 return added
report=[]
for name,n,clauses in [('contradictory-unit',1,[[1],[-1]]),('full2',2,[[1,2],[1,-2],[-1,2],[-1,-2]]),('pigeonhole5',*php(5,4))]:
 text=f'{n} {len(clauses)} -1\n'+''.join(' '.join(map(str,c))+' 0\n' for c in clauses)
 inp=build/(name+'.txt');inp.write_text(text)
 for mode in ['a','b']:
  cp=build/f'{name}-{mode}-c.proof';lp=build/f'{name}-{mode}-lisp.proof'
  c=subprocess.run([str(build/'proof-reference'),str(cp),mode],input=text,text=True,capture_output=True,check=True)
  with lisp_command(ROOT/'tools/sat/proof.lisp',[inp,lp,mode],**options(args)) as command:
   l=subprocess.run(command,text=True,capture_output=True,check=True,timeout=300)
  assert c.stdout.strip()=='20' and l.stdout.strip()=='20',(c.stdout,l.stdout)
  assert cp.read_bytes()==lp.read_bytes(),name
  steps=verify(clauses,lp.read_text()) if mode=='a' else None
  report.append(dict(case=name,format=mode,bytes=lp.stat().st_size,identical=True,rup_additions=steps))
args.report.parent.mkdir(parents=True,exist_ok=True)
args.report.write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
