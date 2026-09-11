(in-package #:pages)


(def-edition-page page-2025
  (use "edition_2025.txt")
  (title "2025")
  (layout
    (podium)
    (header "Leaderboard")
    (leaderboard)
    (header "Détails des jeux")
    (game-group-details "FFA")
    (game-group-details "Équipes")
    (game-group-details "Le Bocal")
    (game-group-details "Quiz Pompe")
    (header "Tournoi")
    (tournament "Tournoi")))


