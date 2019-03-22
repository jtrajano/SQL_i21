CREATE VIEW [dbo].[vyuARProvisionalInvoices]
AS 
SELECT intInvoiceId
     , dblInvoiceTotal = dblInvoiceTotal * -1
	 , dblAmountDue
	 , dblPayment
FROM dbo.tblARInvoice WITH (NOLOCK)
WHERE ysnProcessed = 1
  AND strType = 'Provisional'