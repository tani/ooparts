# 0 "upstream/satch.c"
# 0 "<built-in>"
# 0 "<command-line>"
# 1 "upstream/satch.c"
# 35 "upstream/satch.c"
# 1 "upstream/satch.h" 1
# 11 "upstream/satch.h"
# 1 "fake-include/stdio.h" 1
# 1 "fake-include/compat.h" 1


typedef unsigned long size_t;
typedef long ptrdiff_t;
typedef unsigned long uint64_t;
typedef unsigned long uintptr_t;
typedef unsigned int uint32_t;
typedef unsigned char uint8_t;
typedef _Bool bool;
typedef void FILE;
typedef void *va_list;
# 31 "fake-include/compat.h"
struct timeval { long tv_sec; long tv_usec; };
struct rusage { struct timeval ru_utime, ru_stime; long ru_maxrss; long ru_ixrss, ru_idrss, ru_isrss, ru_minflt, ru_majflt, ru_nswap, ru_inblock, ru_oublock, ru_msgsnd, ru_msgrcv, ru_nsignals, ru_nvcsw, ru_nivcsw; };
void *malloc(size_t); void *calloc(size_t,size_t); void *realloc(void *,size_t);
void free(void *); void *memcpy(void *,const void *,size_t);
void *memmove(void *,const void *,size_t); void *memset(void *,int,size_t);
int strcmp(const char *,const char *); size_t strlen(const char *); int abs(int); double sqrt(double); double log(double);
double log10(double); double pow(double,double);
int printf(const char *,...); int fprintf(FILE *,const char *,...);
int sprintf(char *,const char *,...); int vprintf(const char *,va_list);
int vfprintf(FILE *,const char *,va_list); int fputc(int,FILE *);
int putc(int,FILE *); int fputs(const char *,FILE *); int fflush(FILE *);
void abort(void); int isatty(int); int getrusage(int,struct rusage *);
long getpid(void); long sysconf(int); FILE *fopen(const char *,const char *);
int fclose(FILE *); int fscanf(FILE *,const char *,...);
void qsort(void *,size_t,size_t,int (*)(const void *,const void *));
# 2 "fake-include/stdio.h" 2
# 12 "upstream/satch.h" 2
# 21 "upstream/satch.h"
struct satch;







struct satch *satch_init (void);
void satch_release (struct satch *);
# 40 "upstream/satch.h"
void satch_add (struct satch *, int literal);






int satch_solve (struct satch *, int conflict_limit_non_negative);






int satch_val (struct satch *, int literal);







void satch_add_empty (struct satch *);
void satch_add_unit (struct satch *, int);
void satch_add_binary_clause (struct satch *, int, int);
void satch_add_ternary_clause (struct satch *, int, int, int);
void satch_add_quaternary_clause (struct satch *, int, int, int, int);







void satch_reserve (struct satch *, int maximum_variable_index);





void satch_set_verbose_level (struct satch *, int level);
# 93 "upstream/satch.h"
void satch_enable_logging_messages (struct satch *);



void satch_ascii_proof (struct satch *);



void satch_trace_proof (struct satch *, FILE *);





int satch_maximum_variable (struct satch *);



double satch_process_time (void);



void satch_section (struct satch *, const char *name);



void satch_statistics (struct satch *);



int satch_conflicts (struct satch *);
# 132 "upstream/satch.h"
void satch_start_profiling_parsing (struct satch *);
double satch_stop_profiling_parsing (struct satch *);
# 144 "upstream/satch.h"
const char *satch_version (void);
const char *satch_compile (void);
const char *satch_identifier (void);




unsigned max_stamped_unassigned_variable_on_decision_queue (struct satch
           *solver);



unsigned max_score_unassigned_variable_on_binary_heap (struct satch *solver);
# 36 "upstream/satch.c" 2



# 1 "fake-include/assert.h" 1
# 40 "upstream/satch.c" 2
# 1 "fake-include/math.h" 1
# 41 "upstream/satch.c" 2
# 1 "fake-include/inttypes.h" 1
# 42 "upstream/satch.c" 2
# 1 "fake-include/limits.h" 1
# 43 "upstream/satch.c" 2
# 1 "fake-include/stdarg.h" 1
# 44 "upstream/satch.c" 2
# 1 "fake-include/stdbool.h" 1
# 45 "upstream/satch.c" 2
# 1 "fake-include/stdint.h" 1
# 46 "upstream/satch.c" 2
# 1 "fake-include/stdio.h" 1
# 47 "upstream/satch.c" 2
# 1 "fake-include/stdlib.h" 1
# 48 "upstream/satch.c" 2
# 1 "fake-include/string.h" 1
# 49 "upstream/satch.c" 2





# 1 "fake-include/sys/resource.h" 1
# 1 "fake-include/compat.h" 1
# 2 "fake-include/sys/resource.h" 2
# 55 "upstream/satch.c" 2
# 1 "fake-include/sys/time.h" 1
# 56 "upstream/satch.c" 2
# 1 "fake-include/sys/types.h" 1
# 57 "upstream/satch.c" 2
# 1 "fake-include/unistd.h" 1
# 58 "upstream/satch.c" 2
# 71 "upstream/satch.c"
# 1 "upstream/features.h" 1
# 15 "upstream/features.h"
# 1 "upstream/features/check.h" 1
# 16 "upstream/features.h" 2
# 158 "upstream/features.h"
# 1 "upstream/features/init.h" 1
# 159 "upstream/features.h" 2
# 72 "upstream/satch.c" 2
# 192 "upstream/satch.c"
# 1 "upstream/rsort.h" 1
# 193 "upstream/satch.c" 2


# 1 "upstream/qsort.h" 1
# 196 "upstream/satch.c" 2
# 1 "upstream/stack.h" 1
# 12 "upstream/stack.h"
# 1 "fake-include/stdlib.h" 1
# 13 "upstream/stack.h" 2
# 113 "upstream/stack.h"
struct unsigned_stack
{
  unsigned *begin, *end, *allocated;
};

struct int_stack
{
  int *begin, *end, *allocated;
};
# 197 "upstream/satch.c" 2
# 1 "upstream/colors.h" 1





# 1 "fake-include/assert.h" 1
# 7 "upstream/colors.h" 2
# 1 "fake-include/stdbool.h" 1
# 8 "upstream/colors.h" 2
# 1 "fake-include/unistd.h" 1
# 9 "upstream/colors.h" 2
# 198 "upstream/satch.c" 2







struct clause
{
# 218 "upstream/satch.c"
  bool garbage:1;
  bool protected:1;
  bool redundant:1;

  bool subsumed:1;



  unsigned used:2;





  bool shrunken:1;
  unsigned vivify:2;
# 242 "upstream/satch.c"
  unsigned glue;



  unsigned search;


  unsigned size;







  unsigned literals[2];







};





struct clauses
{
  struct clause **begin, **end, **allocated;
};
# 306 "upstream/satch.c"
struct header
{
  bool binary;
  bool redundant;
  unsigned blocking;
};
# 341 "upstream/satch.c"
union watch
{

  struct header header;

  struct clause *clause;
};



struct watches
{
  union watch *begin, *end, *allocated;
};
# 388 "upstream/satch.c"
struct limits
{

  struct
  {
    uint64_t conflicts;
    uint64_t fixed;
    uint64_t marked;

    uint64_t ticks;
    uint64_t search;

  } eliminate;


  struct {
    uint64_t conflicts;

    uint64_t ticks;
    uint64_t search;

  } vivify;


  struct
  {
    uint64_t conflicts;
    uint64_t fixed;
  } reduce;


  uint64_t rephase;


  uint64_t restart;


  struct
  {
    uint64_t conflicts;
    struct
    {
      uint64_t limit;
      uint64_t interval;
    } ticks;
  } mode;


  struct
  {
    uint64_t marked;

    uint64_t ticks;
    uint64_t search;

  } subsume;

};
# 472 "upstream/satch.c"
struct reluctant
{
  uint64_t u, v;
};







struct options
{
  bool ascii;



  unsigned verbose;
};





struct statistics
{

  uint64_t activated[2];

  uint64_t added;

  uint64_t bests;


  uint64_t bumped;

  uint64_t collected;
  uint64_t conflicts;
  uint64_t deleted;
  uint64_t decisions;
  uint64_t deduced;

  uint64_t eliminated;
  uint64_t elimination_ticks;
  uint64_t eliminations;




  uint64_t fixed;

  uint64_t incremented;

  uint64_t irredundant;
  uint64_t learned;

  uint64_t marked_eliminate;


  uint64_t marked_subsume;


  uint64_t minimized;


  uint64_t moved;

  uint64_t propagations;

  uint64_t reasons;


  uint64_t resolutions;


  uint64_t reduced;
  uint64_t reductions;

  uint64_t redundant;
  uint64_t remaining;

  uint64_t rephased;

  uint64_t reported;

  uint64_t rescored;


  uint64_t restamped;


  uint64_t restarts;


  uint64_t reused;

  uint64_t sections;

  uint64_t shrunken;

  uint64_t solved;

  uint64_t strengthened;
  uint64_t subsumption_ticks;
  uint64_t subsumptions;


  uint64_t subsumed;


  uint64_t switched;


  uint64_t targets;


  uint64_t chrono;
  uint64_t chronosaved;


  uint64_t ticks;
  uint64_t variables;

  uint64_t vivify_reused;
  uint64_t vivify_probes;
  uint64_t vivify_strengthened;
  uint64_t vivify_subsume;
  uint64_t vivified;
  uint64_t vivifications;
  uint64_t vivify_implied;
  uint64_t vivify_conflicts;
  uint64_t probing_ticks;
  uint64_t vivify_propagations;

};







struct link
{
  unsigned prev;
  unsigned next;
  unsigned stamp;
};





struct queue
{
  struct link *links;
  unsigned size;
  unsigned first;
  unsigned last;
  unsigned search;
  unsigned stamp;
};
# 643 "upstream/satch.c"
struct heap
{
  unsigned *begin, *end;
  unsigned *pos;
  double *score;
  unsigned size;
  double increment;
  double factor;
};







struct analyzed
{
  unsigned idx;

  unsigned stamp;

};





struct analyzed_stack
{
  struct analyzed *begin, *end, *allocated;
};






struct trail
{
  unsigned *begin, *end;
  unsigned *propagate;
};


struct level
{
  unsigned * trail;
  unsigned lvl;
  struct {
    unsigned earliest;
    unsigned count;
  } seen;
};

struct control
{
  struct level *begin, *end, *allocated;
};





struct averages
{
  double conflict_level;
  double slow_glue;
  double slow_exp;
  double trail_filled;
  double decision_rate;
  uint64_t saved_decisions;

  double fast_glue;
  double fast_exp;

};
# 797 "upstream/satch.c"
struct profile
{
  double start, time;
  const char *name;
};



struct profiles
{


  struct profile focused; struct profile eliminate; struct profile parse; struct profile reduce; struct profile solve; struct profile stable; struct profile subsume; struct profile decide; struct profile minishrink; struct profile vivify; struct profile total;

  struct profile *begin[16];
  struct profile **end;
};



struct flags
{
  bool active:1;

  bool eliminate:1;
  bool eliminated:1;

  bool fixed:1;

  unsigned subsume:2;

};





struct satch
{
  int status;
  bool inconsistent;
  bool iterate;
  bool stable;
  bool dense;
  unsigned level;
  unsigned size;
  size_t capacity;
  unsigned unassigned;
  unsigned *levels;
  signed char *values;
  struct flags *flags;

  signed char *saved;


  signed char *targets;
  unsigned target;


  signed char *bests;
  unsigned best;

  signed char *marks;

  struct unsigned_stack put[2];


  struct unsigned_stack poisoned;
  struct unsigned_stack removable;


  struct unsigned_stack shrunken;


  unsigned *position;

  signed char *frames;

  struct queue queue[2];


  struct heap scores[2];

  struct clause **reasons;

  struct clause binary[2];


  struct unsigned_stack binaries;


  struct unsigned_stack extend;
  struct unsigned_stack resolvents;

  struct watches *watches;
  struct trail trail;

  struct control control;

  struct analyzed_stack analyzed;
  struct unsigned_stack clause;
  struct unsigned_stack blocks;
  struct clauses irredundant;
  struct clauses redundant;

  struct limits limits;


  struct reluctant reluctant;

  struct options options;
  struct averages averages[2];
  struct statistics statistics;
  struct profiles profiles;




  struct int_stack added;
  FILE *proof;





  struct unsigned_stack sorted;
  struct unsigned_stack sorter;
  struct clauses vivification_schedule;
  signed char *vivify_marks;

  bool vivifying;
# 942 "upstream/satch.c"
};
# 970 "upstream/satch.c"
static unsigned
LITERAL (unsigned idx)
{
  ((void)0);
  return idx << 1;
}



static unsigned
INDEX (unsigned lit)
{
  return lit >> 1;
}



static unsigned
SIGN_BIT (unsigned lit)
{
  return lit & 1;
}




static int
INT_SIGN (unsigned lit)
{
  return SIGN_BIT (lit) ? -1 : 1;
}



static unsigned
NOT (unsigned lit)
{
  return lit ^ 1;
}
# 1198 "upstream/satch.c"
static unsigned
export_literal (unsigned ilit)
{
  const unsigned iidx = INDEX (ilit);
  ((void)0);
  const int eidx = iidx + 1;
  const int elit = SIGN_BIT (ilit) ? -eidx : eidx;
  return elit;
}







static void fatal_error (const char *fmt, ...)
  ;
# 1238 "upstream/satch.c"
static void message (struct satch *,
       unsigned level, const char *name, uint64_t count,
       const char *fmt, ...)
  ;
# 1282 "upstream/satch.c"
static void
fatal_error (const char *fmt, ...)
{
  ((void)0); bool colors = isatty (2); FILE * terminal_file = ((2 == 1) ? 1 : 2); (void) terminal_file;
  va_list ap;
  fprintf (2, "%slibsatch: %sfatal error: %s", (colors ? "\033[1m" : ""), (colors ? "\033[31m" : ""), (colors ? "\033[0m" : ""));
  ((ap)=cl_varargs);
  vfprintf (2, fmt, ap);
  ((void)0);
  fputc ('\n', 2);
  fflush (2);
  abort ();
}



static void
out_of_memory (size_t bytes)
{
  fatal_error ("out-of-memory allocating %zu bytes", bytes);
}





static void
message (struct satch *solver,
  unsigned level, const char *name, uint64_t count,
  const char *fmt, ...)
{
  if (solver->options.verbose < level)
    return;
  fputs ("c ", 1);
  printf ("[%s-%" "lu" "] ", name, count);
  va_list ap;
  ((ap)=cl_varargs);
  vprintf (fmt, ap);
  ((void)0);
  fputc ('\n', 1);
  fflush (1);
}





static void
internal_section (struct satch *solver, const char *name)
{
  ((void)0);
  if (solver->statistics.sections)
    fputs ("c\n", 1);
  ( ((void)0), ++solver->statistics.sections );
  ((void)0); bool colors = isatty (1); FILE * terminal_file = ((1 == 1) ? 1 : 2); (void) terminal_file;
  fputs ("c ", 1);
  do { if (colors) fputs ("\033[34m", terminal_file); } while (0);
  fputs ("---- [ ", 1);
  do { if (colors) fputs ("\033[1m", terminal_file); } while (0);
  fputs (name, 1);
  do { if (colors) fputs ("\033[0m", terminal_file); } while (0);
  do { if (colors) fputs ("\033[34m", terminal_file); } while (0);
  fputs (" ] ", 1);
  for (size_t i = strlen (name); i < 66; i++)
    putc ('-', 1);
  do { if (colors) fputs ("\033[0m", terminal_file); } while (0);
  fputs ("\nc\n", 1);
  fflush (1);
}





static bool
is_temporary_binary (struct satch *solver, struct clause *c)
{
  return c == solver->binary || c == solver->binary + 1;
}
# 1597 "upstream/satch.c"
static double
process_time (void)
{
  struct rusage u;
  double res;
  if (getrusage (0, &u))
    return 0;
  res = u.ru_utime.tv_sec + 1e-6 * u.ru_utime.tv_usec;
  res += u.ru_stime.tv_sec + 1e-6 * u.ru_stime.tv_usec;
  return res;
}



static uint64_t
maximum_resident_set_size (void)
{
  struct rusage u;
  if (getrusage (0, &u))
    return 0;
  return ((uint64_t) u.ru_maxrss) << 10;
}




uint64_t
current_resident_set_size (void)
{
  char path[48];
  sprintf (path, "/proc/%" "lu" "/statm", (uint64_t) getpid ());
  FILE *file = fopen (path, "r");
  if (!file)
    return 0;
  uint64_t dummy, rss;
  int scanned = fscanf (file, "%" "lu" " %" "lu" "", &dummy, &rss);
  fclose (file);
  return scanned == 2 ? rss * sysconf (30) : 0;
}
# 1644 "upstream/satch.c"
static double
percent (double a, double b)
{
  return b ? 100.0 * a / b : 0;
}

static double
relative (double a, double b)
{
  return b ? a / b : 0;
}
# 1673 "upstream/satch.c"
static void
init_profiles (struct satch *solver)
{
  struct profiles *profiles = &solver->profiles;
  profiles->end = profiles->begin;


  profiles->focused.name = "focused"; profiles->eliminate.name = "eliminate"; profiles->parse.name = "parse"; profiles->reduce.name = "reduce"; profiles->solve.name = "solve"; profiles->stable.name = "stable"; profiles->subsume.name = "subsume"; profiles->decide.name = "decide"; profiles->minishrink.name = "minishrink"; profiles->vivify.name = "vivify"; profiles->total.name = "total";

}

static void
start_profiling (struct satch *solver, struct profile *profile)
{
  struct profiles *profiles = &solver->profiles;
  const double start = process_time ();
  profile->start = start;
  ((void)0);
  *profiles->end++ = profile;
}
# 1704 "upstream/satch.c"
static double
stop_profiling (struct satch *solver, struct profile *profile, double stop)
{
  struct profiles *profiles = &solver->profiles;
  ((void)0);
  const double time = stop - profile->start;
  profile->time += time;
  (void) (((void)0), *--(*profiles).end);
  return time;
}






static double
flush_profiles (struct satch *solver)
{
  struct profiles *profiles = &solver->profiles;
  const double stop = process_time ();
  while (!((*profiles).end == (*profiles).begin))
    stop_profiling (solver, (((void)0), (*profiles).end[-1]), stop);
  profiles->total.time = profiles->parse.time + profiles->solve.time;
  return stop;
}
# 1744 "upstream/satch.c"
static double
print_profiles (struct satch *solver)
{


  const double stop = flush_profiles (solver);

  internal_section (solver, "profiling");




  struct profiles *profiles = &solver->profiles;
  const bool verbose = solver->options.verbose > 1;
  ((void)0);
# 1773 "upstream/satch.c"
  do { struct profile * profile = &profiles->focused; if (profile == &profiles->total) break; if (!verbose && !profile->time) break; ((void)0); *profiles->end++ = &profiles->focused; } while (0); do { struct profile * profile = &profiles->eliminate; if (profile == &profiles->total) break; if (!verbose && !profile->time) break; ((void)0); *profiles->end++ = &profiles->eliminate; } while (0); do { struct profile * profile = &profiles->parse; if (profile == &profiles->total) break; if (!verbose && !profile->time) break; ((void)0); *profiles->end++ = &profiles->parse; } while (0); do { struct profile * profile = &profiles->reduce; if (profile == &profiles->total) break; if (!verbose && !profile->time) break; ((void)0); *profiles->end++ = &profiles->reduce; } while (0); do { struct profile * profile = &profiles->solve; if (profile == &profiles->total) break; if (!verbose && !profile->time) break; ((void)0); *profiles->end++ = &profiles->solve; } while (0); do { struct profile * profile = &profiles->stable; if (profile == &profiles->total) break; if (!verbose && !profile->time) break; ((void)0); *profiles->end++ = &profiles->stable; } while (0); do { struct profile * profile = &profiles->subsume; if (profile == &profiles->total) break; if (!verbose && !profile->time) break; ((void)0); *profiles->end++ = &profiles->subsume; } while (0); do { struct profile * profile = &profiles->decide; if (profile == &profiles->total) break; if (!verbose && !profile->time) break; ((void)0); *profiles->end++ = &profiles->decide; } while (0); do { struct profile * profile = &profiles->minishrink; if (profile == &profiles->total) break; if (!verbose && !profile->time) break; ((void)0); *profiles->end++ = &profiles->minishrink; } while (0); do { struct profile * profile = &profiles->vivify; if (profile == &profiles->total) break; if (!verbose && !profile->time) break; ((void)0); *profiles->end++ = &profiles->vivify; } while (0); do { struct profile * profile = &profiles->total; if (profile == &profiles->total) break; if (!verbose && !profile->time) break; ((void)0); *profiles->end++ = &profiles->total; } while (0);






  const size_t size = ((size_t) ((*profiles).end - (*profiles).begin));
  for (size_t i = 0; i < size; i++)
    {
      struct profile *p = profiles->begin[i];
      for (size_t j = i + 1; j < size; j++)
 {
   struct profile *q = profiles->begin[j];
   if (p->time < q->time ||
       (p->time == q->time && strcmp (p->name, q->name) > 0))
     {
       profiles->begin[i] = q;
       profiles->begin[j] = p;
       p = q;
     }
 }
    }



  const double total = profiles->total.time;
  for (size_t i = 0; i < size; i++)
    {
      struct profile *p = profiles->begin[i];
      printf ("c %14.2f  %6.2f %%  %s\n",
       p->time, percent (p->time, total), p->name);

    }
  fputs ("c =============================================\n", 1);
  printf ("c %14.2f  %6.2f %%  total\n", total, 100.0);

  return stop;
}



static void
print_statistics (struct satch *solver, double seconds)
{
  internal_section (solver, "statistics");
  struct statistics s = solver->statistics;
  const bool verbose = solver->options.verbose > 1;
# 1829 "upstream/satch.c"
  if (verbose)
    printf ("c %-24s" " %" "17" "lu" " %" "17" "s clauses\n", "added:", s.added, "");

  printf ("c %-24s" " %" "17" "lu" " %" "17" ".2f interval\n", "bests:",
   s.bests, relative (s.conflicts, s.bests));


  if (verbose)
    printf ("c %-24s" " %" "17" "lu" " %" "17" ".2f literals\n", "bumped:",
     s.bumped, relative (s.bumped, s.conflicts));


  if (verbose)
    printf ("c %-24s" " %" "17" "lu" " %" "17" ".2f per learned\n",
     "chronological backtracking:", s.chrono,
     percent (s.chrono, s.learned));
  if (verbose)
    printf ("c %-24s" " %" "17" "lu" " %" "17" ".2f per jump\n",
     "reused level:", s.chronosaved, relative (s.chronosaved,
            s.chrono));

  printf ("c %-24s" " %" "17" "lu" " %" "17" ".2f MB\n", "collected:",
   s.collected, s.collected / (double) (1u << 20));
  printf ("c %-24s" " %" "17" "lu" " %" "17" ".2f per second\n", "conflicts:",
   s.conflicts, relative (s.conflicts, seconds));
  printf ("c %-24s" " %" "17" "lu" " %" "17" ".2f per conflict\n", "decisions:",
   s.decisions, relative (s.decisions, s.conflicts));
  if (verbose)
    printf ("c %-24s" " %" "17" "lu" " %" "17" ".2f literals\n", "deduced:",
     s.deduced, relative (s.deduced, s.conflicts));
  if (verbose)
    printf ("c %-24s" " %" "17" "lu" " %" "14" ".0f %%  added\n", "deleted:",
     s.deleted, percent (s.deleted, s.added));

  printf ("c %-24s" " %" "17" "lu" " %" "14" ".0f %%  variables\n", "eliminated:",
   s.eliminated, percent (s.eliminated, s.variables));
  if (verbose)
    printf ("c %-24s" " %" "17" "lu" " %" "17" ".2f interval\n", "eliminations:",
     s.eliminations, relative (s.conflicts, s.eliminations));

  printf ("c %-24s" " %" "17" "lu" " %" "14" ".0f %%  variables\n", "fixed:",
   s.fixed, percent (s.fixed, s.variables));
  printf ("c %-24s" " %" "17" "lu" " %" "17" ".2f literals\n", "learned:",
   s.learned, relative (s.learned, s.conflicts));

  if (verbose)
    printf ("c %-24s" " %" "17" "lu" " %" "14" ".0f %%  bumped\n", "incremented:",
     s.incremented, percent (s.incremented, s.bumped));


  if (verbose)
    printf ("c %-24s" " %" "17" "lu" " %" "14" ".0f %%  deduced\n", "minimized:",
     s.minimized, percent (s.minimized, s.deduced));


  if (verbose)
    printf ("c %-24s" " %" "17" "lu" " %" "14" ".0f %%  bumped\n", "moved:",
     s.moved, percent (s.moved, s.bumped));

  printf ("c %-24s" " %" "17" "lu" " %" "17" ".2f per second\n", "propagations:",
   s.propagations, relative (s.propagations, seconds));

  if (verbose)
    printf ("c %-24s" " %" "17" "lu" " %" "14" ".0f %%  bumped\n", "reasons:",
     s.reasons, percent (s.reasons, s.bumped));


  printf ("c %-24s" " %" "17" "lu" " %" "17" ".2f per reduction\n", "reduced:",
   s.reduced, relative (s.reduced, s.reductions));
  if (verbose)
    printf ("c %-24s" " %" "17" "lu" " %" "17" ".2f interval\n", "reductions:",
     s.reductions, relative (s.conflicts, s.reductions));


  printf ("c %-24s" " %" "17" "lu" " %" "17" ".2f interval\n", "rephased:",
   s.rephased, relative (s.conflicts, s.rephased));


  printf ("c %-24s" " %" "17" "lu" " %" "17" ".2f interval\n", "rescored:",
   s.rescored, relative (s.conflicts, s.rescored));


  printf ("c %-24s" " %" "17" "lu" " %" "17" ".2f interval\n", "restamped:",
   s.restamped, relative (s.conflicts, s.restamped));


  printf ("c %-24s" " %" "17" "lu" " %" "17" ".2f per variable\n", "resolutions:",
   s.resolutions, relative (s.resolutions, s.variables));


  printf ("c %-24s" " %" "17" "lu" " %" "17" ".2f interval\n", "restarts:",
   s.restarts, relative (s.conflicts, s.restarts));


  if (verbose)
    printf ("c %-24s" " %" "17" "lu" " %" "14" ".0f %%  restarts\n", "reused:",
     s.reused, percent (s.reused, s.restarts));


  if (verbose)
    printf ("c %-24s" " %" "17" "lu" " %" "14" ".0f %%  deduced\n", "shrunken:",
     s.shrunken, percent (s.shrunken, s.deduced));


  printf ("c %-24s" " %" "17" "lu" " %" "14" ".0f %%  added\n", "strengthened:",
   s.strengthened, percent (s.strengthened, s.added));
  printf ("c %-24s" " %" "17" "lu" " %" "14" ".0f %%  added\n", "subsumed:",
   s.subsumed, percent (s.subsumed, s.added));
  if (verbose)
    printf ("c %-24s" " %" "17" "lu" " %" "17" ".2f interval\n", "subsumptions:",
     s.subsumptions, relative (s.conflicts, s.subsumptions));


  if (verbose)
    printf ("c %-24s" " %" "17" "lu" " %" "17" ".2f interval\n", "switched:",
     s.switched, relative (s.conflicts, s.switched));


  if (verbose)
    printf ("c %-24s" " %" "17" "lu" " %" "17" ".2f interval\n", "targets:",
     s.targets, relative (s.conflicts, s.targets));


  printf ("c %-24s" " %" "17" "lu" " %" "14" ".0f per round\n",
   "vivified:", s.vivified, relative (s.vivified, s.vivifications));
  printf ("c %-24s" " %" "17" "lu" " %" "14" ".0f per round\n",
   "     propagations:", s.vivify_propagations,
   relative (s.vivify_propagations, s.vivifications));
  printf ("c %-24s" " %" "17" "lu" " %" "14" ".0f per propagation\n",
   "     ticks:", s.probing_ticks,
   relative (s.probing_ticks, s.vivify_propagations));
  printf ("c %-24s" " %" "17" "lu" " %" "14" ".0f per round\n",
   "     subsume:", s.vivify_subsume,
   relative (s.vivify_subsume, s.vivifications));
  printf ("c %-24s" " %" "17" "lu" " %" "14" ".0f per round\n",
   "     strengthen:", s.vivify_strengthened,
   relative (s.vivify_strengthened, s.vivifications));
  if (verbose)
    printf ("c %-24s" " %" "17" "lu" " %" "14" ".2f per vivification\n",
     "     reused:", s.vivify_reused,
     relative (s.vivify_reused, s.vivified));

  if (verbose)
    printf ("c %-24s" " %" "17" "lu" " %" "17" ".2f per propagation\n", "ticks:",
     s.ticks, relative (s.ticks, s.propagations));
}

static void
print_resource_usage (struct satch *solver, double seconds)
{
  internal_section (solver, "resources");
  const uint64_t memory = maximum_resident_set_size ();
  printf ("c %-24s %17" "lu" " bytes %11.2f MB\n",
   "memory:", memory, memory / (double) (1 << 20));
  printf ("c %-24s %17s %17.2f seconds\n", "time:", "", seconds);
}
# 2001 "upstream/satch.c"
static void
start_addition_proof_line (struct satch *solver)
{
  ((void)0);
  if (!solver->options.ascii)
    fputc ('a', solver->proof);
}

static void
start_deletion_proof_line (struct satch *solver)
{
  ((void)0);
  fputc ('d', solver->proof);
  if (solver->options.ascii)
    fputc (' ', solver->proof);
}

static void
add_external_literal_to_proof_line (struct satch *solver, int elit)
{
  ((void)0);
  if (solver->options.ascii)
    fprintf (solver->proof, "%d ", elit);
  else
    {



      ((void)0);

      const unsigned plit = 2u * abs (elit) + (elit < 0);






      unsigned rest = plit;

      while (rest & ~0x7f)
 {
   const unsigned char byte = (rest & 0x7f) | 0x80;
   fputc (byte, solver->proof);
   rest >>= 7;
 }

      fputc ((unsigned char) rest, solver->proof);
    }
}

static void
add_internal_literal_to_proof_line (struct satch *solver, unsigned ilit)
{
  const int elit = export_literal (ilit);
  add_external_literal_to_proof_line (solver, elit);
}

static void
end_proof_line (struct satch *solver)
{
  ((void)0);
  if (solver->options.ascii)
    fputs ("0\n", solver->proof);
  else
    fputc (0, solver->proof);
  fflush (solver->proof);
}
# 2080 "upstream/satch.c"
static void
trace_and_check_addition (struct satch *solver,
     size_t size, unsigned *literals, unsigned except)
{
  if (solver->proof)
    {
      start_addition_proof_line (solver);
      for (unsigned lit, * P_lit = (literals), * const END_lit = P_lit + (size); (P_lit != END_lit) && (lit = *P_lit, 1); ++P_lit)
 if (lit != except)
     add_internal_literal_to_proof_line (solver, lit);
      end_proof_line (solver);
    }






}



static void
trace_and_check_deletion (struct satch *solver,
     size_t size, unsigned *literals)
{
  if (solver->proof)
    {
      start_deletion_proof_line (solver);
      for (unsigned lit, * P_lit = (literals), * const END_lit = P_lit + (size); (P_lit != END_lit) && (lit = *P_lit, 1); ++P_lit)
   add_internal_literal_to_proof_line (solver, lit);
      end_proof_line (solver);
    }





}

static void
trace_and_check_empty_addition (struct satch *solver)
{
  trace_and_check_addition (solver, 0, 0, 4294967295U);
}

static void
trace_and_check_unit_addition (struct satch *solver, unsigned unit)
{
  trace_and_check_addition (solver, 1, &unit, 4294967295U);
}



static void
trace_and_check_temporary_addition (struct satch *solver)
{
  const size_t size = ((size_t) ((solver->clause).end - (solver->clause).begin));
  trace_and_check_addition (solver, size, solver->clause.begin, 4294967295U);
}





static void
trace_and_check_binary_deletion (struct satch *solver,
     unsigned lit, unsigned other)
{
  unsigned literals[2] = { lit, other };
  trace_and_check_deletion (solver, 2, literals);
}





static void
trace_and_check_clause_addition (struct satch *solver,
     struct clause *c, unsigned remove)
{
  trace_and_check_addition (solver, c->size, c->literals, remove);
}



static void
trace_and_check_clause_deletion (struct satch *solver, struct clause *c)
{
  trace_and_check_deletion (solver, c->size, c->literals);
}
# 2181 "upstream/satch.c"
static size_t
bytes_clause (size_t size)
{
  ((void)0);
  return sizeof (struct clause) + (size - 2) * sizeof (unsigned);
}



static struct clause *
allocate_clause (size_t size)
{
  const size_t bytes = bytes_clause (size);
  struct clause *res = malloc (bytes);
  if (!res)
    out_of_memory (bytes);
  return res;
}

static size_t
deallocate_clause (struct clause *c)
{
  const size_t bytes = bytes_clause (c->size);
  free (c);
  return bytes;
}
# 2244 "upstream/satch.c"
static struct clause *

add_clause (struct satch *solver, bool redundant, unsigned glue)



{



    ( ((void)0), ++solver->statistics.added );
  const size_t size = ((size_t) ((solver->clause).end - (solver->clause).begin));



  ((void)0);

  struct clause *res = allocate_clause (size);



  res->garbage = 0;
  res->protected = 0;
  res->redundant = redundant;

  res->used = 0;


  res->subsumed = 0;






  res->glue = glue;


  res->search = 0;

  res->size = size;

  res->vivify = 0;
  res->shrunken = 0;

  memcpy (res->literals, solver->clause.begin, size * sizeof (unsigned));
  return res;
}

