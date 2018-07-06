CREATE VIEW [dbo].[vyuARInvoicesForPaymentIntegration]
AS

SELECT 
	 [intTransactionId]					= ARIFP.[intTransactionId]
	,[strTransactionNumber]				= ARIFP.[strTransactionNumber]
	,[intInvoiceId]						= ARIFP.[intInvoiceId]
	,[strInvoiceNumber]					= ARIFP.[strInvoiceNumber]
	,[intBillId]						= ARIFP.[intBillId]
	,[strBillId]						= ARIFP.[strBillId]
	,[strTransactionType]				= ARIFP.[strTransactionType]
	,[strType]							= ARIFP.[strType]
	,[intEntityCustomerId]				= ARIFP.[intEntityCustomerId]	
	,[intAccountId]						= ARIFP.[intAccountId]
	,[intCurrencyId]					= ARIFP.[intCurrencyId]	
	,[dtmDate]							= ARIFP.[dtmDate]
	,[dtmDueDate]						= ARIFP.[dtmDueDate]
	,[dtmPostDate]						= ARIFP.[dtmPostDate]
	,[dblInvoiceTotal]					= ARIFP.[dblInvoiceTotal]
	,[dblBaseInvoiceTotal]				= ARIFP.[dblBaseInvoiceTotal]
	,[dblDiscount]						= ARIFP.[dblDiscount]
	,[dblBaseDiscount]					= ARIFP.[dblBaseDiscount]
	,[dblDiscountAvailable]				= ARIFP.[dblDiscountAvailable]
	,[dblBaseDiscountAvailable]			= ARIFP.[dblBaseDiscountAvailable]
	,[dblInterest]						= ARIFP.[dblInterest]
	,[dblBaseInterest]					= ARIFP.[dblBaseInterest]
	,[dblAmountDue]						= ARIFP.[dblAmountDue]
	,[dblBaseAmountDue]					= ARIFP.[dblBaseAmountDue]
	,[dblPayment]						= ARIFP.[dblPayment]
	,[dblBasePayment]					= ARIFP.[dblBasePayment]
	,[ysnPosted]						= ARIFP.[ysnPosted]
	,[ysnPaid]							= ARIFP.[ysnPaid]
	,[intPaymentId]						= ARIFP.[intPaymentId]
	,[dblTotalTermDiscount]				= ARIFP.[dblTotalTermDiscount]
	,[intCompanyLocationId]				= ARIFP.[intCompanyLocationId]
	,[intTermId]						= ARIFP.[intTermId]
	,[intPaymentMethodId]				= ARIFP.[intPaymentMethodId]	
	,[intCurrencyExchangeRateTypeId]	= ARIFP.[intCurrencyExchangeRateTypeId]
	,[intCurrencyExchangeRateId]		= ARIFP.[intCurrencyExchangeRateId]
	,[dblCurrencyExchangeRate]			= ARIFP.[dblCurrencyExchangeRate]
	,[dtmDiscountDate]					= CASE WHEN ISNULL(ARIFP.dblDiscountAvailable, 0) = 0
												  THEN NULL
												  ELSE [dbo].[fnGetDiscountDateBasedOnTerm](ARIFP.[dtmDate], ARIFP.[intTermId], GETDATE())
										  END
	,[dblInvoiceDiscountAvailable]		= ARIFP.[dblInvoiceDiscountAvailable]
