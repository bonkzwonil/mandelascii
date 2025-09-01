;;Zn+1 = Zn² + C

(defparameter *viewport*
	'((-1.5d0 . 1d0)  (0.5d0 . -1d0)))

(defparameter threshold 4)

(defparameter *iterations* 100)

(defparameter *pxs* 1110)



(defun mandel (c z)
	(declare (optimize (speed 3) (safety 0)))
  (declare (type complex c))
  (declare (type complex z))
	(the complex (+ (* z z)
									c)))

(defun mandel-iter (c &optional (n *iterations*) (z #c(0s0 0s0)))
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
			(let ((z (abs (m4nde1-1t3r (coords->c x y w h)))))
				(if (< z threshold) (incf *pxs*)) ;; just for exiting
				(princ (if (>= z threshold) 
									 " "
									 (z->ascii z)))))
		(princ #\Newline)))
	

(defun calc-viewport (r i w)
	"simple viewport set centered on r,i w height and width"
	(declare (optimize (speed 3) (safety 0)))
	(list (cons (- r (/ w 2)) (- i (/ w 2)))
				(cons (+ r (/ w 2)) (+ i (/ w 2)))))

(defun set-viewport (r i w)
	"simple viewport set centered on r,i w height and width"
	(setf *viewport* (calc-viewport r i w)))

(defparameter *r* -0.6179728241319444d0)
(defparameter *i* 0.4518895494791668d0)
																				;-0.61886875
																				;0.44718610937500014

(let  ((r *r*)
			 (i *i*)
			 (w 3d0))
	(defun next-vp ()
		"Animation, next frame"
		(setf w (* w 0.995d0))
		(calc-viewport r i w)))


(defun cls ()
	(format t "~c[2J" (code-char 27)))
(defun home ()
	(format t "~c[H" (code-char 27)))


;; Optimzed c0de
;; complex numbers are just cons of double float now

(defun m4nde1-1t3r (z  &optional (max_iter (the fixnum 200)))
	(declare (optimize (speed 3) (safety 0)))
	(declare (type (complex double-float) z))
	(let ((x (realpart z))
				(y (imagpart z)))
		(declare (type double-float x))
		(declare (type double-float y))
		(declare (type fixnum max_iter))
		(let ((c (the double-float 0.0d0))
					(ci (the double-float 0.0d0))
					(c2 (the double-float 0.0d0)) ;;sq for optmzn
					(ci2 (the double-float 0.0d0))
					(i (the fixnum 0)))
			(declare (type double-float c))
			(declare (type double-float ci))
			(declare (type double-float c2))
			(declare (type double-float ci2))
			(loop while (and (< (+ c2 ci2) 4) (< i max_iter))
						do
							 (setf ci (+ (* 2 c ci) y))
							 (setf c (+ (- c2 ci2) x))
							 (setf c2 (* c c))
							 (setf ci2 (* ci ci))
							 (incf i))
			(complex c ci))))

;(time (dotimes (i 10000000) (m4nde1 0.5d0 -0.3d0))) ;0.4s
;(time (dotimes (i 10000000) (mandel 0.5d0 -0.3d0))) ;10s  :) 

