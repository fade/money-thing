;; -*-lisp-*-
;;;; money-thing.asd

(asdf:defsystem #:money-thing
  :description "A system to facilitate financial analysis of stocks,
  and stock trading positions."
  :author "Brian O'Reilly <fade@deepsky.com>"
  :license "Modified BSD License"
  ;; :class :package-inferred-system 
  :serial t
  :depends-on (:alexandria
               :cl-json-pointer
               :cl-ppcre
               :cl-strings
               :quri
               :dexador
               :jonathan
               :jsown
               :local-time
               :mcclim
               :rutils
               :vellum
               :cl-yesql
               :cl-yesql/postmodern)
  :pathname "./"
  :components ((:file "app-utils")
               (:file "packages")
               (:file "config")
               (:file "money-thing")
               ;; (:file "db")
               ))

