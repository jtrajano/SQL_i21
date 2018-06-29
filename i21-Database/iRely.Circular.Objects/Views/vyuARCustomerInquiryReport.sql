CREATE VIEW [dbo].[vyuARCustomerInquiryReport]
AS 
SELECT 
  strCustomerName			= CAR.strCustomerName
, intEntityCustomerId		= CAR.intEntityCustomerId
, dbl0Days					= CAR.dbl0Days
, dbl10Days					= CAR.dbl10Days
, dbl30Days					= CAR.dbl30Days
, dbl60Days					= CAR.dbl60Days
, dbl90Days					= CAR.dbl90Days
, dbl91Days					= CAR.dbl91Days
, dblTotalDue				= CAR.dblTotalDue
, dblAmountPaid				= CAR.dblAmountPaid
, dblInvoiceTotal			= CAR.dblInvoiceTotal
, dblYTDSales				= ISNULL(YTDSALES.dblYTDSales, 0)
, dblYDTServiceCharge       = ISNULL(YTDSERVICECHARGE.dblYDTServiceCharge, 0)
, dblHighestAR				= ISNULL(HIGHESTAR.dblInvoiceTotal, 0)
, dtmHighestARDate			= HIGHESTAR.dtmDate
, dblHighestDueAR			= ISNULL(HIGHESTDUEAR.dblInvoiceTotal, 0)
, dtmHighestDueARDate		= HIGHESTDUEAR.dtmDate
, dblLastYearSales			= ISNULL(LASTYEARSALES.dblLastYearSales, 0)
, dblLastPayment			= ISNULL(PAYMENT.dblAmountPaid, 0)
, dtmLastPaymentDate		= PAYMENT.dtmDatePaid
, dblLastStatement			= ISNULL(LASTSTATEMENT.dblLastStatement, 0)
, dtmLastStatementDate		= LASTSTATEMENT.dtmLastStatementDate
, dtmNextPaymentDate		= CB.dtmBudgetDate
, dblUnappliedCredits		= CAR.dblCredits
, dblPrepaids				= CAR.dblPrepaids + CAR.dblPrepayments
, dblFuture					= CAR.dblFuture
, dblBudgetAmount			= ISNULL(dbo.fnARGetCustomerBudget(CAR.intEntityCustomerId, GETDATE()), 0.000000) 
, dtmBudgetMonth			= BUDGETMONTH.dtmBudgetDate
, dblThru					= 0.000000
, dblPendingInvoice			= ISNULL(PENDINGINVOICE.dblPendingInvoice, 0)
, dblPendingPayment			= ISNULL(PENDINGPAYMENT.dblPendingPayment, 0)
, dblCreditLimit			= CUSTOMER.dblCreditLimit
, dblNextPaymentAmount		= ISNULL(CB.dblBudgetAmount, 0)
, dblAmountPastDue			= ISNULL(BUGETPASTDUE.dblAmountPastDue, 0)
, intRemainingBudgetPeriods	= ISNULL(BUDGETPERIODS.intRemainingBudgetPeriods, 0)
, intAveragePaymentDays     = 0
, strBudgetStatus			= CASE WHEN 1 = 1 THEN 'Past Due' ELSE 'Current' END
, strTerm					= CUSTOMER.strTerm
, strContact				= CUSTOMER.strFullAddress
, strCompanyName			= COMPANY.strCompanyName
, strCompanyAddress			= COMPANY.strCompanyAddress
FROM vyuARCustomerAgingReport CAR
CROSS APPLY (
	SELECT dblCreditLimit
		 , strTerm
		 , strFullAddress = dbo.fnARFormatCustomerAddress(CC.strPhone, CC.strEmail, C.strBillToLocationName, C.strBillToAddress, C.strBillToCity, C.strBillToState, C.strBillToZipCode, C.strBillToCountry, NULL, 0)
	FROM dbo.vyuARCustomerSearch C WITH (NOLOCK)
		LEFT JOIN (SELECT intEntityId
		                , strPhone
						, strEmail
				   FROM dbo.vyuARCustomerContacts WITH (NOLOCK)
				   WHERE ysnDefaultContact = 1
		) CC ON C.intEntityId = CC.intEntityId
	WHERE C.intEntityId = CAR.intEntityCustomerId
) CUSTOMER
OUTER APPLY (
	SELECT TOP 1 dtmBudgetDate 
	FROM dbo.tblARCustomerBudget WITH (NOLOCK)
	WHERE (GETDATE() >= dtmBudgetDate AND GETDATE() < DATEADD(MONTH, 1, dtmBudgetDate)) 
	  AND intEntityCustomerId = CAR.intEntityCustomerId
) BUDGETMONTH
OUTER APPLY (
	SELECT dblAmountPastDue = SUM(dblBudgetAmount) - SUM(dblAmountPaid) 
	FROM dbo.tblARCustomerBudget WITH (NOLOCK)
	WHERE intEntityCustomerId = CAR.intEntityCustomerId 
	  AND dtmBudgetDate < GETDATE()
) BUGETPASTDUE
OUTER APPLY (
	SELECT intRemainingBudgetPeriods = COUNT(*)
	FROM dbo.tblARCustomerBudget WITH (NOLOCK)
	WHERE intEntityCustomerId = CAR.intEntityCustomerId 
	  AND dtmBudgetDate >= GETDATE()
) BUDGETPERIODS
LEFT JOIN (
	SELECT intEntityCustomerId
	     , dtmBudgetDate
		 , dblBudgetAmount
	FROM dbo.tblARCustomerBudget WITH (NOLOCK)
) CB ON CAR.intEntityCustomerId = CB.intEntityCustomerId 
	AND DATEADD(MONTH, 1, GETDATE()) BETWEEN CB.dtmBudgetDate AND DATEADD(MONTH, 1, CB.dtmBudgetDate)
