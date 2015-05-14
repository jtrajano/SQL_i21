CREATE VIEW vyuARCustomerHistory
AS 
SELECT
	ISNULL(SO.[dtmProcessDate], SO.[dtmDate])	AS [dtmDate]
	,SO.[strSalesOrderNumber]					AS [strTransactionNumber]
	,SO.[strTransactionType]					AS [strTransactionType]
	,ISNULL(SO.[dblSalesOrderTotal], 0.00)		AS [dblTransactionTotal]
	,ISNULL(SO.[dblPayment], 0.00)				AS [dblAmountPaid]
	,ISNULL(SO.[dblAmountDue], 0.00)			AS [dblAmountDue]
	,C.[intEntityCustomerId]					AS [intEntityCustomerId]
	,C.[strCustomerNumber]						AS [strCustomerNumber]
	,E.[strName]								AS [strCustomerName] 
FROM
	tblSOSalesOrder SO
INNER JOIN
	tblARCustomer C
		ON SO.[intEntityCustomerId] = C.[intEntityCustomerId]
INNER JOIN
	tblEntity E
		ON C.[intEntityCustomerId] = E.[intEntityId] 
	
UNION	
	
SELECT
	ISNULL(I.[dtmPostDate], I.[dtmDate])		AS [dtmDate]
	,I.[strInvoiceNumber]						AS [strTransactionNumber]
	,I.[strTransactionType]						AS [strTransactionType]
	,ISNULL(I.[dblInvoiceTotal], 0.00)			AS [dblTransactionTotal]
	,ISNULL(I.[dblPayment], 0.00)				AS [dblAmountPaid]
	,ISNULL(I.[dblAmountDue], 0.00)				AS [dblAmountDue]
	,C.[intEntityCustomerId]					AS [intEntityCustomerId]
	,C.[strCustomerNumber]						AS [strCustomerNumber]  
	,E.[strName]								AS [strCustomerName]	
FROM
	tblARInvoice I
INNER JOIN
	tblARCustomer C
		ON I.[intEntityCustomerId] = C.[intEntityCustomerId] 
INNER JOIN
	tblEntity E
		ON C.[intEntityCustomerId] = E.[intEntityId] 				
	
	
UNION	
	
SELECT
	 P.[dtmDatePaid]							AS [dtmDate]
	,P.[strRecordNumber]						AS [strTransactionNumber]
	,'Receive Payment'							AS [strTransactionType]
	,ISNULL(PD.[dblTotal], 0.00)				AS [dblTransactionTotal] 
	,ISNULL(P.[dblAmountPaid], 0.00)			AS [dblAmountPaid]
	,ISNULL(P.[dblUnappliedAmount], 0.00)		AS [dblAmountDue]
	,C.[intEntityCustomerId]					AS [intEntityCustomerId]
	,C.[strCustomerNumber]						AS [strCustomerNumber]
	,E.[strName]								AS [strCustomerName]
FROM
	tblARPayment P
LEFT OUTER JOIN
	(
		SELECT
			 [intPaymentId]
			,SUM(dblInvoiceTotal)	AS [dblTotal]
		FROM
			tblARPaymentDetail
		GROUP BY
			[intPaymentId] 
	) AS PD
		ON P.[intPaymentId] = PD.[intPaymentId]
INNER JOIN
	tblARCustomer C
		ON P.[intEntityCustomerId] = C.[intEntityCustomerId] 
INNER JOIN
	tblEntity E
		ON C.[intEntityCustomerId] = E.[intEntityId] 		

