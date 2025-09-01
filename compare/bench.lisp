
;; seperated core iter for language comparison
(defparameter *iterations* 300)

(declaim (type fixnum *iterations*)
				 (optimize (speed 3) (safety 0)))

(declaim (ftype (function (double-float double-float &optional fixnum) ;input
													(values double-float double-float fixnum)) ;output
								m4nde1-1t3r))
(declaim (inline m4nde1-1t3r)) ;;could yield 10% gain and get rid of return coercing

(defun m4nde1-1t3r (x y  &optional (max_iter *iterations*))
	(declare (optimize (speed 3) (space 0) (safety 0)))  ;; benchmark no difference to (speed 3) (safety 0)
	(declare (type double-float x y)
					 (type fixnum max_iter))
	(let ((c 0.0d0)
				(ci 0.0d0)
				(c2 0.0d0) ;;sq for optmzn
				(ci2 0.0d0)
				(i 0))
		(declare (type double-float c ci c2 ci2)
						 (type fixnum i))
		(loop while (and (< (+ c2 ci2) 4) (< i max_iter)) do
						 (setf ci (+ (* 2 c ci) y))
						 (setf c (+ (- c2 ci2) x))
						 (setf c2 (* c c))
						 (setf ci2 (* ci ci))
						 (incf i))
		(values c ci i)))

(defun benchmark (&optional (n 1000000)) ; 1 Million
	(declare (type fixnum n))
	(time (dotimes (i n)
					(m4nde1-1t3r 0.1d0 -0.5d0 5000))))


;;(time (benchmark))
