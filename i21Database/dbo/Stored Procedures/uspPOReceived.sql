CREATE PROCEDURE [dbo].[uspPOReceived]
	@ItemsFromInventoryReceipt ReceiptItemTableType READONLY 
	,@intUserId INT 
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Validations
BEGIN 
	--Validate if purchase order exists.
	BEGIN 
		DECLARE @purchaseOrderNumber AS NVARCHAR(50)
		SELECT	TOP 1 
				@purchaseOrderNumber = strPurchaseOrderNumber
		FROM	@ItemsFromInventoryReceipt ItemReceipt LEFT JOIN tblPOPurchase PO
					ON ItemReceipt.intOrderId = PO.intPurchaseId
		WHERE	strPurchaseOrderNumber IS NULL 

		IF(@purchaseOrderNumber <> NULL)
		BEGIN
			-- 'Purchase Order does not exists.'
			RAISERROR(51033, 11, 1); 
			RETURN;
		END
	END
	
	--Validate if item exists on PO
	BEGIN 
		DECLARE @strItemNo AS NVARCHAR(50)

		SELECT TOP 1 
				@strItemNo = Item.strItemNo
		FROM	tblICItem Item INNER JOIN @ItemsFromInventoryReceipt ReceiptItems
					ON Item.intItemId = ReceiptItems.intItemId
				LEFT JOIN tblPOPurchaseDetail PODetails
					ON PODetails.intPurchaseId = ReceiptItems.intOrderId
					AND PODetails.intItemId = ReceiptItems.intItemId
					AND PODetails.intPurchaseDetailId = ReceiptItems.intLineNo
		WHERE	PODetails.intItemId IS NULL 

		IF(@strItemNo <> NULL)
		BEGIN
			-- 'Purchase Order item does not exists.'
			RAISERROR(51034, 11, 1); 
			RETURN;
		END
	END
		--Validate if PO is not cancelled, or short closed
	BEGIN 
		DECLARE @poId AS NVARCHAR(50)

		SELECT TOP 1 
				@poId = A.strPurchaseOrderNumber
		FROM tblPOPurchase A
		INNER JOIN @ItemsFromInventoryReceipt B
			ON A.intPurchaseId = B.intOrderId
		WHERE A.intOrderStatusId IN (3,4,6)

		IF(@poId <> NULL)
		BEGIN
			DECLARE @error NVARCHAR(500);
			SET @error = 'Unable to update PO. Please check status of ' + @poId;
			RAISERROR(@error, 11, 1); 
			RETURN;
		END
	END
END

-- Update the On-Order Qty
BEGIN 
	DECLARE @ItemToUpdateOnOrderQty ItemCostingTableType

	-- Create the list. 
	INSERT INTO @ItemToUpdateOnOrderQty (
			dtmDate
			,intItemId
			,intItemLocationId
			,intItemUOMId
			,intSubLocationId
			,dblQty
			,dblUOMQty
			,intTransactionId
			,intTransactionDetailId
			,strTransactionId
			,intTransactionTypeId
	)
	SELECT	dtmDate					= ReceiptItems.dtmDate
			,intItemId				= ReceiptItems.intItemId
			,intItemLocationId		= il.intItemLocationId --PO.intShipToId--ReceiptItems.intItemLocationId
			,intItemUOMId			= ReceiptItems.intItemUOMId
			,intSubLocationId		= ReceiptItems.intSubLocationId
			--IC send this data as is, posted or unposted, they are the one doing the logic if on order will be deducted or added
			--NOTE: logic here that we will increase the on order or deduct was on IC, negate the qty to reduce the On Order Qty. 
			,dblQty					= -ReceiptItems.dblQty 
			,dblUOMQty				= ReceiptItems.dblUOMQty
			,intTransactionId		= ReceiptItems.intInventoryReceiptId
			,intTransactionDetailId = ReceiptItems.intInventoryReceiptDetailId
			,strTransactionId		= ReceiptItems.strInventoryReceiptId
			,intTransactionTypeId	= -1 -- Any value
	FROM	@ItemsFromInventoryReceipt ReceiptItems INNER JOIN tblPOPurchase PO 
				ON ReceiptItems.intOrderId = PO.intPurchaseId
			LEFT JOIN tblICItemLocation il
				ON il.intItemId = ReceiptItems.intItemId
				AND il.intLocationId = PO.intShipToId
	WHERE	ReceiptItems.intOrderId IS NOT NULL 

	-- Call the stored procedure that updates the on order qty. 
	EXEC dbo.uspICIncreaseOnOrderQty 
		@ItemToUpdateOnOrderQty
