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

DECLARE @SourceType_STORE AS INT = 7		 
		, @type_Voucher AS INT = 1
		, @type_DebitMemo AS INT = 3
		--, @type_BillToUse INT

DECLARE	@summarizedUpdateDetails AS InventoryUpdateBillQty 

INSERT INTO @summarizedUpdateDetails (
	[intInventoryReceiptItemId]
	,[intInventoryReceiptChargeId]
	,[intInventoryShipmentChargeId]
	,[intSourceTransactionNoId]
	,[strSourceTransactionNo]
	,[intEntityVendorId]
	,[intItemId]
	,[intToBillUOMId]
	,[dblToBillQty]
	,[dblAmountToBill]
	,[ysnStoreDebitMemo]
)
SELECT 
	[intInventoryReceiptItemId]
	,[intInventoryReceiptChargeId]
	,[intInventoryShipmentChargeId]
	,[intSourceTransactionNoId]
	,[strSourceTransactionNo]
	,[intEntityVendorId]
	,[intItemId]
	,[intToBillUOMId]
	,SUM([dblToBillQty])
	,SUM([dblAmountToBill])
	,ysnStoreDebitMemo = 0 
FROM 
	@updateDetails
GROUP BY 
	[intInventoryReceiptItemId]
	,[intInventoryReceiptChargeId]
	,[intInventoryShipmentChargeId]
	,[intSourceTransactionNoId]
	,[strSourceTransactionNo]
	,[intEntityVendorId]
	,[intItemId]
	,[intToBillUOMId]

/*************************************************************************************************
	BEGIN - Update Receipt Item Bill Qty
*************************************************************************************************/
DECLARE @updateDetails_ReceiptItems AS InventoryUpdateBillQty

INSERT INTO @updateDetails_ReceiptItems (
	[intInventoryReceiptItemId]
	,[intInventoryReceiptChargeId]
	,[intInventoryShipmentChargeId]
	,[intSourceTransactionNoId]
	,[strSourceTransactionNo]
	,[intEntityVendorId]
	,[intItemId]
	,[intToBillUOMId]
	,[dblToBillQty]
	,[dblAmountToBill]
	,[ysnStoreDebitMemo]
)
SELECT 
	UpdateTbl.[intInventoryReceiptItemId]
	,UpdateTbl.[intInventoryReceiptChargeId]
	,UpdateTbl.[intInventoryShipmentChargeId]
	,UpdateTbl.[intSourceTransactionNoId]
	,UpdateTbl.[strSourceTransactionNo]
	,UpdateTbl.[intEntityVendorId]
	,UpdateTbl.[intItemId]
	,UpdateTbl.[intToBillUOMId]
	,UpdateTbl.[dblToBillQty]
	,UpdateTbl.[dblAmountToBill]
	,[ysnStoreDebitMemo] = 
		CASE 
			WHEN dbo.fnICGetReceiptTotals(r.intInventoryReceiptId, 6) < 0 AND r.intSourceType = @SourceType_STORE THEN 
				1
			ELSE
				0
		END 
FROM 
	@summarizedUpdateDetails UpdateTbl INNER JOIN tblICInventoryReceiptItem ReceiptItem 
		ON ReceiptItem.intInventoryReceiptItemId = UpdateTbl.intInventoryReceiptItemId 
		AND ReceiptItem.intItemId = UpdateTbl.intItemId
	INNER JOIN tblICItem Item 
		ON Item.intItemId = UpdateTbl.intItemId
	INNER JOin tblICInventoryReceipt r 
		ON r.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
WHERE 
	UpdateTbl.intInventoryReceiptItemId IS NOT NULL 
	AND UpdateTbl.intInventoryReceiptChargeId IS NULL 
	AND UpdateTbl.dblToBillQty <> 0


