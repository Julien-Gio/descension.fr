(defvar number-chars)
(setf number-chars '(#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9))

(defvar alpha-chars)
(setf alpha-chars '(#\a #\b #\c #\d #\e #\f #\g #\h #\i #\j #\k #\l #\m #\n #\o #\p #\q #\r #\s #\t #\u #\v #\w #\x #\y #\z
                    #\A #\B #\C #\D #\E #\F #\G #\H #\I #\J #\K #\L #\M #\N #\O #\P #\Q #\R #\S #\T #\U #\V #\W #\X #\Y #\Z
                    #\_))

(defvar special-chars) 
(setf special-chars '(#\. #\-))

(defvar whitespace-chars) 
(setf whitespace-chars '(#\space #\tab #\page #\newline #\return #\linefeed))

(defvar alphanumeric-chars)
(setf alphanumeric-chars (append number-chars alpha-chars special-chars))

; -----------------------------------

(defun append-char (vec char)
  (vector-push-extend char vec)
  vec)

(defun append-vector (vec1 vec2)
  (loop for c across vec2 do (append-char vec1 c))
  vec1)

(defun match-any-p (stream chars) 
  (cond ((null chars) NIL) 
        ((matchp stream (first chars)) T)
        (t (match-any-p stream (rest chars)))))

(defun matchp (stream char) (char= char (peek-char nil stream nil)))

(defun consume (stream) (read-char stream))

(defun match-and-consume (stream chars)
  (let ((buffer (make-array 0 :element-type 'character :fill-pointer 0 :adjustable T)))
    (loop while (match-any-p stream chars)
          do (append-char buffer (consume stream)))
    buffer))

(defun match-and-consume-until (stream chars)
  (let ((buffer (make-array 0 :element-type 'character :fill-pointer 0 :adjustable T)))
    (loop while (not (match-any-p stream chars))
          do (append-char buffer (consume stream)))
    buffer))

; -----------------------------------

(defun lexer (stream)
  (let ((buffer ())
        (tokens ()))
    (loop for char = (peek-char nil stream nil)
          while (not (null char))
          do (cond ((match-any-p stream whitespace-chars) (consume stream)) ; Skip
                   ((matchp stream #\[)               (consume stream) (setf tokens (cons (list 'OPEN_BRACKET "[") tokens)))
                   ((matchp stream #\])               (consume stream) (setf tokens (cons (list 'CLOSE_BRACKET "]") tokens)))
                   ((matchp stream #\#)               (consume stream) (setf tokens (cons (lexTag stream) tokens)))
                   ((matchp stream #\@)               (consume stream) (setf tokens (cons (lexParticipant stream) tokens)))
                   ((matchp stream (character "("))   (consume stream) (setf tokens (cons (lexDate stream) tokens)))
                   ((matchp stream #\")               (consume stream) (setf tokens (cons (lexString stream) tokens)))
                   ((match-any-p stream '(#\+ #\-))   (setf tokens (cons (lexNumber stream) tokens)))
                   ((match-any-p stream number-chars) (setf tokens (cons (lexNumber stream) tokens)))
                   ((match-any-p stream alpha-chars)  (setf tokens (cons (lexIdentifier stream) tokens)))
                   (t (format t "~&ERROR unhandled char (~A)" (char-code char)) (consume stream))))
    (reverse tokens)))

; TAG: "#" (ALPHA | DIGIT | SPECIAL)+
(defun lexTag (stream)
  (list 'TAG (match-and-consume stream alphanumeric-chars)))

; PARTICIPANT: ">" (ALPHA | DIGIT | SPECIAL)+
(defun lexParticipant (stream)
  (list 'PARTICIPANT (match-and-consume stream alphanumeric-chars)))

; NUMBER: "+"? "-"? DIGIT+ "."? DIGIT*
(defun lexNumber (stream)
  (let ((buffer (make-array 0 :element-type 'character :fill-pointer 0 :adjustable T)))
    (if (matchp stream #\+) (append-char buffer (consume stream)))
    (if (matchp stream #\-) (append-char buffer (consume stream)))

    (append-vector buffer (match-and-consume stream number-chars))

    (if (matchp stream #\.) 
        (progn (append-char buffer (consume stream))
               (append-vector buffer (match-and-consume stream number-chars))))
    
    (list 'NUMBER buffer)))

; IDENTIFIER: ALPHA (ALPHA | DIGIT | SPECIAL)*
(defun lexIdentifier (stream)
   (let ((buffer (make-array 0 :element-type 'character :fill-pointer 0 :adjustable T)))
    (append-char buffer (consume stream))
    (append-vector buffer (match-and-consume stream alphanumeric-chars))
    (list 'IDENTIFIER buffer)))
  
; DATE: "(" DIGIT DIGIT DIGIT DIGIT "-" DIGIT DIGIT "-" DIGIT DIGIT ")"
(defun lexDate (stream)
  (let ((buffer (match-and-consume-until stream (list (character ")")))))
    (consume stream)  ; consume the closing parenthesis.
    (list 'DATE buffer)))

; STRING "\"" <anything but a double-quote>* "\""
(defun lexString (stream)
  (let ((buffer (match-and-consume-until stream '(#\"))))
    (consume stream)  ; consume the closing quote.
    (list 'STRING buffer)))