FROM
	(
		SELECT 
			 [intTransactionId]					= ARI.[intInvoiceId]
			,[strTransactionNumber]				= ARI.[strInvoiceNumber]
			,[intInvoiceId]						= ARI.[intInvoiceId]
			,[strInvoiceNumber]					= ARI.[strInvoiceNumber]
			,[intBillId]						= NULL
			,[strBillId]						= ''
			,[strTransactionType]				= ARI.[strTransactionType]
			,[strType]							= ARI.[strType]
			,[intEntityCustomerId]				= ARI.[intEntityCustomerId]
			,[intCompanyLocationId]				= ARI.[intCompanyLocationId]
			,[intAccountId]						= ARI.[intAccountId]
			,[intCurrencyId]					= ARI.[intCurrencyId]	
			,[dtmDate]							= ARI.[dtmDate]
			,[dtmDueDate]						= ARI.[dtmDueDate]
			,[dtmPostDate]						= ARI.[dtmPostDate]
			,[dblInvoiceTotal]					= ARI.[dblInvoiceTotal]
			,[dblBaseInvoiceTotal]				= ARI.[dblBaseInvoiceTotal]
			,[dblDiscount]						= ARI.[dblDiscount]
			,[dblBaseDiscount]					= ARI.[dblBaseDiscount]
			,[dblDiscountAvailable]				= CASE WHEN ARI.[strTransactionType] IN ('Invoice', 'Debit Memo') THEN ARI.[dblDiscountAvailable] ELSE CAST(0 AS DECIMAL(18,6)) END
			,[dblBaseDiscountAvailable]			= CASE WHEN ARI.[strTransactionType] IN ('Invoice', 'Debit Memo') THEN ARI.[dblBaseDiscountAvailable] ELSE CAST(0 AS DECIMAL(18,6)) END
			,[dblInterest]						= ARI.[dblInterest]
			,[dblBaseInterest]					= ARI.[dblBaseInterest]
			,[dblAmountDue]						= ARI.[dblAmountDue]
			,[dblBaseAmountDue]					= ARI.[dblBaseAmountDue]
			,[dblPayment]						= ARI.[dblPayment]
			,[dblBasePayment]					= ARI.[dblBasePayment]
			,[ysnPosted]						= ARI.[ysnPosted]
			,[ysnPaid]							= ARI.[ysnPaid]
			,[intPaymentId]						= ARI.[intPaymentId]
			,[dblTotalTermDiscount]				= ARI.[dblTotalTermDiscount]
			,[intTermId]						= ARI.[intTermId]
			,[strInvoiceReportNumber]			= CFT.strInvoiceReportNumber
			,[ysnExcludeForPayment]				= (CASE WHEN ARI.[strTransactionType] = 'Customer Prepayment' AND (EXISTS(SELECT NULL FROM tblARInvoiceDetail WHERE [intInvoiceId] = ARI.[intInvoiceId] AND ISNULL([ysnRestricted], 0) = 1))
														THEN CONVERT(BIT, 1)
													WHEN ARI.[strType] = 'CF Tran'
														THEN CONVERT(BIT, 1)
													ELSE CONVERT(BIT, 0) 
													END)
			,[intPaymentMethodId]				= ARI.[intPaymentMethodId]
			,[intCurrencyExchangeRateTypeId]	= FX.[intCurrencyExchangeRateTypeId]
			,[intCurrencyExchangeRateId]		= FX.[intCurrencyExchangeRateId]
			,[dblCurrencyExchangeRate]			= ISNULL(ARI.[dblCurrencyExchangeRate], FX.[dblCurrencyExchangeRate])
			,[dblInvoiceDiscountAvailable]		= CASE WHEN ARI.[strTransactionType] IN ('Invoice', 'Debit Memo') THEN ARI.[dblDiscountAvailable] ELSE CAST(0 AS DECIMAL(18,6)) END
		FROM
			[tblARInvoice] ARI
		LEFT JOIN
			(
			SELECT
				 B.[intInvoiceId]
				,A.[intCurrencyExchangeRateTypeId]
				,A.[intCurrencyExchangeRateId]
				,A.[dblCurrencyExchangeRate]
			FROM
				tblARInvoiceDetail A
			INNER JOIN
				(
				SELECT
					 [intInvoicedetailId]	= MIN([intInvoiceDetailId])
					,[intInvoiceId]			= [intInvoiceId]
				FROM
					tblARInvoiceDetail
				GROUP BY
					[intInvoiceId]
				) B
					ON A.[intInvoiceDetailId] = B.[intInvoicedetailId]
			) FX
				ON ARI.[intInvoiceId] = FX.[intInvoiceId]
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
			ARI.[ysnPosted] = 1
			AND ysnCancelled = 0			
			AND strTransactionType != 'Credit Note'
			AND ((ARI.strType = 'Service Charge' AND ARI.ysnForgiven = 0) OR ((ARI.strType <> 'Service Charge' AND ARI.ysnForgiven = 1) OR (ARI.strType <> 'Service Charge' AND ARI.ysnForgiven = 0)))
			AND (NOT(ARI.strType = 'Provisional' AND ARI.ysnProcessed = 1) OR ysnExcludeFromPayment = 1)
	
		UNION ALL


		SELECT 
			 [intTransactionId]					= APB.[intTransactionId]
			,[strTransactionNumber]				= APB.[strTransactionNumber]
			,[intInvoiceId]						= APB.[intInvoiceId]
			,[strInvoiceNumber]					= APB.[strInvoiceNumber]
			,[intBillId]						= APB.[intBillId]
			,[strBillId]						= APB.[strBillId]
			,[strTransactionType]				= APB.[strTransactionType]
			,[strType]							= APB.[strType]
			,[intEntityCustomerId]				= APB.[intEntityCustomerId]
			,[intCompanyLocationId]				= APB.[intCompanyLocationId]
			,[intAccountId]						= APB.[intAccountId]
			,[intCurrencyId]					= APB.[intCurrencyId]
			,[dtmDate]							= APB.[dtmDate]
			,[dtmDueDate]						= APB.[dtmDueDate]
			,[dtmPostDate]						= APB.[dtmPostDate]
			,[dblInvoiceTotal]					= APB.[dblInvoiceTotal]
			,[dblBaseInvoiceTotal]				= APB.[dblBaseInvoiceTotal]
			,[dblDiscount]						= APB.[dblDiscount]
			,[dblBaseDiscount]					= APB.[dblDiscount]
			,[dblDiscountAvailable]				= APB.[dblDiscountAvailable]
			,[dblBaseDiscountAvailable]			= APB.[dblDiscountAvailable]
			,[dblInterest]						= APB.[dblInterest]
			,[dblBaseInterest]					= APB.[dblBaseInterest]
			,[dblAmountDue]						= APB.[dblAmountDue]
			,[dblBaseAmountDue]					= APB.[dblBaseAmountDue]
			,[dblPayment]						= APB.[dblPayment]
			,[dblBasePayment]					= APB.[dblBasePayment]
			,[ysnPosted]						= APB.[ysnPosted]
			,[ysnPaid]							= APB.[ysnPaid]
			,[intPaymentId]						= APB.[intPaymentId]
			,[dblTotalTermDiscount]				= APB.[dblTotalTermDiscount]			
			,[intTermId]						= APB.[intTermId]
			,[strInvoiceReportNumber]			= APB.[strInvoiceReportNumber]
			,[ysnExcludeForPayment]				= APB.[ysnExcludeForPayment]
			,[intPaymentMethodId]				= APB.[intPaymentMethodId]
			,[intCurrencyExchangeRateTypeId]	= APB.[intCurrencyExchangeRateTypeId]
			,[intCurrencyExchangeRateId]		= NULL
			,[dblCurrencyExchangeRate]			= APB.[dblCurrencyExchangeRate]
			,[dblInvoiceDiscountAvailable]		= APB.[dblInvoiceDiscountAvailable]
		FROM
			[vyuAPVouchersForARPayment] APB
			
	) ARIFP