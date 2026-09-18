(in-package #:html)

;; A few magic numbers for the CSS to work correctly based on the size of the tournament.
(defun get-tournament-wb-css-row-gaps-top (tournament)
  (nthcdr (- 4 (length (tournament-winners-brackets tournament))) '(1 1 4 10)))

(defun get-tournament-lb-css-row-gaps-top (tournament)
  (nthcdr (- 5 (length (tournament-losers-brackets tournament))) '(1 1 1 4 4)))

(defun get-tournament-wb-css-z-row-heights (tournament)
  (nthcdr (- 4 (length (tournament-winners-brackets tournament))) '(0 2 5 0)))

(defun get-tournament-lb-css-z-row-heights (tournament)
  (nthcdr (- 5 (length (tournament-losers-brackets tournament))) '(0 2 2 0 0)))

(defun get-tournament-wb-css-row-gaps-in-between (tournament)
  (nthcdr (- 4 (length (tournament-winners-brackets tournament))) '(0 2 8 0)))

(defun get-tournament-lb-css-row-gaps-in-between (tournament)
  (nthcdr (- 5 (length (tournament-losers-brackets tournament))) '(0 2 2 2 0)))

(defmacro tournament (group-name)
  `(let* ((tournament (find-tournament-by-group-name ,group-name edition))
          (wb (tournament-winners-brackets tournament))
          (wb-rounds (length wb))
          (wb-most-brackets (loop for round in wb maximize (length round)))
          (wb-css-rows (+ 1 (* wb-most-brackets 6)))
          (lb (tournament-losers-brackets tournament))
          (lb-rounds (length lb))
          (lb-most-brackets (loop for round in lb maximize (length round)))
          (lb-css-rows (+ 1 (* lb-most-brackets 6))))
     (list
      (list :h3 '(:attrs :class "tournament-section-header") "Tableau des gagnants")
      (list :div (list :attrs :class "bracket-grid wb"
                       :style (concatenate 'string "grid-template-rows:repeat(" (format nil "~D" wb-css-rows) ",1fr);grid-template-columns: 0 minmax(11em,11em)" (write-repeated-string (- wb-rounds 1) " 3em minmax(11em,11em)")))
            (loop for round in wb
                  for css-row-gap-top in (get-tournament-wb-css-row-gaps-top tournament)
                  for css-row-gaps-in-between in (get-tournament-wb-css-row-gaps-in-between tournament)
                  for css-z-row-height in (get-tournament-wb-css-z-row-heights tournament)
                  for i from 1
                  for css-round = (format nil "round~D" i)
                  collect (list
                           ; header
                           (list :div (list :attrs :class (format nil "bracket-grid-header ~a" css-round))
                                 (list :div (list :attrs :class (format nil "bracket-header-content")) (tournament-bracket-name (first round))))
                           (list :div (list :attrs :class (format nil "bracket-spacer ~a" css-round) :style (format nil "grid-row:span ~a" css-row-gap-top)))
                           ; brackets
                           (loop for bracket in round
                                 for p1 = (first (tournament-bracket-participants bracket))
                                 for p2 = (second (tournament-bracket-participants bracket))
                                 for isP1Winner = (equal p1 (tournament-bracket-winner bracket))
                                 for isP2Winner = (equal p2 (tournament-bracket-winner bracket))
                                 collect (list
                                          (list :div (list :attrs :class (format nil "bracket top ~a ~a" css-round (if isP1Winner "bracket-winner" "")))
                                                (list :div '(:attrs :class "bracket-name") (participant-ref-name p1))
                                                (list :div '(:attrs :class "bracket-points") (if isP1Winner "W" "élim.")))
                                          (list :div (list :attrs :class (format nil "bracket bottom ~a ~a" css-round (if isP2Winner "bracket-winner" "")))
                                                (list :div '(:attrs :class "bracket-name") (participant-ref-name p2))
                                                (list :div '(:attrs :class "bracket-points") (if isP2Winner "W" "élim.")))
                                          (list :div (list :attrs :class (format nil "bracket-spacer ~a" css-round) :style (format nil "grid-row:span ~a" css-row-gaps-in-between)))))
                           ; connetors
                           (unless (= i wb-rounds)
                             (loop for bracket in round
                                   for j from 1
                                     when (oddp j)
                                   collect (list
                                            (list :div (list :attrs :class (format nil "bracket-line ~a" css-round) :style (format nil "grid-row:span ~a" (+ 4 css-row-gap-top))))
                                            (list :div (list :attrs :class (format nil "bracket-line z-down ~a" css-round) :style (format nil "grid-row:span ~a" css-z-row-height))))
                                     when (evenp j)
                                   collect (list
                                            (list :div (list :attrs :class (format nil "bracket-line ~a" css-round) :style "grid-row:span 2"))
                                            (list :div (list :attrs :class (format nil "bracket-line z-up ~a" css-round) :style (format nil "grid-row:span ~a" css-z-row-height)))
                                            (list :div (list :attrs :class (format nil "bracket-line ~a" css-round)))))))))
      (list :h3 '(:attrs :class "tournament-section-header") "Tableau des perdants")
      (list :div (list :attrs :class "bracket-grid lb"
                       :style (concatenate 'string "grid-template-rows:repeat(" (format nil "~D" lb-css-rows) ",1fr);grid-template-columns: 0 minmax(11em,11em)" (write-repeated-string (- lb-rounds 1) " 3em minmax(11em,11em)")))
            (loop for round in lb
                  for css-row-gap-top in (get-tournament-lb-css-row-gaps-top tournament)
                  for css-row-gaps-in-between in (get-tournament-lb-css-row-gaps-in-between tournament)
                  for css-z-row-height in (get-tournament-lb-css-z-row-heights tournament)
                  for i from 1
                  for css-round = (format nil "round~D" i)
                  collect (list
                           ; header
                           (list :div (list :attrs :class (format nil "bracket-grid-header ~a" css-round))
                                 (list :div (list :attrs :class (format nil "bracket-header-content")) (tournament-bracket-name (first round))))
                           (list :div (list :attrs :class (format nil "bracket-spacer ~a" css-round) :style (format nil "grid-row:span ~a" css-row-gap-top)))
                           ; brackets
                           (loop for bracket in round
                                 for p1 = (first (tournament-bracket-participants bracket))
                                 for p2 = (second (tournament-bracket-participants bracket))
                                 for isP1Winner = (equal p1 (tournament-bracket-winner bracket))
                                 for isP2Winner = (equal p2 (tournament-bracket-winner bracket))
                                 collect (list
                                          (list :div (list :attrs :class (format nil "bracket top ~a ~a" css-round (if isP1Winner "bracket-winner" "")))
                                                (list :div '(:attrs :class "bracket-name") (participant-ref-name p1))
                                                (list :div '(:attrs :class "bracket-points")
                                                      (if isP1Winner
                                                          "W"
                                                          (format nil "+~a pts" (participant-points-for-tournament tournament p1)))))
                                          (list :div (list :attrs :class (format nil "bracket bottom ~a ~a" css-round (if isP2Winner "bracket-winner" "")))
                                                (list :div '(:attrs :class "bracket-name") (participant-ref-name p2))
                                                (list :div '(:attrs :class "bracket-points")
                                                      (if isP2Winner
                                                          "W"
                                                          (format nil "+~a pts" (participant-points-for-tournament tournament p2)))))
                                          (list :div (list :attrs :class (format nil "bracket-spacer ~a" css-round) :style (format nil "grid-row:span ~a" css-row-gaps-in-between)))))
                           ; connetors
                           (unless (= i lb-rounds)
                             (loop for bracket in round
                                   for j from 1
                                     when (oddp j)
                                   collect (list
                                            (list :div (list :attrs :class (format nil "bracket-line ~a" css-round) :style (format nil "grid-row:span ~a" (+ 4 css-row-gap-top))))
                                            (list :div (list :attrs :class (format nil "bracket-line z-down ~a" css-round) :style (format nil "grid-row:span ~a" css-z-row-height))))
                                     when (evenp j)
                                   collect (list
                                            (list :div (list :attrs :class (format nil "bracket-line ~a" css-round) :style "grid-row:span 2"))
                                            (list :div (list :attrs :class (format nil "bracket-line z-up ~a" css-round) :style (format nil "grid-row:span ~a" css-z-row-height)))
                                            (list :div (list :attrs :class (format nil "bracket-line ~a" css-round)))))))))
      (list :h3 '(:attrs :class "tournament-section-header") "Grande Finale")
      (let* ((final-bracket (tournament-final-bracket tournament))
             (p1 (first (tournament-bracket-participants final-bracket)))
             (p2 (second (tournament-bracket-participants final-bracket)))
             (isP1Winner (equal p1 (tournament-bracket-winner final-bracket)))
             (isP2Winner (equal p2 (tournament-bracket-winner final-bracket))))
        (list :div (list :attrs :class "bracket-grid gf gf-grid" :style "grid-template-rows:repeat(4,1fr);grid-template-columns:0 minmax(14em,14em)")
              (list :div (list :attrs :class (format nil "bracket top round1 ~a" (if isP1Winner "bracket-winner" "")))
                    (list :div '(:attrs :class "bracket-name") (participant-ref-name p1))
                    (list :div '(:attrs :class "bracket-points")
                          (format nil "+~a pts" (participant-points-for-tournament tournament p1))))
              (list :div (list :attrs :class (format nil "bracket bottom round1 ~a" (if isP2Winner "bracket-winner" "")))
                    (list :div '(:attrs :class "bracket-name") (participant-ref-name p2))
                    (list :div '(:attrs :class "bracket-points")
                          (format nil "+~a pts" (participant-points-for-tournament tournament p2)))))))))
