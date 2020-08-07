CREATE PROCEDURE [dbo].[uspARCustomerInquiryReport]
	  @intEntityCustomerId	INT	= NULL
	, @intEntityUserId		INT = NULL
	, @dtmDate				DATE = NULL
AS

IF(OBJECT_ID('tempdb..#CUSTOMERINQUIRY') IS NOT NULL)
BEGIN
    DROP TABLE #CUSTOMERINQUIRY
END

CREATE TABLE #CUSTOMERINQUIRY (
	  intEntityCustomerId			INT	NOT NULL
	, intEntityId					INT NULL
	, intTermsId					INT NULL
	, strCustomerName				NVARCHAR(300)   COLLATE Latin1_General_CI_AS    NULL
	, strTerm						NVARCHAR(100)   COLLATE Latin1_General_CI_AS    NULL
	, strCustomerNumber				NVARCHAR(100)   COLLATE Latin1_General_CI_AS    NULL
	, strAddress					NVARCHAR(MAX)   COLLATE Latin1_General_CI_AS    NULL
	, strZipCode					NVARCHAR(500)   COLLATE Latin1_General_CI_AS    NULL
	, strCity						NVARCHAR(500)   COLLATE Latin1_General_CI_AS    NULL
	, strState						NVARCHAR(500)   COLLATE Latin1_General_CI_AS    NULL
	, strCountry					NVARCHAR(500)   COLLATE Latin1_General_CI_AS    NULL
	, strEmail						NVARCHAR(500)   COLLATE Latin1_General_CI_AS    NULL
	, strPhone1						NVARCHAR(500)   COLLATE Latin1_General_CI_AS    NULL
	, strPhone2						NVARCHAR(500)   COLLATE Latin1_General_CI_AS    NULL
	, strBusinessLocation			NVARCHAR(500)   COLLATE Latin1_General_CI_AS    NULL
	, strInternalNotes				NVARCHAR(500)   COLLATE Latin1_General_CI_AS    NULL
	, strBudgetStatus				NVARCHAR(500)   COLLATE Latin1_General_CI_AS    NULL
	, strBillToAddress				NVARCHAR(500)   COLLATE Latin1_General_CI_AS    NULL
	, strBillToCity					NVARCHAR(500)   COLLATE Latin1_General_CI_AS    NULL
	, strBillToState				NVARCHAR(500)   COLLATE Latin1_General_CI_AS    NULL
	, strBillToZipCode				NVARCHAR(500)   COLLATE Latin1_General_CI_AS    NULL
	, dblYTDSales					NUMERIC(18, 6) NULL
	, dblYDTServiceCharge			NUMERIC(18, 6) NULL
	, dblHighestAR					NUMERIC(18, 6) NULL
	, dblHighestDueAR				NUMERIC(18, 6) NULL
	, dblLastPayment				NUMERIC(18, 6) NULL
	, dblLastYearSales				NUMERIC(18, 6) NULL
	, dblLastStatement				NUMERIC(18, 6) NULL
	, dblPendingInvoice				NUMERIC(18, 6) NULL
	, dblPendingPayment				NUMERIC(18, 6) NULL
	, dblCreditLimit				NUMERIC(18, 6) NULL
	, dblFuture						NUMERIC(18, 6) NULL
	, dbl0Days						NUMERIC(18, 6) NULL
	, dbl10Days						NUMERIC(18, 6) NULL
	, dbl30Days						NUMERIC(18, 6) NULL
	, dbl60Days						NUMERIC(18, 6) NULL
	, dbl90Days						NUMERIC(18, 6) NULL
	, dbl91Days						NUMERIC(18, 6) NULL
	, dblUnappliedCredits			NUMERIC(18, 6) NULL
	, dblPrepaids					NUMERIC(18, 6) NULL
	, dblTotalDue					NUMERIC(18, 6) NULL
	, dblBudgetAmount				NUMERIC(18, 6) NULL
	, dblThru						NUMERIC(18, 6) NULL
	, dblNextPaymentAmount			NUMERIC(18, 6) NULL
	, dblAmountPastDue				NUMERIC(18, 6) NULL
	, dbl31DaysAmountDue			NUMERIC(18, 6) NULL
	, intRemainingBudgetPeriods		INT NULL
	, intAveragePaymentDays			INT NULL
	, dtmNextPaymentDate			DATETIME NULL
	, dtmLastPaymentDate			DATETIME NULL
	, dtmLastStatementDate			DATETIME NULL
	, dtmBudgetMonth				DATETIME NULL
	, dtmHighestARDate				DATETIME NULL
	, dtmHighestDueARDate			DATETIME NULL
)

