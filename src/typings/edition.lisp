(in-package #:edition)

(defstruct EDITION
  (name "")
  (dates NIL)
  (standing NIL)
  (awards NIL)
  (description "")
  (game-groups NIL)
  (games NIL))


(defstruct GAME
  (name "")
  (description "")
  (group NIL)
  (tags NIL)
  (points NIL)
  (results NIL))

(defstruct PARTICIPANT-REF
 (name ""))