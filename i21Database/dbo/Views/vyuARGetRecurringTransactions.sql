CREATE VIEW [dbo].[vyuARGetRecurringTransactions]
AS

SELECT intInvoiceId AS intTransactionId
	 , strInvoiceNumber AS strTransactionNumber
	 , strTransactionType
	 , dtmDate
FROM tblARInvoice
WHERE strTransactionType = 'Invoice'
  AND ysnTemplate = 1

UNION

SELECT intSalesOrderId AS intTransactionId 
     , strSalesOrderNumber AS strTransactionNumber
	 , strTransactionType
	 , dtmDate
FROM tblSOSalesOrder
WHERE strTransactionType = 'Order'
 AND ysnRecurring = 1