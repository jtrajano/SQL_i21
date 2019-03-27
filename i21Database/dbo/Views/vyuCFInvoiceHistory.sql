CREATE VIEW [dbo].[vyuCFInvoiceHistory]
AS

SELECT 
cfProcessHistory.* ,
 ISNULL(dblTotalAR,0) as dblTotalAR,
 ysnRemittancePage = (CASE WHEN  ISNULL(dblTotalAR,0) > 0 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END)
 FROM tblCFInvoiceProcessHistory AS cfProcessHistory
LEFT JOIN (
			SELECT DISTINCT strInvoiceNumberHistory, dblTotalAR
			FROM tblCFCustomerStatementHistoryStagingTable
		) AS cfCustHistory
ON cfCustHistory.strInvoiceNumberHistory = cfProcessHistory.strInvoiceNumberHistory

GO


