CREATE PROCEDURE [dbo].[uspARUpdateContractOnPost]
	  @intUserId    INT
	, @ysnPost 		BIT = 1
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
			DECLARE @intInvoiceId				INT = NULL
				  , @intInvoiceDetailId			INT = NULL
				  , @intOriginalInvoiceId		INT = NULL
				  , @intOriginalInvoiceDetailId	INT = NULL
				  , @intContractDetailId		INT = NULL				  
				  , @strType					NVARCHAR(100) = NULL
				  , @dblBalanceQty				NUMERIC(18, 6) = 0
				  , @dblSheduledQty				NUMERIC(18, 6) = 0
				  , @dblRemainingQty			NUMERIC(18, 6) = 0
				  , @dblQtyToReturn				NUMERIC(18, 6) = 0
				  , @ysnFromReturn				BIT = 0
				  , @strTransactionType			NVARCHAR(100) = NULL

		    --IF POST, DEDUCT SCHEDULED QTY FIRST BEFORE DEDUCTING BALANCE
			IF @ysnPost = 1
				BEGIN
					SELECT TOP 1 @intInvoiceId				= intInvoiceId
							, @intInvoiceDetailId			= intInvoiceDetailId
							, @intOriginalInvoiceId			= intOriginalInvoiceId
							, @intOriginalInvoiceDetailId	= intOriginalInvoiceDetailId
							, @intContractDetailId			= intContractDetailId
							, @strType						= strType
							, @dblBalanceQty				= dblBalanceQty
							, @dblSheduledQty				= dblSheduledQty
							, @dblRemainingQty				= dblRemainingQty
							, @ysnFromReturn				= ysnFromReturn
							, @strTransactionType			= strTransactionType
					FROM ##ARItemsForContracts
					ORDER BY ABS(dblBalanceQty) ASC
				END
			--IF UNPOST, DEDUCT BALANCE FIRST BEFORE DEDUCTING SCHEDULED QTY
			ELSE
				BEGIN
					SELECT TOP 1 @intInvoiceId				= intInvoiceId
							, @intInvoiceDetailId			= intInvoiceDetailId
							, @intOriginalInvoiceId			= intOriginalInvoiceId
							, @intOriginalInvoiceDetailId	= intOriginalInvoiceDetailId
							, @intContractDetailId			= intContractDetailId
							, @strType						= strType
							, @dblBalanceQty				= dblBalanceQty
							, @dblSheduledQty				= dblSheduledQty
							, @dblRemainingQty				= dblRemainingQty
							, @ysnFromReturn				= ysnFromReturn
							, @strTransactionType			= strTransactionType
					FROM ##ARItemsForContracts
					ORDER BY ABS(dblBalanceQty) DESC
				END

			IF @strType = 'Contract Balance' AND @dblBalanceQty <> 0
				BEGIN
					EXEC dbo.uspCTUpdateSequenceBalance @intContractDetailId = @intContractDetailId
													  , @dblQuantityToUpdate = @dblBalanceQty
													  , @intUserId			 = @intUserId
													  , @intExternalId		 = @intInvoiceDetailId
													  , @strScreenName		 = @strTransactionType
													  , @ysnFromInvoice 	 = 1

					IF ISNULL(@ysnFromReturn, 0) = 1 AND @intOriginalInvoiceDetailId IS NOT NULL
						BEGIN
							SET @dblQtyToReturn = ABS(@dblBalanceQty)
							
							EXEC dbo.uspCTProcessInvoiceReturn @intInvoiceDetailId		= @intOriginalInvoiceDetailId                --> Returned Invoice Detail Id
														     , @intInvoiceId			= @intOriginalInvoiceId                    --> Returned Invoice Id
														     , @intNewInvoiceDetialId	= @intInvoiceDetailId            --> (Credit Memo) Invoice Detail Id
														     , @intNewInvoiceId			= @intInvoiceId                --> (Credit Memo) Invoice Id
														     , @dblQuantity				= @dblQtyToReturn            --> (Credit Memo) Return Quantity - must be positive
						END
				END

			IF @strType = 'Contract Scheduled' AND @dblSheduledQty <> 0
				BEGIN
					EXEC dbo.uspCTUpdateScheduleQuantity @intContractDetailId = @intContractDetailId
													  , @dblQuantityToUpdate = @dblSheduledQty
													  , @intUserId			 = @intUserId
													  , @intExternalId		 = @intInvoiceDetailId
													  , @strScreenName		 = @strTransactionType
				END

			DELETE FROM ##ARItemsForContracts 
			WHERE intInvoiceDetailId = @intInvoiceDetailId 
			  AND intContractDetailId = @intContractDetailId
              AND strType = @strType
		END

END TRY

BEGIN CATCH

	SET @strErrorMsg = ERROR_MESSAGE()  
	RAISERROR (@strErrorMsg, 16 , 1, 'WITH NOWAIT')  
	
END CATCH