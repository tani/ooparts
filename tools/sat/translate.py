#!/usr/bin/env python3
"""Translate the pinned SATCH production configuration to SBCL Common Lisp.
Not a general C compiler. Unsupported syntax raises an exception (never omitted).
Uses GCC only for preprocessing and independent ABI layout verification.
"""
from pathlib import Path
from dataclasses import dataclass,field
import ast as pyast,json,re,subprocess,collections,os
from pycparser import c_parser,c_ast as C
ROOT=Path(__file__).resolve().parents[2]
TOOLS=ROOT/'tools/sat'
GENERATED=ROOT/'build/sat/generator'
SOURCE=ROOT/'vendor/satch/source'
LIBRARY=ROOT/'src/sat'
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
FUNCTION_NAMES={'NOT':'negate-literal', 'LITERAL':'variable-literal',
 'INDEX':'literal-variable', 'SIGN_BIT':'literal-sign-bit', 'INT_SIGN':'integer-sign',
 'restart':'restart-search', 'reduce':'reduce-database', 'assignement_level':'assignment-level'}
def lisp_name(n):
 return n.lower().replace('_','-').replace('/','-')
def sym(n):
 if n.startswith('global/'):return '*'+lisp_name(n.split('/',1)[1])+'*'
 if n.startswith('string/'):return '*text-'+n.split('/')[1]+'*'
 return FUNCTION_NAMES.get(n,lisp_name(n))
def ls(s):return '"'+s.replace('\\','\\\\').replace('"','\\"')+'"'
def align(n,a):return (n+a-1)//a*a
@dataclass
class Place:
 local:object
 address:str
 type:object
 bit:object=None
 width:object=None
 expression:object=None
 def __iter__(self):return iter((self.local,self.address,self.type,self.bit,self.width))
