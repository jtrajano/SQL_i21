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
			WHERE UpdateTbl.intInventoryReceiptItemId IS NOT NULL)
BEGIN
	-- Validate if the item is over billed
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
			WHERE UpdateTbl.intInventoryReceiptChargeId IS NOT NULL)
BEGIN
	-- Validate if the item is over billed
	SELECT TOP 1 
		@TransactionNo = Receipt.strReceiptNumber,
		@ItemNo = Item.strItemNo,
		@ReceiptQty = ReceiptCharge.dblQuantity,
		@BilledQty = ReceiptCharge.dblQuantityBilled
	FROM @updateDetails UpdateTbl
	INNER JOIN tblICInventoryReceiptCharge ReceiptCharge
		ON ReceiptCharge.intInventoryReceiptChargeId = UpdateTbl.intInventoryReceiptChargeId AND ReceiptCharge.intChargeId = UpdateTbl.intItemId
	INNER JOIN tblICInventoryReceipt Receipt
		ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
	INNER JOIN tblICItem Item
		ON Item.intItemId = UpdateTbl.intItemId
	WHERE (ReceiptCharge.dblQuantityBilled + UpdateTbl.dblToBillQty) > ReceiptCharge.dblQuantity -- Throw error if Bill Qty is greater than Receipt Qty
		OR (ReceiptCharge.dblQuantityBilled + UpdateTbl.dblToBillQty) < 0 -- Throw error also if Bill Qty is negative
		AND UpdateTbl.intInventoryReceiptChargeId IS NOT NULL
	

	IF (ISNULL(@TransactionNo,'') != '')
	BEGIN
		--'Billed Qty for {Item No} is already {Billed Qty}. You cannot over bill the transaction'
		EXEC uspICRaiseError 80228, @ItemNo, @BilledQty;
		GOTO Post_Exit;
	END

	UPDATE ReceiptCharge
	SET ReceiptCharge.dblQuantityBilled = ISNULL(ReceiptCharge.dblQuantityBilled, 0) + UpdateTbl.dblToBillQty
	FROM tblICInventoryReceiptCharge ReceiptCharge
	INNER JOIN @updateDetails UpdateTbl
		ON UpdateTbl.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
	WHERE UpdateTbl.intInventoryReceiptChargeId IS NOT NULL
END
/*
	END - Update Receipt Charges Bill Qty
*/

/*
	BEGIN - Update Shipment Charges Bill Qty
*/
IF EXISTS(SELECT TOP 1 1 FROM @updateDetails UpdateTbl
			INNER JOIN tblICInventoryShipmentCharge ShipmentCharge ON ShipmentCharge.intInventoryShipmentChargeId = UpdateTbl.intInventoryShipmentChargeId
			INNER JOIN tblICItem Item ON Item.intItemId = UpdateTbl.intItemId
			WHERE UpdateTbl.intInventoryShipmentChargeId IS NOT NULL)
BEGIN
	-- Validate if the item is over billed
	SELECT TOP 1 
		@TransactionNo = Shipment.strShipmentNumber,
		@ItemNo = Item.strItemNo,
		@ReceiptQty = ShipmentCharge.dblQuantity,
		@BilledQty = ShipmentCharge.dblQuantityBilled
	FROM @updateDetails UpdateTbl
	INNER JOIN tblICInventoryShipmentCharge ShipmentCharge
		ON ShipmentCharge.intInventoryShipmentChargeId = UpdateTbl.intInventoryShipmentChargeId AND ShipmentCharge.intChargeId = UpdateTbl.intItemId
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
	FROM tblICInventoryShipmentCharge ShipmentCharge
	INNER JOIN @updateDetails UpdateTbl
		ON UpdateTbl.intInventoryShipmentChargeId = ShipmentCharge.intInventoryShipmentChargeId
	WHERE UpdateTbl.intInventoryShipmentChargeId IS NOT NULL
END
/*
	END - Update Shipment Charges Bill Qty
*/

Post_Exit:
END