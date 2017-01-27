CREATE VIEW [dbo].[vyuARInvoicesForPayment]
AS

SELECT 
	 [intTransactionId]			= ARIFP.[intTransactionId]
	,[strTransactionNumber]		= ARIFP.[strTransactionNumber]
	,[intInvoiceId]				= ARIFP.[intInvoiceId]
	,[strInvoiceNumber]			= ARIFP.[strInvoiceNumber]
	,[intBillId]				= ARIFP.[intBillId]
	,[strBillId]				= ARIFP.[strBillId]
	,[strTransactionType]		= ARIFP.[strTransactionType]
	,[strType]					= ARIFP.[strType]
	,[intEntityCustomerId]		= ARIFP.[intEntityCustomerId]	
	,[intAccountId]				= ARIFP.[intAccountId]
	,[intCurrencyId]			= ARIFP.[intCurrencyId]	
	,[dtmDate]					= ARIFP.[dtmDate]
	,[dtmDueDate]				= ARIFP.[dtmDueDate]
	,[dtmPostDate]				= ARIFP.[dtmPostDate]
	,[dblInvoiceTotal]			= ARIFP.[dblInvoiceTotal]
	,[dblDiscount]				= ARIFP.[dblDiscount]
	,[dblDiscountAvailable]		= ARIFP.[dblDiscountAvailable]
	,[dblInterest]				= ARIFP.[dblInterest]
	,[dblAmountDue]				= ARIFP.[dblAmountDue]
	,[dblPayment]				= ARIFP.[dblPayment]
	,[ysnPosted]				= ARIFP.[ysnPosted]
	,[ysnPaid]					= ARIFP.[ysnPaid]
	,[intPaymentId]				= ARIFP.[intPaymentId]
	,[dblTotalTermDiscount]		= ARIFP.[dblTotalTermDiscount]
	,[strInvoiceReportNumber]	= ARIFP.[strInvoiceReportNumber]
	,[strTicketNumbers]			= ARIFP.[strTicketNumbers]
	,[strCustomerReferences]	= ARIFP.[strCustomerReferences]
	,[intCompanyLocationId]		= SMCL.[intCompanyLocationId]
	,[strLocationName]			= SMCL.[strLocationName]
	,[intTermId]				= SMT.[intTermID]
	,[strTerm]					= SMT.[strTerm]
	,[strTermType]				= SMT.[strType] 
	,[intTermDiscountDay]		= SMT.[intDiscountDay] 
	,[dtmTermDiscountDate]		= SMT.[dtmDiscountDate]
	,[dblTermDiscountEP]		= SMT.[dblDiscountEP]
	,[intTermBalanceDue]		= SMT.[intBalanceDue]
	,[dtmTermDueDate]			= SMT.[dtmDueDate]
	,[dblTermAPR]				= SMT.[dblAPR]
FROM
	(
		SELECT 
			 [intTransactionId]			= ARI.[intInvoiceId]
			,[strTransactionNumber]		= ARI.[strInvoiceNumber]
			,[intInvoiceId]				= ARI.[intInvoiceId]
			,[strInvoiceNumber]			= ARI.[strInvoiceNumber]
			,[intBillId]				= NULL
			,[strBillId]				= ''
			,[strTransactionType]		= ARI.[strTransactionType]
			,[strType]					= ARI.[strType]
			,[intEntityCustomerId]		= ARI.[intEntityCustomerId]
			,[intCompanyLocationId]		= ARI.[intCompanyLocationId]
			,[intAccountId]				= ARI.[intAccountId]
			,[intCurrencyId]			= ARI.[intCurrencyId]	
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
			,[intTermId]				= ARI.[intTermId]
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
			,[intEntityCustomerId]		= APB.[intEntityVendorId]
			,[intCompanyLocationId]		= APB.intShipToId
			,[intAccountId]				= APB.[intAccountId]
			,[intCurrencyId]			= APB.[intCurrencyId]
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
			,[intTermId]				= APB.[intTermsId]
		FROM
			tblAPBill APB
		INNER JOIN
			tblEMEntityType EMET
				ON APB.[intEntityVendorId] = EMET.[intEntityId]
				AND EMET.[strType] = 'Customer'		
		WHERE
			[intTransactionType] IN (11,3)
			AND [ysnPosted] = 1
	) ARIFP
LEFT OUTER JOIN 
	(
	SELECT
		 [intTermID]
		,[strTerm]
		,[strType]
		,[intDiscountDay]
		,[dtmDiscountDate]
		,[dblDiscountEP] 
		,[intBalanceDue]
		,[dtmDueDate]
		,[dblAPR]
	FROM
		tblSMTerm
	) SMT
		ON ARIFP.[intTermId] = SMT.[intTermID]
LEFT OUTER JOIN 
	(
	SELECT
		 [intCompanyLocationId]
		,[strLocationName]
	FROM
		tblSMCompanyLocation
	) SMCL
		ON ARIFP.[intCompanyLocationId] = SMCL.[intCompanyLocationId]
