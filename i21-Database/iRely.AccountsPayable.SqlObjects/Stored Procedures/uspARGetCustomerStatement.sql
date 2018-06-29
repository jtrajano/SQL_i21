CREATE PROCEDURE [dbo].[uspARGetCustomerStatement]
	 @AsOfDate DATE
	,@CustomerId INT 
AS

--DECLARE @AsOfDate DATE
--SET @AsOfDate = GETDATE()
--SELECT @AsOfDate 


SELECT
	 I.[intInvoiceId]
	,I.[strInvoiceNumber]
	,I.[strTransactionType] 
	,I.[dtmDate]
	,I.[dtmDueDate]
	,DATEDIFF(DAY, I.[dtmDueDate], @AsOfDate) AS [intDaysDue]
	,I.[dblInvoiceTotal] * 
		(CASE WHEN I.[strTransactionType] <> 'Invoice' THEN -1 ELSE 1 END) AS dblTotalAmount
	,I.[dblPayment] * 
		(CASE WHEN I.[strTransactionType] <> 'Invoice' THEN -1 ELSE 1 END) AS dblAppliedAmount	
	,I.[dblAmountDue] * 
		(CASE WHEN I.[strTransactionType] <> 'Invoice' THEN -1 ELSE 1 END) AS dblAmountOpen
	,I.[dblInvoiceTotal]
	,I.[dblPayment] 
	,I.[dblAmountDue]
	,I.[dblTax]
	,C.[strCustomerNumber] 
	,C.[strName]
	,C.[strBillToLocationName] 
	,C.[strBillToAddress]
	,C.[strBillToCountry]
	,C.[strBillToState] 
	,C.[strBillToCity] 
	,C.[strZipCode] 
FROM
	tblARInvoice I
INNER JOIN
	vyuARCustomer C
		ON I.[intEntityCustomerId] = C.[intEntityId] 
WHERE
	I.[ysnPosted] = 1
	AND I.[ysnPaid] = 0
	AND I.[intEntityCustomerId] = @CustomerId
