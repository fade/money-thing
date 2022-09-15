(in-package :money-thing)

;;                           :database  :username  :password      :host
(postmodern:connect-toplevel "marketdb" "tradekit" "yourpassword" "localhost")

(setf cl-postgres:*sql-readtable*
      (cl-postgres:copy-sql-readtable
       simple-date-cl-postgres-glue:*simple-date-sql-readtable*))

;;; stock and stock price data.

(defclass stock ()
  ((id :initarg :id :accessor stock-id :col-type serial :col-identity t)
   (symbol :initarg :symbol :accessor stock-symbol :col-type text)
   (name :initarg :name :accessor stock-name :col-type text)
   (exchange :initarg :exchange :accessor stock-exchange :col-type text)
   (type :initarg :type :accessor stock-type :col-type text)
   (is-etf :initarg :etf? :accessor is-etf? :col-type boolean :initform nil))
  (:documentation "records the name of the company, the symbol of the
  issue, the exchange of record, and the type of issue.")
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

(defun make-stock (symbol name type exchange)
  "Given the metadata for a traded issue, return a DAO object
  containing that data."
  (make-instance 'stock :symbol symbol
                        :name name
                        :exchange exchange
                        :type type))

(defun zero-tables ()
  "drop the stock and tick-data tables from the database, and
reinitialise them."
  (if (pomo:table-exists-p 'tick-data)
      (query (:drop-table 'tick-data)))
  (if (pomo:table-exists-p 'stock)
      (query (:drop-table 'stock)))
  (execute (dao-table-definition 'stock))
  (execute (dao-table-definition 'tick-data)))

;;;  This is an interesting thing. if you create the dao objects and
;;;  save those objects in a lisp list, iterating over the objects in
;;;  that list afterward and attempting to save each one will throw an
;;;  error because the id column in the db is a serial type and is not
;;;  supposed to be null, and the slot is unbound at creation time. If
;;;  you create the dao object, and immediately pass it to
;;;  #'pomo:save-dao, the id serial number is created and the save
;;;  succeeds. This weird behaviour hung me up for a long time.
(defun make-stock-objects (stocklist)
  "given a list of stock metadata of the form '(symbol name
  type exchange) create a database access object representing the
  issue."
  (loop for (symbol name type exchange) in stocklist
                                        ; the last entry in the list contains nil data, so check:
        if (and symbol name type exchange)
          :do
             (let ((dao 
                     (make-stock symbol name type exchange)))
               (format t "~&[ Creating: ~A ][ ~{~A ~^| ~} ]" symbol (list symbol name type exchange))
               (save-dao dao))))

