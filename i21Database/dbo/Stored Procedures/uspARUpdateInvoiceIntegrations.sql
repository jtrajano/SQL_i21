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
  
DECLARE @intInvoiceId				INT	  
	  , @intUserId					INT
	  , @intOriginalInvoiceId		INT
	  , @intSalesOrderId			INT
	  , @intItemContractHeaderId	INT
	  , @strTransactionType			NVARCHAR(25)
	  , @ysnFromItemContract		BIT
	  , @InvoiceIds					InvoiceId
	  	  
SET @intInvoiceId = @InvoiceId
SET @intUserId = @UserId

SELECT TOP 1 @intOriginalInvoiceId = intOriginalInvoiceId
		   , @intSalesOrderId = intSalesOrderId
		   , @strTransactionType = strTransactionType
		   , @ysnFromItemContract = ISNULL(ysnFromItemContract, 0)
FROM tblARInvoice 
WHERE intInvoiceId = @InvoiceId

IF @strTransactionType = 'Proforma Invoice'
	RETURN

EXEC dbo.[uspARUpdateProvisionalOnStandardInvoice] @intInvoiceId, @ForDelete, @intUserId

IF @ForDelete = 1
	BEGIN
		IF @strTransactionType IN ('Credit Memo', 'Credit Note') AND @intOriginalInvoiceId IS NOT NULL
			UPDATE tblARInvoice SET ysnCancelled = 0 WHERE intInvoiceId = @intOriginalInvoiceId

		IF ISNULL(@intSalesOrderId, 0) <> 0
			EXEC dbo.uspSOUpdateReservedStock @intSalesOrderId, 0

		--UPDATE PREPAID ITEM CONTRACT
		IF ISNULL(@ysnFromItemContract, 0) <> 0
			BEGIN
				SELECT TOP 1 @intItemContractHeaderId = intItemContractHeaderId
				FROM tblARInvoiceDetail
				WHERE intInvoiceId = @intInvoiceId
				  AND intItemContractHeaderId IS NOT NULL

				--UPDATE tblCTItemContractHeader SET ysnPrepaid = 0 WHERE intItemContractHeaderId = @intItemContractHeaderId  
			END
	END
	
EXEC dbo.[uspARUpdatePricingHistory] 2, @intInvoiceId, @intUserId
EXEC dbo.[uspSOUpdateOrderShipmentStatus] @intInvoiceId, 'Invoice', @ForDelete
IF @ForDelete = 0 EXEC dbo.[uspARUpdateRemoveSalesOrderStatus] @intInvoiceId
EXEC dbo.[uspARUpdateItemComponent] @intInvoiceId, @ForDelete
EXEC dbo.[uspARUpdateLineItemLotDetail] @intInvoiceId
EXEC dbo.[uspARUpdateReservedStock] @intInvoiceId, @ForDelete, @intUserId, 0
EXEC dbo.[uspARUpdateInboundShipmentOnInvoice] @intInvoiceId, @ForDelete, @intUserId
EXEC dbo.[uspARUpdateCommitted] @intInvoiceId, @ForDelete, @intUserId, 0
EXEC dbo.[uspARUpdateGrainOpenBalance] @intInvoiceId, @ForDelete, @intUserId
EXEC dbo.[uspARUpdateContractOnInvoice] @intInvoiceId, @ForDelete, @intUserId, 0, @InvoiceIds
EXEC dbo.[uspARUpdateItemContractOnInvoice] @intInvoiceId, @ForDelete, @intUserId
IF @ForDelete = 1 EXEC dbo.[uspCTBeforeInvoiceDelete] @intInvoiceId, @intUserId
EXEC dbo.[uspARUpdateReturnedInvoice] @intInvoiceId, @ForDelete, @intUserId 
EXEC dbo.[uspARUpdateInvoiceAccruals] @intInvoiceId

INSERT INTO @InvoiceIds(intHeaderId) SELECT @intInvoiceId
EXEC dbo.[uspARUpdateInvoiceTransactionHistory] @InvoiceIds
IF @ForDelete = 1
EXEC [dbo].[uspGRDeleteStorageHistory] 'Invoice',@InvoiceId

DELETE FROM [tblARTransactionDetail] WHERE [intTransactionId] = @intInvoiceId AND [strTransactionType] = (SELECT TOP 1 [strTransactionType] FROM tblARInvoice WHERE intInvoiceId = @intInvoiceId)

GO