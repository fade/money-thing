;; -*-lisp-*-
;;;; yahoo-finance.asd

(asdf:defsystem #:yahoo-finance
  :description "An interface to the vestigal JSON machinery at Yahoo Finance."
  :author "Brian O'Reilly <fade@deepsky.com>"
  :license "Modified BSD License"
  ;; :class :package-inferred-system 
  :serial t
  :depends-on (:alexandria
               :cl-json-pointer
               :cl-ppcre
               :cl-strings
               :dexador
               :jonathan
               :jsown
               :local-time
               :mcclim
               :rutils
               :vellum)
  :pathname "./"
  :components ((:file "app-utils")
               (:file "yahoo-finance")))

