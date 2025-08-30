;;Zn+1 = Zn² + C

(defparameter *viewport*
	'((-1.5 . 1)  (0.5 . -1)))

(defparameter threshold 15)

(defparameter *iterations* 200)

(defparameter *pxs* 1110)

(defun mandel (c z)
	(declare (optimize (speed 3) (safety 0)))
  (declare (type complex c))
  (declare (type complex z))
	(the complex (+ (* z z)
									c)))

(defun mandel-iter (c n &optional (z #c(0s0 0s0)))
	"iterates c n-times with mandel"
	(declare (optimize (speed 3) (safety 0)))
  (declare (type fixnum n))
  (declare (type complex c))
  (declare (type complex z))
  (declare (type fixnum threshold))
	(let ((i 0))
		(loop while (and (< i n)
										 (< (abs z) threshold))
					do
						 (setf z (mandel c z))
						 (incf i))
		z))

(defun in-mandelset-p (c &optional (iterations *iterations*))
	(>= (abs (mandel-iter c iterations))
			threshold))

(defun viewport-size (&optional (viewport *viewport*))
	(let* ((v1 (car viewport))
				 (v2 (cadr viewport))
				 (vw (- (car v2) (car v1)))
				 (vh (- (cdr v2) (cdr v1))))
		(cons vw vh)))
	
(defun coords->c (x y w h )
	"Hilfsfkt: koords in viewport c umrechnen"
	(let* ((vs (viewport-size))
				 (xn (/ (car vs) w))
				 (yn (/ (cdr vs) h)))
	(complex (+ (* xn x) (caar *viewport*))
					 (+ (* yn y) (caadr *viewport*)))))


;; (defun z->ascii (z &optional (threshold threshold))
;; 	"Asci<<farbe>> bauen"
;; 	(let* ((mina #\A)
;; 				 (maxa #\Z)
;; 				 (w (- (char-code maxa) (char-code mina))))
;; 		(code-char (round (+ (char-code mina) (* (/ z threshold) w))))))

(defun z->ascii (z &optional (threshold threshold))
	"Asci<<farbe>> bauen"
	(let* ((mina #\.)
				 (maxa #\z)
				 (w (- (char-code maxa) (char-code mina))))
		(if (> z 1)
				maxa
				(code-char (round (+ (char-code mina) (* z w) ))))))
		

(defun asciipaint (w h)
	(setf *pxs* 0)
	(loop for y from 0 to (1- h) do
		(loop for x from 0 to (1- w) do
			(let ((z (abs (mandel-iter (coords->c x y w h) *iterations*))))
				(if (< z threshold) (incf *pxs*)) ;; just for exiting
				(princ (if (>= z threshold) 
									 " "
									 (z->ascii z)))))
		(princ #\Newline)))
	

(defun calc-viewport (r i w)
	"simple viewport set centered on r,i w height and width"
	(list (cons (- r (/ w 2)) (- i (/ w 2)))
				(cons (+ r (/ w 2)) (+ i (/ w 2)))))

(defun set-viewport (r i w)
	"simple viewport set centered on r,i w height and width"
	(setf *viewport* (calc-viewport r i w)))

(defparameter *r* -0.6179728241319444)
(defparameter *i* 0.4518895494791668)
																				;-0.61886875
																				;0.44718610937500014

(let  ((r *r*)
			 (i *i*)
			 (w 3))
	(defun next-vp ()
		"Animation, next frame"
		(setf w (* w 0.95))
		(calc-viewport r i w)))


(defun cls ()
	(format t "~c[2J" (code-char 27)))
(defun home ()
	(format t "~c[H" (code-char 27)))



;; Graphics shit
;; (ql:quickload 'zpng)

;; (defun pngpaint (file w h)
;; 	(let* ((png (make-instance 'zpng:png
;; 														:color-type :grayscale
;; 														:width w
;; 														:height h))
;; 				 (image (zpng:data-array png)))
;; 		(setf *pxs* 0)
;; 		(loop for y from 0 to (1- h) do
;; 			(loop for x from 0 to (1- w) do
;; 				(let ((z (abs (mandel-iter (coords->c x y w h) *iterations*))))
;; 					(if (< z threshold) (incf *pxs*)) ;; just for exiting
;; 					(if (< z threshold)
;; 							(setf (aref image y x 0) (mod (round (* z 255)) 255))
;; 							(setf (aref image y x 0) 0)))))
;; 		(zpng:write-png png file)))
