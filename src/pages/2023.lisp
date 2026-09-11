(in-package #:pages)

(def-edition-page page-2023
  (use "edition_2023.txt")
  (title "2023")
  (layout
    (podium)
    (header "Leaderboard")
    (leaderboard)
    (header "Détails des jeux")
    (game-group-details "FFA")
    (game-group-details "Tournoi Versus")
    (game-group-details "Équipes")))


