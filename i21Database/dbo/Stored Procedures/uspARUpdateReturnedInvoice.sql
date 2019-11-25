CREATE PROCEDURE [dbo].[uspARUpdateReturnedInvoice]
	 @InvoiceId		INT   
	,@ForDelete		BIT = 0
	,@UserId		INT = NULL     
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  

UPDATE tblARInvoice
SET [ysnReturned]	= CASE WHEN @ForDelete = 1 THEN 0 ELSE 1 END	
WHERE [intInvoiceId] IN (SELECT [intOriginalInvoiceId] FROM tblARInvoice WHERE [intInvoiceId] = @InvoiceId AND [strTransactionType] = 'Credit Memo')

UPDATE ID
SET [ysnReturned]	= CASE WHEN @ForDelete = 1 THEN 0 ELSE 1 END
FROM tblARInvoiceDetail ID
INNER JOIN tblARInvoiceDetail ORIGID ON ID.intInvoiceDetailId = ORIGID.intOriginalInvoiceDetailId
INNER JOIN tblARInvoice I ON ORIGID.intInvoiceId = I.intInvoiceId
WHERE I.intInvoiceId = @InvoiceId
  AND I.strTransactionType = 'Credit Memo'

GO	