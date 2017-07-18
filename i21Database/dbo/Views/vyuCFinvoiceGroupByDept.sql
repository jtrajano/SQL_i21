
CREATE VIEW [dbo].[vyuCFinvoiceGroupByDept]
AS
SELECT   strDepartment, strItemNo, intAccountId, CONVERT(datetime, FLOOR(CONVERT(numeric(18, 6), dtmTransactionDate))) AS dtmFloorDate, MIN(dtmTransactionDate) 
                         AS dtmMinDate
FROM         dbo.tblCFInvoiceStagingTable AS t2
GROUP BY intAccountId, strDepartment, strItemNo, CONVERT(datetime, FLOOR(CONVERT(numeric(18, 6), dtmTransactionDate)))