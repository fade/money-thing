(in-package :money-thing)

(let ((cl:*break-on-signals* t))
 (yesql:import db
   ;; :from (money-thing.app-utils::make-pathname-in-lisp-subdir "money-thing/db/init.sql")
   :as :cl-yesql/postmodern
   :from #P"/home/fade/SourceCode/lisp/money-thing/db/db.sql"
   :binding :all-functions))

(yesql:import db
   ;; :from (money-thing.app-utils::make-pathname-in-lisp-subdir "money-thing/db/init.sql")
   :as :cl-yesql/postmodern
   :from #P"/home/fade/SourceCode/lisp/money-thing/db/db.sql"
   :binding :all-functions)
