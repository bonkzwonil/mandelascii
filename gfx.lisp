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



(defun make-movie ()
	(loop for i from 0 to 8000 do (setf *viewport* (next-vp)) (pngpaint (format nil "/home/bonk/coden/mandelbrot/image~4,'0d.png" i) 768 768)  (format t ".")))

;;; Threading

