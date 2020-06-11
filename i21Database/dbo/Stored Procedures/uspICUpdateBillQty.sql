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
		, @type_BillToUse INT

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
	,[ysnStoreDebitMemo] = 
		CASE 
			WHEN dbo.fnICGetReceiptTotals(r.intInventoryReceiptId, 6) < 0 AND r.intSourceType = @SourceType_STORE THEN 
				1
			ELSE
				0
		END 
FROM 
	@updateDetails UpdateTbl INNER JOIN tblICInventoryReceiptItem ReceiptItem 
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

/*
	BEGIN - Update Receipt Item Bill Qty
*/
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
	)
	
	INSERT INTO @ReceiptToBills
	SELECT
		r.strReceiptNumber
		,dblOpenReceive = CASE WHEN u.ysnStoreDebitMemo = 1 THEN -ri.dblOpenReceive ELSE ri.dblOpenReceive END
		,dblBillQty = CASE WHEN u.ysnStoreDebitMemo = 1 THEN -ri.dblBillQty ELSE ri.dblBillQty END
		,ri.intItemId
		,ri.intInventoryReceiptItemId
	FROM 
		tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri 
			ON ri.intInventoryReceiptId = r.intInventoryReceiptId
		INNER JOIN @updateDetails_ReceiptItems u 
			ON u.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
			AND u.intItemId = ri.intItemId

	SELECT TOP 1 
		@TransactionNo = ReceiptItem.strReceiptNumber
		,@ItemNo = Item.strItemNo
		,@ReceiptQty = ReceiptItem.dblOpenReceive
		,@BilledQty = ReceiptItem.dblBillQty
	FROM 
		@updateDetails_ReceiptItems intInventoryReceiptItemId INNER JOIN @ReceiptToBills ReceiptItem 
			ON ReceiptItem.intInventoryReceiptItemId = intInventoryReceiptItemId.intInventoryReceiptItemId 
			AND ReceiptItem.intItemId = intInventoryReceiptItemId.intItemId
		INNER JOIN tblICInventoryReceiptItem SourceReceiptItem 
			ON SourceReceiptItem.intInventoryReceiptItemId = intInventoryReceiptItemId.intInventoryReceiptItemId 
			AND SourceReceiptItem.intItemId = intInventoryReceiptItemId.intItemId
		INNER JOIN tblICItem Item
			ON Item.intItemId = intInventoryReceiptItemId.intItemId
	WHERE 
		ABS(
			ISNULL(ReceiptItem.dblBillQty, 0) 
			+ dbo.fnCalculateQtyBetweenUOM(
				intInventoryReceiptItemId.intToBillUOMId
				, SourceReceiptItem.intUnitMeasureId
				, intInventoryReceiptItemId.dblToBillQty
			) 
		) > ABS(ReceiptItem.dblOpenReceive)

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
				, CASE WHEN UpdateTbl.ysnStoreDebitMemo = 1 THEN -UpdateTbl.dblToBillQty ELSE UpdateTbl.dblToBillQty END
			)
	FROM 
		tblICInventoryReceiptItem SourceReceiptItem INNER JOIN @updateDetails_ReceiptItems UpdateTbl
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
	,[ysnStoreDebitMemo] = 
		CASE 
			WHEN dbo.fnICGetReceiptTotals(r.intInventoryReceiptId, 6) < 0 AND r.intSourceType = @SourceType_STORE THEN 
				CASE
					WHEN UpdateTbl.intEntityVendorId = r.intEntityVendorId THEN 1 
					WHEN ReceiptCharge.ysnPrice = 1 THEN 1
					ELSE 
						0
				END
			ELSE
				0
		END 
FROM 
	@updateDetails UpdateTbl INNER JOIN tblICInventoryReceiptCharge ReceiptCharge 
		ON ReceiptCharge.intInventoryReceiptChargeId = UpdateTbl.intInventoryReceiptChargeId 
		AND ReceiptCharge.intChargeId = UpdateTbl.intItemId
	INNER JOIN tblICItem Item 
		ON Item.intItemId = UpdateTbl.intItemId
	INNER JOIN tblICInventoryReceipt r 
		ON r.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
WHERE 
	UpdateTbl.intInventoryReceiptChargeId IS NOT NULL 
	AND UpdateTbl.dblToBillQty <> 0

