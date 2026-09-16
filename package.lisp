(defpackage #:utils
  (:use #:cl)
  (:export #:push-end
           #:write-repeated-string
           #:zero-value-p))

(defpackage #:token
  (:use #:cl #:utils)
  (:export #:TOKEN
           #:make-token
           #:token-type
           #:token-lexeme
           #:token-literal
           #:token-line
           #:token-to-string
           #:token-type-p))

(defpackage #:edition
  (:use #:cl #:utils)
  (:export #:EDITION
           #:make-edition
           #:edition-name
           #:edition-dates
           #:edition-participants
           #:edition-awards
           #:edition-description
           #:edition-game-groups
           #:edition-games
           #:edition-tournaments
           #:get-edition-standing
           #:participant-points-in-edition
           #:PARTICIPANT-REF
           #:make-participant-ref
           #:participant-ref-p
           #:participant-ref-name
           #:participant-ref-equal-p
           #:GAME-GROUP
           #:make-game-group
           #:game-group-name
           #:game-group-format
           #:game-group-description
           #:game-group-tags
           #:GAME
           #:make-game
           #:game-name
           #:game-parent-group
           #:game-tags
           #:game-points
           #:game-points-identifier
           #:game-results
           #:games-in-group
           #:participant-points-for-games
           #:participant-points-for-game
           #:TOURNAMENT
           #:make-tournament
           #:tournament-parent-group
           #:tournament-points
           #:tournament-winners-brackets
           #:tournament-losers-brackets
           #:tournament-final-bracket
           #:TOURNAMENT-BRACKET
           #:make-tournament-bracket
           #:tournament-bracket-name
           #:tournament-bracket-participants
           #:tournament-bracket-winner
           #:tournament-bracket-loser
           #:find-tournament-by-group-name
           #:tournament-in-group
           #:participant-points-for-tournaments
           #:participant-points-for-tournament))

(defpackage #:parser
  (:use #:cl #:utils #:token #:edition)
  (:export #:parse))

(defpackage #:lexer
  (:use #:cl #:utils #:token)
  (:export #:lex
           #:print-tokens))

(defpackage #:interpreter
  (:use #:cl #:utils)
  (:export #:load-content))
           
(defpackage #:html
  (:use #:cl #:utils #:edition)
  (:export #:render-html
           #:copy-assets-to-build-output
           #:header
           #:podium
           #:leaderboard
           #:trophies
           #:tournament
           #:game-group-details
           #:add-page
           #:def-edition-page))

(defpackage #:pages
  (:use #:cl #:utils #:html)
  (:export #:page-home
           #:page-2021
           #:page-2022
           #:page-2023
           #:page-2025
           #:page-2026))

(defpackage #:descension-ssg
  (:use #:cl)
  (:export #:main))

(in-package #:descension-ssg)
