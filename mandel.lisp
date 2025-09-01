;;Zn+1 = Zn² + C
(declaim (optimize speed))
(defparameter *viewport*
	'((-2.0d0 . 1.2d0)  (1d0 . -1.2d0)))

(defparameter *threshold* (the fixnum 3))

(defparameter *iterations* 300)

(defparameter *pxs* 1110)

(defparameter *interactive-p* t) ;; Interactive Mode: move with w,a,s,d , accelerate/decelerte with k,l

(defparameter *delay* 0)

(declaim (type fixnum *iterations* *threshold* *pxs* *delay*))

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
		(tendrils -0.226266648d0 -1.11617444d0)
		(interesting -0.226266563d0 -1.116174286d0 )))


;;Unoptimized & naive
(defun mandel (c z)
	(the complex (+ (* z z)
									c)))

(defun mandel-iter (c &optional (n *iterations*) (z #c(0s0 0s0)))
	"iterates c n-times with mandel, unoptimized and slow"
	(let ((i 0))
		(loop while (and (< i n)
										 (< (abs z) *threshold*)) ;FIXME
					do
						 (setf z (mandel c z))
						 (incf i))
		z))

(defun in-mandelset-p (c &key (iterations *iterations*) (threshold *threshold*))
	(>= (abs (mandel-iter c iterations))
			threshold))


;; -----------
;;  Viewport and axis mapping
;;

(defun viewport-size (&optional (viewport *viewport*))
	(let* ((v1 (car viewport))
				 (v2 (cadr viewport))
				 (vw (- (car v2) (car v1)))
				 (vh (- (cdr v2) (cdr v1))))
		(cons vw vh)))
	



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
		(defun current-w ()
			w)
		(defun reset-move ()
			(setf dr 0d0)
			(setf di 0d0))))


(defun coords->c (x y w h )
	"Hilfsfkt: koords in viewport c umrechnen"
	(let* ((vs (viewport-size))
				 (xn (/ (car vs) w))
				 (yn (/ (cdr vs) h)))
	(complex (+ (* xn x) (caar *viewport*))
					 (+ (* yn y) (cdar *viewport*)))))

(defun init-travel (name &optional (speed 0.95d0))
	(let ((coords (assoc name *mandel-travel-map*)))
		(when coords
			(init-coords (cadr coords) (caddr coords) speed))))


;; ,,Coloring''

(defun z->ascii (z &optional (threshold *threshold*))
	"Asci<<farbe>> bauen"
	(if (>= z threshold)
			" "
			(let* ((mina #\.)
						 (maxa #\z)
						 (w (- (char-code maxa) (char-code mina))))
				(if (> z 1)
						maxa
						(code-char (round (+ (char-code mina) (* z w) )))))))

(defun z->ascii2 (z i &optional (iterations *iterations*))
	"Asci<<farbe>> bauen (2. methode: nach iter"
	(declare (type fixnum i iterations)
					 (type (complex double-float) z))
	(if (>= i iterations)
			" "
			(let* ((mina #\.)
						 (maxa #\z)
						 (w (- (char-code maxa) (char-code mina))))
				(if maxa
						(code-char (round (+ (char-code mina) (* (/ i *iterations*) w))))))))



;; The ascii-rendering

(defun asciipaint (w h)
	(setf *pxs* 0)
	(loop for y from 0 to (1- h) do
		(loop for x from 0 to (1- w) do
			(multiple-value-bind (z i) (m4nde1-1t3r (coords->c x y w h))
				(if (< i *iterations*) (incf *pxs*)) ;; just for exiting
				(princ 	(z->ascii2 z i))))
		(princ #\Newline))
	(home))






	

(defun cls ()
	(format t "~c[2J" (code-char 27)))
(defun home ()
	(format t "~c[H" (code-char 27)))


;; _________________________________________________________________
;;
;; Optimzed c0de
;; complex numbers are just cons of double float, all declared
(declaim (ftype (function ((complex double-float) &optional fixnum) ;input
													(values (complex double-float) fixnum)) ;output
								m4nde1-1t3r))
(declaim (inline m4nde1-1t3r)) ;;could yield 10% gain

(defun m4nde1-1t3r (z  &optional (max_iter *iterations*))
	(declare (optimize speed (space 0)))  ;; benchmark no difference to (speed 3) (safety 0)
	(declare (type (complex double-float) z))
	(let ((x (realpart z))
				(y (imagpart z)))
		(declare (type double-float x y)
						 (type fixnum max_iter))
		(let ((c 0.0d0)
					(ci 0.0d0)
					(c2 0.0d0) ;;sq for optmzn
					(ci2 0.0d0)
					(i 0))
			(declare (type double-float c ci c2 ci2)
							 (type fixnum i))
			(loop while (and (< (+ c2 ci2) 4) (< i max_iter))
						do
							 (setf ci (+ (* 2 c ci) y))
							 (setf c (+ (- c2 ci2) x))
							 (setf c2 (* c c))
							 (setf ci2 (* ci ci))
							 (incf i))
			(the (values (complex double-float) fixnum)  ;; a bit confusing: first values is the typedecl from 'the'!
					 (values (complex c ci)
							i)))))

;;Benchmarking
;(time (dotimes (i 1000000) (m4nde1-1t3r #c(0.5d0 -0.3d0)))) ;0.4s :)
;(time (dotimes (i 1000000) (mandel-iter #c(0.5d0 -0.3d0)))) ;10s   



;;; INteractive Mode
(defun read-cmd ()
	(let ((c (read-char-no-hang))) ;; FIXME: Unfortunately we have to press enter after any cmd, because of terminal buf. Maybe go to ncurses soon
		(when c
			(cond
				((equal #\a c) (move -0.1 0))
				((equal #\w c) (move 0 -0.1))
				((equal #\d c) (move 0.1 0))
				((equal #\s c) (move 0 0.1))
				((equal #\x c) (reset-move))
				((equal #\q c) (quit))))))



;; STats

;;; Lets also have some stats

(defparameter *frames* 0)
(defparameter *iters-done* 0)
(defparameter *start-time* (get-universal-time))
(declaim (type fixnum *frames* *iters-done* *start-time*))

(defun get-stats (&key (reset))
	(let ((stats (list :fps (/ *frames* (max 1 (- (get-universal-time)  *start-time*)))
										 :ips (/ *iters-done* (max 1 (- (get-universal-time)  *start-time*)))
										 :frames *frames*)))
		(when reset
			(setf *frames* 0)
			(setf *iters-done* 0)
			(setf *start-time* (get-universal-time)))
		stats))

(defun print-stats (stats)
	(format nil "~,2f fps, ~,'0:dk ips" (getf stats :fps) (round (/ (getf stats :ips) 1000))))
			
			
								 


;; Benchmark
;;10,710,515,593 processor cycles
;;  0 bytes consed (!)
;;;
;; Around ~7 cycles per iter. not so bad.

(defun benchmark (&optional (n 1000000)) ; 1 Million
	(declare (type fixnum n))
	(time (dotimes (i n)
					(m4nde1-1t3r #c(0.1d0 -0.5d0) 1500))))


;;(sb-sprof:with-profiling (:max-samples 1000 :report :flat :loop t :show-progress t) (BENCHMARK))
