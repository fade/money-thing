(in-package :money-thing)

;;; this section is all about finding a fairly complete database of
;;; traded companies in world exchanges. Finnhub seems to have
;;; complete data for the NYSE and the Nasdaq. Notably the Toronto
;;; Stock Exchange has a query code parameter, but only returns a
;;; handful of ETFs.

(defparameter *getreturn* nil)

(defun dump-json-to-file (filename)
  (with-open-file (s filename :direction :output :if-exists :supersede)
    (write-string *getreturn* s)))

(defun get-known-stock-symbols (&key (endpoint *finnhub-api-endpoint*)
                                (exchange "US")
                                (token *finnhub-api-key*)
                                (user-agent *user-agent*))
  "Get the list of all known stocks from the finnhub finance API for the indicated exchange.
  returned as a JSON output."
  ;; https://finnhub.io/api/v1/stock/symbol?exchange=US&token=bp0nv9frh5r9fdeib5h0
  (let* ((request (quri:make-uri :defaults endpoint
                                 :query `(("exchange" . ,exchange)
                                          ("token" . ,token)))))
    (multiple-value-bind (body status headers uri connection)
        (handler-case
            (dex:request request
                         :method :get
                         :headers `(("User-Agent" . ,user-agent)
                                    ("accept" . "application/json"))
                         :verbose t)
          (error (c) c))
      (setf *getreturn* body)
      (values body status headers uri connection))))

(defun finnhub-stocklist-json->data (&key (jsource *getreturn*))
  "Take a string of json representing a list of all known stocks as
  returned from finnhub.io and turn it into lisp data."
  (let* ((obj (jsown:parse jsource))
         (cl-json-pointer:*json-object-flavor* :jsown))
    (loop for i from 0 to (length obj)
          :collect
          (list
           (get-by-json-pointer obj (format nil "/~A/symbol" i))
           (get-by-json-pointer obj (format nil "/~A/description" i))
           (get-by-json-pointer obj (format nil "/~A/type" i))
           (get-by-json-pointer obj (format nil "/~A/currency" i))))))

(defun populate-finnhub-sources (&key (exchange "US"))
  "Get a list of all known stock issues from finnhub.io, and save the
data to our database."
  (let* ((stock-metadata (finnhub-stocklist-json->data
                          :jsource (get-known-stock-symbols :exchange exchange)))
         (metadata-list (make-stock-objects stock-metadata)))
    (values metadata-list)))
