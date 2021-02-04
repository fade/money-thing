;; -*-lisp-*-
;;;; yahoo-finance.asd

(asdf:defsystem #:yahoo-finance
  :description "An interface to the vestigal JSON machinery at Yahoo Finance."
  :author "Brian O'Reilly <fade@deepsky.com>"
  :license "Modified BSD License"
  ;; :class :package-inferred-system 
  :serial t
  :depends-on (:dexador
               :cl-ppcre
               :cl-strings
               :rutils
               :alexandria
               :jonathan
               :jsown
               :local-time
               :mcclim)
  :pathname "./"
  :components ((:file "app-utils")
               (:file "yahoo-finance")))

