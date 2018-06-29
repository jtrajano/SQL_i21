

CREATE VIEW [dbo].[vyuCFinvoiceGroupByVehicleHistory]
AS
SELECT   
strVehicleNumber, 
strItemNo, 
intAccountId, 
CONVERT(datetime, FLOOR(CONVERT(numeric(18, 6), dtmTransactionDate))) AS dtmFloorDate, 
MIN(dtmTransactionDate) AS dtmMinDate,
strInvoiceNumberHistory
FROM         dbo.tblCFInvoiceHistoryStagingTable AS t2
GROUP BY intAccountId, strVehicleNumber, strItemNo, CONVERT(datetime, FLOOR(CONVERT(numeric(18, 6), dtmTransactionDate))),strInvoiceNumberHistory