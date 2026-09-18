(asdf:defsystem "descension-ssg"
  :description "Static site generator"
  :version "0.0.1"
  :serial T
  :components
    ((:file "package")
     (:file "src/utils")
     (:file "src/types/token")
     (:file "src/types/edition")
     (:file "src/types/game-group")
     (:file "src/interpreter/lexer")
     (:file "src/interpreter/parser")
     (:file "src/interpreter/interpreter")
     (:file "src/renderer/renderer")
     (:file "src/renderer/add-page")
     (:file "src/pages/components/tournament")
     (:file "src/pages/components/edition-page")
     (:file "src/pages/2021")
     (:file "src/pages/2022")
     (:file "src/pages/2023")
     (:file "src/pages/2024")
     (:file "src/pages/2025")
     (:file "src/pages/2026")
     (:file "src/pages/home")
     (:file "src/main")))

