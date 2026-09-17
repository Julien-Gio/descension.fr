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
  (let ((scores (loop for p in (edition-participants edition)
                      for score = (participant-points-in-edition edition p)
                      collect (list p score))))
    (sort scores #'> :key #'second)
    ; Assign positions to each ranking, and handle ties.
    (loop with previous = nil
          for score in scores
          for i = 1 then (+ i 1)
          for position = (if (and (second previous) (= (second score) (second previous)))
                             (third previous)
                             i)
          for result = (append score (list position))
          collect result
          do (setf previous result))))
