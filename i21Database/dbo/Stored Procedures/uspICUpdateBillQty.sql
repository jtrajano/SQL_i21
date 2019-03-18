CREATE PROCEDURE [dbo].[uspICUpdateBillQty]
	@updateDetails AS InventoryUpdateBillQty READONLY
AS
BEGIN

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  

/* Global Variables */
DECLARE @ItemNo NVARCHAR(50);
DECLARE @TransactionNo NVARCHAR(50);
DECLARE @ReceiptQty NUMERIC(18,6);
DECLARE @BilledQty NUMERIC(18,6);

/*
	BEGIN - Update Receipt Item Bill Qty
*/
IF EXISTS(SELECT TOP 1 1 FROM @updateDetails UpdateTbl
			INNER JOIN tblICInventoryReceiptItem ReceiptItem ON ReceiptItem.intInventoryReceiptItemId = UpdateTbl.intInventoryReceiptItemId AND ReceiptItem.intItemId = UpdateTbl.intItemId
			INNER JOIN tblICItem Item ON Item.intItemId = UpdateTbl.intItemId
			WHERE UpdateTbl.intInventoryReceiptItemId IS NOT NULL AND UpdateTbl.intInventoryReceiptChargeId IS NULL AND UpdateTbl.dblToBillQty != 0)
BEGIN
	-- Validate if the item is over billed
	SET @BilledQty = 0;

	SELECT TOP 1 
		@TransactionNo = Receipt.strReceiptNumber,
		@ItemNo = Item.strItemNo,
		@ReceiptQty = ReceiptItem.dblOpenReceive,
		@BilledQty = ReceiptItem.dblBillQty
	FROM @updateDetails UpdateTbl
	INNER JOIN tblICInventoryReceiptItem ReceiptItem 
		ON ReceiptItem.intInventoryReceiptItemId = UpdateTbl.intInventoryReceiptItemId AND ReceiptItem.intItemId = UpdateTbl.intItemId
	INNER JOIN tblICInventoryReceipt Receipt
		ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
	INNER JOIN tblICItem Item
		ON Item.intItemId = UpdateTbl.intItemId
	WHERE (ReceiptItem.dblBillQty + UpdateTbl.dblToBillQty) > ReceiptItem.dblOpenReceive -- Throw error if Bill Qty is greater than Receipt Qty
		OR (ReceiptItem.dblBillQty + UpdateTbl.dblToBillQty) < 0 -- Throw error also if Bill Qty is negative
		AND UpdateTbl.intInventoryReceiptItemId IS NOT NULL
		AND UpdateTbl.intInventoryReceiptChargeId IS NULL
	

	IF (ISNULL(@TransactionNo,'') != '')
	BEGIN
		--'Billed Qty for {Item No} is already {Billed Qty}. You cannot overbill the transaction'
		EXEC uspICRaiseError 80228, @ItemNo, @BilledQty;
		GOTO Post_Exit;
	END

	UPDATE ReceiptItem
	SET ReceiptItem.dblBillQty = ISNULL(ReceiptItem.dblBillQty, 0) + UpdateTbl.dblToBillQty
	FROM tblICInventoryReceiptItem ReceiptItem
	INNER JOIN @updateDetails UpdateTbl
		ON UpdateTbl.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
	WHERE UpdateTbl.intInventoryReceiptItemId IS NOT NULL
		AND UpdateTbl.intInventoryReceiptChargeId IS NULL
END
/*
	END - Update Receipt Item Bill Qty
*/


/*
	BEGIN - Update Receipt Charges Bill Qty
*/
IF EXISTS(SELECT TOP 1 1 FROM @updateDetails UpdateTbl
			INNER JOIN tblICInventoryReceiptCharge ReceiptCharge ON ReceiptCharge.intInventoryReceiptChargeId = UpdateTbl.intInventoryReceiptChargeId AND ReceiptCharge.intChargeId = UpdateTbl.intItemId
			INNER JOIN tblICItem Item ON Item.intItemId = UpdateTbl.intItemId
			WHERE UpdateTbl.intInventoryReceiptChargeId IS NOT NULL AND UpdateTbl.intInventoryReceiptItemId IS NOT NULL AND UpdateTbl.dblToBillQty != 0)
