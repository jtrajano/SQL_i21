/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 tblARInvoiceGrossMarginSummary table is used in Gross Margin Chart in Dashboard
 -------------------------------------------------------------------------------------
*/
GO
IF NOT EXISTS (SELECT TOP 1 1 FROM tblARInvoiceGrossMarginSummary )
BEGIN
	PRINT('Started initializing summary data for invoice gross margin')

	EXEC dbo.uspARInvoiceGrossMarginSummary @ysnRebuild = 1

	PRINT('Finished initializing summary data for invoice gross margin')
END
GO