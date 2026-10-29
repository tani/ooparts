#include "../../vendor/satch/source/satch.h"
#include <stdint.h>
#include <stdlib.h>
extern void bench_statistics(struct satch *, uint64_t *);
#include <time.h>
struct input { int n,m,limit; int *lits; size_t count; };
static double now(clockid_t id) { struct timespec t;clock_gettime(id,&t);return t.tv_sec+1e-9*t.tv_nsec; }
static uint64_t mix(uint64_t hash,uint64_t value) {return (hash^value)*1099511628211ul;}
int main(int argc,char **argv) {
 if(argc!=2)return 1;FILE *in=fopen(argv[1],"r");if(!in)return 1;
 int count;if(fscanf(in,"%d",&count)!=1)return 1;
 struct input *cases=calloc(count,sizeof *cases);
 for(int i=0;i<count;i++) {
  struct input *c=cases+i;size_t capacity=1024;int lit;
  if(fscanf(in,"%d %d %d",&c->n,&c->m,&c->limit)!=3)return 1;
  /* Input storage must not perturb the test allocator's sequence. The same
     array is fully allocated before any solver is created. */
  c->lits=malloc(capacity*sizeof(int));
  for(int j=0;j<c->m;j++)do {
   if(fscanf(in,"%d",&lit)!=1)return 1;
   if(c->count==capacity)c->lits=realloc(c->lits,(capacity*=2)*sizeof(int));
   c->lits[c->count++]=lit;
  }while(lit);
 }
 fclose(in);puts("READY");fflush(stdout);
 int index,repeats;
 while(scanf("%d %d",&index,&repeats)==2) {
  if(index<0)break;if(index>=count||repeats<1)return 1;
  struct input *c=cases+index;
  double sc=0,tc=0,sw=0,tw=0;uint64_t digest=1469598103934665603ul;
  uint64_t sig[13]={0};
  for(int r=0;r<repeats;r++) {
   double c0=now(CLOCK_PROCESS_CPUTIME_ID),w0=now(CLOCK_MONOTONIC);
   struct satch *s=satch_init();satch_reserve(s,c->n);
   for(size_t j=0;j<c->count;j++)satch_add(s,c->lits[j]);
   double c1=now(CLOCK_PROCESS_CPUTIME_ID),w1=now(CLOCK_MONOTONIC);
   int status=satch_solve(s,c->limit);
   double c2=now(CLOCK_PROCESS_CPUTIME_ID),w2=now(CLOCK_MONOTONIC);
   sc+=c2-c1;sw+=w2-w1;tc+=c2-c0;tw+=w2-w0;
   uint32_t model=2166136261u;
   if(status==10)for(int v=1;v<=c->n;v++)model=(model^(uint32_t)satch_val(s,v))*16777619u;
   sig[0]=status;sig[1]=satch_conflicts(s);bench_statistics(s,sig+2);
   sig[11]=model;sig[12]=satch_maximum_variable(s);
   for(int k=0;k<13;k++)digest=mix(digest,sig[k]);
   double c3=now(CLOCK_PROCESS_CPUTIME_ID),w3=now(CLOCK_MONOTONIC);
   satch_release(s);
   tc+=now(CLOCK_PROCESS_CPUTIME_ID)-c3;tw+=now(CLOCK_MONOTONIC)-w3;
  }
  printf("%d %.9f %.9f %.9f %.9f 0 0 0 %lu",repeats,sc,tc,sw,tw,digest);
  for(int k=0;k<13;k++)printf(" %lu",sig[k]);puts("");fflush(stdout);
 }
 return 0;
}
