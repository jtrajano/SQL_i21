﻿CREATE VIEW [dbo].[vyuARPaymentReport]
AS

SELECT
	 [intPaymentId]			= ARP.[intPaymentId]
	,[strRecordNumber]		= ARP.[strRecordNumber]
	,[dtmDatePaid]			= ARP.[dtmDatePaid]
	,[strLocationName]		= SMCL.[strLocationName]
	,[strCurrency]			= SMC.[strCurrency]
	,[strPaymentInfo]		= ARP.[strPaymentInfo]
	,[strNotes]				= ARP.[strNotes]
	,[dblAmountPaid]		= ARP.[dblAmountPaid]
	,[dblUnappliedAmount]	= ARP.[dblUnappliedAmount]
	,[strBatchNumber]		= GLB.[strBatchId]
	,[intEntityCustomerId]	= ARP.[intEntityCustomerId]
	,[strCustomerNumber]	= ARC.[strCustomerNumber]
	,[strCustomerName]		= EME.[strName]
	,[strCustomerAddress]	= CASE WHEN ISNULL(EMEL.[intEntityLocationId],0) <> 0
									THEN [dbo].fnARFormatCustomerAddress(NULL, NULL, EMEL.[strLocationName], EMEL.[strAddress], EMEL.[strCity], EMEL.[strState], EMEL.[strZipCode], EMEL.[strCountry], EME.[strName], ARC.[ysnIncludeEntityName])
								WHEN ISNULL(EMEL1.[intEntityLocationId],0) <> 0
									THEN [dbo].fnARFormatCustomerAddress(NULL, NULL, EMEL1.[strLocationName], EMEL1.[strAddress], EMEL1.[strCity], EMEL1.[strState], EMEL1.[strZipCode], EMEL1.[strCountry], EME.[strName], ARC.[ysnIncludeEntityName])
							  ELSE 
								''
							  END
	,[dblCustomerARBalance]	= ARC.[dblARBalance]
	,[intInvoiceId]			= ARI.[intInvoiceId]
	,[strInvoiceNumber]		= ARI.[strInvoiceNumber]
	,[strInvoiceType]		= ARI.[strTransactionType]
	,[ysnIsCredit]			= CASE WHEN ARI.[strTransactionType] IN ('Credit Memo','Cash Refund','Overpayment','Prepayment') THEN 1 ELSE 0 END
	,[dblInvoiceTotal]		= ISNULL(ARI.[dblInvoiceTotal], 0.00) * (CASE WHEN ARI.[strTransactionType] IN ('Credit Memo','Cash Refund','Overpayment','Prepayment') THEN -1 ELSE 1 END)
	,[dtmDueDate]			= ARI.[dtmDueDate]
	,[dblInterest]			= ISNULL(ARPD.[dblInterest], 0.00)
	,[dblDiscount]			= ISNULL(ARPD.[dblDiscount], 0.00)
	,[dblPayment]			= ISNULL(ARPD.[dblPayment], 0.00)
	,[strCompanyName]		= CASE WHEN SMCL.[strUseLocationAddress] = 'Letterhead'
								THEN ''
							  ELSE
								(SELECT TOP 1 [strCompanyName] FROM tblSMCompanySetup)
							  END
	,[strCompanyAddress]	= CASE WHEN SMCL.[strUseLocationAddress] IS NULL OR SMCL.[strUseLocationAddress] IN ('','No','Always')
									THEN (SELECT TOP 1 [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, [strAddress], [strCity], [strState], [strZip], [strCountry], NULL, ARC.[ysnIncludeEntityName]) FROM tblSMCompanySetup)
								WHEN SMCL.strUseLocationAddress = 'Yes'
									THEN [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, SMCL.[strAddress], SMCL.[strCity], SMCL.[strStateProvince], SMCL.[strZipPostalCode], SMCL.[strCountry], NULL, ARC.[ysnIncludeEntityName])
								WHEN SMCL.[strUseLocationAddress] = 'Letterhead'
									THEN ''
							  END
FROM
	tblARPayment ARP
INNER JOIN
	tblARCustomer ARC
		ON ARP.[intEntityCustomerId] = ARC.[intEntityCustomerId]
