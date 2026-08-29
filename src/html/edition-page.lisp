(in-package #:html)

(defmacro def-edition-page (name &body body)
  (let* ((title-form (get-directive body 'title))
         (title (second title-form))
         (layout-form (get-directive body 'layout))
         (layout-items (rest layout-form))
         (use-form (get-directive body 'use ))
         (edition-filename (second use-form)))
    `(defun ,name ()
       (let ((edition (interpreter:load-content ,edition-filename)))
         (render-html (list :html (list :head (list :title ,title)) 
                                  (list :body (list :h1 "Edition header " (edition-name edition)) 
                                              ,@layout-items)))))))

(defmacro header (content)
  `(list :h2 ,content))

(defmacro podium ()
  `(list :p "PODIUM!" 
      (list :br) 
      (participant-ref-name (first (edition-standing edition)))
      (list :br)
      (participant-ref-name (second (edition-standing edition)))
      (list :br)
      (participant-ref-name (third (edition-standing edition)))))

(defmacro trophies ()
  `(list :p "TROPHIES TODO"))


; =================  Helper functions  =================

(defun get-directive (directives directive-symbol-name)
  (assoc directive-symbol-name directives 
         :key #'symbol-name 
         :test #'string=))
