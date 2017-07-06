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

DECLARE @intInvoiceId INT
	  , @intUserId    INT

SET @intInvoiceId = @InvoiceId
SET @intUserId = @UserId

EXEC dbo.[uspARUpdatePricingHistory] 2, @intInvoiceId, @intUserId
EXEC dbo.[uspARUpdateSOStatusFromInvoice] @intInvoiceId, @ForDelete
EXEC dbo.[uspARUpdateItemComponent] @intInvoiceId, 0
EXEC dbo.[uspARUpdateReservedStock] @intInvoiceId, @ForDelete, @intUserId, 0
EXEC dbo.[uspARUpdateItemComponent] @intInvoiceId, 1
EXEC dbo.[uspARUpdateInboundShipmentOnInvoice] @intInvoiceId, @ForDelete, @intUserId
EXEC dbo.[uspARUpdateProvisionalOnStandardInvoice] @intInvoiceId, @ForDelete, @intUserId
EXEC dbo.[uspARUpdateCommitted] @intInvoiceId, @ForDelete, @intUserId, 0

DELETE FROM [tblARTransactionDetail] WHERE [intTransactionId] = @intInvoiceId AND [strTransactionType] = (SELECT TOP 1 [strTransactionType] FROM tblARInvoice WHERE intInvoiceId = @intInvoiceId)

GO