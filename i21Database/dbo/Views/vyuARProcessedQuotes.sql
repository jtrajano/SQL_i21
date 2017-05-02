CREATE VIEW [dbo].[vyuARProcessedQuotes]
AS
SELECT strSalesOrderOriginId = strSalesOrderNumber
     , strQuoteType
FROM tblSOSalesOrder 
WHERE strTransactionType = 'Quote' 
AND ysnProcessed = 1
