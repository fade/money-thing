;; -*-lisp-*-

(in-package :money-thing)


(defun raw-json (ticker)
  (let* ((tick (string-upcase ticker))
         (url (format nil "~A/v8/finance/chart/~A" *base-url* tick)))
      (multiple-value-bind (body status response-headers uri stream)
          (dex:get url)
        (declare (ignorable body status response-headers uri stream))
        (format t "~&URL: ~A" url)
        ;; (values body status response-headers uri stream)
        ;; (jsown:val (jsown:val *kk* "chart") "result")
        (let* ((data (jsown:parse body))
               (result (first (jsown:val (jsown:val data "chart") "result")))
               (ticker-info (nthcdr 2 (first (nthcdr 1 result))))
               (timestamps (nthcdr 1 (first (nthcdr 2 result))))
               (indicators (cdr (second (third  (first (nthcdr 3 result))))))
               ;; (high   (jsown:val indicators "high"))
               ;; (close  (jsown:val indicators "close"))
               ;; (low    (jsown:val indicators "low"))
               ;; (volume (jsown:val indicators "volume"))
               ;; (open   (jsown:val indicators "open"))
               )

          ;; (values high close low volume open)
          (values ticker-info timestamps indicators))))) ;;timestamps indicators

(defun yfin-data-hashtable (ticker)
  "input debugging."
  (let* ((tick (string-upcase ticker))
         (url (format nil "~A/v8/finance/chart/~A" *base-url* tick)))
    (multiple-value-bind (body  status response-headers url stream)
        (dex:get url)
      (declare (ignorable body  status response-headers url stream))
      (format t "~&URL: ~A~2%" url)
      (jonathan:parse body :as :hash-table))))

(defun bleurg (ticker)
  (let* ((tick (string-upcase ticker))
         (url (format nil "~A/v8/finance/chart/~A" *base-url* tick)))
    (multiple-value-bind (body status response-headers uri stream)
        (dex:get url)
      (declare (ignorable body status response-headers uri stream))
      (format t "~&URL: ~A" url)
      (let* ((data (jsown:parse body))
             (result (first (jsown:val (jsown:val data "chart") "result")))
             (ticker-info (nthcdr 2 (first (nthcdr 1 result))))
             (timestamps (nthcdr 1 (first (nthcdr 2 result))))
             (indicators (cdr (second (third  (first (nthcdr 3 result))))))
             (current-trading-period (first (nthcdr 14 result))))
        (values result)))))

