print('/*******************  BEGIN Update tblARCustomer Total AR Balance *******************/')
GO

EXEC dbo.uspARUpdateCustomerTotalAR

print('/*******************  END Update tblARCustomer Total AR Balance  *******************/')
GO

print('/*******************  BEGIN Update tblARCustomer Highest AR *******************/')
GO

IF OBJECT_ID('tempdb..#CUSTOMERS') IS NOT NULL DROP TABLE #CUSTOMERS
IF OBJECT_ID('tempdb..#AGINGDATES') IS NOT NULL DROP TABLE #AGINGDATES
IF OBJECT_ID('tempdb..#CUSTOMERDATES') IS NOT NULL DROP TABLE #CUSTOMERDATES
IF OBJECT_ID('tempdb..#FINALAGING') IS NOT NULL DROP TABLE #FINALAGING

DECLARE @dtmDateFrom	DATETIME = NULL
DECLARE @dtmDateTo		DATETIME = CAST(GETDATE() AS DATE)

CREATE TABLE #CUSTOMERS (intEntityCustomerId	INT PRIMARY KEY)
CREATE TABLE #AGINGDATES (intId INT PRIMARY KEY, dtmDateFrom	DATETIME)
CREATE TABLE #FINALAGING (
	  intEntityCustomerId	INT
	, dtmDateFrom			DATETIME
	, dblPastDue			NUMERIC(18, 6) NULL DEFAULT 0
	, dblTotalAR			NUMERIC(18, 6) NULL DEFAULT 0
)

INSERT INTO #CUSTOMERS
SELECT DISTINCT intEntityId
FROM tblARCustomer C
INNER JOIN (
	SELECT DISTINCT intEntityCustomerId
	FROM tblARInvoice I 
	WHERE I.ysnPosted = 1
) I ON C.intEntityId = I.intEntityCustomerId
WHERE C.dblHighestAR IS NULL
  --AND C.intEntityId = 1820

SELECT TOP 1 @dtmDateFrom = I.dtmPostDate
FROM tblARInvoice I
WHERE I.ysnPosted = 1
ORDER BY I.dtmPostDate

;WITH AGINGDATES AS (
	SELECT @dtmDateFrom as dtmDateFrom
	UNION ALL
	SELECT DATEADD(DAY, 1, dtmDateFrom)
	FROM AGINGDATES
	WHERE DATEADD(DAY, 1, dtmDateFrom) <= @dtmDateTo
)
INSERT INTO #AGINGDATES
SELECT intId		= ROW_NUMBER() OVER (ORDER BY dtmDateFrom ASC)
	 , dtmDateFrom	= dtmDateFrom
FROM AGINGDATES
OPTION (MAXRECURSION 0)

SELECT * 
INTO #CUSTOMERDATES
FROM #AGINGDATES D, #CUSTOMERS C

INSERT INTO #FINALAGING WITH (TABLOCK) (
	  intEntityCustomerId
	, dtmDateFrom
	, dblPastDue
	, dblTotalAR
)
SELECT intEntityCustomerId	= I.intEntityCustomerId
	 , dtmDateFrom			= C.dtmDateFrom
     , dblPastDue			= SUM(CASE WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, C.dtmDateFrom) > 0
									   THEN 
											CASE WHEN I.strTransactionType NOT IN ('Credit Memo', 'Customer Prepayment', 'Overpayment') 
												 THEN I.dblInvoiceTotal
												 ELSE -I.dblInvoiceTotal
											END 
									   ELSE 0 
								  END) - SUM(ISNULL(P.dblTotalPayment, 0))
	, dblTotalAR			= SUM(CASE WHEN I.strTransactionType NOT IN ('Credit Memo', 'Customer Prepayment', 'Overpayment') 
									   THEN I.dblInvoiceTotal
									   ELSE -I.dblInvoiceTotal
								  END) - SUM(ISNULL(P.dblTotalPayment, 0))
FROM tblARInvoice I
INNER JOIN #CUSTOMERDATES C ON I.intEntityCustomerId = C.intEntityCustomerId
LEFT JOIN (
	SELECT intInvoiceId
		 , dblTotalPayment = SUM((dblPayment + dblDiscount + dblWriteOffAmount) - dblInterest)
		 , C.intEntityCustomerId
		 , C.dtmDateFrom
	FROM tblARPaymentDetail PD
	INNER JOIN tblARPayment P ON P.intPaymentId = PD.intPaymentId
	INNER JOIN #CUSTOMERDATES C ON P.intEntityCustomerId = C.intEntityCustomerId
	WHERE P.ysnPosted = 1
	  AND P.dtmDatePaid <= C.dtmDateFrom
	  AND P.intEntityCustomerId = C.intEntityCustomerId
	  AND P.strReceivePaymentType <> 'Vendor Refund'
	  AND P.ysnInvoicePrepayment = 0
	GROUP BY PD.intInvoiceId, C.intEntityCustomerId, C.dtmDateFrom
) P ON I.intInvoiceId = P.intInvoiceId
   AND P.intEntityCustomerId = C.intEntityCustomerId
   AND P.dtmDateFrom = C.dtmDateFrom
WHERE I.ysnPosted = 1  
  AND I.strTransactionType <> 'Cash Refund'
  AND I.dtmPostDate <= C.dtmDateFrom
  AND I.intEntityCustomerId = C.intEntityCustomerId
GROUP BY I.intEntityCustomerId, C.dtmDateFrom

UPDATE C
SET dblHighestAR		= A.dblTotalAR
  , dtmHighestARDate	= A.dtmDateFrom
FROM tblARCustomer C
CROSS APPLY (
	SELECT TOP 1 dblTotalAR, dtmDateFrom 
	FROM #FINALAGING
	WHERE dblTotalAR IS NOT NULL 
	  AND dblTotalAR > 0
	  AND intEntityCustomerId = C.intEntityId
	ORDER BY dblTotalAR DESC
) A

UPDATE C
SET dblHighestDueAR		= A.dblPastDue
  , dtmHighestDueARDate	= A.dtmDateFrom
FROM tblARCustomer C
CROSS APPLY (
	SELECT TOP 1 dblPastDue, dtmDateFrom 
	FROM #FINALAGING
	WHERE dblPastDue IS NOT NULL 
	  AND dblPastDue > 0
	  AND intEntityCustomerId = C.intEntityId
	ORDER BY dblPastDue DESC
) A

IF OBJECT_ID('tempdb..#CUSTOMERS') IS NOT NULL DROP TABLE #CUSTOMERS
IF OBJECT_ID('tempdb..#AGINGDATES') IS NOT NULL DROP TABLE #AGINGDATES
IF OBJECT_ID('tempdb..#CUSTOMERDATES') IS NOT NULL DROP TABLE #CUSTOMERDATES
IF OBJECT_ID('tempdb..#FINALAGING') IS NOT NULL DROP TABLE #FINALAGING

print('/*******************  END Update tblARCustomer Highest AR  *******************/')
GO