class Translator:
 def __init__(self,tree):
  self.tree=tree; self.typedefs={'size_t':UL,'uint64_t':UL,'uintptr_t':UL,'ptrdiff_t':L,'bool':B,'FILE':VOID,'va_list':UL,'uint32_t':U,'uint8_t':UC}; self.structs={}; self.node_types={}; self.functions={}; self.globals={}; self.enums={}; self.strings={}; self.mapping=[]; self.layouts=[]; self.serial=0
  self.scope=[{}]; self.locals=[]; self.addr_taken=set(); self.allocs=[]; self.static=[]; self.constants={}; self.has_frame=False
  self.field_accessors={}
  for n in tree.ext:
   if isinstance(n,C.Typedef):self.typedefs[n.name]=T('int','size_t',8,8) if n.name=='size_t' else self.typ(n.type)
   elif isinstance(n,C.FuncDef):self.functions[n.decl.name]=self.typ(n.decl.type)
   elif isinstance(n,C.Decl):
    t=self.typ(n.type)
    if n.name and t.kind=='func':self.functions[n.name]=t
    elif n.name:self.globals[n.name]=(sym('global/'+n.name),t)
  # Anonymous C aggregates take the name of their owning field, rather than
  # leaking parser allocation order into the generated Lisp interface.
  def name_fields(t):
   for field,(ft,_,_,_) in t.fields.items():
    while ft.kind=='array':ft=ft.base
    if ft.kind not in ('struct','union'):continue
    if ft.name.startswith('anonymous-'):
     ft.name=('solver' if t.name=='satch' else t.name)+'-'+lisp_name(field)
    name_fields(ft)
  for key,t in self.structs.items():
   if isinstance(key,tuple) and t.defined:name_fields(t)
 def fresh(self,p='v'):
  self.serial+=1
  p={'a':'address','old':'previous-value','ELSE':'else','ENDIF':'end-if',
     'LOOP':'loop-start','ENDLOOP':'loop-end','CONTINUE':'next-iteration',
     'ENDSWITCH':'switch-end','CASE':'case','switch':'switch-value'}.get(p,p.lower())
  return self.local_name(p+'-'+str(self.serial))
 def local_name(self,name):
  name=lisp_name(name)
  if name in {'t','nil','pi'}:name='input-'+name
  count=self.name_counts.get(name,0)+1;self.name_counts[name]=count
  return name if count==1 else name+'-'+str(count)
 def field(self,n):
  base,owner=self.expr(n.name)
  if n.type=='->':owner=owner.base
  ft,offset,bit,width=owner.fields[n.field.name]
  prefix='solver' if owner.name=='satch' else lisp_name(owner.name)
  name=prefix+'-'+lisp_name(n.field.name)
  if name in {sym(function) for function in self.defined_funcs}:name+='-slot'
  self.field_accessors[name]=(ft,offset,bit,width)
  return name,base,ft,offset,bit,width
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
  literal=int(e) if re.fullmatch(r'-?\d+',e) else None
  if t.kind=='bool':
   if source and source.kind=='bool':return e
   if re.fullmatch(r'\(if [\s\S]* (?:1 0|0 1)\)',e):return e
   return str(int(bool(literal))) if literal is not None else '(c-bool '+e+')'
  if t.kind=='float':
   if source and source.kind=='float' and source.size==t.size:return e
   if t.size==8 and source and source.kind=='int' and source.size==8:return '(integer64-double '+e+' '+('t' if source.signed else 'nil')+')'
   return '(float '+e+' '+('1d0' if t.size==8 else '1f0')+')'
  if source and source.kind=='float':return '(values (the '+self.ltype(t)+' (truncate '+e+')))'
  if source and source.kind=='ptr' and t.kind=='int' and t.signed and t.size==8:return e
  if literal is not None:
   value=literal%(1<<(t.size*8))
   if t.signed and value>=(1<<(t.size*8-1)):value-=1<<(t.size*8)
   return str(value)
  if source and source.kind in ('int','bool'):
   if t.kind=='int' and ((source.kind=='bool') or (source.signed==t.signed and source.size<=t.size) or (t.signed and source.size<t.size)):
    return e
  conversion=f'c-{"s" if t.signed else "u"}{t.size*8}'
  if e.startswith('('+conversion+' '):return e
  result=f'({conversion} {e})'
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
   t=at.base;index=b if t.size==1 else f'(* {t.size} {b})'
   return None,f'(+ {a} {index})',t,None,None
  if isinstance(n,C.UnaryOp) and n.op=='*':
   a,at=self.expr(n.expr);return None,a,self.decay(at).base,None,None
  if isinstance(n,C.StructRef):
   name,base,ft,off,bit,width=self.field(n)
   return Place(None,f'({name}-address {base})',ft,bit,width,f'({name} {base})')
  raise ValueError(('lval',type(n),str(n)))
 def store(self,lv,e,source=None):
  s,addr,t,bit,width=lv
  if s:return f'(setf {s} {self.conv(e,t,source)})'
  if t.kind in ('struct','union'):return f'(copy-bytes {addr} {e} {t.size})'
  if getattr(lv,'expression',None):return f'(setf {lv.expression} {self.conv(e,t,source)})'
  if bit is not None:return f'(set-bits {addr} {bit} {width} {self.conv(e,t,source)})'
  return f'(setf {self.load(addr,t)} {self.conv(e,t,source)})'
 def binop(self,op,a,at,b,bt):
  at=self.decay(at);bt=self.decay(bt)
  if op in ('&&','||'):
   return (f'(if (c-true {a}) (c-bool {b}) 0)' if op=='&&' else f'(if (c-true {a}) 1 (c-bool {b}))'),I
  if op in ('+','-') and (at.kind=='ptr' or bt.kind=='ptr'):
   if at.kind=='ptr' and bt.kind=='ptr':return f'(truncate (- {a} {b}) {at.base.size})',L
   if bt.kind=='ptr':a,b,at,bt=b,a,bt,at
   scaled=str(at.base.size*int(b)) if re.fullmatch(r'-?\d+',b) else b if at.base.size==1 else f'(* {at.base.size} {b})'
   return f'({op} {a} {scaled})',at
  ct=self.common(at,bt)
  if op in ('<<','>>'):
   ct=self.promote(at);a=self.conv(a,ct,at)
   return self.conv(f'(ash {a} '+(b if op=='<<' else f'(- {b})')+')',ct),ct
  a=self.conv(a,ct,at);b=self.conv(b,ct,bt)
  if op in ('==','!=','<','>','<=','>='):
   name={'==':'=','!=':'/='}.get(op,op);return f'(if ({name} {a} {b}) 1 0)',I
  name={'&':'logand','|':'logior','^':'logxor','%':'rem','/':'/' if ct.kind=='float' else 'truncate'}.get(op,op)
  if op in ('&','|','^'):return f'({name} {a} {b})',ct
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
   lv=self.lval(n);s,a,t,b,w=lv
   return (getattr(lv,'expression',None) or self.load(a,t,b,w)),t
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
    if isinstance(n.expr,C.StructRef):
     name,base,_,_,_,_=self.field(n.expr)
     a=base;body=Place(None,addr,t,bit,w,f'({name} {addr})')
    read=s or (getattr(body,'expression',None) or self.load(addr,t,bit,w))
    e,_=self.binop('+' if '+' in n.op else '-',old,t,'1',I)
    code=f'(let* ({"" if s else f"({addr} {a})"} ({old} {read})) {self.store(body,e)} '+(old if n.op.startswith('p') else (s or getattr(body,'expression',None) or self.load(addr,t,bit,w)))+')'
    return code,t
   if n.op in ('+','-','~','!') and isinstance(n.expr,C.Constant):
    t,value=self.literal(n.expr);t=self.promote(t)
    if t.kind=='int':
     value={'+':lambda:value,'-':lambda:-value,'~':lambda:~value,'!':lambda:int(not value)}[n.op]()
     return self.conv(str(value),I if n.op=='!' else t),I if n.op=='!' else t
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
    return '(if '+self.condition(n)+' 1 0)',I
   a,at=self.expr(n.left);b,bt=self.expr(n.right);return self.binop(n.op,a,at,b,bt)
  if isinstance(n,C.Assignment):
   lv=self.lval(n.lvalue);s,a,t,bit,w=lv;e,et=self.expr(n.rvalue)
   if n.op=='=':return self.store(lv,e,et),t
   addr=self.fresh('a');lv2=lv if s else (None,addr,t,bit,w)
   if isinstance(n.lvalue,C.StructRef):
    name,base,_,_,_,_=self.field(n.lvalue)
    a=base;lv2=Place(None,addr,t,bit,w,f'({name} {addr})')
   e,_=self.binop(n.op[:-1],s or getattr(lv2,'expression',None) or self.load(addr,t,bit,w),t,e,et)
   return (self.store(lv2,e) if s else f'(let (({addr} {a})) {self.store(lv2,e)})'),t
  if isinstance(n,C.Cast):
   e,source=self.expr(n.expr);t=self.typ(n.to_type)
   if t.name=='size_t' and isinstance(n.expr,C.BinaryOp) and n.expr.op=='-' and self.decay(self.typeof(n.expr.left)).kind=='ptr' and self.decay(self.typeof(n.expr.right)).kind=='ptr':return '(the c-size '+e+')',t
   return self.conv(e,t,source),t
  if isinstance(n,C.TernaryOp):
   condition=self.condition(n.cond);a,at=self.expr(n.iftrue);b,bt=self.expr(n.iffalse);ct=self.common(at,bt)
   return f'(if {condition} {self.conv(a,ct,at)} {self.conv(b,ct,bt)})',ct
  if isinstance(n,C.ExprList):
   nodes=[e for e in n.exprs[:-1] if not (isinstance(e,(C.ID,C.Constant)) or (isinstance(e,C.Cast) and self.typ(e.to_type).kind=='void' and isinstance(e.expr,(C.ID,C.Constant))))]+n.exprs[-1:]
   es=[self.expr(e) for e in nodes]
   return (es[0][0] if len(es)==1 else '(progn '+' '.join(e[0] for e in es)+')'),es[-1][1]
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
  t=self.typ(n.type);name=self.local_name(n.name)
  mem=t.kind in ('array','struct','union') or n.name in self.addr_taken
  self.scope[-1][n.name]=(name,t,mem)
  if n.init and isinstance(n.type,C.TypeDecl) and 'const' in n.quals:
   try:self.constants[n.name]=self.const(n.init)
   except (ValueError,KeyError,TypeError):pass
  if 'static' in n.storage:raise ValueError('static local unsupported')
  self.locals.append((name,t,mem))
  if t.kind=='int' and t.size==8 and not t.signed and t.name!='size_t' and n.name in self.boundary_names:
   self.boxed_locals.add(name)
  forms=[]
  if mem:
   self.has_frame=True
   # Automatic storage has one reusable slot per declaration and call.
   # Loops must not allocate a fresh slot at every iteration.
  if param:
   self.parameter_names.add(name)
   if mem:forms.append(self.store((None,name,t,None,None),'input-'+name))
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
 def condition(self,n):
  constant=self.constant_condition(n)
  if constant is not None:return 't' if constant else 'nil'
  if isinstance(n,C.BinaryOp) and n.op in ('&&','||'):
   left=self.constant_condition(n.left)
   if left is not None:
    if (n.op=='&&' and not left) or (n.op=='||' and left):return 't' if left else 'nil'
    return self.condition(n.right)
   return '('+('and' if n.op=='&&' else 'or')+' '+self.condition(n.left)+' '+self.condition(n.right)+')'
  if isinstance(n,C.UnaryOp) and n.op=='!':
   condition=self.condition(n.expr)
   return condition[5:-1] if condition.startswith('(not ') else '(not '+condition+')'
  expression,_=self.expr(n)
  match=re.fullmatch(r'\(if (\([\s\S]*\)) 1 0\)',expression)
  return match.group(1) if match else '(not (zerop '+expression+'))'
 def contains(self,n,types):
  if n is None:return False
  return isinstance(n,types) or any(self.contains(child,types) for _,child in n.children())
 def effectful(self,n):
  if n is None:return False
  if isinstance(n,(C.Assignment,C.FuncCall)):return True
  if isinstance(n,C.UnaryOp) and n.op in ('p++','p--','++','--'):return True
  return any(self.effectful(child) for _,child in n.children())
 def terminal(self,n):
  if n is None:return False
  if isinstance(n,(C.Return,C.Goto,C.Break,C.Continue)):return True
  if isinstance(n,C.Compound):return bool(n.block_items) and self.terminal(n.block_items[-1])
  if isinstance(n,C.If):
   constant=self.constant_condition(n.cond)
   if constant is not None:return self.terminal(n.iftrue if constant else n.iffalse)
   return n.iffalse is not None and self.terminal(n.iftrue) and self.terminal(n.iffalse)
  return False
 def progn(self,forms):
  if not forms:return 'nil'
  if len(forms)==1:return forms[0]
  return '(progn '+' '.join(forms)+')'
 def local_binding(self,name,t,forms):
  if not forms:return '0d0' if t.kind=='float' else '0'
  prefix='(setf '+name+' '
  if len(forms)==1 and forms[0].startswith(prefix):return forms[0][len(prefix):-1]
  prefix='(locally (declare (optimize (speed 1))) (setf '+name+' '
  if len(forms)==1 and forms[0].startswith(prefix):
   return '(locally (declare (optimize (speed 1))) '+forms[0][len(prefix):-2]+')'
  raise ValueError(('non-scalar initializer',name,forms))
 def bind_lexically(self,bindings,body):
  if not bindings:return body
  declarations=['(type '+self.ltype(t)+' '+name+')' for name,t,_ in bindings if name!='ap']
  declarations+=['(ignorable '+' '.join(name for name,_,_ in bindings)+')']
  boxed=any(name in self.boxed_locals for name,_,_ in bindings)
  if boxed:body=f'(locally (declare (optimize (speed {self.speed}))) '+body+')'
  form='(let* ('+' '.join('('+name+' '+value+')' for name,_,value in bindings)+') (declare '+' '.join(declarations)+') '+body+')'
  # Only the binding/boxing boundary uses the general Lisp value policy. The
  # numerical body immediately restores this function's original speed policy.
  return '(locally (declare (optimize (speed 1))) '+form+')' if boxed else form
 def lexical_sequence(self,items,br,co,tail):
  if not items:return []
  bindings=[];position=0
  while position<len(items) and isinstance(items[position],C.Decl):
   declaration=items[position];forms=self.define(declaration);position+=1
   if not declaration.name:continue
   name,t,mem=self.locals[-1]
   if mem:
    remainder=forms+self.lexical_sequence(items[position:],br,co,tail)
    return [self.bind_lexically(bindings,self.progn(remainder))] if bindings else remainder
   self.lexical_locals.add(name)
   bindings.append((name,t,self.local_binding(name,t,forms)))
  if bindings:
   return [self.bind_lexically(bindings,self.progn(self.lexical_sequence(items[position:],br,co,tail)))]
  if position:return self.lexical_sequence(items[position:],br,co,tail)
  first=items[0];forms=self.stmt(first,br,co,tail and len(items)==1)
  return forms if self.terminal(first) else forms+self.lexical_sequence(items[1:],br,co,tail)
 def stmt(self,n,br=None,co=None,tail=False):
  if n is None:return []
  if isinstance(n,C.Compound):
   self.scope.append({});out=[]
   items=n.block_items or []
   if self.structured:
    out=self.lexical_sequence(items,br,co,tail);self.scope.pop();return out
   leading=n is self.root_body
   for i,x in enumerate(items):
    forms=self.stmt(x,br,co,tail and i==len(items)-1);out+=forms
    if leading and isinstance(x,C.Decl):
     if x.name:self.leading.append((self.locals[-1][0],bool(x.init),self.locals[-1][2]))
    else:leading=False
    if self.structured and self.terminal(x):break
   self.scope.pop();return out
  if isinstance(n,C.Decl):return self.define(n)
  if isinstance(n,C.DeclList):
   out=[]
   for x in n.decls:out+=self.define(x)
   return out
  if isinstance(n,C.If):
   constant=self.constant_condition(n.cond)
   if constant is not None:return self.stmt(n.iftrue if constant else n.iffalse,br,co,tail)
   if self.structured:
    condition=self.condition(n.cond)
    yes=self.stmt(n.iftrue,br,co,tail);no=self.stmt(n.iffalse,br,co,tail)
    if not yes and not no:
     return [condition] if self.effectful(n.cond) else []
    if not no:return ['(when '+condition+' '+self.progn(yes)+')']
    if not yes:return ['(unless '+condition+' '+self.progn(no)+')']
    return ['(if '+condition+' '+self.progn(yes)+' '+self.progn(no)+')']
   el=self.fresh('ELSE');en=self.fresh('ENDIF');e,_=self.expr(n.cond)
   return [f'(unless (c-true {e}) (go {el}))']+self.stmt(n.iftrue,br,co)+[f'(go {en})',el]+self.stmt(n.iffalse,br,co)+[en]
  if isinstance(n,(C.For,C.While,C.DoWhile)):
   if self.structured:
    self.scope.append({});end=self.fresh('loop-end');cont=self.fresh('next-iteration')
    before=len(self.locals)
    initial=self.stmt(n.init,br,co) if isinstance(n,C.For) else []
    bindings=[]
    if len(self.locals)>before and all(not mem for _,_,mem in self.locals[before:]):
     declarations=self.locals[before:]
     if len(initial)==len(declarations):
      for (name,t,_),form in zip(declarations,initial):
       self.lexical_locals.add(name);bindings.append((name,t,self.local_binding(name,t,[form])))
      initial=[]
    constant=True if n.cond is None else self.constant_condition(n.cond)
    if constant is False and not isinstance(n,C.DoWhile):
     self.scope.pop();return [self.bind_lexically(bindings,self.progn(initial))] if bindings else initial
    condition='t' if n.cond is None else self.condition(n.cond)
    body=self.stmt(n.stmt,'(return-from '+end+' nil)','(return-from '+cont+' nil)')
    if self.contains(n.stmt,C.Continue):body=['(block '+cont+' '+self.progn(body)+')']
    update=self.stmt(n.next,br,co) if isinstance(n,C.For) and n.next else []
    if isinstance(n,C.DoWhile) and constant is False:
     if not body:self.scope.pop();return initial
     iteration=self.progn(body)
    else:
     iteration='(loop'+(' while '+condition if not isinstance(n,C.DoWhile) and condition!='t' else '')
     if body:iteration+=' do '+self.progn(body)
     if update:iteration+=' do '+self.progn(update)
     if isinstance(n,C.DoWhile) and condition!='t':iteration+=' while '+condition
     iteration+=')'
    if self.contains(n.stmt,C.Break):iteration='(block '+end+' '+iteration+')'
    self.scope.pop();return [self.bind_lexically(bindings,self.progn(initial+[iteration]))]
   self.scope.append({});start=self.fresh('LOOP');end=self.fresh('ENDLOOP');cont=self.fresh('CONTINUE');out=[]
   if isinstance(n,C.For):out+=self.stmt(n.init,br,co)
   out+=[start]
   if not isinstance(n,C.DoWhile) and n.cond is not None:out+=[f'(unless (c-true {self.expr(n.cond)[0]}) (go {end}))']
   out+=self.stmt(n.stmt,f'(go {end})',f'(go {cont})')+[cont]
   if isinstance(n,C.For) and n.next:out+=[self.expr(n.next)[0]]
   if isinstance(n,C.DoWhile):
    if self.constant_condition(n.cond) is not False:out+=[f'(when (c-true {self.expr(n.cond)[0]}) (go {start}))']
   else:out+=[f'(go {start})']
   out+=[end];self.scope.pop();return out
  if isinstance(n,C.Break):return [br]
  if isinstance(n,C.Continue):return [co]
  if isinstance(n,C.Return):
   expression,source=self.expr(n.expr);expression=self.conv(expression,self.ret,source)
   return [expression if tail else f'(return-from {sym(self.current)} {expression})']
  if isinstance(n,C.Goto):return ['(go user-'+n.name+')']
  if isinstance(n,C.Label):return ['user-'+n.name]+self.stmt(n.stmt,br,co)
  if isinstance(n,C.Switch):
   end=self.fresh('ENDSWITCH');v=self.fresh('switch');self.locals.append((v,I,False));out=[f'(setf {v} {self.expr(n.cond)[0]})'];bodies=[];default=end
   for case in n.stmt.block_items:
    label=self.fresh('CASE')
    if isinstance(case,C.Default):default=label
    else:out+=[f'(when (= {v} {self.expr(case.expr)[0]}) (go {label}))']
    bodies+=[label]
    for item in case.stmts or []:bodies+=self.stmt(item,f'(go {end})',co)
   return out+[f'(go {default})']+bodies+[end]
  if isinstance(n,C.EmptyStatement):return []
  if isinstance(n,C.UnaryOp) and n.op in ('p++','p--','++','--'):
   lv=self.lval(n.expr);local,address,t,bit,width=lv
   place=local or getattr(lv,'expression',None) or self.load(address,t,bit,width)
   if t.kind=='ptr':return [f'({"incf" if "+" in n.op else "decf"} {place} {t.base.size})']
   if t.kind=='int':return [f'({"s" if t.signed else "u"}{t.size*8}-incf {place}'+(' -1' if '-' in n.op else '')+')']
  if isinstance(n,C.Assignment) and n.op in ('+=','-='):
   lv=self.lval(n.lvalue);local,address,t,bit,width=lv
   value,source=self.expr(n.rvalue)
   place=local or getattr(lv,'expression',None) or self.load(address,t,bit,width)
   if t.kind=='ptr':
    delta=value if t.base.size==1 else f'(* {t.base.size} {value})'
    return [f'({"incf" if n.op=="+=" else "decf"} {place} {delta})']
   if t.kind=='int' and source.kind in ('int','bool'):
    return [f'({"s" if t.signed else "u"}{t.size*8}-incf {place} '+(f'(- {value})' if n.op=='-=' else value)+')']
  if isinstance(n,(C.ID,C.Constant)):return []
  if isinstance(n,C.Cast) and self.typ(n.to_type).kind=='void' and isinstance(n.expr,(C.ID,C.Constant)):return []
  return [self.expr(n)[0]]
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
  self.name_counts={};self.serial=0;self.parameter_names=set();self.lexical_locals=set();self.leading=[];self.root_body=f.body
  cold={'process_time','stop_profiling','flush_profiles','restart','fatal_error','out_of_memory','message','internal_section','current_resident_set_size','maximum_resident_set_size','print_profiles','print_statistics','print_resource_usage','report','invalid_usage','satch_statistics','satch_section','satch_process_time','satch_stop_profiling_parsing'}
  inline=({name for name,ft in self.functions.items() if ft.base.kind=='float' or (ft.base.kind=='int' and ft.base.size==8 and ft.base.name!='size_t')}|{'update_heap'})-cold-{'process_time','stop_profiling','flush_profiles'}
  policy='(optimize (speed 1) (safety 1))' if self.current in cold|inline else '(optimize (speed 1) (compilation-speed 3))' if self.current in {'sort_analyzed','sort_reduce_candidates','vivify_sort_lits_by_counts','sort_vivification_candidates','analyze_conflict'} else '(optimize (speed 3))' if self.current in {'propagate_literal','boolean_constraint_propagation','assign','backtrack'} else ''
  self.speed=3 if '(speed 3)' in policy else 1 if '(speed 1)' in policy else 2
  self.boxed_locals=set();self.boundary_names=set()
  class BoundaryReferences(C.NodeVisitor):
   def visit_FuncCall(visitor,node):
    class Names(C.NodeVisitor):
     def visit_ID(inner,ident):self.boundary_names.add(ident.name)
     def visit_StructRef(inner,reference):inner.visit(reference.name)
    if node.args:Names().visit(node.args)
    visitor.generic_visit(node)
  BoundaryReferences().visit(f.body)
  self.structured=not self.contains(f.body,(C.Goto,C.Label,C.Switch))
  self.addr_taken=set()
  class AddressTaken(C.NodeVisitor):
   def visit_UnaryOp(visitor,node):
    if node.op=='&' and isinstance(node.expr,C.ID):self.addr_taken.add(node.expr.name)
    visitor.generic_visit(node)
  AddressTaken().visit(f.body)
  initial=[];params=[];argdecls=[]
  for p in f.decl.type.args.params if f.decl.type.args else []:
   if isinstance(p,C.EllipsisParam) or self.typ(p.type).kind=='void':continue
   initial+=self.define(p,True)
   name,t,mem=self.locals[-1];argument='input-'+name if mem else name
   params.append(argument);argdecls.append('(type '+self.ltype(t)+' '+argument+')')
  tail=self.structured and self.terminal(f.body)
  body=initial+self.stmt(f.body,tail=tail)
  if not self.structured:body=self.prune_cfg(body)
  if self.functions[self.current].varargs:params+=['&rest','varargs']
  promoted={}
  if self.structured:
   for name,initialized,mem in self.leading:
    if not initialized:continue
    prefix='(setf '+name+' '
    if mem or not body or not body[0].startswith(prefix):break
    expression=body[0][len(prefix):-1]
    if re.search(r'(?<![\w*-])'+re.escape(name)+r'(?![\w*-])',expression):break
    promoted[name]=expression;body.pop(0)
  locals_=[(name,t,mem) for name,t,mem in self.locals if mem or (name not in self.parameter_names and name not in self.lexical_locals)]
  memory=[(name,t,mem) for name,t,mem in locals_ if mem]
  scalars=[(name,t,mem) for name,t,mem in locals_ if not mem]
  # Parameters are already lexical variables. Leading declarations become LET*
  # bindings; only C control-flow spanning declarations needs initial placeholders.
  bindings=' '.join('('+name+' '+promoted.get(name,'0d0' if t.kind=='float' else '0')+')' for name,t,mem in scalars)
  declarations=[]
  for name,t,mem in scalars:
   if name=='ap':continue
   declarations.append('(type '+('c-address' if mem else self.ltype(t))+' '+name+')')
  if scalars:declarations.append('(ignorable '+' '.join(name for name,_,_ in scalars)+')')
  declaration='(declare '+' '.join(declarations)+')' if declarations else ''
  if self.structured:
   forms=body+([] if tail else ['0'])
   block=self.progn(forms)
  else:block='(tagbody\n'+'\n'.join('    '+form for form in body)+'\n)\n0'
  if scalars or declarations:block='(let* ('+bindings+')\n '+declaration+'\n '+block+')'
  elif not self.structured:block='(progn '+block+')'
  if memory:
   declarations='(declare '+' '.join('(type c-address '+name+')' for name,_,_ in memory)+' (ignorable '+' '.join(name for name,_,_ in memory)+'))'
   block='(let* ('+' '.join('('+name+' (stack-alloc '+str(t.size)+'))' for name,t,_ in memory)+') '+declarations+' '+block+')'
  if self.has_frame:
   mark=self.local_name('stack-mark')
   block='(let (('+mark+' *stack-top*)) (unwind-protect '+block+' (setf *stack-top* '+mark+')))'
  coord=str(f.decl.coord).replace(str(ROOT)+'/', '')
  if self.current in {'analyze_conflict','sort_analyzed','sort_reduce_candidates','vivify_sort_lits_by_counts','sort_vivification_candidates','schedule_vivification_candidates','vivify_clause','vivify_learn','produces_few_resolvents','backward_subsume_marked','backward_subsume_with_clause'} or len(body)>450:
   policy+=' (notinline checked-address)'
  declarations=([policy] if policy else [])+argdecls
  if params:declarations.append('(ignorable '+' '.join(p for p in params if p!='&rest')+')')
  declaration='(declare '+' '.join(declarations)+')' if declarations else ''
  code=f';;; {coord}\n(defun {sym(self.current)} ({" ".join(params)})\n {declaration}\n {block})\n'
  self.mapping.append({'c_function':self.current,'lisp_function':sym(self.current),'source':coord,'frame':self.has_frame,'structured':self.structured})
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
  for name in sorted(self.defined_funcs):
   if (name=='update_heap' or self.functions[name].base.kind=='float' or (self.functions[name].base.kind=='int' and self.functions[name].base.size==8 and self.functions[name].base.name!='size_t')) and name not in {'process_time','stop_profiling','flush_profiles','print_profiles','satch_process_time','satch_stop_profiling_parsing'}:
    ftypes.insert(0,f'(declaim (inline {sym(name)}))')
  globals_=[]
  for n in self.tree.ext:
   if isinstance(n,C.Decl) and n.name in self.globals:
    name,t=self.globals[n.name]; globals_.append('(declaim (type '+self.ltype(t)+' '+name+'))\n(defparameter '+name+' '+self.conv(self.expr(n.init)[0],t,self.expr(n.init)[1])+')')
  strings=globals_+['(defparameter '+s+' (c-string '+ls(v)+'))' for v,s in self.strings.items()]
  package='(uiop:define-package #:ooparts/sat/engine\n (:use #:cl #:ooparts/sat/runtime #:ooparts/sat/layout)\n (:export '+' '.join('#:'+sym(name) for name in sorted(self.defined_funcs))+'))\n(in-package #:ooparts/sat/engine)\n'
  return package+'(declaim (sb-ext:unmuffle-conditions sb-ext:compiler-note))\n(declaim (optimize (speed 2) (safety 1) (debug 0) (compilation-speed 1)))\n'+ '\n'.join(ftypes+strings)+'\n\n'+'\n'.join(code)
 def layout_source(self):
  exports=[];definitions=[]
  for name,(t,offset,bit,width) in sorted(self.field_accessors.items()):
   exports.extend([name,name+'-address'])
   address=f'(+ ,object {offset})'
   getter=self.load(address,t,bit,width)
   if t.kind in ('struct','union','array'):setter=f'(copy-bytes {address} ,value {t.size})'
   elif bit is not None:setter=f'(set-bits {address} {bit} {width} ,value)'
   else:setter=f'(setf {getter} ,value)'
   definitions.extend([f'(defmacro {name}-address (object) `{address})',
    f'(defmacro {name} (object) `{getter})',
    f'(defsetf {name} (object) (value) `{setter})'])
  return '(uiop:define-package #:ooparts/sat/layout\n (:use #:cl #:ooparts/sat/runtime)\n (:export '+' '.join('#:'+name for name in exports)+'))\n(in-package #:ooparts/sat/layout)\n'+'\n'.join(definitions)+'\n'
 def verify_layouts(self):
  # Validate every named aggregate and recursively all anonymous subaggregates,
  # including actual GCC bitfield storage masks, against the native ABI.
  lines=['#define NDEBUG 1','#include "../../../vendor/satch/source/satch.c"','#include <stddef.h>','int main(void) {'];checks=[]
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
  lines+=['return 0;}'];p=GENERATED/'layout-probe.c';p.write_text('\n'.join(lines))
  subprocess.run(['gcc','-w',str(p),'-lm','-o',str(GENERATED/'layout-probe')],check=True)
  output=subprocess.check_output([str(GENERATED/'layout-probe')],text=True).splitlines()
  if output!=checks:
   import difflib
   raise ValueError('ABI layout mismatch\n'+'\n'.join(difflib.unified_diff(checks,output)))
  (TOOLS/'layouts.txt').write_text('\n'.join(output)+'\n')
  return len(checks)
