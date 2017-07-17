CREATE VIEW vyuARCustomerHistory
AS 
SELECT TRANSACTIONS.*
     , CUSTOMER.strCustomerNumber
	 , CUSTOMER.strName 
FROM (
	SELECT dtmDate				= ISNULL(SO.dtmProcessDate, SO.dtmDate)
		 , strTransactionNumber	= SO.strSalesOrderNumber
		 , strTransactionType	= SO.strTransactionType
		 , dblTransactionTotal	= ISNULL(SO.dblSalesOrderTotal, 0.00)
		 , dblAmountPaid		= ISNULL(SO.dblPayment, 0.00)
		 , dblAmountDue			= ISNULL(SO.dblAmountDue, 0.00)
		 , dblInterest			= 0.00
		 , intEntityCustomerId
		 , ysnPaid				= 0
	FROM dbo.tblSOSalesOrder SO	WITH (NOLOCK)
	WHERE SO.ysnRecurring = 0
	
	UNION	

	SELECT dtmDate				= ISNULL(I.dtmPostDate, I.dtmDate)
		 , strTransactionNumber	= I.strInvoiceNumber
		 , strTransactionType	= I.strTransactionType
		 , dblTransactionTotal	= ISNULL(I.dblInvoiceTotal, 0.00)
		 , dblAmountPaid		= ISNULL(I.dblPayment, 0.00)
		 , dblAmountDue			= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo') THEN ISNULL(I.dblAmountDue, 0.00) * -1 ELSE ISNULL(I.dblAmountDue, 0.00) END
		 , dblInterest			= 0.00
		 , intEntityCustomerId
		 , ysnPaid				= I.ysnPaid
	FROM dbo.tblARInvoice I WITH (NOLOCK)
	WHERE (I.strType <> 'Service Charge' OR (I.strType = 'Service Charge' AND I.ysnForgiven = 0))
	   AND I.ysnRecurring = 0

	UNION	
	
	SELECT dtmDate				= P.dtmDatePaid
		 , strTransactionNumber	= P.strRecordNumber
		 , strTransactionType	= 'Receive Payment'
		 , dblTransactionTotal	= ISNULL(PD.dblTotal, 0.00)
		 , dblAmountPaid		= ISNULL(P.dblAmountPaid, 0.00)
		 , dblAmountDue			= 0.00
		 , dblInterest			= ISNULL(PD.dblInterest, 0.00)
		 , intEntityCustomerId	
		 , ysnPaid				= 0
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