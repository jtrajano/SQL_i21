CREATE VIEW [dbo].[vyuARUnpostedTransactions]
AS

SELECT 
	strInvoiceNumber AS 'strTransactionId'
	,strTransactionType AS 'strTransactionType'
	,dtmDate AS 'dtmDate'
FROM
	tblARInvoice
WHERE
	ysnPosted = 0 
	AND strTransactionType IN ('Invoice','Credit Memo')
	
UNION ALL

SELECT 
	strRecordNumber  AS 'strTransactionId'
	,'Receive Payments' AS 'strTransactionType'
	,dtmDatePaid AS 'dtmDate'
FROM
	tblARPayment
WHERE
	ysnPosted = 0 