END 

-- Update the PO receive Qty
BEGIN 
	UPDATE	PODetail
	SET		dblQtyReceived = PODetail.dblQtyReceived + dbo.fnCalculateQtyBetweenUOM(Items.intItemUOMId, PODetail.intUnitOfMeasureId, Items.dblTotalQty)
	FROM	tblPOPurchaseDetail PODetail 
	CROSS APPLY ( 
	
		SELECT 
			SUM(ReceiptItems.dblQty) AS dblTotalQty
			,ReceiptItems.intItemUOMId
		FROM @ItemsFromInventoryReceipt ReceiptItems
				WHERE PODetail.intItemId = ReceiptItems.intItemId 
				AND PODetail.intPurchaseDetailId = ReceiptItems.intLineNo
				AND PODetail.intPurchaseId = ReceiptItems.intOrderId
		GROUP BY ReceiptItems.intItemUOMId
	) Items
END

--UPDATE CONTRACT IF PO ITEM IS PART OF A CONTRACT

--IF OBJECT_ID('tempdb..#tmpContractItems') IS NOT NULL DROP TABLE #tmpContractItems

DECLARE @contractItems AS ReceiptItemTableType
INSERT INTO @contractItems (
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
	)
SELECT
		A.[intInventoryReceiptId] 
		,A.[strInventoryReceiptId] 
		,A.[strReceiptType] 
		,A.[intSourceType] 
		,A.[dtmDate] 
		,A.[intCurrencyId] 
		,A.[dblExchangeRate] 
		-- Detail 
		,A.[intInventoryReceiptDetailId] 
		,A.[intItemId] 
		,A.[intLotId] 
		,A.[strLotNumber] 
		,A.[intLocationId] 
		,A.[intItemLocationId] 
		,A.[intSubLocationId] 
		,A.[intStorageLocationId] 
		,A.[intItemUOMId] 
		,A.[intWeightUOMId] 
		,A.[dblQty] 
		,A.[dblUOMQty] 
		,A.[dblNetWeight] 
		,A.[dblCost] 
		,A.[intContainerId] 
		,A.[intOwnershipType] 
		,A.[intOrderId] 
		,A.[intSourceId] 
		,A.[intLineNo] 
FROM @ItemsFromInventoryReceipt A 
INNER JOIN tblPOPurchaseDetail B ON A.intLineNo = B.intPurchaseDetailId
WHERE B.intContractDetailId > 0

IF EXISTS(SELECT 1 FROM @contractItems)
BEGIN
	DECLARE @userId INT = (SELECT TOP 1  A.intEntityId FROM tblICInventoryReceipt A INNER JOIN @ItemsFromInventoryReceipt B ON A.intInventoryReceiptId = B.intInventoryReceiptId)
	EXEC uspCTReceived @contractItems, @userId
	IF @@ERROR != 0
	BEGIN
		RETURN;
	END
END

