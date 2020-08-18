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
IF EXISTS(
	SELECT TOP 1 1 
	FROM 
		@updateDetails UpdateTbl INNER JOIN tblICInventoryReceiptItem ReceiptItem 
			ON ReceiptItem.intInventoryReceiptItemId = UpdateTbl.intInventoryReceiptItemId 
			AND ReceiptItem.intItemId = UpdateTbl.intItemId
		INNER JOIN tblICItem Item 
			ON Item.intItemId = UpdateTbl.intItemId
	WHERE 
		UpdateTbl.intInventoryReceiptItemId IS NOT NULL 
		AND UpdateTbl.intInventoryReceiptChargeId IS NULL 
		AND UpdateTbl.dblToBillQty <> 0
)
BEGIN
	-- Validate if the item is over billed
	SET @BilledQty = 0;

	DECLARE 
		  @SourceType_STORE AS INT = 7		 
		, @type_Voucher AS INT = 1
		, @type_DebitMemo AS INT = 3
		, @type_BillToUse INT

	SELECT TOP 1 
		@type_BillToUse = 
			CASE 
				WHEN dbo.fnICGetReceiptTotals(r.intInventoryReceiptId, 6) < 0 AND r.intSourceType = @SourceType_STORE THEN 
					@type_DebitMemo
				ELSE 
					@type_Voucher
			END 
	FROM 
		tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri 
			ON ri.intInventoryReceiptId = r.intInventoryReceiptId
		INNER JOIN @updateDetails d 
			ON d.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
			AND ri.intItemId = d.intItemId
	WHERE 
		r.ysnPosted = 1

	DECLARE @ReceiptToBills TABLE(
		strReceiptNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
		,dblOpenReceive NUMERIC(38, 20)
		,dblBillQty NUMERIC(38, 20)
		,intItemId INT
		,intInventoryReceiptItemId INT
	)
	
	INSERT INTO @ReceiptToBills
	SELECT
		r.strReceiptNumber
		,dblOpenReceive = CASE WHEN @type_BillToUse = @type_DebitMemo THEN -ri.dblOpenReceive ELSE ri.dblOpenReceive END
		,dblBillQty = CASE WHEN @type_BillToUse = @type_DebitMemo THEN -ri.dblBillQty ELSE ri.dblBillQty END
		,ri.intItemId
		,ri.intInventoryReceiptItemId
	FROM 
		tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri 
			ON ri.intInventoryReceiptId = r.intInventoryReceiptId
		INNER JOIN @updateDetails d 
			ON d.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
			AND ri.intItemId = d.intItemId

	SELECT TOP 1 
		@TransactionNo = ReceiptItem.strReceiptNumber
		,@ItemNo = Item.strItemNo
		,@ReceiptQty = ReceiptItem.dblOpenReceive
		,@BilledQty = ReceiptItem.dblBillQty
	FROM 
		@updateDetails UpdateTbl INNER JOIN @ReceiptToBills ReceiptItem 
			ON ReceiptItem.intInventoryReceiptItemId = UpdateTbl.intInventoryReceiptItemId 
			AND ReceiptItem.intItemId = UpdateTbl.intItemId
		INNER JOIN tblICInventoryReceiptItem SourceReceiptItem 
			ON SourceReceiptItem.intInventoryReceiptItemId = UpdateTbl.intInventoryReceiptItemId 
			AND SourceReceiptItem.intItemId = UpdateTbl.intItemId
		INNER JOIN tblICItem Item
			ON Item.intItemId = UpdateTbl.intItemId
	WHERE 
		ABS(
			ISNULL(ReceiptItem.dblBillQty, 0) 
			+ dbo.fnCalculateQtyBetweenUOM(UpdateTbl.intToBillUOMId, SourceReceiptItem.intUnitMeasureId, UpdateTbl.dblToBillQty) 
		) > ABS(ReceiptItem.dblOpenReceive)
		AND UpdateTbl.intInventoryReceiptItemId IS NOT NULL
		AND UpdateTbl.intInventoryReceiptChargeId IS NULL

	IF (ISNULL(@TransactionNo,'') <> '')
	BEGIN
		--'Billed Qty for {Item No} is already {Billed Qty}. You cannot overbill the transaction'
		EXEC uspICRaiseError 80228, @ItemNo, @BilledQty;
		GOTO Post_Exit;
	END

	UPDATE SourceReceiptItem
	SET 
		SourceReceiptItem.dblBillQty = 
			ISNULL(SourceReceiptItem.dblBillQty, 0) 
			+ dbo.fnCalculateQtyBetweenUOM (
				UpdateTbl.intToBillUOMId
				, SourceReceiptItem.intUnitMeasureId
				, CASE WHEN @type_BillToUse = @type_DebitMemo THEN -UpdateTbl.dblToBillQty ELSE UpdateTbl.dblToBillQty END
			)
	FROM 
		tblICInventoryReceiptItem SourceReceiptItem INNER JOIN @updateDetails UpdateTbl
			ON UpdateTbl.intInventoryReceiptItemId = SourceReceiptItem.intInventoryReceiptItemId
	WHERE 
		UpdateTbl.intInventoryReceiptItemId IS NOT NULL
		AND UpdateTbl.intInventoryReceiptChargeId IS NULL