INNER JOIN
	tblEMEntity EME
		ON ARC.[intEntityCustomerId] = EME.[intEntityId]
LEFT OUTER JOIN
	(
	SELECT
		 [intEntityLocationId]
		,[strLocationName]
		,[strAddress]
		,[intEntityId]
		,[strCountry]
		,[strState]
		,[strCity]
		,[strZipCode]
		,[intTermsId]
		,[intShipViaId]
	FROM
		[tblEMEntityLocation]
	WHERE
		ysnDefaultLocation = 1
	) EMEL
	ON ARC.[intEntityCustomerId] = EMEL.[intEntityId]
LEFT OUTER JOIN
	[tblEMEntityLocation] EMEL1
		ON ARC.[intBillToId] = EME.[intEntityId]
INNER JOIN
	tblSMCompanyLocation SMCL
		ON ARP.[intLocationId] = SMCL.[intCompanyLocationId]
LEFT OUTER JOIN
	tblSMCurrency SMC
		ON ARP.[intCurrencyId] = SMC.[intCurrencyID]
LEFT OUTER JOIN
	(
	SELECT --TOP 1
		 GLD.[intTransactionId]
		,GLD.[strTransactionId]
		,GLD.[intAccountId]
		,GLD.[strBatchId]
	FROM
		tblGLDetail GLD
	WHERE
			GLD.[strTransactionType] IN ('Receive Payments')
		AND GLD.[ysnIsUnposted] = 0
		AND GLD.[strCode] = 'AR'
	) GLB
		ON ARP.intPaymentId = GLB.intTransactionId
		AND ARP.intAccountId = GLB.intAccountId
		AND ARP.strRecordNumber = GLB.strTransactionId
LEFT OUTER JOIN
	tblARPaymentDetail ARPD
		ON ARP.[intPaymentId] = ARPD.[intPaymentId]
INNER JOIN
	tblARInvoice ARI
		ON ARPD.[intInvoiceId] = ARI.[intInvoiceId]	
	
UNION ALL

SELECT
	 [intPaymentId]			= ARP.[intPaymentId]
	,[strRecordNumber]		= ARP.[strRecordNumber]
	,[dtmDatePaid]			= ARP.[dtmDatePaid]
	,[strLocationName]		= SMCL.[strLocationName]
	,[strCurrency]			= SMC.[strCurrency]
	,[strPaymentInfo]		= ARP.[strPaymentInfo]
	,[strNotes]				= ARP.[strNotes]
	,[dblAmountPaid]		= ARP.[dblAmountPaid]
	,[dblUnappliedAmount]	= ARP.[dblUnappliedAmount]
	,[strBatchNumber]		= GLB.[strBatchId]
	,[intEntityCustomerId]	= ARP.[intEntityCustomerId]
	,[strCustomerNumber]	= ARC.[strCustomerNumber]
	,[strCustomerName]		= EME.[strName]
	,[strCustomerAddress]	= CASE WHEN ISNULL(EMEL.[intEntityLocationId],0) <> 0
									THEN [dbo].fnARFormatCustomerAddress(NULL, NULL, EMEL.[strLocationName], EMEL.[strAddress], EMEL.[strCity], EMEL.[strState], EMEL.[strZipCode], EMEL.[strCountry], EME.[strName], ARC.[ysnIncludeEntityName])
								WHEN ISNULL(EMEL1.[intEntityLocationId],0) <> 0
									THEN [dbo].fnARFormatCustomerAddress(NULL, NULL, EMEL1.[strLocationName], EMEL1.[strAddress], EMEL1.[strCity], EMEL1.[strState], EMEL1.[strZipCode], EMEL1.[strCountry], EME.[strName], ARC.[ysnIncludeEntityName])
							  ELSE
								''
							  END
	,[dblCustomerARBalance]	= ARC.[dblARBalance]
	,[intInvoiceId]			= ARI.[intInvoiceId]
	,[strInvoiceNumber]		= ARI.[strInvoiceNumber]
	,[strInvoiceType]		= ARI.[strTransactionType]
	,[ysnIsCredit]			= CASE WHEN ARI.[strTransactionType] IN ('Credit Memo','Cash Refund','Overpayment','Prepayment') THEN 1 ELSE 0 END
	,[dblInvoiceTotal]		= ISNULL(ARI.[dblInvoiceTotal], 0.00) * (CASE WHEN ARI.[strTransactionType] IN ('Credit Memo','Cash Refund','Overpayment','Prepayment') THEN -1 ELSE 1 END)
	,[dtmDueDate]			= ARI.[dtmDueDate]
	,[dblInterest]			= ISNULL(ARI.[dblInterest], 0.00) * (CASE WHEN ARI.[strTransactionType] IN ('Credit Memo','Cash Refund','Overpayment','Prepayment') THEN -1 ELSE 1 END)
	,[dblDiscount]			= ISNULL(ARI.[dblDiscount], 0.00) * (CASE WHEN ARI.[strTransactionType] IN ('Credit Memo','Cash Refund','Overpayment','Prepayment') THEN -1 ELSE 1 END)
	,[dblPayment]			= ISNULL(ARI.[dblInvoiceTotal], 0.00) * (CASE WHEN ARI.[strTransactionType] IN ('Credit Memo','Cash Refund','Overpayment','Prepayment') THEN -1 ELSE 1 END)
	,[strCompanyName]		= CASE WHEN SMCL.[strUseLocationAddress] = 'Letterhead'
								THEN ''
							  ELSE
								(SELECT TOP 1 [strCompanyName] FROM tblSMCompanySetup)
							  END
	,[strCompanyAddress]	= CASE WHEN SMCL.[strUseLocationAddress] IS NULL OR SMCL.[strUseLocationAddress] IN ('','No','Always')
									THEN (SELECT TOP 1 [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, [strAddress], [strCity], [strState], [strZip], [strCountry], NULL, ARC.[ysnIncludeEntityName]) FROM tblSMCompanySetup)
								WHEN SMCL.strUseLocationAddress = 'Yes'
									THEN [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, SMCL.[strAddress], SMCL.[strCity], SMCL.[strStateProvince], SMCL.[strZipPostalCode], SMCL.[strCountry], NULL, ARC.[ysnIncludeEntityName])
								WHEN SMCL.[strUseLocationAddress] = 'Letterhead'
									THEN ''
							  END
