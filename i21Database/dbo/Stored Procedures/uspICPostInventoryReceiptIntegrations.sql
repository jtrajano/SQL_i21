CREATE PROCEDURE uspICPostInventoryReceiptIntegrations
	@ysnPost BIT  = 0  
	,@intTransactionId INT = NULL   
	,@intEntityUserSecurityId INT  = NULL    
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  

-- Declare the constants 
DECLARE	-- Receipt Types
		@RECEIPT_TYPE_PURCHASE_CONTRACT AS NVARCHAR(50) = 'Purchase Contract'
		,@RECEIPT_TYPE_PURCHASE_ORDER AS NVARCHAR(50) = 'Purchase Order'
		,@RECEIPT_TYPE_TRANSFER_ORDER AS NVARCHAR(50) = 'Transfer Order'
		,@RECEIPT_TYPE_DIRECT AS NVARCHAR(50) = 'Direct'
		-- Source Types
		,@SOURCE_TYPE_NONE AS INT = 0
		,@SOURCE_TYPE_SCALE AS INT = 1
		,@SOURCE_TYPE_INBOUND_SHIPMENT AS INT = 2
		,@SOURCE_TYPE_TRANSPORT AS INT = 3
		-- Item Ownership types
		,@OWNERSHIP_TYPE_Own AS INT = 1
		,@OWNERSHIP_TYPE_Storage AS INT = 2
		,@OWNERSHIP_TYPE_ConsignedPurchase AS INT = 3
		,@OWNERSHIP_TYPE_ConsignedSale AS INT = 4

-- Get the details from the inventory receipt 
BEGIN 
	DECLARE @ItemsFromInventoryReceipt AS dbo.ReceiptItemTableType
	INSERT INTO @ItemsFromInventoryReceipt (
		-- Header
		[intInventoryReceiptId] 
		,[strInventoryReceiptId] 
		,[strReceiptType] 
		,[intSourceType] 
		,[dtmDate] 
		,[intCurrencyId] 
		,[dblExchangeRate] 
		-- Detail 
		,[intInventoryReceiptDetailId] 
		,[intItemId] 
		,[intLotId] 
		,[strLotNumber] 
		,[intLocationId] 
		,[intItemLocationId] 
		,[intSubLocationId] 
		,[intStorageLocationId] 
		,[intItemUOMId] 
		,[intWeightUOMId] 
		,[dblQty] 
		,[dblUOMQty] 
		,[dblNetWeight] 
		,[dblCost] 
		,[intContainerId] 
		,[intOwnershipType] 
		,[intOrderId] 
		,[intSourceId] 
		,[intLineNo] 
		,[intLoadReceive]
	)
	EXEC dbo.uspICGetItemsFromItemReceipt
		@intReceiptId = @intTransactionId		

	UPDATE	@ItemsFromInventoryReceipt
	SET		dblQty = CASE WHEN @ysnPost = 1 THEN dblQty ELSE -dblQty END 
			,intLoadReceive = CASE WHEN @ysnPost = 1 THEN intLoadReceive ELSE -intLoadReceive END 
END

-- Get the receipt-type and source-type from tblICInventoryReceipt
BEGIN 
	DECLARE @ReceiptType AS NVARCHAR(50) 
			,@SourceType AS INT 
	
	SELECT	@ReceiptType = strReceiptType
			,@SourceType = intSourceType
	FROM	tblICInventoryReceipt 
	WHERE	intInventoryReceiptId = @intTransactionId 
END 

