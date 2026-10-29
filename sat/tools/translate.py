#!/usr/bin/env python3
"""Translate the pinned SATCH production configuration to SBCL Common Lisp.
Not a general C compiler. Unsupported syntax raises an exception (never omitted).
Uses GCC only for preprocessing and independent ABI layout verification.
"""
from pathlib import Path
from dataclasses import dataclass,field
import ast as pyast,json,re,subprocess,collections
from pycparser import c_parser,c_ast as C
ROOT=Path(__file__).resolve().parent.parent
@dataclass(eq=False)
class T:
 kind:str
 name:str=''
 size:int=0
 align:int=1
 signed:bool=False
 base:object=None
 count:object=None
 fields:dict=field(default_factory=dict)
 params:list=field(default_factory=list)
 varargs:bool=False
 defined:bool=False
I=T('int','int',4,4,True); U=T('int','unsigned',4,4); L=T('int','long',8,8,True); UL=T('int','unsigned long',8,8)
CH=T('int','char',1,1,True); UC=T('int','unsigned char',1,1); B=T('bool','bool',1,1)
D=T('float','double',8,8); F=T('float','float',4,4); VOID=T('void','void')
def ptr(t):return T('ptr',base=t,size=8,align=8)
def sym(n):return '|c/'+n+'|'
def ls(s):return '"'+s.replace('\\','\\\\').replace('"','\\"')+'"'
def align(n,a):return (n+a-1)//a*a
class Translator:
 def __init__(self,tree):
  self.tree=tree; self.typedefs={'size_t':UL,'uint64_t':UL,'uintptr_t':UL,'ptrdiff_t':L,'bool':B,'FILE':VOID,'va_list':UL,'uint32_t':U,'uint8_t':UC}; self.structs={}; self.node_types={}; self.functions={}; self.globals={}; self.enums={}; self.strings={}; self.mapping=[]; self.layouts=[]; self.serial=0
  self.scope=[{}]; self.locals=[]; self.addr_taken=set(); self.allocs=[]; self.static=[]; self.constants={}; self.has_frame=False
  for n in tree.ext:
   if isinstance(n,C.Typedef):self.typedefs[n.name]=T('int','size_t',8,8) if n.name=='size_t' else self.typ(n.type)
   elif isinstance(n,C.FuncDef):self.functions[n.decl.name]=self.typ(n.decl.type)
   elif isinstance(n,C.Decl):
    t=self.typ(n.type)
    if n.name and t.kind=='func':self.functions[n.name]=t
    elif n.name:self.globals[n.name]=(sym('global/'+n.name),t)
 def fresh(self,p='v'):
  self.serial+=1;return p+str(self.serial)
 def const(self,n):
  if isinstance(n,C.Constant):return self.literal(n)[1]
  if isinstance(n,C.ID):
   if n.name in self.enums:return self.enums[n.name]
   return self.constants[n.name]
  if isinstance(n,C.UnaryOp):
   if n.op=='sizeof':return self.typeof(n.expr).size
   a=self.const(n.expr);return {'-':lambda:-a,'+':lambda:a,'~':lambda:~a,'!':lambda:int(not a)}[n.op]()
  if isinstance(n,C.BinaryOp):
   a=self.const(n.left)
   if n.op=='||' and a:return 1
   if n.op=='&&' and not a:return 0
   b=self.const(n.right)
   return {'+':lambda:a+b,'-':lambda:a-b,'*':lambda:a*b,'/':lambda:a//b,'<<':lambda:a<<b,'>>':lambda:a>>b,'|':lambda:a|b,'&':lambda:a&b,'>':lambda:int(a>b),'>=':lambda:int(a>=b),'<':lambda:int(a<b),'<=':lambda:int(a<=b),'==':lambda:int(a==b),'!=':lambda:int(a!=b),'||':lambda:int(bool(a) or bool(b)),'&&':lambda:int(bool(a) and bool(b))}[n.op]()
  if isinstance(n,C.Cast):return self.const(n.expr)
  raise ValueError(('constant',type(n),str(n)))
 def typ(self,n):
  if isinstance(n,(C.TypeDecl,C.Typename)):return self.typ(n.type)
  if isinstance(n,C.IdentifierType):
   names=' '.join(n.names)
   if names in self.typedefs:return self.typedefs[names]
   if 'void' in n.names:return VOID
   if '_Bool' in n.names:return B
   if 'double' in n.names:return D
   if 'float' in n.names:return F
   unsigned='unsigned' in n.names
   if 'char' in n.names:return UC if unsigned else CH
   if 'long' in n.names:return UL if unsigned else L
   if 'short' in n.names:return T('int',names,2,2,not unsigned)
   return U if unsigned else I
  if isinstance(n,C.PtrDecl):return ptr(self.typ(n.type))
  if isinstance(n,C.ArrayDecl):
   b=self.typ(n.type);count=self.const(n.dim) if n.dim else 0
   return T('array',base=b,count=count,size=b.size*count,align=b.align)
  if isinstance(n,C.FuncDecl):
   args=[];va=False
   for p in (n.args.params if n.args else []):
    if isinstance(p,C.EllipsisParam):va=True
    else:
     t=self.typ(p.type)
     if t.kind!='void':args.append(t)
   return T('func',base=self.typ(n.type),params=args,varargs=va)
  if isinstance(n,(C.Struct,C.Union)):
   key=(type(n).__name__,n.name) if n.name else id(n)
   if key not in self.structs:self.structs[key]=T('struct' if isinstance(n,C.Struct) else 'union',n.name or 'anonymous-'+str(len(self.structs)))
   t=self.structs[key]
   if n.decls is not None and not t.defined:
    t.defined=True; bits=0;ma=1
    for d in n.decls:
     ft=self.typ(d.type); ma=max(ma,ft.align)
     if d.bitsize:
      width=self.const(d.bitsize)
      pos=0 if t.kind=='union' else bits
      unit=ft.size*8
      if (pos%unit)+width>unit:pos=align(pos,unit)
      off=pos//8;bit=pos%8
      t.fields[d.name]=(ft,off,bit,width)
      bits=max(bits,pos+width)
     else:
      off=0 if t.kind=='union' else align((bits+7)//8,ft.align)
      t.fields[d.name]=(ft,off,None,None);bits=max(bits,(off+ft.size)*8)
    t.align=ma;t.size=align((bits+7)//8,ma)
   return t
  if isinstance(n,C.Enum):
   value=0
   if n.values:
    for e in n.values.enumerators:
     if e.value:value=self.const(e.value)
     self.enums[e.name]=value;value+=1
   return I
  raise ValueError(('type',type(n),str(n)))
 def lookup(self,name):
  for scope in reversed(self.scope):
   if name in scope:return scope[name]
  if name in self.globals:return (*self.globals[name],False)
  raise ValueError(('unbound',name,self.current))
 def typeof(self,n):return self.typ(n) if isinstance(n,C.Typename) else self.expr(n)[1]
 def decay(self,t):return ptr(t.base) if t.kind=='array' else t
 def promote(self,t):return I if t.kind=='bool' or (t.kind=='int' and t.size<4) else t
 def common(self,a,b):
  a,b=self.promote(self.decay(a)),self.promote(self.decay(b))
  if a.kind=='ptr':return a
  if b.kind=='ptr':return b
  if a.kind=='float' or b.kind=='float':return D if a==D or b==D else F
  if a.size==b.size:return (a if not a.signed else b)
  big,small=(a,b) if a.size>b.size else (b,a)
  return big
 def conv(self,e,t,source=None):
  if t.kind in ('struct','union','array','void','func'):return e
  if t.kind=='ptr':return e
  if t.kind=='bool':return '(c-bool '+e+')'
  if t.kind=='float':
   if source and source.kind=='float' and source.size==t.size:return e
   if t.size==8 and source and source.kind=='int' and source.size==8:return '(integer64-double '+e+' '+('t' if source.signed else 'nil')+')'
   return '(float '+e+' '+('1d0' if t.size==8 else '1f0')+')'
  if source and source.kind=='float':return '(values (the '+self.ltype(t)+' (truncate '+e+')))'
  if source and source.kind=='ptr' and t.kind=='int' and t.signed and t.size==8:return e
  if source and source.kind in ('int','bool'):
   if t.kind=='int' and ((source.kind=='bool') or (source.signed==t.signed and source.size<=t.size) or (t.signed and source.size<t.size)):
    return e
  result=f'(c-{ "s" if t.signed else "u"}{t.size*8} {e})'
  return result
 def literal(self,n):
  v=n.value
  if n.type=='string':return CH,pyast.literal_eval(v)
  if n.type=='char':return I,ord(pyast.literal_eval(v))
  if n.type in ('float','double','long double'):
   return (F if v.lower().endswith('f') else D),float(v.rstrip('fFlL'))
  suffix=re.search('[uUlL]+$',v);s=suffix.group().lower() if suffix else '';v=v[:suffix.start()] if suffix else v
  val=int(v,16) if v.lower().startswith('0x') else int(v,8) if len(v)>1 and v.startswith('0') else int(v)
  t=(UL if 'u' in s else L) if 'l' in s else (U if 'u' in s else I)
  if val>2147483647 and not s:t=L
  return t,val
 def string(self,s):
  if s not in self.strings:self.strings[s]=sym('string/'+str(len(self.strings)))
  return self.strings[s]
 def load(self,addr,t,bit=None,width=None):
  if t.kind in ('struct','union','array'):return addr
  if bit is not None:return f'(ldb (byte {width} {bit}) (m-u{8 if bit+width<=8 else 16} {addr}))'
  if t.kind=='ptr':return f'(m-ptr {addr})'
  if t.kind=='bool':return f'(m-u8 {addr})'
  if t.name=='size_t':return f'(m-size {addr})'
  if t.kind=='float':return f'(m-f{t.size*8} {addr})'
  return f'(m-{ "s" if t.signed else "u"}{t.size*8} {addr})'
 def lval(self,n):
  if isinstance(n,C.ID):
   s,t,mem=self.lookup(n.name)
   return (s if not mem else None,s,t,None,None)
  if isinstance(n,C.ArrayRef):
   a,at=self.expr(n.name);b,bt=self.expr(n.subscript);at=self.decay(at)
   if at.kind!='ptr':a,b,at=b,a,self.decay(bt)
   t=at.base;return None,f'(+ {a} (* {t.size} {b}))',t,None,None
  if isinstance(n,C.UnaryOp) and n.op=='*':
   a,at=self.expr(n.expr);return None,a,self.decay(at).base,None,None
  if isinstance(n,C.StructRef):
   a,at=self.expr(n.name)
   if n.type=='->':at=at.base
   ft,off,bit,width=at.fields[n.field.name]
   return None,f'(+ {a} {off})',ft,bit,width
  raise ValueError(('lval',type(n),str(n)))
 def store(self,lv,e,source=None):
  s,addr,t,bit,width=lv
  if s:return f'(setf {s} {self.conv(e,t,source)})'
  if t.kind in ('struct','union'):return f'(copy-bytes {addr} {e} {t.size})'
  if bit is not None:return f'(set-bits {addr} {bit} {width} {self.conv(e,t,source)})'
  return f'(setf {self.load(addr,t)} {self.conv(e,t,source)})'
 def binop(self,op,a,at,b,bt):
  at=self.decay(at);bt=self.decay(bt)
  if op in ('&&','||'):
   return (f'(if (c-true {a}) (c-bool {b}) 0)' if op=='&&' else f'(if (c-true {a}) 1 (c-bool {b}))'),I
  if op in ('+','-') and (at.kind=='ptr' or bt.kind=='ptr'):
   if at.kind=='ptr' and bt.kind=='ptr':return f'(truncate (- {a} {b}) {at.base.size})',L
   if bt.kind=='ptr':a,b,at,bt=b,a,bt,at
   return f'({op} {a} (* {at.base.size} {b}))',at
  ct=self.common(at,bt)
  if op in ('<<','>>'):
   ct=self.promote(at);a=self.conv(a,ct)
   return self.conv(f'(ash {a} '+(b if op=='<<' else f'(- {b})')+')',ct),ct
  a=self.conv(a,ct,at);b=self.conv(b,ct,bt)
  if op in ('==','!=','<','>','<=','>='):
   name={'==':'=','!=':'/='}.get(op,op);return f'(if ({name} {a} {b}) 1 0)',I
  name={'&':'logand','|':'logior','^':'logxor','%':'rem','/':'/' if ct.kind=='float' else 'truncate'}.get(op,op)
  return self.conv(f'({name} {a} {b})',ct),ct
 def expr(self,n):
  if n is None:return '0',I
  if isinstance(n,C.ID):
   if n.name in self.enums:return str(self.enums[n.name]),I
   if n.name=='__func__':return self.string(self.current),ptr(CH)
   if n.name=='cl_varargs':return 'varargs',UL
   if n.name in self.functions and not any(n.name in scope for scope in self.scope):return "(function-handle #'"+sym(n.name)+")",ptr(self.functions[n.name])
   s,t,mem=self.lookup(n.name)
   return (self.load(s,t) if mem else s),t
  if isinstance(n,C.Constant):
   t,v=self.literal(n)
   if n.type=='string':return self.string(v),ptr(CH)
   if t.kind=='float':return repr(v).replace('e','d')+('d0' if 'e' not in repr(v) else ''),t
   return str(v),t
  if isinstance(n,(C.StructRef,C.ArrayRef)) or (isinstance(n,C.UnaryOp) and n.op=='*'):
   s,a,t,b,w=self.lval(n);return self.load(a,t,b,w),t
  if isinstance(n,C.UnaryOp):
   if n.op=='sizeof':return str(self.typeof(n.expr).size),UL
   if n.op=='&':
    s,a,t,_,_=self.lval(n.expr)
    if s:raise ValueError(('address of register',s))
    return a,ptr(t)
   if n.op in ('p++','p--','++','--'):
    lv=self.lval(n.expr);s,a,t,bit,w=lv
    # Capture address once, particularly for *p++.
    addr=self.fresh('a');old=self.fresh('old');body=lv if s else (None,addr,t,bit,w)
    read=s or self.load(addr,t,bit,w)
    e,_=self.binop('+' if '+' in n.op else '-',old,t,'1',I)
    code=f'(let* ({"" if s else f"({addr} {a})"} ({old} {read})) {self.store(body,e)} '+(old if n.op.startswith('p') else (s or self.load(addr,t,bit,w)))+')'
    return code,t
   a,t=self.expr(n.expr);t=self.promote(t)
   if n.op=='!':return f'(if (c-true {a}) 0 1)',I
   name={"-":"-","+":"+","~":"lognot"}[n.op]
   return self.conv(f'({name} {a})',t),t
  if isinstance(n,C.BinaryOp):
   if n.op in ('&&','||'):
    left=self.constant_condition(n.left)
    if left is not None:
     if (n.op=='||' and left) or (n.op=='&&' and not left):return ('1' if left else '0'),I
     e,t=self.expr(n.right);return '(c-bool '+e+')',I
   a,at=self.expr(n.left);b,bt=self.expr(n.right);return self.binop(n.op,a,at,b,bt)
  if isinstance(n,C.Assignment):
   lv=self.lval(n.lvalue);s,a,t,bit,w=lv;e,et=self.expr(n.rvalue)
   if n.op=='=':return self.store(lv,e,et),t
   addr=self.fresh('a');lv2=lv if s else (None,addr,t,bit,w)
   e,_=self.binop(n.op[:-1],s or self.load(addr,t,bit,w),t,e,et)
   return (self.store(lv2,e) if s else f'(let (({addr} {a})) {self.store(lv2,e)})'),t
  if isinstance(n,C.Cast):
   e,source=self.expr(n.expr);t=self.typ(n.to_type)
   if t.name=='size_t' and isinstance(n.expr,C.BinaryOp) and n.expr.op=='-' and self.decay(self.typeof(n.expr.left)).kind=='ptr' and self.decay(self.typeof(n.expr.right)).kind=='ptr':return '(the c-size '+e+')',t
   return self.conv(e,t,source),t
  if isinstance(n,C.TernaryOp):
   cond,_=self.expr(n.cond);a,at=self.expr(n.iftrue);b,bt=self.expr(n.iffalse);ct=self.common(at,bt)
   return f'(if (c-true {cond}) {self.conv(a,ct,at)} {self.conv(b,ct,bt)})',ct
  if isinstance(n,C.ExprList):
   es=[self.expr(e) for e in n.exprs];return '(progn '+' '.join(e[0] for e in es)+')',es[-1][1]
  if isinstance(n,C.FuncCall):
   if isinstance(n.name,C.ID) and n.name.name in self.functions and not any(n.name.name in scope for scope in self.scope):
    name=n.name.name
    if name not in self.functions:raise ValueError(('undeclared call',name))
    ft=self.functions[name];fun=sym(name) if name in self.defined_funcs else 'c-'+name
   else:
    fun,pt=self.expr(n.name);ft=pt.base;fun='funcall (the (function ('+' '.join(self.ltype(p) for p in ft.params)+') (values '+self.ltype(ft.base)+' &optional)) (function-from-handle '+fun+'))'
   args=[]
   for i,arg in enumerate(n.args.exprs if n.args else []):
    e,t=self.expr(arg);args.append(self.conv(e,ft.params[i],t) if i<len(ft.params) else e)
   code='('+fun+(' ' if args else '')+' '.join(args)+')'
   if isinstance(n.name,C.ID) and n.name.name=='message':
    code='(when (>= (m-u32 (+ '+args[0]+' '+str(self.structs[('Struct','satch')].fields['options'][1]+self.structs[('Struct','options')].fields['verbose'][1])+')) '+args[1]+') (locally (declare (optimize (speed 1) (safety 1))) '+code+'))'
   return code,ft.base
  raise ValueError(('expression',type(n),str(n)))
 def define(self,n,param=False):
  if not n.name:
   self.typ(n.type);return []
  t=self.typ(n.type);name=self.fresh('v-'+n.name+'-')
  mem=t.kind in ('array','struct','union') or n.name in self.addr_taken
  self.scope[-1][n.name]=(name,t,mem)
  if n.init and isinstance(n.type,C.TypeDecl) and 'const' in n.quals:
   try:self.constants[n.name]=self.const(n.init)
   except (ValueError,KeyError,TypeError):pass
  if 'static' in n.storage:raise ValueError('static local unsupported')
  self.locals.append((name,t,mem))
  forms=[]
  if mem:
   self.has_frame=True
   # Automatic storage has one reusable slot per declaration and call.
   # Loops must not allocate a fresh slot at every iteration.
  if param:forms.append(self.store((None,name,t,None,None),'arg-'+name) if mem else f'(setf {name} arg-{name})')
  elif n.init:forms+=self.initialize(name,t,n.init,mem)
  return forms
 def initialize(self,name,t,node,mem=True):
  if isinstance(node,C.InitList):
   forms=[f'(c-memset {name} 0 {t.size})'];idx=0
   for e in node.exprs:
    if isinstance(e,C.NamedInitializer):
     des=e.name;e=e.expr;ft=t;off=0;bit=width=None
     for d in des:
      if isinstance(d,C.ID):ft0,o,bit,width=ft.fields[d.name];off+=o;ft=ft0
      else:idx=self.const(d);off+=idx*ft.base.size;ft=ft.base
    elif t.kind=='array':ft=t.base;off=idx*ft.size;bit=width=None
    else:
     ft,off,bit,width=list(t.fields.values())[idx]
    a=f'(+ {name} {off})'
    if isinstance(e,C.InitList):forms+=self.initialize(a,ft,e)
    else:forms.append(self.store((None,a,ft,bit,width),*self.expr(e)))
    idx+=1
   return forms
  form=self.store((None,name,t,None,None) if mem else (name,name,t,None,None),*self.expr(node))
  if not mem and t.kind=='int' and t.size==8 and not t.signed and t.name!='size_t':
   form='(locally (declare (optimize (speed 1))) '+form+')'
  return [form]
 def stmt(self,n,br=None,co=None):
  if n is None:return []
  if isinstance(n,C.Compound):
   self.scope.append({});out=[]
   for x in n.block_items or []:out+=self.stmt(x,br,co)
   self.scope.pop();return out
  if isinstance(n,C.Decl):return self.define(n)
  if isinstance(n,C.DeclList):
   out=[]
   for x in n.decls:out+=self.define(x)
   return out
  if isinstance(n,C.If):
   constant=self.constant_condition(n.cond)
   if constant is not None:return self.stmt(n.iftrue if constant else n.iffalse,br,co)
   el=self.fresh('ELSE');en=self.fresh('ENDIF');e,_=self.expr(n.cond)
   return [f'(unless (c-true {e}) (go {el}))']+self.stmt(n.iftrue,br,co)+[f'(go {en})',el]+self.stmt(n.iffalse,br,co)+[en]
  if isinstance(n,(C.For,C.While,C.DoWhile)):
   self.scope.append({});start=self.fresh('LOOP');end=self.fresh('ENDLOOP');cont=self.fresh('CONTINUE');out=[]
   if isinstance(n,C.For):out+=self.stmt(n.init,br,co)
   out+=[start]
   if not isinstance(n,C.DoWhile) and n.cond is not None:out+=[f'(unless (c-true {self.expr(n.cond)[0]}) (go {end}))']
   out+=self.stmt(n.stmt,end,cont)+[cont]
   if isinstance(n,C.For) and n.next:out+=[self.expr(n.next)[0]]
   if isinstance(n,C.DoWhile):
    if self.constant_condition(n.cond) is not False:out+=[f'(when (c-true {self.expr(n.cond)[0]}) (go {start}))']
   else:out+=[f'(go {start})']
   out+=[end];self.scope.pop();return out
  if isinstance(n,C.Break):return [f'(go {br})']
  if isinstance(n,C.Continue):return [f'(go {co})']
  if isinstance(n,C.Return):return [f'(return-from {sym(self.current)} {self.conv(self.expr(n.expr)[0],self.ret,self.expr(n.expr)[1])})']
  if isinstance(n,C.Goto):return ['(go user-'+n.name+')']
  if isinstance(n,C.Label):return ['user-'+n.name]+self.stmt(n.stmt,br,co)
  if isinstance(n,C.Switch):
   end=self.fresh('ENDSWITCH');v=self.fresh('switch');self.locals.append((v,I,False));out=[f'(setf {v} {self.expr(n.cond)[0]})'];bodies=[];default=end
   for case in n.stmt.block_items:
    label=self.fresh('CASE')
    if isinstance(case,C.Default):default=label
    else:out+=[f'(when (= {v} {self.expr(case.expr)[0]}) (go {label}))']
    bodies+=[label]
    for item in case.stmts or []:bodies+=self.stmt(item,end,co)
   return out+[f'(go {default})']+bodies+[end]
  if isinstance(n,C.EmptyStatement):return []
  return ["(progn "+self.expr(n)[0]+")"]
 def ltype(self,t):
  if t.kind=='void':return '(integer 0 0)'
  if t.kind in ('struct','union','array','ptr'):return 'c-address'
  if t.kind=='bool':return '(integer 0 1)'
  if t.kind=='float':return 'double-float' if t.size==8 else 'single-float'
  if t.kind=='int':
   if t.name=='size_t':return 'c-size'
   return f'({"signed" if t.signed else "unsigned"}-byte {t.size*8})'
  raise ValueError(t)
 def constant_condition(self,node):
  try:return bool(self.const(node))
  except (ValueError,KeyError,TypeError,AttributeError):return None
 def prune_cfg(self,body):
  # Keep all reachable C operations, removing generated no-op jumps and blocks.
  body=[x for x in body if x not in ('(progn 0)','(progn 1)')]
  for _ in range(3):
   labels={x:i for i,x in enumerate(body) if not x.startswith('(')}
   reachable=set();pending=[0]
   while pending:
    i=pending.pop()
    if i in reachable or i>=len(body):continue
    reachable.add(i);x=body[i]
    if x.startswith('(return-from '):continue
    if re.fullmatch(r'\(go [^() ]+\)',x):pending.append(labels[x[4:-1]]);continue
    pending.append(i+1)
    for label in re.findall(r'\(go ([^() ]+)\)',x):pending.append(labels[label])
   body=[x for i,x in enumerate(body) if i in reachable]
   refs=set(re.findall(r'\(go ([^() ]+)\)',' '.join(body)))
   body=[x for x in body if x.startswith('(') or x in refs]
   for i in range(len(body)-1):
    if body[i]==f'(go {body[i+1]})':body[i]='(progn 0)'
   body=[x for x in body if x!='(progn 0)']
  return body
 def translate_function(self,f):
  self.current=f.decl.name;self.scope=[{}];self.locals=[];self.has_frame=False;self.constants={};self.ret=self.functions[self.current].base
  self.addr_taken=set()
  class A(C.NodeVisitor):
   def visit_UnaryOp(a,n):
    if n.op=='&' and isinstance(n.expr,C.ID):self.addr_taken.add(n.expr.name)
    a.generic_visit(n)
  A().visit(f.body)
  initial=[];params=[]
  for p in f.decl.type.args.params if f.decl.type.args else []:
   if isinstance(p,C.EllipsisParam):continue
   if self.typ(p.type).kind=='void':continue
   initial+=self.define(p,True);params.append('arg-'+self.locals[-1][0])
  argdecls=[]
  for name,t,mem in self.locals:
   argdecls.append('(type '+self.ltype(t)+' arg-'+name+')')
  body=self.prune_cfg(initial+self.stmt(f.body))
  if self.functions[self.current].varargs:params+=['&rest','varargs']
  binds=' '.join(f'({name} '+(f'(stack-alloc {t.size})' if mem else ('0d0' if t.kind=='float' else '0'))+')' for name,t,mem in self.locals)
  # Scalar variables remain native Lisp numbers; aggregates use frame-local storage.
  decls=[]
  for name,t,mem in self.locals:
   if name.startswith('v-ap-'):continue  # va_list is a Lisp argument list.
   if mem or t.kind=='ptr':lt='c-address'
   elif t.kind=='float':lt='double-float' if t.size==8 else 'single-float'
   elif t.kind=='bool':lt='(integer 0 1)'
   elif t.kind=='int':lt=self.ltype(t)
   else:continue
   decls.append(f'(type {lt} {name})')
  ds='(declare '+' '.join(decls)+' (ignorable '+ ' '.join(n for n,_,_ in self.locals)+'))' if self.locals else ''
  tag='(tagbody\n'+'\n'.join('    '+s for s in body)+'\n  )\n  0'
  block=f'(let ({binds})\n {ds}\n {tag})'
  if self.has_frame:block='(let ((frame *stack-top*)) (unwind-protect\n'+block+' (setf *stack-top* frame)))'
  coord=str(f.decl.coord).replace(str(ROOT)+'/', '')
  cold={'process_time','stop_profiling','flush_profiles','restart','fatal_error','out_of_memory','message','internal_section','current_resident_set_size','maximum_resident_set_size','print_profiles','print_statistics','print_resource_usage','report','invalid_usage','satch_statistics','satch_section','satch_process_time','satch_stop_profiling_parsing'}
  inline=({name for name,ft in self.functions.items() if ft.base.kind=='float' or (ft.base.kind=='int' and ft.base.size==8 and ft.base.name!='size_t')}|{'update_heap'})-cold-{'process_time','stop_profiling','flush_profiles'}
  policy='(optimize (speed 1) (safety 1))' if self.current in cold|inline else '(optimize (speed 1) (compilation-speed 3))' if self.current in {'sort_analyzed','sort_reduce_candidates','vivify_sort_lits_by_counts','sort_vivification_candidates','analyze_conflict'} else '(optimize (speed 3))' if self.current in {'propagate_literal','boolean_constraint_propagation','assign','backtrack'} else ''
  if self.current in {'analyze_conflict','sort_analyzed','sort_reduce_candidates','vivify_sort_lits_by_counts','sort_vivification_candidates','schedule_vivification_candidates','vivify_clause','vivify_learn','produces_few_resolvents','backward_subsume_marked','backward_subsume_with_clause'} or len(body)>450:
   policy+=' (notinline checked-address)'
  code=f';;; {coord}\n(defun {sym(self.current)} ({" ".join(params)})\n (declare {policy} {" ".join(argdecls)})\n {block})\n'
  self.mapping.append({'c_function':self.current,'lisp_function':sym(self.current),'source':str(f.decl.coord).replace(str(ROOT)+'/', ''),'frame':self.has_frame})
  return code
 def generate(self):
  self.defined_funcs={n.decl.name for n in self.tree.ext if isinstance(n,C.FuncDef)}
  code=[]
  for n in self.tree.ext:
   if isinstance(n,C.FuncDef):
    try:code.append(self.translate_function(n))
    except Exception as e:raise RuntimeError(f'{n.decl.name}: {e}') from e
  ftypes=[]
  for name in sorted(self.defined_funcs):
   ft=self.functions[name]; args=' '.join(self.ltype(p) for p in ft.params)+(' &rest t' if ft.varargs else '')
   ftypes.append(f'(declaim (ftype (function ({args}) (values {self.ltype(ft.base)} &optional)) {sym(name)}))')
  for name in self.defined_funcs:
   if (name=='update_heap' or self.functions[name].base.kind=='float' or (self.functions[name].base.kind=='int' and self.functions[name].base.size==8 and self.functions[name].base.name!='size_t')) and name not in {'process_time','stop_profiling','flush_profiles','print_profiles','satch_process_time','satch_stop_profiling_parsing'}:
    ftypes.insert(0,f'(declaim (inline {sym(name)}))')
  globals_=[]
  for n in self.tree.ext:
   if isinstance(n,C.Decl) and n.name in self.globals:
    name,t=self.globals[n.name]; globals_.append('(declaim (type '+self.ltype(t)+' '+name+'))\n(defparameter '+name+' '+self.conv(self.expr(n.init)[0],t,self.expr(n.init)[1])+')')
  strings=globals_+['(defparameter '+s+' (c-string '+ls(v)+'))' for v,s in self.strings.items()]
  return '(in-package #:ooparts/sat/impl)\n(declaim (sb-ext:unmuffle-conditions sb-ext:compiler-note))\n(declaim (optimize (speed 2) (safety 1) (debug 0) (compilation-speed 1)))\n'+ '\n'.join(ftypes+strings)+'\n\n'+'\n'.join(code)
 def verify_layouts(self):
  # Validate every named aggregate and recursively all anonymous subaggregates,
  # including actual GCC bitfield storage masks, against the native ABI.
  lines=['#define NDEBUG 1','#include "../upstream/satch.c"','#include <stddef.h>','int main(void) {'];checks=[]
  def visit(t,root,path='',offset=0):
   expr='x'+path
   for name,(ft,off,bit,width) in t.fields.items():
    p=path+'.'+name;e='x'+p;label=root+p
    if bit is not None:
     lines.extend(['{ __typeof__(x) y; memset(&y,0,sizeof y); y'+p+' = -1;', 'unsigned char *p=(unsigned char*)&y; for(size_t i=0;i<sizeof y;i++) if(p[i]) printf("BIT '+label+' %zu %u\\n",i,(unsigned)p[i]); }'])
     masks={};start=(offset+off)*8+bit
     for k in range(width):masks[(start+k)//8]=masks.get((start+k)//8,0)|(1<<((start+k)%8))
     for b,m in masks.items():checks.append(f'BIT {label} {b} {m}')
    else:
     lines.append(f'printf("FIELD {label} %zu %zu\\n",(size_t)((char*)&{e}-(char*)&x),sizeof {e});')
     checks.append(f'FIELD {label} {offset+off} {ft.size}')
     if ft.kind in ('struct','union'):visit(ft,root,p,offset+off)
  for (key,t) in self.structs.items():
   if isinstance(key,tuple) and t.defined:
    spec=('struct ' if t.kind=='struct' else 'union ')+t.name
    lines+=['{ '+spec+' x;',f'printf("SIZE {spec} %zu\\n",sizeof x);'];checks.append(f'SIZE {spec} {t.size}');visit(t,spec);lines+=['}']
  lines+=['return 0;}'];p=ROOT/'tools/layout-probe.c';p.write_text('\n'.join(lines))
  subprocess.run(['gcc','-w',str(p),'-lm','-o',str(ROOT/'tools/layout-probe')],check=True)
  output=subprocess.check_output([str(ROOT/'tools/layout-probe')],text=True).splitlines()
  if output!=checks:
   import difflib
   raise ValueError('ABI layout mismatch\n'+'\n'.join(difflib.unified_diff(checks,output)))
  (ROOT/'tools/layouts.txt').write_text('\n'.join(output)+'\n')
  return len(checks)
if __name__=='__main__':
 subprocess.run(['gcc','-E','-nostdinc','-Ifake-include','-DNDEBUG','upstream/satch.c','-o','tools/satch.i'],cwd=ROOT,check=True)
 tree=c_parser.CParser().parse((ROOT/'tools/satch.i').read_text())
 tr=Translator(tree)
 text=tr.generate()
 checks=tr.verify_layouts()
 (ROOT/'src/translated.lisp').write_text(';;; Generated by tools/translate.py; do not edit.\n;;; SATCH b4d4081f8971931399b36c8fdd92bdf4aabac005, -DNDEBUG.\n'+text)
 parts=re.split(r'(?=;;; upstream/satch.c:)',text)
 generated=ROOT/'src/generated';generated.mkdir(exist_ok=True)
 (generated/'prefix.lisp').write_text(parts[0])
 names=[]
 for i in range(0,len(parts)-1,20):
  name=f'part-{i//20:02d}'
  (generated/(name+'.lisp')).write_text('\n'.join(parts[0].splitlines()[:3])+'\n'+''.join(parts[i+1:i+21]))
  names.append(name)
 (ROOT/'tools/parts.json').write_text(json.dumps(names)+'\n')

 (ROOT/'tools/function-map.json').write_text(json.dumps(tr.mapping,indent=2)+'\n')
 print(f'Translated {len(tr.mapping)} functions; verified {checks} ABI layout facts.')
