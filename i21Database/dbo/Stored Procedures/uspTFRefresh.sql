CREATE PROCEDURE [dbo].[uspTFRefresh]

@Guid NVARCHAR(150)

AS 

DELETE FROM tblTFTransactions --WHERE uniqTransactionGuid = @Guid
DELETE FROM tblTFTaxReportSummary --WHERE strSummaryGuid = @Guid