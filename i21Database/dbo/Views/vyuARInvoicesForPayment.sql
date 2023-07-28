﻿CREATE VIEW [dbo].[vyuARInvoicesForPayment]
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
											ELSE
											(CASE WHEN ARIFP.[strType] = 'CF Invoice' THEN
												(SELECT CAST(DATEADD(DAY, intDiscountDay, dtmDate) AS DATE) FROM tblSMTerm WHERE intTermID = ARIFP.[intTermId])
											ELSE
												[dbo].[fnGetDiscountDateBasedOnTerm](ARIFP.[dtmDate], ARIFP.[intTermId], GETDATE())
											END)
										  END
	,[ysnACHActive]						=  ISNULL(ysnACHActive, 0)
	,[dblInvoiceDiscountAvailable]		= ARIFP.[dblInvoiceDiscountAvailable]
 	,intSourceId						= ARIFP.intSourceId 
	,ysnClosed							= ARIFP.ysnClosed
	,ysnForgiven						= ARIFP.ysnForgiven
	,intDaysOld							= DATEDIFF(DAYOFYEAR, CAST(ARIFP.[dtmDate] AS DATE), CAST(GETUTCDATE() AS DATE))
	,intPayToBankAccountId				= ARIFP.intPayToBankAccountId
	,strPayToBankAccountNo				= ISNULL(ARIFP.strPayToBankAccountNo, '')
	,[dblConvenienceFee]				= ARIFP.[dblConvenienceFee]
	,[dblBaseConvenienceFee]			= ARIFP.[dblBaseConvenienceFee]
