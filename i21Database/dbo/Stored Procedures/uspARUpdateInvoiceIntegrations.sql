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

DECLARE @Ids AS Id
INSERT INTO @Ids(intId) SELECT @InvoiceId
EXEC dbo.[uspARUpdateTransactionAccounts] @Ids = @Ids, @TransactionType	= 1

EXEC dbo.[uspARUpdatePricingHistory] 2, @InvoiceId, @UserId
EXEC dbo.[uspARUpdateSOStatusFromInvoice] @InvoiceId, @ForDelete
EXEC dbo.[uspARUpdateItemComponent] @InvoiceId, 0
EXEC dbo.[uspARUpdateReservedStock] @InvoiceId, @ForDelete, @UserId, 0
EXEC dbo.[uspARUpdateItemComponent] @InvoiceId, 1
--AR-4579
--EXEC dbo.[uspARUpdateContractOnInvoice] @InvoiceId, @ForDelete, @UserId
EXEC dbo.[uspARUpdateInboundShipmentOnInvoice] @InvoiceId, @ForDelete, @UserId
EXEC dbo.[uspARUpdateProvisionalOnStandardInvoice] @InvoiceId, @ForDelete, @UserId
EXEC dbo.[uspARUpdateCommitted] @InvoiceId, @ForDelete, @UserId, 0

DELETE FROM [tblARTransactionDetail] WHERE [intTransactionId] = @InvoiceId AND [strTransactionType] = (SELECT TOP 1 [strTransactionType] FROM tblARInvoice WHERE intInvoiceId = @InvoiceId)

GO