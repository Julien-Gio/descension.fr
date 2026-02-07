(require :asdf)
;; Add the project directory to ASDF
(asdf:load-asd
 (merge-pathnames "descension-ssg.asd"
                  *load-truename*))
                  
(asdf:load-system :descension-ssg)
(descension-ssg:main)