//Kackversion in C

#include <stdio.h>
#include <stdlib.h>

typedef struct result {
	double c,ci;
	int i;
} Result;
	
void mandel(double x, double y, int max_iter, Result *r1){
	double c = 0.0;
	double ci = 0.0;
	double ci2 = 0.0;
	double c2 = 0.0;
	int i = 0;
	while( ((c2+ci2) < 4) && (i < max_iter)){
		ci = (c * ci * 2) + y;
		c = (c2 - ci2) + x;
		c2 = c * c;
		ci2 = ci * ci;
		i++;
	}
	//store result
	r1->c = c;
	r1->ci = ci;
	r1->i = i;
}

Result *benchmark (int n){
	Result *r = malloc(sizeof(Result));
	for(int i=0; i<n; i++){
		mandel(0.1,-0.5,5000,r); //compiler optimizes call away with O4, so we need to fake havig interest in the result
	}
	return r;
}
int main(){
	Result *r = malloc(sizeof(Result));
	mandel(0.1,-0.5,5000,r);
	printf("%f %f %d\n", r->c, r->ci, r->i); 
	r = benchmark(1000000);
	printf("%f %f %d\n", r->c, r->ci, r->i); 
	free(r);
}