if __name__=='__main__':
 GENERATED.mkdir(parents=True,exist_ok=True)
 subprocess.run(['gcc','-E','-nostdinc','-I'+str(TOOLS/'fake-include'),'-DNDEBUG',str(SOURCE/'satch.c'),'-o',str(GENERATED/'satch.i')],cwd=ROOT,check=True)
 tree=c_parser.CParser().parse((GENERATED/'satch.i').read_text())
 tr=Translator(tree)
 text=tr.generate()
 checks=tr.verify_layouts()
 (LIBRARY/'engine.lisp').write_text(';;; Generated by tools/sat/translate.py; do not edit.\n;;; Derived from SATCH b4d4081f8971931399b36c8fdd92bdf4aabac005, -DNDEBUG.\n;;; SPDX-License-Identifier: MIT; see licenses/satch-MIT.txt.\n'+text)
 (LIBRARY/'layout.lisp').write_text(';;; Generated checked memory places for the pinned SATCH layout.\n;;; SPDX-License-Identifier: MIT; see licenses/satch-MIT.txt.\n'+tr.layout_source())
 (TOOLS/'function-map.json').write_text(json.dumps(tr.mapping,indent=2)+'\n')
 subprocess.run([os.environ.get('SBCL','sbcl'),'--noinform','--script',str(TOOLS/'format-source.lisp'),str(LIBRARY/'layout.lisp'),str(LIBRARY/'engine.lisp')],check=True)
 print(f'Translated {len(tr.mapping)} functions ({sum(item["structured"] for item in tr.mapping)} structured); verified {checks} ABI layout facts.')
