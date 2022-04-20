CREATE VIEW [dbo].[vyuARCustomerInquiryReport]
AS 
SELECT strCustomerName				= CUSTOMER.strName
     , intEntityCustomerId			= CUSTOMER.intEntityCustomerId
     , dbl0Days						= ISNULL(AGING.dbl0Days, 0)
     , dbl10Days					= ISNULL(AGING.dbl10Days, 0)
     , dbl30Days					= ISNULL(AGING.dbl30Days, 0)
     , dbl60Days					= ISNULL(AGING.dbl60Days, 0)
     , dbl90Days					= ISNULL(AGING.dbl90Days, 0)
     , dbl91Days					= ISNULL(AGING.dbl91Days, 0)
     , dblTotalDue					= ISNULL(AGING.dblTotalDue, 0)
     , dblAmountPaid				= ISNULL(AGING.dblAmountPaid, 0)
     , dblInvoiceTotal				= ISNULL(AGING.dblInvoiceTotal, 0)
     , dblYTDSales					= ISNULL(YTDSALES.dblYTDSales, 0)
     , dblYDTServiceCharge			= ISNULL(YTDSERVICECHARGE.dblYDTServiceCharge, 0)
     , dblHighestAR					= ISNULL(HIGHESTAR.dblInvoiceTotal, 0)
     , dtmHighestARDate				= HIGHESTAR.dtmDate
     , dblHighestDueAR				= ISNULL(HIGHESTDUEAR.dblInvoiceTotal, 0)
     , dtmHighestDueARDate			= HIGHESTDUEAR.dtmDate
     , dblLastYearSales				= ISNULL(LASTYEARSALES.dblLastYearSales, 0)
     , dblLastPayment				= ISNULL(PAYMENT.dblAmountPaid, 0)
     , dtmLastPaymentDate			= PAYMENT.dtmDatePaid
     , dblLastStatement				= ISNULL(LASTSTATEMENT.dblLastStatement, 0)
     , dtmLastStatementDate			= LASTSTATEMENT.dtmLastStatementDate
     , dtmNextPaymentDate			= CB.dtmBudgetDate
     , dblUnappliedCredits			= ISNULL(AGING.dblCredits, 0)
     , dblPrepaids					= ISNULL(AGING.dblPrepaids, 0) + ISNULL(AGING.dblPrepayments, 0)
     , dblFuture					= ISNULL(AGING.dblFuture, 0)
     , dblBudgetAmount				= CUSTOMER.dblMonthlyBudget
     , dtmBudgetMonth				= BUDGETMONTH.dtmBudgetDate
     , dblThru						= 0.000000
     , dblPendingInvoice			= ISNULL(PENDINGINVOICE.dblPendingInvoice, 0)
     , dblPendingPayment			= ISNULL(PENDINGPAYMENT.dblPendingPayment, 0)
     , dblCreditLimit				= CUSTOMER.dblCreditLimit
     , dblNextPaymentAmount			= ISNULL(CB.dblBudgetAmount, 0)
     , dblAmountPastDue				= ISNULL(BUDGETPASTDUE.dblAmountPastDue, 0)
     , intRemainingBudgetPeriods	= ISNULL(BUDGETPERIODS.intRemainingBudgetPeriods, 0)
     , intAveragePaymentDays		= ISNULL(DAYSTOPAY.intDaysToPay, 0)
     , strBudgetStatus				= CASE WHEN 1 = 1 THEN 'Past Due' ELSE 'Current' END COLLATE Latin1_General_CI_AS
     , strTerm						= CUSTOMER.strTerm
     , strContact					= dbo.fnARFormatCustomerAddress(CONTACT.strPhone, CONTACT.strEmail, CUSTOMER.strBillToLocationName, CUSTOMER.strBillToAddress, CUSTOMER.strBillToCity, CUSTOMER.strBillToState, CUSTOMER.strBillToZipCode, CUSTOMER.strBillToCountry, NULL, 0) COLLATE Latin1_General_CI_AS
     , strCompanyName				= COMPANY.strCompanyName
     , strCompanyAddress			= COMPANY.strCompanyAddress
     , strPhone1 					= CONTACT.strPhone
     , strEmail 					= CONTACT.strEmail
     , strInternalNotes				= CONTACT.strInternalNotes
	 , dblCreditStopDays			= ISNULL(AGING.dblCreditStopDays, 0)
