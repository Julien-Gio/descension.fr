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
  (:use #:cl #:edition)
  (:export #:parse))

(defpackage #:lexer
  (:use #:cl)
  (:export #:lex
           #:print-tokens))

(defpackage #:descension-ssg
  (:use #:cl)
  (:export #:main))

(in-package #:descension-ssg)