IF EXISTS(
	SELECT TOP 1 1 FROM @updateDetails_ReceiptCharges
)
BEGIN
	-- Process accrued other charges
	BEGIN 	
		-- Validate if the item is over billed for Accrue
		SET @BilledQty = 0;

		DECLARE @ReceiptChargesToBill TABLE(
			strReceiptNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
			,dblQuantity NUMERIC(38, 20)
			,dblQuantityBilled NUMERIC(38, 20)
			,intItemId INT
			,intInventoryReceiptChargeId INT
			,ReceiptChargesToBill INT
			,dblToBillQty NUMERIC(38, 20)
			,intEntityVendorId INT 
			,intSourceTransactionNoId INT 
		)
	
		INSERT INTO @ReceiptChargesToBill
		SELECT
			Receipt.strReceiptNumber
			,dblQuantity = CASE WHEN u.ysnStoreDebitMemo = 1 THEN -ReceiptCharge.dblQuantity ELSE ReceiptCharge.dblQuantity END
			,dblQuantityBilled = CASE WHEN u.ysnStoreDebitMemo = 1 THEN -ReceiptCharge.dblQuantityBilled ELSE ReceiptCharge.dblQuantityBilled END
			,Item.intItemId
			,ReceiptCharge.intInventoryReceiptChargeId
			,u.intSourceTransactionNoId 
			,dblToBillQty = CASE WHEN u.ysnStoreDebitMemo = 1 THEN -u.dblToBillQty ELSE u.dblToBillQty END
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
			u.intEntityVendorId = Receipt.intEntityVendorId

		SELECT TOP 1 
			@TransactionNo = Receipt.strReceiptNumber
			,@ItemNo = Item.strItemNo
			,@ReceiptQty = ReceiptCharge.dblQuantity
			,@BilledQty = ReceiptCharge.dblQuantityBilled
		FROM 
			@ReceiptChargesToBill ReceiptChargesToBill INNER JOIN tblICInventoryReceiptCharge ReceiptCharge
				ON ReceiptCharge.intInventoryReceiptChargeId = ReceiptChargesToBill.intInventoryReceiptChargeId 
				AND ReceiptCharge.intChargeId = ReceiptChargesToBill.intItemId
			INNER JOIN tblICInventoryReceipt Receipt
				ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
			INNER JOIN tblICItem Item
				ON Item.intItemId = ReceiptChargesToBill.intItemId
		WHERE 
			ABS(
				ReceiptCharge.dblQuantityBilled +
				CASE 
					WHEN ReceiptCharge.ysnPrice = 1 THEN -ReceiptChargesToBill.dblToBillQty
					ELSE ReceiptChargesToBill.dblToBillQty 
				END
			) > ABS(ReceiptCharge.dblQuantity) -- Throw error if Bill Qty is greater than Receipt Qty
			AND ReceiptChargesToBill.intInventoryReceiptChargeId IS NOT NULL
			AND ReceiptChargesToBill.intEntityVendorId = ISNULL(ReceiptCharge.intEntityVendorId, Receipt.intEntityVendorId) 

		IF (ISNULL(@TransactionNo,'') <> '')
		BEGIN
			--'Billed Qty for {Item No} is already {Billed Qty}. You cannot over bill the transaction'
			EXEC uspICRaiseError 80228, @ItemNo, @BilledQty;
			GOTO Post_Exit;
		END

		UPDATE ReceiptCharge
		SET 
			ReceiptCharge.dblQuantityBilled = 
				ISNULL(ReceiptCharge.dblQuantityBilled, 0) + 
				CASE
					WHEN ReceiptCharge.ysnPrice = 1 THEN -u.dblToBillQty 
					ELSE u.dblToBillQty 
				END
			,ReceiptCharge.dblAmountBilled = 
				ISNULL(ReceiptCharge.dblAmountBilled, 0) + 
				dbo.fnMultiply(
					CASE 
						WHEN ReceiptCharge.ysnPrice = 1 THEN -u.dblToBillQty
						ELSE u.dblToBillQty 
					END
					, BillDetail.dblCost			
				)
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
			AND u.intEntityVendorId = 
				CASE 
					WHEN ReceiptCharge.ysnPrice = 1 THEN Receipt.intEntityVendorId 
					ELSE ISNULL(ReceiptCharge.intEntityVendorId, Receipt.intEntityVendorId) 
				END
	END 
	
	-- Process the Charge Entity (Discount) or Price = true
	BEGIN 
		DECLARE @ReceiptDiscountChargesToBill TABLE(
			strReceiptNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
			,dblQuantity NUMERIC(38, 20)
			,dblQuantityPriced NUMERIC(38, 20)
			,intItemId INT
			,intInventoryReceiptChargeId INT
			,ReceiptChargesToBill INT
			,dblToBillQty NUMERIC(38, 20)
			,intEntityVendorId INT 
			,intSourceTransactionNoId INT
		)
	
		INSERT INTO @ReceiptDiscountChargesToBill
		SELECT
			Receipt.strReceiptNumber
			,dblQuantity = CASE WHEN u.ysnStoreDebitMemo = 1 THEN -ReceiptCharge.dblQuantity ELSE ReceiptCharge.dblQuantity END
			,dblQuantityPriced = CASE WHEN u.ysnStoreDebitMemo = 1 THEN -ReceiptCharge.dblQuantityPriced ELSE ReceiptCharge.dblQuantityPriced END
			,Item.intItemId
			,ReceiptCharge.intInventoryReceiptChargeId
			,u.intSourceTransactionNoId 
			,dblToBillQty = CASE WHEN u.ysnStoreDebitMemo = 1 THEN -u.dblToBillQty ELSE u.dblToBillQty END
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

		-- Validate if the item is over billed for Charge Entity/Price = true
		IF EXISTS(
			SELECT TOP 1 1 FROM @ReceiptDiscountChargesToBill
		)
		BEGIN
			SET @BilledQty = 0;

			SELECT TOP 1 
				@TransactionNo = Receipt.strReceiptNumber
				,@ItemNo = Item.strItemNo
				,@ReceiptQty = ReceiptCharge.dblQuantity
				,@BilledQty = ReceiptCharge.dblQuantityPriced
			FROM 
				@ReceiptDiscountChargesToBill u INNER JOIN tblICInventoryReceiptCharge ReceiptCharge
					ON ReceiptCharge.intInventoryReceiptChargeId = u.intInventoryReceiptChargeId 
					AND ReceiptCharge.intChargeId = u.intItemId
					AND ReceiptCharge.intEntityVendorId = u.intEntityVendorId
				INNER JOIN tblICInventoryReceipt Receipt
					ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
				INNER JOIN tblICItem Item
					ON Item.intItemId = ReceiptCharge.intChargeId
			WHERE 
				(ReceiptCharge.dblQuantityPriced + u.dblToBillQty) > ReceiptCharge.dblQuantity -- Throw error if Bill Qty is greater than Receipt Qty
				OR (ReceiptCharge.dblQuantityPriced + u.dblToBillQty) < 0 -- Throw error also if Bill Qty is negative
				AND u.intInventoryReceiptChargeId IS NOT NULL
				AND ReceiptCharge.ysnPrice = 1

			IF (ISNULL(@TransactionNo,'') <> '')
			BEGIN
				--'Billed Qty for {Item No} is already {Billed Qty}. You cannot over bill the transaction'
				EXEC uspICRaiseError 80228, @ItemNo, @BilledQty;
				GOTO Post_Exit;
			END

			UPDATE ReceiptCharge
			SET 
				ReceiptCharge.dblQuantityPriced = ISNULL(ReceiptCharge.dblQuantityPriced, 0) + u.dblToBillQty
				,ReceiptCharge.dblAmountPriced = ISNULL(ReceiptCharge.dblAmountPriced, 0) + (BillDetail.dblTotal * (u.dblToBillQty/ABS(u.dblToBillQty)))
			FROM 
				tblICInventoryReceiptCharge ReceiptCharge INNER JOIN tblICInventoryReceipt Receipt
					ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
				INNER JOIN @ReceiptDiscountChargesToBill u
					ON u.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
					AND u.intEntityVendorId = ReceiptCharge.intEntityVendorId
				INNER JOIN tblAPBillDetail BillDetail
					ON BillDetail.intBillId = u.intSourceTransactionNoId
					AND BillDetail.intItemId = ReceiptCharge.intChargeId
					AND BillDetail.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
			WHERE 
				u.intInventoryReceiptChargeId IS NOT NULL
				AND ReceiptCharge.ysnPrice = 1
		END
	END 
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
			--AND UpdateTbl.intEntityVendorId = ShipmentCharge.intEntityVendorId
			--INNER JOIN tblICItem Item ON Item.intItemId = UpdateTbl.intItemId
	WHERE 
		UpdateTbl.intInventoryShipmentChargeId IS NOT NULL 
		AND UpdateTbl.dblToBillQty <> 0)
