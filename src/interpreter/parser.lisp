(in-package #:parser)

(defmacro push-end (place element)
  `(setf ,place (append ,place (list ,element))))

; ---

(defun parse (tokens) 
  (cond ((or (null tokens) (not (token-type-p (first tokens) :TYPE)))
           (error "~&Error, expected 'type' keyword at top of file."))
        ((token-type-p (second tokens) :EDITION)
           (parse-edition (rest (rest tokens))))
        (t 
           (error "~&Error, unhandled data type ~a" (second tokens)))))

; --- Parse EDITION
(defun parse-edition (tokens)
  (loop with edition = (make-edition)
        repeat 10000 ; avoid infinite loops
        while tokens
        do ; (format T "~&Parsing: ~a" (first tokens))
        (multiple-value-setq (tokens edition) (parse-edition-field tokens edition))
         
        finally (return edition)))

(defun parse-edition-field (tokens edition)
  (let ((token (first tokens)))
    (cond 
      ((token-type-p token :NAME)        (parse-name tokens edition))
      ((token-type-p token :DATES)       (parse-date tokens edition))
      ((token-type-p token :STANDING)    (parse-standing tokens edition))
      ((token-type-p token :DESCRIPTION) (parse-description tokens edition))
      ((token-type-p token :DEFINE)      (parse-define-block tokens edition))
      (T (error "unexpected token ~a" (token-to-string (first tokens)))))))

(defun parse-name (tokens edition)
  (multiple-value-bind (_ rest) (consume tokens :NAME)
    (multiple-value-bind (str-token rest2) (consume rest :STRING)
      (setf (edition-name edition) (token-literal str-token))
      (values rest2 edition))))
      
(defun parse-description (tokens edition)
  (multiple-value-bind (_ rest) (consume tokens :DESCRIPTION)
    (multiple-value-bind (str-token rest2) (consume rest :STRING)
      (setf (edition-description edition) (token-literal str-token))
      (values rest2 edition))))

(defun parse-date (tokens edition)
  (multiple-value-bind (_ rest) (consume tokens :DATES)
  (multiple-value-bind (_ rest2) (consume rest :FROM)
  (multiple-value-bind (start-date rest3) (consume rest2 :DATE)
  (multiple-value-bind (_ rest4) (consume rest3 :TO)
  (multiple-value-bind (end-date rest5) (consume rest4 :DATE)
    (setf (edition-dates edition) (concatenate 'string (token-literal start-date) ":" (token-literal end-date)))  ; TODO JUL implement date ranges 
    (values rest5 edition)))))))

(defun parse-standing (tokens edition)
  (multiple-value-bind (_ rest) (consume tokens :STANDING)
  (multiple-value-bind (rest2 participants) (consume-array rest #'parse-participant-ref)
    (setf (edition-standing edition) participants)
    (values rest2 edition participants))))

(defun parse-define-block (tokens edition)
  (multiple-value-bind (_ rest) (consume tokens :DEFINE)
  (multiple-value-bind (define-type rest2) (consume rest)
    (cond
     ; TODO ((token-type-p define-type :GAME) (parse-game rest2 edition))
     ((token-type-p define-type :GAME-GROUP) (parse-game-group rest2 edition))
     (T (error "unexpected token after define: ~a" (token-to-string define-type)))))))

(defun parse-game-group (tokens edition)
  (let ((game-group (make-game-group))
        (points (make-hash-table :test 'equal))
        (games nil))
    (multiple-value-bind (name-token rest) (consume tokens :STRING)
      (setf (game-group-name game-group) (token-literal name-token))
      (loop repeat 1000 ; avoid infinite loops
            while (not (token-type-p (first rest) :END))
            for token = (first rest)
            do ; (format T "~& Parsing GG (~a): ~a" (length rest) (first rest)) 
               (cond 
                 ((token-type-p token :TAG)         (multiple-value-setq (rest game-group)          (parse-game-group-tag rest game-group)))
                 ((token-type-p token :DESCRIPTION) (multiple-value-setq (rest game-group)          (parse-game-group-description rest game-group)))
                 ((token-type-p token :POINTS)      (multiple-value-bind (restTemp key pointValues) (parse-game-group-points rest)
                                                      (setf rest restTemp)
                                                      (setf (gethash key points) pointValues)))
                 ((token-type-p token :GAME)        (multiple-value-bind (restTemp game)   (parse-game rest)
                                                      (setf rest restTemp)
                                                      (push game games)))
                 (T (error "unexpected token ~a" (token-to-string (first rest))))))
      (multiple-value-bind (_ rest2) (consume rest :END)
      (push game-group (edition-game-groups edition))
      (loop for game in games
            do (setf (game-points game) points)  ; Games inherit points from game-group.
               (setf (game-parent-group game) (game-group-name game-group)))
      ; TODO JUL do games tags inherit from game-group?
      (push games (edition-games edition))
      (values rest2 edition)))))

(defun parse-game-group-tag (tokens game-group)
  (multiple-value-bind (tag-token rest) (consume tokens :TAG)
    (push (token-literal tag-token) (game-group-tags game-group))
    (values rest game-group)))

(defun parse-game-group-description (tokens game-group)
  (multiple-value-bind (_ rest) (consume tokens :DESCRIPTION)
  (multiple-value-bind (string-token rest2) (consume rest :STRING)
    (setf (game-group-description game-group) (token-literal string-token))
    (values rest2 game-group))))

(defun parse-game-group-points (tokens)
  (let ((identifier nil)
        (value nil))
  (multiple-value-bind (_ rest) (consume tokens :POINTS)
    ; identifier (optionnal, defaults to nil)
    (when (token-type-p (first rest) :STRING) 
      (multiple-value-bind (identifierToken restTemp) (consume rest :STRING)
        (setf rest restTemp)
        (setf identifier (token-literal identifierToken))))

    ; a number OR an array of numbers
    (cond 
      ((token-type-p (first rest) :NUMBER) (multiple-value-bind (valueToken restTemp) (consume rest :NUMBER)
                                             (setf rest restTemp)
                                             (setf value (token-literal valueToken))))
      ((token-type-p (first rest) :OPEN_BRACKET) (multiple-value-setq (rest value) (consume-array rest #'token-literal)))
      (T (error "unexpected token ~a" (token-to-string (first rest)))))
    (values rest identifier value))))
    
(defun parse-game-group-gameOLD (tokens)
  (multiple-value-bind (_ rest) (consume tokens :GAME)
  (multiple-value-bind (token-name rest2) (consume rest :STRING)
  (multiple-value-bind (_ rest3) (consume rest2 :RESULTS)
  (multiple-value-bind (rest4 results) (consume-array rest3 #'parse-participant-ref)
    (values rest4 (make-game :name (token-literal token-name) :results results)))))))
    
(defun parse-game (tokens)
  (multiple-value-bind (_ rest) (consume tokens :GAME)
  (multiple-value-bind (token-name rest) (consume rest :STRING)
      (let ((game (make-game :name (token-literal token-name))))
      (loop repeat 1000 ; avoid infinite loops
            while (not (token-type-p (first rest) :END))
            for token = (first rest)
            do (cond 
                 ((token-type-p token :POINTS)  (multiple-value-setq (rest game) (parse-game-points-identifier rest game)))
                 ((token-type-p token :RESULTS) (multiple-value-setq (rest game) (parse-game-results rest game)))
                 (T (loop-finish))))
      (values rest game))
    )))

(defun parse-game-points-identifier (tokens game) 
  (multiple-value-bind (_ rest) (consume tokens :POINTS)
  (multiple-value-bind (string-token rest) (consume rest :STRING)
    (setf (game-points-identifier game) (token-literal string-token))
    (values rest game))))


(defun parse-game-results (tokens game) 
  (multiple-value-bind (_ rest) (consume tokens :RESULTS)
  (multiple-value-bind (rest results) (consume-array rest #'parse-participant-ref)
    (setf (game-results game) results)
    (values rest game))))


; --- Parse PARTICIPANT
(defun parse-participant (tokens)
  (values 'OK (length tokens)))


; --- Parse DATATYPES
(defun parse-participant-ref (token)
  (unless (token-type-p token :PARTICIPANT-REF)
    (error "Expected @participant. Got ~a" token))
  (make-participant-ref :name (token-literal token)))

(defun consume-array (tokens element-parser)
  (let ((elements ()))
    (multiple-value-bind (_ rest) (consume tokens :OPEN_BRACKET)
    (loop while (not (token-type-p (first rest) :CLOSE_BRACKET))
          do (multiple-value-bind (element rest2) (consume rest)
               (push-end elements (funcall element-parser element))
               (setf rest rest2)))
    (multiple-value-bind (_ rest3) (consume rest :CLOSE_BRACKET)
      (values rest3 elements)))))

; --- Helpers
(defun consume (tokens &optional expected-type) 
  (unless tokens
    (error "Expected a token, got nothing."))
  (let ((token (first tokens)))
    (when expected-type
      (unless (token-type-p token expected-type)
        (error "Expected token type ~a, got ~a" expected-type (first token))))
      (values token (rest tokens))))

