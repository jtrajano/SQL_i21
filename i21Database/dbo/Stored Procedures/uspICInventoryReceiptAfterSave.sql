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
DECLARE @ReceiptType_InventoryReturn AS INT = 5

DECLARE @SourceType_None AS INT = 0
DECLARE @SourceType_Scale AS INT = 1
DECLARE @SourceType_InboundShipment AS INT = 2
DECLARE @SourceType_Transport AS INT = 3
DECLARE @SourceType_SettleStorage AS INT = 4

DECLARE @ErrMsg NVARCHAR(MAX)
		,@intReturnValue AS INT 

-- Iterate and process records
DECLARE @Id INT = NULL,
		@intInventoryReceiptItemId	INT = NULL,
		@intContractDetailId		INT = NULL,
		@intPurchaseDetailId		INT = NULL,
		@intFromItemUOMId			INT = NULL,
		@intToItemUOMId				INT = NULL,
		@dblQty						NUMERIC(18,6) = 0

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
						WHEN strReceiptType = 'Inventory Return' THEN @ReceiptType_InventoryReturn
					END 
				,@SourceType = intSourceType 
		FROM	tblICInventoryReceipt
		WHERE	intInventoryReceiptId = @ReceiptId
	END
END

-- Create current snapshot of the Receipt Items 
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
		ReceiptItem.intLoadReceive,
		ReceiptItem.dblNet,
		ReceiptItem.dblGross, 
		intSourceInventoryDetailId = ReceiptItem.intSourceInventoryReceiptItemId
	INTO #tmpAfterSaveReceiptItems
	FROM 
		tblICInventoryReceiptItem ReceiptItem
		LEFT JOIN tblICInventoryReceipt Receipt 
			ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
		LEFT JOIN vyuICGetReceiptItemSource ReceiptItemSource 
			ON ReceiptItemSource.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
	WHERE ReceiptItem.intInventoryReceiptId = @ReceiptId AND (ReceiptItem.strItemType IS NULL OR ReceiptItem.strItemType != 'Option')
	UNION ALL
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
		ItemBundle.intItemId,
		intItemUOMId = ItemBundleUOM.intItemUOMId,
		ReceiptItem.dblOpenReceive,
		ReceiptItemSource.ysnLoad,
		ReceiptItem.intLoadReceive,
		ReceiptItem.dblNet,
		ReceiptItem.dblGross, 
		intSourceInventoryDetailId = ReceiptItem.intSourceInventoryReceiptItemId
	FROM 
		tblICInventoryReceiptItem ReceiptItem
		LEFT JOIN tblICInventoryReceipt Receipt 
			ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
		LEFT JOIN vyuICGetReceiptItemSource ReceiptItemSource 
			ON ReceiptItemSource.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
		INNER JOIN tblICItemBundle ItemBundle 
			ON ItemBundle.intItemBundleId = ReceiptItem.intParentItemLinkId AND ReceiptItem.intItemId = ItemBundle.intBundleItemId
		INNER JOIN tblICItemUOM ItemBundleUOM
			ON ItemBundleUOM.intItemId = ItemBundle.intItemId AND ItemBundleUOM.ysnStockUnit = 1
		WHERE ReceiptItem.intInventoryReceiptId = @ReceiptId


	-- Create snapshot of Receipt Items before Save
	SELECT 
		intInventoryReceiptId = intTransactionId
		,intInventoryReceiptItemId = intTransactionDetailId
		,intOrderType
		,intOrderId = intOrderNumberId
		,intSourceType
		,intSourceId = intSourceNumberId
		,intLineNo
		,intItemId
		,intItemUOMId
		,dblOpenReceive = dblQuantity
		,ysnLoad
		,intLoadReceive
		,dblNet
		,dblGross 
		,intSourceInventoryDetailId
	INTO #tmpBeforeSaveReceiptItems
	FROM tblICTransactionDetailLog TransactionDetail
		--LEFT JOIN tblICItem Item ON Item.intItemId = TransactionDetail.intItemId
	WHERE 
		intTransactionId = @ReceiptId
		AND strTransactionType = 'Inventory Receipt'
		--AND 1 = 
		--	CASE WHEN ISNULL(TransactionDetail.strItemType, '') <> '' AND Item.strType = 'Bundle' THEN 1
		--		 WHEN ISNULL(TransactionDetail.strItemType, '') <> '' THEN 0
		--		 ELSE 1
		--	END 
		
END 

IF @ForDelete = 1
BEGIN 
	-- Call the grain sp when deleting the receipt. 
	EXEC uspGRReverseOnReceiptDelete @ReceiptId
	IF @@ERROR <> 0 GOTO _Exit 

	IF @SourceType = @SourceType_SettleStorage
	BEGIN
		DECLARE @ItemId INT
		DECLARE @SourceNumberId INT
		DECLARE @Quantity DECIMAL(24, 10)

		DECLARE curReceipt CURSOR LOCAL FAST_FORWARD
		FOR
		SELECT	t.intItemId
				, t.intSourceNumberId
				, SUM(dbo.fnCalculateQtyBetweenUOM(t.intItemUOMId, dbo.fnGetItemStockUOM(t.intItemId), t.dblQuantity))
		FROM	tblICTransactionDetailLog t
		WHERE	t.intTransactionId = @ReceiptId
				AND t.strTransactionType = 'Inventory Receipt'
		GROUP BY t.intItemId, t.intSourceNumberId

		OPEN curReceipt

		FETCH NEXT FROM curReceipt INTO @ItemId, @SourceNumberId, @Quantity
		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC uspGRReverseSettleStorage @ItemId, @SourceNumberId, @Quantity, @UserId
			IF @@ERROR <> 0 GOTO _Exit 
			FETCH NEXT FROM curReceipt INTO @ItemId, @SourceNumberId, @Quantity
		END

		CLOSE curReceipt
		DEALLOCATE curReceipt
	END

	-- Call the quality sp when deleting the receipt.
	EXEC uspQMInspectionDeleteResult @ReceiptId
	IF @@ERROR <> 0 GOTO _Exit 
