COLS=$(tput cols)
LNS=$(tput lines)
sbcl --non-interactive --eval "(compile-file #p\"mandel.lisp\")" --load mandel.fasl --eval "(setf *iterations* 507)" --eval "(init-travel 'juliazoom 0.995d0)" --eval "(loop while (> *pxs* 0) do (setf *viewport* (next-vp)) (asciipaint $(( ${COLS} - 1)) $(( ${LNS} -1 ))) (home) (read-cmd))"       
