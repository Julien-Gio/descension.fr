(in-package #:html)

(defparameter *assets-path* "assets")

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

(defun copy-assets-to-build-output ()
  (copy-directory *assets-path* (concatenate 'string *build-path* "/assets")))

(defun copy-directory (src dest)
  (let ((src-dir (uiop:ensure-directory-pathname src))
        (dest-dir (uiop:ensure-directory-pathname dest)))
    (ensure-directories-exist dest-dir)
    (loop for file in (uiop:directory-files src-dir) 
          do (format T "~&COPY ~a" file)
          do (uiop:copy-file file (make-pathname :name (pathname-name file) 
                                                 :type (pathname-type file) 
                                                 :defaults dest-dir)))
    (loop for subdir in (uiop:subdirectories src-dir)
          for dest-subdir = (merge-pathnames (car (last (pathname-directory subdir))) dest-dir)
          do (copy-directory subdir dest-subdir))))