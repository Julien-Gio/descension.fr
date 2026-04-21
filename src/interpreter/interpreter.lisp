(in-package #:interpreter)


(defun load-content (filename)
  (let ((input (make-array 0 :element-type 'character :fill-pointer 0 :adjustable T))
        (tokens ())
        (data ()))
    (with-open-file (file (format nil "./content/~a" filename))
    (loop for line = (read-line file nil)
          while line
          do (format input "~A~&" line)))
    ; (print input)

    (setf tokens (lexer:lex (make-string-input-stream input)))
    ; (lexer:print-tokens tokens)

    (setf data (parser:parse tokens))
    data))
