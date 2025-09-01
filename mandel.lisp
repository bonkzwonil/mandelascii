;;Zn+1 = Zn² + C

(defparameter *viewport*
	'((-2.0d0 . 1.2d0)  (1d0 . -1.2d0)))

(defparameter threshold 3.0d0)

(defparameter *iterations* 100)

(defparameter *pxs* 1110)

(defparameter *interactive-p* t) ;; Interactive Mode: move with w,a,s,d , accelerate/decelerte with k,l

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
					 (+ (* yn y) (cdar *viewport*)))))


;; (defun z->ascii (z &optional (threshold threshold))
;; 	"Asci<<farbe>> bauen"
;; 	(let* ((mina #\A)
;; 				 (maxa #\Z)
;; 				 (w (- (char-code maxa) (char-code mina))))
;; 		(code-char (round (+ (char-code mina) (* (/ z threshold) w))))))

(defun z->ascii (z &optional (threshold threshold))
	"Asci<<farbe>> bauen"
	(if (>= z threshold)
			" "
			(let* ((mina #\.)
						 (maxa #\z)
						 (w (- (char-code maxa) (char-code mina))))
				(if (> z 1)
						maxa
						(code-char (round (+ (char-code mina) (* z w) )))))))

(defun z->ascii2 (i &optional (iterations *iterations*))
	"Asci<<farbe>> bauen (2. methode: nach iter"
	(if (>= i iterations)
			" "
			(let* ((mina #\.)
						 (maxa #\z)
						 (w (- (char-code maxa) (char-code mina))))
				(if maxa
						(code-char (round (+ (char-code mina) (* (/ i *iterations*) w))))))))


(defun asciipaint (w h)
	(setf *pxs* 0)
	(loop for y from 0 to (1- h) do
		(loop for x from 0 to (1- w) do
			(multiple-value-bind (z i) (m4nde1-1t3r (coords->c x y w h))
				(if (< i *iterations*) (incf *pxs*)) ;; just for exiting
				(princ 	(z->ascii2 i))))
		(princ #\Newline))
	(home))




	

(defun calc-viewport (r i w)
	"simple viewport set centered on r,i w height and width"
	(declare (optimize (speed 3) (safety 0)))
  (declare (type double-float r))
  (declare (type double-float i))
  (declare (type double-float w))
	(list (cons (- r (/ w 2.0d0)) (- i (/ w 2.0d0)))
				(cons (+ r (/ w 2.0d0)) (+ i (/ w 2.0d0)))))

(defun set-viewport (r i w)
	"simple viewport set centered on r,i w height and width"
	(setf *viewport* (calc-viewport r i w)))

;(defparameter *r* -0.6179728241319444d0)
;(defparameter *i* 0.4518895494791668d0)

;(defparameter *r* 0.001643721971153d0)
;(defparameter *i* 0.82246763329887d0)
																				;-0.61886875
																				;0.44718610937500014

(defun init-coords (r i &optional (speed 0.95d0))
	"sets coordinate system on center point and builds transform functions"
	(let  ((w 3d0)
				 (dr 0d0)
				 (di 0d0))
		(defun next-vp ()
			"Animation, next frame"
			(setf w (* w speed))
			(incf i di)
			(incf r dr)
			(calc-viewport r i w))
		;;for interactive mode
		(defun move (drp dip) ;in percent of w
			(incf dr (* (/ w 100.0d0) drp))
			(incf di (* (/ w 100.0d0) dip)))
		(defun reset-move ()
			(setf dr 0d0)
			(setf di 0d0))))


;;SOme interesting coords:

(defparameter *mandel-travel-map*
	'((spirals -0.343806077d0 -0.611278040)
		(starfish -0.374004139 -0.659792175)
		(trunks 0.001643721971153d0 0.82246763329887d0)
		(julia -1.768778833d0 0.001738996d0)
		(juliazoom -1.768778832d0 0.001738917)
		(flower -1.999985882d0 0d0)
		(home 0d0 0d0)
		(seahorse -0.743517833d0 0.127094578d0)
		(sun -0.776592024d0 0.136640779d0)
		(tendrils -0.226266648d0 -1.11617444d0)))

(defun init-travel (name &optional (speed 0.95d0))
	(let ((coords (assoc name *mandel-travel-map*)))
		(when coords
			(init-coords (cadr coords) (caddr coords) speed))))

	

(defun cls ()
	(format t "~c[2J" (code-char 27)))
(defun home ()
	(format t "~c[H" (code-char 27)))


;; Optimzed c0de
;; complex numbers are just cons of double float, all declared

(defun m4nde1-1t3r (z  &optional (max_iter *iterations*))
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
			(values (complex c ci)
							i))))

;;Benchmarking
;(time (dotimes (i 1000000) (m4nde1-1t3r #c(0.5d0 -0.3d0)))) ;0.4s :)
;(time (dotimes (i 1000000) (mandel-iter #c(0.5d0 -0.3d0)))) ;10s   



;;; INteractive Mode
(defun read-cmd ()
	(let ((c (read-char-no-hang))) ;; Unfortunately we have to press enter after any cmd, because of terminal buf. Maybe go to ncurses soon
		(when c
			(cond
				((equal #\a c) (move -0.1 0))
				((equal #\w c) (move 0 -0.1))
				((equal #\d c) (move 0.1 0))
				((equal #\s c) (move 0 0.1))
				((equal #\x c) (reset-move))
				((equal #\q c) (quit))))))
						
