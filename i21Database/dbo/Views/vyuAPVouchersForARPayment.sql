CREATE VIEW [dbo].[vyuAPVouchersForARPayment]
AS

SELECT 
			 [intTransactionId]			= APB.[intBillId]
			,[strTransactionNumber]		= APB.[strBillId]
			,[intInvoiceId]				= NULL
			,[strInvoiceNumber]			= '' COLLATE Latin1_General_CI_AS
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
												ELSE 'Invalid Type' COLLATE Latin1_General_CI_AS
										   END) COLLATE Latin1_General_CI_AS
			,[strType]					= 'Voucher' COLLATE Latin1_General_CI_AS
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
			,[ysnPosted]				= case when APB.[intTransactionType] = 11 then cast(1 as bit) else APB.[ysnPosted] end
			,[ysnPaid]					= APB.[ysnPaid]
			,[intPaymentId]				= NULL
			,[dblTotalTermDiscount]		= CAST(0 AS DECIMAL(18,6))
			,[strInvoiceReportNumber]	= '' COLLATE Latin1_General_CI_AS
			,[strTicketNumbers]			= '' COLLATE Latin1_General_CI_AS
			,[strCustomerReferences]	= '' COLLATE Latin1_General_CI_AS
			,[intTermId]				= APB.[intTermsId]
			,[ysnExcludeForPayment]		= APB.ysnPaid 
			,intPaymentMethodId			= APV.intPaymentMethodId	
			,strPaymentMethod			= SMP.strPaymentMethod
			,ysnACHActive				= EFT.ysnActive
			,dblInvoiceDiscountAvailable= CAST(0 AS DECIMAL(18,6))
			,intCurrencyExchangeRateTypeId	= NULL
			,strCurrencyExchangeRateType	= '' COLLATE Latin1_General_CI_AS
			,[dblCurrencyExchangeRate]		= 1.000000
		FROM
			tblAPBill APB
		INNER JOIN
			tblEMEntityType EMET
				ON APB.[intEntityVendorId] = EMET.[intEntityId]
				AND EMET.[strType] = 'Vendor'	
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
		LEFT OUTER JOIN
			(
				SELECT
					LGWCD.[intBillId]
				FROM
					tblLGWeightClaimDetail LGWCD
				INNER JOIN
					tblLGWeightClaim LGWC
						ON LGWCD.intWeightClaimId = LGWC.intWeightClaimId
				WHERE
					LGWC.[ysnPosted] = 1
			) LGWC
				ON APB.[intBillId] = LGWC.[intBillId] 				
		WHERE  (
				(APB.[ysnPosted] = 1 AND APB.intTransactionType IN (1,3))
				OR
				(APB.[ysnPosted] = 0 AND APB.intTransactionType = 11 AND LGWC.[intBillId] IS NOT NULL)
				OR
				(APB.[ysnPosted] = 1 AND APB.intTransactionType = 2 AND APB.intBillId NOT IN (
																								SELECT
																									APPD.[intTransactionId]
																								FROM
																									tblAPAppliedPrepaidAndDebit APPD
																								INNER JOIN
																									tblAPBillDetail APBD
																										ON APPD.[intBillId] = APBD.[intBillId]
																										AND APPD.[ysnApplied] = 1
																								INNER JOIN
																									tblICInventoryReceiptItem ICIRC
																										ON APBD.[intInventoryReceiptItemId] = ICIRC.[intInventoryReceiptItemId]
																								INNER JOIN
																									tblICInventoryReceipt ICIR
																										ON ICIRC.[intInventoryReceiptId] = ICIR.[intInventoryReceiptId]
																										AND ICIR.[intSourceType] = 2
																								INNER JOIN
																									tblLGLoadDetail LGLD
																										ON ICIRC.[intSourceId] = LGLD.[intLoadDetailId]
																								INNER JOIN
																									tblLGWeightClaim LGWC
																										ON LGLD.[intLoadId] = LGWC.[intLoadId]
																										AND LGWC.[ysnPosted] = 1
																							  ))
				)