END
/*
	END - Update Receipt Item Bill Qty
*/


/*
	BEGIN - Update Receipt Charges Bill Qty
*/
IF EXISTS(
	SELECT TOP 1 1 
	FROM 
		@updateDetails UpdateTbl INNER JOIN tblICInventoryReceiptCharge ReceiptCharge 
			ON ReceiptCharge.intInventoryReceiptChargeId = UpdateTbl.intInventoryReceiptChargeId 
			AND ReceiptCharge.intChargeId = UpdateTbl.intItemId
		INNER JOIN tblICItem Item 
			ON Item.intItemId = UpdateTbl.intItemId
	WHERE 
		UpdateTbl.intInventoryReceiptChargeId IS NOT NULL 
		AND UpdateTbl.intInventoryReceiptItemId IS NOT NULL 
		AND UpdateTbl.dblToBillQty <> 0
		AND ReceiptCharge.intEntityVendorId = UpdateTbl.intEntityVendorId
)
BEGIN
	-- Validate if the item is over billed for Accrue
	SET @BilledQty = 0;

	SELECT TOP 1 
		@TransactionNo = Receipt.strReceiptNumber
		,@ItemNo = Item.strItemNo
		,@ReceiptQty = ReceiptCharge.dblQuantity
		,@BilledQty = --ReceiptCharge.dblQuantityBilled
			CASE 
				WHEN ReceiptCharge.strCostMethod IN ('Amount', 'Percentage') THEN ISNULL(ReceiptCharge.dblAmountBilled, 0) 
				ELSE ISNULL(ReceiptCharge.dblQuantityBilled, 0) 
			END 

	FROM 
		tblICInventoryReceiptCharge ReceiptCharge 
		INNER JOIN tblICItem Item
			ON Item.intItemId = ReceiptCharge.intChargeId
		INNER JOIN tblICInventoryReceipt Receipt
			ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
		INNER JOIN @updateDetails UpdateTbl
			ON UpdateTbl.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
			AND UpdateTbl.intItemId = ReceiptCharge.intChargeId
		
	WHERE 
		UpdateTbl.intInventoryReceiptChargeId IS NOT NULL
		AND ReceiptCharge.intEntityVendorId = UpdateTbl.intEntityVendorId
		AND 1 = 
			CASE 
				WHEN ReceiptCharge.strCostMethod IN ('Amount', 'Percentage') THEN 
					--AND ISNULL(ReceiptCharge.dblAmountBilled, 0) + ISNULL(UpdateTbl.dblAmountToBill, 0) > ISNULL(ReceiptCharge.dblAmount, 0) THEN 1 
					CASE						
						WHEN ABS(ISNULL(ReceiptCharge.dblAmountBilled, 0) + ISNULL(UpdateTbl.dblAmountToBill, 0) - ISNULL(ReceiptCharge.dblAmount, 0)) BETWEEN 0.01 AND 0.03 THEN 0 -- tolerate 0.01 to 0.03 discrepancy due to pro-rated charges. 
						WHEN ISNULL(ReceiptCharge.dblAmountBilled, 0) + ISNULL(UpdateTbl.dblAmountToBill, 0) > ISNULL(ReceiptCharge.dblAmount, 0) THEN 1
						ELSE 0
					END 
				WHEN ReceiptCharge.strCostMethod IN ('Per Unit') AND ISNULL(ReceiptCharge.dblQuantityBilled, 0) + ISNULL(UpdateTbl.dblToBillQty, 0) > ISNULL(ReceiptCharge.dblQuantity, 0) THEN 1 
				ELSE 
					0
			END 

	IF (ISNULL(@TransactionNo,'') <> '')
	BEGIN
		--'Billed Qty for {Item No} is already {Billed Qty}. You cannot over bill the transaction'
		EXEC uspICRaiseError 80228, @ItemNo, @BilledQty;
		GOTO Post_Exit;
	END

	UPDATE ReceiptCharge
	SET 
		ReceiptCharge.dblQuantityBilled = 
			ISNULL(ReceiptCharge.dblQuantityBilled, 0) 
			+ CASE 
				WHEN ReceiptCharge.strCostMethod = 'Per Unit' THEN 					
					ISNULL(UpdateTbl.dblToBillQty, 0) 
				ELSE 
					0
			END 

		,ReceiptCharge.dblAmountBilled = 
			ISNULL(ReceiptCharge.dblAmountBilled, 0) 
			+ CASE 
				WHEN ReceiptCharge.strCostMethod IN ('Amount', 'Percentage') THEN 
					ISNULL(UpdateTbl.dblAmountToBill, 0)
				ELSE 
					0
			END

	FROM 
		tblICInventoryReceiptCharge ReceiptCharge INNER JOIN tblICInventoryReceipt Receipt
			ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
		INNER JOIN @updateDetails UpdateTbl
			ON UpdateTbl.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
			AND UpdateTbl.intItemId = ReceiptCharge.intChargeId
		INNER JOIN tblAPBillDetail BillDetail
			ON BillDetail.intBillId = UpdateTbl.intSourceTransactionNoId
			AND BillDetail.intItemId = ReceiptCharge.intChargeId
			AND BillDetail.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
	WHERE 
		UpdateTbl.intInventoryReceiptChargeId IS NOT NULL
		AND UpdateTbl.intEntityVendorId = ReceiptCharge.intEntityVendorId
