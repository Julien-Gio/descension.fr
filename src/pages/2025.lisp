(in-package #:pages)


(def-edition-page page-2025
  (use "testData.txt")
  (title "2025")
  (layout
    (header "Podium")
    (podium)
    (header "Leaderboard")
    (leaderboard)
    (game-group-details "FFA (4 joueurs)")
    (game-group-details "Équipes")
    (header "End of page")))