-- Update the status of the PO
IF EXISTS (SELECT TOP 1 1 FROM @ItemsFromInventoryReceipt WHERE intOrderId IS NOT NULL)
BEGIN 
	DECLARE @intOrderId INT
	
	-- Trim down the list of Purchase Orders. 
	SELECT	DISTINCT 
			intOrderId 
	INTO	#POIds 
	FROM	@ItemsFromInventoryReceipt
	WHERE	intOrderId IS NOT NULL 
	
	DECLARE loopReceiptPOs CURSOR LOCAL FAST_FORWARD
	FOR 
	SELECT  intOrderId
	FROM	#POIds

	OPEN loopReceiptPOs;

	-- Initial fetch attempt
	FETCH NEXT FROM loopReceiptPOs INTO 
		@intOrderId

	-----------------------------------------------------------------------------------------------------------------------------
	-- Start of the loop
	-----------------------------------------------------------------------------------------------------------------------------
	WHILE @@FETCH_STATUS = 0
	BEGIN 
		EXEC uspPOUpdateStatus @intOrderId, DEFAULT
		
		-- Attempt to fetch the next row from cursor. 
		FETCH NEXT FROM loopReceiptPOs INTO 
			@intOrderId
	END;
	-----------------------------------------------------------------------------------------------------------------------------
	-- End of the loop
	-----------------------------------------------------------------------------------------------------------------------------

	CLOSE loopReceiptPOs;
	DEALLOCATE loopReceiptPOs;
END

