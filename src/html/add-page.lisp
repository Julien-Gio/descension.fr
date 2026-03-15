(in-package #:html)

(defparameter *build-path* "output/public")

(defmacro add-page (route html)
  ; TODO export html to correct file
  ; TODO if route is a list, the first string is the cannonical route, the 
  ;      others are aliases that redirect.
  (let* ((route-sanitized (string-right-trim "/" route))
         (directory-path (concatenate 'string *build-path* route-sanitized "/")) ; This needs to end with a / to work.
         (html-path (concatenate 'string directory-path "/index.html")))
    `(progn 
      (ensure-directories-exist ,directory-path)
      (with-open-file (str ,html-path
                       :direction :output
                       :if-exists :supersede
                       :if-does-not-exist :create)
      (format str ,html)))))
