(defpackage #:utils
  (:use #:cl)
  (:export #:push-end))

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
           #:edition-standing
           #:edition-awards
           #:edition-description
           #:edition-game-groups
           #:edition-games
           #:edition-tournaments
           #:PARTICIPANT-REF
           #:make-participant-ref
           #:participant-ref-name
           #:GAME-GROUP
           #:make-game-group
           #:game-group-name
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
           #:TOURNAMENT-BRACKET
           #:make-tournament-bracket
           #:tournament-bracket-name
           #:tournament-bracket-participants
           #:tournament-bracket-winner
           #:tournament-bracket-loser))

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
  (:export #:copy-assets-to-build-output
           #:header
           #:podium
           #:leaderboard
           #:trophies
           #:game-group-details
           #:add-page
           #:def-edition-page))

(defpackage #:pages
  (:use #:cl #:utils #:html)
  (:export #:page-2025))

(defpackage #:descension-ssg
  (:use #:cl)
  (:export #:main))

(in-package #:descension-ssg)