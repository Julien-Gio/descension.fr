(in-package #:html)

(defmacro def-edition-page (name &body body)
  (let* ((title-form (get-directive body 'title))
         (title (second title-form))
         (layout-form (get-directive body 'layout))
         (layout-items (rest layout-form))
         (use-form (get-directive body 'use ))
         (edition-filename (second use-form)))
    `(defun ,name ()
       (let ((html-string (make-array 0 :element-type 'character :fill-pointer 0 :adjustable T))
             (edition (interpreter:load-content ,edition-filename)))
         (format html-string "~&<html>")
         (format html-string "~&<head>")
         (format html-string "~&<title>~a</title>" ,title)
         (format html-string "~&</head>")
         (format html-string "~&<body>")
         (format html-string "~&<h1>Edition header ~a</h1>" (edition-name edition))
         ,@layout-items
         (format html-string "~&</body>")
         (format html-string "~&</html>")
         html-string))))

(defmacro podium ()
  `(format html-string "~&<p>PODIUM!<br/>~a<br/>~a<br/>~a</p>" 
    (participant-ref-name (first (edition-standing edition)))
    (participant-ref-name (second (edition-standing edition)))
    (participant-ref-name (third (edition-standing edition)))))

(defmacro header (content)
  `(format html-string "~&<h2>~a</h2>" ,content))

(defmacro trophies ()
  `(format html-string "~&<p>TROPHIES TODO!</p>"))

(defmacro def-participant-page (name participant)
  (let ((participant-points (gethash participant *points* 0)))
    `(defun ,name ()
       (let ((html-string (make-array 0 :element-type 'character :fill-pointer 0 :adjustable T))
             (level (if (> ,participant-points 50) "great" "bad")))
         (format html-string "<html>")
         (format html-string "<head>")
         (format html-string "<title>~a</title>" ,participant)
         (format html-string "</head>")
         (format html-string "<body>")
         (format html-string "<h1>~a's home</h1>" ,participant)
         (format html-string "<p>This is a ~a player.</p><br/>" level)
         (format html-string "<p>This mf has <em>~a</em> points!</p>" ,participant-points)
         (format html-string "</body>")
         (format html-string "</html>")
         html-string))))


; =================  Helper functions  =================

(defun get-directive (directives directive-symbol-name)
  (assoc directive-symbol-name directives 
         :key #'symbol-name 
         :test #'string=))
