(in-package #:pages)


(def-edition-page page-2024
  (use "edition_2024.txt")
  (title "2024")
  (layout
    (podium)
    (header "Leaderboard")
    (leaderboard)
    (header "Détails des jeux")
    (game-group-details "FFA")
    (game-group-details "Équipes")
    (game-group-details "Spécial")
    (header "Tournoi")
    (tournament "Tournoi")))