DECLARE @strCustomerIds NVARCHAR(100) = NULL

SET @intEntityCustomerId = NULLIF(@intEntityCustomerId, 0)
SET @intEntityUserId 	 = ISNULL(@intEntityUserId, 1)

IF @intEntityCustomerId IS NOT NULL
	SET @strCustomerIds = CAST(@intEntityCustomerId AS NVARCHAR(100))

IF @intEntityUserId IS NULL
	SELECT TOP 1 @intEntityUserId = ISNULL(@intEntityUserId, 1)

SET @dtmDate = ISNULL(CAST(@dtmDate AS DATE), CAST(GETDATE() AS DATE))

EXEC dbo.uspARCustomerAgingAsOfDateReport @intEntityUserId			= @intEntityUserId
										, @strCustomerIds			= @strCustomerIds
										, @dtmDateTo				= @dtmDate

INSERT INTO #CUSTOMERINQUIRY (
	   intEntityCustomerId
     , intEntityId
	 , intTermsId
	 , strCustomerName
	 , strTerm
	 , strCustomerNumber
	 , strAddress
	 , strZipCode
	 , strCity
	 , strState
	 , strCountry
	 , strEmail
	 , strPhone1
	 , strPhone2
	 , strBusinessLocation
	 , strInternalNotes
	 , strBudgetStatus
	 , strBillToAddress
	 , strBillToCity
	 , strBillToState
	 , strBillToZipCode
	 , dblYTDSales
	 , dblYDTServiceCharge
	 , dblLastYearSales
	 , dblLastStatement
	 , dblPendingInvoice
	 , dblPendingPayment
	 , dblCreditLimit
	 , dblFuture
	 , dbl0Days
	 , dbl10Days
	 , dbl30Days
	 , dbl60Days
	 , dbl90Days
	 , dbl91Days
	 , dblUnappliedCredits
	 , dblPrepaids
	 , dblTotalDue
	 , dblBudgetAmount
	 , dblThru
	 , dblNextPaymentAmount
	 , dblAmountPastDue
	 , dbl31DaysAmountDue
	 , intRemainingBudgetPeriods
	 , intAveragePaymentDays
	 , dtmNextPaymentDate
	 , dtmLastStatementDate
	 , dtmBudgetMonth
)
SELECT intEntityCustomerId          = CUSTOMER.intEntityId
     , intEntityId					= CUSTOMER.intEntityId
	 , intTermsId					= ISNULL(CUSTOMER.intTermsId, 0)
	 , strCustomerName				= CUSTOMER.strName
	 , strTerm						= CUSTOMER.strTerm
	 , strCustomerNumber			= CUSTOMER.strCustomerNumber
	 , strAddress					= CUSTOMER.strAddress
	 , strZipCode					= CUSTOMER.strZipCode
	 , strCity						= CUSTOMER.strCity
	 , strState						= CUSTOMER.strState
	 , strCountry					= CUSTOMER.strCountry
	 , strEmail						= CUSTOMER.strEmail
	 , strPhone1					= CUSTOMER.strPhone1
	 , strPhone2					= CUSTOMER.strPhone2
	 , strBusinessLocation			= CUSTOMER.strLocationName
	 , strInternalNotes				= CUSTOMER.strInternalNotes
	 , strBudgetStatus				= 'Past Due'
	 , strBillToAddress				= CUSTOMER.strBillToAddress
	 , strBillToCity				= CUSTOMER.strBillToCity
	 , strBillToState				= CUSTOMER.strBillToState
	 , strBillToZipCode				= CUSTOMER.strBillToZipCode
	 , dblYTDSales					= ISNULL(YTDSALES.dblYTDSales, CONVERT(NUMERIC(18,6), 0))
	 , dblYDTServiceCharge			= ISNULL(YTDSERVICECHARGE.dblYDTServiceCharge, CONVERT(NUMERIC(18,6), 0))	 
	 , dblLastYearSales				= ISNULL(LASTYEARSALES.dblLastYearSales, CONVERT(NUMERIC(18,6), 0))
	 , dblLastStatement				= ISNULL(SOA.dblLastStatement, CONVERT(NUMERIC(18,6), 0))
	 , dblPendingInvoice			= ISNULL(PENDINGINVOICE.dblPendingInvoice, CONVERT(NUMERIC(18,6), 0))
	 , dblPendingPayment			= ISNULL(PENDINGPAYMENT.dblPendingPayment, CONVERT(NUMERIC(18,6), 0))
	 , dblCreditLimit				= ISNULL(CUSTOMER.dblCreditLimit, CONVERT(NUMERIC(18,6), 0))
	 , dblFuture					= ISNULL(AGING.dblFuture, CONVERT(NUMERIC(18,6), 0))
	 , dbl0Days						= ISNULL(AGING.dbl0Days, CONVERT(NUMERIC(18,6), 0))
	 , dbl10Days					= ISNULL(AGING.dbl10Days, CONVERT(NUMERIC(18,6), 0))
	 , dbl30Days					= ISNULL(AGING.dbl30Days, CONVERT(NUMERIC(18,6), 0))
	 , dbl60Days					= ISNULL(AGING.dbl60Days, CONVERT(NUMERIC(18,6), 0))
	 , dbl90Days					= ISNULL(AGING.dbl90Days, CONVERT(NUMERIC(18,6), 0))
	 , dbl91Days					= ISNULL(AGING.dbl91Days, CONVERT(NUMERIC(18,6), 0))
	 , dblUnappliedCredits			= ISNULL(AGING.dblCredits, 0)
	 , dblPrepaids					= ISNULL(AGING.dblPrepaids, 0)
	 , dblTotalDue					= ISNULL(AGING.dblTotalDue, CONVERT(NUMERIC(18,6), 0))
	 , dblBudgetAmount				= ISNULL(CUSTOMER.dblMonthlyBudget, CONVERT(NUMERIC(18,6), 0))	 
	 , dblThru						= 0
	 , dblNextPaymentAmount			= ISNULL(BUDGET.dblBudgetAmount, CONVERT(NUMERIC(18,6), 0))
	 , dblAmountPastDue				= ISNULL(BUDGETPASTDUE.dblAmountPastDue, CONVERT(NUMERIC(18,6), 0))
	 , dbl31DaysAmountDue			= ISNULL(AGING.dbl60Days, CONVERT(NUMERIC(18,6), 0)) + ISNULL(AGING.dbl90Days, CONVERT(NUMERIC(18,6), 0)) + ISNULL(AGING.dbl91Days, CONVERT(NUMERIC(18,6), 0))
	 , intRemainingBudgetPeriods	= ISNULL(BUDGETPERIODS.intRemainingBudgetPeriods, CONVERT(NUMERIC(18,6), 0))
	 , intAveragePaymentDays		= 0
	 , dtmNextPaymentDate			= BUDGETMONTH.dtmBudgetDate	 
	 , dtmLastStatementDate			= SOA.dtmLastStatementDate
	 , dtmBudgetMonth				= BUDGETMONTH.dtmBudgetDate	 