FROM vyuARCustomerSearch CUSTOMER
LEFT JOIN (
	SELECT intEntityCustomerId
		 , dblTotalAR			= SUM(dblTotalDue) - SUM(dblAvailableCredit) - SUM(dblPrepayments)
		 , dblFuture			= SUM(dblFuture)
		 , dbl0Days				= SUM(dbl0Days)
		 , dbl10Days			= SUM(dbl10Days)
		 , dbl30Days			= SUM(dbl30Days)
		 , dbl60Days			= SUM(dbl60Days)
		 , dbl90Days			= SUM(dbl90Days)
		 , dbl91Days			= SUM(dbl91Days)
		 , dblTotalDue			= SUM(dblTotalDue) - SUM(dblAvailableCredit) - SUM(dblPrepayments)
		 , dblAmountPaid		= SUM(dblAmountPaid)
		 , dblInvoiceTotal		= 0.000000
		 , dblCredits			= SUM(dblAvailableCredit) * -1
		 , dblPrepayments		= SUM(dblPrepayments) * -1
		 , dblPrepaids			= 0.000000
		 , dblCreditStopDays	= SUM(dblCreditStopDays)
	FROM vyuARCustomerAgingSubview
	GROUP BY intEntityCustomerId
) AGING ON CUSTOMER.intEntityCustomerId = AGING.intEntityCustomerId
LEFT JOIN (
	SELECT intEntityId
		 , strPhone
		 , strEmail
		 , strInternalNotes
	FROM dbo.vyuARCustomerContacts WITH (NOLOCK)
	WHERE ysnDefaultContact = 1
) CONTACT ON CUSTOMER.intEntityId = CONTACT.intEntityId
LEFT JOIN (
	SELECT dtmBudgetDate		= MIN(dtmBudgetDate)
		 , intEntityCustomerId
	FROM dbo.tblARCustomerBudget WITH (NOLOCK)
	WHERE (GETDATE() >= dtmBudgetDate AND GETDATE() < DATEADD(MONTH, 1, dtmBudgetDate)) 
	GROUP BY intEntityCustomerId
) BUDGETMONTH ON BUDGETMONTH.intEntityCustomerId = CUSTOMER.intEntityCustomerId
LEFT JOIN (
	SELECT dblAmountPastDue = SUM(dblBudgetAmount) - SUM(dblAmountPaid) 
		 , intEntityCustomerId
	FROM dbo.tblARCustomerBudget WITH (NOLOCK)
	WHERE dtmBudgetDate < GETDATE()
	GROUP BY intEntityCustomerId
) BUDGETPASTDUE ON BUDGETPASTDUE.intEntityCustomerId = CUSTOMER.intEntityCustomerId
LEFT JOIN (
	SELECT intRemainingBudgetPeriods = COUNT(*)
		 , intEntityCustomerId
	FROM dbo.tblARCustomerBudget WITH (NOLOCK)
	WHERE dtmBudgetDate >= GETDATE()
	GROUP BY intEntityCustomerId
) BUDGETPERIODS ON BUDGETPERIODS.intEntityCustomerId = CUSTOMER.intEntityCustomerId
LEFT JOIN (
	SELECT intEntityCustomerId
	     , dtmBudgetDate
		 , dblBudgetAmount
	FROM dbo.tblARCustomerBudget WITH (NOLOCK)
) CB ON CUSTOMER.intEntityCustomerId = CB.intEntityCustomerId 
	AND DATEADD(MONTH, 1, GETDATE()) BETWEEN CB.dtmBudgetDate AND DATEADD(MONTH, 1, CB.dtmBudgetDate)