IF EXISTS(
	SELECT TOP 1 1 FROM @updateDetails_ReceiptItems
)
BEGIN
	-- Validate if the item is over billed
	SET @BilledQty = 0;

	DECLARE @ReceiptToBills TABLE(
		strReceiptNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
		,dblOpenReceive NUMERIC(38, 20)
		,dblBillQty NUMERIC(38, 20)
		,intItemId INT
		,intInventoryReceiptItemId INT
		,intUnitMeasureId INT
		,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,dblToBillQty NUMERIC(38, 20)
	)

	-- Summarize the receipt details. 
	INSERT INTO @ReceiptToBills
	SELECT
		r.strReceiptNumber
		,dblOpenReceive = CASE WHEN u.ysnStoreDebitMemo = 1 THEN -ri.dblOpenReceive ELSE ri.dblOpenReceive END
		,dblBillQty = CASE WHEN u.ysnStoreDebitMemo = 1 THEN -ri.dblBillQty ELSE ri.dblBillQty END
		,ri.intItemId
		,ri.intInventoryReceiptItemId
		,ri.intUnitMeasureId
		,Item.strItemNo
		,dblToBillQty = 
			--ISNULL(u.dblToBillQty, 0)
			dbo.fnCalculateQtyBetweenUOM (
				u.intToBillUOMId
				, ri.intUnitMeasureId
				, CASE WHEN u.ysnStoreDebitMemo = 1 THEN -u.dblToBillQty ELSE u.dblToBillQty END
			)

	FROM 
		tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri 
			ON ri.intInventoryReceiptId = r.intInventoryReceiptId
		INNER JOIN tblICItem Item
			ON Item.intItemId = ri.intItemId
		INNER JOIN @updateDetails_ReceiptItems u
			ON u.intInventoryReceiptItemId = ri.intInventoryReceiptItemId 
			AND u.intItemId	= ri.intItemId
		--CROSS APPLY (
		--	SELECT 
		--		UpdateTbl.intInventoryReceiptItemId
		--		,UpdateTbl.intItemId
		--		,UpdateTbl.ysnStoreDebitMemo
		--		,dblToBillQty = 
		--			SUM(
		--				dbo.fnCalculateQtyBetweenUOM(
		--					UpdateTbl.intToBillUOMId
		--					, ri2.intUnitMeasureId
		--					, CASE WHEN UpdateTbl.ysnStoreDebitMemo = 1 THEN -UpdateTbl.dblToBillQty ELSE UpdateTbl.dblToBillQty END
		--				)
		--			)	
		--	FROM 
		--		@updateDetails_ReceiptItems UpdateTbl INNER JOIN tblICInventoryReceiptItem ri2
		--			ON UpdateTbl.intInventoryReceiptItemId = ri2.intInventoryReceiptItemId 
		--			AND UpdateTbl.intItemId	= ri2.intItemId
		--	WHERE 
		--		UpdateTbl.intInventoryReceiptItemId = ri.intInventoryReceiptItemId 
		--		AND UpdateTbl.intItemId	= ri.intItemId
		--	GROUP BY
		--		UpdateTbl.intInventoryReceiptItemId
		--		,UpdateTbl.intItemId
		--		,UpdateTbl.ysnStoreDebitMemo	
		--) GroupedUpdateDetails

	-- Get the top record that will over-bill the voucher. 
	SELECT TOP 1 
		@TransactionNo = ReceiptItem.strReceiptNumber
		,@ItemNo = ReceiptItem.strItemNo
		,@ReceiptQty = ReceiptItem.dblOpenReceive
		,@BilledQty = ReceiptItem.dblBillQty
	FROM 
		@ReceiptToBills ReceiptItem 		
	WHERE 
		ABS(ISNULL(ReceiptItem.dblBillQty, 0) + ReceiptItem.dblToBillQty) > ABS(ReceiptItem.dblOpenReceive)		
	
	-- If there is an over-bill, raise the error. 
	IF (ISNULL(@TransactionNo,'') <> '')
	BEGIN
		--'Billed Qty for {Item No} is already {Billed Qty}. You cannot overbill the transaction'
		EXEC uspICRaiseError 80228, @ItemNo, @BilledQty;
		GOTO Post_Exit;
	END

	-- Otherwise, update the ri dblBillQty. 
	UPDATE SourceReceiptItem
	SET 
		SourceReceiptItem.dblBillQty = 
			ISNULL(SourceReceiptItem.dblBillQty, 0) 
			+ UpdateTbl.dblToBillQty
	FROM 
		tblICInventoryReceiptItem SourceReceiptItem INNER JOIN @ReceiptToBills UpdateTbl
			ON 
				UpdateTbl.intInventoryReceiptItemId = SourceReceiptItem.intInventoryReceiptItemId 
				AND UpdateTbl.intItemId	= SourceReceiptItem.intItemId
				AND UpdateTbl.intInventoryReceiptItemId IS NOT NULL		
END
/*************************************************************************************************
	END - Update Receipt Item Bill Qty
*************************************************************************************************/


