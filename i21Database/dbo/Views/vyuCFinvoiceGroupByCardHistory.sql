

CREATE VIEW [dbo].[vyuCFinvoiceGroupByCardHistory]
AS
SELECT   strCardNumber, strItemNo, intAccountId, CONVERT(datetime, FLOOR(CONVERT(numeric(18, 6), dtmTransactionDate))) AS dtmFloorDate, MIN(dtmTransactionDate) AS dtmMinDate,
strInvoiceNumberHistory
FROM         dbo.tblCFInvoiceHistoryStagingTable AS t2
GROUP BY intAccountId, strCardNumber, strItemNo, CONVERT(datetime, FLOOR(CONVERT(numeric(18, 6), dtmTransactionDate))) ,strInvoiceNumberHistory