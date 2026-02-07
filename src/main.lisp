(in-package #:descension-ssg)

(defun main ()
  (defvar input)
  (defvar tokens)
  (defvar data)
  (setf input (make-array 0 :element-type 'character :fill-pointer 0 :adjustable T))
  (with-open-file (file "./content/testData.txt")
    (loop for line = (read-line file nil)
          while line
          do (format input "~A~&" line)))
  (print input)

  (setf tokens (lexer:lex (make-string-input-stream input)))
  (lexer:print-tokens tokens)

  (format t "~&")

  (setf data (parser:parse tokens))
  (print data))

