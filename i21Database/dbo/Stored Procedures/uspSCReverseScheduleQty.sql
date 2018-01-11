CREATE PROCEDURE [dbo].[uspSCReverseScheduleQty]
	@intInventoryReceiptId INT,
	@UserId INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	----Receipt Created By Delivery Sheet	
	BEGIN
		CREATE TABLE #tmpItemReceiptItemIds (
			[intInventoryReceiptItemId] [INT] PRIMARY KEY,
			[dblQtyToReceive] [NUMERIC](38,20),
			[intContractDetailId] [INT]
			UNIQUE ([intInventoryReceiptItemId])
		);
		INSERT INTO #tmpItemReceiptItemIds(intInventoryReceiptItemId, dblQtyToReceive, intContractDetailId) SELECT intInventoryReceiptItemId, dblOpenReceive, intLineNo FROM tblICInventoryReceiptItem IRI
		INNER JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId 
		WHERE IR.intInventoryReceiptId = @intInventoryReceiptId AND IR.intSourceType = 5 AND IRI.intLineNo > 0  AND IRI.intOwnershipType = 1

		-- Iterate and process records
		DECLARE @Id INT = NULL,
				@intInventoryReceiptItemId	INT = NULL,
				@intContractDetailId		INT = NULL,
				@intFromItemUOMId			INT = NULL,
				@intToItemUOMId				INT = NULL,
				@dblQty						NUMERIC(38,20) = 0

		DECLARE loopItemsForContractScheduleQuantity CURSOR LOCAL FAST_FORWARD
		FOR 
		SELECT	intContractDetailId
				,(dblQtyToReceive * -1)
				,intInventoryReceiptItemId
		FROM	#tmpItemReceiptItemIds

		OPEN loopItemsForContractScheduleQuantity;
	
		-- Initial fetch attempt
		FETCH NEXT FROM loopItemsForContractScheduleQuantity INTO 
			@intContractDetailId
			,@dblQty
			,@intInventoryReceiptItemId;

		-----------------------------------------------------------------------------------------------------------------------------
		-- Start of the loop for the integration sp. 
		-----------------------------------------------------------------------------------------------------------------------------
		WHILE @@FETCH_STATUS = 0
		BEGIN 		
			EXEC	uspCTUpdateScheduleQuantity
					@intContractDetailId	=	@intContractDetailId,
					@dblQuantityToUpdate	=	@dblQty,
					@intUserId				=	@UserId,
					@intExternalId			=	@intInventoryReceiptItemId,
					@strScreenName			=	'Inventory Receipt'

			-- Attempt to fetch the next row from cursor. 
			FETCH NEXT FROM loopItemsForContractScheduleQuantity INTO 
				@intContractDetailId
				,@dblQty
				,@intInventoryReceiptItemId	
		END;
		-----------------------------------------------------------------------------------------------------------------------------
		-- End of the loop
		-----------------------------------------------------------------------------------------------------------------------------

		CLOSE loopItemsForContractScheduleQuantity;
		DEALLOCATE loopItemsForContractScheduleQuantity;
	END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH