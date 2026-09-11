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

(defun tournament-in-group (all-tournaments game-group-name)
  (first (remove-if-not
             (lambda (g) (equal game-group-name (tournament-parent-group g)))
             all-tournaments)))

(defun participant-points-for-tournaments (tournaments participant)
  (loop for tournament in tournaments
          sum (participant-points-for-tournament tournament participant)))

(defun participant-points-for-tournament (tournament participant)
  (to-int-if-possible
   (let* ((gf (tournament-final-bracket tournament))
          (wb (tournament-winners-brackets tournament))
          (lb (tournament-losers-brackets tournament))
          (points (tournament-points tournament))
          (losing-bracket-index (position-if
                                    (lambda (brackets)
                                      (find
                                          participant
                                          brackets
                                        :test #'participant-ref-equal-p
                                        :key #'tournament-bracket-loser))
                                    lb)))
     (cond
      ((participant-ref-equal-p participant (tournament-bracket-winner gf))
        (first points))
      ((participant-ref-equal-p participant (tournament-bracket-loser gf))
        (second points))
      ((numberp losing-bracket-index)
        ; The round where the participant lost the second time determines the points
        (nth (- (length lb) losing-bracket-index -1) points))
      ; In case a participant did not take part in the tournament.
      (T 0)))))

(defun to-int-if-possible (x)
  (if (= x (truncate x)) (truncate x) x))

(defun find-tournament-by-group-name (name edition)
  (loop for tournament in (edition-tournaments edition)
          when (equal name (tournament-parent-group tournament))
          return tournament))