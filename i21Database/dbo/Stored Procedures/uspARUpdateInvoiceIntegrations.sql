CREATE PROCEDURE [dbo].[uspARUpdateInvoiceIntegrations] 
	 @InvoiceId		INT = NULL
	,@ForDelete		BIT = 0    
	,@UserId		INT = NULL     
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  

EXEC dbo.[uspARUpdateSOStatusFromInvoice] @InvoiceId, @ForDelete
EXEC dbo.[uspARUpdateItemComponent] @InvoiceId
EXEC dbo.[uspARUpdateCommitted] @InvoiceId, @ForDelete, @UserId, 0
EXEC dbo.[uspARUpdateContractOnInvoice] @InvoiceId, @ForDelete, @UserId
EXEC dbo.[uspARUpdateInboundShipmentOnInvoice] @InvoiceId, @ForDelete, @UserId
EXEC dbo.[uspARUpdateProvisionalOnStandardInvoice] @InvoiceId, @ForDelete, @UserId

DELETE FROM [tblARTransactionDetail] WHERE [intTransactionId] = @InvoiceId AND [strTransactionType] = (SELECT TOP 1 [strTransactionType] FROM tblARInvoice WHERE intInvoiceId = @InvoiceId)

GO