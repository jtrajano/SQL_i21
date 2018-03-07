CREATE PROCEDURE [dbo].[uspPOReceived]
	--@ItemsFromInventoryReceipt ReceiptItemTableType READONLY 
	--,@intUserId INT 

	@intPurchaseDetailId AS INT 
	,@intInventoryReceiptItemId AS INT
	,@dblQty AS NUMERIC(38, 20)
	,@intUserId INT 

AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @intPurchaseOrderId INT

SELECT	TOP 1 
		@intPurchaseOrderId = PO.intPurchaseId
FROM	tblPOPurchase PO INNER JOIN tblPOPurchaseDetail POD
			ON PO.intPurchaseId = POD.intPurchaseId
WHERE	POD.intPurchaseDetailId = @intPurchaseDetailId

-- Validations
BEGIN 
	--Validate if purchase order exists.
	BEGIN 
		DECLARE @purchaseOrderNumber AS NVARCHAR(50)
		SELECT	TOP 1 
				@purchaseOrderNumber = strPurchaseOrderNumber
		FROM	tblPOPurchase PO INNER JOIN tblPOPurchaseDetail POD
					ON PO.intPurchaseId = POD.intPurchaseId
		WHERE	POD.intPurchaseDetailId = @intPurchaseDetailId
				AND PO.strPurchaseOrderNumber IS NULL 

		IF(@purchaseOrderNumber <> NULL)
		BEGIN
			-- 'Purchase Order does not exists.'
			RAISERROR('Purchase Order does not exists.', 11, 1); 
			RETURN;
		END
	END
	
	--Validate if item exists on PO
	BEGIN 
		DECLARE @strItemNo AS NVARCHAR(50)

		SELECT TOP 1 
				@strItemNo = Item.strItemNo
		FROM	tblPOPurchaseDetail PODetails LEFT JOIN tblICItem Item 
					ON PODetails.intItemId = Item.intItemId
		WHERE	PODetails.intPurchaseDetailId = @intPurchaseDetailId
				AND Item.intItemId IS NULL 

		IF(@strItemNo <> NULL)
		BEGIN
			-- 'Purchase Order item does not exists.'
			RAISERROR('Purchase Order item does not exists.', 11, 1); 
			RETURN;
		END
	END
		--Validate if PO is not cancelled, or short closed
	BEGIN 
		DECLARE @poId AS NVARCHAR(50)

		SELECT TOP 1 
				@poId = PO.strPurchaseOrderNumber
		FROM	tblPOPurchase PO INNER JOIN tblPOPurchaseDetail POD
					ON PO.intPurchaseId = POD.intPurchaseId
		WHERE	POD.intPurchaseDetailId = @intPurchaseDetailId
				AND PO.intOrderStatusId IN (3,4,6)

		IF(@poId <> NULL)
		BEGIN
			DECLARE @error NVARCHAR(500);
			SET @error = 'Unable to update PO. The status for ' + @poId + ' is already Cancelled or Short Closed.';
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
	SELECT	dtmDate					= PO.dtmDate
			,intItemId				= ReceiptItems.intItemId
			,intItemLocationId		= il.intItemLocationId --PO.intShipToId--ReceiptItems.intItemLocationId
			,intItemUOMId			= COALESCE(ReceiptItems.intWeightUOMId, ReceiptItems.intUnitMeasureId) 
			,intSubLocationId		= ReceiptItems.intSubLocationId
			--IC send this data as is, posted or unposted, they are the one doing the logic if on order will be deducted or added
			--NOTE: logic here that we will increase the on order or deduct was on IC, negate the qty to reduce the On Order Qty. 
			,dblQty					= -@dblQty
			,dblUOMQty				= iu.dblUnitQty
			,intTransactionId		= ReceiptItems.intInventoryReceiptId
			,intTransactionDetailId = ReceiptItems.intInventoryReceiptItemId
			,strTransactionId		= Receipt.strReceiptNumber
			,intTransactionTypeId	= -1 -- Any value
	FROM	tblPOPurchase PO INNER JOIN tblPOPurchaseDetail POD
				ON PO.intPurchaseId = POD.intPurchaseId
			INNER JOIN (
				tblICInventoryReceipt Receipt INNER JOIN tblICInventoryReceiptItem ReceiptItems
					ON Receipt.intInventoryReceiptId = ReceiptItems.intInventoryReceiptId
			)
				ON ReceiptItems.intInventoryReceiptItemId = @intInventoryReceiptItemId
			LEFT JOIN tblICItemLocation il
				ON il.intItemId = POD.intItemId
				AND il.intLocationId = PO.intShipToId
			LEFT JOIN tblICItemUOM iu
				ON iu.intItemId = ReceiptItems.intItemId
				AND iu.intItemUOMId = COALESCE(ReceiptItems.intWeightUOMId, ReceiptItems.intUnitMeasureId) 
	WHERE	POD.intPurchaseDetailId = @intPurchaseDetailId
			AND ISNULL(@dblQty, 0) <> 0

	-- Call the stored procedure that updates the on order qty. 
	EXEC dbo.uspICIncreaseOnOrderQty 
		@ItemToUpdateOnOrderQty
