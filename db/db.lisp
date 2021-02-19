(in-package :money-thing)

;; this shouldn't be here except at the REPL.
(postmodern:connect-toplevel "moneything" "moneything" "657483" "localhost")

(setf cl-postgres:*sql-readtable*
      (cl-postgres:copy-sql-readtable
       simple-date-cl-postgres-glue:*simple-date-sql-readtable*))

;;; stock and stock price data.

(defclass stock ()
  ((id :initarg :id :accessor stock-id :col-type integer :col-identity t)
   (symbol :initarg :symbol :accessor stock-symbol :col-type text)
   (description :initarg :description :accessor stock-description :col-type text)
   (currency :initarg :currency :accessor stock-currency :col-type text)
   (type :initarg :type :accessor stock-type :col-type text))
  (:documentation "records the name of the company, the symbol of the
  issue, the currency of record, and the type of issue.")
  (:metaclass postmodern:dao-class)
  (:table-name stock)
  (:keys id))

(defclass tick-data ()
  ((id :initarg :id :accessor tick-id :col-type serial)
   (dt :initarg :dt :accessor tick-dt :col-type timestamp)
   (stock-id :initarg :tick-id :accessor tick-id :col-type int4)
   (open :initarg :open :accessor tick-open :col-type float)
   (high :initarg :high :accessor tick-high :col-type float)
   (low :initarg :low :accessor tick-low :col-type float)
   (close :initarg :close :accessor tick-close :col-type float)
   (volume :initarg :volume :accessor tick-volume :col-type int4))
  (:documentation "this table holds tick candlebar data in a timescale database.")
  (:metaclass postmodern:dao-class)
  (:table-name tick_data)
  (:keys id stock-id))

(defun make-stock (symbol description type currency)
  "Given the metadata for a traded issue, return a DAO object
  containing that data."
  (make-instance 'stock :symbol symbol
                        :description description
                        :currency currency
                        :type type
                        ))

(defun zero-tables ()
  "drop the stock and tick-data tables from the database, and
reinitialise them."
  (if (pomo:table-exists-p 'tick-data)
      (query (:drop-table 'tick-data)))
  (if (pomo:table-exists-p 'stock)
      (query (:drop-table 'stock)))
  (execute (dao-table-definition 'stock))
  (execute (dao-table-definition 'tick-data)))

(defun insert-stock-objects (dao-list)
  (dolist (dao dao-list)
    (if (stock-id dao)
        (postmodern:update-dao dao)
        (postmodern:save-dao dao))))


;;; this is an interesting thing. if you create the dao objects
;;; representing the stocks known to finnhub which we have just looked
;;; up, and save those objects in a lisp list, iterating over the
;;; objects in that list afterward and attempting to save each one
;;; will throw an error because the id collumn in the db is not
;;; supposed to be null, and the slot is unbound at creation time. If
;;; you create the dao object, and immediately pass it to
;;; #'pomo:save-dao, the id serial number is created and the save
;;; succeeds.
(defun make-stock-objects (stocklist)
  "given a list of stock metadata of the form '(symbol description
  type currency) create a database access object representing the
  issue."
  (loop for (symbol description type currency) in stocklist
        ; the last entry in the list contains nil data, so check:
        if (and symbol description type currency)
          :do (format t "~&[ Creating: ~A ][ ~{~A ~^| ~} ]" symbol (list symbol description type currency))
          :do
             (let ((dao 
                     (make-stock symbol description type currency)))
               (save-dao dao))))