static struct clause *
new_irredundant_clause (struct satch *solver)
{

  struct clause *res = add_clause (solver, 0, 0);



  do { if (((solver->irredundant).end == (solver->irredundant).allocated)) do { const size_t old_size = ((size_t) ((solver->irredundant).end - (solver->irredundant).begin)); const size_t old_capacity = ((size_t) ((solver->irredundant).allocated - (solver->irredundant).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(solver->irredundant).begin; (solver->irredundant).begin = realloc ((solver->irredundant).begin, new_bytes); if (!(solver->irredundant).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (solver->irredundant).end = (solver->irredundant).begin + old_size; (solver->irredundant).allocated = (solver->irredundant).begin + new_capacity; } while (0); *(solver->irredundant).end++ = (res); } while (0);
  ( ((void)0), ++solver->statistics.irredundant );
  return res;
}


static struct clause *

new_redundant_clause (struct satch *solver, unsigned glue)



{

  struct clause *res = add_clause (solver, 1, glue);




  do { if (((solver->redundant).end == (solver->redundant).allocated)) do { const size_t old_size = ((size_t) ((solver->redundant).end - (solver->redundant).begin)); const size_t old_capacity = ((size_t) ((solver->redundant).allocated - (solver->redundant).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(solver->redundant).begin; (solver->redundant).begin = realloc ((solver->redundant).begin, new_bytes); if (!(solver->redundant).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (solver->redundant).end = (solver->redundant).begin + old_size; (solver->redundant).allocated = (solver->redundant).begin + new_capacity; } while (0); *(solver->redundant).end++ = (res); } while (0);

  ( ((void)0), ++solver->statistics.redundant );
  return res;
}
# 2334 "upstream/satch.c"
static size_t
delete_clause (struct satch *solver, struct clause *c)
{
  ( ((void)0), ++solver->statistics.deleted );
  do { (void) solver; } while(0);
  if (!c->garbage)
    {
      trace_and_check_clause_deletion (solver, c);
      if (c->redundant)
 do { ((void)0); solver->statistics.redundant--; } while (0);
      else
 do { ((void)0); solver->statistics.irredundant--; } while (0);
    }
  return deallocate_clause (c);
}







static void
watch_literal (struct satch *solver, bool redundant,
        unsigned lit, unsigned blocking, struct clause *c)
{
  ((void)0);
  struct watches *watches = solver->watches + lit;
  union watch watch;
  watch.header.binary = (c->size == 2);
  watch.header.redundant = redundant;
  watch.header.blocking = blocking;
  do { (void) solver; } while(0);
  do { if (((*watches).end == (*watches).allocated)) do { const size_t old_size = ((size_t) ((*watches).end - (*watches).begin)); const size_t old_capacity = ((size_t) ((*watches).allocated - (*watches).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(*watches).begin; (*watches).begin = realloc ((*watches).begin, new_bytes); if (!(*watches).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (*watches).end = (*watches).begin + old_size; (*watches).allocated = (*watches).begin + new_capacity; } while (0); *(*watches).end++ = (watch); } while (0);
  watch.clause = c;
  do { if (((*watches).end == (*watches).allocated)) do { const size_t old_size = ((size_t) ((*watches).end - (*watches).begin)); const size_t old_capacity = ((size_t) ((*watches).allocated - (*watches).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(*watches).begin; (*watches).begin = realloc ((*watches).begin, new_bytes); if (!(*watches).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (*watches).end = (*watches).begin + old_size; (*watches).allocated = (*watches).begin + new_capacity; } while (0); *(*watches).end++ = (watch); } while (0);
}
# 2392 "upstream/satch.c"
static void
unwatch_literal (struct satch *solver, unsigned lit, struct clause *c)
{
  ((void)0);
  struct watches *watches = solver->watches + lit;
  const union watch *const end = watches->end;
  union watch *q = watches->begin;
  for (;;)
    {
      ((void)0);

      const union watch watch = *q++;
      const struct header header = watch.header;


      if (header.binary)
 continue;

      const struct clause *d = q++->clause;
      if (c == d)
 {
   do { (void) solver; } while(0)
                                           ;
   break;
 }
    }
  while (q != end)
    q[-2] = *q, q++;
  watches->end -= 2;
}
# 2455 "upstream/satch.c"
static void
watch_clause (struct satch *solver, struct clause *c)
{
  ((void)0);
  ((void)0);
  const unsigned lit = c->literals[0];
  const unsigned other = c->literals[1];

  const bool redundant = c->redundant;
  watch_literal (solver, redundant, lit, other, c);
  watch_literal (solver, redundant, other, lit, c);




}
# 2482 "upstream/satch.c"
static void
init_binary (struct satch *solver)
{
  for (unsigned i = 0; i < 2; i++)
    {
      struct clause *binary = solver->binary + i;
      binary->size = 2;





    }
}

static void
release_binary (struct satch *solver)
{




  (void) solver;

}






static struct clause *
binary_clause (struct satch *solver, unsigned pos,
        bool redundant, unsigned lit, unsigned other)
{
  ((void)0);
  struct clause *res = solver->binary + pos;
  ((void)0);
  ((void)0);
  res->redundant = redundant;
  res->literals[0] = lit;
  res->literals[1] = other;
  return res;
}
# 2551 "upstream/satch.c"
static bool
is_tagged_clause (const struct clause *const c)
{
  uintptr_t word = (uintptr_t) c;
  return !!(word & 3);
}

static struct clause *
tag_binary_clause (bool redundant, uintptr_t other)
{
  const uintptr_t tmp = (other << 2) | 1 | (redundant << 1);
  struct clause *res = (struct clause *) tmp;
  ((void)0);
  return res;
}

static unsigned
tagged_clause_to_literal (const struct clause *c)
{
  ((void)0);
  const uintptr_t tmp = (uintptr_t) c;
  const unsigned res = tmp >> 2;
  return res;
}

static unsigned
tagged_clause_to_redundant (const struct clause *c)
{
  ((void)0);
  const uintptr_t tmp = (uintptr_t) c;
  const bool res = !!(tmp & 2);
  return res;
}
# 2605 "upstream/satch.c"
static struct clause *
untag_clause (struct satch *solver,
       unsigned pos, unsigned lit, const struct clause *c)
{
  ((void)0);
  const unsigned other = tagged_clause_to_literal (c);
  const bool redundant = tagged_clause_to_redundant (c);
  return binary_clause (solver, pos, redundant, lit, other);
}
# 2707 "upstream/satch.c"
static void
bubble_up (struct satch *solver, struct heap *heap, unsigned idx)
{
  unsigned *stack = heap->begin;
  unsigned *pos = heap->pos;
  unsigned idx_pos = pos[idx];
  const double *const score = heap->score;
  const double idx_score = score[idx];
  while (idx_pos)
    {
      const unsigned parent_pos = (idx_pos - 1) / 2;
      const unsigned parent = stack[parent_pos];
      const double parent_score = score[parent];
      if (parent_score >= idx_score)
 break;

      do { (void) solver; } while(0)
                                                              ;

      stack[idx_pos] = parent;
      pos[parent] = idx_pos;
      idx_pos = parent_pos;
    }
  stack[idx_pos] = idx;
  pos[idx] = idx_pos;
  do { (void) solver; } while(0);
  do { } while (0);
}

static void
bubble_down (struct satch *solver, struct heap *heap, unsigned idx)
{
  const double *score = heap->score;
  unsigned *begin = heap->begin;
  unsigned *pos = heap->pos;

  const unsigned size = ((size_t) ((*heap).end - (*heap).begin));

  const double idx_score = score[idx];
  unsigned idx_pos = pos[idx];

  for (;;)
    {
      unsigned child_pos = 2 * idx_pos + 1;
      if (child_pos >= size)
 break;

      unsigned child = begin[child_pos];
      double child_score = score[child];

      const unsigned sibling_pos = child_pos + 1;
      if (sibling_pos < size)
 {
   const unsigned sibling = begin[sibling_pos];
   const double sibling_score = score[sibling];
   if (sibling_score > child_score)
     {
       child = sibling;
       child_pos = sibling_pos;
       child_score = sibling_score;
     }
 }

      if (child_score <= idx_score)
 break;

      ((void)0);
      do { (void) solver; } while(0)
                                                           ;

      begin[idx_pos] = child;
      pos[child] = idx_pos;
      idx_pos = child_pos;
    }
  begin[idx_pos] = idx;
  pos[idx] = idx_pos;
  do { (void) solver; } while(0);
  do { } while (0);
}

static void
push_heap (struct satch *solver, struct heap *heap, unsigned idx)
{
  const unsigned size = ((size_t) ((*heap).end - (*heap).begin));
  ((void)0);
  unsigned *pos = heap->pos;
  ((void)0);
  pos[idx] = size;
  *heap->end++ = idx;
  do { (void) solver; } while(0);
  bubble_up (solver, heap, idx);
}

static unsigned
max_heap (struct heap *heap)
{
  return ((*heap).begin[((void)0), (0)]);
}

static unsigned
pop_heap (struct satch *solver, struct heap *heap)
{
  do { } while (0);
  const unsigned res = max_heap (heap);
  do { (void) solver; } while(0);
  unsigned *pos = heap->pos;
  ((void)0);
  pos[res] = 4294967295U;
  const unsigned last = (((void)0), *--(*heap).end);
  if (last == res)
    return res;
  pos[last] = 0;
  heap->begin[0] = last;
  bubble_down (solver, heap, last);
  return res;
}



static void
update_heap (struct satch *solver, struct heap *heap,
      unsigned idx, double new_score)
{
  do { } while (0);
  double *score = heap->score;
  const double old_score = score[idx];
  if (old_score < new_score)
    {
      score[idx] = new_score;
      if (heap->pos[idx] != 4294967295U)
 bubble_up (solver, heap, idx);
    }
  else if (old_score > new_score)
    {
      if (heap->pos[idx] != 4294967295U)
 bubble_down (solver, heap, idx);
    }
}

static double
heap_score (struct heap *heap, unsigned idx)
{
  return heap->score[idx];
}

static void
rescore_scores (struct satch *solver, struct heap *scores)
{
  const uint64_t rescored = ( ((void)0), ++solver->statistics.rescored );
  const unsigned size = solver->size;
  double *score = scores->score;
  ((void)0);
  double max_score = score[0];
  for (unsigned idx = 1; idx < size; idx++)
    {
      const double tmp_score = score[idx];
      if (tmp_score > max_score)
 max_score = tmp_score;
    }
  ((void)0);
  message (solver, 2, "rescore", rescored,
    "rescoring heap with maximum score %g", max_score);
  for (unsigned idx = 0; idx < size; idx++)
    score[idx] /= max_score;
  scores->increment /= max_score;
  message (solver, 3, "rescore", rescored,
    "new score increment %g", scores->increment);
}





static void
resize_heap (struct heap *heap, size_t old_capacity, size_t new_capacity)
{
  const size_t size = ((size_t) ((*heap).end - (*heap).begin));
  do { const size_t new_bytes = (size_t) new_capacity * sizeof *(heap->begin); (heap->begin) = realloc ((heap->begin), new_bytes); if (!(heap->begin)) out_of_memory (new_bytes); } while (0);
  heap->end = heap->begin + size;
  do { const size_t new_bytes = (size_t) new_capacity * sizeof *(heap->pos); (heap->pos) = realloc ((heap->pos), new_bytes); if (!(heap->pos)) out_of_memory (new_bytes); } while (0);
  do { const size_t size = sizeof *(heap->score); const size_t old_bytes = old_capacity ? 1 * (size_t) (old_capacity + 0) * size : 0; const size_t new_bytes = 1 * (size_t) (new_capacity + 0) * size; void * chunk = calloc (new_bytes, 1); if (!chunk) out_of_memory (new_bytes); if (old_bytes) memcpy (chunk, (heap->score), old_bytes); free ((heap->score)); (heap->score) = chunk; } while (0);
}

static void
release_heap (struct heap *heap)
{
  free (heap->begin);
  free (heap->pos);
  free (heap->score);
  memset (heap, 0, sizeof *heap);
}

static void
init_scores (struct satch *solver, struct heap *scores)
{
  if (!scores->increment)
    scores->increment = 1.0;
  if (!scores->begin)
    resize_heap (scores, 0, solver->capacity);
}
# 2926 "upstream/satch.c"
static void
activate_scores (struct satch *solver, struct heap *scores,
   struct unsigned_stack *activate)
{
  init_scores (solver, scores);
  const unsigned stable = solver->stable;
  do { (void) solver; } while(0)
              ;
  unsigned *pos = scores->pos;
  double *score = scores->score;
  for (unsigned idx, * PTR_idx = (*activate).begin, * const END_idx = (*activate).end; (PTR_idx != END_idx) && (idx = *PTR_idx, 1); ++PTR_idx)
    {
      const uint64_t activated = ( ((void)0), ++solver->statistics.activated[stable] );
      pos[idx] = 4294967295U;
      score[idx] = 1 - 1.0 / activated;
      push_heap (solver, scores, idx);
    }
  do { free ((*activate).begin); (*activate).begin = (*activate).end = (*activate).allocated = 0; } while (0);
  scores->size = solver->size;
}
# 2977 "upstream/satch.c"
static struct heap *
get_scores (struct satch *solver)
{
  const unsigned stable = solver->stable;
  struct heap *scores = &solver->scores[stable];

  struct unsigned_stack *activate = &solver->put[stable];
  if (!((*activate).end == (*activate).begin))
    activate_scores (solver, scores, activate);




  ((void)0);
  return scores;
}



static void
bump_variable_score (struct satch *solver, unsigned idx)
{
  ( ((void)0), ++solver->statistics.incremented );
  struct heap *scores = get_scores (solver);
  const double old_score = heap_score (scores, idx);
  const double new_score = old_score + scores->increment;
  do { (void) solver; } while(0);
  update_heap (solver, scores, idx, new_score);
  if (new_score > 1e150)
    rescore_scores (solver, scores);
}

static void
bump_score_increment (struct satch *solver)
{
  struct heap *scores = get_scores (solver);
  scores->increment *= scores->factor;
  do { (void) solver; } while(0);
}
# 3205 "upstream/satch.c"
static void
mark_eliminate_literal (struct satch *solver, unsigned lit)
{
  const unsigned idx = INDEX (lit);
  struct flags *f = solver->flags + idx;
  if (!f->active)
    return;
  if (f->eliminate)
    return;
  do { (void) solver; } while(0);
  f->eliminate = 1;
  ( ((void)0), ++solver->statistics.marked_eliminate );
}

static void
mark_eliminate_clause (struct satch *solver, struct clause *c)
{
  for (unsigned lit, * P_lit = ((c)->literals), * const END_lit = P_lit + ((c)->size); (P_lit != END_lit) && (lit = *P_lit, 1); ++P_lit)
    mark_eliminate_literal (solver, lit);
}
# 3233 "upstream/satch.c"
static void
mark_subsume_variable (struct satch *solver, unsigned idx)
{
  struct flags *f = solver->flags + idx;
  if (!f->active)
    return;
  if (f->subsume & 1)
    return;
  do { (void) solver; } while(0);
  f->subsume |= 1;
  ( ((void)0), ++solver->statistics.marked_subsume );
}


static void
mark_subsume_literal (struct satch *solver, unsigned lit)
{
  const unsigned idx = INDEX (lit);
  mark_subsume_variable (solver, idx);
}
# 3264 "upstream/satch.c"
static inline void
watch_binary (struct satch *solver,
       bool redundant, unsigned lit, unsigned blocking)
{
  union watch watch;
  watch.header.binary = 1;
  watch.header.redundant = redundant;
  watch.header.blocking = blocking;
  do { if (((solver->watches[lit]).end == (solver->watches[lit]).allocated)) do { const size_t old_size = ((size_t) ((solver->watches[lit]).end - (solver->watches[lit]).begin)); const size_t old_capacity = ((size_t) ((solver->watches[lit]).allocated - (solver->watches[lit]).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(solver->watches[lit]).begin; (solver->watches[lit]).begin = realloc ((solver->watches[lit]).begin, new_bytes); if (!(solver->watches[lit]).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (solver->watches[lit]).end = (solver->watches[lit]).begin + old_size; (solver->watches[lit]).allocated = (solver->watches[lit]).begin + new_capacity; } while (0); *(solver->watches[lit]).end++ = (watch); } while (0);
  do { (void) solver; } while(0)
                                                                 ;
}

static void
add_new_binary_and_watch_it (struct satch *solver, bool redundant)
{
  ((void)0);
  const unsigned lit = ((solver->clause).begin[((void)0), (0)]);
  const unsigned other = ((solver->clause).begin[((void)0), (1)]);
  watch_binary (solver, redundant, lit, other);
  watch_binary (solver, redundant, other, lit);
  if (redundant)
    ( ((void)0), ++solver->statistics.redundant );
  else
    ( ((void)0), ++solver->statistics.irredundant );
}
# 3299 "upstream/satch.c"
static void
really_delete_binary (struct satch *solver,
        bool redundant, unsigned lit, unsigned other)
{
  do { (void) solver; } while(0);
  trace_and_check_binary_deletion (solver, lit, other);

  if (!redundant)
    {
      mark_eliminate_literal (solver, lit);
      mark_eliminate_literal (solver, other);
    }

  if (redundant)
    do { ((void)0); solver->statistics.redundant--; } while (0);
  else
    do { ((void)0); solver->statistics.irredundant--; } while (0);
}

static void
delete_binary (struct satch *solver,
        bool redundant, unsigned lit, unsigned other)
{






  if (lit < other)
    really_delete_binary (solver, redundant, lit, other);
}
# 3352 "upstream/satch.c"
static void
mark_garbage (struct satch *solver, struct clause *c, const char *msg)
{

  ((void)0);
  ((void)0);

  ((void)0);
  do { (void) solver; } while(0);
  c->garbage = 1;
  trace_and_check_deletion (solver, c->size, c->literals);
  if (c->redundant)
    do { ((void)0); solver->statistics.redundant--; } while (0);
  else
    do { ((void)0); solver->statistics.irredundant--; } while (0);

  if (!c->redundant)
    {
      mark_eliminate_clause (solver, c);
    }


  (void) msg;

}







static void
connect_literal (struct satch *solver, unsigned lit, struct clause *c)
{

  ((void)0);
# 3402 "upstream/satch.c"
  const union watch watch = {.clause = c };
  do { if (((solver->watches[lit]).end == (solver->watches[lit]).allocated)) do { const size_t old_size = ((size_t) ((solver->watches[lit]).end - (solver->watches[lit]).begin)); const size_t old_capacity = ((size_t) ((solver->watches[lit]).allocated - (solver->watches[lit]).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(solver->watches[lit]).begin; (solver->watches[lit]).begin = realloc ((solver->watches[lit]).begin, new_bytes); if (!(solver->watches[lit]).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (solver->watches[lit]).end = (solver->watches[lit]).begin + old_size; (solver->watches[lit]).allocated = (solver->watches[lit]).begin + new_capacity; } while (0); *(solver->watches[lit]).end++ = (watch); } while (0);
}

static void
connect_clause (struct satch *solver, struct clause *c)
{
  for (unsigned lit, * P_lit = ((c)->literals), * const END_lit = P_lit + ((c)->size); (P_lit != END_lit) && (lit = *P_lit, 1); ++P_lit)
    connect_literal (solver, lit, c);
}
# 3420 "upstream/satch.c"
static void
disconnect_literal (struct satch *solver, unsigned lit, struct clause *c)
{

  ((void)0);
# 3434 "upstream/satch.c"
  struct watches *watches = solver->watches + lit;
  const union watch *const end = watches->end;
  union watch *q = watches->begin;
  while (((void)0), q->clause != c)
    q++;
  while (++q != end)
    q[-1] = *q;
  watches->end--;
  if (((*watches).end == (*watches).begin))
    do { free ((*watches).begin); (*watches).begin = (*watches).end = (*watches).allocated = 0; } while (0);
}
# 3485 "upstream/satch.c"
static inline unsigned
assignement_level (struct satch *solver, unsigned lit, struct clause *reason)
{
  if (!reason

      || solver->vivifying

      )
    return solver->level;






  struct clause *fullreason;

  if (is_tagged_clause (reason))
    {
      const unsigned other = tagged_clause_to_literal (reason);
      ((void)0);
      do { (void) solver; } while(0);
      return solver->levels[INDEX (other)];
    }
  else

    fullreason = reason;
  unsigned level = 0;
  for (unsigned other, * P_other = ((fullreason)->literals), * const END_other = P_other + ((fullreason)->size); (P_other != END_other) && (other = *P_other, 1); ++P_other)
    {
      if (other == lit)
 continue;
      ((void)0);
      const unsigned tmp = solver->levels[INDEX (other)];
      if (tmp > level)
 level = tmp;
    }
  do { (void) solver; } while(0);
  return level;

}







static void
assign (struct satch *solver, unsigned lit, struct clause *reason,
 bool known_unit)
{
# 3561 "upstream/satch.c"
  const unsigned idx = INDEX (lit);
  const unsigned level =
    known_unit ? 0 : assignement_level (solver, lit, reason);
  if (!known_unit && !level)
    {
      do { (void) solver; } while(0);
      reason = 0;
    }
  known_unit = known_unit || !level;
  if (!solver->level || known_unit)
    {
      do { (void) solver; } while(0);
      solver->statistics.fixed++;

      ((void)0);
      solver->statistics.remaining--;

      struct flags *f = solver->flags + idx;
      ((void)0);
      f->active = 0;
      ((void)0);
      f->fixed = 1;

      trace_and_check_unit_addition (solver, lit);
      if (reason



 )
 {

   if (!is_tagged_clause (reason))

     mark_garbage (solver, reason, "root-level forcing");
   reason = 0;
 }
    }

  const unsigned not_lit = NOT (lit);
  ((void)0);
  ((void)0);





  solver->values[lit] = 1;
  solver->values[not_lit] = -1;





  if (!solver->vivifying)

    solver->saved[idx] = INT_SIGN (lit);

  solver->reasons[idx] = reason;
  solver->levels[idx] = level;


  solver->position[idx] = ((size_t) ((solver->trail).end - (solver->trail).begin));




  ((void)0);
  *solver->trail.end++ = lit;


  if (reason == 0 && solver->level && !known_unit)
    {
      do { (void) solver; } while(0)
                                                             ;
      struct level level = {.trail = solver->trail.end - 1,
 .lvl = solver->level,
 .seen = {.earliest = 4294967295U,.count = 0}
      };
      do { if (((solver->control).end == (solver->control).allocated)) do { const size_t old_size = ((size_t) ((solver->control).end - (solver->control).begin)); const size_t old_capacity = ((size_t) ((solver->control).allocated - (solver->control).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(solver->control).begin; (solver->control).begin = realloc ((solver->control).begin, new_bytes); if (!(solver->control).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (solver->control).end = (solver->control).begin + old_size; (solver->control).allocated = (solver->control).begin + new_capacity; } while (0); *(solver->control).end++ = (level); } while (0);
    }



  ((void)0);
  solver->unassigned--;


  ((void)0);

}
# 3662 "upstream/satch.c"
static void
activate_literals (struct satch *solver)
{
  struct flags *flags = solver->flags;
  for (unsigned lit, * PTR_lit = (solver->clause).begin, * const END_lit = (solver->clause).end; (PTR_lit != END_lit) && (lit = *PTR_lit, 1); ++PTR_lit)
    {
      const unsigned idx = INDEX (lit);
      struct flags *f = flags + idx;
      if (f->active)
 continue;
      f->active = 1;

      f->subsume = 1;
      ( ((void)0), ++solver->statistics.marked_subsume );


      f->eliminate = 1;
      ( ((void)0), ++solver->statistics.marked_eliminate );

      do { (void) solver; } while(0);


      do { if (((solver->put[0]).end == (solver->put[0]).allocated)) do { const size_t old_size = ((size_t) ((solver->put[0]).end - (solver->put[0]).begin)); const size_t old_capacity = ((size_t) ((solver->put[0]).allocated - (solver->put[0]).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(solver->put[0]).begin; (solver->put[0]).begin = realloc ((solver->put[0]).begin, new_bytes); if (!(solver->put[0]).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (solver->put[0]).end = (solver->put[0]).begin + old_size; (solver->put[0]).allocated = (solver->put[0]).begin + new_capacity; } while (0); *(solver->put[0]).end++ = (idx); } while (0);


      do { if (((solver->put[1]).end == (solver->put[1]).allocated)) do { const size_t old_size = ((size_t) ((solver->put[1]).end - (solver->put[1]).begin)); const size_t old_capacity = ((size_t) ((solver->put[1]).allocated - (solver->put[1]).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(solver->put[1]).begin; (solver->put[1]).begin = realloc ((solver->put[1]).begin, new_bytes); if (!(solver->put[1]).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (solver->put[1]).end = (solver->put[1]).begin + old_size; (solver->put[1]).allocated = (solver->put[1]).begin + new_capacity; } while (0); *(solver->put[1]).end++ = (idx); } while (0);


      solver->statistics.remaining++;
      solver->statistics.variables++;
      solver->unassigned++;
    }
}
# 3712 "upstream/satch.c"
static void
restamp_queue (struct satch *solver, struct queue *queue)
{
  const uint64_t restamped = ( ((void)0), ++solver->statistics.restamped );
  message (solver, 2, "restamp", restamped,
    "restamping indices in decision queue");
  struct link *links = queue->links, *link;
  unsigned stamp = 0;
  for (unsigned idx = queue->first; idx != 4294967295U; idx = link->next)
    {
      link = links + idx;
      ((void)0);
      link->stamp = ++stamp;
    }
  queue->search = queue->last;
  queue->stamp = stamp;
}







static void
enqueue (struct satch *solver, struct queue *queue, unsigned idx)
{
  do { (void) solver; } while(0);
  struct link *const links = queue->links;
  struct link *const link = links + idx;
  const unsigned last = queue->last;
  if (last == 4294967295U)
    {
      ((void)0);
      queue->first = idx;
    }
  else
    {
      struct link *const prev = links + last;
      ((void)0);
      prev->next = idx;
    }
  link->prev = last;
  queue->last = idx;
  link->next = 4294967295U;
# 3768 "upstream/satch.c"
  link->stamp = ++queue->stamp;



  if (link->stamp)

    {
      do { (void) solver; } while(0);
      const unsigned lit = LITERAL (idx);
      if (!solver->values[lit])
 queue->search = idx;
    }

  else
    restamp_queue (solver, queue);

}





static void
dequeue (struct satch *solver, struct queue *queue, unsigned idx)
{
  do { (void) solver; } while(0);
  struct link *const links = queue->links;
  struct link *const link = links + idx;
  const unsigned prev_idx = link->prev;
  const unsigned next_idx = link->next;
  if (prev_idx == 4294967295U)
    {
      ((void)0);
      queue->first = next_idx;
    }
  else
    {
      struct link *const prev = links + prev_idx;
      ((void)0);
      prev->next = next_idx;
    }
  if (next_idx == 4294967295U)
    {
      ((void)0);
      queue->last = prev_idx;
    }
  else
    {
      struct link *next = links + next_idx;
      ((void)0);
      next->prev = prev_idx;
    }
}
# 3831 "upstream/satch.c"
static void
resize_queue (struct queue *queue, size_t new_capacity)
{
  do { const size_t new_bytes = (size_t) new_capacity * sizeof *(queue->links); (queue->links) = realloc ((queue->links), new_bytes); if (!(queue->links)) out_of_memory (new_bytes); } while (0);
}

static void
init_queue (struct satch *solver, struct queue *queue)
{
  if (!queue->size)
    queue->first = queue->last = queue->search = 4294967295U;
  if (!queue->links)
    resize_queue (queue, solver->capacity);
}







static void
activate_queue (struct satch *solver, struct queue *queue,
  struct unsigned_stack *activate)
{
  init_queue (solver, queue);
  const unsigned stable = solver->stable;
  do { (void) solver; } while(0)
              ;
  for (unsigned idx, * PTR_idx = (*activate).begin, * const END_idx = (*activate).end; (PTR_idx != END_idx) && (idx = *PTR_idx, 1); ++PTR_idx)
    {
      ( ((void)0), ++solver->statistics.activated[stable] );
      enqueue (solver, queue, idx);
    }
  do { free ((*activate).begin); (*activate).begin = (*activate).end = (*activate).allocated = 0; } while (0);
  queue->size = solver->size;
}
# 3891 "upstream/satch.c"
static struct queue *
get_queue (struct satch *solver)
{
  const unsigned stable = solver->stable;
  struct queue *queue = &solver->queue[stable];

  struct unsigned_stack *activate = &solver->put[stable];
  if (!((*activate).end == (*activate).begin))
    activate_queue (solver, queue, activate);




  ((void)0);
  return queue;
}



static void
move_variable_to_front (struct satch *solver, unsigned idx)
{
  ( ((void)0), ++solver->statistics.moved );
  do { (void) solver; } while(0);
  struct queue *queue = get_queue (solver);
  dequeue (solver, queue, idx);
  enqueue (solver, queue, idx);
}



static void
release_queue (struct queue *queue)
{
  free (queue->links);
}
# 3961 "upstream/satch.c"
static void
resize_trail (struct trail *trail, size_t new_capacity)
{
  ((void)0);
  const size_t size = ((size_t) ((*trail).end - (*trail).begin));
  const size_t bytes = new_capacity * sizeof (unsigned);
  const unsigned propagate = trail->propagate - trail->begin;
  trail->begin = realloc (trail->begin, bytes);
  if (!trail->begin)
    out_of_memory (bytes);
  trail->end = trail->begin + size;
  trail->propagate = trail->begin + propagate;
}
# 3983 "upstream/satch.c"
static void
increase_capacity (struct satch *solver, unsigned new_capacity)
{
  const unsigned old_capacity = solver->capacity;
  do { (void) solver; } while(0);
  ((void)0);
  ((void)0);
  do { const size_t size = sizeof *(solver->watches); const size_t old_bytes = old_capacity ? 2 * (size_t) (old_capacity + 0) * size : 0; const size_t new_bytes = 2 * (size_t) (new_capacity + 0) * size; void * chunk = calloc (new_bytes, 1); if (!chunk) out_of_memory (new_bytes); if (old_bytes) memcpy (chunk, (solver->watches), old_bytes); free ((solver->watches)); (solver->watches) = chunk; } while (0);
  do { const size_t size = sizeof *(solver->reasons); const size_t old_bytes = old_capacity ? 1 * (size_t) (old_capacity + 0) * size : 0; const size_t new_bytes = 1 * (size_t) (new_capacity + 0) * size; void * chunk = calloc (new_bytes, 1); if (!chunk) out_of_memory (new_bytes); if (old_bytes) memcpy (chunk, (solver->reasons), old_bytes); free ((solver->reasons)); (solver->reasons) = chunk; } while (0);
  do { const size_t size = sizeof *(solver->levels); const size_t old_bytes = old_capacity ? 1 * (size_t) (old_capacity + 0) * size : 0; const size_t new_bytes = 1 * (size_t) (new_capacity + 0) * size; void * chunk = calloc (new_bytes, 1); if (!chunk) out_of_memory (new_bytes); if (old_bytes) memcpy (chunk, (solver->levels), old_bytes); free ((solver->levels)); (solver->levels) = chunk; } while (0);
  do { const size_t size = sizeof *(solver->values); const size_t old_bytes = old_capacity ? 2 * (size_t) (old_capacity + 0) * size : 0; const size_t new_bytes = 2 * (size_t) (new_capacity + 0) * size; void * chunk = calloc (new_bytes, 1); if (!chunk) out_of_memory (new_bytes); if (old_bytes) memcpy (chunk, (solver->values), old_bytes); free ((solver->values)); (solver->values) = chunk; } while (0);

  do { const size_t size = sizeof *(solver->saved); const size_t old_bytes = old_capacity ? 1 * (size_t) (old_capacity + 0) * size : 0; const size_t new_bytes = 1 * (size_t) (new_capacity + 0) * size; void * chunk = calloc (new_bytes, 1); if (!chunk) out_of_memory (new_bytes); if (old_bytes) memcpy (chunk, (solver->saved), old_bytes); free ((solver->saved)); (solver->saved) = chunk; } while (0);


  do { const size_t size = sizeof *(solver->targets); const size_t old_bytes = old_capacity ? 1 * (size_t) (old_capacity + 0) * size : 0; const size_t new_bytes = 1 * (size_t) (new_capacity + 0) * size; void * chunk = calloc (new_bytes, 1); if (!chunk) out_of_memory (new_bytes); if (old_bytes) memcpy (chunk, (solver->targets), old_bytes); free ((solver->targets)); (solver->targets) = chunk; } while (0);


  do { const size_t size = sizeof *(solver->bests); const size_t old_bytes = old_capacity ? 1 * (size_t) (old_capacity + 0) * size : 0; const size_t new_bytes = 1 * (size_t) (new_capacity + 0) * size; void * chunk = calloc (new_bytes, 1); if (!chunk) out_of_memory (new_bytes); if (old_bytes) memcpy (chunk, (solver->bests), old_bytes); free ((solver->bests)); (solver->bests) = chunk; } while (0);

  do { const size_t size = sizeof *(solver->marks); const size_t old_bytes = old_capacity ? 1 * (size_t) (old_capacity + 0) * size : 0; const size_t new_bytes = 1 * (size_t) (new_capacity + 0) * size; void * chunk = calloc (new_bytes, 1); if (!chunk) out_of_memory (new_bytes); if (old_bytes) memcpy (chunk, (solver->marks), old_bytes); free ((solver->marks)); (solver->marks) = chunk; } while (0);
  do { const size_t size = sizeof *(solver->flags); const size_t old_bytes = old_capacity ? 1 * (size_t) (old_capacity + 0) * size : 0; const size_t new_bytes = 1 * (size_t) (new_capacity + 0) * size; void * chunk = calloc (new_bytes, 1); if (!chunk) out_of_memory (new_bytes); if (old_bytes) memcpy (chunk, (solver->flags), old_bytes); free ((solver->flags)); (solver->flags) = chunk; } while (0);
  do { const size_t size = sizeof *(solver->frames); const size_t old_bytes = old_capacity ? 1 * (size_t) (old_capacity + 1) * size : 0; const size_t new_bytes = 1 * (size_t) (new_capacity + 1) * size; void * chunk = calloc (new_bytes, 1); if (!chunk) out_of_memory (new_bytes); if (old_bytes) memcpy (chunk, (solver->frames), old_bytes); free ((solver->frames)); (solver->frames) = chunk; } while (0);

  do { const size_t new_bytes = (size_t) new_capacity * sizeof *(solver->position); (solver->position) = realloc ((solver->position), new_bytes); if (!(solver->position)) out_of_memory (new_bytes); } while (0);

  resize_trail (&solver->trail, new_capacity);



  if (solver->queue[0].size)
    resize_queue (&solver->queue[0], new_capacity);







  ((void)0);
# 4031 "upstream/satch.c"
  ((void)0);


  if (solver->scores[1].size)
    resize_heap (&solver->scores[1], old_capacity, new_capacity);





  do { const size_t size = sizeof *(solver->vivify_marks); const size_t old_bytes = old_capacity ? 1 * (size_t) (old_capacity + 0) * size : 0; const size_t new_bytes = 1 * (size_t) (new_capacity + 0) * size; void * chunk = calloc (new_bytes, 1); if (!chunk) out_of_memory (new_bytes); if (old_bytes) memcpy (chunk, (solver->vivify_marks), old_bytes); free ((solver->vivify_marks)); (solver->vivify_marks) = chunk; } while (0);

  solver->capacity = new_capacity;
}





static void
increase_size (struct satch *solver, unsigned new_size)
{




  const unsigned old_capacity = solver->capacity;
  ((void)0);
  if (new_size > old_capacity)
    {
      unsigned new_capacity;
      if (new_size > 1u << 30)
 new_capacity = 1u << 31;
      else
 {



   ((void)0);
   new_capacity = 1;

   while (new_size > new_capacity)
     {
       ((void)0);
       new_capacity *= 2;
     }
 }
      increase_capacity (solver, new_capacity);
    }
  ((void)0);
  do { (void) solver; } while(0);
  solver->size = new_size;
}







static void
mark_literal (signed char *marks, unsigned lit)
{
  const unsigned idx = INDEX (lit);
  ((void)0);
  marks[idx] = INT_SIGN (lit);
}

static signed char
marked_literal (const signed char *marks, unsigned lit)
{
  const unsigned idx = INDEX (lit);
  signed char res = marks[idx];
  if (SIGN_BIT (lit))
    res = -res;
  return res;
}

static void
unmark_literal (signed char *marks, unsigned lit)
{
  const unsigned idx = INDEX (lit);
  marks[idx] = 0;
}







static bool
imported_clause_trivial_or_satisfied (struct satch *solver)
{
  ((void)0);
  const unsigned *const end_clause = solver->clause.end;
  unsigned *const begin_clause = solver->clause.begin;
  unsigned *q = begin_clause;
  bool trivial = 0;
  signed char *const marks = solver->marks;
  const signed char *const values = solver->values;
  for (const unsigned *p = begin_clause; p != end_clause; p++)
    {
      const unsigned lit = *p;
      const signed char value = values[lit];
      if (value < 0)
 {
   do { (void) solver; } while(0);
   continue;
 }
      if (value > 0)
 {
   do { (void) solver; } while(0);
   trivial = 1;
   break;
 }
      const signed char prev = marked_literal (marks, lit);
      if (prev > 0)
 {
   do { (void) solver; } while(0);
   continue;
 }
      if (prev < 0)
 {
   do { (void) solver; } while(0)
                                         ;
   trivial = 1;
   break;
 }
      *q++ = lit;
      mark_literal (marks, lit);
    }
  solver->clause.end = q;
  for (const unsigned *p = begin_clause; p != q; p++)
    unmark_literal (marks, *p);
  return trivial;
}
# 4178 "upstream/satch.c"
static unsigned
import_literal (struct satch *solver, int elit)
{
  ((void)0);
  ((void)0);
  const int eidx = abs (elit);
  const unsigned iidx = eidx - 1;
  if (iidx >= solver->size)
    increase_size (solver, iidx + 1);
  unsigned ilit = LITERAL (iidx);
  if (elit < 0)
    ilit = NOT (ilit);
  do { (void) solver; } while(0);
  return ilit;
}
# 4212 "upstream/satch.c"
static inline size_t
cache_lines (const void *begin, const void *end)
{
  ((void)0);
  const size_t round = (1u << 7) - 1;
  const size_t bytes = (char *) end - (char *) begin;
  const size_t res = (bytes + round) >> 7;
  return res;
}
# 4238 "upstream/satch.c"
static struct clause *
propagate_literal (struct satch *solver, unsigned lit,
     struct clause *ignore, uint64_t * ticking)
{
  do { (void) solver; } while(0);

  const unsigned not_lit = NOT (lit);
  struct watches *const watches = solver->watches + not_lit;
  signed char *const values = solver->values;


  if (!solver->vivifying)

    ((void)0);





  union watch *q = watches->begin;
  const union watch *p = q;

  struct clause *conflict = 0;

  const union watch *const end_watches = watches->end;
# 4282 "upstream/satch.c"
  uint64_t ticks = 1 + cache_lines (q, end_watches);

  while (!conflict && p != end_watches)
    {

      const union watch watch = *q++ = *p++;
      const struct header header = watch.header;
      const unsigned blocking_lit = header.blocking;
      const signed char blocking_value = values[blocking_lit];





      if (header.binary)
 {
   if (blocking_value < 0)
     {
       conflict = binary_clause (solver, 0,
     header.redundant,
     not_lit, blocking_lit);
       do { (void) solver; } while(0);
     }
   else if (!blocking_value)
     {
       ((void)0);
       assign (solver, blocking_lit,
        tag_binary_clause (header.redundant, not_lit), 0);
       ticks++;
     }



   continue;
 }
      else




 {
   struct clause *clause = (*q++ = *p++).clause;
   if (clause->garbage)
     do { (void) solver; } while(0);
   ((void)0);
   if (clause == ignore) {
     continue;
    }

   if (blocking_value > 0)
     continue;

   unsigned *const literals = clause->literals;
# 4347 "upstream/satch.c"
   ticks++;







   const unsigned other = literals[0] ^ literals[1] ^ not_lit;
   const signed char other_value = values[other];






   if (other_value > 0)
     {

       q[-2].header.blocking = other;

       continue;
     }



   literals[0] = other;
   literals[1] = not_lit;

   const unsigned size = clause->size;
   const unsigned *const end_literals = literals + size;




   unsigned replacement = 4294967295U;
   signed char replacement_value = -1;
   const unsigned *end_search = end_literals;
   unsigned *start_search = literals + 2, *r;







   start_search += clause->search;

   for (r = start_search; r != end_search; r++)
     {
       replacement = *r;
       replacement_value = values[replacement];
       if (replacement_value >= 0)
  break;
     }

   if (replacement_value < 0)
     {
       end_search = start_search;
       start_search = literals + 2;

       for (r = start_search; r != end_search; r++)
  {
    replacement = *r;
    replacement_value = values[replacement];
    if (replacement_value >= 0)
      {
        clause->search = r - start_search;
        break;
      }
  }
     }
   else
     clause->search = r - start_search;

   if (replacement_value > 0)
     {



       q[-2].header.blocking = replacement;

     }
   else if (!replacement_value)
     {
# 4440 "upstream/satch.c"
       do { (void) solver; } while(0);
       q -= 2;



       literals[1] = replacement;
       *r = not_lit;


       const bool redundant = clause->redundant;
       watch_literal (solver, redundant, replacement, other, clause);



       ticks++;
     }
   else if (other_value)
     {


       ((void)0);
       do { (void) solver; } while(0);
       conflict = clause;
     }
   else
     {



       ((void)0);
       assign (solver, other, clause, 0);
       ticks++;
     }
 }
    }

  *ticking += ticks;




  while (p != end_watches)
    *q++ = *p++;
  watches->end = q;

  return conflict;
}
# 4596 "upstream/satch.c"
static void
flush_units (struct satch *solver)
{
  struct trail *trail = &solver->trail;

  ((void)0);
  ((void)0);
  unsigned *new_start = trail->begin;
  while (new_start < trail->end && !solver->levels[INDEX (*new_start)])
    {
      ++new_start;
    }
  const long int delta = new_start - trail->begin;
  trail->propagate -= delta;
  ((void)0);
  do { (void) solver; } while(0);
  unsigned *lit = trail->begin;

  while (new_start != trail->end)
    *(lit++) = *(new_start++);

  for (struct level * lvl = solver->control.begin; lvl != solver->control.end;
       ++lvl)
    {
      lvl->trail -= delta;
      ((void)0);
    }
  ((void)0);
  trail->end = lit;
  ((void)0);
  ((void)0);
  ((void)0);







}
# 4648 "upstream/satch.c"
static struct clause *
boolean_constraint_propagation (struct satch *solver)
{
  do { (void) solver; } while(0);
  struct trail *trail = &solver->trail;
  unsigned *propagate = trail->propagate;
  unsigned *p;

  ((void)0);
  ((void)0);

  struct clause *conflict = 0;
  uint64_t ticks = 0;

  for (p = propagate; !conflict && p != trail->end; p++)
    conflict = propagate_literal (solver, *p, 0, &ticks);

  do { ((void)0); solver->statistics.ticks += (ticks); } while (0);
  solver->trail.propagate = p;
  const unsigned propagated = p - propagate;

  do { ((void)0); solver->statistics.propagations += (propagated); } while (0);

  if (conflict)
    ( ((void)0), ++solver->statistics.conflicts );
  else if (!solver->level

    || solver->iterate

    )
    flush_units (solver);

  return conflict;
}
# 4691 "upstream/satch.c"
static void
save_phases (struct satch *solver, signed char *phases)
{
  const signed char *end = solver->values + (2u*(solver->size));
  signed char *q = phases, tmp;
  for (const signed char *p = solver->values; p != end; p += 2, q++)
    if ((tmp = *p))
      *q = tmp;
  ((void)0);
}

static void
update_target_phases (struct satch *solver, const unsigned assigned)
{
  const uint64_t targets = ( ((void)0), ++solver->statistics.targets );
  save_phases (solver, solver->targets);
  solver->target = assigned;
  message (solver, 3, "target", targets, "targeting %u assigned variables "
    "%.0f%% after %" "lu" " conflicts", assigned,
    percent (assigned, (solver->size)), (solver->statistics.conflicts));
}



static void
update_best_phases (struct satch *solver, const unsigned assigned)
{
  const uint64_t bests = ( ((void)0), ++solver->statistics.bests );
  save_phases (solver, solver->bests);
  solver->best = assigned;
  message (solver, 3, "best", bests, "best trail %u assigned variables "
    "%.0f%% after %" "lu" " conflicts", assigned,
    percent (assigned, (solver->size)), (solver->statistics.conflicts));
}
# 4733 "upstream/satch.c"
static inline unsigned
assigned_variables (struct satch *solver)
{
  ((void)0);
  return (solver->size) - solver->unassigned;
}

static void
update_phases (struct satch *solver)
{
  ((void)0);
  const unsigned assigned = assigned_variables (solver);
  if (assigned > solver->target)
    update_target_phases (solver, assigned);

  if (assigned > solver->best)
    update_best_phases (solver, assigned);

}
# 4772 "upstream/satch.c"
static void
backtrack (struct satch *solver, unsigned new_level)
{
  do { (void) solver; } while(0);
  ((void)0);

  const unsigned *levels = solver->levels;

  signed char *values = solver->values;


  struct queue *queue = 0;
  const struct link *links = 0;
  unsigned search = 4294967295U;
  unsigned max_stamp = 4294967295U;

  if (!solver->stable)

    {
      queue = get_queue (solver);
      links = queue->links;
      search = queue->search;
      max_stamp = search == 4294967295U ? 0 : links[search].stamp;
    }



  struct heap *scores = 0;
  const unsigned *pos = 0;

  if (solver->stable)

    {
      scores = get_scores (solver);
      pos = scores->pos;
    }
# 4817 "upstream/satch.c"
  struct trail *trail = &solver->trail;

  unsigned *target_lit = ((solver->control).begin[((void)0), (new_level)]).trail;
  ((void)0);
  ((void)0);
  ((void)0);
  unsigned *starting = target_lit;



  unsigned *position = solver->position;
  int starting_position = target_lit - solver->trail.begin;
  do { (void) solver; } while(0);



  trail->propagate = target_lit;
  int reassigned = 0;



  while (target_lit != solver->trail.end)
    {
      const unsigned lit = *target_lit;



      ++target_lit;
      const unsigned idx = INDEX (lit);
      ((void)0);

      const unsigned lit_level = levels[idx];
# 4863 "upstream/satch.c"
      do { (void) solver; } while(0);
      ((void)0);

      ((void)0);
      ((void)0);
      if (lit_level <= new_level)
 {
   do { (void) solver; } while(0);
   *starting = lit;
   position[idx] = starting_position;
   ++reassigned;
   ++starting;
   ++starting_position;




   continue;
 }
      do { (void) solver; } while(0);



      solver->unassigned++;
      const unsigned not_lit = NOT (lit);


      ((void)0);
      ((void)0);






      ((void)0);

      values[lit] = 0;
      values[not_lit] = 0;
# 4916 "upstream/satch.c"
      if (links)
 {
   const unsigned stamp = links[idx].stamp;
   if (stamp > max_stamp)
     search = idx, max_stamp = stamp;
 }


      if (pos && pos[idx] == 4294967295U)
 push_heap (solver, scores, idx);
# 4934 "upstream/satch.c"
    }


  solver->trail.end = starting;
# 4946 "upstream/satch.c"
  if (queue)
    {
      do { (void) solver; } while(0);
      queue->search = search;
    }



  solver->control.end = solver->control.begin + new_level;
  ((void)0);
# 4966 "upstream/satch.c"
  ((void)0);

  solver->level = new_level;
}



static void
update_phases_and_backtrack_to_root_level (struct satch *solver)
{
  if (!solver->level)
    return;

  if (solver->stable)
    update_phases (solver);

  backtrack (solver, 0);


  const struct clause *conflict = boolean_constraint_propagation (solver);
  if (conflict)
    solver->inconsistent = 1;

}
# 5004 "upstream/satch.c"
const double slow_beta = 1.0 - 1e-5;







static struct averages *
averages (struct satch *solver)
{
  return solver->averages + solver->stable;
}

static void
update_slow_average (double *average, unsigned value)
{
  *average += 1e-5 * (value - *average);
}

static double
unbiased_slow_average (struct averages *a, double avg)
{
  const double div = 1 - a->slow_exp;
  return !div ? 0 : div == 1 ? avg : avg / div;
}





const double fast_beta = 1.0 - 3e-2;

static void
update_fast_average (double *average, unsigned value)
{
  *average += 3e-2 * (value - *average);
}

static double
unbiased_fast_average (struct averages *a, double avg)
{
  const double div = 1 - a->fast_exp;
  return !div ? 0 : div == 1 ? avg : avg / div;
}







static void
update_betas (struct satch *solver)
{
  struct averages *a = averages (solver);

  if (a->fast_exp)
    a->fast_exp *= fast_beta;

  if (a->slow_exp)
    a->slow_exp *= slow_beta;
}

static void
init_one_set_of_averages (struct averages *a)
{
  a->slow_exp = 1.0;

  a->fast_exp = 1.0;

}

static void
init_averages (struct satch *solver)
{
  for (int i = 0; i < 2; i++)
    init_one_set_of_averages (&solver->averages[i]);
}
# 5098 "upstream/satch.c"
static void
sort_deduced_clause (struct satch *solver)
{
  const unsigned *const levels = solver->levels;
  do { const size_t N_RANK = ((size_t) ((solver->clause).end - (solver->clause).begin)); if (N_RANK <= 1) break; unsigned * V_RANK = (solver->clause).begin; const size_t LENGTH_RANK = 8; const size_t WIDTH_RANK = (1 << LENGTH_RANK); const unsigned MASK_RANK = WIDTH_RANK - 1; size_t COUNT_RANK[WIDTH_RANK]; unsigned * TMP_RANK = 0; const size_t BYTES_TMP_RANK = N_RANK * sizeof (unsigned); unsigned * A_RANK = V_RANK; unsigned * B_RANK = 0; unsigned * C_RANK = A_RANK; unsigned MLOWER_RANK = 0; unsigned MUPPER_RANK = MASK_RANK; bool BOUNDED_RANK = 0; unsigned UPPER_RANK = 0; unsigned LOWER_RANK = ~UPPER_RANK; unsigned SHIFT_RANK = MASK_RANK; for (size_t I_RANK = 0; I_RANK < 8 * sizeof (unsigned); I_RANK += LENGTH_RANK, SHIFT_RANK <<= LENGTH_RANK) { if (BOUNDED_RANK && (LOWER_RANK & SHIFT_RANK) == (UPPER_RANK & SHIFT_RANK)) continue; memset (COUNT_RANK + MLOWER_RANK, 0, (MUPPER_RANK - MLOWER_RANK + 1) * sizeof *COUNT_RANK); unsigned * END_RANK = C_RANK + N_RANK; bool SORTED_RANK = 1; unsigned LAST_RANK = 0; for (unsigned * P_RANK = C_RANK; P_RANK != END_RANK; P_RANK++) { unsigned R_RANK = (~levels[INDEX (*P_RANK)]); if (!BOUNDED_RANK) { LOWER_RANK &= R_RANK; UPPER_RANK |= R_RANK; } unsigned S_RANK = R_RANK >> I_RANK; unsigned M_RANK = S_RANK & MASK_RANK; if (SORTED_RANK && LAST_RANK > M_RANK) SORTED_RANK = 0; else LAST_RANK = M_RANK; COUNT_RANK[M_RANK]++; } MLOWER_RANK = (LOWER_RANK >> I_RANK) & MASK_RANK; MUPPER_RANK = (UPPER_RANK >> I_RANK) & MASK_RANK; if (!BOUNDED_RANK) { BOUNDED_RANK = 1; if ((LOWER_RANK & SHIFT_RANK) == (UPPER_RANK & SHIFT_RANK)) continue; } if (SORTED_RANK) continue; size_t POS_RANK = 0; for (size_t J_RANK = MLOWER_RANK; J_RANK <= MUPPER_RANK; J_RANK++) { const size_t DELTA_RANK = COUNT_RANK[J_RANK]; COUNT_RANK[J_RANK] = POS_RANK; POS_RANK += DELTA_RANK; } if (!TMP_RANK) { ((void)0); TMP_RANK = malloc (BYTES_TMP_RANK); if (!TMP_RANK) out_of_memory (BYTES_TMP_RANK); B_RANK = TMP_RANK; } ((void)0); unsigned * D_RANK = (C_RANK == A_RANK) ? B_RANK : A_RANK; for (unsigned * P_RANK = C_RANK; P_RANK != END_RANK; P_RANK++) { unsigned R_RANK = (~levels[INDEX (*P_RANK)]); unsigned S_RANK = R_RANK >> I_RANK; unsigned M_RANK = S_RANK & MASK_RANK; const size_t POS_RANK = COUNT_RANK[M_RANK]++; D_RANK[POS_RANK] = *P_RANK; } C_RANK = D_RANK; } if (C_RANK == B_RANK) memcpy (A_RANK, B_RANK, N_RANK * sizeof *A_RANK); if (TMP_RANK) free (TMP_RANK); do { } while (0); } while (0);
}
# 5178 "upstream/satch.c"
static void
mark_removable (struct satch *solver, unsigned idx)
{
  ((void)0);
  solver->marks[idx] |= 2;
  do { if (((solver->removable).end == (solver->removable).allocated)) do { const size_t old_size = ((size_t) ((solver->removable).end - (solver->removable).begin)); const size_t old_capacity = ((size_t) ((solver->removable).allocated - (solver->removable).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(solver->removable).begin; (solver->removable).begin = realloc ((solver->removable).begin, new_bytes); if (!(solver->removable).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (solver->removable).end = (solver->removable).begin + old_size; (solver->removable).allocated = (solver->removable).begin + new_capacity; } while (0); *(solver->removable).end++ = (idx); } while (0);
  do { (void) solver; } while(0);
}

static void
mark_poisoned (struct satch *solver, unsigned idx)
{
  ((void)0);
  solver->marks[idx] |= 4;
  do { if (((solver->poisoned).end == (solver->poisoned).allocated)) do { const size_t old_size = ((size_t) ((solver->poisoned).end - (solver->poisoned).begin)); const size_t old_capacity = ((size_t) ((solver->poisoned).allocated - (solver->poisoned).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(solver->poisoned).begin; (solver->poisoned).begin = realloc ((solver->poisoned).begin, new_bytes); if (!(solver->poisoned).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (solver->poisoned).end = (solver->poisoned).begin + old_size; (solver->poisoned).allocated = (solver->poisoned).begin + new_capacity; } while (0); *(solver->poisoned).end++ = (idx); } while (0);
  do { (void) solver; } while(0);
}
# 5209 "upstream/satch.c"
static int
minimize_literal (struct satch *solver, unsigned lit, unsigned depth)
{
  const unsigned idx = INDEX (lit);
  signed char mark = solver->marks[idx];
  ((void)0);
  if (mark & 4)
    return 4;
  if (mark & 2)
    return 2;
  if (depth && (mark & 1))
    return 2;
  const unsigned level = solver->levels[idx];
  if (!level)
    return 2;
  if (depth > 1e4)
    return 4;

  if (!depth && ((solver->control).begin[((void)0), (level - 1)]).seen.count < 2)
    return 4;
  if (solver->position[idx] <=
      ((solver->control).begin[((void)0), (level - 1)]).seen.earliest)
    return 4;

  ((void)0);
  struct clause *reason = solver->reasons[idx];
  if (!reason)
    return 4;
  if (!solver->frames[level])
    return 4;
  int res = 2;

  if (is_tagged_clause (reason))
    reason = untag_clause (solver, 0, NOT (lit), reason);
  else

    ( ((void)0), ++solver->statistics.ticks );
  const unsigned not_lit = NOT (lit);
  do { (void) solver; } while(0)
                           ;
  for (unsigned other, * P_other = ((reason)->literals), * const END_other = P_other + ((reason)->size); (P_other != END_other) && (other = *P_other, 1); ++P_other)
    {
      if (other == not_lit)
 continue;
      if (minimize_literal (solver, other, depth + 1) == 2)
 continue;
      res = 4;
      break;
    }
  if (depth)
    {
      if (res == 2)
 mark_removable (solver, idx);
      else
 mark_poisoned (solver, idx);
    }
  do { (void) solver; } while(0)
                                                                          ;
  return res;
}
# 5310 "upstream/satch.c"
static void
reset_removable_and_poisoned (struct satch *solver)
{
  for (unsigned idx, * PTR_idx = (solver->poisoned).begin, * const END_idx = (solver->poisoned).end; (PTR_idx != END_idx) && (idx = *PTR_idx, 1); ++PTR_idx)
      solver->marks[idx] &= ~4;
  do { (solver->poisoned).end = (solver->poisoned).begin; } while (0);

  for (unsigned idx, * PTR_idx = (solver->removable).begin, * const END_idx = (solver->removable).end; (PTR_idx != END_idx) && (idx = *PTR_idx, 1); ++PTR_idx)
      solver->marks[idx] &= ~2;
  do { (solver->removable).end = (solver->removable).begin; } while (0);
}
# 5333 "upstream/satch.c"
static void
mark_analyzed (struct satch *solver, unsigned idx)
{
  ((void)0);
  solver->marks[idx] |= 1;
  struct analyzed analyzed;
  analyzed.idx = idx;

  analyzed.stamp = 4294967295U;

  do { if (((solver->analyzed).end == (solver->analyzed).allocated)) do { const size_t old_size = ((size_t) ((solver->analyzed).end - (solver->analyzed).begin)); const size_t old_capacity = ((size_t) ((solver->analyzed).allocated - (solver->analyzed).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(solver->analyzed).begin; (solver->analyzed).begin = realloc ((solver->analyzed).begin, new_bytes); if (!(solver->analyzed).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (solver->analyzed).end = (solver->analyzed).begin + old_size; (solver->analyzed).allocated = (solver->analyzed).begin + new_capacity; } while (0); *(solver->analyzed).end++ = (analyzed); } while (0);
  do { (void) solver; } while(0);
}

static inline unsigned
analyze_literal (struct satch *solver, unsigned lit)
{
  const unsigned idx = INDEX (lit);
  const unsigned lit_level = solver->levels[idx];
  if (!lit_level)
    return 4294967295U;
  if (solver->marks[idx])
    return 4294967295U;
  mark_analyzed (solver, idx);
  return lit_level;
}
# 5372 "upstream/satch.c"
static void
mark_shrunken (struct satch *solver, unsigned idx)
{
  ((void)0);
  solver->marks[idx] |= 8;
  do { if (((solver->shrunken).end == (solver->shrunken).allocated)) do { const size_t old_size = ((size_t) ((solver->shrunken).end - (solver->shrunken).begin)); const size_t old_capacity = ((size_t) ((solver->shrunken).allocated - (solver->shrunken).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(solver->shrunken).begin; (solver->shrunken).begin = realloc ((solver->shrunken).begin, new_bytes); if (!(solver->shrunken).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (solver->shrunken).end = (solver->shrunken).begin + old_size; (solver->shrunken).allocated = (solver->shrunken).begin + new_capacity; } while (0); *(solver->shrunken).end++ = (idx); } while (0);
  do { (void) solver; } while(0);
}



static void
reset_shrunken (struct satch *solver)
{
  do { (void) solver; } while(0);
  signed char *marks = solver->marks;
  for (unsigned idx, * PTR_idx = (solver->shrunken).begin, * const END_idx = (solver->shrunken).end; (PTR_idx != END_idx) && (idx = *PTR_idx, 1); ++PTR_idx)
      marks[idx] &= ~8;
  do { (solver->shrunken).end = (solver->shrunken).begin; } while (0);
}



static void
mark_shrunken_as_removable (struct satch *solver)
{
  signed char *marks = solver->marks;
  for (unsigned idx, * PTR_idx = (solver->shrunken).begin, * const END_idx = (solver->shrunken).end; (PTR_idx != END_idx) && (idx = *PTR_idx, 1); ++PTR_idx)
    if (!(marks[idx] & 2))
        mark_removable (solver, idx);
}
# 5416 "upstream/satch.c"
static int
shrink_literal (struct satch *solver, unsigned block_level, unsigned lit)
{
  const unsigned idx = INDEX (lit);
  const unsigned lit_level = solver->levels[idx];
  if (!lit_level)
    return 0;
  if (solver->marks[idx] & 8)
    return 0;
  if (lit_level < block_level)
    return (minimize_literal (solver, lit, 1) == 2) ? 0 : -1;
  mark_shrunken (solver, idx);
  return 1;
}





static void
shrunken_block (struct satch *solver,
  unsigned *begin, unsigned *end, unsigned uip)
{
  for (unsigned *p = begin; p != end; p++)
    *p = 4294967295U;
  *begin = NOT (uip);
  const unsigned idx = INDEX (uip);
  if (!(solver->marks[idx] & 1))
    mark_analyzed (solver, idx);

  const unsigned level = solver->levels[idx];
  if (level != 0)
    {
      struct level *saved = &((solver->control).begin[((void)0), (level - 1)]);
      if (saved->seen.earliest > solver->position[idx])
 saved->seen.earliest = solver->position[idx];
      ++saved->seen.count;
      do { (void) solver; } while(0)
                      ;
    }

  mark_shrunken_as_removable (solver);
  reset_shrunken (solver);
}




static unsigned *
next_block (struct satch *solver, unsigned *end)
{
  const unsigned *const levels = solver->levels;
  unsigned block_level = 4294967295U;
  unsigned *begin = end;
  while (solver->clause.begin < begin)
    {
      const unsigned lit = begin[-1];
      const unsigned idx = INDEX (lit);
      const unsigned lit_level = levels[idx];
      if (lit_level > block_level)
 break;
      block_level = lit_level;
      begin--;
    }
  return begin;
}




static bool
shrink_block (struct satch *solver, unsigned *begin, unsigned *end)
{
  ((void)0);
  unsigned open = end - begin;
  if (open < 2)
    return 1;

  const unsigned block_level = solver->levels[INDEX (*begin)];
  do { (void) solver; } while(0);




  unsigned trail = 0;
  {
    const unsigned *const position = solver->position;
    ((void)0);
    for (unsigned *p = begin; p != end; p++)
      {
 const unsigned lit = *p;
 const unsigned idx = INDEX (lit);
 mark_shrunken (solver, idx);

 const unsigned pos = position[idx];
 ((void)0);
 if (pos > trail)
   trail = pos;
      }
    ((void)0);
  }
# 5530 "upstream/satch.c"
  const unsigned *t = solver->trail.begin + trail;
  unsigned uip = 4294967295U;
  bool failed = 0;

  const signed char *const marks = solver->marks;
  struct clause *const *const reasons = solver->reasons;

  while (!failed)
    {
      unsigned idx;
      do
 ((void)0), uip = *t--;
      while (!(marks[idx = INDEX (uip)] & 8));
      if (!--open)
 break;
      struct clause *reason = reasons[idx];
      ((void)0);

      if (is_tagged_clause (reason))
 reason = untag_clause (solver, 0, uip, reason);
      else

 ( ((void)0), ++solver->statistics.ticks );
      do { (void) solver; } while(0);
      for (unsigned lit, * P_lit = ((reason)->literals), * const END_lit = P_lit + ((reason)->size); (P_lit != END_lit) && (lit = *P_lit, 1); ++P_lit)
 if (lit != uip)
   {
     int tmp = shrink_literal (solver, block_level, lit);
     if ((failed = (tmp < 0)))
       break;
     open += (tmp > 0);
   }
    }

  if (failed)
    reset_shrunken (solver);
  else
    shrunken_block (solver, begin, end, uip);

  do { (void) solver; } while(0)
                                                                            ;

  return !failed;
}



static void
minimize_block (struct satch *solver, unsigned *begin, unsigned *end)
{
  unsigned minimized = 0;
  for (unsigned *p = begin; p != end; p++)
    if (minimize_literal (solver, *p, 0) == 2)
      *p = 4294967295U, minimized++;
  do { ((void)0); solver->statistics.minimized += (minimized); } while (0);
  do { (void) solver; } while(0);
}





static void
shrink_deduced_clause (struct satch *solver)
{
  ((void)0);
  ((void)0);

  {
    unsigned *end = solver->clause.end;
    while (end != solver->clause.begin)
      {
 unsigned *begin = next_block (solver, end);
 if (!shrink_block (solver, begin, end))
   minimize_block (solver, begin, end);
 end = begin;
      }
  }




  {
    const unsigned *const end = solver->clause.end;
    unsigned *q = solver->clause.begin, lit;
    for (const unsigned *p = q; p != end; p++)
      if ((lit = *p) != 4294967295U)
 *q++ = lit;

    const unsigned shrunken = end - q;
    solver->clause.end = q;
    do { (void) solver; } while(0);
    do { ((void)0); solver->statistics.shrunken += (shrunken); } while (0);
  }

  do { (void) solver; } while(0);
}
# 5641 "upstream/satch.c"
static inline void
bump_reason_side_literals (struct satch *solver)
{
  struct averages *a = averages (solver);
  if (unbiased_slow_average (a, a->decision_rate) >=
      10)
    return;

  struct clause *const *const reasons = solver->reasons;
  for (unsigned lit, * PTR_lit = (solver->clause).begin, * const END_lit = (solver->clause).end; (PTR_lit != END_lit) && (lit = *PTR_lit, 1); ++PTR_lit)
    {
      const unsigned idx = INDEX (lit);
      struct clause *reason = reasons[idx];

      if (is_tagged_clause (reason))
 reason = untag_clause (solver, 0, NOT (lit), reason);

      if (!reason)
 continue;
      for (unsigned other, * P_other = ((reason)->literals), * const END_other = P_other + ((reason)->size); (P_other != END_other) && (other = *P_other, 1); ++P_other)
 if (analyze_literal (solver, other) != 4294967295U)
   ( ((void)0), ++solver->statistics.reasons );
    }
}
# 5682 "upstream/satch.c"
static void
add_stamps (struct satch *solver)
{
  struct queue *queue = get_queue (solver);
  const struct link *const links = queue->links;
  const struct analyzed *const end = solver->analyzed.end;
  struct analyzed *const begin = solver->analyzed.begin;
  for (struct analyzed * p = begin; p != end; p++)
    p->stamp = links[p->idx].stamp;
}
# 5723 "upstream/satch.c"
static void
sort_analyzed (struct satch *solver)
{
  add_stamps (solver);
  do { const size_t N_RANK = ((size_t) ((solver->analyzed).end - (solver->analyzed).begin)); if (N_RANK <= 1) break; struct analyzed * V_RANK = (solver->analyzed).begin; const size_t LENGTH_RANK = 8; const size_t WIDTH_RANK = (1 << LENGTH_RANK); const unsigned MASK_RANK = WIDTH_RANK - 1; size_t COUNT_RANK[WIDTH_RANK]; struct analyzed * TMP_RANK = 0; const size_t BYTES_TMP_RANK = N_RANK * sizeof (struct analyzed); struct analyzed * A_RANK = V_RANK; struct analyzed * B_RANK = 0; struct analyzed * C_RANK = A_RANK; unsigned MLOWER_RANK = 0; unsigned MUPPER_RANK = MASK_RANK; bool BOUNDED_RANK = 0; unsigned UPPER_RANK = 0; unsigned LOWER_RANK = ~UPPER_RANK; unsigned SHIFT_RANK = MASK_RANK; for (size_t I_RANK = 0; I_RANK < 8 * sizeof (unsigned); I_RANK += LENGTH_RANK, SHIFT_RANK <<= LENGTH_RANK) { if (BOUNDED_RANK && (LOWER_RANK & SHIFT_RANK) == (UPPER_RANK & SHIFT_RANK)) continue; memset (COUNT_RANK + MLOWER_RANK, 0, (MUPPER_RANK - MLOWER_RANK + 1) * sizeof *COUNT_RANK); struct analyzed * END_RANK = C_RANK + N_RANK; bool SORTED_RANK = 1; unsigned LAST_RANK = 0; for (struct analyzed * P_RANK = C_RANK; P_RANK != END_RANK; P_RANK++) { unsigned R_RANK = (*P_RANK).stamp; if (!BOUNDED_RANK) { LOWER_RANK &= R_RANK; UPPER_RANK |= R_RANK; } unsigned S_RANK = R_RANK >> I_RANK; unsigned M_RANK = S_RANK & MASK_RANK; if (SORTED_RANK && LAST_RANK > M_RANK) SORTED_RANK = 0; else LAST_RANK = M_RANK; COUNT_RANK[M_RANK]++; } MLOWER_RANK = (LOWER_RANK >> I_RANK) & MASK_RANK; MUPPER_RANK = (UPPER_RANK >> I_RANK) & MASK_RANK; if (!BOUNDED_RANK) { BOUNDED_RANK = 1; if ((LOWER_RANK & SHIFT_RANK) == (UPPER_RANK & SHIFT_RANK)) continue; } if (SORTED_RANK) continue; size_t POS_RANK = 0; for (size_t J_RANK = MLOWER_RANK; J_RANK <= MUPPER_RANK; J_RANK++) { const size_t DELTA_RANK = COUNT_RANK[J_RANK]; COUNT_RANK[J_RANK] = POS_RANK; POS_RANK += DELTA_RANK; } if (!TMP_RANK) { ((void)0); TMP_RANK = malloc (BYTES_TMP_RANK); if (!TMP_RANK) out_of_memory (BYTES_TMP_RANK); B_RANK = TMP_RANK; } ((void)0); struct analyzed * D_RANK = (C_RANK == A_RANK) ? B_RANK : A_RANK; for (struct analyzed * P_RANK = C_RANK; P_RANK != END_RANK; P_RANK++) { unsigned R_RANK = (*P_RANK).stamp; unsigned S_RANK = R_RANK >> I_RANK; unsigned M_RANK = S_RANK & MASK_RANK; const size_t POS_RANK = COUNT_RANK[M_RANK]++; D_RANK[POS_RANK] = *P_RANK; } C_RANK = D_RANK; } if (C_RANK == B_RANK) memcpy (A_RANK, B_RANK, N_RANK * sizeof *A_RANK); if (TMP_RANK) free (TMP_RANK); do { } while (0); } while (0);
}
# 5762 "upstream/satch.c"
static int
find_conflict_level (struct satch *solver, struct clause *conflict,
       unsigned *forced)
{
  ((void)0);

  (void) *forced;
  unsigned res = 0;
  int count = 0;
  unsigned *lits = conflict->literals;
  const int size = conflict->size;
  unsigned *const end = lits + size;
  unsigned *const begin = lits;
  for (unsigned *p = begin; p != end; ++p)
    {
      do { (void) solver; } while(0);
      const unsigned idx = INDEX (*p);
      const unsigned level = solver->levels[idx];
      if (level > res)
 {
   res = level;
   *forced = *p;
   count = 1;
 }
      else if (level == res)
 {
   count++;
 }
    }

  do { (void) solver; } while(0)
                                                              ;




  if (!is_temporary_binary (solver, conflict))

    {
      for (unsigned i = 0; i < 2; i++)
 {

   const unsigned lit = lits[i];

   unsigned highest_position = i;
   unsigned highest_literal = lit;
   const unsigned idx = INDEX (lit);
   unsigned highest_level = solver->levels[idx];

   for (int j = i + 1; j < size; j++)
     {
       const int other = lits[j];
       const unsigned idx_other = INDEX (other);
       const unsigned tmp = solver->levels[idx_other];
       if (highest_level >= tmp)
  continue;
       highest_literal = other;
       highest_position = j;
       highest_level = tmp;
       if (highest_level == res)
  break;
     }



   if (highest_position == i)
     continue;


   if (highest_position > 1)
     {
       do { (void) solver; } while(0);
       unwatch_literal (solver, lit, conflict);
     }


   lits[highest_position] = lit;
   lits[i] = highest_literal;


   if (highest_position > 1)

     watch_literal (solver, conflict->redundant, highest_literal,
      lits[!i], conflict);




 }
    }





  if (count != 1)
    {
      *forced = 4294967295U;
      do { (void) solver; } while(0);
    }

  return res;

}


unsigned
reuse_scored_trail_from (struct satch *solver, unsigned asserting_level)
{
  unsigned next = max_score_unassigned_variable_on_binary_heap (solver);
  const double *const scores = solver->scores[solver->stable].score;
  struct clause *const *const reasons = solver->reasons;
  struct control const control = solver->control;
  unsigned *const end = solver->trail.end;
  const double next_score = scores[next];
  double decision_score = 1e150;
  const unsigned control_position =
    asserting_level ? asserting_level - 1 : asserting_level;
  for (unsigned *lit = ((control).begin[((void)0), (control_position)]).trail; lit != end;
       ++lit)
    {
      const unsigned idx = INDEX (*lit);
      const double score = scores[idx];
      const unsigned level = solver->levels[idx];
      if (level <= asserting_level)
 continue;
      if (decision_score < score || score < next_score)
 return level - 1;
      if (!reasons[idx])
 decision_score = score;
    }
  return solver->level - 1;
}



unsigned
reuse_stamped_trail_from (struct satch *solver, unsigned asserting_level)
{
  unsigned next = max_stamped_unassigned_variable_on_decision_queue (solver);
  const struct link *const links = solver->queue[solver->stable].links;
  struct clause *const *const reasons = solver->reasons;
  struct control const control = solver->control;
  unsigned *const end = solver->trail.end;
  const unsigned next_stamp = links[next].stamp;
  unsigned decision_stamp = 4294967295U;
  const unsigned control_position =
    asserting_level ? asserting_level - 1 : asserting_level;
  for (unsigned *lit = ((control).begin[((void)0), (control_position)]).trail; lit != end;
       ++lit)
    {
      const unsigned idx = INDEX (*lit);
      const unsigned stamp = links[idx].stamp;
      const unsigned level = solver->levels[idx];
      if (level <= asserting_level)
 continue;
      if (decision_stamp < stamp || stamp < next_stamp)
 return level - 1;
      if (!reasons[idx])
 decision_stamp = stamp;
    }
  return solver->level - 1;
}
# 5939 "upstream/satch.c"
static unsigned
determine_jump_level (struct satch *solver, unsigned conflict_level,
        unsigned *asserting_level)
{
  signed char *frames = solver->frames;
  unsigned jump_level = 0;
  *asserting_level = 0;

  for (unsigned lit_level, * PTR_lit_level = (solver->blocks).begin, * const END_lit_level = (solver->blocks).end; (PTR_lit_level != END_lit_level) && (lit_level = *PTR_lit_level, 1); ++PTR_lit_level)
    {
      frames[lit_level] = 0;
      if (lit_level != conflict_level && *asserting_level < lit_level)
 *asserting_level = lit_level;

      if (lit_level)
 ((solver->control).begin[((void)0), (lit_level - 1)]).seen.count = 0,
   ((solver->control).begin[((void)0), (lit_level - 1)]).seen.earliest = 4294967295U;

    }
  do { (void) solver; } while(0);


  if (solver->level - *asserting_level < 100 ||
      solver->level - 1 == *asserting_level

      || solver->vivifying

    )
    {
      do { (void) solver; } while(0);
      return *asserting_level;
    }
  do { (void) solver; } while(0);
  if (!solver->unassigned)
    {
      jump_level = solver->level - 1;
      if (*asserting_level != solver->level - 1)
 {
   ( ((void)0), ++solver->statistics.chrono );
   do { ((void)0); solver->statistics.chronosaved += (jump_level - *asserting_level); } while (0);
 }
      return jump_level;
    }


  if (!solver->queue[solver->stable].size)
    return solver->level - 1;







  if (solver->stable)
    {
      jump_level = reuse_scored_trail_from (solver, *asserting_level);
    }

  else
    {
      jump_level = reuse_stamped_trail_from (solver, *asserting_level);
    }




  ((void)0);
  if (*asserting_level != jump_level)
    {
      ( ((void)0), ++solver->statistics.chrono );
      do { ((void)0); solver->statistics.chronosaved += (jump_level - *asserting_level); } while (0);
    }




  return jump_level;
}
# 6060 "upstream/satch.c"
static bool
analyze_conflict (struct satch *solver, struct clause *conflict)
{
  ((void)0);
  ((void)0);

  if (!solver->level)
    {
      do { (void) solver; } while(0);
      trace_and_check_empty_addition (solver);
      solver->inconsistent = 1;
      return 0;
    }
# 6105 "upstream/satch.c"
  ((void)0);
  ((void)0);

  do { if (((solver->clause).end == (solver->clause).allocated)) do { const size_t old_size = ((size_t) ((solver->clause).end - (solver->clause).begin)); const size_t old_capacity = ((size_t) ((solver->clause).allocated - (solver->clause).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(solver->clause).begin; (solver->clause).begin = realloc ((solver->clause).begin, new_bytes); if (!(solver->clause).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (solver->clause).end = (solver->clause).begin + old_size; (solver->clause).allocated = (solver->clause).begin + new_capacity; } while (0); *(solver->clause).end++ = (4294967295U); } while (0);


  unsigned forced = 4294967295U;
  unsigned *forcedp = &forced;
  const unsigned conflict_level =
    find_conflict_level (solver, conflict, forcedp);
  if (!conflict_level)
    {
      do { (void) solver; } while(0);
      trace_and_check_empty_addition (solver);
      solver->inconsistent = 1;
      return 0;
    }
  if (*forcedp != 4294967295U)
    {
      ((void)0);

      ((void)0);

      do { (void) solver; } while(0)
                   ;
      backtrack (solver, conflict_level - 1);

      if (is_temporary_binary (solver, conflict) || conflict->size == 2)
 {

   unsigned other =
     *forcedp ^ conflict->literals[0] ^ conflict->literals[1];
   struct clause *reason = tag_binary_clause (1, other);
   assign (solver, *forcedp, reason, 0);



 }
      else

 assign (solver, *forcedp, conflict, 0);
      do { (solver->blocks).end = (solver->blocks).begin; } while (0);
      do { (solver->clause).end = (solver->clause).begin; } while (0);
      ((void)0);
      return 1;
    }
  if (conflict_level < solver->level)
    {
      do { (void) solver; } while(0)
                                  ;
      backtrack (solver, conflict_level);
    }
  else
    {
      do { (void) solver; } while(0);
    }



  signed char *const marks = solver->marks;
  const unsigned *const levels = solver->levels;
  struct clause *const *const reasons = solver->reasons;
  signed char *frames = solver->frames;

  struct clause *reason = conflict;

  const unsigned *t = solver->trail.end;
  unsigned unresolved_on_current_level = 0;
  unsigned uip = 4294967295U;

  uint64_t ticks = 0;

  for (;;)
    {
      ((void)0);
      do { (void) solver; } while(0);


      if (!is_temporary_binary (solver, reason))

 {
   ((void)0);
   if (!reason->used)
     reason->used = 1;

   else if (reason->glue <= 6)
     reason->used = 2;

   ticks++;
 }

      for (unsigned lit, * P_lit = ((reason)->literals), * const END_lit = P_lit + ((reason)->size); (P_lit != END_lit) && (lit = *P_lit, 1); ++P_lit)
 {
   if (lit == uip)
     continue;
   const unsigned lit_level = analyze_literal (solver, lit);
   if (lit_level == 4294967295U)
     continue;
   ((void)0);
   if (lit_level < conflict_level)
     {
       if (!frames[lit_level])
  {
    do { (void) solver; } while(0);
    do { if (((solver->blocks).end == (solver->blocks).allocated)) do { const size_t old_size = ((size_t) ((solver->blocks).end - (solver->blocks).begin)); const size_t old_capacity = ((size_t) ((solver->blocks).allocated - (solver->blocks).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(solver->blocks).begin; (solver->blocks).begin = realloc ((solver->blocks).begin, new_bytes); if (!(solver->blocks).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (solver->blocks).end = (solver->blocks).begin + old_size; (solver->blocks).allocated = (solver->blocks).begin + new_capacity; } while (0); *(solver->blocks).end++ = (lit_level); } while (0);
    frames[lit_level] = 1;
  }
       do { if (((solver->clause).end == (solver->clause).allocated)) do { const size_t old_size = ((size_t) ((solver->clause).end - (solver->clause).begin)); const size_t old_capacity = ((size_t) ((solver->clause).allocated - (solver->clause).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(solver->clause).begin; (solver->clause).begin = realloc ((solver->clause).begin, new_bytes); if (!(solver->clause).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (solver->clause).end = (solver->clause).begin + old_size; (solver->clause).allocated = (solver->clause).begin + new_capacity; } while (0); *(solver->clause).end++ = (lit); } while (0);

       const unsigned idx = INDEX (lit);
       const unsigned level = solver->levels[idx];
       if (level != 0)
  {
    struct level *saved = &((solver->control).begin[((void)0), (level - 1)]);
    if (saved->seen.earliest > solver->position[idx])
      saved->seen.earliest = solver->position[idx];
    ++saved->seen.count;
    do { (void) solver; } while(0)
                                                 ;
  }

     }
   else
     unresolved_on_current_level++;
 }
      unsigned uip_idx;
      do
 {
   ((void)0);

   if (solver->levels[INDEX (*--t)] == solver->level)
     uip = *t;
   else
     uip = 4294967295U;



 }
      while (uip == 4294967295U || !marks[uip_idx = INDEX (uip)]);
      do { (void) solver; } while(0);
      if (!--unresolved_on_current_level)
 break;
      reason = reasons[uip_idx];

      if (is_tagged_clause (reason))
 reason = untag_clause (solver, 0, uip, reason);

    }
  ((void)0);
  do { (void) solver; } while(0);
  const unsigned not_uip = NOT (uip);
  ((solver->clause).begin[((void)0), (0)]) = not_uip;
  do { ((void)0); solver->statistics.ticks += (ticks); } while (0);

  do { (void) solver; } while(0);
  unsigned size = ((size_t) ((solver->clause).end - (solver->clause).begin));
  do { ((void)0); solver->statistics.deduced += (size); } while (0);
  ((void)0);


  sort_deduced_clause (solver);



  start_profiling (solver, &solver->profiles.minishrink);

  shrink_deduced_clause (solver);



  reset_removable_and_poisoned (solver);
  stop_profiling (solver, &solver->profiles.minishrink, process_time ());
  size = ((size_t) ((solver->clause).end - (solver->clause).begin));


  const unsigned glue = ((size_t) ((solver->blocks).end - (solver->blocks).begin));
  unsigned asserting_level = 0;
  unsigned jump_level =
    determine_jump_level (solver, conflict_level, &asserting_level);
  do { (solver->blocks).end = (solver->blocks).begin; } while (0);

  {
    struct averages *a = averages (solver);

    update_fast_average (&a->fast_glue, glue);

    update_slow_average (&a->slow_glue, glue);
    update_slow_average (&a->conflict_level, conflict_level);
    {
      const uint64_t decisions = (solver->statistics.decisions);
      const uint64_t delta_decisions = decisions - a->saved_decisions;
      a->saved_decisions = decisions;
      update_slow_average (&a->decision_rate, delta_decisions);
    }
    {
      double trail_filled = percent (((size_t) ((solver->trail).end - (solver->trail).begin)),
         solver->statistics.remaining);
      update_slow_average (&a->trail_filled, trail_filled);
    }
    update_betas (solver);

    do { (void) solver; } while(0);
    do { (void) solver; } while(0)
                                               ;

    do { (void) solver; } while(0)
                                          ;

    do { (void) solver; } while(0)
                                          ;
  }


  bump_reason_side_literals (solver);




  if (!solver->stable)

    sort_analyzed (solver);


  for (struct analyzed analyzed, * PTR_analyzed = (solver->analyzed).begin, * const END_analyzed = (solver->analyzed).end; (PTR_analyzed != END_analyzed) && (analyzed = *PTR_analyzed, 1); ++PTR_analyzed)
    {
      const unsigned idx = analyzed.idx;


      ( ((void)0), ++solver->statistics.bumped );





      if (solver->stable)
 bump_variable_score (solver, idx);
      else
 move_variable_to_front (solver, idx);



      ((void)0);
      marks[idx] = 0;
    }
  do { (solver->analyzed).end = (solver->analyzed).begin; } while (0);



  if (solver->stable)

    bump_score_increment (solver);


  trace_and_check_temporary_addition (solver);


  ((void)0);
  backtrack (solver, solver->level - 1);
  if (solver->stable)
    update_phases (solver);
  if (jump_level < solver->level)

    backtrack (solver, jump_level);

  if (size == 1)
    {



      solver->iterate = 1;
      assign (solver, not_uip, 0, 1);
    }

  else if (size == 2)
    {
      const unsigned other = ((solver->clause).begin[((void)0), (1)]);
      do { (void) solver; } while(0);

      add_new_binary_and_watch_it (solver, 1);

      do { ((void)0); solver->statistics.learned += (2); } while (0);
      struct clause *reason = tag_binary_clause (1, other);
      assign (solver, not_uip, reason, 0);
    }

  else
    {
      ((void)0);
      ((void)0);




      for (unsigned *p = solver->clause.begin + 1, *q = p;; q++)
 {
   ((void)0);
   const unsigned lit = *q;
   unsigned idx = INDEX (lit);
   unsigned lit_level = levels[idx];
   ((void)0);
   if (lit_level == asserting_level)
     {
       *q = *p;
       *p = lit;
       break;
     }
 }


      struct clause *learned = new_redundant_clause (solver, glue);






      if (glue <= 6)
 learned->used = 2;
      else

 learned->used = 1;

      do { (void) solver; } while(0);
      do { ((void)0); solver->statistics.learned += (size); } while (0);


      watch_clause (solver, learned);





      assign (solver, not_uip, learned, 0);
    }

  do { (solver->clause).end = (solver->clause).begin; } while (0);
  return 1;

}





unsigned
max_stamped_unassigned_variable_on_decision_queue (struct satch *solver)
{
  struct queue *queue = get_queue (solver);
  const struct link *const links = queue->links;
  const signed char *const values = solver->values;

  unsigned idx = queue->search;

  for (;;)
    {
      ((void)0);
      const unsigned lit = LITERAL (idx);
      const signed char value = values[lit];
      if (!value)
 break;
      idx = links[idx].prev;
    }
  queue->search = idx;

  do { (void) solver; } while(0)
                                      ;

  return idx;
}




unsigned
max_score_unassigned_variable_on_binary_heap (struct satch *solver)
{
  const signed char *const values = solver->values;
  struct heap *scores = get_scores (solver);

  unsigned idx;

  for (;;)
    {
      idx = max_heap (scores);
      const unsigned lit = LITERAL (idx);
      const signed char value = values[lit];
      if (!value)
 break;
      pop_heap (solver, scores);
    }

  do { (void) solver; } while(0)
                                        ;

  return idx;
}
# 6515 "upstream/satch.c"
static unsigned
decide_variable (struct satch *solver)
{
  unsigned idx;
# 6528 "upstream/satch.c"
  if (solver->stable)
    idx = max_score_unassigned_variable_on_binary_heap (solver);
  else
    idx = max_stamped_unassigned_variable_on_decision_queue (solver);


  do { (void) solver; } while(0);

  return idx;
}
# 6546 "upstream/satch.c"
static int
original_phase (void)
{

  return 1;



}

static int
decide_phase (struct satch *solver, unsigned idx)
{
  signed char value = 0;

  if (solver->stable)
    value = solver->targets[idx];


  if (!value)
    value = solver->saved[idx];

  if (!value)
    value = original_phase ();
  do { (void) solver; } while(0);
  (void) idx;
  return value;
}





static void
decide (struct satch *solver)
{
# 6609 "upstream/satch.c"
  start_profiling (solver, &solver->profiles.decide);
  ( ((void)0), ++solver->statistics.decisions );

  ((void)0);
  ((void)0);
  ((void)0);


  ((void)0);

  solver->level++;



  const unsigned idx = decide_variable (solver);
  const int value = decide_phase (solver, idx);

  const unsigned lit = LITERAL (idx);
  const unsigned decision = (value < 0 ? NOT (lit) : lit);
  do { (void) solver; } while(0);

  assign (solver, decision, 0, 0);
  stop_profiling (solver, &solver->profiles.decide, process_time ());
}
# 6693 "upstream/satch.c"
static void
report (struct satch *solver, unsigned verbose, int type)
{
  if (solver->options.verbose < verbose)
    return;

  ( ((void)0), ++solver->statistics.reported );




  struct averages *a = averages (solver);
  const double seconds = process_time ();
  const double MB = current_resident_set_size () / (double) (1 << 20);
  const double level = unbiased_slow_average (a, a->conflict_level);

  const uint64_t switched = solver->statistics.switched;


  const uint64_t reductions = solver->statistics.reductions;


  const uint64_t restarts = solver->statistics.restarts;

  const double rate = unbiased_slow_average (a, a->decision_rate);
  const uint64_t conflicts = (solver->statistics.conflicts);

  const uint64_t redundant = solver->statistics.redundant;

  const double trail = unbiased_slow_average (a, a->trail_filled);
  const double glue = unbiased_slow_average (a, a->slow_glue);
  const uint64_t irredundant = solver->statistics.irredundant;
  const uint64_t variables = solver->statistics.remaining;
  double remaining = percent (variables, solver->statistics.variables);



  int num_reported = 0;

  int column[16];
  char line[256];
  int end_line = 0;

  line[end_line++] = 'c';





  line[end_line++] = ' ';
  line[end_line++] = type;
# 6760 "upstream/satch.c"
  { ((void)0); line[end_line++] = ' '; column[num_reported++] = end_line; char buffer[32]; sprintf (buffer, "%.2f", seconds); for (const char * p = buffer; *p; p++) ((void)0), line[end_line++] = *p; } { ((void)0); line[end_line++] = ' '; column[num_reported++] = end_line; char buffer[32]; sprintf (buffer, "%.0f", MB); for (const char * p = buffer; *p; p++) ((void)0), line[end_line++] = *p; } { ((void)0); line[end_line++] = ' '; column[num_reported++] = end_line; char buffer[32]; sprintf (buffer, "%.0f", level); for (const char * p = buffer; *p; p++) ((void)0), line[end_line++] = *p; } { ((void)0); line[end_line++] = ' '; column[num_reported++] = end_line; char buffer[32]; sprintf (buffer, "%" "lu", switched); for (const char * p = buffer; *p; p++) ((void)0), line[end_line++] = *p; } { ((void)0); line[end_line++] = ' '; column[num_reported++] = end_line; char buffer[32]; sprintf (buffer, "%" "lu", reductions); for (const char * p = buffer; *p; p++) ((void)0), line[end_line++] = *p; } { ((void)0); line[end_line++] = ' '; column[num_reported++] = end_line; char buffer[32]; sprintf (buffer, "%" "lu", restarts); for (const char * p = buffer; *p; p++) ((void)0), line[end_line++] = *p; } { ((void)0); line[end_line++] = ' '; column[num_reported++] = end_line; char buffer[32]; sprintf (buffer, "%.0f", rate); for (const char * p = buffer; *p; p++) ((void)0), line[end_line++] = *p; } { ((void)0); line[end_line++] = ' '; column[num_reported++] = end_line; char buffer[32]; sprintf (buffer, "%" "lu", conflicts); for (const char * p = buffer; *p; p++) ((void)0), line[end_line++] = *p; } { ((void)0); line[end_line++] = ' '; column[num_reported++] = end_line; char buffer[32]; sprintf (buffer, "%" "lu", redundant); for (const char * p = buffer; *p; p++) ((void)0), line[end_line++] = *p; } { ((void)0); line[end_line++] = ' '; column[num_reported++] = end_line; char buffer[32]; sprintf (buffer, "%.0f%%", trail); for (const char * p = buffer; *p; p++) ((void)0), line[end_line++] = *p; } { ((void)0); line[end_line++] = ' '; column[num_reported++] = end_line; char buffer[32]; sprintf (buffer, "%.0f", glue); for (const char * p = buffer; *p; p++) ((void)0), line[end_line++] = *p; } { ((void)0); line[end_line++] = ' '; column[num_reported++] = end_line; char buffer[32]; sprintf (buffer, "%" "lu", irredundant); for (const char * p = buffer; *p; p++) ((void)0), line[end_line++] = *p; } { ((void)0); line[end_line++] = ' '; column[num_reported++] = end_line; char buffer[32]; sprintf (buffer, "%" "lu", variables); for (const char * p = buffer; *p; p++) ((void)0), line[end_line++] = *p; } { ((void)0); line[end_line++] = ' '; column[num_reported++] = end_line; char buffer[32]; sprintf (buffer, "%.0f%%", remaining); for (const char * p = buffer; *p; p++) ((void)0), line[end_line++] = *p; }
# 6769 "upstream/satch.c"
  ((void)0); bool colors = isatty (1); FILE * terminal_file = ((1 == 1) ? 1 : 2); (void) terminal_file;

  if ((solver->statistics.reported % 16) == 1)
    {
      char header[3][256];
      int end_header[3];

      for (int i = 0; i < 3; i++)
 {
   header[i][0] = 'c';
   end_header[i] = 1;
 }

      int reported = 0;
# 6821 "upstream/satch.c"
      { const int row = reported % 3; ((void)0); header[row][end_header[row]++] = ' '; ((void)0); const int start = column[reported++]; const int end = (reported == num_reported ? end_line : column[reported]); const int value_width = end - start - 1; const int name_width = strlen ("seconds"); int target; if (name_width > value_width) target = start - (name_width - value_width + 1)/2; else target = start + (value_width - name_width + 1)/2; ((void)0); while (end_header[row] < target) { ((void)0); header[row][end_header[row]++] = ' '; } for (const char * p = "seconds"; *p; p++) { ((void)0); header[row][end_header[row]++] = *p; } } { const int row = reported % 3; ((void)0); header[row][end_header[row]++] = ' '; ((void)0); const int start = column[reported++]; const int end = (reported == num_reported ? end_line : column[reported]); const int value_width = end - start - 1; const int name_width = strlen ("MB"); int target; if (name_width > value_width) target = start - (name_width - value_width + 1)/2; else target = start + (value_width - name_width + 1)/2; ((void)0); while (end_header[row] < target) { ((void)0); header[row][end_header[row]++] = ' '; } for (const char * p = "MB"; *p; p++) { ((void)0); header[row][end_header[row]++] = *p; } } { const int row = reported % 3; ((void)0); header[row][end_header[row]++] = ' '; ((void)0); const int start = column[reported++]; const int end = (reported == num_reported ? end_line : column[reported]); const int value_width = end - start - 1; const int name_width = strlen ("level"); int target; if (name_width > value_width) target = start - (name_width - value_width + 1)/2; else target = start + (value_width - name_width + 1)/2; ((void)0); while (end_header[row] < target) { ((void)0); header[row][end_header[row]++] = ' '; } for (const char * p = "level"; *p; p++) { ((void)0); header[row][end_header[row]++] = *p; } } { const int row = reported % 3; ((void)0); header[row][end_header[row]++] = ' '; ((void)0); const int start = column[reported++]; const int end = (reported == num_reported ? end_line : column[reported]); const int value_width = end - start - 1; const int name_width = strlen ("switched"); int target; if (name_width > value_width) target = start - (name_width - value_width + 1)/2; else target = start + (value_width - name_width + 1)/2; ((void)0); while (end_header[row] < target) { ((void)0); header[row][end_header[row]++] = ' '; } for (const char * p = "switched"; *p; p++) { ((void)0); header[row][end_header[row]++] = *p; } } { const int row = reported % 3; ((void)0); header[row][end_header[row]++] = ' '; ((void)0); const int start = column[reported++]; const int end = (reported == num_reported ? end_line : column[reported]); const int value_width = end - start - 1; const int name_width = strlen ("reductions"); int target; if (name_width > value_width) target = start - (name_width - value_width + 1)/2; else target = start + (value_width - name_width + 1)/2; ((void)0); while (end_header[row] < target) { ((void)0); header[row][end_header[row]++] = ' '; } for (const char * p = "reductions"; *p; p++) { ((void)0); header[row][end_header[row]++] = *p; } } { const int row = reported % 3; ((void)0); header[row][end_header[row]++] = ' '; ((void)0); const int start = column[reported++]; const int end = (reported == num_reported ? end_line : column[reported]); const int value_width = end - start - 1; const int name_width = strlen ("restarts"); int target; if (name_width > value_width) target = start - (name_width - value_width + 1)/2; else target = start + (value_width - name_width + 1)/2; ((void)0); while (end_header[row] < target) { ((void)0); header[row][end_header[row]++] = ' '; } for (const char * p = "restarts"; *p; p++) { ((void)0); header[row][end_header[row]++] = *p; } } { const int row = reported % 3; ((void)0); header[row][end_header[row]++] = ' '; ((void)0); const int start = column[reported++]; const int end = (reported == num_reported ? end_line : column[reported]); const int value_width = end - start - 1; const int name_width = strlen ("rate"); int target; if (name_width > value_width) target = start - (name_width - value_width + 1)/2; else target = start + (value_width - name_width + 1)/2; ((void)0); while (end_header[row] < target) { ((void)0); header[row][end_header[row]++] = ' '; } for (const char * p = "rate"; *p; p++) { ((void)0); header[row][end_header[row]++] = *p; } } { const int row = reported % 3; ((void)0); header[row][end_header[row]++] = ' '; ((void)0); const int start = column[reported++]; const int end = (reported == num_reported ? end_line : column[reported]); const int value_width = end - start - 1; const int name_width = strlen ("conflicts"); int target; if (name_width > value_width) target = start - (name_width - value_width + 1)/2; else target = start + (value_width - name_width + 1)/2; ((void)0); while (end_header[row] < target) { ((void)0); header[row][end_header[row]++] = ' '; } for (const char * p = "conflicts"; *p; p++) { ((void)0); header[row][end_header[row]++] = *p; } } { const int row = reported % 3; ((void)0); header[row][end_header[row]++] = ' '; ((void)0); const int start = column[reported++]; const int end = (reported == num_reported ? end_line : column[reported]); const int value_width = end - start - 1; const int name_width = strlen ("redundant"); int target; if (name_width > value_width) target = start - (name_width - value_width + 1)/2; else target = start + (value_width - name_width + 1)/2; ((void)0); while (end_header[row] < target) { ((void)0); header[row][end_header[row]++] = ' '; } for (const char * p = "redundant"; *p; p++) { ((void)0); header[row][end_header[row]++] = *p; } } { const int row = reported % 3; ((void)0); header[row][end_header[row]++] = ' '; ((void)0); const int start = column[reported++]; const int end = (reported == num_reported ? end_line : column[reported]); const int value_width = end - start - 1; const int name_width = strlen ("trail"); int target; if (name_width > value_width) target = start - (name_width - value_width + 1)/2; else target = start + (value_width - name_width + 1)/2; ((void)0); while (end_header[row] < target) { ((void)0); header[row][end_header[row]++] = ' '; } for (const char * p = "trail"; *p; p++) { ((void)0); header[row][end_header[row]++] = *p; } } { const int row = reported % 3; ((void)0); header[row][end_header[row]++] = ' '; ((void)0); const int start = column[reported++]; const int end = (reported == num_reported ? end_line : column[reported]); const int value_width = end - start - 1; const int name_width = strlen ("glue"); int target; if (name_width > value_width) target = start - (name_width - value_width + 1)/2; else target = start + (value_width - name_width + 1)/2; ((void)0); while (end_header[row] < target) { ((void)0); header[row][end_header[row]++] = ' '; } for (const char * p = "glue"; *p; p++) { ((void)0); header[row][end_header[row]++] = *p; } } { const int row = reported % 3; ((void)0); header[row][end_header[row]++] = ' '; ((void)0); const int start = column[reported++]; const int end = (reported == num_reported ? end_line : column[reported]); const int value_width = end - start - 1; const int name_width = strlen ("irredundant"); int target; if (name_width > value_width) target = start - (name_width - value_width + 1)/2; else target = start + (value_width - name_width + 1)/2; ((void)0); while (end_header[row] < target) { ((void)0); header[row][end_header[row]++] = ' '; } for (const char * p = "irredundant"; *p; p++) { ((void)0); header[row][end_header[row]++] = *p; } } { const int row = reported % 3; ((void)0); header[row][end_header[row]++] = ' '; ((void)0); const int start = column[reported++]; const int end = (reported == num_reported ? end_line : column[reported]); const int value_width = end - start - 1; const int name_width = strlen ("variables"); int target; if (name_width > value_width) target = start - (name_width - value_width + 1)/2; else target = start + (value_width - name_width + 1)/2; ((void)0); while (end_header[row] < target) { ((void)0); header[row][end_header[row]++] = ' '; } for (const char * p = "variables"; *p; p++) { ((void)0); header[row][end_header[row]++] = *p; } } { const int row = reported % 3; ((void)0); header[row][end_header[row]++] = ' '; ((void)0); const int start = column[reported++]; const int end = (reported == num_reported ? end_line : column[reported]); const int value_width = end - start - 1; const int name_width = strlen ("remaining"); int target; if (name_width > value_width) target = start - (name_width - value_width + 1)/2; else target = start + (value_width - name_width + 1)/2; ((void)0); while (end_header[row] < target) { ((void)0); header[row][end_header[row]++] = ' '; } for (const char * p = "remaining"; *p; p++) { ((void)0); header[row][end_header[row]++] = *p; } }




      fputs ("c\n", 1);



      for (int i = 0; i < 3; i++)
 {
   fputc ('c', 1);
   do { if (colors) fputs ("\033[33m", terminal_file); } while (0);
   for (int j = 1; j < end_header[i]; j++)
     fputc (header[i][j], 1);
   do { if (colors) fputs ("\033[0m", terminal_file); } while (0);
   fputc ('\n', 1);
 }

      fputs ("c\n", 1);
    }



  fputs ("c ", 1);


  bool reset = 0;
  if (colors)
    {
      bool magenta = 0;

      switch (type)
 {
 case '0':
 case '1':
 case '?':
 case 'i':
   fputs ("\033[1m", 1);
   reset = 1;
   break;
 case 's':
   fputs ("\033[32m", 1);
   reset = 1;
   break;
 case 'e':
   fputs ("\033[1;32m", 1);
   reset = 1;
   break;
 case '[':
 case ']':
   fputs ("\033[35m", 1);
   magenta = 1;
   break;
 }

      ((void)0);
      fputc (line[2], 1);

      if (reset)
 fputs ("\033[0m", 1);

      if (magenta)
 reset = 1;
      else if (solver->stable)
 {
   fputs ("\033[35m", 1);
   reset = 1;
 }
    }
  else

    fputc (line[2], 1);

  for (int i = 3; i < end_line; i++)
    fputc (line[i], 1);

  if (reset)
    fputs ("\033[0m", 1);

  fputc ('\n', 1);

  fflush (1);
}
# 6915 "upstream/satch.c"
static void
iterate (struct satch *solver)
{
  report (solver, 1, 'i');
  solver->iterate = 0;
}







static double
logn (uint64_t n)
{
  ((void)0);
  const double res = log10 (n + 9);
  ((void)0);
  return res;
}





static double
nlognlogn (uint64_t n)
{
  ((void)0);
  const double tmp = log10 (n + 9);
  ((void)0);
  const double res = n * tmp * tmp;
  ((void)0);
  return res;
}



static double
nlogn (uint64_t n)
{
  ((void)0);
  const double tmp = log10 (n + 9);
  ((void)0);
  const double res = n * tmp;
  ((void)0);
  return res;
}





static double
nlognlognlogn (uint64_t n)
{
  ((void)0);
  const double tmp = log10 (n + 9);
  ((void)0);
  const double res = n * tmp * tmp * tmp;
  ((void)0);
  return res;
}





static double
ndivlogn (uint64_t n)
{
  ((void)0);
  const double div = log10 (n + 9);
  ((void)0);
  const double res = n / div;
  ((void)0);
  return res;
}





static double
quadratic (uint64_t n)
{
  ((void)0);
  const double res = n * n;
  ((void)0);
  return res;
}
# 7029 "upstream/satch.c"
static double
scale_interval (uint64_t base, double (*scale) (uint64_t), uint64_t count)
{
  ((void)0);
  double scaling = scale (count);
  ((void)0);
  double res = base * scaling;
  ((void)0);
  return res;
}
# 7058 "upstream/satch.c"
static unsigned
reuse_stamped_trail (struct satch *solver)
{

  return reuse_stamped_trail_from (solver, 1);
# 7080 "upstream/satch.c"
}







static unsigned
reuse_scored_trail (struct satch *solver)
{

  return reuse_scored_trail_from (solver, 1);
# 7110 "upstream/satch.c"
}






static unsigned
reuse_trail (struct satch *solver)
{
  unsigned res;

  ((void)0);
  ((void)0);
  ((void)0);
# 7134 "upstream/satch.c"
    {





      if (solver->stable)
 res = reuse_scored_trail (solver);
      else
 res = reuse_stamped_trail (solver);

    }


  if (res)
    {
      message (solver, 4, "restart", solver->statistics.restarts,
        "reusing trail up-to level %u out of %u levels %.0f%%",
        res, solver->level, percent (res, solver->level));
      ( ((void)0), ++solver->statistics.reused );
    }
  else
    do { (void) solver; } while(0);

  return res;
}
# 7175 "upstream/satch.c"
static bool
restarting (struct satch *solver)
{
  ((void)0);
  ((void)0);

  if (!solver->level)
    return 0;
  if (solver->limits.restart > (solver->statistics.conflicts))
    return 0;







  if (solver->stable)
    return 1;



  struct averages *a = averages (solver);

  const double fast = unbiased_fast_average (a, a->fast_glue);
  const double slow = unbiased_slow_average (a, a->slow_glue);
  const double limit = 1.1 * slow;

  return limit <= fast;
}

static void
restart (struct satch *solver)
{
  const uint64_t restarts = ( ((void)0), ++solver->statistics.restarts );
  message (solver, 4, "restart", restarts,
    "restarting after %" "lu" " conflicts (limit %" "lu" ")",
    (solver->statistics.conflicts), solver->limits.restart);
  report (solver, 3, 'r');


  if (solver->stable)
    update_phases (solver);



  {
    unsigned new_level = reuse_trail (solver);
    if (new_level < solver->level)
      backtrack (solver, new_level);
  }




  uint64_t interval;

  if (solver->stable)
    {




      struct reluctant *r = &solver->reluctant;
      uint64_t u = r->u, v = r->v;




      interval = v * 1024;

      if ((u & -u) == v)
 u++, v = 1;
      else
 ((void)0), v *= 2;
      r->u = u, r->v = v;
    }
  else

    {
      ((void)0);
      interval = (1 - 1) + logn (restarts);
      ((void)0);
    }

  solver->limits.restart = (solver->statistics.conflicts) + interval;

  message (solver, 4, "restart", restarts,
    "new %s restart limit %" "lu" " after %" "lu" " conflicts",
    solver->stable ? "stable" : "focused",
    solver->limits.restart, interval);
}
# 7294 "upstream/satch.c"
static bool
rephasing (struct satch *solver)
{
  if (!solver->stable)
    return 0;
  return solver->limits.rephase <= (solver->statistics.conflicts);
}

static char
original_phases (struct satch *solver)
{
  const signed char value = original_phase ();
  memset (solver->saved, value, (solver->size));
  return 'O';
}



static char
inverted_phases (struct satch *solver)
{
  const signed char value = -original_phase ();
  memset (solver->saved, value, (solver->size));
  return 'I';
}





static char
best_phases (struct satch *solver)
{
  const signed char *const bests = solver->bests;
  const signed char *const end = bests + (solver->size);
  signed char *const saved = solver->saved;
  signed char *q = saved, tmp;
  for (const signed char *p = bests; p != end; p++, q++)
    if ((tmp = *p))
      *q = tmp;
  solver->best = 0;
  return 'B';
}



static void
rephase (struct satch *solver)
{
  char (*functions[4]) (struct satch *);
  unsigned size_functions = 0;


  functions[size_functions++] = inverted_phases;

  functions[size_functions++] = best_phases;


  functions[size_functions++] = original_phases;

  functions[size_functions++] = best_phases;

  ((void)0);

  const uint64_t rephased = ( ((void)0), ++solver->statistics.rephased );
  const char type = functions[rephased % size_functions] (solver);

  const uint64_t interval =
    scale_interval (1e3, nlognlognlogn, rephased);
  solver->limits.rephase = (solver->statistics.conflicts) + interval;
  message (solver, 4, "rephase", rephased,
    "new rephase limit %" "lu" " conflicts after %" "lu",
    solver->limits.rephase, interval);

  if (solver->stable)
    {
      do { (void) solver; } while(0);
      memcpy (solver->targets, solver->saved, (solver->size));
      solver->target = 0;
    }

  report (solver, 1, type);
}
# 7391 "upstream/satch.c"
static bool
reducing (struct satch *solver)
{
  return solver->limits.reduce.conflicts <= (solver->statistics.conflicts);
}







static void
set_protect_flag_of_reasons (struct satch *solver, bool protect)
{
  struct clause *const *const reasons = solver->reasons;
  for (unsigned lit, * PTR_lit = (solver->trail).begin, * const END_lit = (solver->trail).end; (PTR_lit != END_lit) && (lit = *PTR_lit, 1); ++PTR_lit)
    {
      const unsigned idx = INDEX (lit);
      struct clause *reason = reasons[idx];
      if (!reason)
 continue;

      if (is_tagged_clause (reason))
 continue;

      do { (void) solver; } while(0);
      ((void)0);
      reason->protected = protect;
    }
}
# 7432 "upstream/satch.c"
static bool
clause_satisfied (struct satch *solver, struct clause *c)
{
  ((void)0);

  ((void)0);
  ((void)0);
  ((void)0);


  const signed char *const values = solver->values;
  unsigned num_false = 0;

  for (unsigned lit, * P_lit = ((c)->literals), * const END_lit = P_lit + ((c)->size); (P_lit != END_lit) && (lit = *P_lit, 1); ++P_lit)
    {
      const signed char value = values[lit];
      if (value > 0)
 return 1;
      if (value < 0)
 num_false++;
    }

  if (!num_false)
    return 0;

  do { (void) solver; } while(0);

  ((void)0);
  for (unsigned lit, * P_lit = ((c)->literals), * const END_lit = P_lit + ((c)->size); (P_lit != END_lit) && (lit = *P_lit, 1); ++P_lit)
    if (!values[lit])
      do { if (((solver->clause).end == (solver->clause).allocated)) do { const size_t old_size = ((size_t) ((solver->clause).end - (solver->clause).begin)); const size_t old_capacity = ((size_t) ((solver->clause).allocated - (solver->clause).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(solver->clause).begin; (solver->clause).begin = realloc ((solver->clause).begin, new_bytes); if (!(solver->clause).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (solver->clause).end = (solver->clause).begin + old_size; (solver->clause).allocated = (solver->clause).begin + new_capacity; } while (0); *(solver->clause).end++ = (lit); } while (0);


  for (unsigned lit, * PTR_lit = (solver->clause).begin, * const END_lit = (solver->clause).end; (PTR_lit != END_lit) && (lit = *PTR_lit, 1); ++PTR_lit)
      mark_subsume_literal (solver, lit);


  if (!solver->dense)
    {
      trace_and_check_temporary_addition (solver);
      trace_and_check_clause_deletion (solver, c);


      const unsigned *old_lits = c->literals;
      const unsigned *new_lits = solver->clause.begin;





      unwatch_literal (solver, old_lits[0], c);
      unwatch_literal (solver, old_lits[1], c);





      const size_t size = ((size_t) ((solver->clause).end - (solver->clause).begin));
      ((void)0);
      ((void)0);
# 7500 "upstream/satch.c"
      if (size == 2)
 {
   watch_binary (solver, c->redundant, new_lits[0], new_lits[1]);
   watch_binary (solver, c->redundant, new_lits[1], new_lits[0]);
   do { (void) solver; } while(0);
   c->garbage = 1;
 }
      else

 {


   watch_literal (solver, c->redundant, new_lits[0], new_lits[1], c);
   watch_literal (solver, c->redundant, new_lits[1], new_lits[0], c);





   unsigned *p = c->literals;
   for (unsigned lit, * PTR_lit = (solver->clause).begin, * const END_lit = (solver->clause).end; (PTR_lit != END_lit) && (lit = *PTR_lit, 1); ++PTR_lit)
      *p++ = lit;

   c->size = size;

   if (c->redundant && c->size >= c->glue)
     c->glue = size - 1;


   c->search = 0;





   do { (void) solver; } while(0);
 }


    }

  do { (solver->clause).end = (solver->clause).begin; } while (0);

  return 0;
}







static bool
mark_garbage_if_satisfied (struct satch *solver, struct clause *c)
{
  ((void)0);

  ((void)0);
  ((void)0);

  if (c->garbage)
    return 1;
  if (!clause_satisfied (solver, c))
    return 0;
  mark_garbage (solver, c, "root-level satisfied");
  return 1;
}
# 7580 "upstream/satch.c"
static void
mark_irredundant_clauses_as_garbage_if_satisfied (struct satch *solver)
{
  ((void)0);
  for (struct clause * c, ** PTR_c = (solver->irredundant).begin, ** const END_c = (solver->irredundant).end; (PTR_c != END_c) && (c = *PTR_c, 1); ++PTR_c)
    (void) mark_garbage_if_satisfied (solver, c);
}
# 7597 "upstream/satch.c"
static void
gather_reduce_candidates (struct satch *solver, bool new_fixed,
     struct clauses *candidates)
{







  for (struct clause * c, ** PTR_c = (solver->redundant).end, ** const BEGIN_c = (solver->redundant).begin; (PTR_c-- != BEGIN_c) && (c = *PTR_c, 1);)
    {
      ((void)0);
      if (c->garbage)
 continue;
      if (c->protected)
 continue;
      if (new_fixed)
 {
   if (mark_garbage_if_satisfied (solver, c))
     continue;
   if (c->garbage)
     continue;
 }

      ((void)0);







      if (c->glue <= 2)
 continue;


      if (c->used)
 {
   c->used--;

   if (c->glue <= 6)

     continue;
 }

      do { if (((*candidates).end == (*candidates).allocated)) do { const size_t old_size = ((size_t) ((*candidates).end - (*candidates).begin)); const size_t old_capacity = ((size_t) ((*candidates).allocated - (*candidates).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(*candidates).begin; (*candidates).begin = realloc ((*candidates).begin, new_bytes); if (!(*candidates).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (*candidates).end = (*candidates).begin + old_size; (*candidates).allocated = (*candidates).begin + new_capacity; } while (0); *(*candidates).end++ = (c); } while (0);
    }

  if (solver->options.verbose < 2)
    return;

  const size_t size_candidates = ((size_t) ((*candidates).end - (*candidates).begin));
  const size_t redundant = ((size_t) ((solver->redundant).end - (solver->redundant).begin));
  message (solver, 2, "reduce", solver->statistics.reductions,
    "gathered %zu reduce candidate clauses %.0f%%",
    size_candidates, percent (size_candidates, redundant));
}




static void
flush_garbage_watches (struct satch *solver)
{
  struct watches *all_watches = solver->watches;

  signed char *const values = solver->values;
  const unsigned *const levels = solver->levels;

  for (unsigned lit = 0, END_LITERALS = (2u*(solver->size)); lit < END_LITERALS; lit++)
    {

      signed char lit_value = values[lit];
      if (lit_value && levels[INDEX (lit)])
 lit_value = 0;

      struct watches *const lit_watches = all_watches + lit;
      union watch *const end = lit_watches->end;
      union watch *q = lit_watches->begin;
      const union watch *p = q;
      while (p != end)
 {

   const union watch watch = *p++;

   const struct header header = watch.header;
   if (header.binary)
     {
       const unsigned blocking = header.blocking;

       signed char blocking_value = values[blocking];
       if (blocking_value && levels[INDEX (blocking)])
  blocking_value = 0;
# 7701 "upstream/satch.c"
       if (lit_value || blocking_value)
  {
    ((void)0);
    delete_binary (solver, header.redundant, lit, blocking);
    continue;
  }
       *q++ = watch;
       continue;
     }

   *q++ = watch;

   const struct clause *const clause = (*q++ = *p++).clause;
   if (clause->garbage)
     q -= 2;
 }
      lit_watches->end = q;
    }
}







static void
delete_garbage_clauses (struct satch *solver, struct clauses *clauses,
   size_t *bytes_ptr, size_t *count_ptr)
{
  size_t bytes = 0;
  size_t count = 0;

  struct clause *const *const end = clauses->end;
  struct clause **q = clauses->begin;

  for (struct clause ** p = q; p != end; p++)
    {
      struct clause *const c = *p;
      if (c->garbage)
 {
   ((void)0);
   bytes += delete_clause (solver, c);
   count++;
 }
      else
 *q++ = c;
    }
  clauses->end = q;

  *bytes_ptr += bytes;
  *count_ptr += count;
}
# 7770 "upstream/satch.c"
static uint64_t
rank_clause (struct clause *c)
{
  return ((uint64_t) c->glue << 32) + c->size;
}

static void
sort_reduce_candidates (struct clauses *candidates)
{
  do { const size_t N_RANK = ((size_t) ((*candidates).end - (*candidates).begin)); if (N_RANK <= 1) break; struct clause * * V_RANK = (*candidates).begin; const size_t LENGTH_RANK = 8; const size_t WIDTH_RANK = (1 << LENGTH_RANK); const uint64_t MASK_RANK = WIDTH_RANK - 1; size_t COUNT_RANK[WIDTH_RANK]; struct clause * * TMP_RANK = 0; const size_t BYTES_TMP_RANK = N_RANK * sizeof (struct clause *); struct clause * * A_RANK = V_RANK; struct clause * * B_RANK = 0; struct clause * * C_RANK = A_RANK; uint64_t MLOWER_RANK = 0; uint64_t MUPPER_RANK = MASK_RANK; bool BOUNDED_RANK = 0; uint64_t UPPER_RANK = 0; uint64_t LOWER_RANK = ~UPPER_RANK; uint64_t SHIFT_RANK = MASK_RANK; for (size_t I_RANK = 0; I_RANK < 8 * sizeof (uint64_t); I_RANK += LENGTH_RANK, SHIFT_RANK <<= LENGTH_RANK) { if (BOUNDED_RANK && (LOWER_RANK & SHIFT_RANK) == (UPPER_RANK & SHIFT_RANK)) continue; memset (COUNT_RANK + MLOWER_RANK, 0, (MUPPER_RANK - MLOWER_RANK + 1) * sizeof *COUNT_RANK); struct clause * * END_RANK = C_RANK + N_RANK; bool SORTED_RANK = 1; uint64_t LAST_RANK = 0; for (struct clause * * P_RANK = C_RANK; P_RANK != END_RANK; P_RANK++) { uint64_t R_RANK = rank_clause (*P_RANK); if (!BOUNDED_RANK) { LOWER_RANK &= R_RANK; UPPER_RANK |= R_RANK; } uint64_t S_RANK = R_RANK >> I_RANK; uint64_t M_RANK = S_RANK & MASK_RANK; if (SORTED_RANK && LAST_RANK > M_RANK) SORTED_RANK = 0; else LAST_RANK = M_RANK; COUNT_RANK[M_RANK]++; } MLOWER_RANK = (LOWER_RANK >> I_RANK) & MASK_RANK; MUPPER_RANK = (UPPER_RANK >> I_RANK) & MASK_RANK; if (!BOUNDED_RANK) { BOUNDED_RANK = 1; if ((LOWER_RANK & SHIFT_RANK) == (UPPER_RANK & SHIFT_RANK)) continue; } if (SORTED_RANK) continue; size_t POS_RANK = 0; for (size_t J_RANK = MLOWER_RANK; J_RANK <= MUPPER_RANK; J_RANK++) { const size_t DELTA_RANK = COUNT_RANK[J_RANK]; COUNT_RANK[J_RANK] = POS_RANK; POS_RANK += DELTA_RANK; } if (!TMP_RANK) { ((void)0); TMP_RANK = malloc (BYTES_TMP_RANK); if (!TMP_RANK) out_of_memory (BYTES_TMP_RANK); B_RANK = TMP_RANK; } ((void)0); struct clause * * D_RANK = (C_RANK == A_RANK) ? B_RANK : A_RANK; for (struct clause * * P_RANK = C_RANK; P_RANK != END_RANK; P_RANK++) { uint64_t R_RANK = rank_clause (*P_RANK); uint64_t S_RANK = R_RANK >> I_RANK; uint64_t M_RANK = S_RANK & MASK_RANK; const size_t POS_RANK = COUNT_RANK[M_RANK]++; D_RANK[POS_RANK] = *P_RANK; } C_RANK = D_RANK; } if (C_RANK == B_RANK) memcpy (A_RANK, B_RANK, N_RANK * sizeof *A_RANK); if (TMP_RANK) free (TMP_RANK); do { } while (0); } while (0);
}
# 7842 "upstream/satch.c"
static void
mark_garbage_candidates (struct satch *solver, struct clauses *candidates)
{
  const size_t size = ((size_t) ((*candidates).end - (*candidates).begin));
  ((void)0);
  const size_t reduce = 0.75 * size;

  message (solver, 4, "reduce", solver->statistics.reductions,
    "target is to reduce %zu out of %zu clauses %.0f%%",
    reduce, size, percent (reduce, size));

  const double keep_fraction = 1.0 - 0.75;
  const size_t keep = keep_fraction * size;

  size_t reduced = 0;

  while (((size_t) ((*candidates).end - (*candidates).begin)) > keep)
    {
      struct clause *c = (((void)0), *--(*candidates).end);
      ((void)0);
      mark_garbage (solver, c, "reducing");
      reduced++;
    }

  do { ((void)0); solver->statistics.reduced += (reduced); } while (0);

  message (solver, 3, "reduce", solver->statistics.reductions,
    "reducing %zu out of %zu clauses %.0f%%",
    reduced, size, percent (reduced, size));

}
# 7938 "upstream/satch.c"
static void
reduce (struct satch *solver)
{



  start_profiling (solver, &solver->profiles.reduce);
  const uint64_t reductions = ( ((void)0), ++solver->statistics.reductions );
# 7955 "upstream/satch.c"
  const bool new_fixed =
    solver->limits.reduce.fixed < solver->statistics.fixed;

  if (new_fixed)
    {
      update_phases_and_backtrack_to_root_level (solver);
      mark_irredundant_clauses_as_garbage_if_satisfied (solver);
    }
  else
    set_protect_flag_of_reasons (solver, 1);







  {
    struct clauses candidates;
    do { (candidates).end = (candidates).begin = (candidates).allocated = 0; } while (0);

    gather_reduce_candidates (solver, new_fixed, &candidates);
    sort_reduce_candidates (&candidates);
    mark_garbage_candidates (solver, &candidates);

    do { free ((candidates).begin); (candidates).begin = (candidates).end = (candidates).allocated = 0; } while (0);
  }




  flush_garbage_watches (solver);



  {
    size_t bytes = 0, count = 0;
    if (new_fixed)
      delete_garbage_clauses (solver, &solver->irredundant, &bytes, &count);
    delete_garbage_clauses (solver, &solver->redundant, &bytes, &count);



    message (solver, 2, "reduce", reductions,
      "collected %zu clauses (%zu bytes, %.0f MB)",
      count, bytes, bytes / (double) (1u << 20));

    do { ((void)0); solver->statistics.collected += (bytes); } while (0);
  }



  if (!new_fixed)
    set_protect_flag_of_reasons (solver, 0);



  {
    solver->limits.reduce.fixed = solver->statistics.fixed;
    const uint64_t interval =
      scale_interval (300, ndivlogn, reductions);
    solver->limits.reduce.conflicts = (solver->statistics.conflicts) + interval;
    message (solver, 4, "reduce", reductions,
      "next limit at %" "lu" " after %" "lu" " conflicts",
      solver->limits.reduce.conflicts, interval);
  }

  report (solver, 1, '-');
  stop_profiling (solver, &solver->profiles.reduce, process_time ());



}
# 8044 "upstream/satch.c"
static void
start_mode (struct satch *solver)
{
  if (solver->stable)
    {
      start_profiling (solver, &solver->profiles.stable);
      report (solver, 1, '[');
      do { (void) solver; } while(0);
    }
  else
    {
      start_profiling (solver, &solver->profiles.focused);
      report (solver, 1, '{');
      do { (void) solver; } while(0);
    }
}

static void
stop_mode (struct satch *solver)
{
  if (solver->stable)
    {
      stop_profiling (solver, &solver->profiles.stable, process_time ());
      do { (void) solver; } while(0);
      report (solver, 1, ']');
    }
  else
    {
      stop_profiling (solver, &solver->profiles.focused, process_time ());
      do { (void) solver; } while(0);
      report (solver, 1, '}');
    }
}
# 8091 "upstream/satch.c"
static bool
switching (struct satch *solver)
{
  struct limits *limits = &solver->limits;
  if (limits->mode.conflicts && limits->mode.conflicts <= (solver->statistics.conflicts))
    return 1;
  return limits->mode.ticks.limit <= (solver->statistics.ticks);
}

static void
set_new_mode_switching_limit (struct satch *solver, uint64_t switched)
{
  struct limits *limits = &solver->limits;
  const uint64_t interval = limits->mode.ticks.interval;
  const uint64_t count = (switched + 1) / 2;
  const uint64_t scaled = scale_interval (interval, quadratic, count);
  solver->limits.mode.ticks.limit = (solver->statistics.ticks) + scaled;
  message (solver, 3, "switch", switched,
    "new %s mode limit of %" "lu" " ticks after %" "lu" " ticks",
    solver->stable ? "focused" : "stable",
    limits->mode.ticks.limit, scaled);
}

static void
mode_ticks_limit_hit (struct satch *solver, uint64_t switched)
{
  message (solver, 2, "switch", switched,
    "limit of %" "lu" " ticks hit at %" "lu" " ticks",
    solver->limits.mode.ticks.limit, (solver->statistics.ticks));
}

static void
switch_to_focused_mode (struct satch *solver, uint64_t switched)
{
  ((void)0);
  mode_ticks_limit_hit (solver, switched);
  solver->stable = 0;
  ((void)0);
  ((void)0);
}

static void
switch_to_stable_mode (struct satch *solver, uint64_t switched)
{
  ((void)0);

  struct limits *limits = &solver->limits;

  if (limits->mode.conflicts)
    {
      message (solver, 2, "switch", switched,
        "limit of %" "lu" " conflicts hit at %"
        "lu" " conflicts and %" "lu" " ticks",
        limits->mode.conflicts, (solver->statistics.conflicts), (solver->statistics.ticks));

      limits->mode.ticks.interval = (solver->statistics.ticks);
      limits->mode.conflicts = 0;
    }
  else
    mode_ticks_limit_hit (solver, switched);

  solver->stable = 1;
  ((void)0);


  solver->reluctant.u = solver->reluctant.v = 1;
  solver->limits.restart = (solver->statistics.conflicts) + 1024;



  do { (void) solver; } while(0);
  solver->target = 0;

}

static void
switch_mode (struct satch *solver)
{
  stop_mode (solver);
  const uint64_t switched = ( ((void)0), ++solver->statistics.switched );







  if (solver->level)
    backtrack (solver, 0);

  if (solver->stable)
    switch_to_focused_mode (solver, switched);
  else
    switch_to_stable_mode (solver, switched);




  struct averages *a = averages (solver);
  a->saved_decisions = (solver->statistics.decisions);

  set_new_mode_switching_limit (solver, switched);
  start_mode (solver);
}







static bool
more_elimination_candidates (struct satch *solver)
{
  return solver->statistics.marked_eliminate >
    solver->limits.eliminate.marked;
}



static bool
more_subsumption_candidates (struct satch *solver)
{
  return solver->statistics.marked_subsume > solver->limits.subsume.marked;
}



static bool
eliminating (struct satch *solver)
{




  if (!more_elimination_candidates (solver))

    if (!more_subsumption_candidates (solver))

      return 0;

  return solver->limits.eliminate.conflicts < (solver->statistics.conflicts);



}
# 8257 "upstream/satch.c"
static void
flush_redundant_watches (struct satch *solver, bool new_fixed)
{
  ((void)0);
  const struct flags *const flags = solver->flags;
  for (unsigned lit = 0, END_LITERALS = (2u*(solver->size)); lit < END_LITERALS; lit++)
    {
      struct watches *watches = solver->watches + lit;
      const union watch *const end = watches->end;
      union watch *q = watches->begin, *p = q;
      const bool lit_active = new_fixed ? 1 : flags[INDEX (lit)].active;
      while (p != end)
 {
   struct header header = p->header;
   if (header.binary)
     {
       const unsigned other = header.blocking;
       const bool redundant = header.redundant;
       const bool other_active =
  new_fixed ? 1 : flags[INDEX (other)].active;

       if (lit_active && other_active)
  {
    if (header.redundant)
      {
        if (lit < other)
   {
     do { if (((solver->binaries).end == (solver->binaries).allocated)) do { const size_t old_size = ((size_t) ((solver->binaries).end - (solver->binaries).begin)); const size_t old_capacity = ((size_t) ((solver->binaries).allocated - (solver->binaries).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(solver->binaries).begin; (solver->binaries).begin = realloc ((solver->binaries).begin, new_bytes); if (!(solver->binaries).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (solver->binaries).end = (solver->binaries).begin + old_size; (solver->binaries).allocated = (solver->binaries).begin + new_capacity; } while (0); *(solver->binaries).end++ = (lit); } while (0);
     do { if (((solver->binaries).end == (solver->binaries).allocated)) do { const size_t old_size = ((size_t) ((solver->binaries).end - (solver->binaries).begin)); const size_t old_capacity = ((size_t) ((solver->binaries).allocated - (solver->binaries).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(solver->binaries).begin; (solver->binaries).begin = realloc ((solver->binaries).begin, new_bytes); if (!(solver->binaries).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (solver->binaries).end = (solver->binaries).begin + old_size; (solver->binaries).allocated = (solver->binaries).begin + new_capacity; } while (0); *(solver->binaries).end++ = (other); } while (0);
   }
      }
    else
      q++->clause = tag_binary_clause (0, other);
  }
       else
  delete_binary (solver, redundant, lit, other);

       p++;
     }
   else
     {
       if (!header.redundant)
  {
    struct clause *c = p[1].clause;
    if (!new_fixed || !c->garbage)
      q++->clause = c;
  }

       p += 2;
     }
 }
      watches->end = q;
      if (((*watches).end == (*watches).begin))
 do { free ((*watches).begin); (*watches).begin = (*watches).end = (*watches).allocated = 0; } while (0);
    }
  do { (void) solver; } while(0)
                                         ;
}
# 8371 "upstream/satch.c"
static void
connect_occurrences_in_irredundant_clauses (struct satch *solver)
{
  ((void)0);
  for (struct clause * c, ** PTR_c = (solver->irredundant).begin, ** const END_c = (solver->irredundant).end; (PTR_c != END_c) && (c = *PTR_c, 1); ++PTR_c)
    {
      const unsigned *const lits = c->literals;
      const unsigned *const end = lits + c->size;
      for (const unsigned *p = lits + 2; p != end; p++)
       if (!c->garbage)
         connect_literal (solver, *p, c);
    }
}

static void
switch_to_dense_mode (struct satch *solver)
{
  do { (void) solver; } while(0);
  ((void)0);
  bool new_fixed = solver->limits.eliminate.fixed < solver->statistics.fixed;
  if (new_fixed)
    mark_irredundant_clauses_as_garbage_if_satisfied (solver);
  flush_redundant_watches (solver, new_fixed);
  solver->dense = 1;
  connect_occurrences_in_irredundant_clauses (solver);
}
# 8405 "upstream/satch.c"
static void
disconnect_all_clauses (struct satch *solver)
{
  ((void)0);
  const struct flags *const flags = solver->flags;
  for (unsigned lit = 0, END_LITERALS = (2u*(solver->size)); lit < END_LITERALS; lit++)
    {
      struct watches *watches = solver->watches + lit;
      const union watch *const end = watches->end;
      union watch *q = watches->begin;
      struct clause *c;
      bool lit_eliminated = flags[INDEX (lit)].eliminated;
      for (const union watch * p = q; p != end; p++)
 if (is_tagged_clause (c = p->clause))
   {
     const unsigned other = tagged_clause_to_literal (c);
     const bool other_eliminated = flags[INDEX (other)].eliminated;
     if (!lit_eliminated && !other_eliminated)
       {
  union watch watch;
  watch.header.binary = 1;
  watch.header.redundant = 0;
  watch.header.blocking = other;
  *q++ = watch;
       }
     else
       delete_binary (solver, 0, lit, other);
   }
      watches->end = q;
    }
}
# 8451 "upstream/satch.c"
static void
watch_saved_redundant_binaries (struct satch *solver)
{
  const unsigned *begin = solver->binaries.begin;
  const unsigned *end = solver->binaries.end;
  const struct flags *const flags = solver->flags;
  for (const unsigned *p = begin; p != end; p += 2)
    {
      const unsigned i[2] = { INDEX (p[0]), INDEX (p[1]) };
      const struct flags f[2] = { flags[i[0]], flags[i[1]] };
      const bool eliminated[2] = { f[0].eliminated, f[1].eliminated };
      if (!eliminated[0] && !eliminated[1])
 {
   watch_binary (solver, 1, p[0], p[1]);
   watch_binary (solver, 1, p[1], p[0]);
 }
      else
 delete_binary (solver, 1, p[0], p[1]);
    }
  do { (solver->binaries).end = (solver->binaries).begin; } while (0);
}



static void
watch_clauses (struct satch *solver, struct clauses *clauses)
{
  for (struct clause * c, ** PTR_c = (*clauses).begin, ** const END_c = (*clauses).end; (PTR_c != END_c) && (c = *PTR_c, 1); ++PTR_c)
      watch_clause (solver, c);
}

static void
switch_to_sparse_mode (struct satch *solver)
{
  do { (void) solver; } while(0);
  ((void)0);
  disconnect_all_clauses (solver);
  solver->dense = 0;

  watch_saved_redundant_binaries (solver);

  watch_clauses (solver, &solver->irredundant);
  watch_clauses (solver, &solver->redundant);
}





static bool
clause_eliminated (struct satch *solver, struct clause *c)
{
  ((void)0);
  ((void)0);
  const struct flags *const flags = solver->flags;
  for (unsigned lit, * P_lit = ((c)->literals), * const END_lit = P_lit + ((c)->size); (P_lit != END_lit) && (lit = *P_lit, 1); ++P_lit)
    if (flags[INDEX (lit)].eliminated)
      return 1;
  return 0;
}

static void
mark_satisfied_eliminated_redundant_clauses_garbage (struct satch *solver)
{
  for (struct clause * c, ** PTR_c = (solver->redundant).begin, ** const END_c = (solver->redundant).end; (PTR_c != END_c) && (c = *PTR_c, 1); ++PTR_c)
    if (!c->garbage)
      {
 if (clause_eliminated (solver, c))
   mark_garbage (solver, c, "eliminated");
 else if (clause_satisfied (solver, c))
   mark_garbage (solver, c, "root-level satisfied");
      }
}




static void
mark_and_collect_garbage_clauses_after_elimination (struct satch *solver)
{
  ((void)0);

  if (solver->limits.eliminate.fixed < solver->statistics.fixed)
    mark_irredundant_clauses_as_garbage_if_satisfied (solver);

  mark_satisfied_eliminated_redundant_clauses_garbage (solver);

  {
    size_t bytes = 0, count = 0;
    delete_garbage_clauses (solver, &solver->irredundant, &bytes, &count);
    delete_garbage_clauses (solver, &solver->redundant, &bytes, &count);



    message (solver, 2, "elimination", solver->statistics.eliminations,
      "collected %zu clauses (%zu bytes, %.0f MB)",
      count, bytes, bytes / (double) (1u << 20));

    do { ((void)0); solver->statistics.collected += (bytes); } while (0);
  }
}
# 8569 "upstream/satch.c"
static bool
backward_subsume_marked (struct satch *solver,
    unsigned size, unsigned lit,
    struct clause *skip, unsigned traversed)
{



  ((void)0);

  struct watches *const watches = solver->watches + lit;
  const signed char *const values = solver->values;
  const signed char *const marks = solver->marks;

  bool touched = 0;

  ((void)0);

  uint64_t ticks = 1 + cache_lines ((watches)->begin, (watches)->end);

  do { ((void)0); solver->statistics.subsumption_ticks += (ticks); } while (0);

  const union watch *const end_of_watches = watches->end, *p;
  union watch *q = watches->begin;

  for (p = q; p != end_of_watches; p++)
    {
      const union watch watch = *q++ = *p;




      struct clause *c = watch.clause;
      if (c == skip)
 continue;


      if (is_tagged_clause (c))
 {

   continue;
 }
      else

 {
   ticks++;
   if (c->garbage)
     continue;
 }

      if (c->size < size)
 continue;

      bool satisfied = 0;
      unsigned clashed = 0;
      unsigned found = 0;

      unsigned clashing = 4294967295U;

      for (unsigned other, * P_other = ((c)->literals), * const END_other = P_other + ((c)->size); (P_other != END_other) && (other = *P_other, 1); ++P_other)
 {
   const signed char value = values[other];
   if (value > 0)
     {
       satisfied = 1;
       break;
     }
   if (value < 0)
     continue;
   const signed char mark = marked_literal (marks, other);
   if (!mark)
     continue;
   if (mark < 0)
     {

       if (clashed++)
  break;
       clashing = other;




     }
   else
     ((void)0);
   found++;
 }


      if (clashed > 1)
 continue;




      if (satisfied)
 {
   mark_garbage (solver, c, "root-level satisfied");
   continue;
 }

      if (found < size)
 continue;

      ((void)0);



      if (clashed)
 {

   {
     const size_t occs = ((size_t) ((solver->watches[clashing]).end - (solver->watches[clashing]).begin));
     if (occs >= 1e3)
       continue;
   }

   ((void)0);
   ((void)0);
   do { (void) solver; } while(0);





   ((void)0);
# 8717 "upstream/satch.c"
   trace_and_check_clause_addition (solver, c, clashing);
   trace_and_check_clause_deletion (solver, c);

   mark_eliminate_literal (solver, clashing);
# 8731 "upstream/satch.c"
     {
       ((void)0);
       if (lit == clashing)
  {
    do { (void) solver; } while(0);
    q--;
  }
       else
  {
    ticks++;
    disconnect_literal (solver, clashing, c);
  }

       for (unsigned other, * P_other = ((c)->literals), * const END_other = P_other + ((c)->size); (P_other != END_other) && (other = *P_other, 1); ++P_other)
  if (other != clashing)
    mark_subsume_literal (solver, other);
     }





   if (c->size == 3)
     {
       c->garbage = 1;
       unsigned first = 4294967295U, second = 4294967295U;

       for (unsigned other, * P_other = ((c)->literals), * const END_other = P_other + ((c)->size); (P_other != END_other) && (other = *P_other, 1); ++P_other)
  if (other != clashing)
    {
      if (first == 4294967295U)
        first = other;
      else
        {
   ((void)0);
   second = other;
        }
      disconnect_literal (solver, other, c);
    }
       ((void)0);
       ((void)0);
       connect_literal (solver, first, tag_binary_clause (0, second));
       connect_literal (solver, second, tag_binary_clause (0, first));
       touched = (first == traversed || second == traversed);
       ticks += 2;
     }
   else



     {


       unsigned *r = c->literals;
       const unsigned *end_of_literals = r + c->size;
       while (((void)0), *r != clashing)
  r++;
       while (++r != end_of_literals)
  r[-1] = *r;

       c->size--;

       ((void)0);


       c->search = 0;

       do { (void) solver; } while(0);
       ( ((void)0), ++solver->statistics.strengthened );
     }
 }
      else


 {
   mark_garbage (solver, c, "subsumed");
   ( ((void)0), ++solver->statistics.subsumed );
 }
    }
  watches->end = q;
  if (((*watches).end == (*watches).begin))
    do { free ((*watches).begin); (*watches).begin = (*watches).end = (*watches).allocated = 0; } while (0);

  do { ((void)0); solver->statistics.subsumption_ticks += (ticks); } while (0);






  return touched;
}
# 8838 "upstream/satch.c"
static bool
backward_subsume_with_clause (struct satch *solver,
         struct clause *c, unsigned traversed)
{

  if (!is_temporary_binary (solver, c))

    {
      ((void)0);
      c->subsumed = 1;
    }

  ((void)0);
  do { (void) solver; } while(0);
  ((void)0);

  bool satisfied = 0;
  bool touched = 0;
  bool subsume = 1;

  uint64_t min_pos_occs = 18446744073709551615UL;
  uint64_t min_neg_occs = 18446744073709551615UL;
  unsigned min_pos_lit = 4294967295U;
  unsigned min_neg_lit = 4294967295U;

  unsigned actual_size = 0;

  const struct watches *const watches = solver->watches;
  const struct flags *const flags = solver->flags;
  const signed char *values = solver->values;
  signed char *marks = solver->marks;

  uint64_t ticks = 2;

  for (unsigned lit, * P_lit = ((c)->literals), * const END_lit = P_lit + ((c)->size); (P_lit != END_lit) && (lit = *P_lit, 1); ++P_lit)
    {
      signed char value = values[lit];

      if (value > 0)
 {
   do { (void) solver; } while(0);
   satisfied = 1;
   break;
 }

      if (value < 0)
 continue;

      const unsigned idx = INDEX (lit);
      if (!flags[idx].subsume)
 {
   do { (void) solver; } while(0);
   subsume = 0;
   break;
 }



      mark_literal (marks, lit);
      actual_size++;

      ticks++;

      const size_t pos_occs = ((size_t) ((watches[lit]).end - (watches[lit]).begin));
      if (pos_occs < min_pos_occs)
 min_pos_occs = pos_occs, min_pos_lit = lit;

      const unsigned not_lit = NOT (lit);

      const size_t neg_occs = ((size_t) ((watches[not_lit]).end - (watches[not_lit]).begin));
      if (neg_occs < min_neg_occs)
 min_neg_occs = neg_occs, min_neg_lit = not_lit;
    }

  do { ((void)0); solver->statistics.subsumption_ticks += (ticks); } while (0);

  if (satisfied)
    {

      if (!is_temporary_binary (solver, c))

 mark_garbage (solver, c, "root-level satisfied");
    }
  else if (subsume)
    {
      do { (void) solver; } while(0)
                                                           ;


      if (min_pos_occs <= 1e3)

 {
   ( (min_pos_lit == 4294967295U) ? ( fflush (1), fprintf (2, "%s:%ld: %s: Coverage goal `%s' reached.\n", "upstream/satch.c", (long) 8930, __func__, "min_pos_lit == INVALID"), abort (), (void) 0 ) : (void) 0 );
   ((void)0);

   do { (void) solver; } while(0)
                                           ;

   if (backward_subsume_marked (solver, actual_size,
           min_pos_lit, c, traversed))
     touched = 1;
 }




 if (min_neg_occs <= 1e3)

   {
     ( (min_neg_lit == 4294967295U) ? ( fflush (1), fprintf (2, "%s:%ld: %s: Coverage goal `%s' reached.\n", "upstream/satch.c", (long) 8947, __func__, "min_neg_lit == INVALID"), abort (), (void) 0 ) : (void) 0 );
     ((void)0);

     do { (void) solver; } while(0)
                                      ;

     if (backward_subsume_marked (solver, actual_size,
      min_neg_lit, c, traversed))
       touched = 1;
   }
    }

  for (unsigned lit, * P_lit = ((c)->literals), * const END_lit = P_lit + ((c)->size); (P_lit != END_lit) && (lit = *P_lit, 1); ++P_lit)
    unmark_literal (marks, lit);

  return touched;
}

static void
backward_subsume_literal (struct satch *solver, unsigned lit)
{





  ( ((void)0), ++solver->statistics.subsumption_ticks );

  const struct watches *const watches = solver->watches + lit;

  if (((size_t) ((*watches).end - (*watches).begin)) > 1e3)
    return;


  do { (void) solver; } while(0)
                    ;

  uint64_t ticks = cache_lines ((watches)->begin, (watches)->end);

RESTART:

  for (union watch watch, * PTR_watch = (*watches).begin, * const END_watch = (*watches).end; (PTR_watch != END_watch) && (watch = *PTR_watch, 1); ++PTR_watch)
    {
      struct clause *c = watch.clause;

      if (is_tagged_clause (c))
 c = untag_clause (solver, 0, lit, c);
      else

 {
   ticks++;
   if (c->garbage || c->subsumed)
     continue;
 }

      if (c->size <= 1e3)

 if (backward_subsume_with_clause (solver, c, lit))
   {




     do { (void) solver; } while(0);
     goto RESTART;
   }
    }

  do { ((void)0); solver->statistics.subsumption_ticks += (ticks); } while (0);
}
# 9027 "upstream/satch.c"
static bool
remove_duplicated_virtual_binary_clauses (struct satch *solver, unsigned lit)
{
  do { (void) solver; } while(0);
  ((void)0);
  ((void)0);

  struct watches *const watches = solver->watches + lit;
  const union watch *const end = watches->end;
  union watch *q = watches->begin, *p = q;

  uint64_t ticks = 1 + cache_lines (watches->begin, watches->end);

  signed char *marks = solver->marks;
  bool assigned = 0;

  while (!assigned && p != end)
    {
      const union watch watch = *p++;
      struct clause *c = watch.clause;
      if (is_tagged_clause (c))
 {
   const unsigned other = tagged_clause_to_literal (c);
   const signed char mark = marked_literal (marks, other);
   if (mark > 0)
     {
       really_delete_binary (solver, 0, lit, other);
       struct clause *d = tag_binary_clause (0, lit);
       disconnect_literal (solver, other, d);
       ( ((void)0), ++solver->statistics.subsumed );
       ticks++;
       continue;
     }
   if (mark < 0)
     {
       do { (void) solver; } while(0);
       trace_and_check_unit_addition (solver, lit);
       ( ((void)0), ++solver->statistics.strengthened );
       assign (solver, lit, 0, 1);
       assigned = 1;
     }
   else
     mark_literal (marks, other);
 }
      *q++ = watch;
    }

  for (const union watch * r = watches->begin; r != q; r++)
    if (is_tagged_clause (r->clause))
      unmark_literal (marks, tagged_clause_to_literal (r->clause));

  while (p != end)
    *q++ = *p++;

  watches->end = q;

  do { ((void)0); solver->statistics.subsumption_ticks += (ticks); } while (0);

  return !assigned;
}



static void
backward_subsume_variable (struct satch *solver, unsigned idx)
{
  do { (void) solver; } while(0);
  ((void)0);
  ((void)0);

  const unsigned lit = LITERAL (idx);
  const unsigned not_lit = NOT (lit);

  if (!remove_duplicated_virtual_binary_clauses (solver, lit))
    return;
  if (!remove_duplicated_virtual_binary_clauses (solver, not_lit))
    return;

  backward_subsume_literal (solver, lit);
  backward_subsume_literal (solver, not_lit);

  solver->flags[idx].subsume = 2;
}



static bool
subsumption_ticks_limit_hit (struct satch *solver)
{
  return solver->statistics.subsumption_ticks > solver->limits.subsume.ticks;
}



static void
full_backward_subsumption (struct satch *solver)
{
  if (!more_subsumption_candidates (solver))
    return;

  start_profiling (solver, &solver->profiles.subsume);
  const uint64_t subsumptions = ( ((void)0), ++solver->statistics.subsumptions );

  do { (void) solver; } while(0);

  struct flags *flags = solver->flags;

  uint64_t total_subsumed = 0, total_strengthened = 0;
  uint64_t strengthened;
  unsigned round = 0;

  do
    {
      round++;

      const uint64_t subsumed_before = solver->statistics.subsumed;
      const uint64_t strengthened_before = solver->statistics.strengthened;
      const unsigned remaining = solver->statistics.remaining;
      unsigned scheduled = 0, tried = 0;

      for (unsigned idx = 0, END_VARIABLES = (solver->size); idx < END_VARIABLES; idx++)
 {
   struct flags *f = flags + idx;
   if (f->active && (f->subsume &= 1))
     scheduled++;
 }

      for (unsigned idx = 0, END_VARIABLES = (solver->size); idx < END_VARIABLES; idx++)
 {
   struct flags *f = flags + idx;
   if (f->active && f->subsume)
     {
       backward_subsume_variable (solver, idx);
       tried++;

       if (subsumption_ticks_limit_hit (solver))
  {
    message (solver, 4, "subsumption", subsumptions,
      "subsumption ticks limit hit");
    break;
  }

     }
 }

      message (solver, 3, "subsumption", subsumptions,
        "tried %u variables %.0f%% of %u scheduled %.0f%%"
        " in round %u", tried, percent (tried, scheduled),
        scheduled, percent (scheduled, remaining), round);

      uint64_t subsumed = solver->statistics.subsumed - subsumed_before;
      strengthened = solver->statistics.strengthened - strengthened_before;

      total_subsumed += subsumed;
      total_strengthened += strengthened;

      message (solver, 3, "subsumption", subsumptions,
        "subsumed %" "lu" " and strengthened %" "lu"
        " clauses in round %u", subsumed, strengthened, round);

      report (solver, 1 + !(subsumed + strengthened), 's');

      if (round >= 2)
 break;
      if (subsumption_ticks_limit_hit (solver))
 break;

    }
  while (!solver->inconsistent && strengthened);

  for (struct clause * c, ** PTR_c = (solver->irredundant).begin, ** const END_c = (solver->irredundant).end; (PTR_c != END_c) && (c = *PTR_c, 1); ++PTR_c)
    c->subsumed = 0;

  unsigned kept = 0;
  for (unsigned idx = 0, END_VARIABLES = (solver->size); idx < END_VARIABLES; idx++)
    {
      struct flags *f = flags + idx;
      if (f->active & (f->subsume & 1))
 kept++;
    }

  message (solver, 3, "subsumption", subsumptions,
    "keeping %u variables scheduled %.0f%%",
    kept, percent (kept, solver->statistics.remaining));

  if (!kept)
    solver->limits.subsume.marked = solver->statistics.marked_subsume;

  message (solver, 2, "subsumption", subsumptions,
    "subsumed %" "lu" " and strengthened %" "lu"
    " clauses in %u rounds",
    total_subsumed, total_strengthened, round);

  stop_profiling (solver, &solver->profiles.subsume, process_time ());
}
# 9232 "upstream/satch.c"
static unsigned
actual_number_of_occurrences (struct satch *solver, unsigned lit)
{

  ((void)0);

  ((void)0);

  struct watches *watches = solver->watches + lit;

  signed char *values = solver->values;


  union watch *begin = watches->begin, *q = begin;
  const union watch *end = watches->end, *p = q;

  uint64_t ticks = 1;
  unsigned res = 0;

  while (p != end)
    {
      const union watch watch = *p++;

      struct clause *c = watch.clause;

      if (is_tagged_clause (c))
 {
   const unsigned other = tagged_clause_to_literal (c);
   if (values[other] > 0)
     {
       really_delete_binary (solver, 0, lit, other);
       struct clause *d = tag_binary_clause (0, lit);
       disconnect_literal (solver, other, d);
       ticks++;
       continue;
     }
 }
      else

 {
   ticks++;
   if (mark_garbage_if_satisfied (solver, c))
     continue;
 }

      *q++ = watch;
      res++;


      if (res > 1e3)
 break;

      if (!is_tagged_clause (c))

 if (c->size > 100)
   {
     res = 1e3 + 1;
     break;
   }

    }

  ticks += cache_lines (begin, q);
  do { ((void)0); solver->statistics.elimination_ticks += (ticks); } while (0);

  while (p != end)
    *q++ = *p++;

  watches->end = q;
  if (((*watches).end == (*watches).begin))
    do { free ((*watches).begin); (*watches).begin = (*watches).end = (*watches).allocated = 0; } while (0);

  return res;
}




static bool
can_be_eliminated (struct satch *solver, unsigned pivot_idx)
{
  const struct flags *const f = solver->flags + pivot_idx;
  if (!f->active)
    return 0;
  if (!f->eliminate)
    return 0;

  const unsigned lit = LITERAL (pivot_idx);
  const unsigned not_lit = NOT (lit);



  const uint64_t pos = actual_number_of_occurrences (solver, lit);
  const uint64_t neg = actual_number_of_occurrences (solver, not_lit);

  if (pos && neg > 1e3)
    return 0;

  if (neg && pos > 1e3)
    return 0;
# 9340 "upstream/satch.c"
  return 1;
}
# 9350 "upstream/satch.c"
static bool
produces_few_resolvents (struct satch *solver, unsigned pivot_idx)
{
  ((void)0);

  const unsigned pivot = LITERAL (pivot_idx);
  const unsigned not_pivot = NOT (pivot);

  struct watches *const pos_watches = solver->watches + pivot;
  struct watches *const neg_watches = solver->watches + not_pivot;

  ((void)0);

  do { (void) solver; } while(0);

  const size_t pos_count = ((size_t) ((*pos_watches).end - (*pos_watches).begin));
  const size_t neg_count = ((size_t) ((*neg_watches).end - (*neg_watches).begin));

  const uint64_t limit = pos_count + neg_count;
  uint64_t resolvents = 0;

  uint64_t ticks = 2;
  ticks += cache_lines ((pos_watches)->begin, (pos_watches)->end);
  ticks += cache_lines ((neg_watches)->begin, (neg_watches)->end);

  signed char *marks = solver->marks;

  ((void)0);
  ((void)0);







  for (union watch pos_watch, * PTR_pos_watch = (*pos_watches).begin, * const END_pos_watch = (*pos_watches).end; (PTR_pos_watch != END_pos_watch) && (pos_watch = *PTR_pos_watch, 1); ++PTR_pos_watch)
    {
      struct clause *c = pos_watch.clause;

      if (is_tagged_clause (c))
 c = untag_clause (solver, 0, pivot, c);
      else

 {
   ticks++;
   if (c->garbage)
     continue;
 }




      for (unsigned lit, * P_lit = ((c)->literals), * const END_lit = P_lit + ((c)->size); (P_lit != END_lit) && (lit = *P_lit, 1); ++P_lit)
 mark_literal (marks, lit);

      for (union watch neg_watch, * PTR_neg_watch = (*neg_watches).begin, * const END_neg_watch = (*neg_watches).end; (PTR_neg_watch != END_neg_watch) && (neg_watch = *PTR_neg_watch, 1); ++PTR_neg_watch)
 {
   struct clause *d = neg_watch.clause;

   if (is_tagged_clause (d))
     d = untag_clause (solver, 1, not_pivot, d);
   else

     {
       ticks++;
       if (d->garbage)
  continue;
     }

   do { (void) solver; } while(0);
   do { (void) solver; } while(0);

   ( ((void)0), ++solver->statistics.resolutions );

   bool tautological = 0;
   for (unsigned lit, * P_lit = ((d)->literals), * const END_lit = P_lit + ((d)->size); (P_lit != END_lit) && (lit = *P_lit, 1); ++P_lit)
     if (lit != not_pivot && marked_literal (marks, lit) < 0)
       {
  do { (void) solver; } while(0)
                                        ;
  tautological = 1;
  break;
       }

   if (tautological)
     continue;

   do { (void) solver; } while(0);

   if (++resolvents > limit)
     break;




   for (unsigned lit, * P_lit = ((c)->literals), * const END_lit = P_lit + ((c)->size); (P_lit != END_lit) && (lit = *P_lit, 1); ++P_lit)
     if (lit != pivot)
       do { if (((solver->resolvents).end == (solver->resolvents).allocated)) do { const size_t old_size = ((size_t) ((solver->resolvents).end - (solver->resolvents).begin)); const size_t old_capacity = ((size_t) ((solver->resolvents).allocated - (solver->resolvents).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(solver->resolvents).begin; (solver->resolvents).begin = realloc ((solver->resolvents).begin, new_bytes); if (!(solver->resolvents).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (solver->resolvents).end = (solver->resolvents).begin + old_size; (solver->resolvents).allocated = (solver->resolvents).begin + new_capacity; } while (0); *(solver->resolvents).end++ = (lit); } while (0);

   for (unsigned lit, * P_lit = ((d)->literals), * const END_lit = P_lit + ((d)->size); (P_lit != END_lit) && (lit = *P_lit, 1); ++P_lit)
     if (!marks[INDEX (lit)])
       do { if (((solver->resolvents).end == (solver->resolvents).allocated)) do { const size_t old_size = ((size_t) ((solver->resolvents).end - (solver->resolvents).begin)); const size_t old_capacity = ((size_t) ((solver->resolvents).allocated - (solver->resolvents).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(solver->resolvents).begin; (solver->resolvents).begin = realloc ((solver->resolvents).begin, new_bytes); if (!(solver->resolvents).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (solver->resolvents).end = (solver->resolvents).begin + old_size; (solver->resolvents).allocated = (solver->resolvents).begin + new_capacity; } while (0); *(solver->resolvents).end++ = (lit); } while (0);

   do { if (((solver->resolvents).end == (solver->resolvents).allocated)) do { const size_t old_size = ((size_t) ((solver->resolvents).end - (solver->resolvents).begin)); const size_t old_capacity = ((size_t) ((solver->resolvents).allocated - (solver->resolvents).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(solver->resolvents).begin; (solver->resolvents).begin = realloc ((solver->resolvents).begin, new_bytes); if (!(solver->resolvents).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (solver->resolvents).end = (solver->resolvents).begin + old_size; (solver->resolvents).allocated = (solver->resolvents).begin + new_capacity; } while (0); *(solver->resolvents).end++ = (4294967295U); } while (0);
 }

      for (unsigned lit, * P_lit = ((c)->literals), * const END_lit = P_lit + ((c)->size); (P_lit != END_lit) && (lit = *P_lit, 1); ++P_lit)
 unmark_literal (marks, lit);

      if (resolvents > limit)
 break;

      if (solver->inconsistent)
 break;
    }

  do { ((void)0); solver->statistics.elimination_ticks += (ticks); } while (0);

  if (solver->inconsistent)
    return 0;

  if (resolvents > limit)
    {
      do { (solver->resolvents).end = (solver->resolvents).begin; } while (0);
      do { (void) solver; } while(0);
      return 0;
    }

  do { (void) solver; } while(0);
  return 1;
}



static void
add_and_connect_resolvent (struct satch *solver)
{
  const size_t size = ((size_t) ((solver->clause).end - (solver->clause).begin));
  ((void)0);

  if (!size)
    {
      do { (void) solver; } while(0);
      solver->inconsistent = 1;
    }
  else if (size == 1)
    {
      const unsigned unit = ((solver->clause).begin[((void)0), (0)]);
      do { (void) solver; } while(0);
      assign (solver, unit, 0, 1);
    }

  else if (size == 2)
    {
      const unsigned lit = ((solver->clause).begin[((void)0), (0)]);
      const unsigned other = ((solver->clause).begin[((void)0), (1)]);
      do { (void) solver; } while(0);
      connect_literal (solver, lit, tag_binary_clause (0, other));
      connect_literal (solver, other, tag_binary_clause (0, lit));
      ( ((void)0), ++solver->statistics.irredundant );
    }

  else
    {
      struct clause *resolvent = new_irredundant_clause (solver);
      do { (void) solver; } while(0);
      connect_clause (solver, resolvent);
    }





  for (unsigned lit, * PTR_lit = (solver->clause).begin, * const END_lit = (solver->clause).end; (PTR_lit != END_lit) && (lit = *PTR_lit, 1); ++PTR_lit)
      mark_subsume_literal (solver, lit);


}




static void
push_clause_on_extension_stack (struct satch *solver,
    unsigned eliminated, struct clause *c)
{

  if (is_tagged_clause (c))
    c = untag_clause (solver, 0, eliminated, c);

  do { if (((solver->extend).end == (solver->extend).allocated)) do { const size_t old_size = ((size_t) ((solver->extend).end - (solver->extend).begin)); const size_t old_capacity = ((size_t) ((solver->extend).allocated - (solver->extend).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(solver->extend).begin; (solver->extend).begin = realloc ((solver->extend).begin, new_bytes); if (!(solver->extend).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (solver->extend).end = (solver->extend).begin + old_size; (solver->extend).allocated = (solver->extend).begin + new_capacity; } while (0); *(solver->extend).end++ = (4294967295U); } while (0);
  do { if (((solver->extend).end == (solver->extend).allocated)) do { const size_t old_size = ((size_t) ((solver->extend).end - (solver->extend).begin)); const size_t old_capacity = ((size_t) ((solver->extend).allocated - (solver->extend).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(solver->extend).begin; (solver->extend).begin = realloc ((solver->extend).begin, new_bytes); if (!(solver->extend).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (solver->extend).end = (solver->extend).begin + old_size; (solver->extend).allocated = (solver->extend).begin + new_capacity; } while (0); *(solver->extend).end++ = (eliminated); } while (0);
  for (unsigned lit, * P_lit = ((c)->literals), * const END_lit = P_lit + ((c)->size); (P_lit != END_lit) && (lit = *P_lit, 1); ++P_lit)
    if (lit != eliminated)
      do { if (((solver->extend).end == (solver->extend).allocated)) do { const size_t old_size = ((size_t) ((solver->extend).end - (solver->extend).begin)); const size_t old_capacity = ((size_t) ((solver->extend).allocated - (solver->extend).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(solver->extend).begin; (solver->extend).begin = realloc ((solver->extend).begin, new_bytes); if (!(solver->extend).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (solver->extend).end = (solver->extend).begin + old_size; (solver->extend).allocated = (solver->extend).begin + new_capacity; } while (0); *(solver->extend).end++ = (lit); } while (0);
}

static void
push_unit_on_extension_stack (struct satch *solver, unsigned eliminated)
{
  do { if (((solver->extend).end == (solver->extend).allocated)) do { const size_t old_size = ((size_t) ((solver->extend).end - (solver->extend).begin)); const size_t old_capacity = ((size_t) ((solver->extend).allocated - (solver->extend).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(solver->extend).begin; (solver->extend).begin = realloc ((solver->extend).begin, new_bytes); if (!(solver->extend).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (solver->extend).end = (solver->extend).begin + old_size; (solver->extend).allocated = (solver->extend).begin + new_capacity; } while (0); *(solver->extend).end++ = (4294967295U); } while (0);
  do { if (((solver->extend).end == (solver->extend).allocated)) do { const size_t old_size = ((size_t) ((solver->extend).end - (solver->extend).begin)); const size_t old_capacity = ((size_t) ((solver->extend).allocated - (solver->extend).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(solver->extend).begin; (solver->extend).begin = realloc ((solver->extend).begin, new_bytes); if (!(solver->extend).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (solver->extend).end = (solver->extend).begin + old_size; (solver->extend).allocated = (solver->extend).begin + new_capacity; } while (0); *(solver->extend).end++ = (eliminated); } while (0);
}

static void
push_clauses_on_extension_stack (struct satch *solver,
     unsigned eliminated, struct watches *watches)
{
  for (union watch watch, * PTR_watch = (*watches).begin, * const END_watch = (*watches).end; (PTR_watch != END_watch) && (watch = *PTR_watch, 1); ++PTR_watch)
      push_clause_on_extension_stack (solver, eliminated, watch.clause);
}



static void
eliminate_watched_clause (struct satch *solver,
     unsigned eliminated, struct clause *c)
{

  if (is_tagged_clause (c))
    {
      const unsigned other = tagged_clause_to_literal (c);
      really_delete_binary (solver, 0, eliminated, other);
      struct clause *d = tag_binary_clause (0, eliminated);
      disconnect_literal (solver, other, d);
      ( ((void)0), ++solver->statistics.elimination_ticks );
      c = untag_clause (solver, 0, eliminated, c);
    }
  else

  if (c->garbage)
    return;

  else

    mark_garbage (solver, c, "eliminated");




}




static void
eliminate_watched_clauses (struct satch *solver,
      unsigned eliminated, struct watches *watches)
{
  for (union watch watch, * PTR_watch = (*watches).begin, * const END_watch = (*watches).end; (PTR_watch != END_watch) && (watch = *PTR_watch, 1); ++PTR_watch)
      eliminate_watched_clause (solver, eliminated, watch.clause);
  do { free ((*watches).begin); (*watches).begin = (*watches).end = (*watches).allocated = 0; } while (0);
}







static void
eliminate_variable (struct satch *solver, unsigned pivot_idx)
{
  ((void)0);
  ((void)0);

  const unsigned pivot = LITERAL (pivot_idx);
  const unsigned not_pivot = NOT (pivot);

  do { (void) solver; } while(0);



  {
    struct flags *f = solver->flags + pivot_idx;
    ((void)0);
    ((void)0);
    f->eliminated = 1;
    f->active = 0;
    do { ((void)0); solver->statistics.remaining--; } while (0);
    ( ((void)0), ++solver->statistics.eliminated );
  }



  uint64_t ticks = 0;

  {
    const signed char *const values = solver->values;
    bool satisfied = 0;

    for (unsigned lit, * PTR_lit = (solver->resolvents).begin, * const END_lit = (solver->resolvents).end; (PTR_lit != END_lit) && (lit = *PTR_lit, 1); ++PTR_lit)
      {
 if (lit != 4294967295U)
   {
     signed char value = values[lit];
     if (value > 0)
       satisfied = 1;
     else if (!satisfied && !value)
       do { if (((solver->clause).end == (solver->clause).allocated)) do { const size_t old_size = ((size_t) ((solver->clause).end - (solver->clause).begin)); const size_t old_capacity = ((size_t) ((solver->clause).allocated - (solver->clause).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(solver->clause).begin; (solver->clause).begin = realloc ((solver->clause).begin, new_bytes); if (!(solver->clause).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (solver->clause).end = (solver->clause).begin + old_size; (solver->clause).allocated = (solver->clause).begin + new_capacity; } while (0); *(solver->clause).end++ = (lit); } while (0);
   }
 else if (satisfied)
   {
     do { (solver->clause).end = (solver->clause).begin; } while (0);
     satisfied = 0;
   }
 else
   {
     do { (void) solver; } while(0);
     trace_and_check_temporary_addition (solver);
     add_and_connect_resolvent (solver);
     ticks += ((size_t) ((solver->clause).end - (solver->clause).begin));
     do { (solver->clause).end = (solver->clause).begin; } while (0);
     ticks++;
     if (solver->inconsistent)
       break;
   }
      }
  }

  if (solver->inconsistent)
    return;

  do { (solver->resolvents).end = (solver->resolvents).begin; } while (0);

  {
    struct watches *const pos_watches = solver->watches + pivot;
    struct watches *const neg_watches = solver->watches + not_pivot;

    const size_t pos_lines = 1 + cache_lines ((pos_watches)->begin, (pos_watches)->end);
    const size_t neg_lines = 1 + cache_lines ((neg_watches)->begin, (neg_watches)->end);







    if (((size_t) ((*pos_watches).end - (*pos_watches).begin)) < ((size_t) ((*neg_watches).end - (*neg_watches).begin)))
      {
 ticks += 1 + pos_lines;
 push_clauses_on_extension_stack (solver, pivot, pos_watches);
 push_unit_on_extension_stack (solver, not_pivot);
      }
    else
      {
 ticks += 1 + neg_lines;
 push_clauses_on_extension_stack (solver, not_pivot, neg_watches);
 push_unit_on_extension_stack (solver, pivot);
      }
# 9711 "upstream/satch.c"
    ticks += 2 + pos_lines + neg_lines;

    eliminate_watched_clauses (solver, pivot, pos_watches);
    eliminate_watched_clauses (solver, not_pivot, neg_watches);
  }

  do { ((void)0); solver->statistics.elimination_ticks += (ticks); } while (0);
}
# 9732 "upstream/satch.c"
static void
set_elimination_ticks_limit (struct satch *solver)
{
  struct limits *const limits = &solver->limits;
  const struct statistics *const statistics = &solver->statistics;
  const uint64_t eliminations = statistics->eliminations;

  const uint64_t delta = statistics->ticks - limits->eliminate.search;
  uint64_t limit = delta * 0.2;
  message (solver, 2, "elimination", eliminations,
    "elimination limit of %" "lu" " ticks = %g * search ticks %"
    "lu", limit, (double) 0.2, delta);
  limits->eliminate.ticks = statistics->elimination_ticks + limit;






}

static bool
elimination_ticks_limit_hit (struct satch *solver)
{
  return solver->statistics.elimination_ticks >
    solver->limits.eliminate.ticks;
}





static void
set_subsumption_ticks_limit (struct satch *solver)
{
  struct limits *const limits = &solver->limits;
  const struct statistics *const statistics = &solver->statistics;
  const uint64_t eliminations = statistics->eliminations;

  const uint64_t delta = statistics->ticks - limits->subsume.search;
  uint64_t limit = delta * 0.1;
  message (solver, 2, "elimination", eliminations,
    "subsumption limit of %" "lu" " ticks = %g * search ticks %"
    "lu", limit, (double) 0.1, delta);
  limits->subsume.ticks = statistics->subsumption_ticks + limit;






}







static int
eliminate_variables (struct satch *solver)
{
  start_profiling (solver, &solver->profiles.eliminate);
  const uint64_t eliminations = ( ((void)0), ++solver->statistics.eliminations );



  update_phases_and_backtrack_to_root_level (solver);
  ((void)0);


  set_elimination_ticks_limit (solver);


  set_subsumption_ticks_limit (solver);





  switch_to_dense_mode (solver);



  unsigned eliminated, total = 0, round = 0;
  const unsigned original = solver->statistics.remaining;

  do
    {

      full_backward_subsumption (solver);
      if (!more_elimination_candidates (solver))
 break;

      const unsigned remaining = solver->statistics.remaining;
      eliminated = 0;
      round++;

      for (unsigned idx = 0, END_VARIABLES = (solver->size); idx < END_VARIABLES; idx++)
 {
   if (can_be_eliminated (solver, idx) &&
       produces_few_resolvents (solver, idx))
     {
       eliminate_variable (solver, idx);
       eliminated++;
     }
   else
     solver->flags[idx].eliminate = 0;

   if (solver->inconsistent)
     break;


   if (elimination_ticks_limit_hit (solver))
     {
       message (solver, 4, "elimination", eliminations,
         "elimination ticks limit hit");
       break;
     }

 }

      total += eliminated;
      message (solver, 3, "elimination", eliminations,
        "eliminated %u variables %.0f%% of remaining %u in round %u",
        eliminated, percent (eliminated, remaining), remaining, round);

      report (solver, 1 + !eliminated, 'e');

      if (round >= 2)
 break;
      if (elimination_ticks_limit_hit (solver))
 break;

    }
  while (!solver->inconsistent && eliminated);

  unsigned kept = 0;
  const struct flags *const flags = solver->flags;
  for (unsigned idx = 0, END_VARIABLES = (solver->size); idx < END_VARIABLES; idx++)
    {
      const struct flags *const f = flags + idx;
      if (!f->active)
 continue;
      if (f->eliminate)
 kept++;
    }

  message (solver, 3, "elimination", eliminations,
    "keeping %u variables scheduled %.0f%%",
    kept, percent (kept, solver->statistics.remaining));

  message (solver, 2, "elimination", eliminations,
    "eliminated %u variables %.0f%% in total in %u rounds",
    total, percent (total, original), round);




  mark_and_collect_garbage_clauses_after_elimination (solver);



  switch_to_sparse_mode (solver);



  solver->trail.propagate = solver->trail.begin;





  {
    const struct statistics *const statistics = &solver->statistics;
    struct limits *const limits = &solver->limits;

    if (!kept)
      {
 limits->eliminate.fixed = statistics->fixed;
 limits->eliminate.marked = statistics->marked_eliminate;
      }


    limits->eliminate.search = statistics->ticks;


    limits->subsume.search = statistics->ticks;


    const uint64_t interval =
      scale_interval (500, nlognlogn, eliminations);
    limits->eliminate.conflicts = (solver->statistics.conflicts) + interval;

    message (solver, 4, "elimination", eliminations,
      "next limit at %" "lu" " after %" "lu" " conflicts",
      limits->eliminate.conflicts, interval);
  }


  stop_profiling (solver, &solver->profiles.eliminate, process_time ());

  return solver->inconsistent ? 20 : 0;
}

static void
extend_solution (struct satch *solver)
{
  const unsigned *const begin = solver->extend.begin;
  signed char *const values = solver->values;

  const unsigned *p = solver->extend.end;

  unsigned last = 4294967295U;
  bool satisfied = 0;
  signed char value = -1;

  while (p != begin)
    {
      const unsigned lit = *--p;
      if (lit != 4294967295U)
 {
   value = values[lit];
   ((void)0);
   if (value > 0)
     satisfied = 1;
 }
      else if (!satisfied)
 {
   ((void)0);
   values[last] = 1;
   values[NOT (last)] = -1;
   do { (void) solver; } while(0);
 }
      else
 satisfied = 0;
      last = lit;
    }
}







static signed char
satch_fixed (struct satch *solver, unsigned lit)
{

  ((void)0);
  const signed char value = solver->values[lit];
  if (!value)
    return 0;
  if (solver->levels[INDEX (lit)])
    return 0;
  return value;
}

static inline int
int_compare (long int a, long int b)
{
  if (a < b)
    return -1;
  if (a == b)
    return 0;
  return 1;
}
# 10014 "upstream/satch.c"
static void
vivify_sort_lits_by_counts (struct satch *solver, unsigned *counts,
       struct unsigned_stack *c)
{


  (void) solver;



  do { const size_t N_RANK = ((size_t) ((*c).end - (*c).begin)); if (N_RANK <= 1) break; unsigned * V_RANK = (*c).begin; const size_t LENGTH_RANK = 8; const size_t WIDTH_RANK = (1 << LENGTH_RANK); const unsigned MASK_RANK = WIDTH_RANK - 1; size_t COUNT_RANK[WIDTH_RANK]; unsigned * TMP_RANK = 0; const size_t BYTES_TMP_RANK = N_RANK * sizeof (unsigned); unsigned * A_RANK = V_RANK; unsigned * B_RANK = 0; unsigned * C_RANK = A_RANK; unsigned MLOWER_RANK = 0; unsigned MUPPER_RANK = MASK_RANK; bool BOUNDED_RANK = 0; unsigned UPPER_RANK = 0; unsigned LOWER_RANK = ~UPPER_RANK; unsigned SHIFT_RANK = MASK_RANK; for (size_t I_RANK = 0; I_RANK < 8 * sizeof (unsigned); I_RANK += LENGTH_RANK, SHIFT_RANK <<= LENGTH_RANK) { if (BOUNDED_RANK && (LOWER_RANK & SHIFT_RANK) == (UPPER_RANK & SHIFT_RANK)) continue; memset (COUNT_RANK + MLOWER_RANK, 0, (MUPPER_RANK - MLOWER_RANK + 1) * sizeof *COUNT_RANK); unsigned * END_RANK = C_RANK + N_RANK; bool SORTED_RANK = 1; unsigned LAST_RANK = 0; for (unsigned * P_RANK = C_RANK; P_RANK != END_RANK; P_RANK++) { unsigned R_RANK = ~counts[*P_RANK]; if (!BOUNDED_RANK) { LOWER_RANK &= R_RANK; UPPER_RANK |= R_RANK; } unsigned S_RANK = R_RANK >> I_RANK; unsigned M_RANK = S_RANK & MASK_RANK; if (SORTED_RANK && LAST_RANK > M_RANK) SORTED_RANK = 0; else LAST_RANK = M_RANK; COUNT_RANK[M_RANK]++; } MLOWER_RANK = (LOWER_RANK >> I_RANK) & MASK_RANK; MUPPER_RANK = (UPPER_RANK >> I_RANK) & MASK_RANK; if (!BOUNDED_RANK) { BOUNDED_RANK = 1; if ((LOWER_RANK & SHIFT_RANK) == (UPPER_RANK & SHIFT_RANK)) continue; } if (SORTED_RANK) continue; size_t POS_RANK = 0; for (size_t J_RANK = MLOWER_RANK; J_RANK <= MUPPER_RANK; J_RANK++) { const size_t DELTA_RANK = COUNT_RANK[J_RANK]; COUNT_RANK[J_RANK] = POS_RANK; POS_RANK += DELTA_RANK; } if (!TMP_RANK) { ((void)0); TMP_RANK = malloc (BYTES_TMP_RANK); if (!TMP_RANK) out_of_memory (BYTES_TMP_RANK); B_RANK = TMP_RANK; } ((void)0); unsigned * D_RANK = (C_RANK == A_RANK) ? B_RANK : A_RANK; for (unsigned * P_RANK = C_RANK; P_RANK != END_RANK; P_RANK++) { unsigned R_RANK = ~counts[*P_RANK]; unsigned S_RANK = R_RANK >> I_RANK; unsigned M_RANK = S_RANK & MASK_RANK; const size_t POS_RANK = COUNT_RANK[M_RANK]++; D_RANK[POS_RANK] = *P_RANK; } C_RANK = D_RANK; } if (C_RANK == B_RANK) memcpy (A_RANK, B_RANK, N_RANK * sizeof *A_RANK); if (TMP_RANK) free (TMP_RANK); do { } while (0); } while (0);






}

static void
vivify_sort_stack_by_counts (struct satch *solver, unsigned *counts,
        struct unsigned_stack *c)
{
  vivify_sort_lits_by_counts (solver, counts, c);
}

static void
vivify_sort_clause_by_counts (struct satch *solver, unsigned *counts,
         struct clause *c)
{

  ((void)0);


  ((void)0);

  struct unsigned_stack c2 = {.begin = c->literals,
    .end = c->literals + c->size,
    .allocated = c->literals + c->size
  };
  vivify_sort_lits_by_counts (solver, counts, &c2);
}


static inline bool
worse_candidate (unsigned* counts, const struct clause *const c, const struct clause *const d)
{
  ((void)0);
  ((void)0);
  ((void)0);

  ((void)0);
  ((void)0);

  if (!c->vivify && d->vivify)
    return 1;

  if (c->vivify && !d->vivify)
    return 0;

  unsigned const *p = c->literals;
  unsigned const *q = d->literals;
  const unsigned *const e = c->literals + c->size;
  const unsigned *const f = d->literals + d->size;

  while (p != e && q != f)
    {
      const unsigned a = *p++;
      const unsigned b = *q++;
      if (a == b)
 continue;
      const unsigned u = counts[a];
      const unsigned v = counts[b];
      if (u < v)
        return 1;
      if (u > v)
        return 0;
      return a < b;
    }

  if (p != e && q == f)
    return 1;
  if (p == e && q != f)
    return 0;

  return (long int)c < (long int)d;
}


static void
sort_vivification_candidates (struct satch *solver,
         struct clauses *schedule, unsigned *counts)
{
  for (struct clause * c, ** PTR_c = (*schedule).begin, ** const END_c = (*schedule).end; (PTR_c != END_c) && (c = *PTR_c, 1); ++PTR_c)
    {
      vivify_sort_clause_by_counts (solver, counts, c);
    }



  do { const size_t N_SORT_STACK = ((size_t) ((*schedule).end - (*schedule).begin)); if (N_SORT_STACK <= 1) break; struct clause* * A_SORT_STACK = (*schedule).begin; do { const size_t N_SORT = (N_SORT_STACK); if (!N_SORT) break; struct clause* * A_SORT = (A_SORT_STACK); do { ((void)0); ((void)0); size_t L_QUICK_SORT = 0; size_t R_QUICK_SORT = N_SORT - 1; if (R_QUICK_SORT - L_QUICK_SORT <= 10) break; for (;;) { const size_t M = L_QUICK_SORT + (R_QUICK_SORT - L_QUICK_SORT) / 2; do { struct clause* TMP_SWAP = (A_SORT[M]); (A_SORT[M]) = (A_SORT[R_QUICK_SORT - 1]); (A_SORT[R_QUICK_SORT - 1]) = (TMP_SWAP); } while (0); do { if (worse_candidate (counts, A_SORT[R_QUICK_SORT - 1], A_SORT[L_QUICK_SORT])) do { struct clause* TMP_SWAP = (A_SORT[L_QUICK_SORT]); (A_SORT[L_QUICK_SORT]) = (A_SORT[R_QUICK_SORT - 1]); (A_SORT[R_QUICK_SORT - 1]) = (TMP_SWAP); } while (0); } while(0); do { if (worse_candidate (counts, A_SORT[R_QUICK_SORT], A_SORT[L_QUICK_SORT])) do { struct clause* TMP_SWAP = (A_SORT[L_QUICK_SORT]); (A_SORT[L_QUICK_SORT]) = (A_SORT[R_QUICK_SORT]); (A_SORT[R_QUICK_SORT]) = (TMP_SWAP); } while (0); } while(0); do { if (worse_candidate (counts, A_SORT[R_QUICK_SORT], A_SORT[R_QUICK_SORT - 1])) do { struct clause* TMP_SWAP = (A_SORT[R_QUICK_SORT - 1]); (A_SORT[R_QUICK_SORT - 1]) = (A_SORT[R_QUICK_SORT]); (A_SORT[R_QUICK_SORT]) = (TMP_SWAP); } while (0); } while(0); size_t I_QUICK_SORT; do { const size_t L_PARTITION = (L_QUICK_SORT + 1); I_QUICK_SORT = L_PARTITION - 1; size_t J_PARTITION = (R_QUICK_SORT - 1); struct clause* PIVOT_PARTITION = A_SORT[J_PARTITION]; for (;;) { while (worse_candidate (counts, A_SORT[++I_QUICK_SORT], PIVOT_PARTITION)) ; while (worse_candidate (counts, PIVOT_PARTITION, A_SORT[--J_PARTITION])) if (J_PARTITION == L_PARTITION) break; if (I_QUICK_SORT >= J_PARTITION) break; do { struct clause* TMP_SWAP = (A_SORT[I_QUICK_SORT]); (A_SORT[I_QUICK_SORT]) = (A_SORT[J_PARTITION]); (A_SORT[J_PARTITION]) = (TMP_SWAP); } while (0); } do { struct clause* TMP_SWAP = (A_SORT[I_QUICK_SORT]); (A_SORT[I_QUICK_SORT]) = (A_SORT[R_QUICK_SORT - 1]); (A_SORT[R_QUICK_SORT - 1]) = (TMP_SWAP); } while (0); } while(0); ((void)0); ((void)0); size_t LL_QUICK_SORT; size_t RR_QUICK_SORT; if (I_QUICK_SORT - L_QUICK_SORT < R_QUICK_SORT - I_QUICK_SORT) { LL_QUICK_SORT = I_QUICK_SORT + 1; RR_QUICK_SORT = R_QUICK_SORT; R_QUICK_SORT = I_QUICK_SORT - 1; } else { LL_QUICK_SORT = L_QUICK_SORT; RR_QUICK_SORT = I_QUICK_SORT - 1; L_QUICK_SORT = I_QUICK_SORT + 1; } if (R_QUICK_SORT - L_QUICK_SORT > 10) { ((void)0); do { if ((((solver->sorter)).end == ((solver->sorter)).allocated)) do { const size_t old_size = ((size_t) (((solver->sorter)).end - ((solver->sorter)).begin)); const size_t old_capacity = ((size_t) (((solver->sorter)).allocated - ((solver->sorter)).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *((solver->sorter)).begin; ((solver->sorter)).begin = realloc (((solver->sorter)).begin, new_bytes); if (!((solver->sorter)).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); ((solver->sorter)).end = ((solver->sorter)).begin + old_size; ((solver->sorter)).allocated = ((solver->sorter)).begin + new_capacity; } while (0); *((solver->sorter)).end++ = (LL_QUICK_SORT); } while (0); do { if ((((solver->sorter)).end == ((solver->sorter)).allocated)) do { const size_t old_size = ((size_t) (((solver->sorter)).end - ((solver->sorter)).begin)); const size_t old_capacity = ((size_t) (((solver->sorter)).allocated - ((solver->sorter)).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *((solver->sorter)).begin; ((solver->sorter)).begin = realloc (((solver->sorter)).begin, new_bytes); if (!((solver->sorter)).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); ((solver->sorter)).end = ((solver->sorter)).begin + old_size; ((solver->sorter)).allocated = ((solver->sorter)).begin + new_capacity; } while (0); *((solver->sorter)).end++ = (RR_QUICK_SORT); } while (0); } else if (RR_QUICK_SORT - LL_QUICK_SORT > 10) { L_QUICK_SORT = LL_QUICK_SORT; R_QUICK_SORT = RR_QUICK_SORT; } else if (!(((solver->sorter)).end == ((solver->sorter)).begin)) { R_QUICK_SORT = (((void)0), *--((solver->sorter)).end); L_QUICK_SORT = (((void)0), *--((solver->sorter)).end); } else break; } } while (0); do { size_t L_INSERTION_SORT = 0; size_t R_INSERTION_SORT = N_SORT - 1; for (size_t I_INSERTION_SORT = R_INSERTION_SORT; I_INSERTION_SORT > L_INSERTION_SORT; I_INSERTION_SORT--) do { if (worse_candidate (counts, A_SORT[I_INSERTION_SORT], A_SORT[I_INSERTION_SORT - 1])) do { struct clause* TMP_SWAP = (A_SORT[I_INSERTION_SORT - 1]); (A_SORT[I_INSERTION_SORT - 1]) = (A_SORT[I_INSERTION_SORT]); (A_SORT[I_INSERTION_SORT]) = (TMP_SWAP); } while (0); } while(0); for (size_t I_INSERTION_SORT = L_INSERTION_SORT + 2; I_INSERTION_SORT <= R_INSERTION_SORT; I_INSERTION_SORT++) { struct clause* PIVOT_INSERTION_SORT = A_SORT[I_INSERTION_SORT]; size_t J_INSERTION_SORT = I_INSERTION_SORT; while (worse_candidate (counts, PIVOT_INSERTION_SORT, A_SORT[J_INSERTION_SORT - 1])) { A_SORT[J_INSERTION_SORT] = A_SORT[J_INSERTION_SORT - 1]; J_INSERTION_SORT--; } A_SORT[J_INSERTION_SORT] = PIVOT_INSERTION_SORT; } } while (0); do { } while(0); } while (0); } while (0);
}

static void
count_literal (unsigned lit, unsigned *counts)
{
  const unsigned old_count = counts[lit];
  const unsigned new_count =
    (old_count < 4294967295U) ? old_count + 1 : 4294967295U;
  counts[lit] = new_count;
}

static void
vivify_count_clause (struct clause *c, unsigned *counts)
{
  for (unsigned lit, * P_lit = ((c)->literals), * const END_lit = P_lit + ((c)->size); (P_lit != END_lit) && (lit = *P_lit, 1); ++P_lit)
    count_literal (lit, counts);
}

void
flush_large_watches (struct satch *solver)
{



  do { (void) solver; } while(0);
  struct watches *all_watches = solver->watches;
  for (unsigned lit = 0, END_LITERALS = (2u*(solver->size)); lit < END_LITERALS; lit++)
    {
      struct watches *lit_watches = all_watches + lit;

      union watch *q = lit_watches->begin;
      const union watch *const end = lit_watches->end, *p = q;
      while (p != end)
 {
   const union watch watch = *q++ = *p++;
   const struct header header = watch.header;
   if (header.binary)
     {



     }
   else
     {
       q--;
       p++;
     }
 }
      lit_watches->end = q;



    }




}

void
watch_large_clauses (struct satch *solver)
{
  do { (void) solver; } while(0);
  for (struct clause * c, ** PTR_c = (solver->irredundant).begin, ** const END_c = (solver->irredundant).end; (PTR_c != END_c) && (c = *PTR_c, 1); ++PTR_c)
    {
      if (c->garbage)
 continue;

      c->search = 0;


      watch_clause (solver, c);

    }
  for (struct clause * c, ** PTR_c = (solver->redundant).begin, ** const END_c = (solver->redundant).end; (PTR_c != END_c) && (c = *PTR_c, 1); ++PTR_c)
    {
      if (c->garbage)
 continue;

      c->search = 0;


      watch_clause (solver, c);

    }



}

static void
promote_clause (struct satch *solver, struct clause *c, unsigned glue)
{







  const unsigned old_glue = c->glue;
  ((void)0);

  c->glue = glue;
  if (old_glue > 2 && glue <= 2)
    {
      do { (void) solver; } while(0);
    }

  else if (old_glue > 6 && glue <= 6)
    {
      do { (void) solver; } while(0);

      c->used = 2;

    }
  else
    {
      do { (void) solver; } while(0);
    }






}



inline static signed char
vivify_marked_literal (struct satch *solver, unsigned lit)
{
  const unsigned idx = INDEX (lit);
  signed char res = solver->vivify_marks[idx];
  return (res == INT_SIGN (lit));
}

void
vivify_mark_literal (struct satch *solver, unsigned lit)
{

  const unsigned idx = INDEX (lit);
  ((void)0);
  solver->vivify_marks[idx] = INT_SIGN (lit);
}

static struct clause *
vivify_boolean_constraint_propagation (struct satch *solver,
           struct clause *ignore)
{
  struct trail *trail = &solver->trail;
  unsigned *propagate = trail->propagate;
  unsigned *p;

  ((void)0);
  ((void)0);

  struct clause *conflict = 0;
  uint64_t ticks = 0;

  if (ignore)
    do { (void) solver; } while(0);
  for (p = propagate; !conflict && p != trail->end; p++)
    conflict = propagate_literal (solver, *p, ignore, &ticks);

  do { ((void)0); solver->statistics.probing_ticks += (ticks); } while (0);
  solver->trail.propagate = p;
  const unsigned propagated = p - propagate;

  do { ((void)0); solver->statistics.vivify_propagations += (propagated); } while (0);

  if (conflict)
    ( ((void)0), ++solver->statistics.vivify_conflicts );

  return conflict;
}

static void
vivify_binary_or_large_conflict (struct satch *solver,
     struct clause *conflict)
{
  ((void)0);
  ((void)0);
  do { (void) solver; } while(0)
                       ;



  for (unsigned lit, * P_lit = ((conflict)->literals), * const END_lit = P_lit + ((conflict)->size); (P_lit != END_lit) && (lit = *P_lit, 1); ++P_lit)
    {
      ((void)0);
      const unsigned level = solver->levels[INDEX (lit)];
      if (!level)
 continue;




      mark_analyzed (solver, INDEX (lit));
    }
  do { (void) solver; } while(0);
  ((void)0);
  ((void)0);
}

static void
vivify_mark_garbage (struct satch *solver, struct clause *c, const char *msg)
{
  ((void)0);

  unwatch_literal (solver, c->literals[0], c);
  unwatch_literal (solver, c->literals[1], c);




  mark_garbage (solver, c, msg);
}

static bool
vivify_learn (struct satch *solver,
       struct clause *c,
       unsigned non_false, bool irredundant, unsigned implied)
{
  bool res;

  size_t size = ((size_t) ((solver->clause).end - (solver->clause).begin));
  ((void)0);
  ((void)0);

  if (size == 1)
    {
      do { (void) solver; } while(0);
      if (solver->level)
 backtrack (solver, 0);

      const unsigned unit = ((solver->clause).begin[((void)0), (0)]);
      assign (solver, unit, 0, 1);
      solver->iterate = 1;
      vivify_mark_garbage (solver, c, "subsumed by unit");
      ((void)0);
      struct clause *conflict = boolean_constraint_propagation (solver);
      if (conflict)
 {
   ((void)0);
   do { (void) solver; } while(0);
   solver->inconsistent = 1;
   return 0;
 }
      ( ((void)0), ++solver->statistics.vivify_strengthened );
      res = 1;
    }
  else
    {
      const unsigned *const levels = solver->levels;
      const signed char *const values = solver->values;

      unsigned highest_level = 0;
      for (unsigned lit, * PTR_lit = (solver->clause).begin, * const END_lit = (solver->clause).end; (PTR_lit != END_lit) && (lit = *PTR_lit, 1); ++PTR_lit)
 {
   const signed char value = values[lit];
   if (!value)
     {
       do { (void) solver; } while(0);
       highest_level = 4294967295U;
       break;
     }
   const unsigned idx = INDEX (lit);
   const unsigned level = levels[idx];
   ((void)0);
   if (level > highest_level)
     highest_level = level;
 }

      if (highest_level != 4294967295U)
 do { (void) solver; } while(0);

      unsigned literals_on_highest_level = 0;
      for (unsigned lit, * PTR_lit = (solver->clause).begin, * const END_lit = (solver->clause).end; (PTR_lit != END_lit) && (lit = *PTR_lit, 1); ++PTR_lit)
 {
   const unsigned value = values[lit];
   if (!value)
     literals_on_highest_level++;
   else
     {
       const unsigned idx = INDEX (lit);
       const unsigned level = levels[idx];
       ((void)0);
       if (level == highest_level)
  literals_on_highest_level++;
     }
 }






      if (highest_level == 4294967295U && literals_on_highest_level > 1)
 do { (void) solver; } while(0);
      else
 {
   unsigned jump_level = 0;
   for (unsigned lit, * PTR_lit = (solver->clause).begin, * const END_lit = (solver->clause).end; (PTR_lit != END_lit) && (lit = *PTR_lit, 1); ++PTR_lit)
     {
       const signed char value = values[lit];
       if (!value)
  continue;
       const unsigned idx = INDEX (lit);
       const unsigned level = levels[idx];
       if (level == highest_level)
  continue;
       if (level > jump_level)
  jump_level = level;
     }
   do { (void) solver; } while(0);

   if (jump_level < solver->level)
     backtrack (solver, jump_level);
 }


      if (size == 2)
 {




   const bool redundant = c->redundant;
   do { (void) solver; } while(0);
   trace_and_check_temporary_addition (solver);
   add_new_binary_and_watch_it (solver, redundant);

   vivify_mark_garbage (solver, c, "vivified clause");
   ( ((void)0), ++solver->statistics.vivify_strengthened );
   res = 1;
 }
      else

      if (size < non_false)
 {

   ((void)0);



   do { (solver->clause).end = (solver->clause).begin; } while (0);
   ((void)0);
   const unsigned old_size = c->size;
   unsigned new_size = 0, *lits = c->literals;

   const unsigned litA = lits[0];
   const unsigned litB = lits[1];


   ((void)0);
   for (unsigned i = 0; i < old_size; i++)
     {
       const unsigned lit = lits[i];
       ((void)0);
       do { if (((solver->clause).end == (solver->clause).allocated)) do { const size_t old_size = ((size_t) ((solver->clause).end - (solver->clause).begin)); const size_t old_capacity = ((size_t) ((solver->clause).allocated - (solver->clause).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(solver->clause).begin; (solver->clause).begin = realloc ((solver->clause).begin, new_bytes); if (!(solver->clause).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (solver->clause).end = (solver->clause).begin + old_size; (solver->clause).allocated = (solver->clause).begin + new_capacity; } while (0); *(solver->clause).end++ = (lit); } while (0);
       bool keep = 1;
       if (lit != implied)
  {
    const unsigned idx = INDEX (lit);
    const signed char mark = solver->marks[idx];
    if (!(mark & 1))
      keep = 0;
    else if (solver->reasons[idx])
      keep = 0;
    if (!keep)
      do { (void) solver; } while(0)


                                    ;
  }
       if (!c->redundant)
  {

    if (keep)
      mark_subsume_variable (solver, INDEX (lit));


    if (!keep)
      mark_eliminate_literal (solver, lit);

  }
       if (keep)
  lits[new_size++] = lit;
              else {



              }
     }
   ((void)0);
   ((void)0);
   if (!c->shrunken)
     {
       c->shrunken = 1;
       lits[old_size - 1] = 4294967295U;
     }
   c->size = new_size;
   trace_and_check_clause_addition (solver, c, 4294967295U);
   trace_and_check_deletion (solver, ((size_t) ((solver->clause).end - (solver->clause).begin)),
        solver->clause.begin);
   do { (solver->clause).end = (solver->clause).begin; } while (0);
   if (!c->redundant

       && c->glue >= new_size

     )
     {
       promote_clause (solver, c, new_size - 1);
     }

   unwatch_literal (solver, litA, c);
   unwatch_literal (solver, litB, c);



   if (new_size == 2)
     {
       ((void)0);
       do { if (((solver->clause).end == (solver->clause).allocated)) do { const size_t old_size = ((size_t) ((solver->clause).end - (solver->clause).begin)); const size_t old_capacity = ((size_t) ((solver->clause).allocated - (solver->clause).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(solver->clause).begin; (solver->clause).begin = realloc ((solver->clause).begin, new_bytes); if (!(solver->clause).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (solver->clause).end = (solver->clause).begin + old_size; (solver->clause).allocated = (solver->clause).begin + new_capacity; } while (0); *(solver->clause).end++ = (c->literals[0]); } while (0);
       do { if (((solver->clause).end == (solver->clause).allocated)) do { const size_t old_size = ((size_t) ((solver->clause).end - (solver->clause).begin)); const size_t old_capacity = ((size_t) ((solver->clause).allocated - (solver->clause).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(solver->clause).begin; (solver->clause).begin = realloc ((solver->clause).begin, new_bytes); if (!(solver->clause).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (solver->clause).end = (solver->clause).begin + old_size; (solver->clause).allocated = (solver->clause).begin + new_capacity; } while (0); *(solver->clause).end++ = (c->literals[1]); } while (0);
       add_new_binary_and_watch_it (solver, c->redundant);
       do { (solver->clause).end = (solver->clause).begin; } while (0);
       vivify_mark_garbage (solver, c,
       "vivify shortened to binary clause");
     }
   else

     {

       c->search = 0;

       do { (void) solver; } while(0);
       ( ((void)0), ++solver->statistics.vivify_strengthened );



       watch_clause (solver, c);



     }
   res = 1;
 }
      else if (irredundant && !c->redundant)
 {
   ( ((void)0), ++solver->statistics.vivify_subsume );
   vivify_mark_garbage (solver, c, "vivify subsumed (learn)");
   res = 1;
 }
      else
 {
   do { (void) solver; } while(0);
   res = 0;
 }
    }

  return res;
}

static bool
vivify_analyze (struct satch *solver, struct clause *c,
  struct clause *conflict, bool *irredundant_ptr)
{
  ((void)0);
  ((void)0);
  do { (void) solver; } while(0);

  signed char *vivify_marks = solver->vivify_marks;
  signed char *marks = solver->marks;
  for (unsigned lit, * P_lit = ((c)->literals), * const END_lit = P_lit + ((c)->size); (P_lit != END_lit) && (lit = *P_lit, 1); ++P_lit)
    {
      do { (void) solver; } while(0);
      vivify_mark_literal (solver, lit);
    }

  bool subsumed = 0;

  if (c->redundant || !conflict->redundant)
    {
      subsumed = 1;
      for (unsigned lit, * P_lit = ((conflict)->literals), * const END_lit = P_lit + ((conflict)->size); (P_lit != END_lit) && (lit = *P_lit, 1); ++P_lit)
 {
   const signed char value = satch_fixed (solver, lit);
   if (value < 0)
     continue;
   ((void)0);
   if (vivify_marked_literal (solver, lit) > 0)
     continue;
   subsumed = 0;
   break;
 }
      if (subsumed)
 do { (void) solver; } while(0);
    }

  size_t analyzed = 0;
  bool irredundant = conflict && !conflict->redundant;

  const unsigned *const levels = solver->levels;
  const signed char *const values = solver->values;
  struct clause *const *const reasons = solver->reasons;

  while (analyzed < ((size_t) ((solver->analyzed).end - (solver->analyzed).begin)))
    {
      const unsigned idx = ((solver->analyzed).begin[((void)0), (analyzed)]).idx;
      const unsigned lit = values[LITERAL (idx)] > 0 ?
 LITERAL (idx) : NOT (LITERAL (idx));
      ((void)0);
      const unsigned not_lit = NOT (lit);
      struct clause *const reason = reasons[INDEX (lit)];
      analyzed++;
      ((void)0);
      ((void)0);
      if (!reasons[idx])
 {
   do { (void) solver; } while(0);
   do { if (((solver->clause).end == (solver->clause).allocated)) do { const size_t old_size = ((size_t) ((solver->clause).end - (solver->clause).begin)); const size_t old_capacity = ((size_t) ((solver->clause).allocated - (solver->clause).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(solver->clause).begin; (solver->clause).begin = realloc ((solver->clause).begin, new_bytes); if (!(solver->clause).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (solver->clause).end = (solver->clause).begin + old_size; (solver->clause).allocated = (solver->clause).begin + new_capacity; } while (0); *(solver->clause).end++ = (not_lit); } while (0);
 }

      else if (is_tagged_clause (reason))
 {
   const unsigned other = tagged_clause_to_literal (reason);
   const bool redundant = tagged_clause_to_redundant (reason);
   if (redundant)
     irredundant = 0;
   ((void)0);
   ((void)0);
   if (c->redundant || !redundant)
     {
       if (vivify_marked_literal (solver, lit) < 0 &&
    vivify_marked_literal (solver, other) < 0)
  {
    do { (void) solver; } while(0)
                                      ;
    subsumed = 1;
  }
     }
   if (marks[INDEX (other)] & 1)
     continue;
   do { (void) solver; } while(0)
                                                   ;
   mark_analyzed (solver, INDEX (other));
 }

      else
 {
   do { (void) solver; } while(0);
   if (reason->redundant)
     irredundant = 0;
   bool subsuming = vivify_marked_literal (solver, lit);
   for (unsigned other, * P_other = ((reason)->literals), * const END_other = P_other + ((reason)->size); (P_other != END_other) && (other = *P_other, 1); ++P_other)
     {
       if (other == lit)
  continue;
       if (other == not_lit)
  continue;
       ((void)0);
       if (!levels[INDEX (other)])
  continue;
       if (!vivify_marked_literal (solver, other))
  subsuming = 0;
       if (marks[INDEX (other)] & 1)
  continue;
       mark_analyzed (solver, INDEX (other));
     }
   if (subsuming && (c->redundant || !reason->redundant))
     {
       subsumed = 1;
       do { (void) solver; } while(0);
     }
 }
    }

  for (unsigned lit, * P_lit = ((c)->literals), * const END_lit = P_lit + ((c)->size); (P_lit != END_lit) && (lit = *P_lit, 1); ++P_lit)
    {
      do { (void) solver; } while(0);
      unmark_literal (vivify_marks, lit);
    }

  const size_t size = ((size_t) ((solver->clause).end - (solver->clause).begin));
  ((void)0);
  if (subsumed)
    {
      if (size == 1)
 {
   do { (void) solver; } while(0);







   subsumed = 0;
 }
      else
 do { (void) solver; } while(0);
    }
  if (!subsumed)
    {
      *irredundant_ptr = irredundant;
      do { (void) solver; } while(0);
    }

  return subsumed;
}

static void
vivify_reset_analyzed (struct satch *solver)
{
  signed char *marks = solver->marks;
  for (struct analyzed analyzed, * PTR_analyzed = (solver->analyzed).begin, * const END_analyzed = (solver->analyzed).end; (PTR_analyzed != END_analyzed) && (analyzed = *PTR_analyzed, 1); ++PTR_analyzed)
    {
      const unsigned idx = analyzed.idx;
      marks[idx] &= ~1;
    }
  do { (solver->analyzed).end = (solver->analyzed).begin; } while (0);
  do { (solver->clause).end = (solver->clause).begin; } while (0);
}


static struct clause *
vivify_unit_conflict (struct satch *solver, unsigned lit)
{
  ((void)0);
  const unsigned idx = INDEX (lit);
  do { (void) solver; } while(0);
  ((void)0);
  struct clause *conflict;
  struct clause *const reason = solver->reasons[idx];


  if (is_tagged_clause (reason))
    {
      conflict = untag_clause (solver, 0, lit, reason);
    }
  else

    conflict = reason;
  mark_analyzed (solver, idx);
  do { if (((solver->clause).end == (solver->clause).allocated)) do { const size_t old_size = ((size_t) ((solver->clause).end - (solver->clause).begin)); const size_t old_capacity = ((size_t) ((solver->clause).allocated - (solver->clause).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(solver->clause).begin; (solver->clause).begin = realloc ((solver->clause).begin, new_bytes); if (!(solver->clause).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (solver->clause).end = (solver->clause).begin + old_size; (solver->clause).allocated = (solver->clause).begin + new_capacity; } while (0); *(solver->clause).end++ = (lit); } while (0);
  return conflict;
}



static bool
vivify_clause (struct satch *solver, struct clause *c, unsigned *counts)
{
  ((void)0);
  ((void)0);
  const unsigned *levels = solver->levels;
  struct unsigned_stack *sorted = &solver->sorted;

  do { (void) solver; } while(0);
  do { (*sorted).end = (*sorted).begin; } while (0);

  for (unsigned lit, * P_lit = ((c)->literals), * const END_lit = P_lit + ((c)->size); (P_lit != END_lit) && (lit = *P_lit, 1); ++P_lit)
    {
      const signed char value = satch_fixed (solver, lit);
      if (value < 0)
 continue;
      if (value > 0)
 {
   vivify_mark_garbage (solver, c, "root-level satisfied");
   break;
 }
      do { if (((*sorted).end == (*sorted).allocated)) do { const size_t old_size = ((size_t) ((*sorted).end - (*sorted).begin)); const size_t old_capacity = ((size_t) ((*sorted).allocated - (*sorted).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(*sorted).begin; (*sorted).begin = realloc ((*sorted).begin, new_bytes); if (!(*sorted).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (*sorted).end = (*sorted).begin + old_size; (*sorted).allocated = (*sorted).begin + new_capacity; } while (0); *(*sorted).end++ = (lit); } while (0);
    }


  if (c->garbage)
    return 0;
  const unsigned non_false = ((size_t) ((*sorted).end - (*sorted).begin));

  ((void)0);
  ((void)0);


  if (!non_false)
    do { (void) solver; } while(0);
  else if (non_false == c->size)
    do { (void) solver; } while(0);
  else
    do { (void) solver; } while(0);

  if (non_false == 2)
    {
      do { (void) solver; } while(0);
      return 0;
    }

  unsigned unit = 4294967295U;

  for (unsigned lit, * P_lit = ((c)->literals), * const END_lit = P_lit + ((c)->size); (P_lit != END_lit) && (lit = *P_lit, 1); ++P_lit)
    {
      const signed char value = solver->values[lit];
      if (value < 0)
 continue;
      if (!value)
 {
   unit = 4294967295U;
   break;
 }
      ((void)0);
      if (unit != 4294967295U)
 {
   unit = 4294967295U;
   break;
 }
      unit = lit;
    }
  if (unit == 4294967295U)
    do { (void) solver; } while(0);
  else
    {
      do { (void) solver; } while(0);
      const unsigned level = levels[INDEX (unit)];
      ((void)0);
      do { (void) solver; } while(0);
      backtrack (solver, level - 1);
    }

  vivify_sort_stack_by_counts (solver, counts, sorted);

  unsigned implied = 4294967295U;
  unsigned falsified = 0;
  unsigned satisfied = 0;
  struct clause *conflict = 0;
  unsigned level = 0;
  bool res = 0;
  ((void)0);
  for (unsigned lit, * PTR_lit = (*sorted).begin, * const END_lit = (*sorted).end; (PTR_lit != END_lit) && (lit = *PTR_lit, 1); ++PTR_lit)
    {
      if (level++ < solver->level)
 {
   struct level frame = ((solver->control).begin[((void)0), (level - 1)]);
   const unsigned not_lit = NOT (lit);
   if (*frame.trail == not_lit)
     {
       do { (void) solver; } while(0);
       ( ((void)0), ++solver->statistics.vivify_reused );
       ( ((void)0), ++solver->statistics.vivify_probes );
       ((void)0);
       continue;
     }

   do { (void) solver; } while(0);
   backtrack (solver, level - 1);
 }
      const signed char value = solver->values[lit];
      ((void)0);
      if (!value)
 {
   do { (void) solver; } while(0);
   const unsigned not_lit = NOT (lit);
   ( ((void)0), ++solver->statistics.vivify_probes );
   solver->level++;
   assign (solver, not_lit, 0, 0);
   ((void)0);
   conflict = vivify_boolean_constraint_propagation (solver, c);
   if (!conflict)
     continue;
   vivify_binary_or_large_conflict (solver, conflict);
   ((void)0);
   break;
 }

      if (value < 0)
 {
   ((void)0);
   do { (void) solver; } while(0);
   falsified++;
   continue;
 }

      satisfied++;
      ((void)0);
      ((void)0);
      do { (void) solver; } while(0);


      if (!c->redundant)
 {
   implied = lit;
   conflict = vivify_unit_conflict (solver, lit);
   ((void)0);
   ((void)0);
 }
      else
 {
   vivify_mark_garbage (solver, c, "vivify implied");
   ( ((void)0), ++solver->statistics.vivify_implied );
   res = 1;
 }

      break;
    }

  if (c->garbage)
    {
      ((void)0);
      ((void)0);
    }
  else if (conflict)
    {
      ((void)0);
      ((void)0);
      bool irredundant;
      const bool subsumed =
 vivify_analyze (solver, c, conflict, &irredundant);

      backtrack (solver, solver->level - 1);

      if (subsumed)
 {
   vivify_mark_garbage (solver, c, "vivify subsumed");
   do { (void) solver; } while(0);
   ( ((void)0), ++solver->statistics.vivify_subsume );
   ( ((void)0), ++solver->statistics.subsumed );
   res = 1;
 }
      else
 res = vivify_learn (solver, c, non_false, irredundant, implied);
      vivify_reset_analyzed (solver);
    }
  else if (falsified && !satisfied)
    {
      do { (void) solver; } while(0);
      ((void)0);
      struct clause *const *const reasons = solver->reasons;
      ((void)0);
      for (unsigned lit, * PTR_lit = (*sorted).begin, * const END_lit = (*sorted).end; (PTR_lit != END_lit) && (lit = *PTR_lit, 1); ++PTR_lit)
 {
   const unsigned idx = INDEX (lit);
   ((void)0);
   if (reasons[idx])
     continue;
   ((void)0);
   mark_analyzed (solver, idx);
   do { if (((solver->clause).end == (solver->clause).allocated)) do { const size_t old_size = ((size_t) ((solver->clause).end - (solver->clause).begin)); const size_t old_capacity = ((size_t) ((solver->clause).allocated - (solver->clause).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(solver->clause).begin; (solver->clause).begin = realloc ((solver->clause).begin, new_bytes); if (!(solver->clause).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (solver->clause).end = (solver->clause).begin + old_size; (solver->clause).allocated = (solver->clause).begin + new_capacity; } while (0); *(solver->clause).end++ = (lit); } while (0);
 }
      res = vivify_learn (solver, c, non_false, 0, 4294967295U);
      vivify_reset_analyzed (solver);
    }
  else
    {
      ((void)0);
      do { (void) solver; } while(0);
    }

  if (!res)
    return 0;

  ( ((void)0), ++solver->statistics.vivified );

  ((void)0);
  ((void)0);
  return 1;
}

static bool
simplify_vivification_candidate (struct satch *solver, struct clause *const c)
{
  ((void)0);
  ((void)0);
  bool satisfied = 0;
  ((void)0);
  const signed char *const values = solver->values;
  do { (void) solver; } while(0);
  for (unsigned lit, * P_lit = ((c)->literals), * const END_lit = P_lit + ((c)->size); (P_lit != END_lit) && (lit = *P_lit, 1); ++P_lit)
    {
      const signed char value = values[lit];
      if (value > 0)
 {
   satisfied = 1;
   mark_garbage (solver, c, "vivification satisfied candidate");
   break;
 }
      if (!value)
 do { if (((solver->clause).end == (solver->clause).allocated)) do { const size_t old_size = ((size_t) ((solver->clause).end - (solver->clause).begin)); const size_t old_capacity = ((size_t) ((solver->clause).allocated - (solver->clause).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(solver->clause).begin; (solver->clause).begin = realloc ((solver->clause).begin, new_bytes); if (!(solver->clause).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (solver->clause).end = (solver->clause).begin + old_size; (solver->clause).allocated = (solver->clause).begin + new_capacity; } while (0); *(solver->clause).end++ = (lit); } while (0);
    }
  unsigned non_false = ((size_t) ((solver->clause).end - (solver->clause).begin));
  if (satisfied)
    {
      do { (solver->clause).end = (solver->clause).begin; } while (0);
      return 1;
    }
  if (non_false == c->size)
    {
      do { (solver->clause).end = (solver->clause).begin; } while (0);
      return 0;
    }
  ((void)0);
  ((void)0);
# 11025 "upstream/satch.c"
  if (non_false == 2)
    {




      trace_and_check_temporary_addition (solver);
      do { (void) solver; } while(0);
      add_new_binary_and_watch_it (solver, c->redundant);
      mark_garbage (solver, c, "vivification shrunken candidate");
    }
  else

    {
      const unsigned old_size = c->size;
      unsigned new_size = 0, *lits = c->literals;
      do { (solver->clause).end = (solver->clause).begin; } while (0);
      for (unsigned i = 0; i < old_size; i++)
 {
   const unsigned lit = lits[i];
   do { if (((solver->clause).end == (solver->clause).allocated)) do { const size_t old_size = ((size_t) ((solver->clause).end - (solver->clause).begin)); const size_t old_capacity = ((size_t) ((solver->clause).allocated - (solver->clause).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(solver->clause).begin; (solver->clause).begin = realloc ((solver->clause).begin, new_bytes); if (!(solver->clause).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (solver->clause).end = (solver->clause).begin + old_size; (solver->clause).allocated = (solver->clause).begin + new_capacity; } while (0); *(solver->clause).end++ = (lit); } while (0);
   const signed char value = solver->values[lit];
   if (value != 0 && solver->levels[INDEX (lit)] == 0)
     continue;
   ((void)0);
   if (value < 0)
     continue;
   lits[new_size++] = lit;
 }

      ((void)0);

      ((void)0);
      ((void)0);
      c->size = new_size;

      c->search = 0;

      if (c->redundant

   && c->glue >= new_size

 )
 promote_clause (solver, c, new_size - 1);
      if (!c->shrunken)
 {
   c->shrunken = 1;
   lits[old_size - 1] = 4294967295U;
 }
      do { (void) solver; } while(0);
      trace_and_check_clause_addition (solver, c, 4294967295U);
      trace_and_check_deletion (solver, ((size_t) ((solver->clause).end - (solver->clause).begin)),
    solver->clause.begin);





    }
  do { (solver->clause).end = (solver->clause).begin; } while (0);
  return 0;
}

static void
schedule_vivification_candidates (struct satch *solver, unsigned *counts



      , bool redundant

      , bool tier2

  )
{
  unsigned lower_glue_limit, upper_glue_limit;

  if (tier2)
    {
      lower_glue_limit = 2 + 1;
      upper_glue_limit = 6;
    }
  else


    {
      lower_glue_limit = 0;
      upper_glue_limit = 2;
    }
# 11121 "upstream/satch.c"
  size_t prioritized = 0;
  for (unsigned prioritize = 0; prioritize < 2; prioritize++)
    {
      if (!redundant)
 {
   for (struct clause * c, ** PTR_c = (solver->irredundant).begin, ** const END_c = (solver->irredundant).end; (PTR_c != END_c) && (c = *PTR_c, 1); ++PTR_c)
     {
       if (c->garbage)
  continue;
       if (c->redundant)
  continue;




       if (c->vivify != prioritize)
  {
    continue;
  }
       if (simplify_vivification_candidate (solver, c))
  continue;
       if (prioritize)
  prioritized++;
       vivify_count_clause (c, counts);
       do { if (((solver->vivification_schedule).end == (solver->vivification_schedule).allocated)) do { const size_t old_size = ((size_t) ((solver->vivification_schedule).end - (solver->vivification_schedule).begin)); const size_t old_capacity = ((size_t) ((solver->vivification_schedule).allocated - (solver->vivification_schedule).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(solver->vivification_schedule).begin; (solver->vivification_schedule).begin = realloc ((solver->vivification_schedule).begin, new_bytes); if (!(solver->vivification_schedule).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (solver->vivification_schedule).end = (solver->vivification_schedule).begin + old_size; (solver->vivification_schedule).allocated = (solver->vivification_schedule).begin + new_capacity; } while (0); *(solver->vivification_schedule).end++ = (c); } while (0);
     }
 }
      else
 {
   for (struct clause * c, ** PTR_c = (solver->redundant).begin, ** const END_c = (solver->redundant).end; (PTR_c != END_c) && (c = *PTR_c, 1); ++PTR_c)
     {
       if (c->garbage)
  continue;
       if (!c->redundant)
  continue;






       if (c->glue < lower_glue_limit)
  continue;
       if (c->glue > upper_glue_limit)
  continue;






       if (c->vivify != prioritize)
  {
    continue;
  }
       if (simplify_vivification_candidate (solver, c))
  continue;
       if (prioritize)
  prioritized++;
       vivify_count_clause (c, counts);
       do { if (((solver->vivification_schedule).end == (solver->vivification_schedule).allocated)) do { const size_t old_size = ((size_t) ((solver->vivification_schedule).end - (solver->vivification_schedule).begin)); const size_t old_capacity = ((size_t) ((solver->vivification_schedule).allocated - (solver->vivification_schedule).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(solver->vivification_schedule).begin; (solver->vivification_schedule).begin = realloc ((solver->vivification_schedule).begin, new_bytes); if (!(solver->vivification_schedule).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (solver->vivification_schedule).end = (solver->vivification_schedule).begin + old_size; (solver->vivification_schedule).allocated = (solver->vivification_schedule).begin + new_capacity; } while (0); *(solver->vivification_schedule).end++ = (c); } while (0);
     }
 }
    }




  if (prioritized)
    {
      do { (void) solver; } while(0)
                                           ;
    }
  else
    {
      do { (void) solver; } while(0);
      for (struct clause * c, ** PTR_c = (solver->vivification_schedule).begin, ** const END_c = (solver->vivification_schedule).end; (PTR_c != END_c) && (c = *PTR_c, 1); ++PTR_c
                                                     )
 {

   ((void)0);

   c->vivify = 1;
 }
    }
}

enum round
{




  REDUNDANT_TIER1_ROUND = 1,


  REDUNDANT_TIER2_ROUND = 2,

  IRREDUNDANT_ROUND = 3
};

static size_t
vivify_round (struct satch *solver, unsigned round, uint64_t delta,
       double effort)
{
  ((void)0);
  char tag;
# 11268 "upstream/satch.c"
  if (round == REDUNDANT_TIER2_ROUND)
    {
      tag = 'u';
    }
  else


  if (round == REDUNDANT_TIER1_ROUND)
    {
      tag = 'v';
    }
  else

    {
      ((void)0);
      tag = 'w';
    }


  flush_large_watches (solver);

  const uint64_t scaled = effort * delta;
  uint64_t start = solver->statistics.probing_ticks;
  const uint64_t ticks_limit = start + scaled;





  bool redundant, tier2;
# 11313 "upstream/satch.c"
  if (round == REDUNDANT_TIER1_ROUND)
    redundant = 1, tier2 = 0;
  else


  if (round == REDUNDANT_TIER2_ROUND)
    redundant = tier2 = 1;
  else

    {
      ((void)0);
      redundant = tier2 = 0;
    }

  unsigned *counts = calloc ((2u*(solver->size)), sizeof (unsigned));

  if (!counts)
    fatal_error ("could not allocate counts for vivification");
  struct clauses *schedule = &solver->vivification_schedule;


  schedule_vivification_candidates (solver, counts,



        redundant

        , tier2

    );
  const size_t scheduled = ((size_t) ((*schedule).end - (*schedule).begin));







  do { (void) solver; } while(0)
                                         ;
  size_t vivified = 0, tried = 0;

  sort_vivification_candidates (solver, schedule, counts);
  watch_large_clauses (solver);

  while (!((*schedule).end == (*schedule).begin))
    {
      if (solver->statistics.probing_ticks > ticks_limit)
 break;
      struct clause *c = (((void)0), *--(*schedule).end);
      if (c->garbage)
 continue;
      tried++;
      if (vivify_clause (solver, c, counts))
 ++vivified;
      c->vivify = 0;
      if (solver->inconsistent)
 break;
    }

  if (solver->level)
    backtrack (solver, 0);
  if (!solver->inconsistent)
    {
      size_t remain = ((size_t) ((*schedule).end - (*schedule).begin));
      const bool keep = 1;
      size_t prioritized = 0;
      if (remain)
 {
   while (!((*schedule).end == (*schedule).begin))
     {
       struct clause *c = (((void)0), *--(*schedule).end);
       if (!c->vivify)
  continue;
       prioritized++;
       if (!keep)
  c->vivify = 0;
     }
   if (!prioritized)
     do { (void) solver; } while(0);
   else if (keep)
     do { (void) solver; } while(0)
                                                    ;
 }
      else
 do { (void) solver; } while(0);
    }

  do { (*schedule).end = (*schedule).begin; } while (0);
  ((void)0);

  report (solver, 1, tag);
  free (counts);
  return scheduled;
}
# 11417 "upstream/satch.c"
static size_t
vivify_redundant_tier1 (struct satch *solver, uint64_t delta, double effort)
{
  return vivify_round (solver, REDUNDANT_TIER1_ROUND, delta, effort);
}



static size_t
vivify_redundant_tier2 (struct satch *solver, uint64_t delta, double effort)
{
  return vivify_round (solver, REDUNDANT_TIER2_ROUND, delta, effort);
}


static void
vivify_irredundant (struct satch *solver, uint64_t redundant_scheduled,
      uint64_t delta, double effort)
{

  const double factor = 10;
  const uint64_t limit = factor * redundant_scheduled;
  uint64_t irredundant_candidates = 0;

  for (struct clause * c, ** PTR_c = (solver->irredundant).begin, ** const END_c = (solver->irredundant).end; (PTR_c != END_c) && (c = *PTR_c, 1); ++PTR_c)
    {
      ((void)0);
      if (c->garbage)
 continue;
      else if (++irredundant_candidates > limit)
 break;
    }

  if (irredundant_candidates > limit)
    do { (void) solver; } while(0)


                                                             ;
  else
    {
      do { (void) solver; } while(0)


                                                               ;
      if (irredundant_candidates > redundant_scheduled)
 {
   do { (void) solver; } while(0)


                                                    ;
 }

      (void) vivify_round (solver, IRREDUNDANT_ROUND, delta, effort);
    }
}

static uint64_t
vivify_adjustment (struct satch *solver)
{
  return nlogn (1 + solver->statistics.irredundant +
  solver->statistics.redundant);
}

static bool
really_vivify (struct satch *solver)
{
  const uint64_t limit = vivify_adjustment (solver);
  const uint64_t search_ticks = solver->statistics.ticks;
  return limit < search_ticks;
}
# 11498 "upstream/satch.c"
static int
vivify (struct satch *solver)
{
  if (solver->inconsistent)
    return 20;

  if (solver->level)
    update_phases_and_backtrack_to_root_level (solver);
  ((void)0);
  ((void)0);

  const uint64_t vivifications = ( ((void)0), ++solver->statistics.vivifications );



  const uint64_t interval =
    scale_interval (1000, nlogn, vivifications);
  struct limits *const limits = &solver->limits;
  limits->vivify.conflicts = (solver->statistics.conflicts) + interval;


  if (!solver->statistics.redundant)
    return 0;
  if (!really_vivify (solver))
    return 0;

  start_profiling (solver, &solver->profiles.vivify);

  solver->vivifying = 1;


  const struct statistics *const statistics = &solver->statistics;
  const uint64_t last = statistics->ticks - limits->vivify.search;
  const uint64_t ticks = last < 1e4 ? 1e4 : last;
  const uint64_t adjustment = vivify_adjustment (solver);
  const uint64_t delta = ticks * 100*1e-3 + adjustment;




  message (solver, 2, "vivification", vivifications,
    "elimination limit of %" "lu" " ticks = %g * search ticks %"
    "lu", (solver->statistics.ticks) + delta, (double) 100*1e-3, delta);
  uint64_t redundant_scheduled = 0;
  double sum = 3 + 6 + 1;


  const uint64_t vivified = solver->statistics.vivified;





  redundant_scheduled +=
    vivify_redundant_tier2 (solver, delta, 6 / sum);



  if (!solver->inconsistent)
    {

      redundant_scheduled +=
 vivify_redundant_tier1 (solver, delta, 3 / sum);


      if (!solver->inconsistent)
 vivify_irredundant (solver, redundant_scheduled, delta,
       1 / sum);

    }


  {


    const uint64_t limit = limits->vivify.conflicts;
    limits->vivify.search = (solver->statistics.ticks);
    message (solver, 2, "vivification", vivifications,
      "%" "lu" " vivified, next limit at %" "lu" " after %" "lu"
      " conflicts", solver->statistics.vivified - vivified, limit,
      interval);

  }
  ((void)0);
  solver->vivifying = 0;
  do { (solver->vivification_schedule).end = (solver->vivification_schedule).begin; } while (0);
  stop_profiling (solver, &solver->profiles.vivify, process_time ());

  if (solver->inconsistent)
    return 20;
  else
    return 0;
}

static bool
vivifying (struct satch *solver)
{





  return solver->limits.vivify.conflicts < (solver->statistics.conflicts);



}






static void
init_limits (struct satch *solver)
{




  solver->limits.eliminate.conflicts = 500;



  solver->limits.reduce.conflicts = 300;


  solver->limits.rephase = 1e3;


  solver->limits.restart = 1;


  solver->limits.mode.conflicts = 1e3;
  solver->limits.mode.ticks.limit = 1e8;



  solver->limits.vivify.conflicts = 1000;
# 11647 "upstream/satch.c"
  (void) solver;
}







static int
solve (struct satch *solver, int delta_limit)
{
  start_profiling (solver, &solver->profiles.solve);
  report (solver, 1, '*');

  int res = solver->inconsistent ? 20 : 0;
  struct clause *conflict;

  uint64_t conflict_limit =
    delta_limit < 0 ? 18446744073709551615UL : (solver->statistics.conflicts) + delta_limit;


  start_mode (solver);

  while (!res)
    if ((conflict = boolean_constraint_propagation (solver)))
      {
 if (!analyze_conflict (solver, conflict))
   res = 20;
      }
    else
      {
 if (solver->iterate)
   iterate (solver);

 if (!solver->unassigned)
   res = 10;
 else
   {
     if ((solver->statistics.conflicts) >= conflict_limit)
       break;
     else

     if (restarting (solver))
       restart (solver);
     else


     if (switching (solver))
       switch_mode (solver);
     else


     if (reducing (solver))
       reduce (solver);
     else


     if (rephasing (solver))
       rephase (solver);
     else


     if (eliminating (solver))
       res = eliminate_variables (solver);
     else


     if (vivifying (solver))
       res = vivify (solver);
     else

       decide (solver);
   }
      }

  stop_mode (solver);


  report (solver, 1, !res ? '?' : res == 10 ? '1' : '0');
  stop_profiling (solver, &solver->profiles.solve, process_time ());
  return res;
}
# 11778 "upstream/satch.c"
static void
invalid_usage (const char *message, const char *function)
{
  ((void)0); bool colors = isatty (2); FILE * terminal_file = ((2 == 1) ? 1 : 2); (void) terminal_file;
  fprintf (2,
    "%slibsatch: %sfatal error: %sinvalid API usage in '%s': %s\n",
    (colors ? "\033[1m" : ""), (colors ? "\033[31m" : ""), (colors ? "\033[0m" : ""), function, message);
  fflush (2);
  abort ();
}
# 11819 "upstream/satch.c"
static struct satch *
internal_init (void)
{
  struct satch *solver = calloc (1, sizeof (struct satch));
  if (!solver)
    fatal_error ("could not allocate solver");







  init_binary (solver);




  solver->scores[0].factor = 1.15;


  solver->scores[1].factor = 1.05;



  init_averages (solver);

  init_limits (solver);

  init_profiles (solver);
  return solver;
}



static void
internal_release (struct satch *solver)
{





  solver->proof = 0;
  for (unsigned lit = 0, END_LITERALS = (2u*(solver->size)); lit < END_LITERALS; lit++)
    {
      struct watches *watches = solver->watches + lit;
# 11874 "upstream/satch.c"
      do { free ((*watches).begin); (*watches).begin = (*watches).end = (*watches).allocated = 0; } while (0);
    }

  free (solver->watches);

  free (solver->levels);
  free (solver->values);

  free (solver->saved);


  free (solver->targets);


  free (solver->bests);

  free (solver->marks);

  free (solver->vivify_marks);

  free (solver->flags);
  free (solver->frames);

  free (solver->position);
  do { free ((solver->control).begin); (solver->control).begin = (solver->control).end = (solver->control).allocated = 0; } while (0);

  free (solver->reasons);
  free (solver->trail.begin);



  release_queue (&solver->queue[0]);






  ((void)0);







  ((void)0);


  release_heap (&solver->scores[1]);







  do { free ((solver->put[0]).begin); (solver->put[0]).begin = (solver->put[0]).end = (solver->put[0]).allocated = 0; } while (0);




  do { free ((solver->put[1]).begin); (solver->put[1]).begin = (solver->put[1]).end = (solver->put[1]).allocated = 0; } while (0);






  do { free ((solver->extend).begin); (solver->extend).begin = (solver->extend).end = (solver->extend).allocated = 0; } while (0);
  do { free ((solver->resolvents).begin); (solver->resolvents).begin = (solver->resolvents).end = (solver->resolvents).allocated = 0; } while (0);



  do { free ((solver->poisoned).begin); (solver->poisoned).begin = (solver->poisoned).end = (solver->poisoned).allocated = 0; } while (0);
  do { free ((solver->removable).begin); (solver->removable).begin = (solver->removable).end = (solver->removable).allocated = 0; } while (0);


  do { free ((solver->shrunken).begin); (solver->shrunken).begin = (solver->shrunken).end = (solver->shrunken).allocated = 0; } while (0);

  do { free ((solver->analyzed).begin); (solver->analyzed).begin = (solver->analyzed).end = (solver->analyzed).allocated = 0; } while (0);
  do { free ((solver->clause).begin); (solver->clause).begin = (solver->clause).end = (solver->clause).allocated = 0; } while (0);
  do { free ((solver->blocks).begin); (solver->blocks).begin = (solver->blocks).end = (solver->blocks).allocated = 0; } while (0);

  do { free ((solver->binaries).begin); (solver->binaries).begin = (solver->binaries).end = (solver->binaries).allocated = 0; } while (0);


  for (struct clause * c, ** PTR_c = (solver->irredundant).begin, ** const END_c = (solver->irredundant).end; (PTR_c != END_c) && (c = *PTR_c, 1); ++PTR_c)
      (void) delete_clause (solver, c);
  do { free ((solver->irredundant).begin); (solver->irredundant).begin = (solver->irredundant).end = (solver->irredundant).allocated = 0; } while (0);

  for (struct clause * c, ** PTR_c = (solver->redundant).begin, ** const END_c = (solver->redundant).end; (PTR_c != END_c) && (c = *PTR_c, 1); ++PTR_c)
      (void) delete_clause (solver, c);
  do { free ((solver->redundant).begin); (solver->redundant).begin = (solver->redundant).end = (solver->redundant).allocated = 0; } while (0);

  ((void)0);
  ((void)0);

  release_binary (solver);


  do { free ((solver->added).begin); (solver->added).begin = (solver->added).end = (solver->added).allocated = 0; } while (0);
# 11985 "upstream/satch.c"
  do { free ((solver->vivification_schedule).begin); (solver->vivification_schedule).begin = (solver->vivification_schedule).end = (solver->vivification_schedule).allocated = 0; } while (0);
  do { free ((solver->sorted).begin); (solver->sorted).begin = (solver->sorted).end = (solver->sorted).allocated = 0; } while (0);

  free (solver);
}



static void
internal_add (struct satch *solver, int elit)
{







  if (solver->inconsistent)
    return;

  if (elit)
    {





      const unsigned ilit = import_literal (solver, elit);
      do { if (((solver->clause).end == (solver->clause).allocated)) do { const size_t old_size = ((size_t) ((solver->clause).end - (solver->clause).begin)); const size_t old_capacity = ((size_t) ((solver->clause).allocated - (solver->clause).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(solver->clause).begin; (solver->clause).begin = realloc ((solver->clause).begin, new_bytes); if (!(solver->clause).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (solver->clause).end = (solver->clause).begin + old_size; (solver->clause).allocated = (solver->clause).begin + new_capacity; } while (0); *(solver->clause).end++ = (ilit); } while (0);
      do { if (((solver->added).end == (solver->added).allocated)) do { const size_t old_size = ((size_t) ((solver->added).end - (solver->added).begin)); const size_t old_capacity = ((size_t) ((solver->added).allocated - (solver->added).begin)); const size_t new_capacity = old_capacity ? 2*old_capacity : 1; const size_t new_bytes = new_capacity * sizeof *(solver->added).begin; (solver->added).begin = realloc ((solver->added).begin, new_bytes); if (!(solver->added).begin) fatal_error ("out-of-memory reallocating '%zu' bytes", new_bytes); (solver->added).end = (solver->added).begin + old_size; (solver->added).allocated = (solver->added).begin + new_capacity; } while (0); *(solver->added).end++ = (elit); } while (0);



    }
  else
    {



      bool remove_original_clause;





      if (!imported_clause_trivial_or_satisfied (solver))
 {





   activate_literals (solver);




   const size_t size = ((size_t) ((solver->clause).end - (solver->clause).begin));

   if (!size)
     {
       do { (void) solver; } while(0);
       solver->inconsistent = 1;
     }
   else if (size == 1)
     {
# 12062 "upstream/satch.c"
       const unsigned unit = ((solver->clause).begin[((void)0), (0)]);
       const signed char value = solver->values[unit];
       if (value > 0)
  {
    do { (void) solver; } while(0);
  }
       else if (value < 0)
  {
    do { (void) solver; } while(0);
    solver->inconsistent = 1;
  }
       else
  {
    do { (void) solver; } while(0);
    assign (solver, unit, 0, 1);
    remove_original_clause = 1;
  }
     }

   else if (size == 2)
     {
       add_new_binary_and_watch_it (solver, 0);





     }

   else
     {
       struct clause *clause = new_irredundant_clause (solver);
       do { (void) solver; } while(0);

       watch_clause (solver, clause);




     }

   const size_t added = ((size_t) ((solver->added).end - (solver->added).begin));
   ((void)0);

   if (size < added)
     {
       trace_and_check_temporary_addition (solver);
       remove_original_clause = 1;
     }
   else
     remove_original_clause = 0;
 }
      else
 remove_original_clause = 1;

      do { (solver->clause).end = (solver->clause).begin; } while (0);
      if (remove_original_clause)
 {
   if (solver->proof)
     {
       start_deletion_proof_line (solver);
       for (int lit, * PTR_lit = (solver->added).begin, * const END_lit = (solver->added).end; (PTR_lit != END_lit) && (lit = *PTR_lit, 1); ++PTR_lit)
    add_external_literal_to_proof_line (solver, lit);
       end_proof_line (solver);
     }





 }
      do { (solver->added).end = (solver->added).begin; } while (0);
    }
}





struct satch *
satch_init (void)
{
  return internal_init ();
}

void
satch_release (struct satch *solver)
{
  do { if (!(solver)) invalid_usage ("zero solver argument", __func__); } while (0);
  internal_release (solver);
}







void
satch_add (struct satch *solver, int elit)
{
  do { if (!(solver)) invalid_usage ("zero solver argument", __func__); } while (0);
  do { if (!(!solver->statistics.solved)) invalid_usage ("incremental usage not implemented yet", __func__); } while (0);
  do { do { if (!((elit) != (-2147483647-1))) invalid_usage ("'INT_MIN' literal argument", __func__); } while (0); do { if (!(sizeof (void*) > 4 || abs (elit) <= (1<<29))) invalid_usage ("maximum of '2^29' variables exceeded on 32-bit system", __func__); } while (0); } while (0);
  internal_add (solver, elit);
}





void
satch_add_empty (struct satch *solver)
{
  do { if (!(solver)) invalid_usage ("zero solver argument", __func__); } while (0);
  do { if (!(!solver->statistics.solved)) invalid_usage ("incremental usage not implemented yet", __func__); } while (0);
  internal_add (solver, 0);
}

void
satch_add_unit (struct satch *solver, int unit)
{
  do { if (!(solver)) invalid_usage ("zero solver argument", __func__); } while (0);
  do { if (!(!solver->statistics.solved)) invalid_usage ("incremental usage not implemented yet", __func__); } while (0);
  do { do { if (!((unit))) invalid_usage ("zero literal argument", __func__); } while (0); do { if (!((unit) != (-2147483647-1))) invalid_usage ("'INT_MIN' literal argument", __func__); } while (0); } while (0);
  internal_add (solver, unit);
  internal_add (solver, 0);
}

void
satch_add_binary_clause (struct satch *solver, int a, int b)
{
  do { if (!(solver)) invalid_usage ("zero solver argument", __func__); } while (0);
  do { if (!(!solver->statistics.solved)) invalid_usage ("incremental usage not implemented yet", __func__); } while (0);
  do { do { if (!((a))) invalid_usage ("zero literal argument", __func__); } while (0); do { if (!((a) != (-2147483647-1))) invalid_usage ("'INT_MIN' literal argument", __func__); } while (0); } while (0);
  do { do { if (!((b))) invalid_usage ("zero literal argument", __func__); } while (0); do { if (!((b) != (-2147483647-1))) invalid_usage ("'INT_MIN' literal argument", __func__); } while (0); } while (0);
  internal_add (solver, a);
  internal_add (solver, b);
  internal_add (solver, 0);
}

void
satch_add_ternary_clause (struct satch *solver, int a, int b, int c)
{
  do { if (!(solver)) invalid_usage ("zero solver argument", __func__); } while (0);
  do { if (!(!solver->statistics.solved)) invalid_usage ("incremental usage not implemented yet", __func__); } while (0);
  do { do { if (!((a))) invalid_usage ("zero literal argument", __func__); } while (0); do { if (!((a) != (-2147483647-1))) invalid_usage ("'INT_MIN' literal argument", __func__); } while (0); } while (0);
  do { do { if (!((b))) invalid_usage ("zero literal argument", __func__); } while (0); do { if (!((b) != (-2147483647-1))) invalid_usage ("'INT_MIN' literal argument", __func__); } while (0); } while (0);
  do { do { if (!((c))) invalid_usage ("zero literal argument", __func__); } while (0); do { if (!((c) != (-2147483647-1))) invalid_usage ("'INT_MIN' literal argument", __func__); } while (0); } while (0);
  internal_add (solver, a);
  internal_add (solver, b);
  internal_add (solver, c);
  internal_add (solver, 0);
}

void
satch_add_quaternary_clause (struct satch *solver, int a, int b, int c, int d)
{
  do { if (!(solver)) invalid_usage ("zero solver argument", __func__); } while (0);
  do { if (!(!solver->statistics.solved)) invalid_usage ("incremental usage not implemented yet", __func__); } while (0);
  do { do { if (!((a))) invalid_usage ("zero literal argument", __func__); } while (0); do { if (!((a) != (-2147483647-1))) invalid_usage ("'INT_MIN' literal argument", __func__); } while (0); } while (0);
  do { do { if (!((b))) invalid_usage ("zero literal argument", __func__); } while (0); do { if (!((b) != (-2147483647-1))) invalid_usage ("'INT_MIN' literal argument", __func__); } while (0); } while (0);
  do { do { if (!((c))) invalid_usage ("zero literal argument", __func__); } while (0); do { if (!((c) != (-2147483647-1))) invalid_usage ("'INT_MIN' literal argument", __func__); } while (0); } while (0);
  do { do { if (!((d))) invalid_usage ("zero literal argument", __func__); } while (0); do { if (!((d) != (-2147483647-1))) invalid_usage ("'INT_MIN' literal argument", __func__); } while (0); } while (0);
  internal_add (solver, a);
  internal_add (solver, b);
  internal_add (solver, c);
  internal_add (solver, d);
  internal_add (solver, 0);
}







void
satch_reserve (struct satch *solver, int max_var)
{
  do { if (!(solver)) invalid_usage ("zero solver argument", __func__); } while (0);
  ((void)0);
  const size_t requested_capacity = max_var;
  if (requested_capacity > solver->capacity)
    increase_capacity (solver, requested_capacity);
}

int
satch_maximum_variable (struct satch *solver)
{
  do { if (!(solver)) invalid_usage ("zero solver argument", __func__); } while (0);
  ((void)0);
  return solver->size;
}
# 12265 "upstream/satch.c"
int
satch_val (struct satch *solver, int elit)
{
  do { if (!(solver)) invalid_usage ("zero solver argument", __func__); } while (0);
  do { do { if (!((elit))) invalid_usage ("zero literal argument", __func__); } while (0); do { if (!((elit) != (-2147483647-1))) invalid_usage ("'INT_MIN' literal argument", __func__); } while (0); } while (0);
  do { if (!(solver->status == 10)) invalid_usage ((solver->status == 20 ? "expected status to be '10' and not '20'" : !solver->status ? "expected status to be '10' and not '0'" : "expected status to be '10'"), __func__); } while (0)




                                   ;
  int eidx = abs (elit);
  ((void)0);
  ((void)0);
  const unsigned iidx = eidx - 1;
  if (iidx >= solver->size)
    return eidx;
  const unsigned ilit = LITERAL (iidx);
  signed char tmp = solver->values[ilit];
  if (!tmp)
    return eidx;
  int res = (tmp > 0) ? elit : -elit;
  if (elit < 0)
    res = -res;
  ((void)0);
  return res;
}

int
satch_solve (struct satch *solver, int conflict_limit)
{
  do { if (!(solver)) invalid_usage ("zero solver argument", __func__); } while (0);
  do { if (!(((solver->clause).end == (solver->clause).begin))) invalid_usage ("incomplete clause (zero literal missing)", __func__); } while (0)
                                               ;
  do { if (!(!solver->status)) invalid_usage ("no incremental solving yet", __func__); } while (0);
  ( ((void)0), ++solver->statistics.solved );
  if (solver->options.verbose)
    internal_section (solver, "solving");
  int res = solve (solver, conflict_limit);
  do { (void) solver; } while(0);
  solver->status = res;
  if (res == 10)
    {

      extend_solution (solver);





    }
  return res;
}



void
satch_set_verbose_level (struct satch *solver, int new_verbose_level)
{
  do { if (!(solver)) invalid_usage ("zero solver argument", __func__); } while (0);
  if (new_verbose_level < 0)
    new_verbose_level = 0;




  solver->options.verbose = new_verbose_level;
}

void
satch_enable_logging_messages (struct satch *solver)
{
  do { if (!(solver)) invalid_usage ("zero solver argument", __func__); } while (0);







  solver->options.verbose = 2147483647;
}

void
satch_ascii_proof (struct satch *solver)
{
  do { if (!(solver)) invalid_usage ("zero solver argument", __func__); } while (0);
  solver->options.ascii = 1;
}

void
satch_trace_proof (struct satch *solver, FILE * proof)
{
  do { if (!(solver)) invalid_usage ("zero solver argument", __func__); } while (0);
  solver->proof = proof;
}



double
satch_process_time (void)
{
  return process_time ();
}

void
satch_start_profiling_parsing (struct satch *solver)
{
  do { if (!(solver)) invalid_usage ("zero solver argument", __func__); } while (0);
  start_profiling (solver, &solver->profiles.parse);
}

double
satch_stop_profiling_parsing (struct satch *solver)
{
  do { if (!(solver)) invalid_usage ("zero solver argument", __func__); } while (0);
  return stop_profiling (solver, &solver->profiles.parse, process_time ());
}

void
satch_section (struct satch *solver, const char *name)
{
  do { if (!(solver)) invalid_usage ("zero solver argument", __func__); } while (0);
  internal_section (solver, name);
}

void
satch_statistics (struct satch *solver)
{
  do { if (!(solver)) invalid_usage ("zero solver argument", __func__); } while (0);
  const double stop = print_profiles (solver);
  print_statistics (solver, stop);
  print_resource_usage (solver, stop);
}

int
satch_conflicts (struct satch *solver)
{
  do { if (!(solver)) invalid_usage ("zero solver argument", __func__); } while (0);
  const uint64_t conflicts = solver->statistics.conflicts;
  return (conflicts > (uint64_t) 2147483647) ? 2147483647 : conflicts;
}
