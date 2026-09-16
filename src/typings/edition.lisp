(in-package #:edition)

(defstruct EDITION
  (name "")
  (dates NIL)
  (participants NIL)
  (awards NIL)
  (description "")
  (game-groups NIL)
  (games NIL)
  (tournaments NIL))

(defstruct PARTICIPANT-REF
  (name ""))

(defun participant-ref-equal-p (a b)
  (string= (participant-ref-name a) (participant-ref-name b)))

(defun get-edition-standing (edition)
  (let ((scores (loop with previous = nil
                      for p in (edition-participants edition)
                      for i = 1 then (+ i 1)
                      for score = (participant-points-in-edition edition p)
                      for position = (if (and (second previous) (= score (second previous)))
                                         (third previous)
                                         i)
                      collect (list p score position)
                      do (setf previous (list p score i)))))
    (sort scores #'= :key #'second)
    scores))
