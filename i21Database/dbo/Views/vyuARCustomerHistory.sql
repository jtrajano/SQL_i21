CREATE VIEW vyuARCustomerHistory
AS 
SELECT TRANSACTIONS.*
     , CUSTOMER.strCustomerNumber
	 , CUSTOMER.strName 
FROM (
	SELECT dtmDate				= SO.dtmDate
		 , dtmPostDate			= SO.dtmProcessDate
		 , strTransactionNumber	= SO.strSalesOrderNumber
		 , strTransactionType	= SO.strTransactionType
		 , dblTransactionTotal	= ISNULL(SO.dblSalesOrderTotal, 0.00)
		 , dblAmountPaid		= ISNULL(SO.dblPayment, 0.00)
		 , dblAmountDue			= ISNULL(SO.dblAmountDue, 0.00)
		 , dblInterest			= 0.00
		 , intEntityCustomerId
		 , ysnPaid				= 0
	FROM dbo.tblSOSalesOrder SO	WITH (NOLOCK)
	WHERE ISNULL(SO.ysnRecurring, 0) = 0
	
	UNION	

	SELECT dtmDate				= I.dtmDate
		 , dtmPostDate			= I.dtmPostDate
		 , strTransactionNumber	= I.strInvoiceNumber
		 , strTransactionType	= I.strTransactionType
		 , dblTransactionTotal	= ISNULL(I.dblInvoiceTotal, 0.00)
		 , dblAmountPaid		= ISNULL(I.dblPayment, 0.00)
		 , dblAmountDue			= ISNULL(I.dblAmountDue, 0.00) * dbo.fnARGetInvoiceAmountMultiplier(I.strTransactionType)
		 , dblInterest			= 0.00
		 , intEntityCustomerId
		 , ysnPaid				= I.ysnPaid
	FROM dbo.tblARInvoice I WITH (NOLOCK)
		OUTER APPLY
		(
		   SELECT ISC.strInvoiceNumber from tblARInvoiceDetail ID
		   INNER JOIN tblARInvoice II ON II.intInvoiceId=ID.intInvoiceId
		   INNER JOIN tblARInvoice ISC ON ISC.strInvoiceNumber = ID.strDocumentNumber
		   WHERE ISC.strInvoiceNumber=I.strInvoiceNumber AND II.strTransactionType ='Credit Memo'
		   AND ID.strDocumentNumber like '%SC%'  AND ISC.ysnForgiven =1
		)SCCM
	WHERE (I.strType <> 'Service Charge' OR (I.strType = 'Service Charge' AND  (ysnForgiven = 0 OR SCCM.strInvoiceNumber IS NOT NULL)))
	   AND I.ysnRecurring = 0

	UNION	
	
	SELECT dtmDate				= P.dtmDatePaid
		 , dtmPostDate			= P.dtmDatePaid
		 , strTransactionNumber	= P.strRecordNumber
		 , strTransactionType	= 'Receive Payment'
		 , dblTransactionTotal	= ISNULL(PD.dblTotal, 0.00)
		 , dblAmountPaid		= ISNULL(P.dblAmountPaid, 0.00)
		 , dblAmountDue			= 0.00
		 , dblInterest			= ISNULL(PD.dblInterest, 0.00)
		 , intEntityCustomerId	
		 , ysnPaid				= P.ysnPosted
	FROM dbo.tblARPayment P WITH (NOLOCK)
	LEFT OUTER JOIN (SELECT intPaymentId 
						  , dblTotal	= SUM(dblInvoiceTotal)
						  , dblInterest = SUM(dblInterest) 
					 FROM dbo.tblARPaymentDetail WITH (NOLOCK) 
					 GROUP BY intPaymentId
	) PD ON P.intPaymentId = PD.intPaymentId
) TRANSACTIONS
INNER JOIN (
	SELECT intEntityId
		 , strCustomerNumber
		 , strName
	FROM dbo.vyuARCustomerSearch WITH (NOLOCK)
) CUSTOMER ON TRANSACTIONS.intEntityCustomerId = CUSTOMER.intEntityId