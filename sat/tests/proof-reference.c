#define NDEBUG 1
#include "../upstream/satch.c"
int main(int argc,char **argv) {
 if(argc!=3)return 1; int n,m,limit,lit;
 if(scanf("%d %d %d",&n,&m,&limit)!=3)return 1;
 struct satch *s=satch_init();satch_reserve(s,n);
 FILE *proof=fopen(argv[1],"wb");if(!proof)return 1;
 if(argv[2][0]=='a')satch_ascii_proof(s);
 satch_trace_proof(s,proof);
 for(int i=0;i<m;i++) { do { if(scanf("%d",&lit)!=1) return 1; satch_add(s,lit); } while(lit); }
 printf("%d\n",satch_solve(s,limit));satch_release(s);fclose(proof);return 0;
}
