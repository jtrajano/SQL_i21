PRINT '********************** BEGIN - Rebuild AR Report Fields **********************'
GO

IF EXISTS ( SELECT * FROM sys.objects WHERE type = 'P' AND name = 'uspARUpdateInvoiceReportFields')
BEGIN
	EXEC [dbo].[uspARUpdateInvoiceReportFields] DEFAULT, 1
END

IF EXISTS ( SELECT * FROM sys.objects WHERE type = 'P' AND name = 'uspARUpdatePaymentInvoiceField')
BEGIN
	EXEC [dbo].[uspARUpdatePaymentInvoiceField] DEFAULT, 1
END

PRINT ' ********************** END - Rebuild AR Report Fields  **********************'
GO