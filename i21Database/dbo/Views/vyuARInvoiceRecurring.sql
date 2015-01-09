CREATE VIEW dbo.vyuARInvoiceRecurring
AS
SELECT     
 intInvoiceId AS intTransactionId
,strInvoiceNumber AS strTransactionNumber
,dtmDate
FROM 
dbo.tblARInvoice


