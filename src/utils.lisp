(in-package #:utils)

;;; Simialar to push, but adds the element to the end of the list.
(defmacro push-end (val place)
  `(setf ,place (append ,place (list ,val))))

(defun write-repeated-string (n string)
  (with-output-to-string (s)
    (loop repeat n do (format s "~a" string))))