END 

-- Validate if the item is over billed for Charge Entity/Price = true
IF EXISTS(
	SELECT TOP 1 1 
	FROM 
		tblICInventoryReceipt Receipt 			
		INNER JOIN tblICInventoryReceiptCharge ReceiptCharge 
			ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
		INNER JOIN @updateDetails UpdateTbl 		
			ON ReceiptCharge.intInventoryReceiptChargeId = UpdateTbl.intInventoryReceiptChargeId 
			AND ReceiptCharge.intChargeId = UpdateTbl.intItemId			
		INNER JOIN tblICItem Item 
			ON Item.intItemId = UpdateTbl.intItemId
	WHERE 
		UpdateTbl.intInventoryReceiptChargeId IS NOT NULL 
		AND ReceiptCharge.ysnPrice = 1
		AND Receipt.intEntityVendorId = UpdateTbl.intEntityVendorId		
)
BEGIN
	SET @BilledQty = 0;

	SELECT TOP 1 
		@TransactionNo = Receipt.strReceiptNumber
		,@ItemNo = Item.strItemNo
		,@ReceiptQty = ReceiptCharge.dblQuantity
		,@BilledQty = --ReceiptCharge.dblQuantityPriced
			CASE 
				WHEN ReceiptCharge.strCostMethod IN ('Amount', 'Percentage') THEN ISNULL(ReceiptCharge.dblAmountPriced, 0) 
				ELSE ISNULL(ReceiptCharge.dblQuantityPriced, 0) 
			END 
	FROM 
		tblICInventoryReceipt Receipt 			
		INNER JOIN tblICInventoryReceiptCharge ReceiptCharge 
			ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
		INNER JOIN @updateDetails UpdateTbl 		
			ON ReceiptCharge.intInventoryReceiptChargeId = UpdateTbl.intInventoryReceiptChargeId 
			AND ReceiptCharge.intChargeId = UpdateTbl.intItemId			
		INNER JOIN tblICItem Item 
			ON Item.intItemId = UpdateTbl.intItemId
	WHERE 
		UpdateTbl.intInventoryReceiptChargeId IS NOT NULL
		AND ReceiptCharge.ysnPrice = 1
		AND Receipt.intEntityVendorId = UpdateTbl.intEntityVendorId
		AND 1 = 
			CASE 
				WHEN ReceiptCharge.strCostMethod IN ('Amount', 'Percentage') THEN --AND ISNULL(ReceiptCharge.dblAmountPriced, 0) + ISNULL(UpdateTbl.dblAmountToBill, 0) > ISNULL(ReceiptCharge.dblAmount, 0) THEN 1 
					CASE						
						WHEN ABS(ISNULL(ReceiptCharge.dblAmountPriced, 0) + ISNULL(UpdateTbl.dblAmountToBill, 0) - ISNULL(ReceiptCharge.dblAmount, 0)) BETWEEN 0.01 AND 0.03 THEN 0 -- tolerate 0.01 to 0.03 discrepancy due to pro-rated charges.
						WHEN ISNULL(ReceiptCharge.dblAmountPriced, 0) + ISNULL(UpdateTbl.dblAmountToBill, 0) > ISNULL(ReceiptCharge.dblAmount, 0) THEN 1
						ELSE 0
					END 
				WHEN ReceiptCharge.strCostMethod IN ('Per Unit') AND ISNULL(ReceiptCharge.dblQuantityPriced, 0) + ISNULL(UpdateTbl.dblToBillQty, 0) > ISNULL(ReceiptCharge.dblQuantity, 0) THEN 1 
				ELSE 
					0
			END 

	IF (ISNULL(@TransactionNo,'') <> '')
	BEGIN
		--'Billed Qty for {Item No} is already {Billed Qty}. You cannot over bill the transaction'
		EXEC uspICRaiseError 80228, @ItemNo, @BilledQty;
		GOTO Post_Exit;
	END

	UPDATE ReceiptCharge
	SET 
		ReceiptCharge.dblQuantityPriced = 
			ISNULL(ReceiptCharge.dblQuantityPriced, 0) 
			+ CASE 
				WHEN ReceiptCharge.strCostMethod = 'Per Unit' THEN 					
					ISNULL(UpdateTbl.dblToBillQty, 0) 
				ELSE 
					0
			END 

		,ReceiptCharge.dblAmountPriced = 
			ISNULL(ReceiptCharge.dblAmountPriced, 0) 
			+ CASE 
				WHEN ReceiptCharge.strCostMethod IN ('Amount', 'Percentage') THEN 
					ISNULL(UpdateTbl.dblAmountToBill, 0)
				ELSE 
					0
			END
	FROM 
		tblICInventoryReceiptCharge ReceiptCharge INNER JOIN tblICInventoryReceipt Receipt
			ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
		INNER JOIN @updateDetails UpdateTbl
			ON UpdateTbl.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
			AND ReceiptCharge.intChargeId = UpdateTbl.intItemId
			
	WHERE 
		UpdateTbl.intInventoryReceiptChargeId IS NOT NULL
		AND ReceiptCharge.ysnPrice = 1
		AND UpdateTbl.intEntityVendorId = Receipt.intEntityVendorId		
