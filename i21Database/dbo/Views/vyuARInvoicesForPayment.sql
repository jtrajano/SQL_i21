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
	,[strCustomerName]			= ARIFP.[strCustomerName]
	,[strCustomerNumber]		= ARIFP.[strCustomerNumber]
	,[intAccountId]				= ARIFP.[intAccountId]
	,[intCurrencyId]			= ARIFP.[intCurrencyId]	
	,[dtmDate]					= ARIFP.[dtmDate]
	,[dtmDueDate]				= ARIFP.[dtmDueDate]
	,[dtmPostDate]				= ARIFP.[dtmPostDate]
	,[dblInvoiceTotal]			= ARIFP.[dblInvoiceTotal]
	,[dblBaseInvoiceTotal]		= ARIFP.[dblBaseInvoiceTotal]
	,[dblDiscount]				= ARIFP.[dblDiscount]
	,[dblBaseDiscount]			= ARIFP.[dblBaseDiscount]
	,[dblDiscountAvailable]		= ARIFP.[dblDiscountAvailable]
	,[dblBaseDiscountAvailable]	= ARIFP.[dblBaseDiscountAvailable]
	,[dblInterest]				= ARIFP.[dblInterest]
	,[dblBaseInterest]			= ARIFP.[dblBaseInterest]
	,[dblAmountDue]				= ARIFP.[dblAmountDue]
	,[dblBaseAmountDue]			= ARIFP.[dblBaseAmountDue]
	,[dblPayment]				= ARIFP.[dblPayment]
	,[dblBasePayment]			= ARIFP.[dblBasePayment]
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
	,[ysnExcludeForPayment]		= ARIFP.[ysnExcludeForPayment]
	,[intPaymentMethodId]		= ARIFP.[intPaymentMethodId]	
	,[strPaymentMethod]			= ARIFP.[strPaymentMethod]
	,[intCurrencyExchangeRateTypeId]	= DFR.[intCurrencyExchangeRateTypeId]
	,[strCurrencyExchangeRateType]		= DFR.[strCurrencyExchangeRateType]
	,[intCurrencyExchangeRateId]		= DFR.[intCurrencyExchangeRateId]
	,[dblCurrencyExchangeRate]			= DFR.[dblCurrencyExchangeRate]
	,[ysnInvoicePrepayment]				= ARIFP.ysnInvoicePrepayment
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
			,[strCustomerName]			= CE.strName
			,[strCustomerNumber]		= ARC.[strCustomerNumber]
			,[intCompanyLocationId]		= ARI.[intCompanyLocationId]
			,[intAccountId]				= ARI.[intAccountId]
			,[intCurrencyId]			= ARI.[intCurrencyId]	
			,[dtmDate]					= ARI.[dtmDate]
			,[dtmDueDate]				= ARI.[dtmDueDate]
			,[dtmPostDate]				= ARI.[dtmPostDate]
			,[dblInvoiceTotal]			= ARI.[dblInvoiceTotal]
			,[dblBaseInvoiceTotal]		= ARI.[dblBaseInvoiceTotal]
			,[dblDiscount]				= ARI.[dblDiscount]
			,[dblBaseDiscount]			= ARI.[dblBaseDiscount]
			,[dblDiscountAvailable]		= ARI.[dblDiscountAvailable]
			,[dblBaseDiscountAvailable]	= ARI.[dblBaseDiscountAvailable]
			,[dblInterest]				= ARI.[dblInterest]
			,[dblBaseInterest]			= ARI.[dblBaseInterest]
			,[dblAmountDue]				= ARI.[dblAmountDue]
			,[dblBaseAmountDue]			= ARI.[dblBaseAmountDue]
			,[dblPayment]				= ARI.[dblPayment]
			,[dblBasePayment]			= ARI.[dblBasePayment]
			,[ysnPosted]				= ARI.[ysnPosted]
			,[ysnPaid]					= ARI.[ysnPaid]
			,[intPaymentId]				= ARI.[intPaymentId]
			,[dblTotalTermDiscount]		= ARI.[dblTotalTermDiscount]
			,[strInvoiceReportNumber]	= CFT.strInvoiceReportNumber
			,[strTicketNumbers]			= dbo.fnARGetScaleTicketNumbersFromInvoice(ARI.intInvoiceId)
			,[strCustomerReferences]	= dbo.fnARGetCustomerReferencesFromInvoice(ARI.intInvoiceId)
			,[intTermId]				= ARI.[intTermId]
			,[ysnExcludeForPayment]		= (CASE WHEN ARI.strTransactionType = 'Customer Prepayment' AND (EXISTS(SELECT NULL FROM tblARInvoiceDetail WHERE intInvoiceId = ARI.intInvoiceId AND (ISNULL(ysnRestricted, 0) = 1 OR ISNULL(intContractDetailId, 0) <> 0))) 
												THEN CONVERT(BIT, 1)
											WHEN ARI.strType = 'CF Tran'
												THEN CONVERT(BIT, 1)
											ELSE CONVERT(BIT, 0) 
										 END)
			,intPaymentMethodId				= ARC.intPaymentMethodId	
			,strPaymentMethod				= SMP.strPaymentMethod
			,ysnInvoicePrepayment			=  ARP.ysnInvoicePrepayment
		FROM
			[tblARInvoice] ARI
		INNER JOIN
			(SELECT 
				strCustomerNumber,
				intEntityCustomerId,
				intPaymentMethodId
			 FROM 
				dbo.tblARCustomer) AS ARC ON ARI.[intEntityCustomerId] = ARC.[intEntityCustomerId] 
		INNER JOIN
			(SELECT	
				intEntityId,
				strName
			 FROM
				dbo.tblEMEntity) AS CE ON ARC.[intEntityCustomerId] = CE.intEntityId 
		LEFT OUTER JOIN
			(SELECT 
				intPaymentMethodID,
				strPaymentMethod
			 FROM
				dbo.tblSMPaymentMethod) AS SMP ON ARC.intPaymentMethodId = SMP.intPaymentMethodID
		LEFT OUTER JOIN
			(
				SELECT
					intPaymentId
					,ysnInvoicePrepayment
				FROM
					tblARPayment
			) ARP
				ON ARI.intPaymentId = ARP.intPaymentId 
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
			AND ((ARI.strType = 'Service Charge' AND ARI.ysnForgiven = 0) OR ((ARI.strType <> 'Service Charge' AND ARI.ysnForgiven = 1) OR (ARI.strType <> 'Service Charge' AND ARI.ysnForgiven = 0)))
	
	
		UNION ALL


		SELECT 
			 [intTransactionId]			= APB.[intBillId]
			,[strTransactionNumber]		= APB.[strBillId]
			,[intInvoiceId]				= 0
			,[strInvoiceNumber]			= ''
			,[intBillId]				= APB.[intBillId]
			,[strBillId]				= APB.[strBillId]
			,[strTransactionType]		= (CASE WHEN APB.[intTransactionType] = 11 THEN 'Weight Claim' WHEN APB.[intTransactionType] = 3 THEN 'Debit Memo' ELSE '' END)
			,[strType]					= 'Voucher'
			,[intEntityCustomerId]		= APB.[intEntityVendorId]
			,[strCustomerName]			= CE.[strName]
			,[strCustomerNumber]		= APV.[strVendorId]
			,[intCompanyLocationId]		= APB.intShipToId
			,[intAccountId]				= APB.[intAccountId]
			,[intCurrencyId]			= APB.[intCurrencyId]
			,[dtmDate]					= APB.[dtmDate]
			,[dtmDueDate]				= APB.[dtmDueDate]
			,[dtmPostDate]				= APB.[dtmBillDate]
			,[dblInvoiceTotal]			= APB.[dblTotal]
			,[dblBaseInvoiceTotal]		= APB.[dblTotal]
			,[dblDiscount]				= APB.[dblDiscount]
			,[dblBaseDiscount]			= APB.[dblDiscount]
			,[dblDiscountAvailable]		= CAST(0 AS DECIMAL(18,6))
			,[dblBaseDiscountAvailable]	= CAST(0 AS DECIMAL(18,6))
			,[dblInterest]				= APB.[dblInterest]
			,[dblBaseInterest]			= APB.[dblInterest]
			,[dblAmountDue]				= APB.[dblAmountDue]
			,[dblBaseAmountDue]			= APB.[dblAmountDue]
			,[dblPayment]				= APB.[dblPayment]
			,[dblBasePayment]			= APB.[dblPayment]
			,[ysnPosted]				= APB.[ysnPosted]
			,[ysnPaid]					= APB.[ysnPaid]
			,[intPaymentId]				= NULL
			,[dblTotalTermDiscount]		= CAST(0 AS DECIMAL(18,6))
			,[strInvoiceReportNumber]	= ''
			,[strTicketNumbers]			= ''
			,[strCustomerReferences]	= ''
			,[intTermId]				= APB.[intTermsId]
			,[ysnExcludeForPayment]		= CONVERT(BIT, 0)
			,intPaymentMethodId			= APV.intPaymentMethodId	
			,strPaymentMethod			= SMP.strPaymentMethod
			,ysnInvoicePrepayment			=  NULL
		FROM
			tblAPBill APB
		INNER JOIN
			tblEMEntityType EMET
				ON APB.[intEntityVendorId] = EMET.[intEntityId]
				AND EMET.[strType] = 'Customer'	
		INNER JOIN
			(SELECT 				
				intEntityVendorId,
				intPaymentMethodId,
				strVendorId
			 FROM 
				dbo.tblAPVendor) AS APV ON APV.[intEntityVendorId] = APB.[intEntityVendorId] 
		INNER JOIN
			(SELECT	
				intEntityId,
				strName
			 FROM
				dbo.tblEMEntity) AS CE ON APV.[intEntityVendorId] = CE.intEntityId 	
		LEFT OUTER JOIN
			(SELECT 
				intPaymentMethodID,
				strPaymentMethod
			 FROM
				dbo.tblSMPaymentMethod) AS SMP ON APV.intPaymentMethodId = SMP.intPaymentMethodID								
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
CROSS APPLY
		[dbo].[fnARGetDefaultForexRate](ARIFP.[dtmDate], ARIFP.[intCurrencyId], NULL) DFR
