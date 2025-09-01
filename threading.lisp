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
		(loop for line across linebuf DO
			(mapcar #'princ
							line)
			(princ #\Newline)))
	(home))



;(segment-iter #'(lambda (y) (render-line 100 y 16)) i 16)

