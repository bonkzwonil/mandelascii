COLS=$(tput cols)
LNS=$(tput lines)
sbcl --non-interactive --eval "(compile-file #p\"mandel.lisp\")" --load mandel.fasl --eval "(setf *iterations* 807)" --eval "(init-travel 'spirals 0.95d0)" --eval "(loop while (> *pxs* 0) do (setf *viewport* (next-vp)) (asciipaint $(( ${COLS} - 1)) $(( ${LNS} -1 ))) (home) (read-cmd))"       