OUTER APPLY (
	SELECT TOP 1 P.intEntityCustomerId
               , P.dblAmountPaid
			   , P.dtmDatePaid 
    FROM dbo.tblARPayment P WITH (NOLOCK)
		INNER JOIN (SELECT intPaymentMethodID
						 , strPaymentMethod 
					FROM dbo.tblSMPaymentMethod WITH (NOLOCK)
		) PM ON P.intPaymentMethodId = PM.intPaymentMethodID
	WHERE P.intEntityCustomerId = CAR.intEntityCustomerId 
		AND P.ysnPosted = 1 
		AND PM.strPaymentMethod != 'CF Invoice'
	ORDER BY P.intPaymentId DESC
) PAYMENT
OUTER APPLY (
	SELECT dblYTDSales = SUM(CASE WHEN strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') 
								  THEN ISNULL(dblInvoiceSubtotal, 0) * -1 
								  ELSE ISNULL(dblInvoiceSubtotal, 0) 
							 END)
	FROM dbo.tblARInvoice WITH (NOLOCK)	
	WHERE ysnPosted = 1
	  AND YEAR(dtmPostDate) = DATEPART(year, GETDATE()) 
	  AND intEntityCustomerId = CAR.intEntityCustomerId
) YTDSALES
OUTER APPLY (
	SELECT dblLastYearSales= SUM(CASE WHEN strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') 
									  THEN ISNULL(dblInvoiceSubtotal, 0) * -1 
									  ELSE ISNULL(dblInvoiceSubtotal, 0) 
								 END)
	FROM dbo.tblARInvoice WITH (NOLOCK)	
	WHERE ysnPosted = 1
	  AND YEAR(dtmPostDate) = DATEPART(year, GETDATE()) - 1
	  AND intEntityCustomerId = CAR.intEntityCustomerId
) LASTYEARSALES
OUTER APPLY (
	SELECT dblPendingInvoice = SUM(CASE WHEN strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(dblInvoiceTotal,0) * -1 ELSE ISNULL(dblInvoiceTotal,0) END) 
	FROM dbo.tblARInvoice WITH (NOLOCK)
	WHERE intEntityCustomerId = CAR.intEntityCustomerId 
	  AND ysnPosted = 0 
	  AND ((strType = 'Service Charge' AND ysnForgiven = 0) OR ((strType <> 'Service Charge' AND ysnForgiven = 1) OR (strType <> 'Service Charge' AND ysnForgiven = 0)))
) PENDINGINVOICE
OUTER APPLY (
	SELECT dblPendingPayment = SUM(ISNULL(dblAmountPaid ,0)) 
	FROM dbo.tblARPayment WITH (NOLOCK)
	WHERE intEntityCustomerId = CAR.intEntityCustomerId 
	  AND ysnPosted = 0
) PENDINGPAYMENT
OUTER APPLY (
	SELECT TOP 1 dblLastStatement
			   , dtmLastStatementDate
	FROM dbo.tblARStatementOfAccount WITH (NOLOCK) 
	WHERE strEntityNo = CAR.strEntityNo
) LASTSTATEMENT
OUTER APPLY (
	SELECT TOP 1 strCompanyName
			   , strCompanyAddress = dbo.fnARFormatCustomerAddress(NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, NULL) 
	FROM dbo.tblSMCompanySetup WITH (NOLOCK)
) COMPANY
OUTER APPLY (
	SELECT TOP 1 dblInvoiceTotal
		       , dtmDate
	FROM dbo.tblARInvoice
	WHERE ysnPosted = 1
	  AND strTransactionType IN ('Invoice', 'Debit Memo')
	  AND strType <> 'CF Tran'
	  AND intEntityCustomerId = CAR.intEntityCustomerId
	ORDER BY dblInvoiceTotal DESC	  
) HIGHESTAR
OUTER APPLY (
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
	AND intEntityCustomerId = CAR.intEntityCustomerId
	AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, ISNULL(PD.dtmDatePaid, GETDATE())) > 0
	ORDER BY DATEDIFF(DAYOFYEAR, I.dtmDueDate, ISNULL(PD.dtmDatePaid, GETDATE())) DESC
) HIGHESTDUEAR
OUTER APPLY (
	SELECT dblYDTServiceCharge = SUM(ISNULL(dblInvoiceTotal, 0))
	FROM dbo.tblARInvoice WITH (NOLOCK)	
	WHERE ysnPosted = 1
	  AND ysnForgiven = 0
	  AND strType = 'Service Charge'	  
	  AND YEAR(dtmPostDate) = DATEPART(year, GETDATE())
	  AND intEntityCustomerId = CAR.intEntityCustomerId
) YTDSERVICECHARGE