BEGIN
	-- Validate if the item is over billed
	SELECT TOP 1 
		@TransactionNo = Shipment.strShipmentNumber
		,@ItemNo = Item.strItemNo
		,@ReceiptQty = ShipmentCharge.dblQuantity
		,@BilledQty = ShipmentCharge.dblQuantityBilled
	FROM 
		@updateDetails UpdateTbl INNER JOIN tblICInventoryShipmentCharge ShipmentCharge
			ON ShipmentCharge.intInventoryShipmentChargeId = UpdateTbl.intInventoryShipmentChargeId 
			AND ShipmentCharge.intChargeId = UpdateTbl.intItemId
			AND ShipmentCharge.intEntityVendorId = UpdateTbl.intEntityVendorId
		INNER JOIN tblICInventoryShipment Shipment
			ON Shipment.intInventoryShipmentId = ShipmentCharge.intInventoryShipmentId
		INNER JOIN tblICItem Item
			ON Item.intItemId = UpdateTbl.intItemId
	WHERE 
		(ShipmentCharge.dblQuantityBilled + UpdateTbl.dblToBillQty) > ShipmentCharge.dblQuantity -- Throw error if Bill Qty is greater than Receipt Qty
		OR (ShipmentCharge.dblQuantityBilled + UpdateTbl.dblToBillQty) < 0 -- Throw error also if Bill Qty is negative
		AND UpdateTbl.intInventoryShipmentChargeId IS NOT NULL

	IF (ISNULL(@TransactionNo,'') <> '')
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