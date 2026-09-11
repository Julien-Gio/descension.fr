(in-package #:edition)

(defstruct EDITION
  (name "")
  (dates NIL)
  (standing NIL)
  (awards NIL)
  (description "")
  (game-groups NIL)
  (games NIL)
  (tournaments NIL))

(defstruct PARTICIPANT-REF
  (name ""))

(defun participant-ref-equal-p (a b)
  (string= (participant-ref-name a) (participant-ref-name b)))