(defun decode-ticker-jsown (ticker)
  "decode json return from yahoo finance endpoint"
  (let* ((tick (string-upcase ticker))
         (url (format nil "~A/v8/finance/chart/~A" *base-url* tick)))
    (multiple-value-bind (body status response-headers uri stream)
        (dex:get url)
      (declare (ignorable body status response-headers uri stream))
      (format t "~&URL: ~A" url)
      (let* ((data (jsown:parse body))
             (result (first (jsown:val (jsown:val data "chart") "result")))
             (ticker-info (nthcdr 2 (first (nthcdr 1 result))))
             (timestamps (nthcdr 1 (first (nthcdr 2 result))))
             (indicators (cdr (second (third  (first (nthcdr 3 result))))))
             (current-trading-period (first (nthcdr 14 result))))
        (make-instance 'ticker
                       :symbol (cdr (assoc "symbol" ticker-info :test #'equal))
                       :pricing-currency (cdr (assoc "currency" ticker-info :test #'equal))
                       :exchange-name (cdr (assoc "exchangeName" ticker-info :test #'equal))
                       :instrument-type (cdr (assoc "instrumentType" ticker-info :test #'equal))
                       :first-trade-date (cdr (assoc "firstTradeDate" ticker-info :test #'equal))
                       :regular-market-time (cdr (assoc "regularMarketTime" ticker-info :test #'equal))
                       :gmtoffset (cdr (assoc  "gmtoffset" ticker-info :test #'equal))
                       :timezone (cdr (assoc  "timezone" ticker-info :test #'equal))
                       :exchange-timezone-name (cdr (assoc  "exchangeTimezoneName" ticker-info :test #'equal))
                       :current-trading-period current-trading-period
                       :regular-market-price (cdr (assoc  "regularMarketPrice" ticker-info :test #'equal))
                       :chart-previous-close (cdr (assoc  "chartPreviousClose" ticker-info :test #'equal))
                       :previous-close (cdr (assoc  "previousClose" ticker-info :test #'equal))
                       :scale (cdr (assoc  "scale" ticker-info :test #'equal))
                       :price-hint (cdr (assoc  "priceHint" ticker-info :test #'equal))
                       :timestamps (mapcar #'local-time:unix-to-timestamp timestamps))))))

(defun parse-ticker-as-hash (body)
  "Given a JSON body, parse it with jonathan, but step through the parse in the debugger."
  (jonathan:parse body :as :hash-table :junk-allowed t))

(defun decode-ticker (ticker)
  (let* ((tick (string-upcase ticker))
         (url (format nil "~A/v8/finance/chart/~A" *base-url* tick)))
    
    (multiple-value-bind (body status response-headers uri stream)
        (dex:get url)
      (declare (ignorable body status response-headers uri stream))
      (format t "~&[[~A]]" url)
      (let* ((data (parse-ticker-as-hash body))
             (result (first (gethash "result" (gethash "chart" data))))
             (ticker-info (gethash "meta" result)) 
             (timestamps (gethash "timestamp" result)) ;; this is a list
             (indicators (first (gethash "quote" (gethash "indicators" result))))
             (current-trading-period (gethash "currentTradingPeriod" ticker-info))) ;; post / pre / regular

        (values
         (make-instance 'ticker
                        :symbol (gethash "symbol" ticker-info)
                        :pricing-currency (gethash "currency" ticker-info)
                        :exchange-name (gethash "exchangeName" ticker-info)
                        :instrument-type (gethash "instrumentType" ticker-info)
                        :first-trade-date (gethash "firstTradeDate" ticker-info)
                        :regular-market-time (gethash "regularMarketTime" ticker-info)
                        :gmtoffset (gethash "gmtoffset" ticker-info)
                        :timezone (gethash "timezone" ticker-info)
                        :valid-ranges (gethash "validRanges" ticker-info)
                        :exchange-timezone-name (gethash "exchangeTimezoneName" ticker-info)
                        :current-trading-period (gethash "regular" current-trading-period)
                        :regular-market-price (gethash  "regularMarketPrice" ticker-info)
                        :chart-previous-close (gethash "chartPreviousClose" ticker-info)
                        :previous-close (gethash "previousClose" ticker-info)
                        :scale (gethash "scale" ticker-info)
                        :price-hint (gethash "priceHint" ticker-info)
                        :timestamps (mapcar #'local-time:unix-to-timestamp timestamps)
                        :indicators indicators                   
                        :period-lows (gethash "low" indicators)
                        :period-highs (gethash "high" indicators)
                        :period-opens (gethash "open" indicators)
                        :period-volumes (gethash "volume" indicators)))))))



;;; object to contain ticker description and indices.

(defclass trading-period ()
  ((timezone :initarg :timezone :initform "GMT" :reader timezone)
   (start-of :initarg :start-of :initform nil :accessor start-of)
   (end-of  :initarg :end-of :initform nil :accessor end-of)
   (gmtoffset :initarg :gmtoffset :initform 0 :accessor gmtoffset)))

(defclass ticker ()
  ((symbol :initarg :symbol :initform (error "ticker needs a symb
ol to represent."))
   (pricing-currency :initarg :pricing-currency :initform nil :initarg :pcof)
   (exchange-name :initarg :exchange-name :initform nil :accessor exchange-name)
   (instrument-type :initarg :instrument-type :initform nil :accessor instrument-type)
   (first-trade-date :initarg :first-trade-date :initform nil :accessor first-trade-date)
   (regular-market-time :initarg :regular-market-time :initform nil :accessor regular-market-time)
   (gmtoffset :initarg :gmtoffset :initform nil :accessor gmtoffset)
   (timezone :initarg :timezone :initform nil :accessor timezone)
   (exchange-timezone-name :initarg :exchange-timezone-name :initform nil :accessor exchange-timezone-name)
   (regular-market-price :initarg :regular-market-price :initform nil :accessor regular-market-price)
   (chart-previous-close :initarg :chart-previous-close :initform nil :accessor chart-previous-close)
   (previous-close :initarg :previous-close :initform nil :accessor previous-close)
   (scale :initarg :scale :initform nil :accessor scale)
   (price-hint :initarg :price-hint :initform nil :accessor price-hint)
   (current-trading-period :initarg :current-trading-period :initform nil :accessor current-trading-period)
   (trading-periods :initarg :trading-periods :initform nil :accessor trading-periods)
   (data-granularity :initarg :data-granularity :initform nil :accessor data-granularity)
   (range :initarg :range :initform nil :accessor range)
   (valid-ranges :initarg :valid-ranges :initform nil :accessor valid-ranges)
   (timestamps :initarg :timestamps :initform nil :accessor timestamps)
   (indicators :initarg :indicators :initform nil :accessor indicators)
   (period-opens :initarg :period-opens :initform nil :accessor period-opens)
   (period-lows :initarg :period-lows :initform nil :accessor period-lows)
   (period-highs :initarg :period-highs :initform nil :accessor period-highs)
   (period-closes :initarg :period-closes :initform nil :accessor period-closes)
   (period-volumes :initarg :period-volumes :initform nil :accessor period-volumes)
   (period-instant-data :initarg :period-instant-data :initform nil
                        :accessor period-instant-data
                        :documentation "lists of the form: (timestamp open low high volume)"))
  (:documentation "An object that holds the metadata and pricing data
  for a given stock in a given period, defaulting to one day."))

(defmethod initialize-instance :after ((tick ticker) &key)
  (setf (first-trade-date tick) (local-time:unix-to-timestamp (first-trade-date tick))
        (regular-market-time tick) (local-time:unix-to-timestamp (regular-market-time tick))
        (current-trading-period tick) (make-instance 'trading-period
                                                     :timezone (gethash "timezone" (current-trading-period tick))
                                                     :start-of (local-time:unix-to-timestamp (gethash "start" (current-trading-period tick)))
                                                     :end-of (local-time:unix-to-timestamp (gethash "end" (current-trading-period tick)))
                                                     :gmtoffset (gethash "gmtoffset" (current-trading-period tick)))
        (period-instant-data tick) (mapcar #'list (timestamps tick) (period-opens tick)
                                           (period-lows tick) (period-highs tick)
                                           (period-volumes tick))))

(defmethod print-object ((tick ticker) stream)
  ;; (format stream "~@[L~A ~]~S~@[: ~S~]"
  ;;         nil
  ;;         (error tick)
  ;;         (matrix-error-line tick))
  (call-next-method))

(defmethod print-period-instant-data ((tick ticker) stream)
  (loop for slitch in (period-instant-data tick)
        do (format stream "~&[[ ~{~A~^ ~}]]" slitch)))

(defun -main (&optional args)
  (format t "~a~%" "I don't do much yet"))

