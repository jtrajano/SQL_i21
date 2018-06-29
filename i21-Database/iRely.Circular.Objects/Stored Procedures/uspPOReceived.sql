CREATE PROCEDURE [dbo].[uspPOReceived]
	@intPurchaseDetailId AS INT 
	,@intInventoryReceiptItemId AS INT
	,@dblQty AS NUMERIC(38, 20)
	,@intUserId INT 
AS

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
			,intItemId				= POD.intItemId
			,intItemLocationId		= il.intItemLocationId 
			,intItemUOMId			= POD.intUnitOfMeasureId
			,intSubLocationId		= NULL 
			,dblQty					= -@dblQty
			,dblUOMQty				= iu.dblUnitQty
			,intTransactionId		= PO.intPurchaseId
			,intTransactionDetailId = POD.intPurchaseDetailId
			,strTransactionId		= PO.strPurchaseOrderNumber
			,intTransactionTypeId	= -1 -- Any value
	FROM	tblPOPurchase PO INNER JOIN tblPOPurchaseDetail POD
				ON PO.intPurchaseId = POD.intPurchaseId
			LEFT JOIN tblICItemLocation il
				ON il.intItemId = POD.intItemId
				AND il.intLocationId = PO.intShipToId
			LEFT JOIN tblICItemUOM iu
				ON iu.intItemId = POD.intItemId 
				AND iu.intItemUOMId = POD.intUnitOfMeasureId 
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

----UPDATE CONTRACT IF PO ITEM IS PART OF A CONTRACT
--DECLARE @contractItems AS ReceiptItemTableType
--INSERT INTO @contractItems (
--		-- Header
--		[intInventoryReceiptId] 
--		,[strInventoryReceiptId] 
--		,[strReceiptType] 
--		,[intSourceType] 
--		,[dtmDate] 
--		,[intCurrencyId] 
--		,[dblExchangeRate] 
--		-- Detail 
--		,[intInventoryReceiptDetailId] 
--		,[intItemId] 
--		,[intLotId] 
--		,[strLotNumber] 
--		,[intLocationId] 
--		,[intItemLocationId] 
--		,[intSubLocationId] 
--		,[intStorageLocationId] 
--		,[intItemUOMId] 
--		,[intWeightUOMId] 
--		,[dblQty] 
--		,[dblUOMQty] 
--		,[dblNetWeight] 
--		,[dblCost] 
--		,[intContainerId] 
--		,[intOwnershipType] 
--		,[intOrderId] 
--		,[intSourceId] 
--		,[intLineNo] 
--	)
--SELECT
--		ri.[intInventoryReceiptId] 
--		,[strInventoryReceiptId] = r.strReceiptNumber
--		,r.[strReceiptType] 
--		,r.[intSourceType] 
--		,[dtmDate] = r.dtmReceiptDate
--		,r.[intCurrencyId] 
--		,[dblExchangeRate] = ri.dblForexRate --r.[dblExchangeRate] 
--		-- Detail 
--		,[intInventoryReceiptDetailId] = ri.[intInventoryReceiptItemId] 
--		,ri.[intItemId] 
--		,[intLotId] = NULL --A.[intLotId] 
--		,[strLotNumber] = NULL --A.[strLotNumber] 
--		,r.[intLocationId] 
--		,il.[intItemLocationId] 
--		,ri.[intSubLocationId] 
--		,ri.[intStorageLocationId] 
--		,ri.[intUnitMeasureId] 
--		,ri.[intWeightUOMId] 
--		,@dblQty--A.[dblQty] 
--		,[dblUOMQty] = iu.dblUnitQty --A.[dblUOMQty] 
--		,[dblNetWeight] = ri.dblNet --A.[dblNetWeight] 
--		,ri.[dblUnitCost] 
--		,ri.[intContainerId] 
--		,ri.[intOwnershipType] 
--		,ri.[intOrderId] 
--		,ri.[intSourceId] 
--		,ri.[intLineNo] 
--FROM	tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
--			ON r.intInventoryReceiptId = ri.intInventoryReceiptId
--		LEFT JOIN tblICItemLocation il
--			ON il.intItemId = ri.intItemId
--			AND il.intLocationId = r.intLocationId
--		LEFT JOIN tblICItemUOM iu
--			ON iu.intItemId = ri.intItemId
--			AND iu.intItemUOMId = ri.intUnitMeasureId
--WHERE	ri.intInventoryReceiptItemId = @intInventoryReceiptItemId
--		AND ISNULL(@dblQty, 0) <> 0 
--		AND r.strReceiptType = 'Purchase Contract'

--IF EXISTS(SELECT 1 FROM @contractItems)
--BEGIN
--	EXEC uspCTReceived @contractItems, @intUserId
--	IF @@ERROR != 0
--	BEGIN
--		RETURN;
--	END
--END

-- Update the status of the PO
BEGIN 
	EXEC uspPOUpdateStatus @intPurchaseOrderId, DEFAULT
END 