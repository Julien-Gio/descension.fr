(in-package #:html)

(defparameter *void-elements* '("area" "base" "br" "col" "embed" "hr" "img" "input" "link" "meta" "param" "source" "track" "wbr"))

(defun render-html (node)
  (with-output-to-string (out)
    (write-node node out)))

(defun write-node (node out)
  (cond ((null node) #| Do nothing |#)
        ((numberp node) (write-string (escape-html (write-to-string node)) out))
        ((stringp node) (write-string (escape-html node) out))
        ((keywordp (first node)) (write-tag node out))
        (T (loop for sub-node in node do (write-node sub-node out)))))

(defun write-tag (node out)
  (let* ((tag (string-downcase (symbol-name (car node))))
         (attributes (if (and (listp (cadr node))
                              (keywordp (caadr node))
                              (string= (symbol-name (caadr node)) "ATTRS"))
                         (cadr node)))
         (children (if (null attributes) (cdr node) (cddr node))))
    (if (member tag *void-elements* :test #'string=)
        (progn ; Void element <tag/>
              (format out "<~a" tag)
              (write-attrs attributes out)
              (format out "/>"))
        (progn ; Standard element <tag></tag>
              (format out "<~a" tag)
              (write-attrs attributes out)
              (format out ">")
              (loop for child in children do (write-node child out))
              (format out "</~a>" tag)))))

(defun write-attrs (attrs out)
  ; The first element in attrs is always ":attrs", skip it.
  (loop for (key val) on (rest attrs) by #'cddr
        do (format out " ~a=\"~a\"" (string-downcase (symbol-name key)) (escape-html val))))

(defun escape-html (in)
  (with-output-to-string (out)
    (loop for ch across in
          for escaped = (case ch (#\& "&amp;") (#\< "&lt;") (#\> "&gt;") (#\" "&quot;") (T (string ch)))
          do (write-string escaped out))))