﻿CREATE VIEW [dbo].[vyuARInvoicesForPayment]
AS

SELECT EOD.ysnClosed, vyuARInvoicesForPayments.* FROM (
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
	,[strCustomerName]					= ARIFP.[strCustomerName]
	,[strCustomerNumber]				= ARIFP.[strCustomerNumber]
	,[strAccountNumber]					= ARIFP.[strAccountNumber]
	,[strAddress]						= ARIFP.[strAddress]
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
	,[strInvoiceReportNumber]			= ARIFP.[strInvoiceReportNumber]
	,[strTicketNumbers]					= ARIFP.[strTicketNumbers]
	,[strCustomerReferences]			= ARIFP.[strCustomerReferences]
	,[intCompanyLocationId]				= SMCL.[intCompanyLocationId]
	,[strLocationName]					= SMCL.[strLocationName]
	,[intTermId]						= SMT.[intTermID]
	,[strTerm]							= SMT.[strTerm]
	,[strTermType]						= SMT.[strType] 
	,[intTermDiscountDay]				= SMT.[intDiscountDay] 
	,[dtmTermDiscountDate]				= SMT.[dtmDiscountDate]	
	,[dblTermDiscountEP]				= SMT.[dblDiscountEP]
	,[intTermBalanceDue]				= SMT.[intBalanceDue]
	,[dtmTermDueDate]					= SMT.[dtmDueDate]
	,[dblTermAPR]						= SMT.[dblAPR]
	,[ysnExcludeForPayment]				= ARIFP.[ysnExcludeForPayment]
	,[intPaymentMethodId]				= ARIFP.[intPaymentMethodId]	
	,[strPaymentMethod]					= ARIFP.[strPaymentMethod]
	,[intCurrencyExchangeRateTypeId]	= ARIFP.[intCurrencyExchangeRateTypeId]
	,[strCurrencyExchangeRateType]		= ARIFP.[strCurrencyExchangeRateType]
	,[intCurrencyExchangeRateId]		= ARIFP.[intCurrencyExchangeRateId]
	,[dblCurrencyExchangeRate]			= ARIFP.[dblCurrencyExchangeRate]
	,[dtmDiscountDate]					= CASE WHEN ISNULL(ARIFP.dblDiscountAvailable, 0) = 0
												  THEN NULL
												  ELSE [dbo].[fnGetDiscountDateBasedOnTerm](ARIFP.[dtmDate], SMT.[intTermID], GETDATE())
										  END
	,[ysnACHActive]						=  ISNULL(ysnACHActive, 0)
	,[dblInvoiceDiscountAvailable]		= ARIFP.[dblInvoiceDiscountAvailable]
 	,ARIFP.intSourceId  
FROM (
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
			,[strCustomerName]					= CE.strName
			,[strCustomerNumber]				= ARC.[strCustomerNumber]
			,[strAccountNumber]					= ARC.[strAccountNumber]
			,[strAddress]						= EL.[strAddress]
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
			,[strInvoiceReportNumber]			= CFT.strInvoiceReportNumber
			,[strTicketNumbers]					= SCALETICKETS.[strTicketNumbers]
			,[strCustomerReferences]			= CUSTOMERREFERENCES.[strCustomerReferences]
			,[intTermId]						= ARI.[intTermId]
			,[ysnExcludeForPayment]				= (CASE WHEN ARI.[strTransactionType] = 'Customer Prepayment' AND (EXISTS(SELECT NULL FROM tblARInvoiceDetail WHERE [intInvoiceId] = ARI.[intInvoiceId] AND ISNULL([ysnRestricted], 0) = 1))
														THEN CONVERT(BIT, 1)
													WHEN ARI.[strType] = 'CF Tran'
														THEN CONVERT(BIT, 1)
													ELSE CONVERT(BIT, 0) 
													END)
			,[intPaymentMethodId]				= ARC.[intPaymentMethodId]
			,[strPaymentMethod]					= SMP.[strPaymentMethod]
			,[intCurrencyExchangeRateTypeId]	= FX.[intCurrencyExchangeRateTypeId]
			,[strCurrencyExchangeRateType]		= FX.[strCurrencyExchangeRateType] COLLATE Latin1_General_CI_AS
			,[intCurrencyExchangeRateId]		= FX.[intCurrencyExchangeRateId]
			,[dblCurrencyExchangeRate]			= ISNULL(ARI.[dblCurrencyExchangeRate], FX.[dblCurrencyExchangeRate])
			,[ysnACHActive]						= EFT.[ysnActive]
			,[dblInvoiceDiscountAvailable]		= CASE WHEN ARI.[strTransactionType] IN ('Invoice', 'Debit Memo') THEN ARI.[dblDiscountAvailable] ELSE CAST(0 AS DECIMAL(18,6)) END
			,ARI.intSourceId
		FROM dbo.tblARInvoice ARI WITH (NOLOCK)
		INNER JOIN (
			SELECT intEntityId
				 , strCustomerNumber
				 , intPaymentMethodId
				 , strAccountNumber
			 FROM dbo.tblARCustomer WITH (NOLOCK)
		) AS ARC ON ARI.[intEntityCustomerId] = ARC.[intEntityId]
		INNER JOIN (
			SELECT intEntityId
				 , strAddress
			FROM dbo.tblEMEntityLocation WITH (NOLOCK)
			WHERE ysnDefaultLocation = 1
		) AS EL ON ARC.intEntityId = EL.intEntityId
		INNER JOIN (
			SELECT intEntityId
				 , strName
			FROM dbo.tblEMEntity WITH (NOLOCK)
		) AS CE ON ARC.[intEntityId] = CE.intEntityId 
		LEFT OUTER JOIN (
			SELECT intPaymentMethodID
				 , strPaymentMethod
			FROM dbo.tblSMPaymentMethod WITH (NOLOCK)
		) AS SMP ON ARC.intPaymentMethodId = SMP.intPaymentMethodID
		LEFT OUTER JOIN (
			SELECT intInvoiceId
				 , strInvoiceReportNumber
			FROM dbo.tblCFTransaction WITH (NOLOCK)
		) CFT ON ARI.[intInvoiceId] = CFT.[intInvoiceId]	
		LEFT JOIN (
			SELECT intEntityId
				 , ysnActive
			FROM dbo.tblEMEntityEFTInformation WITH (NOLOCK)
		) EFT ON CE.intEntityId = EFT.intEntityId
		LEFT JOIN (
			SELECT B.[intInvoiceId]
				 , A.[intCurrencyExchangeRateTypeId]
				 , A.[intCurrencyExchangeRateId]
				 , A.[dblCurrencyExchangeRate]
				 , SM.[strCurrencyExchangeRateType]
			FROM dbo.tblARInvoiceDetail A WITH (NOLOCK)
			INNER JOIN (
				SELECT [intInvoicedetailId]	= MIN([intInvoiceDetailId])
					 , [intInvoiceId]		= [intInvoiceId]
				FROM dbo.tblARInvoiceDetail WITH (NOLOCK)
				GROUP BY intInvoiceId
			) B ON A.[intInvoiceDetailId] = B.[intInvoicedetailId]
			INNER JOIN (
				SELECT intCurrencyExchangeRateTypeId
					 , strCurrencyExchangeRateType
				FROM dbo.tblSMCurrencyExchangeRateType WITH (NOLOCK)
			) SM ON A.[intCurrencyExchangeRateTypeId] = SM.[intCurrencyExchangeRateTypeId]
		) FX ON ARI.[intInvoiceId] = FX.[intInvoiceId]				
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
		WHERE ARI.[ysnPosted] = 1
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
			,[strCustomerName]					= APB.[strCustomerName]
			,[strCustomerNumber]				= APB.[strCustomerNumber]
			,[strAccountNumber]					= ARC.[strAccountNumber]
			,[strAddress]						= EL.[strAddress]
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
			,[strInvoiceReportNumber]			= APB.[strInvoiceReportNumber]
			,[strTicketNumbers]					= APB.[strTicketNumbers]
			,[strCustomerReferences]			= APB.[strCustomerReferences]
			,[intTermId]						= APB.[intTermId]
			,[ysnExcludeForPayment]				= APB.[ysnExcludeForPayment]
			,[intPaymentMethodId]				= APB.[intPaymentMethodId]
			,[strPaymentMethod]					= APB.[strPaymentMethod]
			,[intCurrencyExchangeRateTypeId]	= APB.[intCurrencyExchangeRateTypeId]
			,[strCurrencyExchangeRateType]		= APB.[strCurrencyExchangeRateType] COLLATE Latin1_General_CI_AS
			,[intCurrencyExchangeRateId]		= NULL
			,[dblCurrencyExchangeRate]			= APB.[dblCurrencyExchangeRate]
			,[ysnACHActive]						= APB.[ysnACHActive]
			,[dblInvoiceDiscountAvailable]		= APB.[dblInvoiceDiscountAvailable]
   			,[intSourceId] = NULL
		FROM [vyuAPVouchersForARPayment] APB
		INNER JOIN (
			SELECT intEntityId
				 , strAccountNumber
			 FROM dbo.tblARCustomer WITH (NOLOCK)
		) AS ARC ON APB.intEntityCustomerId = ARC.intEntityId
		INNER JOIN (
			SELECT intEntityId
				 , strAddress
			FROM dbo.tblEMEntityLocation WITH (NOLOCK)
			WHERE ysnDefaultLocation = 1
		) AS EL ON APB.intEntityCustomerId = EL.intEntityId
	) ARIFP
LEFT OUTER JOIN (
	SELECT intTermID
		 , strTerm
		 , strType
		 , intDiscountDay
		 , dtmDiscountDate
		 , dblDiscountEP
		 , intBalanceDue
		 , dtmDueDate
		 , dblAPR
	FROM dbo.tblSMTerm WITH (NOLOCK)
) SMT ON ARIFP.intTermId = SMT.intTermID
LEFT OUTER JOIN (
	SELECT intCompanyLocationId
		 , strLocationName
	FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
) SMCL ON ARIFP.intCompanyLocationId = SMCL.intCompanyLocationId
) vyuARInvoicesForPayments
LEFT JOIN tblARPOS POS on vyuARInvoicesForPayments.intSourceId = POS.intPOSId
LEFT JOIN vyuARPOSEndOfDay EOD on POS.intPOSLogId = EOD.intPOSLogId