a.out:
	gcc c.c

ao.out:
	gcc -O c.c -o ao.out

a4.out:
	gcc -O4 c.c -o a4.out

bench.fasl:
	sbcl --non-interactive --eval "(compile-file \"bench.lisp\")"

.PHONY compile: a.out bench.fasl a4.out ao.out

all: compile
	@echo Nodejs
	time node node.js
	@echo Common Lisp
	time sbcl --non-interactive --load bench.fasl --eval "(benchmark)"
	@echo C
	time ./a.out
	@echo C -O
	time ./ao.out
	@echo C -O4
	time ./a4.out
#slowest bastard last
	@echo and the sucker
	time python3 python.py


clean:
	@rm *.out bench.fasl



