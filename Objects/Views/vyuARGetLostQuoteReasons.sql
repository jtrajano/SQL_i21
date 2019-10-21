CREATE VIEW [dbo].[vyuARGetLostQuoteReasons]
AS
SELECT DISTINCT strLostQuoteReason 
FROM tblSOSalesOrder 
WHERE strTransactionType = 'Quote' AND strOrderStatus = 'Lost'