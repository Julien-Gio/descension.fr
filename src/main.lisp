(setf *invoke-debugger-hook* nil) ; Enable the debugger for SBCL.

(load "lexer.lisp")

(defvar input)
(defvar tokens)
(setf input (make-array 0 :element-type 'character :fill-pointer 0 :adjustable T))
(with-open-file (file "../content/testData.txt")
  (loop for line = (read-line file nil)
        while line
        do (format input "~A~&" line)))
(print input)

(setf tokens (lexer (make-string-input-stream input)))
; (print-tokens tokens)
