CREATE PROCEDURE [dbo].[uspARUpdateContractOnPost]
    @intUserId  INT
AS

DECLARE @strErrorMsg	NVARCHAR(500) = NULL

BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	WHILE EXISTS(SELECT TOP 1 NULL FROM ##ARItemsForContracts)
		BEGIN
			DECLARE @intInvoiceDetailId		INT = NULL
				  , @intContractDetailId	INT = NULL
				  , @strType				NVARCHAR(100) = NULL
				  , @dblQuantity			NUMERIC(18, 6) = 0
				  , @dblBalanceQty			NUMERIC(18, 6) = 0
				  , @dblSheduledQty			NUMERIC(18, 6) = 0
				  , @dblRemainingQty		NUMERIC(18, 6) = 0

			SELECT TOP 1 @intInvoiceDetailId	= intInvoiceDetailId
					   , @intContractDetailId	= intContractDetailId
					   , @strType				= strType
					   , @dblQuantity			= dblQuantity
					   , @dblBalanceQty			= dblBalanceQty
					   , @dblSheduledQty		= dblSheduledQty
					   , @dblRemainingQty		= dblRemainingQty
			FROM ##ARItemsForContracts

			IF @strType = 'Contract Balance' AND @dblBalanceQty <> 0
				BEGIN
					EXEC dbo.uspCTUpdateSequenceBalance @intContractDetailId = @intContractDetailId
													  , @dblQuantityToUpdate = @dblBalanceQty
													  , @intUserId			 = @intUserId
													  , @intExternalId		 = @intInvoiceDetailId
													  , @strScreenName		 = 'Invoice'
													  , @ysnFromInvoice 	 = 1
				END

			IF @strType = 'Contract Scheduled' AND @dblSheduledQty <> 0
				BEGIN
					EXEC dbo.uspCTUpdateScheduleQuantity @intContractDetailId = @intContractDetailId
													  , @dblQuantityToUpdate = @dblSheduledQty
													  , @intUserId			 = @intUserId
													  , @intExternalId		 = @intInvoiceDetailId
													  , @strScreenName		 = 'Invoice'
				END

			IF @strType = 'Remaining Scheduled' AND @dblRemainingQty <> 0
				BEGIN
					EXEC dbo.uspCTUpdateScheduleQuantity @intContractDetailId = @intContractDetailId
													  , @dblQuantityToUpdate = @dblRemainingQty
													  , @intUserId			 = @intUserId
													  , @intExternalId		 = @intInvoiceDetailId
													  , @strScreenName		 = 'Invoice'
				END

			DELETE FROM ##ARItemsForContracts 
			WHERE intInvoiceDetailId = @intInvoiceDetailId 
			  AND intContractDetailId = @intContractDetailId
			  AND dblQuantity = @dblQuantity
              AND strType = @strType
		END

END TRY

BEGIN CATCH

	SET @strErrorMsg = ERROR_MESSAGE()  
	RAISERROR (@strErrorMsg, 16 , 1, 'WITH NOWAIT')  
	
END CATCH