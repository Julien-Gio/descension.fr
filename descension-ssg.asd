(asdf:defsystem "descension-ssg"
  :description "Static site generator"
  :version "0.0.1"
  :serial T
  :components
    ((:file "package")
     (:file "src/typings/token")
     (:file "src/typings/edition")
     (:file "src/interpreter/lexer")
     (:file "src/interpreter/parser")
     (:file "src/interpreter/interpreter")
     (:file "src/html/renderer")
     (:file "src/html/add-page")
     (:file "src/html/edition-page")
     (:file "src/pages/2025")
     (:file "src/main")))

