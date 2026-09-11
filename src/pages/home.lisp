(in-package #:pages)

(defun page-home ()
  (render-html (list :html (list :head (list :title "Descension")
                                 (list :link '(:attrs :href "../../assets/main.css" :rel "stylesheet")))
                     (list :body
                           (list :h1 (list :a '(:attrs :href "/") "Descension"))
                           (list :h2 "Les archives")
                           (list :div (list :a '(:attrs :class "edition-link" :href "/e/2025") "Edition 2025"))
                           (list :div (list :a '(:attrs :class "edition-link" :href "/e/2024") "Edition 2024"))
                           (list :div (list :a '(:attrs :class "edition-link" :href "/e/2023") "Edition 2023"))
                           (list :div (list :a '(:attrs :class "edition-link" :href "/e/2022") "Edition 2022"))
                           (list :div (list :a '(:attrs :class "edition-link" :href "/e/2021") "Edition 2021"))
                           (list :div (list :a '(:attrs :class "edition-link" :href "/e/2019") "Edition 2019"))))))
