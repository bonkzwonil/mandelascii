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
				(let ((z (abs (m4nde1-1t3r (coords->c x y w h) *iterations*))))
					(if (< z threshold) (incf *pxs*)) ;; just for exiting
					(if (< z threshold)
							(setf (aref image y x 0) (mod (round (* z 255)) 255))
							(setf (aref image y x 0) 0)))))
		(zpng:write-png png file)))

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

(defun render-img-mp (w h)
	(let* ((png (make-instance 'zpng:png
														 :color-type :grayscale
														 :width w
														 :height h))
				 (image (zpng:data-array png)))

		(let* ((funs (segment-iter #'(lambda (y)
																	(loop for x from 0 by 1 for px in (render-line w y h :colorizer #'i->greyscale)
																				DO
																					 (setf (aref image y x 0) px)))
										h 12))
			
					 (threads (mapcar #'sb-thread:make-thread
														funs)))
			
			;;join threads
			(mapcar #'sb-thread:join-thread threads)
			;;image array now built
			png)))

(defun count-colors (png w h)
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
						 (let ((png (render-img-mp 768 768)))
							 (setf *viewport* (next-vp))
							 (zpng:write-png png (format nil "/home/bonk/coden/mandelbrot/image~4,'0d.png" i))
							 (setf colors (count-colors png 768 768)) ;FIXME: get width from png
							 (format t ".")
							 (force-output *standard-output*)
							 (when (= 0 (mod i 40))
								 (format t "  ~a~%" i))))))




(defun make-movie ()
	(loop for i from 0 to 8000 do (setf *viewport* (next-vp)) (pngpaint (format nil "/home/bonk/coden/mandelbrot/image~4,'0d.png" i) 768 768)  (format t ".")))

;;; Threading

