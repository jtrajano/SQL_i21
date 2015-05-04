﻿CREATE PROCEDURE [dbo].[uspPOReceived]
	@receiptItemId INT
	,@ysnPost BIT 
AS
BEGIN

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @purchaseId INT, @lineNo INT, @itemId INT;
	DECLARE @purchaseOrderNumber NVARCHAR(50), @strItemNo NVARCHAR(50);
	DECLARE @posted BIT;
	DECLARE @count INT = 0;
	DECLARE @receivedNum DECIMAL(18,6);

	SELECT	B.intSourceId
			,B.intLineNo
			,B.dblOpenReceive
			,B.intItemId
			,A.ysnPosted
			,B.intUnitMeasureId
			,CalculatedOpenReceive = B.dblOpenReceive
	INTO	#tmpReceivedPOItems
	FROM	tblICInventoryReceipt A LEFT JOIN tblICInventoryReceiptItem B 
				ON A.intInventoryReceiptId = B.intInventoryReceiptId
	WHERE	A.intInventoryReceiptId = @receiptItemId

	SELECT TOP 1 @posted = ysnPosted FROM #tmpReceivedPOItems

	--Validate if purchase order exists..
	SELECT	TOP 1 
			@purchaseOrderNumber = strPurchaseOrderNumber
	FROM	#tmpReceivedPOItems A OUTER APPLY  (
				SELECT strPurchaseOrderNumber FROM tblPOPurchase B WHERE A.intSourceId = B.intPurchaseId
			) PurchaseOrders
	WHERE	PurchaseOrders.strPurchaseOrderNumber IS NULL

	IF(@purchaseOrderNumber <> NULL)
	BEGIN
		RAISERROR(51033, 11, 1); --Not Exists
		RETURN;
	END

	--Validate if item exists on PO
	SELECT  TOP 1 
			@strItemNo = (SELECT strItemNo FROM tblICItem WHERE intItemId = A.intItemId)
	FROM	#tmpReceivedPOItems A OUTER APPLY (
				SELECT	intItemId 
				FROM	tblPOPurchaseDetail B 
				WHERE	A.intSourceId = B.intPurchaseId
						AND A.intItemId = B.intItemId 
						AND A.intLineNo = B.intPurchaseDetailId
			) PurchaseOrderDetails
	WHERE	PurchaseOrderDetails.intItemId IS NULL

	IF(@strItemNo <> NULL)
	BEGIN
		--PO item not exists
		RAISERROR(51034, 11, 1); 
		RETURN;
	END

	-- Calculate the open receive to the UOM of the PO
	UPDATE	POItems
	SET		CalculatedOpenReceive = dbo.fnCalculateQtyBetweenUOM(POItems.intUnitMeasureId, PODetail.intUnitOfMeasureId, POItems.dblOpenReceive)
	FROM	#tmpReceivedPOItems POItems INNER JOIN dbo.tblPOPurchaseDetail PODetail
				ON POItems.intSourceId = PODetail.intPurchaseId
				AND POItems.intLineNo = PODetail.intPurchaseDetailId


	-- Update the On Order Qty
	BEGIN 
		DECLARE @ItemToUpdateOnOrderQty ItemCostingTableType

		-- Get the list. 
		INSERT INTO @ItemToUpdateOnOrderQty (
				dtmDate
				,intItemId
				,intItemLocationId
				,intItemUOMId
				,intSubLocationId
				,dblQty
				,dblUOMQty
				,intTransactionId
				,strTransactionId
				,intTransactionTypeId
		)
		SELECT	dtmDate					= Receipt.dtmReceiptDate
				,intItemId				= ReceiptItem.intItemId
				,intItemLocationId		= ItemLocation.intItemLocationId
				,intItemUOMId			= ReceiptItem.intUnitMeasureId
				,intSubLocationId		= ReceiptItem.intSubLocationId
				,dblQty					= ReceiptItem.dblOpenReceive * CASE WHEN @ysnPost = 1 THEN -1 ELSE 1 END -- dbo.fnCalculateQtyBetweenUOM(ReceiptItem.intUnitMeasureId, PODetail.intUnitOfMeasureId, ReceiptItem.dblOpenReceive) 
				,dblUOMQty				= ItemUOM.dblUnitQty   --1 -- Keep value as one (1). The dblQty is converted manually by using the fnCalculateQtyBetweenUOM function.
				,intTransactionId		= Receipt.intInventoryReceiptId
				,strTransactionId		= Receipt.strReceiptNumber
				,intTransactionTypeId	= -1 -- any value
		FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
					ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
				INNER JOIN dbo.tblPOPurchaseDetail PODetail
					ON ReceiptItem.intSourceId = PODetail.intPurchaseId
					AND ReceiptItem.intLineNo = PODetail.intPurchaseDetailId
				INNER JOIN dbo.tblICItemLocation ItemLocation
					ON ItemLocation.intItemId = ReceiptItem.intItemId
					AND ItemLocation.intLocationId = Receipt.intLocationId				
				INNER JOIN dbo.tblICItemUOM	ItemUOM
					ON ItemUOM.intItemUOMId = ReceiptItem.intUnitMeasureId
		WHERE	Receipt.intInventoryReceiptId = @receiptItemId
				AND ReceiptItem.intSourceId IS NOT NULL 

		-- Call the stored procedure that updates the on order qty. 
		EXEC dbo.uspICIncreaseOnOrderQty @ItemToUpdateOnOrderQty
	END 
	
	UPDATE	A
	SET		dblQtyReceived = CASE	WHEN	 @posted = 1 THEN (dblQtyReceived + B.CalculatedOpenReceive) 
									ELSE (	dblQtyReceived - B.CalculatedOpenReceive) 
							END
	FROM	tblPOPurchaseDetail A INNER JOIN #tmpReceivedPOItems B 
				ON A.intItemId = B.intItemId 
				AND A.intPurchaseDetailId = B.intLineNo
				AND intPurchaseId = B.intSourceId
				--AND intPurchaseDetailId IN (SELECT intLineNo FROM #tmpReceivedPOItems)

	SELECT DISTINCT intSourceId INTO #poIds FROM #tmpReceivedPOItems
	DECLARE @countPoIds INT = (SELECT COUNT(*) FROM #poIds)
	DECLARE @counter INT = 0;

	WHILE @counter != @countPoIds
	BEGIN
		SET @counter = @counter + 1;
		SET @purchaseId = (SELECT TOP(1) intSourceId FROM #poIds)
		EXEC uspPOUpdateStatus @purchaseId, DEFAULT
		DELETE FROM #poIds WHERE intSourceId = @purchaseId
	END

END