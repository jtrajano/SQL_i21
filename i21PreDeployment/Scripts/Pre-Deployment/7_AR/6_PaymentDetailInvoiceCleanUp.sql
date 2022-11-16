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

PRINT '********************** BEGIN - FIX INVALID PAYMENT LOCATION **********************'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE [name] = N'intLocationId' AND [object_id] = OBJECT_ID(N'tblARPayment'))
  AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE [name] = N'intCompanyLocationId' AND [object_id] = OBJECT_ID(N'tblSMCompanyLocation'))
  
BEGIN
	DELETE P
	FROM tblARPayment P
	LEFT JOIN tblSMCompanyLocation CL ON P.intLocationId = CL.intCompanyLocationId
	WHERE (P.intLocationId = 0 OR ISNULL(CL.intCompanyLocationId, 0) = 0)
	   AND P.intLocationId IS NOT NULL
END

PRINT '********************** END - FIX INVALID PAYMENT LOCATION **********************'
GO
