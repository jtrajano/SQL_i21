CREATE VIEW vyuARCustomerHistory
AS 
SELECT TRANSACTIONS.* 
	 , strCustomerNumber	= C.strCustomerNumber
	 , strCustomerName		= C.strName
FROM (
	SELECT dtmDate				= ISNULL(SO.dtmProcessDate, SO.dtmDate)
		 , strTransactionNumber	= SO.strSalesOrderNumber
		 , strTransactionType	= SO.strTransactionType
		 , dblTransactionTotal	= ISNULL(SO.dblSalesOrderTotal, 0.00)
		 , dblAmountPaid		= ISNULL(SO.dblPayment, 0.00)
		 , dblAmountDue			= ISNULL(SO.dblAmountDue, 0.00)
		 , intEntityCustomerId	= SO.intEntityCustomerId
		 , ysnPaid				= 0
	FROM dbo.tblSOSalesOrder SO WITH (NOLOCK)
	WHERE SO.ysnRecurring = 0
	
	UNION ALL

	SELECT dtmDate				= ISNULL(I.dtmPostDate, I.dtmDate)
		 , strTransactionNumber	= I.strInvoiceNumber
		 , strTransactionType	= I.strTransactionType
		 , dblTransactionTotal	= ISNULL(I.dblInvoiceTotal, 0.00)
		 , dblAmountPaid		= ISNULL(I.dblPayment, 0.00)
		 , dblAmountDue			= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo') THEN ISNULL(I.dblAmountDue, 0.00) * -1 ELSE ISNULL(I.dblAmountDue, 0.00) END
		 , intEntityCustomerId	= I.intEntityCustomerId	 
		 , ysnPaid				= I.ysnPaid
	FROM tblARInvoice I WITH (NOLOCK)
	WHERE (I.strType <> 'Service Charge' OR (I.strType = 'Service Charge' AND I.ysnForgiven = 0))
	AND I.ysnRecurring = 0

	UNION ALL
	
	SELECT dtmDate				= P.dtmDatePaid
		 , strTransactionNumber	= P.strRecordNumber
		 , strTransactionType	= 'Receive Payment'
		 , dblTransactionTotal	= ISNULL(PD.dblTotal, 0.00)
		 , dblAmountPaid		= ISNULL(P.dblAmountPaid, 0.00)
		 , dblAmountDue			= 0.00
		 , intEntityCustomerId	= P.intEntityCustomerId
		 , ysnPaid				= 0
	FROM tblARPayment P WITH (NOLOCK)
	INNER JOIN (
		SELECT intPaymentId
			 , dblTotal = SUM(dblInvoiceTotal)
		FROM dbo.tblARPaymentDetail PD WITH (NOLOCK)
		INNER JOIN (
			SELECT intInvoiceId
			FROM dbo.tblARInvoice WITH (NOLOCK)
			WHERE ysnPosted = 1
			  AND strType <> 'CF Tran'
		) INV ON PD.intInvoiceId = INV.intInvoiceId
		GROUP BY intPaymentId
	) PD ON P.intPaymentId = PD.intPaymentId
) TRANSACTIONS
INNER JOIN (
	SELECT intEntityCustomerId
	     , strName
		 , strCustomerNumber
	FROM dbo.vyuARCustomerSearch WITH (NOLOCK)
) C ON TRANSACTIONS.intEntityCustomerId = C.intEntityCustomerId