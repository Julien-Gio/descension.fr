(in-package #:token)

(defstruct TOKEN
  type
  lexeme
  literal
  line)

(defun token-type-p (token type)
  (eq (token-type token) type))

(defun token-to-string (token) 
  (format nil "~a ~a ~a (line ~a)" (token-type token) (token-lexeme token) (token-literal token) (token-line token)))