FROM (
		--AR TRANSACTIONS
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
			,[strTicketNumbers]					= ARI.[strTicketNumbers]
			,[strCustomerReferences]			= ARI.[strCustomerReferences]
			,[intTermId]						= ARI.[intTermId]
			,[ysnExcludeForPayment]				= (CASE WHEN ARI.[strTransactionType] = 'Customer Prepayment' AND PREPID.intInvoiceId IS NOT NULL
														THEN CONVERT(BIT, 1)
													WHEN ARI.[strType] = 'CF Tran'
														THEN CONVERT(BIT, 1)
													WHEN ARI.[strTransactionType] = 'Customer Prepayment' AND ISNULL(PREPAY.intPaymentId, 0) = 0
														THEN CONVERT(BIT, 1)
													WHEN ISNULL(ARI.ysnRefundProcessed, 0) = 1 AND ARI.dblAmountDue = 0
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
			,intSourceId						= ARI.intSourceId
			,ysnClosed							= CASE WHEN ISNULL(EOD.ysnClosed, 0) = 1 AND ISNULL(ONACCOUNT.intPOSPaymentId, 0) = 0 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
			,ysnForgiven						= ARI.ysnForgiven
			,intPayToBankAccountId				= PFBA.intBankAccountId
			,strPayToBankAccountNo				= PFBA.strBankAccountNo
			,[dblConvenienceFee]				= ARI.[dblConvenienceFee]
			,[dblBaseConvenienceFee]			= ARI.[dblBaseConvenienceFee]
		FROM dbo.tblARInvoice ARI WITH (NOLOCK)
		INNER JOIN tblARCustomer ARC WITH (NOLOCK) ON ARI.[intEntityCustomerId] = ARC.[intEntityId]
		INNER JOIN (
			SELECT intEntityId
				 , strAddress
			FROM dbo.tblEMEntityLocation WITH (NOLOCK)
			WHERE ysnDefaultLocation = 1
		) AS EL ON ARC.intEntityId = EL.intEntityId
		INNER JOIN tblEMEntity CE WITH (NOLOCK) ON ARC.[intEntityId] = CE.intEntityId 
		LEFT OUTER JOIN tblSMPaymentMethod SMP WITH (NOLOCK) ON ARC.intPaymentMethodId = SMP.intPaymentMethodID
		LEFT OUTER JOIN tblCFTransaction CFT WITH (NOLOCK) ON ARI.[intInvoiceId] = CFT.[intInvoiceId]	
		LEFT JOIN tblEMEntityEFTInformation EFT WITH (NOLOCK) ON CE.intEntityId = EFT.intEntityId AND ARI.intCurrencyId = EFT.intCurrencyId
		LEFT JOIN (
			SELECT intPaymentId
				 , ysnInvoicePrepayment
			FROM dbo.tblARPayment WITH (NOLOCK)
			WHERE ysnPosted = 1
			  AND ysnProcessedToNSF = 0
		) PREPAY ON ARI.intPaymentId = PREPAY.intPaymentId
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
				FROM tblARInvoiceDetail WITH (NOLOCK)
				WHERE intCurrencyExchangeRateTypeId IS NOT NULL
				GROUP BY intInvoiceId
			) B ON A.[intInvoiceDetailId] = B.[intInvoicedetailId]
			INNER JOIN tblSMCurrencyExchangeRateType SM WITH (NOLOCK) ON A.[intCurrencyExchangeRateTypeId] = SM.[intCurrencyExchangeRateTypeId]
			WHERE A.intCurrencyExchangeRateTypeId IS NOT NULL
		) FX ON ARI.[intInvoiceId] = FX.[intInvoiceId]						
		LEFT JOIN tblARPOS POS ON ARI.[intInvoiceId] = POS.[intInvoiceId]		
		LEFT JOIN tblARPOSLog POSLOG ON POS.intPOSLogId = POSLOG.intPOSLogId
		LEFT JOIN tblARPOSEndOfDay EOD ON POSLOG.intPOSEndOfDayId = EOD.intPOSEndOfDayId
		OUTER APPLY (
			SELECT TOP 1 intPOSPaymentId
			FROM tblARPOSPayment
			WHERE intPOSId = POS.intPOSId
			  AND strPaymentMethod = 'On Account'
			  AND ARI.strType = 'POS'
		) ONACCOUNT
		OUTER APPLY (
			SELECT TOP 1 intInvoiceId
			FROM tblARInvoiceDetail PID
			WHERE PID.intInvoiceId = ARI.intInvoiceId
			  AND PID.ysnRestricted = 1
			  AND ARI.strTransactionType = 'Customer Prepayment'
		) PREPID
		LEFT JOIN vyuCMBankAccount PFBA ON PFBA.intBankAccountId = ISNULL(ARI.intPayToCashBankAccountId, ISNULL(ARI.intDefaultPayToBankAccountId, 0))
		WHERE (ARI.[ysnPosted] = 1 OR (ARI.[ysnPosted] = 0 AND ARI.strComments = 'NSF Processed' AND ARI.strTransactionType = 'Overpayment'))
		  AND (ARI.ysnCancelled IS NULL OR ARI.ysnCancelled = 0)
		  AND ARI.strTransactionType != 'Credit Note'
		  AND (NOT(ARI.strType = 'Provisional' AND ARI.ysnProcessed = 1) OR ysnExcludeFromPayment = 1)
		  AND ARI.ysnProcessedToNSF = 0
	
		UNION ALL

		--AP TRANSACTIONS
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
			,[strAccountNumber]					= ARC.[strVendorAccountNum]
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
   			,[intSourceId] 						= NULL
			,ysnClosed							= CAST(0 AS BIT)
			,ysnForgiven						= CAST(0 AS BIT)
			,intPayToBankAccountId				= NULL
			,strPayToBankAccountNo				= NULL
			,[dblConvenienceFee]				= CAST(0 AS DECIMAL(18,6))
			,[dblBaseConvenienceFee]			= CAST(0 AS DECIMAL(18,6))
		FROM [vyuAPVouchersForARPayment] APB
		INNER JOIN tblAPVendor ARC WITH (NOLOCK) ON APB.intEntityCustomerId = ARC.intEntityId
		INNER JOIN (
			SELECT intEntityId
				 , strAddress
			FROM dbo.tblEMEntityLocation WITH (NOLOCK)
			WHERE ysnDefaultLocation = 1
		) AS EL ON APB.intEntityCustomerId = EL.intEntityId

		UNION ALL

		--EFT BUDGETS
		SELECT  
			 [intTransactionId]					= CB.intCustomerBudgetId
			,[strTransactionNumber]				= 'EFT Budget ' + CONVERT(NVARCHAR(50), CB.dtmBudgetDate, 101) COLLATE Latin1_General_CI_AS
			,[intInvoiceId]						= NULL
			,[strInvoiceNumber]					= 'EFT Budget ' + CONVERT(NVARCHAR(50), CB.dtmBudgetDate, 101) COLLATE Latin1_General_CI_AS
			,[intBillId]						= NULL
			,[strBillId]						= '' COLLATE Latin1_General_CI_AS
			,[strTransactionType]				= 'EFT Budget' COLLATE Latin1_General_CI_AS
			,[strType]							= 'EFT Budget' COLLATE Latin1_General_CI_AS
			,[intEntityCustomerId]				= CB.intEntityCustomerId
			,[strCustomerName]					= CE.strName
			,[strCustomerNumber]				= ARC.strCustomerNumber
			,[strAccountNumber]					= ARC.strAccountNumber
			,[strAddress]						= EL.strAddress
			,[intCompanyLocationId]				= EL.intWarehouseId
			,[intAccountId]						= ISNULL(SMCL.intARAccount, ARCP.intARAccountId)
			,[intCurrencyId]					= ARC.intCurrencyId	
			,[dtmDate]							= CB.dtmBudgetDate
			,[dtmDueDate]						= CB.dtmBudgetDate
			,[dtmPostDate]						= CB.dtmBudgetDate
			,[dblInvoiceTotal]					= CB.dblBudgetAmount
			,[dblBaseInvoiceTotal]				= CB.dblBudgetAmount
			,[dblDiscount]						= CAST(0 AS DECIMAL(18,6))
			,[dblBaseDiscount]					= CAST(0 AS DECIMAL(18,6))
			,[dblDiscountAvailable]				= CAST(0 AS DECIMAL(18,6))
			,[dblBaseDiscountAvailable]			= CAST(0 AS DECIMAL(18,6))
			,[dblInterest]						= CAST(0 AS DECIMAL(18,6))
			,[dblBaseInterest]					= CAST(0 AS DECIMAL(18,6))
			,[dblAmountDue]						= CB.dblBudgetAmount - CB.dblAmountPaid
			,[dblBaseAmountDue]					= CB.dblBudgetAmount - CB.dblAmountPaid
			,[dblPayment]						= CB.dblAmountPaid
			,[dblBasePayment]					= CB.dblAmountPaid
			,[ysnPosted]						= CAST(1 AS BIT)
			,[ysnPaid]							= CAST(0 AS BIT)
			,[intPaymentId]						= NULL
			,[dblTotalTermDiscount]				= CAST(0 AS DECIMAL(18,6))
			,[strInvoiceReportNumber]			= NULL
			,[strTicketNumbers]					= NULL
			,[strCustomerReferences]			= NULL
			,[intTermId]						= ARC.intTermsId
			,[ysnExcludeForPayment]				= CAST(0 AS BIT)
			,[intPaymentMethodId]				= ISNULL(PM.intPaymentMethodID, ARC.intPaymentMethodId)
			,[strPaymentMethod]					= ISNULL(PM.strPaymentMethod, SMP.strPaymentMethod)
			,[intCurrencyExchangeRateTypeId]	= NULL
			,[strCurrencyExchangeRateType]		= NULL
			,[intCurrencyExchangeRateId]		= NULL
			,[dblCurrencyExchangeRate]			= CAST(1 AS DECIMAL(18,6))
			,[ysnACHActive]						= CAST(1 AS BIT)
			,[dblInvoiceDiscountAvailable]		= CAST(0 AS DECIMAL(18,6))
			,[intSourceId]						= NULL
			,[ysnClosed]						= CAST(0 AS BIT)
			,ysnForgiven						= CAST(0 AS BIT)
			,intPayToBankAccountId				= NULL
			,strPayToBankAccountNo				= NULL
			,[dblConvenienceFee]				= CAST(0 AS DECIMAL(18,6))
			,[dblBaseConvenienceFee]			= CAST(0 AS DECIMAL(18,6))
		FROM dbo.tblARCustomerBudget CB WITH (NOLOCK)
		INNER JOIN (
			SELECT C.intEntityId
				, C.strCustomerNumber
				, C.intPaymentMethodId
				, C.intCurrencyId
				, C.intTermsId
				, C.strAccountNumber
			FROM dbo.tblARCustomer C WITH (NOLOCK)
			INNER JOIN dbo.tblEMEntityEFTInformation EFT WITH (NOLOCK) ON C.intEntityId = EFT.intEntityId
			WHERE EFT.ysnActive = 1
		) AS ARC ON CB.intEntityCustomerId = ARC.[intEntityId]
		INNER JOIN (
			SELECT intEntityId
				, intWarehouseId
				, strAddress
			FROM dbo.tblEMEntityLocation WITH (NOLOCK)
			WHERE ysnDefaultLocation = 1 
			  AND ISNULL(intWarehouseId, 0) <> 0
		) AS EL ON ARC.intEntityId = EL.intEntityId
		INNER JOIN tblEMEntity CE WITH (NOLOCK) ON ARC.[intEntityId] = CE.intEntityId 
		LEFT OUTER JOIN tblSMPaymentMethod SMP WITH (NOLOCK) ON ARC.intPaymentMethodId = SMP.intPaymentMethodID
		OUTER APPLY (
			SELECT TOP 1 intPaymentMethodID
					   , strPaymentMethod 
			FROM tblSMPaymentMethod
			WHERE LOWER(strPaymentMethod) LIKE '%ach%'
		) PM		
		INNER JOIN tblSMCompanyLocation SMCL WITH (NOLOCK) ON EL.intWarehouseId = SMCL.intCompanyLocationId
		CROSS APPLY (
			SELECT TOP 1 intARAccountId
			FROM tblARCompanyPreference
		) ARCP
		WHERE CB.dblBudgetAmount - CB.dblAmountPaid <> 0
	) ARIFP
LEFT OUTER JOIN tblSMTerm SMT WITH (NOLOCK) ON ARIFP.intTermId = SMT.intTermID
LEFT OUTER JOIN tblSMCompanyLocation SMCL WITH (NOLOCK) ON ARIFP.intCompanyLocationId = SMCL.intCompanyLocationId