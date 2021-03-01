;; -*-lisp-*-
;;;; money-thing.asd

(asdf:defsystem #:money-thing
  :description "A system to facilitate financial analysis of stocks,
  and stock trading positions."
  :author "Brian O'Reilly <fade@deepsky.com>"
  :license "Modified BSD License"
  ;; :class :package-inferred-system 
  :serial t
  :depends-on (#:alexandria
               #:cl-json-pointer
               #:cl-ppcre
               #:cl-strings
               #:quri
               #:dexador
               #:jonathan
               #:jsown
               #:local-time
               #:mcclim
               #:rutils
               #:vellum
               #:simple-date
               #:simple-date/postgres-glue
               #:postmodern
               ;; #:cl-yesql
               ;; #:cl-yesql/postmodern
               #:net.didierverna.clon)
  :pathname "./"
  :components ((:static-file "money-thing.asd")
               (:file "app-utils")
               (:file "packages")
               (:file "config")
               (:file "money-thing")
               (:module :data-access
                :components ((:file "yfin")
                             (:file "finnhub-io")))
               (:module :db
                :components ((:file "db")))))