FROM vyuARCustomerSearch CUSTOMER
LEFT JOIN tblARCustomerAgingStagingTable AGING ON CUSTOMER.intEntityCustomerId = AGING.intEntityCustomerId AND AGING.intEntityUserId = @intEntityUserId AND AGING.strAgingType = 'Summary'
LEFT JOIN tblARStatementOfAccount SOA ON SOA.strEntityNo = CUSTOMER.strCustomerNumber
LEFT JOIN (
	SELECT intEntityCustomerId
		 , dtmBudgetDate		= MAX(dtmBudgetDate)
	FROM dbo.tblARCustomerBudget WITH (NOLOCK)
	WHERE (@dtmDate >= dtmBudgetDate AND @dtmDate < DATEADD(MONTH, 1, dtmBudgetDate)) 
	GROUP BY intEntityCustomerId
) BUDGETMONTH ON CUSTOMER.intEntityCustomerId = BUDGETMONTH.intEntityCustomerId
LEFT JOIN (
	SELECT intEntityCustomerId
		 , dblAmountPastDue		= SUM(dblBudgetAmount) - SUM(dblAmountPaid) 
	FROM dbo.tblARCustomerBudget WITH (NOLOCK)
	WHERE dtmBudgetDate < @dtmDate
	GROUP BY intEntityCustomerId
) BUDGETPASTDUE ON CUSTOMER.intEntityCustomerId = BUDGETPASTDUE.intEntityCustomerId
LEFT JOIN (
	SELECT intEntityCustomerId
	     , dtmBudgetDate
		 , dblBudgetAmount
	FROM dbo.tblARCustomerBudget WITH (NOLOCK)
	WHERE DATEADD(MONTH, 1, @dtmDate) BETWEEN dtmBudgetDate AND DATEADD(MONTH, 1, dtmBudgetDate)
) BUDGET ON CUSTOMER.intEntityCustomerId = BUDGET.intEntityCustomerId 
LEFT JOIN (
	SELECT intEntityCustomerId
		 , intRemainingBudgetPeriods = COUNT(*)
	FROM dbo.tblARCustomerBudget WITH (NOLOCK)
	WHERE dtmBudgetDate >= @dtmDate
	GROUP BY intEntityCustomerId
) BUDGETPERIODS ON CUSTOMER.intEntityCustomerId = BUDGETPERIODS.intEntityCustomerId
LEFT JOIN (
	SELECT intEntityCustomerId
		 , dblYTDSales = SUM(CASE WHEN strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') 
								  THEN ISNULL(dblInvoiceSubtotal, 0) * -1 
								  ELSE ISNULL(dblInvoiceSubtotal, 0) 
							 END)
	FROM dbo.tblARInvoice WITH (NOLOCK)	
	WHERE ysnPosted = 1
	  AND YEAR(dtmPostDate) = DATEPART(year, @dtmDate) 
	GROUP BY intEntityCustomerId
) YTDSALES ON CUSTOMER.intEntityCustomerId = YTDSALES.intEntityCustomerId
LEFT JOIN (
	SELECT intEntityCustomerId
		 , dblLastYearSales= SUM(CASE WHEN strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') 
									  THEN ISNULL(dblInvoiceSubtotal, 0) * -1 
									  ELSE ISNULL(dblInvoiceSubtotal, 0) 
								 END)
	FROM dbo.tblARInvoice WITH (NOLOCK)	
	WHERE ysnPosted = 1
	  AND YEAR(dtmPostDate) = DATEPART(year, @dtmDate) - 1
	GROUP BY intEntityCustomerId
) LASTYEARSALES ON CUSTOMER.intEntityCustomerId = LASTYEARSALES.intEntityCustomerId
LEFT JOIN (
	SELECT intEntityCustomerId
		 , dblPendingInvoice = SUM(CASE WHEN strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(dblInvoiceTotal,0) * -1 ELSE ISNULL(dblInvoiceTotal,0) END) 
	FROM dbo.tblARInvoice WITH (NOLOCK)
	WHERE ysnPosted = 0 
	  AND ((strType = 'Service Charge' AND ysnForgiven = 0) OR ((strType <> 'Service Charge' AND ysnForgiven = 1) OR (strType <> 'Service Charge' AND ysnForgiven = 0)))
	GROUP BY intEntityCustomerId
) PENDINGINVOICE ON CUSTOMER.intEntityCustomerId = PENDINGINVOICE.intEntityCustomerId
LEFT JOIN (
	SELECT intEntityCustomerId
		 , dblPendingPayment = SUM(ISNULL(dblAmountPaid ,0)) 
	FROM dbo.tblARPayment WITH (NOLOCK)
	WHERE ysnPosted = 0
	GROUP BY intEntityCustomerId
) PENDINGPAYMENT ON CUSTOMER.intEntityCustomerId = PENDINGPAYMENT.intEntityCustomerId 
LEFT JOIN (
	SELECT intEntityCustomerId
		 , dblYDTServiceCharge = SUM(ISNULL(dblInvoiceTotal, 0))
	FROM dbo.tblARInvoice WITH (NOLOCK)	
	WHERE ysnPosted = 1
	  AND ysnForgiven = 0
	  AND strType = 'Service Charge'	  
	  AND YEAR(dtmPostDate) = DATEPART(YEAR, @dtmDate)
	  GROUP BY intEntityCustomerId
) YTDSERVICECHARGE ON YTDSERVICECHARGE.intEntityCustomerId = PENDINGPAYMENT.intEntityCustomerId 
WHERE @intEntityCustomerId IS NULL OR CUSTOMER.intEntityCustomerId = @intEntityCustomerId

