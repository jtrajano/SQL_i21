﻿--Activate this on 17.3 for AR-3714

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

PRINT '********************** BEGIN - FIX INVALID PAYMENT METHOD **********************'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE [name] = N'intPaymentMethodId' AND [object_id] = OBJECT_ID(N'tblARPayment'))
  AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE [name] = N'intPaymentMethodID' AND [object_id] = OBJECT_ID(N'tblSMPaymentMethod'))
  AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE [name] = N'strPaymentMethod' AND [object_id] = OBJECT_ID(N'tblCMUndepositedFund'))
  
BEGIN
	IF OBJECT_ID('tempdb..#PAYMENTS') IS NOT NULL DROP TABLE #PAYMENTS	
	
	IF EXISTS (SELECT TOP 1 1 FROM sys.triggers WHERE [name] = 'trg_tblARPaymentUpdate')
		ALTER TABLE tblARPayment DISABLE TRIGGER trg_tblARPaymentUpdate

	DECLARE @intPaymentMethodId	INT				= NULL
		  , @strPaymentMethod	NVARCHAR(100)	= NULL

	SELECT TOP 1 @intPaymentMethodId	= intPaymentMethodID
			   , @strPaymentMethod		= strPaymentMethod
	FROM tblSMPaymentMethod
	WHERE strPaymentMethod NOT IN ('Write Off', 'ACH')
	ORDER BY intPaymentMethodID ASC

	IF @intPaymentMethodId IS NOT NULL
		BEGIN
			SELECT P.intPaymentId
				 , P.strRecordNumber
				 , P.strPaymentMethod
			INTO #PAYMENTS
			FROM tblARPayment P
			LEFT JOIN tblSMPaymentMethod PM ON P.intPaymentMethodId = PM.intPaymentMethodID
			WHERE intPaymentMethodId = 0
			   OR PM.intPaymentMethodID IS NULL
			   OR intPaymentMethodId IS NULL

			UPDATE P
			SET intPaymentMethodId	= CASE WHEN PM.intPaymentMethodID IS NULL THEN @intPaymentMethodId ELSE PM.intPaymentMethodID END
			  , strPaymentMethod	= CASE WHEN PM.intPaymentMethodID IS NULL THEN @strPaymentMethod ELSE PM.strPaymentMethod END
			FROM tblARPayment P
			INNER JOIN #PAYMENTS PP ON P.intPaymentId = PP.intPaymentId
			LEFT JOIN tblSMPaymentMethod PM ON P.strPaymentMethod = PM.strPaymentMethod	

			UPDATE UF
			SET strPaymentMethod = P.strPaymentMethod
			FROM tblCMUndepositedFund UF
			INNER JOIN #PAYMENTS PP ON UF.intSourceTransactionId = PP.intPaymentId AND UF.strSourceTransactionId = PP.strRecordNumber
			INNER JOIN tblARPayment P ON P.intPaymentId = PP.intPaymentId
		END

	IF EXISTS (SELECT TOP 1 1 FROM sys.triggers WHERE [name] = 'trg_tblARPaymentUpdate')
		ALTER TABLE tblARPayment ENABLE TRIGGER trg_tblARPaymentUpdate

	IF OBJECT_ID('tempdb..#PAYMENTS') IS NOT NULL DROP TABLE #PAYMENTS
END

PRINT '********************** END - FIX INVALID PAYMENT METHOD **********************'
GO