COLS=$(tput cols)
LNS=$(tput lines)
sbcl --non-interactive --eval "(compile-file #p\"mandel.lisp\")" --load mandel.fasl --eval "(setf *iterations* 107)" --eval "(loop do (setf *viewport* (next-vp)) (asciipaint $(( ${COLS} - 1)) $(( ${LNS} -1 ))) (home))"       
