CREATE VIEW vyuARCustomerHistory
AS 
SELECT dtmDate				= ISNULL(SO.dtmProcessDate, SO.dtmDate)
	 , strTransactionNumber	= SO.strSalesOrderNumber
	 , strTransactionType	= SO.strTransactionType
	 , dblTransactionTotal	= ISNULL(SO.dblSalesOrderTotal, 0.00)
	 , dblAmountPaid		= ISNULL(SO.dblPayment, 0.00)
	 , dblAmountDue			= ISNULL(SO.dblAmountDue, 0.00)
	 , intEntityCustomerId	= C.intEntityCustomerId
	 , strCustomerNumber	= C.strCustomerNumber
	 , strCustomerName		= E.strName
	 , ysnPaid				= 0
FROM tblSOSalesOrder SO
INNER JOIN tblARCustomer C ON SO.intEntityCustomerId = C.intEntityCustomerId
INNER JOIN tblEntity E ON C.intEntityCustomerId = E.intEntityId
	
UNION	
	
SELECT dtmDate				= ISNULL(I.dtmPostDate, I.dtmDate)
	 , strTransactionNumber	= I.strInvoiceNumber
	 , strTransactionType	= I.strTransactionType
	 , dblTransactionTotal	= ISNULL(I.dblInvoiceTotal, 0.00)
	 , dblAmountPaid		= ISNULL(I.dblPayment, 0.00)
	 , dblAmountDue			= CASE WHEN I.strTransactionType <> 'Invoice' THEN ISNULL(I.dblAmountDue, 0.00) * -1 ELSE ISNULL(I.dblAmountDue, 0.00) END
	 , intEntityCustomerId	= C.intEntityCustomerId
	 , strCustomerNumber	= C.strCustomerNumber
	 , strCustomerName		= E.strName
	 , ysnPaid				= I.ysnPaid
FROM tblARInvoice I
INNER JOIN tblARCustomer C ON I.intEntityCustomerId = C.intEntityCustomerId 
INNER JOIN tblEntity E ON C.intEntityCustomerId = E.intEntityId
	
UNION	
	
SELECT dtmDate				= P.dtmDatePaid
	 , strTransactionNumber	= P.strRecordNumber
	 , strTransactionType	= 'Receive Payment'
	 , dblTransactionTotal	= ISNULL(PD.dblTotal, 0.00)
	 , dblAmountPaid		= ISNULL(P.dblAmountPaid, 0.00)
	 , dblAmountDue			= 0.00
	 , intEntityCustomerId	= C.intEntityCustomerId
	 , strCustomerNumber	= C.strCustomerNumber
	 , strCustomerName		= E.strName
	 , ysnPaid				= 0
FROM tblARPayment P
LEFT OUTER JOIN (SELECT intPaymentId ,SUM(dblInvoiceTotal)	AS dblTotal FROM tblARPaymentDetail GROUP BY intPaymentId) AS PD ON P.intPaymentId = PD.intPaymentId
INNER JOIN tblARCustomer C ON P.intEntityCustomerId = C.intEntityCustomerId 
INNER JOIN tblEntity E ON C.intEntityCustomerId = E.intEntityId