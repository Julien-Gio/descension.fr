(in-package #:edition)

(defstruct EDITION
  (name "")
  (dates NIL)
  (standing NIL)
  (awards NIL)
  (description "")
  (game-groups NIL)
  (games NIL))

(defstruct GAME-GROUP
  (name "")
  (tags nil)
  (description ""))

(defstruct GAME
  (name "")
  (parent-group NIL)
  (tags NIL)
  (points-identifier NIL)
  (points NIL)
  (results NIL))

(defstruct PARTICIPANT-REF
 (name ""))

 