CREATE PROCEDURE [dbo].[uspPOReceived]
	@receiptItemId INT
	,@tranType INT
AS
BEGIN

	DECLARE @purchaseId INT, @lineNo INT, @itemId INT;
	DECLARE @strItemNo NVARCHAR(50);
	DECLARE @posted BIT;
	DECLARE @receivedNum DECIMAL(18,6);
	DECLARE @itemFull NVARCHAR(200);
	DECLARE @errMsg NVARCHAR(200);

	IF OBJECT_ID('tempdb..#receivedItems') IS NOT NULL
		DROP TABLE #receivedItems

	CREATE TABLE #receivedItems(intSourceId INT, intLineNo INT, dblOpenReceive DECIMAL(18,6), intItemId INT, ysnPosted BIT)

	IF (@tranType = 1) --Inventory Receipt
	BEGIN
		INSERT INTO	#receivedItems
		SELECT	B.intSourceId
				,B.intLineNo
				,B.dblOpenReceive
				,B.intItemId
				,A.ysnPosted
		FROM	tblICInventoryReceipt A LEFT JOIN tblICInventoryReceiptItem B 
					ON A.intInventoryReceiptId = B.intInventoryReceiptId
		WHERE	A.intInventoryReceiptId = @receiptItemId
	END
	ELSE IF(@tranType = 2) --Bill
	BEGIN
		INSERT INTO	#receivedItems
		SELECT	B.intPurchaseId
				,B.intPurchaseDetailId
				,A.dblQtyReceived
				,B.intItemId
				,A1.ysnPosted
		FROM	tblAPBill A1 
				INNER JOIN tblAPBillDetail A
					ON A1.intBillId = A.intBillId
				INNER JOIN tblPOPurchaseDetail B 
					ON A.intItemReceiptId = B.intPurchaseDetailId
				INNER JOIN tblICItem C
					ON B.intItemId = C.intItemId
		WHERE	A.intBillId = @receiptItemId
		AND strType IN ('Service','Software','Non-Inventory','Other Charge')
	END
	ELSE
	BEGIN
		RAISERROR('Invalid transaction type.', 16, 1);
	END

	SELECT TOP (1) @posted = ysnPosted FROM #receivedItems

	--VALIDATIONS

	IF(@tranType = 1)
	BEGIN
		SELECT @itemFull = C.strItemNo FROM tblPOPurchaseDetail A 
						INNER JOIN #receivedItems B ON A.intPurchaseDetailId = B.intLineNo 
															AND A.intItemId = B.intItemId 
															AND intPurchaseId = intSourceId 
						INNER JOIN tblICItem C ON B.intItemId = C.intItemId
						INNER JOIN tblICInventoryReceiptItem D ON B.intLineNo = D.intLineNo
						WHERE C.strType NOT IN ('Service','Software','Non-Inventory','Other Charge')
						AND D.dblBillQty = D.dblReceived AND dblReceived != 0

		IF @itemFull IS NOT NULL AND @posted = 1
		BEGIN
			--fully billed item
			SET @errMsg = '''' + @itemFull + ''' item was fully billed.'
			RAISERROR(@errMsg, 16, 1); 
			RETURN;
		END
	END

	IF(@tranType = 2)
	BEGIN
		SELECT @itemFull = C.strItemNo FROM tblPOPurchaseDetail A 
						INNER JOIN #receivedItems B ON A.intPurchaseDetailId = B.intLineNo 
															AND A.intItemId = B.intItemId 
															AND intPurchaseId = intSourceId 
															AND dblQtyReceived = dblQtyOrdered
						INNER JOIN tblICItem C ON B.intItemId = C.intItemId
						WHERE C.strType IN ('Service','Software','Non-Inventory','Other Charge')

		IF @itemFull IS NOT NULL AND @posted = 1
		BEGIN
			--fully billed item
			SET @errMsg = '''' + @itemFull + ''' item was fully billed.'
			RAISERROR(@errMsg, 16, 1); 
			RETURN;
		END
	END

	--Validate if purchase order exists..
	DECLARE @purchaseOrderNumber NVARCHAR(50);
	SELECT	TOP 1 
			@purchaseOrderNumber = strPurchaseOrderNumber
	FROM	#receivedItems A OUTER APPLY  (
				SELECT strPurchaseOrderNumber FROM tblPOPurchase B WHERE A.intSourceId = B.intPurchaseId
			) PurchaseOrders
	WHERE	PurchaseOrders.strPurchaseOrderNumber IS NULL

	IF(@purchaseOrderNumber <> NULL)
	BEGIN
		RAISERROR(51033, 16, 1); --Not Exists
		RETURN;
	END

	--Validate if item exists on PO
	SELECT  TOP 1 
			@strItemNo = (SELECT strItemNo FROM tblICItem WHERE intItemId = A.intItemId)
	FROM	#receivedItems A OUTER APPLY (
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
		RAISERROR(51034, 16, 1); 
		RETURN;
	END

	IF EXISTS(SELECT 1 FROM tblPOPurchaseDetail A 
					INNER JOIN #receivedItems B ON A.intPurchaseDetailId = B.intLineNo 
														AND A.intItemId = B.intItemId 
														AND intPurchaseId = intSourceId 
														AND (dblQtyReceived + B.dblOpenReceive) > dblQtyOrdered)
					AND @posted = 1
	BEGIN
		--Received item exceeds
		RAISERROR(51035, 16, 1); 
		RETURN;
	END


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
				,dblQty					= ReceiptItem.dblOpenReceive * CASE WHEN @posted = 1 THEN -1 ELSE 1 END 
				,dblUOMQty				= ItemUOM.dblUnitQty 
				,intTransactionId		= Receipt.intInventoryReceiptId
				,strTransactionId		= Receipt.strReceiptNumber
				,intTransactionTypeId	= -1 -- any value

		FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
					ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
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
	SET		dblQtyReceived = CASE	WHEN	 @posted = 1 THEN (dblQtyReceived + B.dblOpenReceive) 
									ELSE (	dblQtyReceived - B.dblOpenReceive) 
							END
	FROM	tblPOPurchaseDetail A INNER JOIN #receivedItems B 
				ON A.intItemId = B.intItemId 
				AND A.intPurchaseDetailId = B.intLineNo
				AND intPurchaseId = B.intSourceId
				--AND intPurchaseDetailId IN (SELECT intLineNo FROM #tmpReceivedPOItems)

	EXEC uspPOUpdateStatus @receiptItemId, DEFAULT

END
