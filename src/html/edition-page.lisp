(in-package #:html)

(defmacro def-edition-page (name &body body)
  (let* ((title-form (get-directive body 'title))
         (title (second title-form))
         (layout-form (get-directive body 'layout))
         (layout-items (rest layout-form))
         (use-form (get-directive body 'use))
         (edition-filename (second use-form)))
    `(defun ,name ()
       (let ((edition (interpreter:load-content ,edition-filename)))
         (render-html (list :html (list :head (list :title ,title)
                                        (list :link '(:attrs :href "../../assets/main.css" :rel "stylesheet"))
                                        (list :link '(:attrs :href "../../assets/edition.css" :rel "stylesheet")))
                            (list :body (list :h1 (list :a '(:attrs :href "/") "Descension - Edition " (edition-name edition)))
                                  ,@layout-items)))))))

(defmacro header (content)
  `(list :h2 ,content))

(defmacro podium ()
  `(list :div '(:attrs :class "podium")
         (list :div '(:attrs :class "podium-top-3")
               (list :div '(:attrs :class "silver")
                     (participant-ref-name (second (edition-standing edition)))
                     (list :div '(:attrs :class "podium-step")))
               (list :div '(:attrs :class "gold")
                     (participant-ref-name (first (edition-standing edition)))
                     (list :div '(:attrs :class "podium-step")))
               (list :div '(:attrs :class "bronze")
                     (participant-ref-name (third (edition-standing edition)))
                     (list :div '(:attrs :class "podium-step"))))
         (append (list :div '(:attrs :class "rest-of-standings"))
           (loop for p in (cdddr (edition-standing edition))
                 for i from 4
                 collect (list :p (list :attrs :data-position (format nil "~d" i))
                               (participant-ref-name p))))))

(defmacro leaderboard ()
  `(list :div '(:attrs :class "leaderboard")
         (let* ((game-groups (loop for gg in (edition-game-groups edition) collect (game-group-name gg)))
                (participant-points (loop for p in (edition-standing edition)
                                          for i from 1
                                          for p-name = (participant-ref-name p)
                                          collect (append (list i p-name (participant-points-for-games (edition-games edition) p-name))
                                                    (loop for gg in (edition-game-groups edition)
                                                          for group-games = (games-in-group (edition-games edition) (game-group-name gg))
                                                          collect (participant-points-for-games group-games p-name))))))
           (html-table (append '(nil nil nil) game-groups) participant-points))))

(defmacro trophies ()
  `(list :p "TROPHIES TODO"))

(defmacro game-group-details (group-name)
  `(list :div '(:attrs :class "game-group-details")
         (let* ((participant-names (loop for p in (edition-standing edition) collect (participant-ref-name p)))
                (all-games (edition-games edition))
                (group-games (remove-if-not (lambda (g) (equal ,group-name (game-parent-group g))) all-games))
                (points-per-game (loop for g in group-games
                                       collect (append (list (game-name g))
                                                 (loop for p in (edition-standing edition)
                                                       collect (participant-points-for-game g (participant-ref-name p)))))))
           (html-table (append (list ,group-name) participant-names)
                       points-per-game))))

(defmacro tournament (group-name)
  `(let* ((tournament (find-tournament-by-group-name ,group-name edition))
          (wb (tournament-winners-brackets tournament))
          (wb-rounds (length wb))
          (wb-most-brackets (loop for round in wb maximize (length round)))
          (wb-css-rows (+ 1 (* wb-most-brackets 6)))
          (wb-css-row-gaps-top '(1 1 4 10)) ; TODO remove hard-coded gaps
          (wb-css-row-gaps-in-between '(0 2 8 0))
          (wb-css-z-row-heights '(0 2 5 0)) ; TODO remove hard-coded gaps
          (lb (tournament-losers-brackets tournament))
          (lb-rounds (length lb))
          (lb-most-brackets (loop for round in lb maximize (length round)))
          (lb-css-rows (+ 1 (* lb-most-brackets 6)))
          (lb-css-row-gaps-top '(1 1 1 4 4)) ; TODO remove hard-coded gaps
          (lb-css-row-gaps-in-between '(0 2 2 0 0))
          (lb-css-z-row-heights '(0 2 2 2 0))) ; TODO remove hard-coded gaps
     (list
      (list :h3 '(:attrs :class "tournament-section-header") "Tableau des gagnants")
      (list :div (list :attrs :class "bracket-grid wb"
                       :style (concatenate 'string "grid-template-rows:repeat(" (format nil "~D" wb-css-rows) ",1fr);grid-template-columns: 0 minmax(11em,11em)" (write-repeated-string (- wb-rounds 1) " 3em minmax(11em,11em)")))
            (loop for round in wb
                  for css-row-gap-top in wb-css-row-gaps-top
                  for css-row-gaps-in-between in wb-css-row-gaps-in-between
                  for css-z-row-height in wb-css-z-row-heights
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
                                                (list :div '(:attrs :class "bracket-points") 0))
                                          (list :div (list :attrs :class (format nil "bracket bottom ~a ~a" css-round (if isP2Winner "bracket-winner" "")))
                                                (list :div '(:attrs :class "bracket-name") (participant-ref-name p2))
                                                (list :div '(:attrs :class "bracket-points") 0))
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
                  for css-row-gap-top in lb-css-row-gaps-top
                  for css-row-gaps-in-between in lb-css-row-gaps-in-between
                  for css-z-row-height in lb-css-z-row-heights
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
                                                (list :div '(:attrs :class "bracket-points") 0))
                                          (list :div (list :attrs :class (format nil "bracket bottom ~a ~a" css-round (if isP2Winner "bracket-winner" "")))
                                                (list :div '(:attrs :class "bracket-name") (participant-ref-name p2))
                                                (list :div '(:attrs :class "bracket-points") 0))
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
        (list :div (list :attrs :class "bracket-grid gf gf-grid" :style "grid-template-rows:repeat(4,1fr);grid-template-columns:0 minmax(11em,11em)")
              (list :div (list :attrs :class (format nil "bracket top round1 ~a" (if isP1Winner "bracket-winner" ""))) 
                (list :div '(:attrs :class "bracket-name") (participant-ref-name p1))
                (list :div '(:attrs :class "bracket-points") 0)
                )
              (list :div (list :attrs :class (format nil "bracket bottom round1 ~a" (if isP2Winner "bracket-winner" ""))) 
              (list :div '(:attrs :class "bracket-name") (participant-ref-name p2))
                (list :div '(:attrs :class "bracket-points") 0)
              ))))))

(defun html-table (header-cells data-rows)
  (list :table
        (append (list :tr) (loop for h in header-cells collect (list :th h)))
        (loop for row in data-rows
              collect (append (list :tr)
                        (loop for data-cell in row
                              collect (list :td data-cell))))))

; =================  Helper functions  =================

(defun get-directive (directives directive-symbol-name)
  (assoc directive-symbol-name directives
         :key #'symbol-name
         :test #'string=))