/*****************************************************************************************************
	BEGIN - Update Receipt Charges Bill Qty
*****************************************************************************************************/
DECLARE @updateDetails_ReceiptCharges AS InventoryUpdateBillQty
INSERT INTO @updateDetails_ReceiptCharges (
	[intInventoryReceiptItemId]
	,[intInventoryReceiptChargeId]
	,[intInventoryShipmentChargeId]
	,[intSourceTransactionNoId]
	,[strSourceTransactionNo]
	,[intEntityVendorId]
	,[intItemId]
	,[intToBillUOMId]
	,[dblToBillQty]
	,[dblAmountToBill]
	,[ysnStoreDebitMemo]
)
SELECT 
	UpdateTbl.[intInventoryReceiptItemId]
	,UpdateTbl.[intInventoryReceiptChargeId]
	,UpdateTbl.[intInventoryShipmentChargeId]
	,UpdateTbl.[intSourceTransactionNoId]
	,UpdateTbl.[strSourceTransactionNo]
	,UpdateTbl.[intEntityVendorId]
	,UpdateTbl.[intItemId]
	,UpdateTbl.[intToBillUOMId]
	,UpdateTbl.[dblToBillQty]
	,UpdateTbl.[dblAmountToBill]
	,[ysnStoreDebitMemo] = 
		CASE 
			WHEN dbo.fnICGetReceiptTotals(r.intInventoryReceiptId, 6) < 0 AND r.intSourceType = @SourceType_STORE THEN 
				CASE
					WHEN ReceiptCharge.ysnPrice = 1 THEN 1
					WHEN UpdateTbl.intEntityVendorId = r.intEntityVendorId THEN 1 
					ELSE 
						0
				END 

				
			ELSE
				0
		END 
FROM 
	@summarizedUpdateDetails UpdateTbl INNER JOIN tblICInventoryReceiptCharge ReceiptCharge 
		ON ReceiptCharge.intInventoryReceiptChargeId = UpdateTbl.intInventoryReceiptChargeId 
		AND ReceiptCharge.intChargeId = UpdateTbl.intItemId
	INNER JOIN tblICItem Item 
		ON Item.intItemId = UpdateTbl.intItemId
	INNER JOIN tblICInventoryReceipt r 
		ON r.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
WHERE 
	UpdateTbl.intInventoryReceiptChargeId IS NOT NULL 

DECLARE @ReceiptChargesToBill TABLE(
	strReceiptNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
	,dblQuantity NUMERIC(38, 20)
	,dblQuantityBilled NUMERIC(38, 20)
	,dblAmountBilled NUMERIC(38, 20)
	,intItemId INT
	,intInventoryReceiptChargeId INT
	,ReceiptChargesToBill INT
	,dblToBillQty NUMERIC(38, 20)
	,dblAmountToBill NUMERIC(38, 20)
	,intEntityVendorId INT 
	,intSourceTransactionNoId INT 
)

INSERT INTO @ReceiptChargesToBill
SELECT
	Receipt.strReceiptNumber
	,dblQuantity = CASE WHEN u.ysnStoreDebitMemo = 1 THEN -ReceiptCharge.dblQuantity ELSE ReceiptCharge.dblQuantity END
	,dblQuantityBilled = CASE WHEN u.ysnStoreDebitMemo = 1 THEN -ReceiptCharge.dblQuantityBilled ELSE ReceiptCharge.dblQuantityBilled END
	,dblAmountBilled = CASE WHEN u.ysnStoreDebitMemo = 1 THEN -ReceiptCharge.dblAmountBilled ELSE ReceiptCharge.dblAmountBilled END
	,Item.intItemId
	,ReceiptCharge.intInventoryReceiptChargeId
	,u.intSourceTransactionNoId 
	,dblToBillQty = CASE WHEN u.ysnStoreDebitMemo = 1 THEN -u.dblToBillQty ELSE u.dblToBillQty END 
	,dblAmountToBill = CASE WHEN u.ysnStoreDebitMemo = 1 THEN -u.dblAmountToBill ELSE u.dblAmountToBill END 
	,intEntityVendorId = u.intEntityVendorId
	,u.intSourceTransactionNoId
FROM 
	@updateDetails_ReceiptCharges u INNER JOIN tblICInventoryReceiptCharge ReceiptCharge
		ON ReceiptCharge.intInventoryReceiptChargeId = u.intInventoryReceiptChargeId 
		AND ReceiptCharge.intChargeId = u.intItemId
	INNER JOIN tblICInventoryReceipt Receipt
		ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
	INNER JOIN tblICItem Item
		ON Item.intItemId = u.intItemId
