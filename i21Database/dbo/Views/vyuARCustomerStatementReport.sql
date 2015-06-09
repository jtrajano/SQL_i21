CREATE VIEW [dbo].[vyuARCustomerStatementReport]
AS
SELECT I.[intInvoiceId]
	 , I.[strInvoiceNumber]
	 , I.[strTransactionType] 
	 , I.[dtmDate]
	 , I.[dtmDueDate]
	 , DATEDIFF(DAY, I.[dtmDueDate], GETDATE()) AS [intDaysDue]
	 , I.[dblInvoiceTotal] * 
	  	(CASE WHEN I.[strTransactionType] <> 'Invoice' THEN -1 ELSE 1 END) AS dblTotalAmount
	 , I.[dblPayment] * 
	  	(CASE WHEN I.[strTransactionType] <> 'Invoice' THEN -1 ELSE 1 END) AS dblAppliedAmount	
	 , I.[dblAmountDue] * 
	  	(CASE WHEN I.[strTransactionType] <> 'Invoice' THEN -1 ELSE 1 END) AS dblAmountOpen
	 , I.[dblInvoiceTotal]
	 , I.[dblPayment] 
	 , I.[dblAmountDue]
	 , I.[dblTax]
	 , I.dblDiscount
	 , C.[strCustomerNumber] 
	 , C.[strName]
	 , I.[strBillToLocationName] 
	 , I.[strBillToAddress]
	 , I.[strBillToCountry]
	 , I.[strBillToState] 
	 , I.[strBillToCity]
	 , strFullAddress = ISNULL(I.[strBillToLocationName] + CHAR(13) + char(10), '')
						+ ISNULL(I.[strBillToAddress] + CHAR(13) + char(10), '')
						+ ISNULL(I.[strBillToCity] + CHAR(13) + char(10), '')
						+ ISNULL(I.[strBillToState]     + ' ',    '')
						+ ISNULL(I.[strBillToCountry] + ' ',    '')
FROM tblARInvoice I
INNER JOIN vyuARCustomer C ON I.[intEntityCustomerId] = C.[intEntityCustomerId] 
WHERE
	I.[ysnPosted] = 1
	AND I.[ysnPaid] = 0
