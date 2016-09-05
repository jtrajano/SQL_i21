CREATE PROCEDURE [dbo].[uspICInventoryReceiptAfterSave]
	@ReceiptId INT,
	@ForDelete BIT = 0,
	@UserId INT = NULL

AS

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  

	
DECLARE @ReceiptType AS INT
DECLARE @SourceType AS INT

DECLARE @ReceiptType_PurchaseContract AS INT = 1
DECLARE @ReceiptType_PurchaseOrder AS INT = 2
DECLARE @ReceiptType_TransferOrder AS INT = 3
DECLARE @ReceiptType_Direct AS INT = 4

DECLARE @SourceType_None AS INT = 0
DECLARE @SourceType_Scale AS INT = 1
DECLARE @SourceType_InboundShipment AS INT = 2
DECLARE @SourceType_Transport AS INT = 3

DECLARE @ErrMsg NVARCHAR(MAX)

-- Initialize the variables
BEGIN
	IF (@ForDelete = 1)
	BEGIN
		SELECT	@ReceiptType = intOrderType
				,@SourceType = intSourceType 
		FROM	tblICTransactionDetailLog
		WHERE	intTransactionId = @ReceiptId
				AND strTransactionType = 'Inventory Receipt'		
	END
	ELSE
	BEGIN
		SELECT	@ReceiptType = 
					CASE WHEN strReceiptType = 'Purchase Contract' THEN @ReceiptType_PurchaseContract
						WHEN strReceiptType = 'Purchase Order' THEN @ReceiptType_PurchaseOrder
						WHEN strReceiptType = 'Transfer Order' THEN @ReceiptType_TransferOrder
						WHEN strReceiptType = 'Direct' THEN @ReceiptType_Direct
					END 
				,@SourceType = intSourceType 
		FROM	tblICInventoryReceipt
		WHERE	intInventoryReceiptId = @ReceiptId
	END
END

-- Validate. 
BEGIN		
	-- Do not proceed if receipt type is NOT a 'Purchase Contract' 
	IF	@ReceiptType <> @ReceiptType_PurchaseContract
		GOTO _Exit;

	-- Do not proceed if the source type is 'Inbound Shipment' or 'Scale'. 
	-- Logistics (Inbound Shipment) and Scale (Scale Ticket) will be calling uspCTUpdateScheduleQuantity on their own. 
	IF ISNULL(@SourceType, @SourceType_None) = @SourceType_InboundShipment OR ISNULL(@SourceType, @SourceType_None) = @SourceType_Scale
		GOTO _Exit;
END

-- Call the grain sp when deleting the receipt. 
IF @ForDelete = 1
BEGIN 
	EXEC uspGRReverseOnReceiptDelete @ReceiptId
END 

