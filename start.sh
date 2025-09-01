COLS=$(tput cols)
LNS=$(tput lines)
sbcl --non-interactive --eval "(compile-file #p\"mandel.lisp\")" --load mandel.fasl --load threading.fasl --eval "(setf *iterations* 2000)" --eval "(init-travel 'trunks 0.95d0)" --eval "(loop while (> *pxs* 0) do (setf *viewport* (next-vp)) (asciipaint-mp $(( ${COLS} - 1)) $(( ${LNS} -1 ))) (read-cmd))"       
