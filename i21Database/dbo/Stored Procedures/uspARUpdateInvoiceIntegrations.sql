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
  
DECLARE @intInvoiceId			INT
	  , @intUserId				INT
	  , @intOriginalInvoiceId	INT
	  , @strTransactionType		NVARCHAR(25)
	  	  
SET @intInvoiceId = @InvoiceId
SET @intUserId = @UserId

EXEC dbo.[uspARUpdateProvisionalOnStandardInvoice] @intInvoiceId, @ForDelete, @intUserId

IF @ForDelete = 1
	BEGIN
		SELECT TOP 1 @intOriginalInvoiceId = intOriginalInvoiceId
				   , @strTransactionType = strTransactionType
		FROM tblARInvoice 
		WHERE intInvoiceId = @InvoiceId 

		IF @strTransactionType = 'Credit Note' AND @intOriginalInvoiceId IS NOT NULL
			UPDATE tblARInvoice SET ysnCancelled = 0 WHERE intInvoiceId = @intOriginalInvoiceId
	END

EXEC dbo.[uspARUpdatePricingHistory] 2, @intInvoiceId, @intUserId
EXEC dbo.[uspSOUpdateOrderShipmentStatus] @intInvoiceId, 'Invoice', @ForDelete
EXEC dbo.[uspARUpdateItemComponent] @intInvoiceId, 0
EXEC dbo.[uspARUpdateReservedStock] @intInvoiceId, @ForDelete, @intUserId, 0
EXEC dbo.[uspARUpdateItemComponent] @intInvoiceId, 1
EXEC dbo.[uspARUpdateInboundShipmentOnInvoice] @intInvoiceId, @ForDelete, @intUserId
EXEC dbo.[uspARUpdateCommitted] @intInvoiceId, @ForDelete, @intUserId, 0
EXEC dbo.[uspARUpdateGrainOpenBalance] @intInvoiceId, @ForDelete, @intUserId
EXEC dbo.[uspARUpdateContractOnInvoice] @intInvoiceId, @ForDelete, @intUserId
EXEC dbo.[uspARUpdateReturnedInvoice] @intInvoiceId, @ForDelete, @intUserId 
EXEC dbo.[uspARUpdateInvoiceAccruals] @intInvoiceId

DECLARE @InvoiceIds InvoiceId
INSERT INTO @InvoiceIds(intHeaderId) SELECT @intInvoiceId
EXEC dbo.[uspARUpdateInvoiceTransactionHistory] @InvoiceIds
IF @ForDelete = 1
EXEC [dbo].[uspGRDeleteStorageHistory] 'Invoice',@InvoiceId

DELETE FROM [tblARTransactionDetail] WHERE [intTransactionId] = @intInvoiceId AND [strTransactionType] = (SELECT TOP 1 [strTransactionType] FROM tblARInvoice WHERE intInvoiceId = @intInvoiceId)

GO