#define NDEBUG 1
#ifdef MATCH_ALLOCATOR
#include "arena.h"
#endif
#include "../upstream/satch.c"
int main(void) {
 int n,m,limit,lit,id=0;
 while(scanf("%d %d %d",&n,&m,&limit)==3) {
  struct satch *s=satch_init(); satch_reserve(s,n);
  for(int i=0;i<m;i++) { do { if(scanf("%d",&lit)!=1) return 1; satch_add(s,lit); } while(lit); }
  int result=satch_solve(s,limit);
  printf("%d %d %d",id++,result,satch_conflicts(s));
  printf(" %lu %lu %lu %lu %lu %lu %lu %lu %lu",s->statistics.decisions,s->statistics.propagations,s->statistics.ticks,
    s->statistics.reductions,s->statistics.restarts,s->statistics.switched,s->statistics.rephased,s->statistics.eliminations,s->statistics.vivifications);
  if(result==10) for(int i=1;i<=n;i++) printf(" %d",satch_val(s,i));
  printf("\n");satch_release(s);
 }
 return 0;
}