END
/*
	END - Update Receipt Charges Bill Qty
*/

/*
	BEGIN - Update Shipment Charges Bill Qty
*/
IF EXISTS(
	SELECT TOP 1 1 
	FROM 
		@updateDetails UpdateTbl INNER JOIN tblICInventoryShipmentCharge ShipmentCharge 
			ON ShipmentCharge.intInventoryShipmentChargeId = UpdateTbl.intInventoryShipmentChargeId 
	WHERE 
		UpdateTbl.intInventoryShipmentChargeId IS NOT NULL 
		AND UpdateTbl.dblToBillQty <> 0
)
BEGIN
	-- Validate if the item is over billed
	SELECT TOP 1 
		@TransactionNo = Shipment.strShipmentNumber
		,@ItemNo = Item.strItemNo
		,@ReceiptQty = ShipmentCharge.dblQuantity
		,@BilledQty = --ShipmentCharge.dblQuantityBilled
			CASE 
				WHEN ShipmentCharge.strCostMethod IN ('Amount', 'Percentage') THEN ISNULL(ShipmentCharge.dblAmountBilled, 0) 
				ELSE ISNULL(ShipmentCharge.dblQuantityBilled, 0) 
			END 
	FROM 
		@updateDetails UpdateTbl INNER JOIN tblICInventoryShipmentCharge ShipmentCharge
			ON ShipmentCharge.intInventoryShipmentChargeId = UpdateTbl.intInventoryShipmentChargeId 
			AND ShipmentCharge.intChargeId = UpdateTbl.intItemId
		INNER JOIN tblICInventoryShipment Shipment
			ON Shipment.intInventoryShipmentId = ShipmentCharge.intInventoryShipmentId
		INNER JOIN tblICItem Item
			ON Item.intItemId = UpdateTbl.intItemId
	WHERE 

		UpdateTbl.intInventoryShipmentChargeId IS NOT NULL
		AND ShipmentCharge.intEntityVendorId = UpdateTbl.intEntityVendorId
		AND 1 = 
			CASE 
				WHEN ShipmentCharge.strCostMethod IN ('Amount', 'Percentage') AND ISNULL(ShipmentCharge.dblAmountBilled, 0) + ISNULL(UpdateTbl.dblAmountToBill, 0) > ISNULL(ShipmentCharge.dblAmount, 0) THEN 1 
				WHEN ShipmentCharge.strCostMethod IN ('Per Unit') AND ISNULL(ShipmentCharge.dblQuantityBilled, 0) + ISNULL(UpdateTbl.dblToBillQty, 0) > ISNULL(ShipmentCharge.dblQuantity, 0) THEN 1 
				ELSE 
					0
			END 

	IF (ISNULL(@TransactionNo,'') <> '')
	BEGIN
		--'Billed Qty for {Item No} is already {Billed Qty}. You cannot over bill the transaction'
		EXEC uspICRaiseError 80228, @ItemNo, @BilledQty;
		GOTO Post_Exit;
	END

	UPDATE ShipmentCharge
	SET 
		ShipmentCharge.dblQuantityBilled = 
			ISNULL(ShipmentCharge.dblQuantityBilled, 0) 
			+ CASE 
				WHEN ShipmentCharge.strCostMethod = 'Per Unit' THEN 					
					ISNULL(UpdateTbl.dblToBillQty, 0) 
				ELSE 
					0
			END 

		,ShipmentCharge.dblAmountBilled = 
			ISNULL(ShipmentCharge.dblAmountBilled, 0) 
			+ CASE 
				WHEN ShipmentCharge.strCostMethod IN ('Amount', 'Percentage') THEN 
					ISNULL(UpdateTbl.dblAmountToBill, 0)
				ELSE 
					0
			END
			
	FROM 
		tblICInventoryShipmentCharge ShipmentCharge
		INNER JOIN @updateDetails UpdateTbl
			ON UpdateTbl.intInventoryShipmentChargeId = ShipmentCharge.intInventoryShipmentChargeId			
	WHERE 
		UpdateTbl.intInventoryShipmentChargeId IS NOT NULL
		AND ShipmentCharge.intEntityVendorId = UpdateTbl.intEntityVendorId
END
/*
	END - Update Shipment Charges Bill Qty
*/

Post_Exit:
END