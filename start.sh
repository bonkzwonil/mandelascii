#!/usr/bin/env bash
COLS=$(tput cols)
LNS=$(tput lines)
echo $?
STARTP=$1
ITER=$2
#THREADS=$3

if [ $STARTP == "list" ];
then
		sbcl --non-interactive --load mandel.lisp --eval "(progn (cls) (home))" --eval "(format t \"Try these nice Locations: ~%~%   ~{~a~^, ~}~%\" (mapcar #'car *mandel-travel-map*))" --noprint 2>/dev/null
		exit;
fi;

sbcl --non-interactive --eval "(compile-file #p\"mandel.lisp\")" \
		 --load mandel.fasl \
		 --load threading.fasl \
		 --eval "(setf *iterations* ${ITER:=1000})" \
		 --eval "(init-travel '${STARTP:=trunks} 0.95d0)" \
		 --eval "(loop while (> *pxs* 0) do (setf *viewport* (next-vp)) (asciipaint-mp $(( ${COLS} - 1)) $(( ${LNS} -1 ))) (read-cmd))"




