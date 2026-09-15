(in-package #:pages)


(def-edition-page page-2026
  (use "edition_2026.txt")
  (title "2026")
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


