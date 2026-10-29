#ifndef COMPAT_H
#define COMPAT_H
typedef unsigned long size_t;
typedef long ptrdiff_t;
typedef unsigned long uint64_t;
typedef unsigned long uintptr_t;
typedef unsigned int uint32_t;
typedef unsigned char uint8_t;
typedef _Bool bool;
typedef void FILE;
typedef void *va_list;
#define true 1
#define false 0
#define NULL 0
#define UINT_MAX 4294967295U
#define UINT32_MAX 4294967295U
#define INT_MAX 2147483647
#define INT_MIN (-2147483647-1)
#define UINT64_MAX 18446744073709551615UL
#define SIZE_MAX UINT64_MAX
#define PRIu64 "lu"
#define PRId64 "ld"
#define __attribute__(x)
#define assert(...) ((void)0)
#define va_start(a,b) ((a)=cl_varargs)
#define va_end(a) ((void)0)
#define stdout 1
#define stderr 2
#define RUSAGE_SELF 0
#define _SC_PAGESIZE 30
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
#endif
