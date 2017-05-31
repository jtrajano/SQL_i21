PRINT N'***** BEGIN Set Foreign ID To Default (Patronage) *****'
GO
BEGIN
	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblPATDividendsCustomer' AND  [COLUMN_NAME] = 'intBillId')
	BEGIN
		UPDATE tblPATDividendsCustomer
		SET intBillId = NULL
		WHERE intBillId = 0
	END

	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblPATEquityPaySummary' AND  [COLUMN_NAME] = 'intBillId')
	BEGIN
		UPDATE tblPATEquityPaySummary
		SET intBillId = NULL
		WHERE intBillId = 0
	END

	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblPATRefundCustomer' AND  [COLUMN_NAME] = 'intBillId')
	BEGIN
		UPDATE tblPATRefundCustomer
		SET intBillId = NULL
		WHERE intBillId = 0
	END

	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblPATCustomerStock' AND  [COLUMN_NAME] = 'intBillId')
	BEGIN
		UPDATE tblPATCustomerStock
		SET intBillId = NULL
		WHERE intBillId = 0
	END

	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblPATCustomerStock' AND  [COLUMN_NAME] = 'intInvoiceId')
	BEGIN
		UPDATE tblPATCustomerStock
		SET intInvoiceId = NULL
		WHERE intInvoiceId = 0
	END
END
GO
PRINT N'***** END Set Foreign ID To Default (Patronage) *****'