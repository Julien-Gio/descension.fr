(in-package #:pages)


(def-edition-page page-2025
  (use "testData.txt")
  (title "2025")
  (layout
    (header "Podium")
    (podium)
    (header "Leaderboard")
    (leaderboard)
    (game-group-details "FFA")
    (game-group-details "Équipes")
    (game-group-details "Le Bocal")
    (game-group-details "Quiz Pompe")
    (header "End of page")))