LEFT JOIN (
	SELECT dblAmountPaid		= MAX(dblAmountPaid)
		 , dtmDatePaid			= MAX(dtmDatePaid)
		 , intEntityCustomerId
	FROM (
		SELECT dblAmountPaid		
			 , dtmDatePaid				
			 , intEntityCustomerId
			 , intRowNumber			=  ROW_NUMBER() OVER(PARTITION BY intEntityCustomerId ORDER BY intPaymentId DESC) 
		FROM dbo.tblARPayment P WITH (NOLOCK)
		WHERE P.ysnPosted = 1
		  AND ISNULL(P.strPaymentInfo, '') != 'CF Invoice'		
	) I 
	WHERE I.intRowNumber = 1
	GROUP BY intEntityCustomerId
) PAYMENT ON PAYMENT.intEntityCustomerId = CUSTOMER.intEntityCustomerId
LEFT JOIN (
	SELECT dblYTDSales = SUM(CASE WHEN strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') 
								  THEN ISNULL(dblInvoiceSubtotal, 0) * -1 
								  ELSE ISNULL(dblInvoiceSubtotal, 0) 
							 END)
		 , intEntityCustomerId
	FROM dbo.tblARInvoice WITH (NOLOCK)	
	WHERE ysnPosted = 1
	  AND YEAR(dtmPostDate) = DATEPART(year, GETDATE())
	GROUP BY intEntityCustomerId
) YTDSALES ON YTDSALES.intEntityCustomerId = CUSTOMER.intEntityCustomerId
LEFT JOIN (
	SELECT dblLastYearSales= SUM(CASE WHEN strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') 
									  THEN ISNULL(dblInvoiceSubtotal, 0) * -1 
									  ELSE ISNULL(dblInvoiceSubtotal, 0) 
								 END)
		 , intEntityCustomerId
	FROM dbo.tblARInvoice WITH (NOLOCK)	
	WHERE ysnPosted = 1
	  AND YEAR(dtmPostDate) = DATEPART(year, GETDATE()) - 1
	GROUP BY intEntityCustomerId
) LASTYEARSALES ON LASTYEARSALES.intEntityCustomerId = CUSTOMER.intEntityCustomerId
LEFT JOIN (
	SELECT dblPendingInvoice = SUM(CASE WHEN strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(dblInvoiceTotal,0) * -1 ELSE ISNULL(dblInvoiceTotal,0) END) 
		 , intEntityCustomerId
	FROM dbo.tblARInvoice WITH (NOLOCK)
	WHERE ysnPosted = 0 
	  AND ((strType = 'Service Charge' AND ysnForgiven = 0) OR ((strType <> 'Service Charge' AND ysnForgiven = 1) OR (strType <> 'Service Charge' AND ysnForgiven = 0)))
	GROUP BY intEntityCustomerId
) PENDINGINVOICE ON PENDINGINVOICE.intEntityCustomerId = CUSTOMER.intEntityCustomerId 
LEFT JOIN (
	SELECT dblPendingPayment = SUM(ISNULL(dblAmountPaid ,0)) 
		 , intEntityCustomerId
	FROM dbo.tblARPayment WITH (NOLOCK)
	WHERE ysnPosted = 0
	GROUP BY intEntityCustomerId
) PENDINGPAYMENT ON PENDINGPAYMENT.intEntityCustomerId = CUSTOMER.intEntityCustomerId
LEFT JOIN (
	SELECT dblLastStatement
	     , dtmLastStatementDate
		 , strEntityNo
	FROM dbo.tblARStatementOfAccount WITH (NOLOCK) 	
) LASTSTATEMENT ON LASTSTATEMENT.strEntityNo = CUSTOMER.strCustomerNumber
OUTER APPLY (
	SELECT TOP 1 strCompanyName
			   , strCompanyAddress = dbo.fnARFormatCustomerAddress(NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, NULL) COLLATE Latin1_General_CI_AS
	FROM dbo.tblSMCompanySetup WITH (NOLOCK)
) COMPANY
LEFT JOIN (
	SELECT dblInvoiceTotal		= MAX(dblInvoiceTotal)
		 , dtmDate				= MAX(dtmDate)
		 , intEntityCustomerId
	FROM (
		SELECT dblInvoiceTotal		
			 , dtmDate				
			 , intEntityCustomerId
			 , intRowNumber			=  ROW_NUMBER() OVER(PARTITION BY intEntityCustomerId ORDER BY dblInvoiceTotal DESC) 
		FROM dbo.tblARInvoice
		WHERE ysnPosted = 1
			AND strTransactionType IN ('Invoice', 'Debit Memo')
			AND strType <> 'CF Tran'
	) I 
	WHERE I.intRowNumber = 1
	GROUP BY intEntityCustomerId	  
) HIGHESTAR ON HIGHESTAR.intEntityCustomerId = CUSTOMER.intEntityCustomerId
LEFT JOIN (
	SELECT dblInvoiceTotal		= MAX(dblInvoiceTotal)
		 , dtmDate				= MAX(dtmDate)
		 , intEntityCustomerId
	FROM (
		SELECT dblInvoiceTotal		
			 , dtmDate				
			 , intEntityCustomerId
			 , intRowNumber			=  ROW_NUMBER() OVER(PARTITION BY intEntityCustomerId ORDER BY DATEDIFF(DAYOFYEAR, I.dtmDueDate, ISNULL(PD.dtmDatePaid, GETDATE())) DESC) 
		FROM dbo.tblARInvoice I WITH (NOLOCK)
		LEFT JOIN (
			SELECT intInvoiceId
				 , dtmDatePaid = MAX(P.dtmDatePaid)
			FROM dbo.tblARPaymentDetail PD WITH (NOLOCK)
			INNER JOIN (
				SELECT intPaymentId
					 , dtmDatePaid
				FROM dbo.tblARPayment P WITH (NOLOCK)
			) P ON P.intPaymentId = PD.intPaymentId 
			GROUP BY intInvoiceId
		) PD ON PD.intInvoiceId = I.intInvoiceId
		WHERE I.ysnPosted = 1
		  AND I.strTransactionType IN ('Invoice', 'Debit Memo')
		  AND I.strType <> 'CF Tran'
		  AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, ISNULL(PD.dtmDatePaid, GETDATE())) > 0
	) I 
	WHERE I.intRowNumber = 1
	GROUP BY intEntityCustomerId
) HIGHESTDUEAR ON HIGHESTDUEAR.intEntityCustomerId = CUSTOMER.intEntityCustomerId
LEFT JOIN (
	SELECT dblYDTServiceCharge = SUM(ISNULL(dblInvoiceTotal, 0))
		 , intEntityCustomerId
	FROM dbo.tblARInvoice WITH (NOLOCK)	
	WHERE ysnPosted = 1
	  AND ysnForgiven = 0
	  AND strType = 'Service Charge'	  
	  AND YEAR(dtmPostDate) = DATEPART(year, GETDATE())
	GROUP BY intEntityCustomerId
) YTDSERVICECHARGE ON CUSTOMER.intEntityCustomerId = YTDSERVICECHARGE.intEntityCustomerId
LEFT JOIN (
	SELECT intEntityCustomerId	= I.intEntityCustomerId
		 , intDaysToPay = AVG(CASE WHEN I.ysnPaid = 0 OR I.strTransactionType IN ('Cash') THEN 0 
								   ELSE DATEDIFF(DAYOFYEAR, I.dtmDate, CAST(FULLPAY.dtmDatePaid AS DATE))
						      END)
	FROM tblARInvoice I
	CROSS APPLY (
		SELECT TOP 1 P.dtmDatePaid
		FROM tblARPaymentDetail PD
		INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId
		WHERE PD.intInvoiceId = I.intInvoiceId
		AND P.ysnPosted = 1
		AND P.ysnInvoicePrepayment = 0
		ORDER BY P.dtmDatePaid DESC
	) FULLPAY
	WHERE I.ysnPosted = 1
	  AND I.ysnPaid = 1
	GROUP BY I.intEntityCustomerId
) DAYSTOPAY ON DAYSTOPAY.intEntityCustomerId = CUSTOMER.intEntityCustomerId