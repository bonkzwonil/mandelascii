a.out:
	gcc c.c

ao.out:
	gcc -O c.c -o ao.out

a4.out:
	gcc -O4 c.c -o a4.out

bench.fasl:
	sbcl --non-interactive --eval "(compile-file \"bench.lisp\")"

cobol:
	cobc  --std=ibm -Wall -v -fno-binary-truncate -fnotrunc -O2 -A "-O3 -ffast-math -fomit-frame-pointer " -x cobol.cob

.PHONY compile: a.out bench.fasl a4.out ao.out cobol



run: compile
	echo Nodejs | tee > timing.txt
	time -v -o timing.tmp node node.js
	cat timing.tmp | tee>> timing.txt
	echo Common Lisp | tee >> timing.txt
	time -v -o timing.tmp sbcl --non-interactive --load bench.fasl --eval "(benchmark)" |tee >>timing.txt
	echo C| tee >> timing.txt
	time -v -o timing.tmp ./a.out
	cat timing.tmp | tee>> timing.txt
	echo C -O| tee >> timing.txt
	time -v -o timing.tmp ./ao.out
	cat timing.tmp | tee>> timing.txt
	echo C -O4| tee >> timing.txt
	time -v -o timing.tmp ./a4.out
	cat timing.tmp | tee>> timing.txt
#slowest bastard last
	echo and the sucker Python | tee >> timing.txt
	time -v -o timing.tmp python3 python.py
	cat timing.tmp | tee>> timing.txt
	echo AND COBOL, LOL | tee >> timing.txt
	time -v -o timing.tmp ./cobol
	cat timing.tmp | tee>> timing.txt
	rm timing.tmp
	cat timing.txt

clean:
	@rm *.out bench.fasl *.o cobol *.i perf.* timing.* *.s 



