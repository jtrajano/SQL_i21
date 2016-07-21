CREATE VIEW [dbo].[vyuARUnpostedTransactions]
AS

SELECT 
	 I.strInvoiceNumber		AS 'strTransactionId'
	,I.strTransactionType	AS 'strTransactionType'
	,I.dtmDate				AS 'dtmDate'
	,I.intInvoiceId			AS 'intTransactionId'
	,E.strName				AS 'strUserName'
	,I.strComments			AS 'strDescription'
	,I.intEntityCustomerId	AS 'intEntityId' 
FROM
	tblARInvoice I
INNER JOIN
	tblEntity E 
		ON I.intEntityId = E.intEntityId 
WHERE
	I.ysnPosted = 0 
	AND I.strTransactionType IN ('Invoice','Credit Memo')
	AND ISNULL(I.intDistributionHeaderId, 0) = 0
	AND I.ysnTemplate = 0
	AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
	
UNION ALL

SELECT 
	 P.strRecordNumber		AS 'strTransactionId'
	,'Receive Payments'		AS 'strTransactionType'
	,P.dtmDatePaid			AS 'dtmDate'
	,P.intPaymentId 		AS 'intTransactionId'
	,E.strName				AS 'strUserName'
	,P.strNotes 			AS 'strDescription'
	,P.intEntityId			AS 'intEntityId' 
FROM
	tblARPayment P
INNER JOIN
	tblEntity E 
		ON P.intEntityId = E.intEntityId 	
WHERE
	ysnPosted = 0
