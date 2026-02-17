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
           #:game-description
           #:game-parent-group
           #:game-tags
           #:game-points
           #:game-results))

(defpackage #:parser
  (:use #:cl #:token #:edition)
  (:export #:parse))

(defpackage #:lexer
  (:use #:cl #:token)
  (:export #:lex
           #:print-tokens))

(defpackage #:descension-ssg
  (:use #:cl)
  (:export #:main))

(in-package #:descension-ssg)