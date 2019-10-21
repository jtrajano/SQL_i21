CREATE VIEW [dbo].[vyuARGetLostQuoteCompetitors]
AS 
SELECT DISTINCT strLostQuoteCompetitor 
FROM tblSOSalesOrder 
WHERE strTransactionType = 'Quote' AND strOrderStatus = 'Lost'