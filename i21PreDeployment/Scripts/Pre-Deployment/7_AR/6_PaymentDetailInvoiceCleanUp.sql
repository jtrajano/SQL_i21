--Activate this on 17.3 for AR-3714

IF	(
	EXISTS(SELECT NULL FROM sys.tables WHERE name = N'tblARPaymentDetail') AND EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intInvoiceId' AND [object_id] = OBJECT_ID(N'tblARPaymentDetail'))
	AND
	EXISTS(SELECT NULL FROM sys.tables WHERE name = N'tblARPaymentDetail') AND EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intBillId' AND [object_id] = OBJECT_ID(N'tblARPaymentDetail'))
	AND
	EXISTS(SELECT NULL FROM sys.tables WHERE name = N'tblARInvoice') AND EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intInvoiceId' AND [object_id] = OBJECT_ID(N'tblARInvoice'))
	AND
	EXISTS(SELECT NULL FROM sys.tables WHERE name = N'tblAPBill') AND EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intBillId' AND [object_id] = OBJECT_ID(N'tblAPBill'))
	)
BEGIN
	DECLARE @strQuery NVARCHAR(MAX) = CAST('' AS NVARCHAR(MAX)) + '
		UPDATE tblARPaymentDetail
		SET
			[intInvoiceId] = NULL
		WHERE
			[intInvoiceId] IS NOT NULL
			AND [intBillId] IS NOT NULL
			AND NOT EXISTS (SELECT NULL FROM tblARInvoice WHERE tblARInvoice.[intInvoiceId] = tblARPaymentDetail.[intInvoiceId])
	
		UPDATE tblARPaymentDetail
		SET
			[intBillId] = NULL
		WHERE
			[intBillId] IS NOT NULL
			AND [intInvoiceId] IS NOT NULL
			AND NOT EXISTS (SELECT NULL FROM tblAPBill WHERE tblAPBill.[intBillId] = tblARPaymentDetail.[intBillId])
	
		DELETE FROM tblARPaymentDetail
		WHERE
			NOT EXISTS (SELECT NULL FROM tblARInvoice WHERE tblARInvoice.[intInvoiceId] = tblARPaymentDetail.[intInvoiceId])
			AND NOT EXISTS (SELECT NULL FROM tblAPBill WHERE tblAPBill.[intBillId] = tblARPaymentDetail.[intBillId])'

	EXEC sp_executesql @strQuery	
END