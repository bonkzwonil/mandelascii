;;Lets speed shit up

(defmacro segment-iter (func i n &optional (n-threads 4))
	;;build n-threads iter specs
	(cons 'list
				(loop for ti from 0 to (1- n-threads) collect
							`(lambda () (loop for ,i from ,ti to (1- ,n) by ,n-threads collect (funcall ,func ,i))))))

;(segment-iter #'(lambda (x) x) i 12)


(defun render-line (w y h)
	(loop for x from 0 to (1- w)
				collect
				(multiple-value-bind (z i) (m4nde1-1t3r (coords->c x y w h) *iterations*)
					(if (< i *iterations*) (incf *pxs*)) ;; just for exiting
					(if (< i *iterations*)
							(mod (round (* (/ i *iterations*) 255)) 255)
							0))))

(defun render-line-ascii (w y h)  ;;fixme: combine
	(loop for x from 0 to (1- w)
				collect
				(multiple-value-bind (z i) (m4nde1-1t3r (coords->c x y w h) *iterations*)
					(if (< i *iterations*) (incf *pxs*)) ;; just for exiting
					(z->ascii2 i))))


;(segment-iter #'(lambda (y) (render-line 100 y 16)) i 16)

;; (defun render-img-mp (w h)
;; 	(let* ((png (make-instance 'zpng:png
;; 														 :color-type :grayscale
;; 														 :width w
;; 														 :height h))
;; 				 (image (zpng:data-array png)))

;; 		(let* ((funs (segment-iter #'(lambda (y)
;; 																	(loop for x from 0 by 1 for px in (render-line w y h)
;; 																				DO
;; 																					 (setf (aref image y x 0) px)))
;; 										i h 12))
			
;; 					 (threads (mapcar #'sb-thread:make-thread
;; 														funs)))
			
;; 			;;join threads
;; 			(mapcar #'sb-thread:join-thread threads)
;; 			;;image array now built
;; 			png)))
		
;; (defun pngpaint-mp (file w h)
;; 	(zpng:write-png (render-img-mp w h) file))
	

;; (defun make-movie-mp ()
;; 	(loop for i from 0 by 1 while (> *pxs* 0)
;; 				do (setf *viewport* (next-vp))
;; 					 (pngpaint-mp (format nil "/home/bonk/coden/mandelbrot/image~4,'0d.png" i) 768 768)
;; 					 (format t ".")))




(defun asciipaint-mp (w h)
	(setf *pxs* 0)
	(let* ((linebuf (make-array h))
				 (funs (segment-iter #'(lambda (y)
																 (setf (aref linebuf y) (render-line-ascii w y h)))
									 i h 10))
			
				 (threads (mapcar #'sb-thread:make-thread
													funs)))
		;;join threads
		(mapcar #'sb-thread:join-thread threads)
		(loop for line across linebuf DO
			(mapcar #'princ
							line)
			(princ #\Newline)))
	(home))
