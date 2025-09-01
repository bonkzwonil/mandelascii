;;Lets speed shit up

(defmacro segment-iter (func n &optional (n-threads 4))
	;;build n-threads iter specs
	(cons 'list
				(loop for ti from 0 to (1- n-threads) collect
							`(lambda () (loop for i from ,ti to (1- ,n) by ,n-threads collect (funcall ,func i))))))

;(segment-iter #'(lambda (x) x) i 12)


(defun render-line (w y h &key (colorizer #'z->ascii2))
	(declare (optimize speed)
					 (type fixnum w y h)
					 (type function colorizer))
	(loop for x from 0 to (1- w)
				collect
				(multiple-value-bind (z i) (m4nde1-1t3r (coords->c x y w h) *iterations*)
					(if (< i *iterations*) (incf *pxs*)) ;; just for exiting
					(funcall colorizer z i))))
			

(defun asciipaint-mp (w h)
	(setf *pxs* 0)
	(incf *frames*)
	(let* ((linebuf (make-array h))
				 (funs (segment-iter #'(lambda (y)
																 (setf (aref linebuf y) (render-line w y h)))
									 h 10))
			
				 (threads (mapcar #'sb-thread:make-thread
													funs)))
		;;join threads
		(mapcar #'sb-thread:join-thread threads)
		(home)
		(loop for line across linebuf DO
			(mapcar #'princ
							line)
			(princ #\Newline))
		(when (> *delay* 0)
			(sleep (/ *delay* 1000)))
		;;return linebuf, as we might need it (for counting colors etc
		linebuf))


;(segment-iter #'(lambda (y) (render-line 100 y 16)) i 16)


(defun count-colors-ascii (linebuf) ;;FIXME: shit implementation!
	(declare (optimize speed)
					 (type (simple-vector) linebuf))
	(let*  ((colors (make-hash-table)))
		(loop for line across linebuf do
					(loop for char in line do
						(setf (gethash char colors) t)))
		(hash-table-count colors)))

	