-- REFACTOR OLD CODE:
--===========================================================================================================================================================
-- BEGIN ORIGINAL CODE:
--===========================================================================================================================================================

	--DECLARE @purchaseId INT, @lineNo INT, @itemId INT;
	--DECLARE @purchaseOrderNumber NVARCHAR(50), @strItemNo NVARCHAR(50);
	--DECLARE @posted BIT;
	--DECLARE @count INT = 0;
	--DECLARE @receivedNum DECIMAL(18,6);

	--SELECT	B.intOrderId
	--		,B.intLineNo
	--		,B.dblOpenReceive
	--		,B.intItemId
	--		,A.ysnPosted
	--		,B.intUnitMeasureId
	--		,CalculatedOpenReceive = B.dblOpenReceive
	--INTO	#tmpReceivedPOItems
	--FROM	tblICInventoryReceipt A LEFT JOIN tblICInventoryReceiptItem B 
	--			ON A.intInventoryReceiptId = B.intInventoryReceiptId
	--WHERE	A.intInventoryReceiptId = @receiptItemId

	--SELECT TOP 1 @posted = ysnPosted FROM #tmpReceivedPOItems

	----Validate if purchase order exists..
	--SELECT	TOP 1 
	--		@purchaseOrderNumber = strPurchaseOrderNumber
	--FROM	#tmpReceivedPOItems A OUTER APPLY  (
	--			SELECT strPurchaseOrderNumber FROM tblPOPurchase B WHERE A.intOrderId = B.intPurchaseId
	--		) PurchaseOrders
	--WHERE	PurchaseOrders.strPurchaseOrderNumber IS NULL

	--IF(@purchaseOrderNumber <> NULL)
	--BEGIN
	--	RAISERROR(51033, 11, 1); --Not Exists
	--	RETURN;
	--END

	----Validate if item exists on PO
	--SELECT  TOP 1 
	--		@strItemNo = (SELECT strItemNo FROM tblICItem WHERE intItemId = A.intItemId)
	--FROM	#tmpReceivedPOItems A OUTER APPLY (
	--			SELECT	intItemId 
	--			FROM	tblPOPurchaseDetail B 
	--			WHERE	A.intOrderId = B.intPurchaseId
	--					AND A.intItemId = B.intItemId 
	--					AND A.intLineNo = B.intPurchaseDetailId
	--		) PurchaseOrderDetails
	--WHERE	PurchaseOrderDetails.intItemId IS NULL

	--IF(@strItemNo <> NULL)
	--BEGIN
	--	--PO item not exists
	--	RAISERROR(51034, 11, 1); 
	--	RETURN;
	--END

	---- Calculate the open receive to the UOM of the PO
	--UPDATE	POItems
	--SET		CalculatedOpenReceive = dbo.fnCalculateQtyBetweenUOM(POItems.intUnitMeasureId, PODetail.intUnitOfMeasureId, POItems.dblOpenReceive)
	--FROM	#tmpReceivedPOItems POItems INNER JOIN dbo.tblPOPurchaseDetail PODetail
	--			ON POItems.intOrderId = PODetail.intPurchaseId
	--			AND POItems.intLineNo = PODetail.intPurchaseDetailId


	---- Update the On Order Qty
	--BEGIN 
	--	DECLARE @ItemToUpdateOnOrderQty ItemCostingTableType

	--	-- Get the list. 
	--	INSERT INTO @ItemToUpdateOnOrderQty (
	--			dtmDate
	--			,intItemId
	--			,intItemLocationId
	--			,intItemUOMId
	--			,intSubLocationId
	--			,dblQty
	--			,dblUOMQty
	--			,intTransactionId
	--			,intTransactionDetailId
	--			,strTransactionId
	--			,intTransactionTypeId
	--	)
	--	SELECT	dtmDate					= Receipt.dtmReceiptDate
	--			,intItemId				= ReceiptItem.intItemId
	--			,intItemLocationId		= ItemLocation.intItemLocationId
	--			,intItemUOMId			= ReceiptItem.intUnitMeasureId
	--			,intSubLocationId		= ReceiptItem.intSubLocationId
	--			,dblQty					= ReceiptItem.dblOpenReceive * CASE WHEN @ysnPost = 1 THEN -1 ELSE 1 END -- dbo.fnCalculateQtyBetweenUOM(ReceiptItem.intUnitMeasureId, PODetail.intUnitOfMeasureId, ReceiptItem.dblOpenReceive) 
	--			,dblUOMQty				= ItemUOM.dblUnitQty   --1 -- Keep value as one (1). The dblQty is converted manually by using the fnCalculateQtyBetweenUOM function.
	--			,intTransactionId		= Receipt.intInventoryReceiptId
	--			,intTransactionDetailId = ReceiptItem.intInventoryReceiptItemId
	--			,strTransactionId		= Receipt.strReceiptNumber
	--			,intTransactionTypeId	= -1 -- any value
	--	FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
	--				ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
	--			INNER JOIN dbo.tblPOPurchaseDetail PODetail
	--				ON ReceiptItem.intOrderId = PODetail.intPurchaseId
	--				AND ReceiptItem.intLineNo = PODetail.intPurchaseDetailId
	--			INNER JOIN dbo.tblICItemLocation ItemLocation
	--				ON ItemLocation.intItemId = ReceiptItem.intItemId
	--				AND ItemLocation.intLocationId = Receipt.intLocationId				
	--			INNER JOIN dbo.tblICItemUOM	ItemUOM
	--				ON ItemUOM.intItemUOMId = ReceiptItem.intUnitMeasureId
	--	WHERE	Receipt.intInventoryReceiptId = @receiptItemId
	--			AND ReceiptItem.intOrderId IS NOT NULL 

	--	-- Call the stored procedure that updates the on order qty. 
	--	EXEC dbo.uspICIncreaseOnOrderQty @ItemToUpdateOnOrderQty
	--END 
	
	--UPDATE	A
	--SET		dblQtyReceived = CASE	WHEN	 @posted = 1 THEN (dblQtyReceived + B.CalculatedOpenReceive) 
	--								ELSE (	dblQtyReceived - B.CalculatedOpenReceive) 
	--						END
	--FROM	tblPOPurchaseDetail A INNER JOIN #tmpReceivedPOItems B 
	--			ON A.intItemId = B.intItemId 
	--			AND A.intPurchaseDetailId = B.intLineNo
	--			AND intPurchaseId = B.intOrderId
	--			--AND intPurchaseDetailId IN (SELECT intLineNo FROM #tmpReceivedPOItems)

	--SELECT DISTINCT intOrderId INTO #poIds FROM #tmpReceivedPOItems
	--DECLARE @countPoIds INT = (SELECT COUNT(*) FROM #poIds)
	--DECLARE @counter INT = 0;

	--WHILE @counter != @countPoIds
	--BEGIN
	--	SET @counter = @counter + 1;
	--	SET @purchaseId = (SELECT TOP(1) intOrderId FROM #poIds)
	--	EXEC uspPOUpdateStatus @purchaseId, DEFAULT
	--	DELETE FROM #poIds WHERE intOrderId = @purchaseId
	--END
--===========================================================================================================================================================
-- END ORIGINAL CODE:
--===========================================================================================================================================================
END