CREATE PROCEDURE [dbo].[uspICProcessToBill]
	@intReceiptId int,
	@intUserId int,
	@intBillId int OUTPUT,
	@strBillIds NVARCHAR(MAX) = NULL OUTPUT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @intEntityVendorId AS INT				
		,@type_Voucher AS INT = 1
		,@type_DebitMemo AS INT = 3
		,@billTypeToUse AS INT 

		,@voucherItems AS VoucherDetailReceipt 
		,@voucherOtherCharges AS VoucherDetailReceiptCharge 
		,@intShipFrom AS INT
		,@intShipTo AS INT 
		,@intCurrencyId AS INT 

SELECT	@intEntityVendorId = intEntityVendorId
		,@billTypeToUse = 
			CASE 
				WHEN r.strReceiptType = 'Inventory Return' THEN @type_DebitMemo
				ELSE @type_Voucher 
			END
		,@intShipFrom = r.intShipFromId
		,@intShipTo = r.intLocationId
		,@intCurrencyId = r.intCurrencyId
FROM	tblICInventoryReceipt r 
WHERE	r.ysnPosted = 1
		AND r.intInventoryReceiptId = @intReceiptId
		AND ISNULL(r.strReceiptType, '') <> 'Transfer Order'

-- Assemble the voucher items 
BEGIN 
	INSERT INTO @voucherItems (
			[intInventoryReceiptType]
			,[intInventoryReceiptItemId]
			,[dblQtyReceived]
			,[dblCost]
			,[intTaxGroupId]
	)
	SELECT 
			[intInventoryReceiptType] = 
				CASE 
					WHEN r.strReceiptType = 'Direct' THEN 1
					WHEN r.strReceiptType = 'Purchase Contract' THEN 2
					WHEN r.strReceiptType = 'Purchase Order' THEN 3
					WHEN r.strReceiptType = 'Transfer Order' THEN 4
					WHEN r.strReceiptType = 'Inventory Return' THEN 4
					ELSE NULL 
				END 
			,[intInventoryReceiptItemId] = ri.intInventoryReceiptItemId
			,[dblQtyReceived] = ri.dblOpenReceive - ri.dblBillQty
			,[dblCost] = ri.dblUnitCost
			,[intTaxGroupId] = ri.intTaxGroupId
	FROM	tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
				ON r.intInventoryReceiptId = ri.intInventoryReceiptId
	WHERE	r.ysnPosted = 1
			AND r.intInventoryReceiptId = @intReceiptId
			AND ri.dblBillQty < ri.dblOpenReceive 
			AND ri.intOwnershipType != 2		
END 

-- Assemble the Other Charges
BEGIN
	INSERT INTO @voucherOtherCharges (
			[intInventoryReceiptChargeId]
			,[dblQtyReceived]
			,[dblCost]
			,[intTaxGroupId]
	)
	SELECT	
			[intInventoryReceiptChargeId] = rc.intInventoryReceiptChargeId
			,[dblQtyReceived] = 
				CASE 
					WHEN rc.ysnPrice = 1 THEN 
						rc.dblQuantity - ISNULL(-rc.dblQuantityPriced, 0) 
					ELSE 
						rc.dblQuantity - ISNULL(rc.dblQuantityBilled, 0) 
				END 

			,[dblCost] = 
				CASE 
					WHEN rc.strCostMethod = 'Per Unit' THEN rc.dblRate
					ELSE rc.dblAmount
				END 
			,[intTaxGroupId] = rc.intTaxGroupId
	FROM	tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptCharge rc
				ON r.intInventoryReceiptId = rc.intInventoryReceiptId
	WHERE	r.ysnPosted = 1
			AND r.intInventoryReceiptId = @intReceiptId
			AND 
			(
				(
					rc.ysnPrice = 1
					AND ISNULL(-rc.dblAmountPriced, 0) < rc.dblAmount
				)
				OR (
					rc.ysnAccrue = 1 
					AND r.intEntityVendorId = ISNULL(rc.intEntityVendorId, r.intEntityVendorId) 
					AND ISNULL(rc.dblAmountBilled, 0) < rc.dblAmount
				)
			)
END 

-- Call the AP sp to convert the IR to Voucher. 
BEGIN 
	EXEC [dbo].[uspAPCreateBillData]
		@userId = @intUserId
		,@vendorId = @intEntityVendorId
		,@type = @billTypeToUse
		,@voucherDetailReceipt = @voucherItems
		,@voucherDetailReceiptCharge = @voucherOtherCharges
		,@shipTo = @intShipTo
		,@shipFrom = @intShipFrom
		,@currencyId = @intCurrencyId
		,@billId = @intBillId OUTPUT
END 

SELECT @strBillIds = 
	LTRIM(
		STUFF(
				' ' + (
					SELECT  CONVERT(NVARCHAR(50), @intBillId) + '|^|'
					--FROM	#tmpBillIds
					--ORDER BY intBillId
					FOR xml path('')
				)
			, 1
			, 1
			, ''
		)
	)