FROM
	tblARPayment ARP
INNER JOIN
	tblARCustomer ARC
		ON ARP.[intEntityCustomerId] = ARC.[intEntityCustomerId]
INNER JOIN
	tblEMEntity EME
		ON ARC.[intEntityCustomerId] = EME.[intEntityId]
LEFT OUTER JOIN
	(
	SELECT
		 [intEntityLocationId]
		,[strLocationName]
		,[strAddress]
		,[intEntityId]
		,[strCountry]
		,[strState]
		,[strCity]
		,[strZipCode]
		,[intTermsId]
		,[intShipViaId]
	FROM
		[tblEMEntityLocation]
	WHERE
		ysnDefaultLocation = 1
	) EMEL
	ON ARC.[intEntityCustomerId] = EMEL.[intEntityId]
LEFT OUTER JOIN
	[tblEMEntityLocation] EMEL1
		ON ARC.[intBillToId] = EME.[intEntityId]
INNER JOIN
	tblSMCompanyLocation SMCL
		ON ARP.[intLocationId] = SMCL.[intCompanyLocationId]
LEFT OUTER JOIN
	tblSMCurrency SMC
		ON ARP.[intCurrencyId] = SMC.[intCurrencyID]
LEFT OUTER JOIN
	(
	SELECT --TOP 1
		 GLD.[intTransactionId]
		,GLD.[strTransactionId]
		,GLD.[intAccountId]
		,GLD.[strBatchId]
	FROM
		tblGLDetail GLD
	WHERE
			GLD.[strTransactionType] IN ('Receive Payments')
		AND GLD.[ysnIsUnposted] = 0
		AND GLD.[strCode] = 'AR'
	) GLB
		ON ARP.intPaymentId = GLB.intTransactionId
		AND ARP.intAccountId = GLB.intAccountId
		AND ARP.strRecordNumber = GLB.strTransactionId
INNER JOIN
	tblARInvoice ARI
		ON ARP.[intPaymentId] = ARI.[intPaymentId]
		AND ARI.[ysnPosted] = 1	

GO