END 

-- Update the PO receive Qty
BEGIN 
	UPDATE	PODetail
	SET		dblQtyReceived = PODetail.dblQtyReceived + @dblQty
	FROM	tblPOPurchaseDetail PODetail 
	WHERE	PODetail.intPurchaseDetailId = @intPurchaseDetailId
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
		ri.[intInventoryReceiptId] 
		,[strInventoryReceiptId] = r.strReceiptNumber
		,r.[strReceiptType] 
		,r.[intSourceType] 
		,[dtmDate] = r.dtmReceiptDate
		,r.[intCurrencyId] 
		,[dblExchangeRate] = ri.dblForexRate --r.[dblExchangeRate] 
		-- Detail 
		,[intInventoryReceiptDetailId] = ri.[intInventoryReceiptItemId] 
		,ri.[intItemId] 
		,[intLotId] = NULL --A.[intLotId] 
		,[strLotNumber] = NULL --A.[strLotNumber] 
		,r.[intLocationId] 
		,il.[intItemLocationId] 
		,ri.[intSubLocationId] 
		,ri.[intStorageLocationId] 
		,ri.[intUnitMeasureId] 
		,ri.[intWeightUOMId] 
		,@dblQty--A.[dblQty] 
		,[dblUOMQty] = iu.dblUnitQty --A.[dblUOMQty] 
		,[dblNetWeight] = ri.dblNet --A.[dblNetWeight] 
		,ri.[dblUnitCost] 
		,ri.[intContainerId] 
		,ri.[intOwnershipType] 
		,ri.[intOrderId] 
		,ri.[intSourceId] 
		,ri.[intLineNo] 
FROM	tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
			ON r.intInventoryReceiptId = ri.intInventoryReceiptId
		LEFT JOIN tblICItemLocation il
			ON il.intItemId = ri.intItemId
			AND il.intLocationId = r.intLocationId
		LEFT JOIN tblICItemUOM iu
			ON iu.intItemId = ri.intItemId
			AND iu.intItemUOMId = ri.intUnitMeasureId
WHERE	ri.intInventoryReceiptItemId = @intInventoryReceiptItemId
		AND ISNULL(@dblQty, 0) <> 0 
		AND r.strReceiptType = 'Purchase Contract'
		
--FROM @ItemsFromInventoryReceipt A 
--INNER JOIN tblPOPurchaseDetail B ON A.intLineNo = B.intPurchaseDetailId
--WHERE B.intContractDetailId > 0

IF EXISTS(SELECT 1 FROM @contractItems)
BEGIN
	--DECLARE @userId INT = (
	--	SELECT	TOP 1 
	--			A.intEntityId 
	--	FROM	tblICInventoryReceipt A INNER JOIN @ItemsFromInventoryReceipt B 
	--				ON A.intInventoryReceiptId = B.intInventoryReceiptId)

	EXEC uspCTReceived @contractItems, @intUserId
	IF @@ERROR != 0
	BEGIN
		RETURN;
	END
END

-- Update the status of the PO
BEGIN 
	EXEC uspPOUpdateStatus @intPurchaseOrderId, DEFAULT
END 


---- Update the status of the PO
--IF EXISTS (SELECT TOP 1 1 FROM @ItemsFromInventoryReceipt WHERE intOrderId IS NOT NULL)
--BEGIN 
--	DECLARE @intOrderId INT
	
--	-- Trim down the list of Purchase Orders. 
--	SELECT	DISTINCT 
--			intOrderId 
--	INTO	#POIds 
--	FROM	@ItemsFromInventoryReceipt
--	WHERE	intOrderId IS NOT NULL 
	
--	DECLARE loopReceiptPOs CURSOR LOCAL FAST_FORWARD
--	FOR 
--	SELECT  intOrderId
--	FROM	#POIds

--	OPEN loopReceiptPOs;

--	-- Initial fetch attempt
--	FETCH NEXT FROM loopReceiptPOs INTO 
--		@intOrderId

--	-----------------------------------------------------------------------------------------------------------------------------
--	-- Start of the loop
--	-----------------------------------------------------------------------------------------------------------------------------
--	WHILE @@FETCH_STATUS = 0
--	BEGIN 
--		EXEC uspPOUpdateStatus @intOrderId, DEFAULT
		
--		-- Attempt to fetch the next row from cursor. 
--		FETCH NEXT FROM loopReceiptPOs INTO 
--			@intOrderId
--	END;
--	-----------------------------------------------------------------------------------------------------------------------------
--	-- End of the loop
--	-----------------------------------------------------------------------------------------------------------------------------

--	CLOSE loopReceiptPOs;
--	DEALLOCATE loopReceiptPOs;
--END

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
	--	RAISERROR('Purchase Order does not exists.', 11, 1); --Not Exists
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
	--	RAISERROR('Purchase Order item does not exists.', 11, 1); 
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