BEGIN
	-- Validate if the item is over billed for Accrue
	SET @BilledQty = 0;

	SELECT TOP 1 
		@TransactionNo = Receipt.strReceiptNumber,
		@ItemNo = Item.strItemNo,
		@ReceiptQty = ReceiptCharge.dblQuantity,
		@BilledQty = ReceiptCharge.dblQuantityBilled
	FROM @updateDetails UpdateTbl
	INNER JOIN tblICInventoryReceiptCharge ReceiptCharge
		ON ReceiptCharge.intInventoryReceiptChargeId = UpdateTbl.intInventoryReceiptChargeId 
		AND ReceiptCharge.intChargeId = UpdateTbl.intItemId
	INNER JOIN tblICInventoryReceipt Receipt
		ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
	INNER JOIN tblICItem Item
		ON Item.intItemId = UpdateTbl.intItemId
	WHERE (ReceiptCharge.dblQuantityBilled + CASE WHEN ReceiptCharge.ysnPrice = 1 THEN UpdateTbl.dblToBillQty * -1 ELSE UpdateTbl.dblToBillQty END) > ReceiptCharge.dblQuantity -- Throw error if Bill Qty is greater than Receipt Qty
		--OR (ReceiptCharge.dblQuantityBilled + CASE WHEN ReceiptCharge.ysnPrice = 1 THEN UpdateTbl.dblToBillQty * -1 ELSE UpdateTbl.dblToBillQty END) < 0 -- Throw error also if Bill Qty is negative
		AND UpdateTbl.intInventoryReceiptChargeId IS NOT NULL
		AND UpdateTbl.intEntityVendorId = CASE WHEN ReceiptCharge.ysnPrice = 1 
												THEN Receipt.intEntityVendorId
												ELSE ISNULL(ReceiptCharge.intEntityVendorId, Receipt.intEntityVendorId)
											END

	IF (ISNULL(@TransactionNo,'') != '')
	BEGIN
		--'Billed Qty for {Item No} is already {Billed Qty}. You cannot over bill the transaction'
		EXEC uspICRaiseError 80228, @ItemNo, @BilledQty;
		GOTO Post_Exit;
	END

	UPDATE ReceiptCharge
	SET ReceiptCharge.dblQuantityBilled = ISNULL(ReceiptCharge.dblQuantityBilled, 0) + CASE WHEN ReceiptCharge.ysnPrice = 1 THEN UpdateTbl.dblToBillQty * -1 ELSE UpdateTbl.dblToBillQty END
		,ReceiptCharge.dblAmountBilled = ISNULL(ReceiptCharge.dblAmountBilled, 0) + (dbo.fnMultiply(CASE WHEN ReceiptCharge.ysnPrice = 1 THEN UpdateTbl.dblToBillQty * -1 ELSE UpdateTbl.dblToBillQty END, BillDetail.dblCost))
	FROM tblICInventoryReceiptCharge ReceiptCharge
	INNER JOIN tblICInventoryReceipt Receipt
		ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
	INNER JOIN @updateDetails UpdateTbl
		ON UpdateTbl.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
		AND UpdateTbl.intItemId = ReceiptCharge.intChargeId
	INNER JOIN tblAPBillDetail BillDetail
		ON BillDetail.intBillId = UpdateTbl.intSourceTransactionNoId
		AND BillDetail.intItemId = ReceiptCharge.intChargeId
		AND BillDetail.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
	WHERE UpdateTbl.intInventoryReceiptChargeId IS NOT NULL
		AND UpdateTbl.intEntityVendorId = CASE WHEN ReceiptCharge.ysnPrice = 1 
												THEN Receipt.intEntityVendorId
												ELSE ISNULL(ReceiptCharge.intEntityVendorId, Receipt.intEntityVendorId)
											END
	
	-- Validate if the item is over billed for Charge Entity/Price = true
	IF EXISTS(SELECT TOP 1 1 FROM @updateDetails UpdateTbl
			INNER JOIN tblICInventoryReceiptCharge ReceiptCharge ON ReceiptCharge.intInventoryReceiptChargeId = UpdateTbl.intInventoryReceiptChargeId 
				AND ReceiptCharge.intChargeId = UpdateTbl.intItemId
				AND ReceiptCharge.intEntityVendorId = UpdateTbl.intEntityVendorId
			INNER JOIN tblICItem Item ON Item.intItemId = UpdateTbl.intItemId
			WHERE UpdateTbl.intInventoryReceiptChargeId IS NOT NULL 
				AND ReceiptCharge.ysnPrice = 1
	)
	BEGIN
		SET @BilledQty = 0;

		SELECT TOP 1 
			@TransactionNo = Receipt.strReceiptNumber,
			@ItemNo = Item.strItemNo,
			@ReceiptQty = ReceiptCharge.dblQuantity,
			@BilledQty = ReceiptCharge.dblQuantityPriced
		FROM @updateDetails UpdateTbl
		INNER JOIN tblICInventoryReceiptCharge ReceiptCharge
			ON ReceiptCharge.intInventoryReceiptChargeId = UpdateTbl.intInventoryReceiptChargeId 
			AND ReceiptCharge.intChargeId = UpdateTbl.intItemId
			AND ReceiptCharge.intEntityVendorId = UpdateTbl.intEntityVendorId
		INNER JOIN tblICInventoryReceipt Receipt
			ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
		INNER JOIN tblICItem Item
			ON Item.intItemId = ReceiptCharge.intChargeId
		WHERE (ReceiptCharge.dblQuantityPriced + UpdateTbl.dblToBillQty) > ReceiptCharge.dblQuantity -- Throw error if Bill Qty is greater than Receipt Qty
			OR (ReceiptCharge.dblQuantityPriced + UpdateTbl.dblToBillQty) < 0 -- Throw error also if Bill Qty is negative
			AND UpdateTbl.intInventoryReceiptChargeId IS NOT NULL
			AND ReceiptCharge.ysnPrice = 1

		IF (ISNULL(@TransactionNo,'') != '')
		BEGIN
			--'Billed Qty for {Item No} is already {Billed Qty}. You cannot over bill the transaction'
			EXEC uspICRaiseError 80228, @ItemNo, @BilledQty;
			GOTO Post_Exit;
		END

		UPDATE ReceiptCharge
		SET ReceiptCharge.dblQuantityPriced = ISNULL(ReceiptCharge.dblQuantityPriced, 0) + UpdateTbl.dblToBillQty
			,ReceiptCharge.dblAmountPriced = ISNULL(ReceiptCharge.dblAmountPriced, 0) + (BillDetail.dblTotal * (UpdateTbl.dblToBillQty/ABS(UpdateTbl.dblToBillQty)))
		FROM tblICInventoryReceiptCharge ReceiptCharge
		INNER JOIN tblICInventoryReceipt Receipt
			ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
		INNER JOIN @updateDetails UpdateTbl
			ON UpdateTbl.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
			AND UpdateTbl.intEntityVendorId = ReceiptCharge.intEntityVendorId
		INNER JOIN tblAPBillDetail BillDetail
			ON BillDetail.intBillId = UpdateTbl.intSourceTransactionNoId
			AND BillDetail.intItemId = ReceiptCharge.intChargeId
			AND BillDetail.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
		WHERE UpdateTbl.intInventoryReceiptChargeId IS NOT NULL
			AND ReceiptCharge.ysnPrice = 1
	END
