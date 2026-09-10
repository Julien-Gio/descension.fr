(in-package #:utils)

;;; Simialar to push, but adds the element to the end of the list.
(defmacro push-end (val place)
  `(setf ,place (append ,place (list ,val))))

