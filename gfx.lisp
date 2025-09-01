;; Graphics shit
 (ql:quickload 'zpng)


(defun pngpaint (file w h)
	(let* ((png (make-instance 'zpng:png
														:color-type :grayscale
														:width w
														:height h))
				 (image (zpng:data-array png)))
		(setf *pxs* 0)
		(loop for y from 0 to (1- h) do
			(loop for x from 0 to (1- w) do
				(multiple-value-bind (z i) (m4nde1-1t3r (coords->c x y w h) *iterations*)
					(if (< i *iterations*) (incf *pxs*)) ;; just for exiting
					(if (< i *iterations*)
							(setf (aref image y x 0) (mod (round (* (/ i *iterations*) 255)) 255))
							(setf (aref image y x 0) 0)))))
		(zpng:write-png png file)))


(defun i->greyscale (z i &optional (iterations *iterations*)) ;z not used
	(incf *iters-done* i) ;;location abused a bit
	(if (< i iterations)
			(mod (round (* (/ i iterations) 255)) 255)
			0))

(defun render-img-mp (w h)
	(let* ((png (make-instance 'zpng:png
														 :color-type :grayscale
														 :width w
														 :height h))
				 (image (zpng:data-array png)))

		(let* ((funs (segment-iter
										 #'(lambda (y)
												 (loop for x from 0 by 1 for px in (render-line w y h :colorizer #'i->greyscale) DO
													 (setf (aref image y x 0) px)))
										 h 12))
					 (threads (mapcar #'sb-thread:make-thread
														funs)))
			
			;;join threads
			(mapcar #'sb-thread:join-thread threads)
			;;image array now built
			png)))

(defun count-colors (png w h)
	(declare (type fixnum w h))
	(declare (optimize speed))
	(let* ((image (zpng:data-array png))
				 (colors (make-hash-table)))
		(loop for y from 0 to (1- h) do
			(loop for x from 0 to (1- w) DO
				(setf (gethash (aref image x y 0) colors) t)))
		(hash-table-count colors)))
		
(defun pngpaint-mp (file w h)
	(zpng:write-png (render-img-mp w h) file))
	

(defun make-movie-mp ()
	(let ((colors 2))
		(loop for i from 0 by 1
					while (and (> *pxs* 0) (> colors 1))
					do
						 (let ((png (render-img-tc--mp 768 768)))
							 (setf *viewport* (next-vp))
							 (zpng:write-png png (format nil "/home/bonk/coden/mandelbrot/image~4,'0d.png" i))
							 (setf colors (count-colors png 768 768)) ;FIXME: get width from png
							 (format t ".")
							 (force-output *standard-output*)
							 (incf *frames*)
							 (when (= 0 (mod i 40))
								 (format t "  ~a frames, ~a~%" i (print-stats (get-stats :reset t))))))))




(defun make-movie ()
	(loop for i from 0 to 8000 do (setf *viewport* (next-vp)) (pngpaint (format nil "/home/bonk/coden/mandelbrot/image~4,'0d.png" i) 768 768)  (format t ".")))

;;; Threading



;;MULTICOLOR

(defun iz->truecolor (z i &optional (iterations *iterations*))
	(declare (optimize speed)
					 (type fixnum i iterations)
					 (type (complex double-float) z))
	(incf *iters-done* i) ;;location abused a bit
	(if (< i iterations)
			(list
			 ;(mod (round (* (/ i iterations) 255)) 255)
			 (mod (round (* (/ (abs z) *threshold*) 255)) 255)
			 (mod (round (* (/ (abs (realpart z)) *threshold*) 255)) 255)
			 (mod (round (* (/ (abs (imagpart z)) *threshold*) 255)) 255))
			(list 0 0 0)))

;; (defun iz->truecolor (z i &optional (iterations *iterations*)) 
;; 	(if (< i iterations)
;; 			(list
;; 			 (mod (round (* (/ (abs z) *threshold*) 255)) 255)
;; 			 (mod (round (* (/ (abs (realpart z)) *threshold*) 255)) 255)
;; 			 (mod (round (* (/ (abs (imagpart z)) *threshold*) 255)) 255))
;; 			(list 0 0 0)))


(defun render-img-tc--mp (w h)
	(let* ((png (make-instance 'zpng:png
														 :color-type :truecolor
														 :width w
														 :height h))
				 (image (zpng:data-array png)))

		(let* ((funs (segment-iter #'(lambda (y)
																	(loop for x from 0 by 1 for px in (render-line w y h :colorizer #'iz->truecolor)
																				DO
																					 (destructuring-bind (r g b) px
																						 (setf (aref image y x 0) r)
																						 (setf (aref image y x 1) g)
																						 (setf (aref image y x 2) b))))
										h 12))
			
					 (threads (mapcar #'sb-thread:make-thread
														funs)))
			
			;;join threads
			(mapcar #'sb-thread:join-thread threads)
			;;image array now built
			png)))
