/* Test-only allocator, reproducing the Lisp arena's size classes and LIFO
   reuse. Necessary for exact traces: worse_candidate breaks ties by address.
   This is never linked to or called by the Lisp implementation. */
#ifndef TEST_ARENA_H
#define TEST_ARENA_H
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <assert.h>
struct arena_block { size_t capacity; struct arena_block *next; };
static unsigned char *arena_base;
static size_t arena_top;
static struct arena_block *arena_bins[32];
static unsigned arena_class(size_t n) { unsigned k=4; while(((size_t)1<<k)<n) k++; return k; }
static void *arena_malloc(size_t n) {
 unsigned k=arena_class(n);size_t capacity=(size_t)1<<k;
 if(!arena_base) { arena_base=malloc(256ul<<20);if(!arena_base) abort(); }
 struct arena_block *b=arena_bins[k];
 if(b) arena_bins[k]=b->next;
 else { if(arena_top+sizeof *b+capacity>(256ul<<20)) abort();
  b=(struct arena_block*)(arena_base+arena_top);arena_top+=sizeof *b+capacity;b->capacity=capacity; }
 return b+1;
}
static void arena_free(void *p) {
 if(!p)return;struct arena_block *b=((struct arena_block*)p)-1;
 unsigned k=arena_class(b->capacity);b->next=arena_bins[k];arena_bins[k]=b;
}
static void *arena_calloc(size_t n,size_t m) { void *p=arena_malloc(n*m);memset(p,0,n*m);return p; }
static void *arena_realloc(void *p,size_t n) {
 if(!p)return arena_malloc(n);struct arena_block *b=((struct arena_block*)p)-1;
 if(n<=b->capacity)return p;
 void *q=arena_malloc(n);memcpy(q,p,b->capacity);arena_free(p);return q;
}
#define malloc arena_malloc
#define calloc arena_calloc
#define realloc arena_realloc
#define free arena_free
#endif
