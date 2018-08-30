﻿CREATE PROCEDURE [dbo].[uspICConvertReceiptToVoucher]
	@intReceiptId INT,
	@intEntityUserSecurityId INT,
	@intBillId INT OUTPUT,
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
		,@voucherDetailClaim AS VoucherDetailClaim

		,@intShipFrom AS INT
		,@intShipTo AS INT 
		,@strVendorRefNo NVARCHAR(50)
		,@intCurrencyId AS INT 

		,@intShipFrom_DebitMemo AS INT
		,@intReturnValue AS INT

DECLARE @Own AS INT = 1
		,@Storage AS INT = 2
		,@ConsignedPurchase AS INT = 3

SELECT	@intEntityVendorId = intEntityVendorId
		,@billTypeToUse = @type_Voucher 
		,@intShipFrom = r.intShipFromId
		,@intShipTo = r.intLocationId
		,@strVendorRefNo = r.strVendorRefNo
		,@intCurrencyId = r.intCurrencyId
FROM	tblICInventoryReceipt r
WHERE	r.ysnPosted = 1
		AND r.intInventoryReceiptId = @intReceiptId

BEGIN 
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
				INNER JOIN tblICItem Item 
					ON Item.intItemId = ri.intItemId
		WHERE	r.ysnPosted = 1
				AND r.intInventoryReceiptId = @intReceiptId
				AND ri.dblBillQty < ri.dblOpenReceive 
				AND ri.intOwnershipType = @Own
				AND Item.strType <> 'Bundle'
				AND ISNULL(r.strReceiptType, '') <> 'Transfer Order'
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
						WHEN rc.strCostMethod = 'Gross Unit' THEN rc.dblRate
						ELSE rc.dblAmount
					END 
				,[intTaxGroupId] = rc.intTaxGroupId
		FROM	tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptCharge rc
					ON r.intInventoryReceiptId = rc.intInventoryReceiptId
		WHERE	r.ysnPosted = 1
				AND r.intInventoryReceiptId = @intReceiptId
				AND ISNULL(r.strReceiptType, '') <> 'Transfer Order'
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

	-- Check if we can convert the IR to Voucher
	IF NOT EXISTS (
		SELECT	TOP 1 1 
		FROM	tblICInventoryReceiptItem ri INNER JOIN @voucherItems vi
					ON ri.intInventoryReceiptItemId = vi.intInventoryReceiptItemId
		WHERE	ISNULL(ri.dblOpenReceive, 0) <> ISNULL(ri.dblBillQty, 0)
	) AND NOT EXISTS (
		SELECT TOP 1 1 FROM @voucherOtherCharges
	)
	BEGIN 
		-- Voucher is no longer needed. All items have Voucher. 
		EXEC uspICRaiseError 80111; 
		SET @intReturnValue = -80111;
		GOTO Post_Exit;
	END 

	-- Call the AP sp to convert the IR to Voucher. 
	BEGIN 
		DECLARE @throwedError AS NVARCHAR(1000);

		EXEC [dbo].[uspAPCreateBillData]
			@userId = @intEntityUserSecurityId
			,@vendorId = @intEntityVendorId
			,@type = @billTypeToUse
			,@voucherDetailReceipt = @voucherItems
			,@voucherDetailReceiptCharge = @voucherOtherCharges
			,@shipTo = @intShipTo
			,@shipFrom = @intShipFrom
			,@vendorOrderNumber = @strVendorRefNo
			,@currencyId = @intCurrencyId
			,@throwError = 0
			,@error = @throwedError OUTPUT
			,@billId = @intBillId OUTPUT

		IF(@throwedError <> '')
		BEGIN
			RAISERROR(@throwedError, 16, 1);
			SET @intReturnValue = -89999;
			GOTO Post_Exit;
		END
	END 

	SELECT @strBillIds = 
		LTRIM(
			STUFF(
					' ' + (
						SELECT  CONVERT(NVARCHAR(50), @intBillId) + '|^|'
						FOR xml path('')
					)
				, 1
				, 1
				, ''
			)
		)
END 

Post_Exit:
RETURN @intReturnValue;