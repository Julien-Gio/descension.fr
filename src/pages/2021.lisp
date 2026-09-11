(in-package #:pages)

(def-edition-page page-2021
  (use "edition_2021.txt")
  (title "2021")
  (layout
    (podium)
    (header "Leaderboard")
    (leaderboard)
    (header "Détails des jeux")
    (game-group-details "FFA")
    (game-group-details "Tournoi (round robin)")
    (game-group-details "Quiz Pompe")
    (game-group-details "Blind & Run")))


