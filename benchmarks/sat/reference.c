/* Compile the library separately, so the benchmark driver cannot inline
   its public entry points. No LTO is enabled. */
#define NDEBUG 1
#ifdef MATCH_ALLOCATOR
#include "../../tests/sat/arena.h"
#endif
#include "../../vendor/satch/source/satch.c"
void bench_statistics(struct satch *s,uint64_t *sig) {
 sig[0]=s->statistics.decisions;sig[1]=s->statistics.propagations;
 sig[2]=s->statistics.ticks;sig[3]=s->statistics.reductions;
 sig[4]=s->statistics.restarts;sig[5]=s->statistics.switched;
 sig[6]=s->statistics.rephased;sig[7]=s->statistics.eliminations;
 sig[8]=s->statistics.vivifications;
}
