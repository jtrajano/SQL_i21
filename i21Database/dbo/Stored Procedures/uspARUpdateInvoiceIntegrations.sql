CREATE PROCEDURE [dbo].[uspARUpdateInvoiceIntegrations] 
	 @InvoiceId			INT = NULL	
	,@ForDelete			BIT = 0    
	,@UserId			INT = NULL
	,@InvoiceDetailId 	INT = NULL     
AS  

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF

DECLARE @intTranCount	 			INT
DECLARE @intInvoiceId				INT	  
	  , @intUserId					INT
	  , @intOriginalInvoiceId		INT
	  , @intSalesOrderId			INT
	  , @intItemContractHeaderId	INT
	  , @strTransactionType			NVARCHAR(25)
	  , @strBatchId     			NVARCHAR(100)
	  , @ysnFromItemContract		BIT
	  , @InvoiceIds					InvoiceId	  
	  , @InvoicesForContractDelete	InvoiceId

--For Prepaid Contract Update
DECLARE @dblValueToUpdate NUMERIC(18, 6),
		@intTransactionDetailId INT,
		@strScreenName NVARCHAR(50) = 'Prepayment',
		@strRowState  NVARCHAR(50)


SET @intTranCount = @@trancount;

BEGIN TRY
	IF @intTranCount = 0
		BEGIN TRANSACTION
	ELSE
		SAVE TRANSACTION uspARUpdateInvoiceIntegrations

	SET @intInvoiceId = @InvoiceId
	SET @intUserId = @UserId

	SELECT TOP 1 @intOriginalInvoiceId = intOriginalInvoiceId
			, @intSalesOrderId = intSalesOrderId
			, @strTransactionType = strTransactionType
			, @ysnFromItemContract = ISNULL(ysnFromItemContract, 0)
			, @strBatchId			= strBatchId
	FROM tblARInvoice 
	WHERE intInvoiceId = @InvoiceId

	IF @strTransactionType = 'Proforma Invoice'
		BEGIN
			IF @intTranCount = 0
				COMMIT TRANSACTION

			RETURN
		END

	EXEC dbo.[uspARUpdateProvisionalOnStandardInvoice] @intInvoiceId, @ForDelete, @intUserId
	
    --FOR PREPAID ITEM CONTRACT
	SELECT TOP 1 
		 @intItemContractHeaderId    = intItemContractHeaderId
		,@dblValueToUpdate         = ABS(dblTotal)
		,@intTransactionDetailId = intInvoiceDetailId
	FROM tblARInvoiceDetail
	WHERE intInvoiceId = @intInvoiceId
	AND intItemContractHeaderId IS NOT NULL	

	IF @ForDelete = 1
		BEGIN
			--IF PREPAID ITEM CONTRACT--Use FOR UPDATING PREPAID CONTRACT
			SET @dblValueToUpdate  = ABS(@dblValueToUpdate)
			SET @strRowState = 'delete'

			IF @strTransactionType IN ('Credit Memo', 'Credit Note') AND @intOriginalInvoiceId IS NOT NULL
				UPDATE tblARInvoice SET ysnCancelled = 0 WHERE intInvoiceId = @intOriginalInvoiceId

			IF ISNULL(@intSalesOrderId, 0) <> 0
				EXEC dbo.uspSOUpdateReservedStock @intSalesOrderId, 0
			EXEC dbo.uspIPInterCompanyPreStageInvoice @intInvoiceId, 'Deleted', @intUserId
		END
	ELSE IF NOT EXISTS (SELECT TOP 1 NULL FROM tblARInvoicePreStage WHERE intInvoiceId = @intInvoiceId AND strRowState = 'Deleted')
		BEGIN
			--IF PREPAID ITEM CONTRACT
		    SET @dblValueToUpdate  = -1 * ABS(@dblValueToUpdate)  

			IF EXISTS (SELECT TOP 1 NULL FROM tblARInvoicePreStage WHERE intInvoiceId = @intInvoiceId AND strRowState = 'Added')
			BEGIN
				EXEC dbo.uspIPInterCompanyPreStageInvoice @intInvoiceId, 'Modified', @intUserId
				SET @strRowState = 'update'
			END
			ELSE
			BEGIN
				EXEC dbo.uspIPInterCompanyPreStageInvoice @intInvoiceId, 'Added', @intUserId
				SET @strRowState = 'add'
			END
		END

	--UPDATE PREPAID ITEM CONTRACT
	IF ISNULL(@ysnFromItemContract, 0) <> 0
	BEGIN
		EXEC uspCTItemContractUpdateRemainingDollarValue @intItemContractHeaderId,  @dblValueToUpdate, @intUserId, @intTransactionDetailId , @strScreenName,  @strRowState, @intInvoiceId
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
	EXEC dbo.[uspARUpdateContractOnInvoice] @intInvoiceId, @ForDelete, @intUserId, @InvoiceIds
	EXEC dbo.[uspARUpdateItemContractOnInvoice] @intInvoiceId, @ForDelete, @intUserId
	IF @ForDelete = 1 AND @InvoiceDetailId IS NULL EXEC dbo.[uspCTBeforeInvoiceDelete] @intInvoiceId, @intUserId
	EXEC dbo.[uspARUpdateReturnedInvoice] @intInvoiceId, @ForDelete, @intUserId 
	EXEC dbo.[uspARUpdateInvoiceAccruals] @intInvoiceId	
	
	INSERT INTO @InvoiceIds(
		  intHeaderId
		, ysnForDelete
		, strBatchId
	) 
	SELECT intHeaderId 	= @intInvoiceId
		 , ysnForDelete = ISNULL(@ForDelete, 0)
		 , strBatchId 	= @strBatchId	

	EXEC dbo.[uspARUpdateInvoiceTransactionHistory] @InvoiceIds
	EXEC dbo.[uspARLogRiskPosition] @InvoiceIds, @UserId

	-- --PRICING LAYER
	-- INSERT INTO @InvoicesForContractDelete(
	-- 	  intHeaderId
	-- 	, intDetailId
	-- 	, ysnForDelete
	-- 	, strBatchId
	-- )--INVOICE HEADER DELETED 
	-- SELECT intHeaderId 	= intInvoiceId
	-- 	 , intDetailId	= intInvoiceDetailId
	-- 	 , ysnForDelete = CAST(1 AS BIT)
	-- 	 , strBatchId 	= @strBatchId
	-- FROM tblARInvoiceDetail ID
	-- WHERE (@ForDelete = 1 AND ID.intInvoiceId = @intInvoiceId)
	--    AND ID.intContractDetailId IS NOT NULL
	   
	-- WHILE EXISTS (SELECT TOP 1 NULL FROM @InvoicesForContractDelete)
	-- 	BEGIN
	-- 		DECLARE @intInvoiceToDelete			INT = NULL
	-- 			  , @intInvoiceDetailToDeleteId	INT = NULL

	-- 		SELECT TOP 1 @intInvoiceToDelete			= intHeaderId
	-- 			       , @intInvoiceDetailToDeleteId	= intDetailId
	-- 		FROM @InvoicesForContractDelete

	-- 		EXEC [dbo].[uspCTUpdatePricingLayer] @intInvoiceId 			= @intInvoiceToDelete
	-- 										   , @intInvoiceDetailId 	= @intInvoiceDetailToDeleteId
    -- 										   , @strScreen 			= 'Invoice'
    -- 										   , @intUserId				= @UserId
			
	-- 		DELETE FROM @InvoicesForContractDelete WHERE intHeaderId = @intInvoiceToDelete AND intDetailId = @intInvoiceDetailToDeleteId
	-- 	END

	IF @ForDelete = 1
		BEGIN
			EXEC [dbo].[uspGRDeleteStorageHistory] 'Invoice', @InvoiceId			
		END

	DELETE FROM [tblARTransactionDetail] WHERE [intTransactionId] = @intInvoiceId AND [strTransactionType] = (SELECT TOP 1 [strTransactionType] FROM tblARInvoice WHERE intInvoiceId = @intInvoiceId)

	IF @intTranCount = 0
		COMMIT;
END TRY
BEGIN CATCH
	DECLARE @strErrorMsg varchar(4000) = ERROR_MESSAGE()
	DECLARE @strThrow	 NVARCHAR(MAX) = 'RAISERROR(''' + @strErrorMsg + ''', 11, 1)'
	
	IF (@@version NOT LIKE '%2008%')
	BEGIN
		SET @strThrow = 'THROW 51000, ''' + @strErrorMsg + ''', 1'
		
		IF XACT_STATE() = -1
			ROLLBACK;
		IF XACT_STATE() = 1 AND @intTranCount = 0
			ROLLBACK
		IF XACT_STATE() = 1 AND @intTranCount > 0
			ROLLBACK TRANSACTION uspARUpdateInvoiceIntegrations;
	END

	EXEC sp_executesql @strThrow

END CATCH

GO