END 

-- Call the integration with contracts. 
-- Conditions: 
-- 1. Do not proceed if receipt type is NOT a 'Purchase Contract' 
-- 2. Do not proceed if the source type is 'Inbound Shipment' or 'Scale'. Logistics (Inbound Shipment) and Scale (Scale Ticket) will be calling uspCTUpdateScheduleQuantity on their own. 
IF	@ReceiptType = @ReceiptType_PurchaseContract
	AND (
		ISNULL(@SourceType, @SourceType_None) NOT IN (@SourceType_InboundShipment, @SourceType_Scale)
	)
BEGIN 
	-- Get the deleted, new, or modified data. 
	BEGIN
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
			dblQty
		)
		-- Changed Quantity/UOM
		SELECT 
			currentSnapshot.intInventoryReceiptItemId,
			currentSnapshot.intLineNo,
			currentSnapshot.intItemUOMId,
			CASE WHEN (ISNULL(currentSnapshot.ysnLoad, 0) = 0) THEN dbo.fnCalculateQtyBetweenUOM(currentSnapshot.intItemUOMId, ContractDetail.intItemUOMId, (CASE WHEN @ForDelete = 1 THEN currentSnapshot.dblOpenReceive ELSE (currentSnapshot.dblOpenReceive - previousSnapshot.dblOpenReceive) END))
				ELSE (CASE WHEN @ForDelete = 1 THEN currentSnapshot.intLoadReceive ELSE (currentSnapshot.intLoadReceive - previousSnapshot.intLoadReceive) END) END 
		FROM 
			#tmpAfterSaveReceiptItems currentSnapshot
			INNER JOIN #tmpBeforeSaveReceiptItems previousSnapshot
				ON previousSnapshot.intInventoryReceiptId = currentSnapshot.intInventoryReceiptId
				AND previousSnapshot.intInventoryReceiptItemId = currentSnapshot.intInventoryReceiptItemId
			INNER JOIN tblCTContractDetail ContractDetail
				ON ContractDetail.intContractDetailId = currentSnapshot.intLineNo
			LEFT JOIN tblICItem Item ON Item.intItemId = ContractDetail.intItemId
		WHERE
			currentSnapshot.intLineNo IS NOT NULL
			AND currentSnapshot.intLineNo = previousSnapshot.intLineNo
			AND currentSnapshot.intItemId = previousSnapshot.intItemId		
			AND (currentSnapshot.intItemUOMId <> previousSnapshot.intItemUOMId OR currentSnapshot.dblOpenReceive <> previousSnapshot.dblOpenReceive OR currentSnapshot.intLoadReceive <> previousSnapshot.intLoadReceive)		

		--New Contract Selected
		UNION ALL 
		SELECT 
			currentSnapshot.intInventoryReceiptItemId
			,currentSnapshot.intLineNo
			,currentSnapshot.intItemUOMId
			,CASE WHEN (ISNULL(currentSnapshot.ysnLoad, 0) = 0) THEN dbo.fnCalculateQtyBetweenUOM(currentSnapshot.intItemUOMId, previousSnapshot.intItemUOMId, currentSnapshot.dblOpenReceive)
				ELSE currentSnapshot.intLoadReceive END
		FROM 
			#tmpAfterSaveReceiptItems currentSnapshot
			INNER JOIN #tmpBeforeSaveReceiptItems previousSnapshot
				ON previousSnapshot.intInventoryReceiptId = currentSnapshot.intInventoryReceiptId
				AND previousSnapshot.intInventoryReceiptItemId = currentSnapshot.intInventoryReceiptItemId
			INNER JOIN tblCTContractDetail ContractDetail
				ON ContractDetail.intContractDetailId = currentSnapshot.intLineNo
			LEFT JOIN tblICItem Item ON Item.intItemId = ContractDetail.intItemId
		WHERE
			currentSnapshot.intLineNo IS NOT NULL
			AND currentSnapshot.intLineNo <> previousSnapshot.intLineNo		
			AND currentSnapshot.intItemId = previousSnapshot.intItemId		

		--Replaced Contract
		UNION ALL
		SELECT 
			currentSnapshot.intInventoryReceiptItemId
			,previousSnapshot.intLineNo
			,previousSnapshot.intItemUOMId
			,CASE WHEN (ISNULL(previousSnapshot.ysnLoad, 0) = 0) THEN dbo.fnCalculateQtyBetweenUOM(previousSnapshot.intItemUOMId, ContractDetail.intItemUOMId, (previousSnapshot.dblOpenReceive * -1))
				ELSE previousSnapshot.intLoadReceive * -1 END
		FROM 
			#tmpAfterSaveReceiptItems currentSnapshot
			INNER JOIN #tmpBeforeSaveReceiptItems previousSnapshot
				ON previousSnapshot.intInventoryReceiptId = currentSnapshot.intInventoryReceiptId
				AND previousSnapshot.intInventoryReceiptItemId = currentSnapshot.intInventoryReceiptItemId
			INNER JOIN tblCTContractDetail ContractDetail
				ON ContractDetail.intContractDetailId = currentSnapshot.intLineNo
			LEFT JOIN tblICItem Item ON Item.intItemId = ContractDetail.intItemId
		WHERE
			currentSnapshot.intLineNo IS NOT NULL
			AND currentSnapshot.intLineNo <> previousSnapshot.intLineNo
			AND currentSnapshot.intItemId = previousSnapshot.intItemId
		
		--Removed Contract
		UNION ALL
		SELECT 
			currentSnapshot.intInventoryReceiptItemId
			,previousSnapshot.intLineNo
			,previousSnapshot.intItemUOMId
			,CASE WHEN (ISNULL(previousSnapshot.ysnLoad, 0) = 0) THEN dbo.fnCalculateQtyBetweenUOM(previousSnapshot.intItemUOMId, ContractDetail.intItemUOMId, (previousSnapshot.dblOpenReceive * -1))
				ELSE previousSnapshot.intLoadReceive * -1 END
		FROM 
			#tmpAfterSaveReceiptItems currentSnapshot
			INNER JOIN #tmpBeforeSaveReceiptItems previousSnapshot
				ON previousSnapshot.intInventoryReceiptId = currentSnapshot.intInventoryReceiptId
				AND previousSnapshot.intInventoryReceiptItemId = currentSnapshot.intInventoryReceiptItemId
			INNER JOIN tblCTContractDetail ContractDetail
				ON ContractDetail.intContractDetailId = currentSnapshot.intLineNo
			LEFT JOIN tblICItem Item ON Item.intItemId = ContractDetail.intItemId
		WHERE
			currentSnapshot.intLineNo IS NULL
			AND previousSnapshot.intLineNo IS NOT NULL
		
		--Deleted Item
		UNION ALL	
		SELECT
			previousSnapshot.intInventoryReceiptItemId
			,previousSnapshot.intLineNo
			,previousSnapshot.intItemUOMId
			,CASE WHEN (ISNULL(previousSnapshot.ysnLoad, 0) = 0) THEN dbo.fnCalculateQtyBetweenUOM(previousSnapshot.intItemUOMId, ContractDetail.intItemUOMId, (previousSnapshot.dblOpenReceive * -1))
				ELSE previousSnapshot.intLoadReceive * -1 END
		FROM 
			#tmpBeforeSaveReceiptItems previousSnapshot
			INNER JOIN tblCTContractDetail ContractDetail
				ON ContractDetail.intContractDetailId = previousSnapshot.intLineNo
			LEFT JOIN tblICItem Item ON Item.intItemId = ContractDetail.intItemId
		WHERE
			previousSnapshot.intLineNo IS NOT NULL
			AND previousSnapshot.intInventoryReceiptItemId NOT IN (SELECT intInventoryReceiptItemId FROM #tmpAfterSaveReceiptItems)

		--Added Item
		UNION ALL
		SELECT 
			currentSnapshot.intInventoryReceiptItemId
			,currentSnapshot.intLineNo
			,currentSnapshot.intItemUOMId
			,CASE WHEN (ISNULL(currentSnapshot.ysnLoad, 0) = 0) THEN dbo.fnCalculateQtyBetweenUOM(currentSnapshot.intItemUOMId, ContractDetail.intItemUOMId, currentSnapshot.dblOpenReceive)
				ELSE currentSnapshot.intLoadReceive END
		FROM 
			#tmpAfterSaveReceiptItems currentSnapshot
			INNER JOIN tblCTContractDetail ContractDetail
				ON ContractDetail.intContractDetailId = currentSnapshot.intLineNo
			LEFT JOIN tblICItem Item ON Item.intItemId = ContractDetail.intItemId
		WHERE
			currentSnapshot.intLineNo IS NOT NULL
			AND currentSnapshot.intInventoryReceiptItemId NOT IN (SELECT intInventoryReceiptItemId FROM #tmpBeforeSaveReceiptItems)
	END
	BEGIN 
		DECLARE loopItemsForPurchaseOrderReceivedQty CURSOR LOCAL FAST_FORWARD
		FOR 
		SELECT	intContractDetailId
				,dblQty
				,intInventoryReceiptItemId
		FROM	@tblToProcess

		OPEN loopItemsForPurchaseOrderReceivedQty;
	
		-- Initial fetch attempt
		FETCH NEXT FROM loopItemsForPurchaseOrderReceivedQty INTO 
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

			IF @@ERROR <> 0 GOTO _Exit

			-- Attempt to fetch the next row from cursor. 
			FETCH NEXT FROM loopItemsForPurchaseOrderReceivedQty INTO 
				@intContractDetailId
				,@dblQty
				,@intInventoryReceiptItemId	
		END;
		-----------------------------------------------------------------------------------------------------------------------------
		-- End of the loop
		-----------------------------------------------------------------------------------------------------------------------------

		CLOSE loopItemsForPurchaseOrderReceivedQty;
		DEALLOCATE loopItemsForPurchaseOrderReceivedQty;
	END
END 

-- If it is an inventory return, update the returned qty & net of the IR transaction.
IF @ReceiptType = @ReceiptType_InventoryReturn
BEGIN 
	UPDATE	ri
	SET		dblQtyReturned = ISNULL(ri.dblQtyReturned, 0) - beforeSave.dblOpenReceive
			,dblNetReturned = ISNULL(ri.dblNetReturned, 0) - beforeSave.dblNet
			,dblGrossReturned  = ISNULL(ri.dblGrossReturned, 0) - beforeSave.dblGross 
	FROM	tblICInventoryReceiptItem ri 
			INNER JOIN #tmpBeforeSaveReceiptItems beforeSave
				ON ri.intInventoryReceiptItemId = beforeSave.intSourceInventoryDetailId

	UPDATE	ri
	SET		dblQtyReturned = ISNULL(ri.dblQtyReturned, 0) + afterSave.dblOpenReceive
			,dblNetReturned = ISNULL(ri.dblNetReturned, 0) + afterSave.dblNet
			,dblGrossReturned = ISNULL(ri.dblGrossReturned, 0) + afterSave.dblGross
	FROM	tblICInventoryReceiptItem ri 
			INNER JOIN #tmpAfterSaveReceiptItems afterSave
				ON ri.intInventoryReceiptItemId = afterSave.intSourceInventoryDetailId

	-- Validate for Over-Return.
	BEGIN 
		-- Validate for over-return 
		EXEC @intReturnValue = uspICValidateReceiptForReturn
			@intReceiptId = NULL
			,@intReturnId = @ReceiptId

		IF @intReturnValue < 0 GOTO _Exit 
	END 
END 

-- Reduce Open Purchase Contract Qty if IR is processed through Purchase Contract and source is not from Inbound Shipment
IF @ReceiptType = @ReceiptType_PurchaseContract AND @SourceType <> @SourceType_InboundShipment
BEGIN
	DECLARE @ItemsOpenPurchaseContract AS ItemsOpenPurchaseContractTableType

	IF @ForDelete = 0
	BEGIN
		INSERT INTO @ItemsOpenPurchaseContract(intItemId, intItemLocationId, intItemUOMId, dblQty, intTransactionId, strTransactionId, intTransactionTypeId)
		SELECT ri.intItemId, 
			l.intItemLocationId, 
			p.intItemUOMId, 
			-p.dblQty, 
			p.intInventoryReceiptItemId, 
			r.strReceiptNumber, 10 -- 10 is the Id of the Open Purchase Contract in tblICTransactionType table
		FROM @tblToProcess p
			INNER JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptItemId = p.intInventoryReceiptItemId
			INNER JOIN tblICInventoryReceipt r ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblICItemLocation l ON l.intItemId = ri.intItemId
	END
	ELSE
	BEGIN
		INSERT INTO @ItemsOpenPurchaseContract(intItemId, intItemLocationId, intItemUOMId, dblQty, intTransactionId, strTransactionId, intTransactionTypeId)
		SELECT log.intItemId, loc.intItemLocationId, log.intItemUOMId, log.dblQuantity, log.intTransactionId, '', 10
		FROM tblICTransactionDetailLog log
			INNER JOIN tblICItemLocation loc ON loc.intItemId = log.intItemId
		WHERE log.intTransactionId = @ReceiptId
			AND log.strTransactionType = 'Inventory Receipt'
	END

	--Uncomment this when Contract has implemented Open Purchase Contract
	--EXEC dbo.uspICIncreaseOpenPurchaseContractQty @ItemsOpenPurchaseContract
END

IF (@ReceiptType = @ReceiptType_PurchaseContract AND @SourceType = 6)
BEGIN
	BEGIN
		-- Create temporary table for processing records
		DECLARE @tblPurchaseContractOrderToProcess TABLE
		(
			intKeyId					INT IDENTITY,
			intInventoryReceiptItemId	INT,
			intPurchaseDetailId			INT,
			intItemUOMId				INT,
			dblQty						NUMERIC(12,4)
		)

		INSERT INTO @tblPurchaseContractOrderToProcess (
			intInventoryReceiptItemId,
			intPurchaseDetailId,
			intItemUOMId,
			dblQty
		)
		-- Changed Quantity/UOM
		SELECT 
			currentSnapshot.intInventoryReceiptItemId,
			PurchaseOrderDetail.intPurchaseDetailId,
			currentSnapshot.intItemUOMId,
			CASE 
				WHEN (ISNULL(currentSnapshot.ysnLoad, 0) = 0) THEN 
					dbo.fnCalculateQtyBetweenUOM(
						currentSnapshot.intItemUOMId
						, PurchaseOrderDetail.intUnitOfMeasureId
						, (
							CASE 
								WHEN @ForDelete = 1 THEN currentSnapshot.dblOpenReceive 
								ELSE (currentSnapshot.dblOpenReceive - previousSnapshot.dblOpenReceive) 
							END
						)
					)
				ELSE currentSnapshot.intLoadReceive END 
		FROM 
			#tmpAfterSaveReceiptItems currentSnapshot
			INNER JOIN #tmpBeforeSaveReceiptItems previousSnapshot
				ON previousSnapshot.intInventoryReceiptId = currentSnapshot.intInventoryReceiptId
				AND previousSnapshot.intInventoryReceiptItemId = currentSnapshot.intInventoryReceiptItemId
			INNER JOIN tblPOPurchaseDetail PurchaseOrderDetail
				ON PurchaseOrderDetail.intContractDetailId = currentSnapshot.intLineNo
			LEFT JOIN tblICItem Item 
				ON Item.intItemId = PurchaseOrderDetail.intItemId
		WHERE
			currentSnapshot.intLineNo IS NOT NULL
			AND currentSnapshot.intLineNo = previousSnapshot.intLineNo
			AND currentSnapshot.intItemId = previousSnapshot.intItemId		
			AND (currentSnapshot.intItemUOMId <> previousSnapshot.intItemUOMId OR currentSnapshot.dblOpenReceive <> previousSnapshot.dblOpenReceive)
		
		-- New PO Item Selected
		UNION ALL 
		SELECT 
			currentSnapshot.intInventoryReceiptItemId
			,PurchaseOrderDetail.intPurchaseDetailId
			,currentSnapshot.intItemUOMId
			,CASE 
				WHEN (ISNULL(currentSnapshot.ysnLoad, 0) = 0) THEN 
					dbo.fnCalculateQtyBetweenUOM (
						currentSnapshot.intItemUOMId
						, previousSnapshot.intItemUOMId
						, currentSnapshot.dblOpenReceive
					)
				ELSE 
					currentSnapshot.intLoadReceive 
			END
		FROM 
			#tmpAfterSaveReceiptItems currentSnapshot
			INNER JOIN #tmpBeforeSaveReceiptItems previousSnapshot
				ON previousSnapshot.intInventoryReceiptId = currentSnapshot.intInventoryReceiptId
				AND previousSnapshot.intInventoryReceiptItemId = currentSnapshot.intInventoryReceiptItemId
			INNER JOIN tblPOPurchaseDetail PurchaseOrderDetail
				ON PurchaseOrderDetail.intContractDetailId = currentSnapshot.intLineNo
			LEFT JOIN tblICItem Item 
				ON Item.intItemId = PurchaseOrderDetail.intItemId
		WHERE
			currentSnapshot.intLineNo IS NOT NULL
			AND currentSnapshot.intLineNo <> previousSnapshot.intLineNo		
			AND currentSnapshot.intItemId = previousSnapshot.intItemId		

		-- Replaced PO Item 
		UNION ALL
		SELECT 
			currentSnapshot.intInventoryReceiptItemId
			,PurchaseOrderDetail.intPurchaseDetailId
			,previousSnapshot.intItemUOMId
			,CASE 
				WHEN (ISNULL(previousSnapshot.ysnLoad, 0) = 0) THEN 
					dbo.fnCalculateQtyBetweenUOM (
						previousSnapshot.intItemUOMId
						, PurchaseOrderDetail.intUnitOfMeasureId
						, -previousSnapshot.dblOpenReceive
					)
				ELSE 
					previousSnapshot.intLoadReceive 
			END
		FROM 
			#tmpAfterSaveReceiptItems currentSnapshot
			INNER JOIN #tmpBeforeSaveReceiptItems previousSnapshot
				ON previousSnapshot.intInventoryReceiptId = currentSnapshot.intInventoryReceiptId
				AND previousSnapshot.intInventoryReceiptItemId = currentSnapshot.intInventoryReceiptItemId
			INNER JOIN tblPOPurchaseDetail PurchaseOrderDetail
				ON PurchaseOrderDetail.intContractDetailId = currentSnapshot.intLineNo
			LEFT JOIN tblICItem Item 
				ON Item.intItemId = PurchaseOrderDetail.intItemId
		WHERE
			currentSnapshot.intLineNo IS NOT NULL
			AND currentSnapshot.intLineNo <> previousSnapshot.intLineNo
			AND currentSnapshot.intItemId = previousSnapshot.intItemId
		
		-- Removed the PO Item 
		UNION ALL
		SELECT 
			currentSnapshot.intInventoryReceiptItemId
			,PurchaseOrderDetail.intPurchaseDetailId
			,previousSnapshot.intItemUOMId
			,CASE 
				WHEN (ISNULL(previousSnapshot.ysnLoad, 0) = 0) THEN 
					dbo.fnCalculateQtyBetweenUOM (
						previousSnapshot.intItemUOMId
						, PurchaseOrderDetail.intUnitOfMeasureId
						, -previousSnapshot.dblOpenReceive
					)
				ELSE 
					previousSnapshot.intLoadReceive 
			END
		FROM 
			#tmpAfterSaveReceiptItems currentSnapshot
			INNER JOIN #tmpBeforeSaveReceiptItems previousSnapshot
				ON previousSnapshot.intInventoryReceiptId = currentSnapshot.intInventoryReceiptId
				AND previousSnapshot.intInventoryReceiptItemId = currentSnapshot.intInventoryReceiptItemId
			INNER JOIN tblPOPurchaseDetail PurchaseOrderDetail
				ON PurchaseOrderDetail.intContractDetailId = currentSnapshot.intLineNo
			LEFT JOIN tblICItem Item 
				ON Item.intItemId = PurchaseOrderDetail.intItemId
		WHERE
			currentSnapshot.intLineNo IS NULL
			AND previousSnapshot.intLineNo IS NOT NULL
		
		-- Deleted the PO Item 
		UNION ALL	
		SELECT
			previousSnapshot.intInventoryReceiptItemId
			,PurchaseOrderDetail.intPurchaseDetailId
			,previousSnapshot.intItemUOMId
			,CASE 
				WHEN (ISNULL(previousSnapshot.ysnLoad, 0) = 0) THEN 
					dbo.fnCalculateQtyBetweenUOM (
						previousSnapshot.intItemUOMId
						, PurchaseOrderDetail.intUnitOfMeasureId
						, -previousSnapshot.dblOpenReceive
					)
				ELSE 
					previousSnapshot.intLoadReceive 
			END
		FROM 
			#tmpBeforeSaveReceiptItems previousSnapshot
			INNER JOIN tblPOPurchaseDetail PurchaseOrderDetail
				ON PurchaseOrderDetail.intContractDetailId = previousSnapshot.intLineNo
			LEFT JOIN tblICItem Item 
				ON Item.intItemId = PurchaseOrderDetail.intItemId
		WHERE
			previousSnapshot.intLineNo IS NOT NULL
			AND previousSnapshot.intInventoryReceiptItemId NOT IN (SELECT intInventoryReceiptItemId FROM #tmpAfterSaveReceiptItems)

		-- Added PO Item 
		UNION ALL
		SELECT 
			currentSnapshot.intInventoryReceiptItemId
			,PurchaseOrderDetail.intPurchaseDetailId
			,currentSnapshot.intItemUOMId
			,CASE 
				WHEN (ISNULL(currentSnapshot.ysnLoad, 0) = 0) THEN 
					dbo.fnCalculateQtyBetweenUOM (
						currentSnapshot.intItemUOMId
						, PurchaseOrderDetail.intUnitOfMeasureId
						, currentSnapshot.dblOpenReceive
					)
				ELSE 
					currentSnapshot.intLoadReceive 
			END
		FROM 
			#tmpAfterSaveReceiptItems currentSnapshot
			INNER JOIN tblPOPurchaseDetail PurchaseOrderDetail
				ON PurchaseOrderDetail.intContractDetailId = currentSnapshot.intLineNo
			LEFT JOIN tblICItem Item 
				ON Item.intItemId = PurchaseOrderDetail.intItemId
		WHERE
			currentSnapshot.intLineNo IS NOT NULL
			AND currentSnapshot.intInventoryReceiptItemId NOT IN (SELECT intInventoryReceiptItemId FROM #tmpBeforeSaveReceiptItems)
			 
		DECLARE loopItemsForPurchaseOrderReceivedQty CURSOR LOCAL FAST_FORWARD
		FOR 
		SELECT	intPurchaseDetailId
				,dblQty
				,intInventoryReceiptItemId
		FROM	@tblPurchaseContractOrderToProcess

		OPEN loopItemsForPurchaseOrderReceivedQty;
	
		-- Initial fetch attempt
		FETCH NEXT FROM loopItemsForPurchaseOrderReceivedQty INTO 
			@intPurchaseDetailId
			,@dblQty
			,@intInventoryReceiptItemId;

		-----------------------------------------------------------------------------------------------------------------------------
		-- Start of the loop for the integration sp. 
		-----------------------------------------------------------------------------------------------------------------------------
		WHILE @@FETCH_STATUS = 0
		BEGIN 		
			EXEC dbo.uspPOReceived 
				@intPurchaseDetailId
				,@intInventoryReceiptItemId
				,@dblQty
				,@UserId			
			
			IF @@ERROR <> 0 GOTO _Exit

			-- Attempt to fetch the next row from cursor. 
			FETCH NEXT FROM loopItemsForPurchaseOrderReceivedQty INTO 
				@intPurchaseDetailId
				,@dblQty
				,@intInventoryReceiptItemId	
		END;
		-----------------------------------------------------------------------------------------------------------------------------
		-- End of the loop
		-----------------------------------------------------------------------------------------------------------------------------

		CLOSE loopItemsForPurchaseOrderReceivedQty;
		DEALLOCATE loopItemsForPurchaseOrderReceivedQty;
	END
END

IF	@ReceiptType = @ReceiptType_PurchaseOrder
BEGIN 
	-- Get the deleted, new, or modified data. 
	BEGIN
		-- Create temporary table for processing records
		DECLARE @tblPurchaseOrderToProcess TABLE
		(
			intKeyId					INT IDENTITY,
			intInventoryReceiptItemId	INT,
			intPurchaseDetailId			INT,
			intItemUOMId				INT,
			dblQty						NUMERIC(12,4)
		)

		INSERT INTO @tblPurchaseOrderToProcess (
			intInventoryReceiptItemId,
			intPurchaseDetailId,
			intItemUOMId,
			dblQty
		)
		-- Changed Quantity/UOM
		SELECT 
			currentSnapshot.intInventoryReceiptItemId,
			currentSnapshot.intLineNo,
			currentSnapshot.intItemUOMId,
			CASE 
				WHEN (ISNULL(currentSnapshot.ysnLoad, 0) = 0) THEN 
					dbo.fnCalculateQtyBetweenUOM(
						currentSnapshot.intItemUOMId
						, PurchaseOrderDetail.intUnitOfMeasureId
						, (
							CASE 
								WHEN @ForDelete = 1 THEN currentSnapshot.dblOpenReceive 
								ELSE (currentSnapshot.dblOpenReceive - previousSnapshot.dblOpenReceive) 
							END
						)
					)
				ELSE currentSnapshot.intLoadReceive END 
		FROM 
			#tmpAfterSaveReceiptItems currentSnapshot
			INNER JOIN #tmpBeforeSaveReceiptItems previousSnapshot
				ON previousSnapshot.intInventoryReceiptId = currentSnapshot.intInventoryReceiptId
				AND previousSnapshot.intInventoryReceiptItemId = currentSnapshot.intInventoryReceiptItemId
			INNER JOIN tblPOPurchaseDetail PurchaseOrderDetail
				ON PurchaseOrderDetail.intPurchaseDetailId = currentSnapshot.intLineNo
			LEFT JOIN tblICItem Item 
				ON Item.intItemId = PurchaseOrderDetail.intItemId
		WHERE
			currentSnapshot.intLineNo IS NOT NULL
			AND currentSnapshot.intLineNo = previousSnapshot.intLineNo
			AND currentSnapshot.intItemId = previousSnapshot.intItemId		
			AND (currentSnapshot.intItemUOMId <> previousSnapshot.intItemUOMId OR currentSnapshot.dblOpenReceive <> previousSnapshot.dblOpenReceive)
		
		-- New PO Item Selected
		UNION ALL 
		SELECT 
			currentSnapshot.intInventoryReceiptItemId
			,currentSnapshot.intLineNo
			,currentSnapshot.intItemUOMId
			,CASE 
				WHEN (ISNULL(currentSnapshot.ysnLoad, 0) = 0) THEN 
					dbo.fnCalculateQtyBetweenUOM (
						currentSnapshot.intItemUOMId
						, previousSnapshot.intItemUOMId
						, currentSnapshot.dblOpenReceive
					)
				ELSE 
					currentSnapshot.intLoadReceive 
			END
		FROM 
			#tmpAfterSaveReceiptItems currentSnapshot
			INNER JOIN #tmpBeforeSaveReceiptItems previousSnapshot
				ON previousSnapshot.intInventoryReceiptId = currentSnapshot.intInventoryReceiptId
				AND previousSnapshot.intInventoryReceiptItemId = currentSnapshot.intInventoryReceiptItemId
			INNER JOIN tblPOPurchaseDetail PurchaseOrderDetail
				ON PurchaseOrderDetail.intPurchaseDetailId = currentSnapshot.intLineNo
			LEFT JOIN tblICItem Item 
				ON Item.intItemId = PurchaseOrderDetail.intItemId
		WHERE
			currentSnapshot.intLineNo IS NOT NULL
			AND currentSnapshot.intLineNo <> previousSnapshot.intLineNo		
			AND currentSnapshot.intItemId = previousSnapshot.intItemId		

		-- Replaced PO Item 
		UNION ALL
		SELECT 
			currentSnapshot.intInventoryReceiptItemId
			,previousSnapshot.intLineNo
			,previousSnapshot.intItemUOMId
			,CASE 
				WHEN (ISNULL(previousSnapshot.ysnLoad, 0) = 0) THEN 
					dbo.fnCalculateQtyBetweenUOM (
						previousSnapshot.intItemUOMId
						, PurchaseOrderDetail.intUnitOfMeasureId
						, -previousSnapshot.dblOpenReceive
					)
				ELSE 
					previousSnapshot.intLoadReceive 
			END
		FROM 
			#tmpAfterSaveReceiptItems currentSnapshot
			INNER JOIN #tmpBeforeSaveReceiptItems previousSnapshot
				ON previousSnapshot.intInventoryReceiptId = currentSnapshot.intInventoryReceiptId
				AND previousSnapshot.intInventoryReceiptItemId = currentSnapshot.intInventoryReceiptItemId
			INNER JOIN tblPOPurchaseDetail PurchaseOrderDetail
				ON PurchaseOrderDetail.intPurchaseDetailId = currentSnapshot.intLineNo
			LEFT JOIN tblICItem Item 
				ON Item.intItemId = PurchaseOrderDetail.intItemId
		WHERE
			currentSnapshot.intLineNo IS NOT NULL
			AND currentSnapshot.intLineNo <> previousSnapshot.intLineNo
			AND currentSnapshot.intItemId = previousSnapshot.intItemId
		
		-- Removed the PO Item 
		UNION ALL
		SELECT 
			currentSnapshot.intInventoryReceiptItemId
			,previousSnapshot.intLineNo
			,previousSnapshot.intItemUOMId
			,CASE 
				WHEN (ISNULL(previousSnapshot.ysnLoad, 0) = 0) THEN 
					dbo.fnCalculateQtyBetweenUOM (
						previousSnapshot.intItemUOMId
						, PurchaseOrderDetail.intUnitOfMeasureId
						, -previousSnapshot.dblOpenReceive
					)
				ELSE 
					previousSnapshot.intLoadReceive 
			END
		FROM 
			#tmpAfterSaveReceiptItems currentSnapshot
			INNER JOIN #tmpBeforeSaveReceiptItems previousSnapshot
				ON previousSnapshot.intInventoryReceiptId = currentSnapshot.intInventoryReceiptId
				AND previousSnapshot.intInventoryReceiptItemId = currentSnapshot.intInventoryReceiptItemId
			INNER JOIN tblPOPurchaseDetail PurchaseOrderDetail
				ON PurchaseOrderDetail.intPurchaseDetailId = currentSnapshot.intLineNo
			LEFT JOIN tblICItem Item 
				ON Item.intItemId = PurchaseOrderDetail.intItemId
		WHERE
			currentSnapshot.intLineNo IS NULL
			AND previousSnapshot.intLineNo IS NOT NULL
		
		-- Deleted the PO Item 
		UNION ALL	
		SELECT
			previousSnapshot.intInventoryReceiptItemId
			,previousSnapshot.intLineNo
			,previousSnapshot.intItemUOMId
			,CASE 
				WHEN (ISNULL(previousSnapshot.ysnLoad, 0) = 0) THEN 
					dbo.fnCalculateQtyBetweenUOM (
						previousSnapshot.intItemUOMId
						, PurchaseOrderDetail.intUnitOfMeasureId
						, -previousSnapshot.dblOpenReceive
					)
				ELSE 
					previousSnapshot.intLoadReceive 
			END
		FROM 
			#tmpBeforeSaveReceiptItems previousSnapshot
			INNER JOIN tblPOPurchaseDetail PurchaseOrderDetail
				ON PurchaseOrderDetail.intPurchaseDetailId = previousSnapshot.intLineNo
			LEFT JOIN tblICItem Item 
				ON Item.intItemId = PurchaseOrderDetail.intItemId
		WHERE
			previousSnapshot.intLineNo IS NOT NULL
			AND previousSnapshot.intInventoryReceiptItemId NOT IN (SELECT intInventoryReceiptItemId FROM #tmpAfterSaveReceiptItems)

		-- Added PO Item 
		UNION ALL
		SELECT 
			currentSnapshot.intInventoryReceiptItemId
			,currentSnapshot.intLineNo
			,currentSnapshot.intItemUOMId
			,CASE 
				WHEN (ISNULL(currentSnapshot.ysnLoad, 0) = 0) THEN 
					dbo.fnCalculateQtyBetweenUOM (
						currentSnapshot.intItemUOMId
						, PurchaseOrderDetail.intUnitOfMeasureId
						, currentSnapshot.dblOpenReceive
					)
				ELSE 
					currentSnapshot.intLoadReceive 
			END
		FROM 
			#tmpAfterSaveReceiptItems currentSnapshot
			INNER JOIN tblPOPurchaseDetail PurchaseOrderDetail
				ON PurchaseOrderDetail.intPurchaseDetailId = currentSnapshot.intLineNo
			LEFT JOIN tblICItem Item 
				ON Item.intItemId = PurchaseOrderDetail.intItemId
		WHERE
			currentSnapshot.intLineNo IS NOT NULL
			AND currentSnapshot.intInventoryReceiptItemId NOT IN (SELECT intInventoryReceiptItemId FROM #tmpBeforeSaveReceiptItems)

		DECLARE loopItemsForPurchaseOrderReceivedQty CURSOR LOCAL FAST_FORWARD
		FOR 
		SELECT	intPurchaseDetailId
				,dblQty
				,intInventoryReceiptItemId
		FROM	@tblPurchaseOrderToProcess

		OPEN loopItemsForPurchaseOrderReceivedQty;
	
		-- Initial fetch attempt
		FETCH NEXT FROM loopItemsForPurchaseOrderReceivedQty INTO 
			@intPurchaseDetailId
			,@dblQty
			,@intInventoryReceiptItemId;

		-----------------------------------------------------------------------------------------------------------------------------
		-- Start of the loop for the integration sp. 
		-----------------------------------------------------------------------------------------------------------------------------
		WHILE @@FETCH_STATUS = 0
		BEGIN 		
			EXEC dbo.uspPOReceived 
				@intPurchaseDetailId
				,@intInventoryReceiptItemId
				,@dblQty
				,@UserId			
			
			IF @@ERROR <> 0 GOTO _Exit

			-- Attempt to fetch the next row from cursor. 
			FETCH NEXT FROM loopItemsForPurchaseOrderReceivedQty INTO 
				@intPurchaseDetailId
				,@dblQty
				,@intInventoryReceiptItemId	
		END;
		-----------------------------------------------------------------------------------------------------------------------------
		-- End of the loop
		-----------------------------------------------------------------------------------------------------------------------------

		CLOSE loopItemsForPurchaseOrderReceivedQty;
		DEALLOCATE loopItemsForPurchaseOrderReceivedQty;
	END
END 

IF(@ReceiptType = @ReceiptType_TransferOrder)
BEGIN
	IF @ForDelete = 0 
		EXEC dbo.[uspICUpdateTransferOrderStatus] @ReceiptId, 3 -- Set status of the transfer order to 'Closed'
	ELSE 
		EXEC dbo.[uspICUpdateTransferOrderStatus] @ReceiptId, 1 -- Set status of the transfer order to 'Open'
END

-- Delete Quality Management Inspection
DECLARE @intProductTypeId AS INT = 3 -- Receipt
	,@intProductValueId AS INT = @ReceiptId -- intInventoryReceiptId

IF @ForDelete = 1
BEGIN
	EXEC uspQMInspectionDeleteResult @intProductValueId, @intProductTypeId
END
ELSE
BEGIN
	DECLARE @intControlPointId AS INT = 3
	DECLARE @QualityInspectionTable QualityInspectionTable
 
	INSERT INTO @QualityInspectionTable (intPropertyId,strPropertyName,strPropertyValue,strComment)
	SELECT iri.intQAPropertyId, iri.strPropertyName,'true / false', iri.strComment
	FROM tblICInventoryReceiptInspection iri
	WHERE iri.intInventoryReceiptId = @ReceiptId
 
	EXEC uspQMInspectionSaveResult @intControlPointId, @intProductTypeId, @intProductValueId, @UserId, @QualityInspectionTable	
END

-- Delete the data snapshot. 
DELETE	FROM tblICTransactionDetailLog 
WHERE	strTransactionType = 'Inventory Receipt' 
		AND intTransactionId = @ReceiptId

_Exit: 

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpBeforeSaveReceiptItems')) DROP TABLE #tmpBeforeSaveReceiptItems
IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAfterSaveReceiptItems')) DROP TABLE #tmpAfterSaveReceiptItems

-- Sync Lot Remarks
UPDATE l
SET l.strNotes = rl.strRemarks
FROM tblICInventoryReceiptItemLot rl
	INNER JOIN tblICLot l ON l.intLotId = rl.intLotId
	INNER JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptItemId = rl.intInventoryReceiptItemId
WHERE l.strNotes != rl.strRemarks
	AND ri.intInventoryReceiptId = @ReceiptId