END
/*
	END - Update Receipt Charges Bill Qty
*/

/*
	BEGIN - Update Shipment Charges Bill Qty
*/
IF EXISTS(SELECT TOP 1 1 FROM @updateDetails UpdateTbl
			INNER JOIN tblICInventoryShipmentCharge ShipmentCharge 
				ON ShipmentCharge.intInventoryShipmentChargeId = UpdateTbl.intInventoryShipmentChargeId --AND UpdateTbl.intEntityVendorId = ShipmentCharge.intEntityVendorId
			--INNER JOIN tblICItem Item ON Item.intItemId = UpdateTbl.intItemId
			WHERE UpdateTbl.intInventoryShipmentChargeId IS NOT NULL AND UpdateTbl.dblToBillQty != 0)
BEGIN
	-- Validate if the item is over billed
	SELECT TOP 1 
		@TransactionNo = Shipment.strShipmentNumber,
		@ItemNo = Item.strItemNo,
		@ReceiptQty = ShipmentCharge.dblQuantity,
		@BilledQty = ShipmentCharge.dblQuantityBilled
	FROM @updateDetails UpdateTbl
	INNER JOIN tblICInventoryShipmentCharge ShipmentCharge
		ON ShipmentCharge.intInventoryShipmentChargeId = UpdateTbl.intInventoryShipmentChargeId 
		AND ShipmentCharge.intChargeId = UpdateTbl.intItemId
		AND ShipmentCharge.intEntityVendorId = UpdateTbl.intEntityVendorId
	INNER JOIN tblICInventoryShipment Shipment
		ON Shipment.intInventoryShipmentId = ShipmentCharge.intInventoryShipmentId
	INNER JOIN tblICItem Item
		ON Item.intItemId = UpdateTbl.intItemId
	WHERE (ShipmentCharge.dblQuantityBilled + UpdateTbl.dblToBillQty) > ShipmentCharge.dblQuantity -- Throw error if Bill Qty is greater than Receipt Qty
		OR (ShipmentCharge.dblQuantityBilled + UpdateTbl.dblToBillQty) < 0 -- Throw error also if Bill Qty is negative
		AND UpdateTbl.intInventoryShipmentChargeId IS NOT NULL

	IF (ISNULL(@TransactionNo,'') != '')
	BEGIN
		--'Billed Qty for {Item No} is already {Billed Qty}. You cannot over bill the transaction'
		EXEC uspICRaiseError 80228, @ItemNo, @BilledQty;
		GOTO Post_Exit;
	END

	UPDATE ShipmentCharge
	SET ShipmentCharge.dblQuantityBilled = ISNULL(ShipmentCharge.dblQuantityBilled, 0) + UpdateTbl.dblToBillQty
		,ShipmentCharge.dblAmountBilled = ISNULL(ShipmentCharge.dblAmountBilled, 0) + (BillDetail.dblTotal * (UpdateTbl.dblToBillQty/ABS(UpdateTbl.dblToBillQty)))
	FROM tblICInventoryShipmentCharge ShipmentCharge
	INNER JOIN @updateDetails UpdateTbl
		ON UpdateTbl.intInventoryShipmentChargeId = ShipmentCharge.intInventoryShipmentChargeId
		AND ShipmentCharge.intEntityVendorId = UpdateTbl.intEntityVendorId
	INNER JOIN tblAPBillDetail BillDetail
			ON BillDetail.intBillId = UpdateTbl.intSourceTransactionNoId
			AND BillDetail.intItemId = ShipmentCharge.intChargeId
			AND BillDetail.intInventoryShipmentChargeId = ShipmentCharge.intInventoryShipmentChargeId
	WHERE UpdateTbl.intInventoryShipmentChargeId IS NOT NULL
END
/*
	END - Update Shipment Charges Bill Qty
*/

Post_Exit:
END