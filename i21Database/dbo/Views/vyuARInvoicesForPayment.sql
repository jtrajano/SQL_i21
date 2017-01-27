CREATE VIEW [dbo].[vyuARInvoicesForPayment]
AS
SELECT 
	 [intTransactionId]			= ARI.[intInvoiceId]
	,[strTransactionNumber]		= ARI.[strInvoiceNumber]
	,[intInvoiceId]				= ARI.[intInvoiceId]
	,[strInvoiceNumber]			= ARI.[strInvoiceNumber]
	,[intBillId]				= NULL
	,[strBillId]				= ''
	,[strTransactionType]		= ARI.[strTransactionType]
	,[strType]					= ARI.[strType]
	,[intEntityId]				= ARI.[intEntityCustomerId]
	,[intCompanyLocationId]		= ARI.[intCompanyLocationId]
	,[intAccountId]				= ARI.[intAccountId]
	,[intCurrencyId]			= ARI.[intCurrencyId]
	,[intTermId]				= ARI.[intTermId]
	,[strTerm]					= SMT.[strTerm]
	,[dtmDate]					= ARI.[dtmDate]
	,[dtmDueDate]				= ARI.[dtmDueDate]
	,[dtmPostDate]				= ARI.[dtmPostDate]
	,[dblInvoiceTotal]			= ARI.[dblInvoiceTotal]
	,[dblDiscount]				= ARI.[dblDiscount]
	,[dblDiscountAvailable]		= ARI.[dblDiscountAvailable]
	,[dblInterest]				= ARI.[dblInterest]
	,[dblAmountDue]				= ARI.[dblAmountDue]
	,[dblPayment]				= ARI.[dblPayment]
	,[ysnPosted]				= ARI.[ysnPosted]
	,[ysnPaid]					= ARI.[ysnPaid]
	,[intPaymentId]				= ARI.[intPaymentId]
	,[dblTotalTermDiscount]		= ARI.[dblTotalTermDiscount]
	,[strInvoiceReportNumber]	= CFT.strInvoiceReportNumber
	,[strTicketNumbers]			= dbo.fnARGetScaleTicketNumbersFromInvoice(ARI.intInvoiceId)
	,[strCustomerReferences]	= dbo.fnARGetCustomerReferencesFromInvoice(ARI.intInvoiceId)
FROM
	[tblARInvoice] ARI
LEFT OUTER JOIN 
	(
	SELECT
		 [intInvoiceId]
		,[strInvoiceReportNumber]
	FROM
		tblCFTransaction
	) CFT 
		ON ARI.[intInvoiceId] = CFT.[intInvoiceId]
LEFT OUTER JOIN 
	(
	SELECT
		 [intTermID]
		,[strTerm]
	FROM
		tblSMTerm
	) SMT
		ON ARI.[intTermId] = SMT.[intTermID]		
WHERE
	[ysnPosted] = 1
	
	
UNION ALL


SELECT 
	 [intTransactionId]			= APB.[intBillId]
	,[strTransactionNumber]		= APB.[strBillId]
	,[intInvoiceId]				= NULL
	,[strInvoiceNumber]			= ''
	,[intBillId]				= APB.[intBillId]
	,[strBillId]				= APB.[strBillId]
	,[strTransactionType]		= (CASE WHEN APB.[intTransactionType] = 11 THEN 'Weight Claim' WHEN APB.[intTransactionType] = 3 THEN 'Debit Memo' ELSE '' END)
	,[strType]					= 'Voucher'
	,[intEntityId]				= APB.[intEntityVendorId]
	,[intCompanyLocationId]		= APB.intShipToId
	,[intAccountId]				= APB.[intAccountId]
	,[intCurrencyId]			= APB.[intCurrencyId]
	,[intTermId]				= APB.[intTermsId]
	,[strTerm]					= SMT.[strTerm]
	,[dtmDate]					= APB.[dtmDate]
	,[dtmDueDate]				= APB.[dtmDueDate]
	,[dtmPostDate]				= APB.[dtmBillDate]
	,[dblInvoiceTotal]			= APB.[dblTotal]
	,[dblDiscount]				= APB.[dblDiscount]
	,[dblDiscountAvailable]		= CAST(0 AS DECIMAL(18,6))
	,[dblInterest]				= APB.[dblInterest]
	,[dblAmountDue]				= APB.[dblAmountDue]
	,[dblPayment]				= APB.[dblPayment]
	,[ysnPosted]				= APB.[ysnPosted]
	,[ysnPaid]					= APB.[ysnPaid]
	,[intPaymentId]				= NULL
	,[dblTotalTermDiscount]		= CAST(0 AS DECIMAL(18,6))
	,[strInvoiceReportNumber]	= ''
	,[strTicketNumbers]			= ''
	,[strCustomerReferences]	= ''
FROM
	tblAPBill APB
INNER JOIN
	tblEMEntityType EMET
		ON APB.[intEntityVendorId] = EMET.[intEntityId]
		AND EMET.[strType] = 'Customer'
LEFT OUTER JOIN 
	(
	SELECT
		 [intTermID]
		,[strTerm]
	FROM
		tblSMTerm
	) SMT
		ON APB.[intTermsId] = SMT.[intTermID]		
WHERE
	[intTransactionType] IN (11,3)
	AND [ysnPosted] = 1