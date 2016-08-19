CREATE PROCEDURE [dbo].[uspTFRefresh]

AS 

DELETE FROM tblTFTransactions
DELETE FROM tblTFTaxReportSummary