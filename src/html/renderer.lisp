(in-package #:html)

(defparameter *void-elements* '("area" "base" "br" "col" "embed" "hr" "img" "input" "link" "meta" "param" "source" "track" "wbr"))

(defun render-html (node) 
  (with-output-to-string (out)
    (write-node node out)))

(defun write-node (node out)
  (cond ((null node) #| Do nothing |#)
        ((stringp node) (write-string (escape-html node) out))
        ((keywordp (first node)) (write-tag node out))
        (T (loop for sub-node in node do (write-node sub-node out)))))

(defun write-tag (node out) 
  (let ((tag (string-downcase (symbol-name (first node))))
        (children (rest node)))
    (if (and (null children) (member tag *void-elements* :test #'string=)) 
          (format out "<~a/>" tag)
          (progn (format out "<~a>" tag)
                 (loop for child in children do (write-node child out))
                 (format out "</~a>" tag)))))

(defun escape-html (in)
  (with-output-to-string (out) 
    (loop for ch across in
          for escaped = (case ch (#\& "&amp;") (#\< "&lt;") (#\> "&gt;") (#\" "&quot;") (T (string ch)))
          do (write-string escaped out))))