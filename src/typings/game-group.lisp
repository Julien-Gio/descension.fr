(in-package #:edition)

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

(defun games-in-group (all-games game-group-name)
  (remove-if-not (lambda (g) (equal game-group-name (game-parent-group g))) all-games))

(defun participant-points-for-games (games participant-name)
  (loop for game in games
          sum (participant-points-for-game game participant-name)))


(defun participant-points-for-game (game participant-name)
  (let* ((points (game-points game))
         (ranking (position-if #'(lambda (ref) (equal participant-name (participant-ref-name ref))) (game-results game))))
    (cond
     ((null ranking) 0)
     ((numberp points) points)
     ((listp points) (or (nth ranking points) 0))
     (T (error "unhandled points format in game ~a" (game-name game))))))