-- Call the integration scripts based on Receipt type
BEGIN 
	-- Update the received quantities back to the Contract Management
	IF	@ReceiptType = @RECEIPT_TYPE_PURCHASE_CONTRACT 
	BEGIN 
		EXEC dbo.uspCTReceived @ItemsFromInventoryReceipt, @intEntityUserSecurityId
	END

	-- Update the received quantities back to the Purchasing
	IF	@ReceiptType = @RECEIPT_TYPE_PURCHASE_ORDER AND ISNULL(@SourceType, @SOURCE_TYPE_NONE) = @SOURCE_TYPE_NONE
	BEGIN 
		DECLARE @ItemsFromIRForPO AS dbo.ReceiptItemTableType

		-- Do not include the 'return' items (with negative qty)
		INSERT INTO @ItemsFromIRForPO (
				-- Header
				[intInventoryReceiptId] 
				,[strInventoryReceiptId] 
				,[strReceiptType] 
				,[intSourceType] 
				,[dtmDate] 
				,[intCurrencyId] 
				,[dblExchangeRate] 
				-- Detail 
				,[intInventoryReceiptDetailId] 
				,[intItemId] 
				,[intLotId] 
				,[strLotNumber] 
				,[intLocationId] 
				,[intItemLocationId] 
				,[intSubLocationId] 
				,[intStorageLocationId] 
				,[intItemUOMId] 
				,[intWeightUOMId] 
				,[dblQty] 
				,[dblUOMQty] 
				,[dblNetWeight] 
				,[dblCost] 
				,[intContainerId] 
				,[intOwnershipType] 
				,[intOrderId] 
				,[intSourceId] 
				,[intLineNo] 
				,[intLoadReceive]
		)
		SELECT 
				-- Header
				[intInventoryReceiptId] 
				,[strInventoryReceiptId] 
				,[strReceiptType] 
				,[intSourceType] 
				,[dtmDate] 
				,[intCurrencyId] 
				,[dblExchangeRate] 
				-- Detail 
				,[intInventoryReceiptDetailId] 
				,[intItemId] 
				,[intLotId] 
				,[strLotNumber] 
				,[intLocationId] 
				,[intItemLocationId] 
				,[intSubLocationId] 
				,[intStorageLocationId] 
				,[intItemUOMId] 
				,[intWeightUOMId] 
				,[dblQty] 
				,[dblUOMQty] 
				,[dblNetWeight] 
				,[dblCost] 
				,[intContainerId] 
				,[intOwnershipType] 
				,[intOrderId] 
				,[intSourceId] 
				,[intLineNo] 
				,[intLoadReceive]
		FROM	@ItemsFromInventoryReceipt
		WHERE	(@ysnPost = 0 AND dblQty < 0)
				OR (@ysnPost = 1 AND dblQty > 0) 

		EXEC dbo.uspPOReceived @ItemsFromIRForPO, @intEntityUserSecurityId
	END

	-- Update the In-Transit for Transfer Orders 
	IF @ReceiptType = @RECEIPT_TYPE_TRANSFER_ORDER
	BEGIN 
		-- Update the In-Transit Outbound
		BEGIN 
			DECLARE @InTransit_Outbound AS InTransitTableType

			-- Get all company-owned stocks. 
			INSERT INTO @InTransit_Outbound (
				[intItemId]
				,[intItemLocationId]
				,[intItemUOMId]
				,[intLotId]
				,[intSubLocationId]
				,[intStorageLocationId]
				,[dblQty]
				,[intTransactionId]
				,[strTransactionId]
				,[intTransactionTypeId]
			)
			SELECT	[intItemId]				= ri.intItemId
					,[intItemLocationId]	= itemLocation.intItemLocationId
					,[intItemUOMId]			= ISNULL(itemLot.intItemUnitMeasureId, ISNULL(ri.intWeightUOMId, ri.intUnitMeasureId))
					,[intLotId]				= itemLot.intLotId
					,[intSubLocationId]		= ISNULL(tfd.intFromSubLocationId, ri.intSubLocationId)
					,[intStorageLocationId]	= ISNULL(tfd.intFromStorageLocationId, ri.intStorageLocationId) 
					,[dblQty]				=	CASE	WHEN itemLot.intLotId IS NOT NULL THEN 
															itemLot.dblQuantity
														WHEN ri.intWeightUOMId IS NOT NULL THEN 
															ri.dblNet
														ELSE	
															ri.dblOpenReceive
												END 				
					,[intTransactionId]		= r.intInventoryReceiptId
					,[strTransactionId]		= r.strReceiptNumber
					,[intTransactionTypeId] = 4 -- Inventory Receipt
			FROM	dbo.tblICInventoryReceipt r INNER JOIN dbo.tblICInventoryReceiptItem ri
						ON r.intInventoryReceiptId = ri.intInventoryReceiptId
					INNER JOIN dbo.tblICItemLocation itemLocation
						ON itemLocation.intItemId = ri.intItemId
						AND itemLocation.intLocationId = r.intTransferorId	
					LEFT JOIN dbo.tblICInventoryReceiptItemLot itemLot
						ON itemLot.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
					LEFT JOIN (
						dbo.tblICInventoryTransfer tf INNER JOIN tblICInventoryTransferDetail tfd
							ON tf.intInventoryTransferId = tfd.intInventoryTransferId
					)
						ON tfd.intInventoryTransferDetailId = ri.intLineNo
						AND tfd.intInventoryTransferId = ri.intInventoryReceiptId
						AND tfd.intItemId = ri.intItemId
			WHERE	r.intInventoryReceiptId = @intTransactionId
					AND ISNULL(ri.intOwnershipType, @OWNERSHIP_TYPE_Own) = @OWNERSHIP_TYPE_Own
					AND ri.dblOpenReceive > 0

			-- If posting, reduce the in-transit 
			UPDATE @InTransit_Outbound
			SET dblQty = CASE WHEN @ysnPost = 1 THEN -dblQty ELSE dblQty END 

			-- Update the In-Transit Outbound
			EXEC dbo.uspICIncreaseInTransitOutBoundQty @InTransit_Outbound
		END

		---- Update the In-Transit Inbound
		--BEGIN 
		--	DECLARE @InTransit_Inbound AS InTransitTableType

		--	-- Get all company-owned stocks. 
		--	INSERT INTO @InTransit_Inbound (
		--		[intItemId]
		--		,[intItemLocationId]
		--		,[intItemUOMId]
		--		,[intLotId]
		--		,[intSubLocationId]
		--		,[intStorageLocationId]
		--		,[dblQty]
		--		,[intTransactionId]
		--		,[strTransactionId]
		--		,[intTransactionTypeId]
		--	)
		--	SELECT	[intItemId]				= ri.intItemId
		--			,[intItemLocationId]	= itemLocation.intItemLocationId
		--			,[intItemUOMId]			= ISNULL(itemLot.intItemUnitMeasureId, ISNULL(ri.intWeightUOMId, ri.intUnitMeasureId))
		--			,[intLotId]				= itemLot.intLotId
		--			,[intSubLocationId]		= ri.intSubLocationId
		--			,[intStorageLocationId]	= ri.intStorageLocationId
		--			,[dblQty]				=	CASE	WHEN itemLot.intLotId IS NOT NULL THEN 
		--													itemLot.dblQuantity
		--												WHEN ri.intWeightUOMId IS NOT NULL THEN 
		--													ri.dblNet
		--												ELSE	
		--													ri.dblOpenReceive
		--										END 
		--			,[intTransactionId]		= r.intInventoryReceiptId
		--			,[strTransactionId]		= r.strReceiptNumber
		--			,[intTransactionTypeId] = 4 -- Inventory Receipt
		--	FROM	dbo.tblICInventoryReceipt r INNER JOIN dbo.tblICInventoryReceiptItem ri
		--				ON r.intInventoryReceiptId = ri.intInventoryReceiptId
		--			INNER JOIN dbo.tblICItemLocation itemLocation
		--				ON itemLocation.intItemId = ri.intItemId
		--				AND itemLocation.intLocationId = r.intLocationId	
		--			LEFT JOIN dbo.tblICInventoryReceiptItemLot itemLot
		--				ON itemLot.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
		--	WHERE	r.intInventoryReceiptId = @intTransactionId
		--			AND ISNULL(ri.intOwnershipType, @OWNERSHIP_TYPE_Own) = @OWNERSHIP_TYPE_Own
		--			AND ri.dblOpenReceive > 0

		--	-- If posting, reduce the in-transit 
		--	UPDATE @InTransit_Inbound
		--	SET dblQty = CASE WHEN @ysnPost = 1 THEN -dblQty ELSE dblQty END 

		--	-- Update the In-Transit Inbound
		--	EXEC dbo.uspICIncreaseInTransitInBoundQty @InTransit_Inbound 
		--END
	END 
END 

-- Call the integration scripts based on Source type
BEGIN 
	-- Update the received quantities back to Inbound Shipment 
	IF	ISNULL(@SourceType, @SOURCE_TYPE_NONE) = @SOURCE_TYPE_INBOUND_SHIPMENT
	BEGIN 
		EXEC dbo.uspLGReceived @ItemsFromInventoryReceipt, @intEntityUserSecurityId
	END

	-- Update the received quantities back to a Scale Ticket
	IF	ISNULL(@SourceType, @SOURCE_TYPE_NONE) = @SOURCE_TYPE_SCALE
	BEGIN 
		EXEC dbo.uspSCReceived @ItemsFromInventoryReceipt, @intEntityUserSecurityId
	END

	-- Update the received quantities back to Transport Order
	IF	ISNULL(@SourceType, @SOURCE_TYPE_NONE) = @SOURCE_TYPE_TRANSPORT
	BEGIN 
		EXEC dbo.uspTRReceived @ItemsFromInventoryReceipt, @intEntityUserSecurityId
	END
END 

_Exit: 