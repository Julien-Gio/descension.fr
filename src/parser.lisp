(in-package #:parser)

(defparameter _ nil) ; throwaway var. I need to declare it to silence warnings of unused vars.

(defun parse (tokens) 
  (cond ((or (null tokens) (not (token-type-p (first tokens) :TYPE)))
         (format t "~&Error, expected 'type' keyword at top of file.")
         (values nil))
        ((token-type-p (second tokens) :EDITION)
         (parse-edition (rest (rest tokens))))
        (t 
         (format t "~&Error, unhandled data type ~A" (second tokens)))))

; --- Parse EDITION
(defun parse-edition (tokens)
  (loop with edition = (make-edition)
        while tokens
        do (multiple-value-setq (tokens edition)
             (parse-edition-field tokens edition))
        finally (return edition)))

(defun parse-edition-field (tokens edition)
  (let ((token (first tokens)))
    (cond 
      ((token-type-p token :NAME) (parse-name tokens edition))
      ((token-type-p token :DATES) (parse-date tokens edition))
      ((token-type-p token :STANDING) (parse-standing tokens edition))
      (T (error "unexpected token ~a" (first tokens))))))

(defun parse-name (tokens edition)
  (multiple-value-bind (_ rest) (consume tokens :NAME)
    (multiple-value-bind (str rest2) (consume rest :STRING)
      (setf (edition-name edition) (second str))
      (values rest2 edition))))

(defun parse-date (tokens edition)
  (multiple-value-bind (_ rest) (consume tokens :DATES)
  (multiple-value-bind (_ rest2) (consume rest :FROM)
  (multiple-value-bind (start-date rest3) (consume rest2 :DATE)
  (multiple-value-bind (_ rest4) (consume rest3 :TO)
  (multiple-value-bind (end-date rest5) (consume rest4 :DATE)
    (setf (edition-dates edition) (concatenate 'string (second start-date) ":" (second end-date)))
    (values rest5 edition)))))))

(defun parse-standing (tokens edition)
  (multiple-value-bind (_ rest) (consume tokens :STANDING)
  (multiple-value-bind (rest2 participants) (consume-array rest 'parse-participant-ref)
    (setf (edition-standing edition) participants)
    (values rest2 edition participants))))


; --- Parse PARTICIPANT
(defun parse-participant (tokens)
  (values 'OK (length tokens)))


; --- Parse DATATYPES
(defun parse-participant-ref (token)
  (unless (token-type-p token :PARTICIPANT-REF)
    (error "Expected @participant. Got ~a" token))
  (make-participant-ref :name (second token)))

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
(defun token-type-p (token type)
  (eq (first token) type))

(defun consume (tokens &optional expected-type)
  (unless tokens
    (error "Expected a token, got nothing."))
  (let ((token (first tokens)))
    (when expected-type
      (unless (token-type-p token expected-type)
        (error "Expected token type ~a, got ~a" expected-type (first token))))
      (values token (rest tokens))))

(defmacro push-end (place element)
  `(setf ,place (append ,place (list ,element))))
