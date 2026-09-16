(in-package #:lexer)

(defvar number-chars)
(setf number-chars '(#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9))

(defvar alpha-chars)
(setf alpha-chars '(#\a #\b #\c #\d #\e #\f #\g #\h #\i #\j #\k #\l #\m #\n #\o #\p #\q #\r #\s #\t #\u #\v #\w #\x #\y #\z
                        #\A #\B #\C #\D #\E #\F #\G #\H #\I #\J #\K #\L #\M #\N #\O #\P #\Q #\R #\S #\T #\U #\V #\W #\X #\Y #\Z
                        #\_))

(defvar special-chars)
(setf special-chars '(#\. #\-))

(defvar whitespace-chars)
(setf whitespace-chars '(#\space #\tab #\page))

(defvar newline-chars)
(setf newline-chars '(#\newline #\return #\linefeed))

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

(defun matchp (stream char)
  (let ((peeked-char (peek-char nil stream nil)))
    (and (not (null peeked-char)) (char= char peeked-char))))

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

(defun lex (stream)
  (let ((tokens ())
        (line-num 1))
    (loop for char = (peek-char nil stream nil)
          while (not (null char))
            when (matchp stream #\newline)
          do (incf line-num)
          do (cond ((matchp stream #\;) (match-and-consume-until stream newline-chars)) ; Skip comments
                   ((match-any-p stream newline-chars) (consume stream)) ; Skip whitespace
                   ((match-any-p stream whitespace-chars) (consume stream)) ; Skip whitespace
                   ((matchp stream #\[) (consume stream) (push (make-token :type :OPEN_BRACKET :lexeme "[" :line line-num) tokens))
                   ((matchp stream #\]) (consume stream) (push (make-token :type :CLOSE_BRACKET :lexeme "]" :line line-num) tokens))
                   ((matchp stream #\#) (consume stream) (push (lex-tag stream line-num) tokens))
                   ((matchp stream #\@) (consume stream) (push (lex-participant-ref stream line-num) tokens))
                   ((matchp stream (character "(")) (consume stream) (push (lex-date stream line-num) tokens))
                   ((matchp stream #\") (consume stream) (push (lex-string stream line-num) tokens)
                                        (incf line-num (count-char-in-string (token-lexeme (first tokens)) #\newline))) ; Strings can be multiline.
                   ((match-any-p stream '(#\+ #\-)) (push (lex-number stream line-num) tokens))
                   ((match-any-p stream number-chars) (push (lex-number stream line-num) tokens))
                   ((match-any-p stream alpha-chars) (push (lex-keyword-or-identifier stream line-num) tokens))
                   (t (error "~&ERROR unhandled char line ~a '~c' (decimal ~a)" line-num char (char-code char)))))
    (reverse tokens)))

; TAG: "#" (ALPHA | DIGIT | SPECIAL)+
(defun lex-tag (stream line-num)
  (let ((literal (match-and-consume stream alphanumeric-chars)))
    (make-token :type :TAG
                :lexeme (format nil "#~a" literal)
                :literal literal
                :line line-num)))

; PARTICIPANT: "@" (ALPHA | DIGIT | SPECIAL)+
(defun lex-participant-ref (stream line-num)
  (let ((literal (match-and-consume stream alphanumeric-chars)))
    (make-token :type :PARTICIPANT-REF
                :lexeme (format nil "@~a" literal)
                :literal literal
                :line line-num)))

; NUMBER: "+"? "-"? DIGIT+ "."? DIGIT*
(defun lex-number (stream line-num)
  (let ((buffer (make-array 0 :element-type 'character :fill-pointer 0 :adjustable T))
        (sign 1)
        (integer-str "")
        (integer-val 0)
        (fraction-str "")
        (fraction-val 0))
    ; Sign
    (when (matchp stream #\+) (append-char buffer (consume stream)) (setf sign 1))
    (when (matchp stream #\-) (append-char buffer (consume stream)) (setf sign -1))

    ; Decimal part
    (setf integer-str (match-and-consume stream number-chars))
    (append-vector buffer integer-str)
    (when (> (length integer-str) 0))
    (setf integer-val (parse-integer integer-str))

    ; Fraction part
    (if (matchp stream #\.)
        (progn (append-char buffer (consume stream))
               (setf fraction-str (match-and-consume stream number-chars))
               (when (> (length fraction-str) 0))
               (setf fraction-val (parse-integer fraction-str))
               (append-vector buffer fraction-str)))

    (make-token :type :NUMBER
                :lexeme buffer
                :literal (* sign (+ integer-val (/ (float fraction-val) (expt 10 (length fraction-str)))))
                :line line-num)))

; IDENTIFIER: ALPHA (ALPHA | DIGIT | SPECIAL)*
(defun lex-keyword-or-identifier (stream line-num)
  (let ((lexeme (make-array 0 :element-type 'character :fill-pointer 0 :adjustable T)))
    (append-char lexeme (consume stream))
    (append-vector lexeme (match-and-consume stream alphanumeric-chars))
    (cond ((equal lexeme "type") (make-token :type :TYPE :lexeme lexeme :line line-num))
          ((equal lexeme "edition") (make-token :type :EDITION :lexeme lexeme :line line-num))
          ((equal lexeme "from") (make-token :type :FROM :lexeme lexeme :line line-num))
          ((equal lexeme "to") (make-token :type :TO :lexeme lexeme :line line-num))
          ((equal lexeme "define") (make-token :type :DEFINE :lexeme lexeme :line line-num))
          ((equal lexeme "end") (make-token :type :END :lexeme lexeme :line line-num))
          ((equal lexeme "name") (make-token :type :NAME :lexeme lexeme :line line-num))
          ((equal lexeme "participants") (make-token :type :PARTICIPANTS :lexeme lexeme :line line-num))
          ((equal lexeme "description") (make-token :type :DESCRIPTION :lexeme lexeme :line line-num))
          ((equal lexeme "dates") (make-token :type :DATES :lexeme lexeme :line line-num))
          ((equal lexeme "game-group") (make-token :type :GAME-GROUP :lexeme lexeme :line line-num))
          ((equal lexeme "tournament") (make-token :type :TOURNAMENT :lexeme lexeme :line line-num))
          ((equal lexeme "points") (make-token :type :POINTS :lexeme lexeme :line line-num))
          ((equal lexeme "game") (make-token :type :GAME :lexeme lexeme :line line-num))
          ((equal lexeme "results") (make-token :type :RESULTS :lexeme lexeme :line line-num))
          ((equal lexeme "set") (make-token :type :SET :lexeme lexeme :line line-num))
          ((equal lexeme "winners-bracket") (make-token :type :WINNERS_BRACKET :lexeme lexeme :line line-num))
          ((equal lexeme "losers-bracket") (make-token :type :LOSERS_BRACKET :lexeme lexeme :line line-num))
          ((equal lexeme "final-bracket") (make-token :type :FINAL_BRACKET :lexeme lexeme :line line-num))
          (T (make-token :type :IDENTIFIER :lexeme lexeme :line line-num)))))

; DATE: "(" DIGIT DIGIT DIGIT DIGIT "-" DIGIT DIGIT "-" DIGIT DIGIT ")"
(defun lex-date (stream line-num)
  (let ((buffer (match-and-consume-until stream (list (character ")")))))
    (consume stream) ; consume the closing parenthesis.
    (make-token :type :DATE
                :lexeme (format nil "(~a)" buffer)
                :literal buffer
                :line line-num)))

; STRING "\"" <anything but a double-quote>* "\""
(defun lex-string (stream line-num)
  (let ((buffer (match-and-consume-until stream '(#\"))))
    (consume stream) ; consume the closing quote.
    (make-token :type :STRING
                :lexeme (format nil "\"~a\"" buffer)
                :literal buffer
                :line line-num)))

; ----------------------------------------

(defun count-char-in-string (str char)
  (loop with count = 0
        for c across str
          when (char= c char)
        do (incf count)
        finally (return count)))

(defun print-tokens (tokens)
  (loop for token in tokens
        do (format t "~&~a" (token-to-string token))))
