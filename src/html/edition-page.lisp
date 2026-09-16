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
  `(let* ((standing (get-edition-standing edition))
          (p1 (first standing))
          (p2 (second standing))
          (p3 (third standing))
          (others (cdddr standing)))
     (list :div '(:attrs :class "podium")
           (list :div '(:attrs :class "podium-top-3")
                 (list :div '(:attrs :class "silver")
                       (participant-ref-name (first p2))
                       (list :div '(:attrs :class "podium-step")))
                 (list :div '(:attrs :class "gold")
                       (participant-ref-name (first p1))
                       (list :div '(:attrs :class "podium-step")))
                 (list :div '(:attrs :class "bronze")
                       (participant-ref-name (first p3))
                       (list :div '(:attrs :class "podium-step"))))
           (append (list :div '(:attrs :class "rest-of-standings"))
             (loop for ranking in others
                   collect (list :p (list :attrs :data-position (format nil "~d" (third ranking)))
                                 (participant-ref-name (first ranking))))))))

(defmacro leaderboard ()
  `(list :div '(:attrs :class "leaderboard")
         (let* ((game-groups (loop for gg in (edition-game-groups edition) collect (game-group-name gg)))
                (participant-points (loop for ranking in (get-edition-standing edition)
                                          for p = (first ranking)
                                          for position = (third ranking)
                                          collect (append
                                                    (list position
                                                          (participant-ref-name p)
                                                          (participant-points-in-edition edition p))
                                                    (loop for gg in (edition-game-groups edition)
                                                          for group-games = (games-in-group (edition-games edition) (game-group-name gg))
                                                          for group-tournament = (tournament-in-group (edition-tournaments edition) (game-group-name gg))
                                                            when (string= (game-group-format gg) "standard")
                                                          collect (participant-points-for-games group-games p)
                                                            when (string= (game-group-format gg) "tournament")
                                                          collect (participant-points-for-tournament group-tournament p))))))
           (html-table (append '(nil nil "Total") game-groups) participant-points))))

(defmacro trophies ()
  `(list :p "TROPHIES TODO"))

(defmacro game-group-details (group-name)
  `(list :div '(:attrs :class "game-group-details")
         (let* ((participant-names (loop for ranking in (get-edition-standing edition)
                                         for p = (first ranking)
                                         collect (participant-ref-name p)))
                (all-games (edition-games edition))
                (group-games (remove-if-not (lambda (g) (equal ,group-name (game-parent-group g))) all-games))
                (points-per-game (loop for g in group-games
                                       collect (append (list (game-name g))
                                                 (mapcar
                                                     #'(lambda (x) (format nil "~@D" x))
                                                   (loop for ranking in (get-edition-standing edition)
                                                         for p = (first ranking)
                                                         collect (participant-points-for-game g p)))))))
           (html-table (append (list ,group-name) participant-names)
                       points-per-game))))

(defun html-table (header-cells data-rows)
  (list :table
        (append (list :tr) (loop for h in header-cells collect (list :th h)))
        (loop for row in data-rows
              collect (append (list :tr)
                        (loop for data-cell in row
                              for isZero = (zero-value-p data-cell)
                              collect (list :td (list :attrs :class (if isZero "zero" "")) data-cell))))))

; =================  Helper functions  =================

(defun get-directive (directives directive-symbol-name)
  (assoc directive-symbol-name directives
         :key #'symbol-name
         :test #'string=))
