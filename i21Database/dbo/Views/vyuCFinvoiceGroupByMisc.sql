


CREATE VIEW [dbo].[vyuCFinvoiceGroupByMisc]
AS
SELECT   strUserId,strMiscellaneous, strItemNo, intAccountId, CONVERT(datetime, FLOOR(CONVERT(numeric(18, 6), dtmTransactionDate))) AS dtmFloorDate, MIN(dtmTransactionDate) 
                         AS dtmMinDate,strStatementType
FROM         dbo.tblCFInvoiceStagingTable AS t2
GROUP BY intAccountId, strMiscellaneous, strItemNo, CONVERT(datetime, FLOOR(CONVERT(numeric(18, 6), dtmTransactionDate))), strUserId,strStatementType