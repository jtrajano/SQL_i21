﻿CREATE VIEW [dbo].[vyuARCustomerInquiryReport]
AS 
SELECT 
  CAR.strCustomerName
, CAR.intEntityCustomerId
, CAR.dbl0Days
, CAR.dbl10Days
, CAR.dbl30Days
, CAR.dbl60Days
, CAR.dbl90Days
, CAR.dbl91Days
, CAR.dblTotalDue
, CAR.dblAmountPaid
, CAR.dblInvoiceTotal
, dblYTDSales				= (SELECT ISNULL(SUM(CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo') THEN ISNULL(I.dblInvoiceSubtotal, 0) * -1 ELSE ISNULL(I.dblInvoiceSubtotal, 0) END), 0.000000)
								FROM tblARInvoice I	WHERE I.ysnPosted = 1 AND YEAR(I.dtmPostDate) =  DATEPART(year, GETDATE()) AND I.intEntityCustomerId = CAR.intEntityCustomerId)
, dblLastYearSales			= (SELECT ISNULL(SUM(CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo') THEN ISNULL(I.dblInvoiceSubtotal, 0) * -1 ELSE ISNULL(I.dblInvoiceSubtotal, 0) END), 0.000000)
								FROM tblARInvoice I WHERE I.ysnPosted = 1 AND YEAR(I.dtmPostDate) =  DATEPART(year, GETDATE()) - 1 AND I.intEntityCustomerId = CAR.intEntityCustomerId)
, dblLastPayment			= ISNULL((SELECT TOP 1 ISNULL(dblAmountPaid, 0) FROM tblARPayment WHERE intEntityCustomerId = CAR.intEntityCustomerId AND ysnPosted = 1 ORDER BY dtmDatePaid DESC, intPaymentId DESC), 0)
, dtmLastPaymentDate		= (SELECT TOP 1 dtmDatePaid FROM tblARPayment WHERE intEntityCustomerId = CAR.intEntityCustomerId AND ysnPosted = 1 ORDER BY dtmDatePaid DESC, intPaymentId DESC)
, dblLastStatement			= (SELECT TOP 1 [dblLastStatement] FROM [tblARStatementOfAccount] WHERE strEntityNo = CAR.strEntityNo)
, dtmLastStatementDate		= (SELECT TOP 1 [dtmLastStatementDate] FROM [tblARStatementOfAccount] WHERE strEntityNo = CAR.strEntityNo)
, dtmNextPaymentDate		= CB.dtmBudgetDate
, dblUnappliedCredits		= CAR.dblCredits
, dblPrepaids				= CAR.dblPrepaids
, dblFuture					= CAR.dblFuture
, dblBudgetAmount			= ISNULL(dbo.fnARGetCustomerBudget(CAR.intEntityCustomerId, GETDATE()), 0.000000) 
, dblBudgetMonth			= ISNULL((SELECT dblMonthlyBudget FROM tblARCustomer WHERE intEntityCustomerId = CAR.intEntityCustomerId), 0.000000)
, dblThru					= 0.000000
, dblPendingInvoice			= (SELECT ISNULL(SUM(CASE WHEN strTransactionType NOT IN ('Invoice', 'Debit Memo') THEN ISNULL(dblInvoiceTotal,0) * -1 ELSE ISNULL(dblInvoiceTotal,0) END), 0) FROM tblARInvoice WHERE intEntityCustomerId = CAR.intEntityCustomerId AND ysnPosted = 0)
, dblPendingPayment			= (SELECT ISNULL(SUM(ISNULL(dblAmountPaid ,0)), 0) FROM tblARPayment WHERE intEntityCustomerId = CAR.intEntityCustomerId AND ysnPosted = 0)
, dblCreditLimit			= (SELECT dblCreditLimit FROM tblARCustomer WHERE intEntityCustomerId = CAR.intEntityCustomerId)
, dblNextPaymentAmount		= ISNULL(CB.dblBudgetAmount, 0.000000)
, dblAmountPastDue			= (SELECT ISNULL(SUM(dblBudgetAmount),0.000000) FROM tblARCustomerBudget WHERE intEntityCustomerId = CAR.intEntityCustomerId AND dtmBudgetDate < GETDATE())
, intRemainingBudgetPeriods	= (SELECT ISNULL(COUNT(*), 0) FROM tblARCustomerBudget WHERE intEntityCustomerId = CAR.intEntityCustomerId AND dtmBudgetDate >= GETDATE())
, strBudgetStatus			= CASE WHEN 1 = 1 THEN 'Past Due' ELSE 'Current' END
, strTerm					= (SELECT TOP 1 strTerm FROM vyuARCustomer C INNER JOIN tblSMTerm T ON C.intTermsId = T.intTermID WHERE intEntityCustomerId = CAR.intEntityCustomerId)
, strContact				= (SELECT strFullAddress = [dbo].fnARFormatCustomerAddress(CC.strPhone, CC.strEmail, C.strBillToLocationName, C.strBillToAddress, C.strBillToCity, C.strBillToState, C.strBillToZipCode, C.strBillToCountry, NULL, 0)
									FROM vyuARCustomer C INNER JOIN vyuARCustomerContacts CC ON C.intEntityCustomerId = CC.intEntityCustomerId AND ysnDefaultContact = 1 WHERE C.intEntityCustomerId = CAR.intEntityCustomerId)
, strCompanyName			= (SELECT TOP 1 strCompanyName FROM tblSMCompanySetup)
, strCompanyAddress			= (SELECT TOP 1 dbo.[fnARFormatCustomerAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, NULL) FROM tblSMCompanySetup)
FROM vyuARCustomerAgingReport CAR
LEFT JOIN tblARCustomerBudget CB 
	ON CAR.intEntityCustomerId = CB.intEntityCustomerId 
	AND DATEADD(MONTH, 1, GETDATE()) BETWEEN CB.dtmBudgetDate AND DATEADD(MONTH, 1, CB.dtmBudgetDate)



	