UPDATE CI
SET dblHighestAR		= ISNULL(HIGHESTAR.dblInvoiceTotal, 0)
  , dtmHighestARDate	= HIGHESTAR.dtmDate
FROM #CUSTOMERINQUIRY CI
CROSS APPLY (
	SELECT TOP 1 dblInvoiceTotal
		       , dtmDate
	FROM dbo.tblARInvoice
	WHERE ysnPosted = 1
	  AND strTransactionType IN ('Invoice', 'Debit Memo')
	  AND strType <> 'CF Tran'
	  AND intEntityCustomerId = CI.intEntityCustomerId
	ORDER BY dblInvoiceTotal DESC	  
) HIGHESTAR

UPDATE CI
SET dblLastPayment		= ISNULL(PAYMENT.dblAmountPaid, 0)
  , dtmLastPaymentDate	= PAYMENT.dtmDatePaid
FROM #CUSTOMERINQUIRY CI
CROSS APPLY (
	SELECT TOP 1 P.dblAmountPaid
			   , P.dtmDatePaid 
    FROM dbo.tblARPayment P WITH (NOLOCK)
		INNER JOIN (SELECT intPaymentMethodID
						 , strPaymentMethod 
					FROM dbo.tblSMPaymentMethod WITH (NOLOCK)
		) PM ON P.intPaymentMethodId = PM.intPaymentMethodID
	WHERE P.intEntityCustomerId = CI.intEntityCustomerId 
		AND P.ysnPosted = 1 
		AND PM.strPaymentMethod != 'CF Invoice'
	ORDER BY P.intPaymentId DESC
) PAYMENT