-- Get the deleted, new, or modified data. 
BEGIN
	-- Create current snapshot of Receipt Items after Save
	SELECT
		ReceiptItem.intInventoryReceiptId,
		ReceiptItem.intInventoryReceiptItemId,
		intOrderType = (
			CASE WHEN Receipt.strReceiptType = 'Purchase Contract' THEN @ReceiptType_PurchaseContract
				WHEN Receipt.strReceiptType = 'Purchase Order' THEN @ReceiptType_PurchaseOrder
				WHEN Receipt.strReceiptType = 'Transfer Order' THEN @ReceiptType_TransferOrder
				WHEN Receipt.strReceiptType = 'Direct' THEN @ReceiptType_Direct
			END),
		ReceiptItem.intOrderId,
		Receipt.intSourceType,
		ReceiptItem.intSourceId,
		ReceiptItem.intLineNo,
		ReceiptItem.intItemId,
		intItemUOMId = ReceiptItem.intUnitMeasureId,
		ReceiptItem.dblOpenReceive,
		ReceiptItemSource.ysnLoad,
		ReceiptItem.intLoadReceive
	INTO #tmpReceiptItems
	FROM tblICInventoryReceiptItem ReceiptItem
		LEFT JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
		LEFT JOIN vyuICGetReceiptItemSource ReceiptItemSource ON ReceiptItemSource.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
	WHERE ReceiptItem.intInventoryReceiptId = @ReceiptId
	-- Create snapshot of Receipt Items before Save
	SELECT 
		intInventoryReceiptId = intTransactionId,
		intInventoryReceiptItemId = intTransactionDetailId,
		intOrderType,
		intOrderId = intOrderNumberId,
		intSourceType,
		intSourceId = intSourceNumberId,
		intLineNo,
		intItemId,
		intItemUOMId,
		dblOpenReceive = dblQuantity,
		ysnLoad,
		intLoadReceive
	INTO #tmpLogReceiptItems
	FROM tblICTransactionDetailLog
	WHERE intTransactionId = @ReceiptId
		AND strTransactionType = 'Inventory Receipt'

	-- Create temporary table for processing records
	DECLARE @tblToProcess TABLE
	(
		intKeyId					INT IDENTITY,
		intInventoryReceiptItemId	INT,
		intContractDetailId			INT,
		intItemUOMId				INT,
		dblQty						NUMERIC(12,4)	
	)

	INSERT INTO @tblToProcess(
		intInventoryReceiptItemId,
		intContractDetailId,
		intItemUOMId,
		dblQty)

	-- Changed Quantity/UOM
	SELECT 
		currentSnapshot.intInventoryReceiptItemId,
		currentSnapshot.intLineNo,
		currentSnapshot.intItemUOMId,
		CASE WHEN (ISNULL(currentSnapshot.ysnLoad, 0) = 0) THEN dbo.fnCalculateQtyBetweenUOM(currentSnapshot.intItemUOMId, ContractDetail.intItemUOMId, (CASE WHEN @ForDelete = 1 THEN currentSnapshot.dblOpenReceive ELSE (currentSnapshot.dblOpenReceive - previousSnapshot.dblOpenReceive) END))
			ELSE currentSnapshot.intLoadReceive END 
	FROM #tmpReceiptItems currentSnapshot
	INNER JOIN #tmpLogReceiptItems previousSnapshot
		ON previousSnapshot.intInventoryReceiptId = currentSnapshot.intInventoryReceiptId
		AND previousSnapshot.intInventoryReceiptItemId = currentSnapshot.intInventoryReceiptItemId
	INNER JOIN tblCTContractDetail ContractDetail
		ON ContractDetail.intContractDetailId = currentSnapshot.intLineNo
	WHERE
		currentSnapshot.intLineNo IS NOT NULL
		AND currentSnapshot.intLineNo = previousSnapshot.intLineNo
		AND currentSnapshot.intItemId = previousSnapshot.intItemId		
		AND (currentSnapshot.intItemUOMId <> previousSnapshot.intItemUOMId OR currentSnapshot.dblOpenReceive <> previousSnapshot.dblOpenReceive)

	UNION ALL 
		
	--New Contract Selected
	SELECT
		currentSnapshot.intInventoryReceiptItemId
		,currentSnapshot.intLineNo
		,currentSnapshot.intItemUOMId
		,CASE WHEN (ISNULL(currentSnapshot.ysnLoad, 0) = 0) THEN dbo.fnCalculateQtyBetweenUOM(currentSnapshot.intItemUOMId, previousSnapshot.intItemUOMId, currentSnapshot.dblOpenReceive)
			ELSE currentSnapshot.intLoadReceive END
	FROM #tmpReceiptItems currentSnapshot
	INNER JOIN #tmpLogReceiptItems previousSnapshot
		ON previousSnapshot.intInventoryReceiptId = currentSnapshot.intInventoryReceiptId
		AND previousSnapshot.intInventoryReceiptItemId = currentSnapshot.intInventoryReceiptItemId
	INNER JOIN tblCTContractDetail ContractDetail
		ON ContractDetail.intContractDetailId = currentSnapshot.intLineNo
	WHERE
		currentSnapshot.intLineNo IS NOT NULL
		AND currentSnapshot.intLineNo <> previousSnapshot.intLineNo		
		AND currentSnapshot.intItemId = previousSnapshot.intItemId		
		
	UNION ALL

	--Replaced Contract
	SELECT
		currentSnapshot.intInventoryReceiptItemId
		,previousSnapshot.intLineNo
		,previousSnapshot.intItemUOMId
		,CASE WHEN (ISNULL(previousSnapshot.ysnLoad, 0) = 0) THEN dbo.fnCalculateQtyBetweenUOM(previousSnapshot.intItemUOMId, ContractDetail.intItemUOMId, (previousSnapshot.dblOpenReceive * -1))
			ELSE previousSnapshot.intLoadReceive END
	FROM #tmpReceiptItems currentSnapshot
	INNER JOIN #tmpLogReceiptItems previousSnapshot
		ON previousSnapshot.intInventoryReceiptId = currentSnapshot.intInventoryReceiptId
		AND previousSnapshot.intInventoryReceiptItemId = currentSnapshot.intInventoryReceiptItemId
	INNER JOIN tblCTContractDetail ContractDetail
		ON ContractDetail.intContractDetailId = currentSnapshot.intLineNo
	WHERE
		currentSnapshot.intLineNo IS NOT NULL
		AND currentSnapshot.intLineNo <> previousSnapshot.intLineNo
		AND currentSnapshot.intItemId = previousSnapshot.intItemId

	UNION ALL
		
	--Removed Contract
	SELECT
		currentSnapshot.intInventoryReceiptItemId
		,previousSnapshot.intLineNo
		,previousSnapshot.intItemUOMId
		,CASE WHEN (ISNULL(previousSnapshot.ysnLoad, 0) = 0) THEN dbo.fnCalculateQtyBetweenUOM(previousSnapshot.intItemUOMId, ContractDetail.intItemUOMId, (previousSnapshot.dblOpenReceive * -1))
			ELSE previousSnapshot.intLoadReceive END
	FROM #tmpReceiptItems currentSnapshot
	INNER JOIN #tmpLogReceiptItems previousSnapshot
		ON previousSnapshot.intInventoryReceiptId = currentSnapshot.intInventoryReceiptId
		AND previousSnapshot.intInventoryReceiptItemId = currentSnapshot.intInventoryReceiptItemId
	INNER JOIN tblCTContractDetail ContractDetail
		ON ContractDetail.intContractDetailId = currentSnapshot.intLineNo
	WHERE
		currentSnapshot.intLineNo IS NULL
		AND previousSnapshot.intLineNo IS NOT NULL
		
	UNION ALL	

	--Deleted Item
	SELECT
		previousSnapshot.intInventoryReceiptItemId
		,previousSnapshot.intLineNo
		,previousSnapshot.intItemUOMId
		,CASE WHEN (ISNULL(previousSnapshot.ysnLoad, 0) = 0) THEN dbo.fnCalculateQtyBetweenUOM(previousSnapshot.intItemUOMId, ContractDetail.intItemUOMId, (previousSnapshot.dblOpenReceive * -1))
			ELSE previousSnapshot.intLoadReceive END
	FROM #tmpLogReceiptItems previousSnapshot
	INNER JOIN tblCTContractDetail ContractDetail
		ON ContractDetail.intContractDetailId = previousSnapshot.intLineNo
	WHERE
		previousSnapshot.intLineNo IS NOT NULL
		AND previousSnapshot.intInventoryReceiptItemId NOT IN (SELECT intInventoryReceiptItemId FROM #tmpReceiptItems)
		
	UNION ALL
		
	--Added Item
	SELECT
		currentSnapshot.intInventoryReceiptItemId
		,currentSnapshot.intLineNo
		,currentSnapshot.intItemUOMId
		,CASE WHEN (ISNULL(currentSnapshot.ysnLoad, 0) = 0) THEN dbo.fnCalculateQtyBetweenUOM(currentSnapshot.intItemUOMId, ContractDetail.intItemUOMId, currentSnapshot.dblOpenReceive)
			ELSE currentSnapshot.intLoadReceive END
	FROM #tmpReceiptItems currentSnapshot
	INNER JOIN tblCTContractDetail ContractDetail
		ON ContractDetail.intContractDetailId = currentSnapshot.intLineNo
	WHERE
		currentSnapshot.intLineNo IS NOT NULL
		AND currentSnapshot.intInventoryReceiptItemId NOT IN (SELECT intInventoryReceiptItemId FROM #tmpLogReceiptItems)
END

BEGIN TRY
	-- Call the integration with contracts. 
	BEGIN 
		-- Iterate and process records
		DECLARE @Id INT = NULL,
				@intInventoryReceiptItemId	INT = NULL,
				@intContractDetailId		INT = NULL,
				@intFromItemUOMId			INT = NULL,
				@intToItemUOMId				INT = NULL,
				@dblQty						NUMERIC(18,6) = 0

		DECLARE loopItemsForContractScheduleQuantity CURSOR LOCAL FAST_FORWARD
		FOR 
		SELECT	intContractDetailId
				,dblQty
				,intInventoryReceiptItemId
		FROM	@tblToProcess

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

		DROP TABLE #tmpLogReceiptItems
		DROP TABLE #tmpReceiptItems
	END
END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg, 16, 1, 'WITH NOWAIT')  
END CATCH

_Exit: 

-- Delete the data snapshot. 
DELETE	FROM tblICTransactionDetailLog 
WHERE	strTransactionType = 'Inventory Receipt' 
		AND intTransactionId = @ReceiptId

