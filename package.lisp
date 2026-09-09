(defpackage #:token
  (:use #:cl)
  (:export #:TOKEN
           #:make-token
           #:token-type
           #:token-lexeme
           #:token-literal
           #:token-line
           #:token-to-string
           #:token-type-p))

(defpackage #:edition
  (:use #:cl)
  (:export #:EDITION
           #:make-edition
           #:edition-name
           #:edition-dates
           #:edition-standing
           #:edition-awards
           #:edition-description
           #:edition-game-groups
           #:edition-games
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
           #:participant-points-for-game))

(defpackage #:parser
  (:use #:cl #:token #:edition)
  (:export #:parse))

(defpackage #:lexer
  (:use #:cl #:token)
  (:export #:lex
           #:print-tokens))

(defpackage #:interpreter
  (:use #:cl)
  (:export #:load-content))
           
(defpackage #:html
  (:use #:cl #:edition)
  (:export #:copy-assets-to-build-output
           #:header
           #:podium
           #:leaderboard
           #:trophies
           #:game-group-details
           #:add-page
           #:def-edition-page))

(defpackage #:pages
  (:use #:cl #:html)
  (:export #:page-2025))

(defpackage #:descension-ssg
  (:use #:cl)
  (:export #:main))

(in-package #:descension-ssg)