WHERE
	ReceiptCharge.intEntityVendorId = u.intEntityVendorId

IF EXISTS(
	SELECT TOP 1 1 FROM @ReceiptChargesToBill
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
				WHEN ReceiptCharge.strCostMethod IN ('Amount', 'Percentage') THEN ISNULL(ReceiptChargesToBill.dblAmountBilled, 0) 
				ELSE ISNULL(ReceiptChargesToBill.dblQuantityBilled, 0) 
			END 
	FROM 
		tblICInventoryReceiptCharge ReceiptCharge 
		INNER JOIN tblICItem Item
			ON Item.intItemId = ReceiptCharge.intChargeId
		INNER JOIN tblICInventoryReceipt Receipt
			ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
		INNER JOIN @ReceiptChargesToBill ReceiptChargesToBill
			ON ReceiptChargesToBill.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
			AND ReceiptChargesToBill.intItemId = ReceiptCharge.intChargeId
		
	WHERE 
		ReceiptChargesToBill.intInventoryReceiptChargeId IS NOT NULL
		AND ReceiptCharge.intEntityVendorId = ReceiptChargesToBill.intEntityVendorId
		AND 1 = 
			CASE 
				WHEN ReceiptCharge.strCostMethod IN ('Amount', 'Percentage') AND ISNULL(ReceiptCharge.dblAmountBilled, 0) + ISNULL(ReceiptChargesToBill.dblAmountToBill, 0) > ISNULL(ReceiptCharge.dblAmount, 0) THEN 1 
				WHEN ISNULL(ReceiptCharge.dblQuantityBilled, 0) + ISNULL(ReceiptChargesToBill.dblToBillQty, 0) > ISNULL(ReceiptCharge.dblQuantity, 0) THEN 1 
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
				WHEN ReceiptCharge.strCostMethod IN ('Amount', 'Percentage') THEN 					
					0
				ELSE 
					ISNULL(u.dblToBillQty, 0) 
			END 

		,ReceiptCharge.dblAmountBilled = 
			ISNULL(ReceiptCharge.dblAmountBilled, 0) 
			+ CASE 
				WHEN ReceiptCharge.strCostMethod IN ('Amount', 'Percentage') THEN 
					ISNULL(u.dblAmountToBill, 0)
				ELSE 
					0
			END

	FROM 
		tblICInventoryReceiptCharge ReceiptCharge INNER JOIN tblICInventoryReceipt Receipt
			ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
		INNER JOIN @ReceiptChargesToBill u
			ON u.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
			AND u.intItemId = ReceiptCharge.intChargeId
		INNER JOIN tblAPBillDetail BillDetail
			ON BillDetail.intBillId = u.intSourceTransactionNoId
			AND BillDetail.intItemId = ReceiptCharge.intChargeId
			AND BillDetail.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
	WHERE 
		u.intInventoryReceiptChargeId IS NOT NULL
		AND u.intEntityVendorId = ReceiptCharge.intEntityVendorId
END 
/*****************************************************************************************************
	END - Update Receipt Charges Bill Qty
*****************************************************************************************************/

/*****************************************************************************************************
-- BEGIN - Update the billed for Charge Entity/Price = true
*****************************************************************************************************/
DECLARE @ReceiptDiscountChargesToBill TABLE(
	strReceiptNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
	,dblQuantity NUMERIC(38, 20)
	,dblQuantityPriced NUMERIC(38, 20)
	,intItemId INT
	,intInventoryReceiptChargeId INT
	,ReceiptChargesToBill INT
	,dblToBillQty NUMERIC(38, 20)
	,dblAmountToBill NUMERIC(38, 20)
	,intEntityVendorId INT 
	,intSourceTransactionNoId INT
)
	
INSERT INTO @ReceiptDiscountChargesToBill
SELECT
	Receipt.strReceiptNumber
	,dblQuantity = CASE WHEN u.ysnStoreDebitMemo = 1 THEN ReceiptCharge.dblQuantity ELSE -ReceiptCharge.dblQuantity END
	,dblQuantityPriced = CASE WHEN u.ysnStoreDebitMemo = 1 THEN ReceiptCharge.dblQuantityPriced ELSE -ReceiptCharge.dblQuantityPriced END
	,Item.intItemId
	,ReceiptCharge.intInventoryReceiptChargeId
	,u.intSourceTransactionNoId 
	,dblToBillQty = CASE WHEN u.ysnStoreDebitMemo = 1 THEN u.dblToBillQty ELSE -u.dblToBillQty END 
	,dblAmountToBill = CASE WHEN u.ysnStoreDebitMemo = 1 THEN u.dblAmountToBill ELSE -u.dblAmountToBill END 
	,intEntityVendorId = u.intEntityVendorId
	,u.intSourceTransactionNoId
FROM 
	@updateDetails_ReceiptCharges u INNER JOIN tblICInventoryReceiptCharge ReceiptCharge
		ON ReceiptCharge.intInventoryReceiptChargeId = u.intInventoryReceiptChargeId 
		AND ReceiptCharge.intChargeId = u.intItemId
	INNER JOIN tblICInventoryReceipt Receipt
		ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
	INNER JOIN tblICItem Item
		ON Item.intItemId = u.intItemId
WHERE 
	ReceiptCharge.ysnPrice = 1
	AND Receipt.intEntityVendorId = u.intEntityVendorId		

IF EXISTS(
	SELECT TOP 1 1 FROM @ReceiptDiscountChargesToBill
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
		INNER JOIN @ReceiptDiscountChargesToBill u 		
			ON ReceiptCharge.intInventoryReceiptChargeId = u.intInventoryReceiptChargeId 
			AND ReceiptCharge.intChargeId = u.intItemId			
		INNER JOIN tblICItem Item 
			ON Item.intItemId = u.intItemId
	WHERE 
		u.intInventoryReceiptChargeId IS NOT NULL
		AND ReceiptCharge.ysnPrice = 1
		AND Receipt.intEntityVendorId = u.intEntityVendorId
		AND 1 = 
			CASE 
				WHEN ReceiptCharge.strCostMethod IN ('Amount', 'Percentage') AND ISNULL(ReceiptCharge.dblAmountPriced, 0) + ISNULL(u.dblAmountToBill, 0) > ISNULL(ReceiptCharge.dblAmount, 0) THEN 1 
				WHEN ISNULL(ReceiptCharge.dblQuantityPriced, 0) + ISNULL(u.dblToBillQty, 0) > ISNULL(ReceiptCharge.dblQuantity, 0) THEN 1 
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
				WHEN ReceiptCharge.strCostMethod IN ('Amount', 'Percentage')  THEN 					
					0
				ELSE 
					ISNULL(u.dblToBillQty, 0) 
			END 

		,ReceiptCharge.dblAmountPriced = 
			ISNULL(ReceiptCharge.dblAmountPriced, 0) 
			+ CASE 
				WHEN ReceiptCharge.strCostMethod IN ('Amount', 'Percentage') THEN 
					ISNULL(u.dblAmountToBill, 0)
				ELSE 
					0
			END
	FROM 
		tblICInventoryReceiptCharge ReceiptCharge INNER JOIN tblICInventoryReceipt Receipt
			ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
		INNER JOIN @ReceiptDiscountChargesToBill u
			ON u.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
			AND ReceiptCharge.intChargeId = u.intItemId
			
	WHERE 
		u.intInventoryReceiptChargeId IS NOT NULL
		AND ReceiptCharge.ysnPrice = 1
		AND u.intEntityVendorId = Receipt.intEntityVendorId		
END
/*****************************************************************************************************
	END - Update the billed for Charge Entity/Price = true
*****************************************************************************************************/

/*****************************************************************************************************
	BEGIN - Update Shipment Charges Bill Qty
*****************************************************************************************************/
IF EXISTS(
	SELECT TOP 1 1 
	FROM 
		@summarizedUpdateDetails UpdateTbl INNER JOIN tblICInventoryShipmentCharge ShipmentCharge 
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
		@summarizedUpdateDetails UpdateTbl INNER JOIN tblICInventoryShipmentCharge ShipmentCharge
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
		INNER JOIN @summarizedUpdateDetails UpdateTbl
			ON UpdateTbl.intInventoryShipmentChargeId = ShipmentCharge.intInventoryShipmentChargeId			
	WHERE 
		UpdateTbl.intInventoryShipmentChargeId IS NOT NULL
		AND ShipmentCharge.intEntityVendorId = UpdateTbl.intEntityVendorId
END
/*****************************************************************************************************
	END - Update Shipment Charges Bill Qty
*****************************************************************************************************/


Post_Exit:
END