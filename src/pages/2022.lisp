(in-package #:pages)

(def-edition-page page-2022
  (use "edition_2022.txt")
  (title "2022")
  (layout
    (podium)
    (header "Leaderboard")
    (leaderboard)
    (header "Détails des jeux")
    (game-group-details "Individuels")
    (game-group-details "Tournoi Versus")
    (game-group-details "Équipes")
    (game-group-details "Quiz Pompe")
    (game-group-details "Blind & Run")))


