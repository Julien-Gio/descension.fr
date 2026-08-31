(in-package #:descension-ssg)

(defun main ()
  (html:copy-assets-to-build-output)
  (load "src/router.lisp"))

