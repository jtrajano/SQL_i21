CREATE PROCEDURE [dbo].[uspICConvertReceiptToVoucher]
	@intReceiptId INT,
	@intEntityUserSecurityId INT,
	@intBillId INT OUTPUT,
	@strBillIds NVARCHAR(MAX) = NULL OUTPUT,
	@intScreenId INT = NULL
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
		,@intSourceType AS INT 
		,@strReceiptNumber AS NVARCHAR(50)
		,@dtmReceiptDate AS DATETIME

		,@voucherItems AS VoucherDetailReceipt 
		,@voucherOtherCharges AS VoucherDetailReceiptCharge 
		,@voucherDetailClaim AS VoucherDetailClaim

		,@intShipFrom AS INT
		,@intShipTo AS INT 
		,@strVendorRefNo NVARCHAR(50)
		,@intCurrencyId AS INT 

		,@intShipFrom_DebitMemo AS INT
		,@intReturnValue AS INT

DECLARE @SourceType_NONE AS INT = 0
		,@SourceType_SCALE AS INT = 1
		,@SourceType_INBOUND_SHIPMENT AS INT = 2
		,@SourceType_TRANSPORT AS INT = 3
		,@SourceType_SETTLE_STORAGE AS INT = 4
		,@SourceType_DELIVERY_SHEET AS INT = 5
		,@SourceType_PURCHASE_ORDER AS INT = 6
		,@SourceType_STORE AS INT = 7

DECLARE @Own AS INT = 1
		,@Storage AS INT = 2
		,@ConsignedPurchase AS INT = 3

DECLARE @intScreenId_InventoryReceipt AS INT = 1

SELECT	@intEntityVendorId = intEntityVendorId
		,@billTypeToUse = 
				CASE 
					WHEN dbo.fnICGetReceiptTotals(r.intInventoryReceiptId, 6) < 0 AND r.intSourceType = @SourceType_STORE THEN 
						@type_DebitMemo
					ELSE 
						@type_Voucher
				END 

		,@intShipFrom = r.intShipFromId
		,@intShipTo = r.intLocationId
		,@strVendorRefNo = r.strVendorRefNo
		,@intCurrencyId = r.intCurrencyId
		,@intSourceType = r.intSourceType
		,@strReceiptNumber = r.strReceiptNumber
		,@dtmReceiptDate = r.dtmReceiptDate
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
				,[dblQtyReceived] = 
					CASE 
						WHEN @billTypeToUse = @type_DebitMemo THEN 
							-(ri.dblOpenReceive - ri.dblBillQty)
						ELSE 
							ri.dblOpenReceive - ri.dblBillQty
					END 
				,[dblCost] = ri.dblUnitCost
				,[intTaxGroupId] = ri.intTaxGroupId
		FROM	tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
					ON r.intInventoryReceiptId = ri.intInventoryReceiptId
				INNER JOIN tblICItem Item 
					ON Item.intItemId = ri.intItemId
		WHERE	r.ysnPosted = 1
				AND r.intInventoryReceiptId = @intReceiptId
				AND ABS(ri.dblBillQty) < ABS(ri.dblOpenReceive)
				AND ri.intOwnershipType = @Own
				AND Item.strType <> 'Bundle'
				AND ISNULL(r.strReceiptType, '') <> 'Transfer Order'
				AND 1 = 
					CASE 
						WHEN @intScreenId = @intScreenId_InventoryReceipt AND ri.ysnAllowVoucher = 0 THEN 
							0
						ELSE 
							1
					END 
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
				AND 1 = 
					CASE 
						WHEN @intScreenId = @intScreenId_InventoryReceipt AND rc.ysnAllowVoucher = 0 THEN 
							0
						ELSE 
							1
					END
	END 

	-- Check if we can convert the IR Items to Voucher
	IF (
		EXISTS (
			SELECT	TOP 1 1 
			FROM	tblICInventoryReceiptItem ri INNER JOIN tblICItem i
						ON ri.intItemId = i.intItemId
			WHERE	ri.intInventoryReceiptId = @intReceiptId
					AND ri.dblBillQty < ri.dblOpenReceive 
					AND ri.intOwnershipType = @Own
					AND i.strType <> 'Bundle'
		)
		AND NOT EXISTS (SELECT TOP 1 1 FROM @voucherItems) 
	) 
	BEGIN 
		-- 'The items in {Receipt Number} are not allowed to be converted to Voucher. It could be a DP or Zero Spot Priced.'
		EXEC uspICRaiseError 80226, @strReceiptNumber; 
		RETURN -80226; 
	END 

	-- Check if we can convert the IR Other Charges to Voucher
	IF (
		EXISTS (
			SELECT	TOP 1 1 
			FROM	tblICInventoryReceiptCharge rc INNER JOIN tblICInventoryReceipt r
						ON rc.intInventoryReceiptId = r.intInventoryReceiptId
			WHERE	rc.intInventoryReceiptId = @intReceiptId
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
		)
		AND NOT EXISTS (SELECT TOP 1 1 FROM @voucherOtherCharges) 
	) 
	BEGIN 
		-- 'The other charges in {Receipt Number} are not allowed to be converted to Voucher. It could be a DP or Zero Spot Priced.'
		EXEC uspICRaiseError 80227, @strReceiptNumber; 
		RETURN -80227; 
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
			,@voucherDate = @dtmReceiptDate

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