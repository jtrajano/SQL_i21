CREATE VIEW [dbo].[vyuARCustomerInquiryReport]
AS 
SELECT 
  CAR.strCustomerName
, CAR.intEntityCustomerId
, CAR.dbl10Days
, CAR.dbl30Days
, CAR.dbl60Days
, CAR.dbl90Days
, CAR.dbl91Days
, CAR.dblTotalDue
, CAR.dblAmountPaid
, CAR.dblInvoiceTotal
, dblYTDSales			= (SELECT ISNULL(SUM(CASE WHEN I.strTransactionType <> 'Invoice' THEN ISNULL(I.dblInvoiceSubtotal, 0) * -1 ELSE ISNULL(I.dblInvoiceSubtotal, 0) END), 0.000000)
							FROM tblARInvoice I	WHERE I.ysnPosted = 1 AND I.dtmDueDate <= GETDATE() AND YEAR(I.dtmPostDate) =  DATEPART(year, GETDATE()) AND I.intEntityCustomerId = CAR.intEntityCustomerId)
, dblLastYearSales		= (SELECT ISNULL(SUM(CASE WHEN I.strTransactionType <> 'Invoice' THEN ISNULL(I.dblInvoiceSubtotal, 0) * -1 ELSE ISNULL(I.dblInvoiceSubtotal, 0) END), 0.000000)
							FROM tblARInvoice I WHERE I.ysnPosted = 1 AND I.dtmDueDate <= GETDATE() AND YEAR(I.dtmPostDate) =  DATEPART(year, GETDATE()) - 1 AND I.intEntityCustomerId = CAR.intEntityCustomerId)
, dblLastPayment		= ISNULL((SELECT TOP 1 ISNULL(dblAmountPaid, 0) FROM tblARPayment WHERE intEntityCustomerId = CAR.intEntityCustomerId AND ysnPosted = 1 ORDER BY dtmDatePaid DESC, intPaymentId DESC), 0)
, dtmLastPaymentDate	= (SELECT TOP 1 dtmDatePaid FROM tblARPayment WHERE intEntityCustomerId = CAR.intEntityCustomerId AND ysnPosted = 1 ORDER BY dtmDatePaid DESC, intPaymentId DESC)
, dblLastStatement		= ISNULL((SELECT TOP 1 ISNULL(I.dblPayment, 0) FROM tblARInvoice I 
										INNER JOIN tblARPayment P ON I.intEntityCustomerId = P.intEntityCustomerId
									WHERE I.ysnPosted = 1 
										AND I.ysnPaid = 1
										AND I.intEntityCustomerId = CAR.intEntityCustomerId 
									ORDER BY P.dtmDatePaid DESC, P.intPaymentId DESC), 0)
, dtmLastStatementDate = (SELECT TOP 1 P.dtmDatePaid FROM tblARInvoice I 
										INNER JOIN tblARPayment P ON I.intEntityCustomerId = P.intEntityCustomerId
									WHERE I.ysnPosted = 1
										AND I.ysnPaid = 1
										AND I.intEntityCustomerId = CAR.intEntityCustomerId 
									ORDER BY P.dtmDatePaid DESC, P.intPaymentId DESC)
, dblUnappliedCredits	= CAR.dblCredits
, dblPrepaids			= 0.000000
, dblFuture				= 0.000000
, dblBudgetAmount		= ISNULL((SELECT dblMonthlyBudget FROM tblARCustomer WHERE intEntityCustomerId = CAR.intEntityCustomerId), 0.000000)
, dblBudgetMonth		= ISNULL(dbo.fnARGetCustomerBudget(CAR.intEntityCustomerId, GETDATE()), 0.000000)
, dblThru				= 0.000000
, dblPendingInvoice		= (SELECT ISNULL(SUM(CASE WHEN strTransactionType <> 'Invoice' THEN ISNULL(dblInvoiceTotal,0) * -1 ELSE ISNULL(dblInvoiceTotal,0) END), 0) FROM tblARInvoice WHERE intEntityCustomerId = CAR.intEntityCustomerId AND ysnPosted = 0)
, dblPendingPayment		= (SELECT ISNULL(SUM(ISNULL(dblAmountPaid ,0)), 0) FROM tblARPayment WHERE intEntityCustomerId = CAR.intEntityCustomerId AND ysnPosted = 0)
, dblCreditLimit		= (SELECT dblCreditLimit FROM tblARCustomer WHERE intEntityCustomerId = CAR.intEntityCustomerId)
, strTerm				= (SELECT TOP 1 strTerm FROM vyuARCustomer C INNER JOIN tblSMTerm T ON C.intTermsId = T.intTermID WHERE intEntityCustomerId = CAR.intEntityCustomerId)
, strContact			= (SELECT strFullAddress = [dbo].fnARFormatCustomerAddress(CC.strPhone, CC.strEmail, C.strBillToLocationName, C.strBillToAddress, C.strBillToCity, C.strBillToState, C.strBillToZipCode, C.strBillToCountry, NULL)
								FROM vyuARCustomer C INNER JOIN vyuARCustomerContacts CC ON C.intEntityCustomerId = CC.intEntityCustomerId AND ysnDefaultContact = 1 WHERE C.intEntityCustomerId = CAR.intEntityCustomerId)
, strCompanyName		= (SELECT TOP 1 strCompanyName FROM tblSMCompanySetup)
, strCompanyAddress	= (SELECT TOP 1 dbo.[fnARFormatCustomerAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL) FROM tblSMCompanySetup)
FROM vyuARCustomerAgingReport CAR 