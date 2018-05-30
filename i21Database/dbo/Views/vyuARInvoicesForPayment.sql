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
	,[dtmDiscountDate]			= CASE WHEN ISNULL(ARIFP.dblDiscountAvailable, 0) = 0
										  THEN NULL
										  ELSE CASE WHEN ISNULL(intDiscountDay, 0) = 0 OR ISNULL(intDiscountDay, 0) > DATEDIFF(DAY, DATEADD(DAY, 1-DAY(ARIFP.dtmDate), ARIFP.dtmDate), DATEADD(MONTH, 1, DATEADD(DAY, 1-DAY(ARIFP.dtmDate), ARIFP.dtmDate)))
													THEN DATEADD(DAY, 1, ARIFP.dtmDate)
											   ELSE DATEADD(DAY, intDiscountDay, ARIFP.dtmDate)
										  END
								  END
	,ysnACHActive					=  ISNULL(ysnACHActive, 0)
	,dblInvoiceDiscountAvailable
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
			,[dblDiscountAvailable]		= CASE WHEN ARI.[strTransactionType] IN ('Invoice', 'Debit Memo') THEN ARI.[dblDiscountAvailable] ELSE CAST(0 AS DECIMAL(18,6)) END
			,[dblBaseDiscountAvailable]	= CASE WHEN ARI.[strTransactionType] IN ('Invoice', 'Debit Memo') THEN ARI.[dblBaseDiscountAvailable] ELSE CAST(0 AS DECIMAL(18,6)) END
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
			,[strTicketNumbers]			= SCALETICKETS.strTicketNumbers
			,[strCustomerReferences]	= CUSTOMERREFERENCES.strCustomerReferences
			,[intTermId]				= ARI.[intTermId]
			,[ysnExcludeForPayment]     = (CASE WHEN ARI.strTransactionType = 'Customer Prepayment' AND (EXISTS(SELECT NULL FROM tblARInvoiceDetail WHERE intInvoiceId = ARI.intInvoiceId AND ISNULL(ysnRestricted, 0) = 1))
												THEN CONVERT(BIT, 1)
											WHEN ARI.strType = 'CF Tran'
												THEN CONVERT(BIT, 1)
											ELSE CONVERT(BIT, 0) 
										 END)
			,intPaymentMethodId				= ARC.intPaymentMethodId	
			,strPaymentMethod				= SMP.strPaymentMethod
			,ysnACHActive					= EFT.ysnActive
			,dblInvoiceDiscountAvailable	= CASE WHEN ARI.[strTransactionType] IN ('Invoice', 'Debit Memo') THEN ARI.[dblDiscountAvailable] ELSE CAST(0 AS DECIMAL(18,6)) END
		FROM
			[tblARInvoice] ARI
		INNER JOIN
			(SELECT 
				strCustomerNumber,
				[intEntityId],
				intPaymentMethodId
			 FROM 
				dbo.tblARCustomer) AS ARC ON ARI.[intEntityCustomerId] = ARC.[intEntityId] 
		INNER JOIN
			(SELECT	
				intEntityId,
				strName
			 FROM
				dbo.tblEMEntity) AS CE ON ARC.[intEntityId] = CE.intEntityId 
		LEFT OUTER JOIN
			(SELECT 
				intPaymentMethodID,
				strPaymentMethod
			 FROM
				dbo.tblSMPaymentMethod) AS SMP ON ARC.intPaymentMethodId = SMP.intPaymentMethodID
		LEFT OUTER JOIN 
			(
			SELECT
				 [intInvoiceId]
				,[strInvoiceReportNumber]
			FROM
				tblCFTransaction
			) CFT 
				ON ARI.[intInvoiceId] = CFT.[intInvoiceId]	
		LEFT JOIN
			(
				SELECT
					intEntityId,
					ysnActive
				FROM
					tblEMEntityEFTInformation
			) EFT ON CE.intEntityId = EFT.intEntityId				
		OUTER APPLY (
			SELECT strTicketNumbers = LEFT(strTicketNumber, LEN(strTicketNumber) - 1)
			FROM (
				SELECT CAST(T.strTicketNumber AS VARCHAR(200))  + ', '
				FROM dbo.tblARInvoiceDetail ID WITH(NOLOCK)		
				INNER JOIN (
					SELECT intTicketId
						 , strTicketNumber 
					FROM dbo.tblSCTicket WITH(NOLOCK)
				) T ON ID.intTicketId = T.intTicketId
				WHERE ID.intInvoiceId = ARI.intInvoiceId
				GROUP BY ID.intInvoiceId, ID.intTicketId, T.strTicketNumber
				FOR XML PATH ('')
			) INV (strTicketNumber)
		) SCALETICKETS
		OUTER APPLY (
			SELECT strCustomerReferences = LEFT(strCustomerReference, LEN(strCustomerReference) - 1)
			FROM (
				SELECT CAST(T.strCustomerReference AS VARCHAR(200))  + ', '
				FROM dbo.tblARInvoiceDetail ID WITH(NOLOCK)		
				INNER JOIN (
					SELECT intTicketId
						 , strCustomerReference 
					FROM dbo.tblSCTicket WITH(NOLOCK)
					WHERE ISNULL(strCustomerReference, '') <> ''
				) T ON ID.intTicketId = T.intTicketId
				WHERE ID.intInvoiceId = ARI.intInvoiceId
				GROUP BY ID.intInvoiceId, ID.intTicketId, T.strCustomerReference
				FOR XML PATH ('')
			) INV (strCustomerReference)
		) CUSTOMERREFERENCES
		WHERE
			[ysnPosted] = 1
			AND ysnCancelled = 0
			AND ysnExcludeFromPayment = 0
			AND strTransactionType != 'Credit Note'
			AND ((ARI.strType = 'Service Charge' AND ARI.ysnForgiven = 0) OR ((ARI.strType <> 'Service Charge' AND ARI.ysnForgiven = 1) OR (ARI.strType <> 'Service Charge' AND ARI.ysnForgiven = 0)))
			AND NOT(ARI.strType = 'Provisional' AND ARI.ysnProcessed = 1)
	
	
		UNION ALL


		SELECT 
			 [intTransactionId]			= APB.[intBillId]
			,[strTransactionNumber]		= APB.[strBillId]
			,[intInvoiceId]				= NULL
			,[strInvoiceNumber]			= ''
			,[intBillId]				= APB.[intBillId]
			,[strBillId]				= APB.[strBillId]
			,[strTransactionType]		= (CASE WHEN APB.[intTransactionType] = 1 THEN 'Voucher'
												WHEN APB.[intTransactionType] = 2 THEN 'Vendor Prepayment'
												WHEN APB.[intTransactionType] = 3 THEN 'Debit Memo'
												WHEN APB.[intTransactionType] = 7 THEN 'Invalid Type'
												WHEN APB.[intTransactionType] = 9 THEN '1099 Adjustment'
												WHEN APB.[intTransactionType] = 11 THEN 'Claim'
												WHEN APB.[intTransactionType] = 13 THEN 'Basis Advance'
												WHEN APB.[intTransactionType] = 14 THEN 'Deferred Interest'
												ELSE 'Invalid Type'
										   END)
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
			,ysnACHActive				= EFT.ysnActive
			,dblInvoiceDiscountAvailable= CAST(0 AS DECIMAL(18,6))
		FROM
			tblAPBill APB
		INNER JOIN
			tblEMEntityType EMET
				ON APB.[intEntityVendorId] = EMET.[intEntityId]
				AND EMET.[strType] = 'Customer'	
		INNER JOIN
			(SELECT 				
				[intEntityId],
				intPaymentMethodId,
				strVendorId
			 FROM 
				dbo.tblAPVendor) AS APV ON APV.[intEntityId] = APB.[intEntityVendorId] 
		INNER JOIN
			(SELECT	
				intEntityId,
				strName
			 FROM
				dbo.tblEMEntity) AS CE ON APV.[intEntityId] = CE.intEntityId 	
		LEFT OUTER JOIN
			(SELECT 
				intPaymentMethodID,
				strPaymentMethod
			 FROM
				dbo.tblSMPaymentMethod) AS SMP ON APV.intPaymentMethodId = SMP.intPaymentMethodID	
		LEFT OUTER JOIN
			(
				SELECT
				intEntityId,
				ysnActive
				FROM tblEMEntityEFTInformation
				) AS EFT ON CE.intEntityId = EFT.intEntityId								
		WHERE [ysnPosted] = 1 AND APB.intTransactionType IN (1,2,3,11) 
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