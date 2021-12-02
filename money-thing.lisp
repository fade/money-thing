;; -*-lisp-*-

(in-package :money-thing)

;;; objects to contain ticker description and indices.

(defclass trading-period ()
  ((timezone :initarg :timezone :initform "GMT" :reader timezone)
   (start-of :initarg :start-of :initform nil :accessor start-of)
   (end-of  :initarg :end-of :initform nil :accessor end-of)
   (gmtoffset :initarg :gmtoffset :initform 0 :accessor gmtoffset)))

(defclass ticker ()
  ((symbol :initarg :symbol
           :initform (error "ticker needs a symbol to represent.")
           :reader ticker-symbol)
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
  "Turn the timestamps returned from yahoo finance into
local-time timestamps which we can calculate with."
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

;; (defmethod print-object ((tick ticker) stream)
;;   (format stream "~@[L~A ~]~S~@[: ~S~]"
;;           nil
;;           (error tick)
;;           (matrix-error-line tick))
;;   (call-next-method))

(defmethod print-period-instant-data ((tick ticker) stream)
  (loop for slitch in (period-instant-data tick)
        do (format stream "~&[[ ~{~A~^ ~}]]" slitch)))

(defun -main (&optional args)
  (format t "~a~%" "I don't do much yet"))

