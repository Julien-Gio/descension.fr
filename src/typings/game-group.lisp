(in-package #:edition)

(defstruct GAME-GROUP
  (format "standard") ; can be one of [standard, tournament]
  (name "")
  (tags NIL)
  (description ""))

(defstruct GAME
  (name "")
  (parent-group NIL)
  (tags NIL)
  (points-identifier NIL)
  (points NIL)
  (results NIL))

(defstruct TOURNAMENT
  (parent-group NIL)
  (points NIL)
  (winners-brackets NIL)
  (losers-brackets NIL)
  (final-bracket NIL))

(defstruct TOURNAMENT-BRACKET
  (name "")
  (participants NIL)
  (winner NIL)
  (loser NIL))


(defun games-in-group (all-games game-group-name)
  (remove-if-not (lambda (g) (equal game-group-name (game-parent-group g))) all-games))

(defun participant-points-for-games (games participant-name)
  (to-int-if-possible (loop for game in games
                              sum (participant-points-for-game game participant-name))))

(defun participant-points-for-game (game participant-name)
  (let* ((points (game-points game))
         (ranking (position-if #'(lambda (ref) (equal participant-name (participant-ref-name ref))) (game-results game))))
    (to-int-if-possible (cond
                         ((null ranking) 0)
                         ((numberp points) points)
                         ((listp points) (or (nth ranking points) 0))
                         (T (error "unhandled points format in game ~a" (game-name game)))))))

(defun to-int-if-possible (x)
  (if (= x (truncate x)) (truncate x) x))

(defun find-tournament-by-group-name (name edition)
  (loop for tournament in (edition-tournaments edition)
          when (equal name (tournament-parent-group tournament))
          return tournament))