UPDATE CI
SET dblHighestDueAR		= ISNULL(HIGHESTDUEAR.dblInvoiceTotal, 0)
  , dtmHighestDueARDate	= HIGHESTDUEAR.dtmDate
FROM #CUSTOMERINQUIRY CI
CROSS APPLY (
	SELECT TOP 1 I.dblInvoiceTotal
			   , I.dtmDate
	FROM dbo.tblARInvoice I WITH (NOLOCK)
		LEFT JOIN (SELECT intInvoiceId
						 , dtmDatePaid = MAX(P.dtmDatePaid)
					FROM dbo.tblARPaymentDetail PD WITH (NOLOCK)
						INNER JOIN (SELECT intPaymentId
										 , dtmDatePaid
									FROM dbo.tblARPayment P WITH (NOLOCK)
						) P ON P.intPaymentId = PD.intPaymentId 
					GROUP BY intInvoiceId
		) PD ON PD.intInvoiceId = I.intInvoiceId
	WHERE ysnPosted = 1
	AND strTransactionType IN ('Invoice', 'Debit Memo')
	AND strType <> 'CF Tran'
	AND intEntityCustomerId = CI.intEntityCustomerId
	AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, ISNULL(PD.dtmDatePaid, @dtmDate)) > 0
	ORDER BY DATEDIFF(DAYOFYEAR, I.dtmDueDate, ISNULL(PD.dtmDatePaid, @dtmDate)) DESC
) HIGHESTDUEAR

UPDATE #CUSTOMERINQUIRY
SET dblHighestDueAR = ISNULL(dblHighestDueAR, 0)
  , dblLastPayment = ISNULL(dblLastPayment, 0)
  , dblHighestAR = ISNULL(dblHighestAR, 0)

SELECT * FROM #CUSTOMERINQUIRY