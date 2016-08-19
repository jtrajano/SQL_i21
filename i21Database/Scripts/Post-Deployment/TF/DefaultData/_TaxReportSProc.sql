GO
PRINT 'START TF tblTFTaxReportSProc'
GO
TRUNCATE TABLE tblTFTaxReportSProc
DECLARE @FormCode NVARCHAR(100)

	SELECT TOP 1 @FormCode = strFormCode FROM tblTFReportingComponent WHERE strFormCode = 'MF-360'
		IF (@FormCode IS NOT NULL)
			BEGIN
				INSERT [dbo].[tblTFTaxReportSProc] ([strSPFormCode], [strSPInventory], [strSPInvoice], [strSPGenerateReport], [intConcurrencyId]) 
				VALUES (N'MF-360', N'uspTFGetInventoryTax', N'uspTFGetInvoiceTax', N'uspTFRunTax', 0)
			END

	SELECT TOP 1 @FormCode = strFormCode FROM tblTFReportingComponent WHERE strFormCode = 'SF-900'
		IF (@FormCode IS NOT NULL)
			BEGIN
				INSERT [dbo].[tblTFTaxReportSProc] ([strSPFormCode], [strSPInventory], [strSPInvoice], [strSPGenerateReport], [intConcurrencyId]) 
				VALUES (N'SF-900', N'uspTFGetInventoryTax', N'uspTFGetInvoiceTax', N'uspTFGenerateSF900', 0)
			END

	SELECT TOP 1 @FormCode = strFormCode FROM tblTFReportingComponent WHERE strFormCode = 'GT-103'
		IF (@FormCode IS NOT NULL)
			BEGIN
				INSERT [dbo].[tblTFTaxReportSProc] ([strSPFormCode], [strSPInventory], [strSPInvoice], [strSPGenerateReport], [intConcurrencyId]) 
				VALUES (N'GT-103', N'uspTFGT103InventoryTax', N'uspTFGT103InvoiceTax', N'uspTFGT103RunTax', 0)
			END

GO
PRINT 'END TF tblTFTaxReportSProc'
GO