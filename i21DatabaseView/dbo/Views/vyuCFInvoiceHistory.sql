CREATE VIEW [dbo].[vyuCFInvoiceHistory]
AS

SELECT cfProcessHistory.* , ISNULL(dblTotalAR,0) as dblTotalAR FROM tblCFInvoiceProcessHistory AS cfProcessHistory
LEFT JOIN (
			SELECT DISTINCT strInvoiceNumberHistory, dblTotalAR
			FROM tblCFCustomerStatementHistoryStagingTable
		) AS cfCustHistory
ON cfCustHistory.strInvoiceNumberHistory = cfProcessHistory.strInvoiceNumberHistory

GO


