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

(defun decode-ticker-jsown (ticker)
  "decode json returned from yahoo finance endpoint. return a ticker object."
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
  "Given a JSON body, parse it with jonathan, returning a hash-table."
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
                        :period-closes (gethash "close" indicators)
                        :period-lows (gethash "low" indicators)
                        :period-highs (gethash "high" indicators)
                        :period-opens (gethash "open" indicators)
                        :period-volumes (gethash "volume" indicators)))))))





