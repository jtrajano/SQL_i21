﻿CREATE VIEW [dbo].[vyuCFInvoiceHistory]
AS

WITH INVCYCLE (
	strInvoiceReportNumber , intCustomerId , strInvoiceCycle
)
AS
(
	SELECT  strInvoiceReportNumber , intCustomerId , strInvoiceCycle 
	FROM tblCFInvoiceHistoryStagingTable 
	GROUP BY strInvoiceReportNumber , intCustomerId , strInvoiceCycle
)

SELECT 
strInvoiceCycle = (SELECT TOP 1 strInvoiceCycle FROM INVCYCLE where strInvoiceReportNumber = cfProcessHistory.strInvoiceNumberHistory and intCustomerId = cfProcessHistory.intCustomerId),
cfProcessHistory.* ,
 ISNULL(dblTotalAR,0) as dblTotalAR,
 ysnRemittancePage = (
						CASE WHEN  ISNULL(dblTotalAR,0) > 0 
						THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) 
						END
					  )
 FROM tblCFInvoiceProcessHistory AS cfProcessHistory
LEFT JOIN (
			SELECT DISTINCT strInvoiceNumberHistory, dblTotalAR
			FROM tblCFCustomerStatementHistoryStagingTable
		) AS cfCustHistory
ON cfCustHistory.strInvoiceNumberHistory = cfProcessHistory.strInvoiceNumberHistory

GO
