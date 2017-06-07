CREATE VIEW vyuARReceivables
AS 
SELECT 
	 I.[dtmDate]									AS [dtmDate] 
	,I.[intInvoiceId]								AS [intInvoiceId]
	,I.[strInvoiceNumber]							AS [strInvoiceNumber]
	,0.00											AS [dblAmountPaid] 
	,ISNULL(I.[dblInvoiceTotal],0)					AS [dblTotal] 
	,I.[dblAmountDue]								AS [dblAmountDue] 
	,0.00											AS [dblDiscount] 
	,C.[strCustomerNumber]							AS [strCustomerNumber]
	,ISNULL(RTRIM(LTRIM(C.[strCustomerNumber])),'') 
		+ ' - ' + ISNULL(E.[strName],'')			AS [strCustomerIdName] 
	,I.[dtmDueDate]									AS [dtmDueDate]
	,I.[ysnPosted]									AS [ysnPosted]								
	,I.[ysnPaid]									AS [ysnPaid]
FROM
	tblARInvoice I
INNER JOIN
	tblARCustomer C
		ON C.[intEntityId] = I.[intEntityCustomerId]
INNER JOIN 
	tblEMEntity E 
		ON C.[intEntityId] = E.[intEntityId]
WHERE
	I.[ysnPosted] = 1

UNION ALL
   
SELECT 
	 P.[dtmDatePaid]								AS [dtmDate] 
	,PD.[intInvoiceId]								AS [intInvoiceId]
	,I.[strInvoiceNumber]							AS [strInvoiceNumber]
	,PD.[dblPayment]								AS [dblAmountPaid] 
	,0.00											AS [dblTotal] 
	,0.00											AS [dblAmountDue] 
	,PD.[dblDiscount]								AS [dblDiscount] 
	,C.[strCustomerNumber]							AS [strCustomerNumber]
	,ISNULL(RTRIM(LTRIM(C.[strCustomerNumber])),'') 
		+ ' - ' + ISNULL(E.[strName],'')			AS [strCustomerIdName] 
	,I.[dtmDueDate]									AS [dtmDueDate]
	,I.[ysnPosted]									AS [ysnPosted]				
	,I.[ysnPaid]									AS [ysnPaid]
FROM
	tblARPayment  P
INNER JOIN
	tblARCustomer C
		ON P.[intEntityCustomerId] = C.[intEntityId] 
INNER JOIN
	tblEMEntity E
		ON C.[intEntityId] = E.[intEntityId] 			
LEFT JOIN 
	tblARPaymentDetail PD
		ON P.[intPaymentId] = PD.[intPaymentId]
LEFT JOIN
	tblARInvoice I
	ON PD.[intInvoiceId] = I.[intInvoiceId]
WHERE
	P.[ysnPosted] = 1  
	AND I.[ysnPosted] = 1
