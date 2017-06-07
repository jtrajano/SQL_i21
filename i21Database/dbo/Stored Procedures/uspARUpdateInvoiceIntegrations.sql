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
	  , @ysnForDelete BIT

SET @intInvoiceId = @InvoiceId
SET @intUserId = @UserId
SET @ysnForDelete = @ForDelete

IF (@intInvoiceId IS NULL)
	BEGIN
		SET @ysnForDelete = 0
	END
ELSE
	BEGIN
		SET @ysnForDelete = 1
	END

EXEC dbo.[uspARUpdatePricingHistory] 2, @intInvoiceId, @intUserId
EXEC dbo.[uspARUpdateSOStatusFromInvoice] @intInvoiceId, @ysnForDelete
EXEC dbo.[uspARUpdateItemComponent] @intInvoiceId, 0
EXEC dbo.[uspARUpdateReservedStock] @intInvoiceId, @ysnForDelete, @intUserId, 0
EXEC dbo.[uspARUpdateItemComponent] @intInvoiceId, 1
EXEC dbo.[uspARUpdateInboundShipmentOnInvoice] @intInvoiceId, @ysnForDelete, @intUserId
EXEC dbo.[uspARUpdateProvisionalOnStandardInvoice] @intInvoiceId, @ysnForDelete, @intUserId
EXEC dbo.[uspARUpdateCommitted] @intInvoiceId, @ysnForDelete, @intUserId, 0

DELETE FROM [tblARTransactionDetail] WHERE [intTransactionId] = @intInvoiceId AND [strTransactionType] = (SELECT TOP 1 [strTransactionType] FROM tblARInvoice WHERE intInvoiceId = @intInvoiceId)

GO