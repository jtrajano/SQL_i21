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
		,@receiptType AS NVARCHAR(50) 
		,@originalEntityVendorId AS INT 

		,@voucherItems AS VoucherDetailReceipt 
		,@voucherOtherCharges AS VoucherDetailReceiptCharge 
		,@voucherDetailClaim AS VoucherDetailClaim

		,@intShipFrom AS INT
		,@intShipTo AS INT 
		,@strVendorRefNo NVARCHAR(50)
		,@intCurrencyId AS INT 

		,@intShipFrom_DebitMemo AS INT

DECLARE @Own AS INT = 1
		,@Storage AS INT = 2
		,@ConsignedPurchase AS INT = 3

SELECT	@intEntityVendorId = intEntityVendorId
		,@originalEntityVendorId = intEntityVendorId
		,@billTypeToUse = 
			CASE 
				WHEN r.strReceiptType = 'Inventory Return' THEN @type_DebitMemo
				ELSE @type_Voucher 
			END
		,@intShipFrom = r.intShipFromId
		,@intShipTo = r.intLocationId
		,@strVendorRefNo = r.strVendorRefNo
		,@intCurrencyId = r.intCurrencyId
		,@receiptType = r.strReceiptType
FROM	tblICInventoryReceipt r
WHERE	r.ysnPosted = 1
		AND r.intInventoryReceiptId = @intReceiptId
		AND ISNULL(r.strReceiptType, '') <> 'Transfer Order'

IF @receiptType = 'Inventory Return'
BEGIN 
	-- Create the temp table if it does not exists. 
	IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpReturnVendors')) 
	BEGIN 
		CREATE TABLE #tmpReturnVendors (
			intEntityVendorId INT
			,intInventoryReceiptItemId INT
		)
	END 

	-- Get the vendor to use for the voucher. 
	-- Contract Sequence has a 'Check Claims' setup that allows an item to be returned to the producer instead of the receipt vendor. 
	INSERT INTO #tmpReturnVendors (
		intEntityVendorId
		,intInventoryReceiptItemId
	)
	SELECT  intEntityVendorId = ISNULL(contractSequence.intProducerId, rtn.intEntityVendorId)
			,rtnItem.intInventoryReceiptItemId
	FROM	tblICInventoryReceipt rtn INNER JOIN tblICInventoryReceiptItem rtnItem
				ON rtn.intInventoryReceiptId = rtnItem.intInventoryReceiptId
			INNER JOIN tblICInventoryReceiptItem receiptItem
				ON receiptItem.intInventoryReceiptItemId = rtnItem.intSourceInventoryReceiptItemId
			INNER JOIN tblICInventoryReceipt receipt
				ON receipt.intInventoryReceiptId = receiptItem.intInventoryReceiptId
			LEFT JOIN tblCTContractDetail contractSequence
				ON receipt.strReceiptType = 'Purchase Contract'				
				AND contractSequence.intContractDetailId = rtnItem.intLineNo
				AND contractSequence.intContractHeaderId = rtnItem.intOrderId
				AND contractSequence.ysnClaimsToProducer = 1
	WHERE	rtn.ysnPosted = 1
			AND rtn.intInventoryReceiptId = @intReceiptId
			AND rtnItem.intOwnershipType = @Own			

	DECLARE loopVendor CURSOR LOCAL FAST_FORWARD 
	FOR 
	SELECT	DISTINCT 
			intEntityVendorId 
	FROM	#tmpReturnVendors

	-- Open the cursor 
	OPEN loopVendor;

	-- First data row fetch from the cursor 
	FETCH NEXT FROM loopVendor INTO @intEntityVendorId;

	-- Begin Loop
	WHILE @@FETCH_STATUS = 0
	BEGIN 
		-- Assemble the voucher items 
		BEGIN 
			DELETE FROM @voucherItems
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
					INNER JOIN #tmpReturnVendors rtnVendor
						ON rtnVendor.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
			WHERE	r.ysnPosted = 1
					AND r.intInventoryReceiptId = @intReceiptId
					AND ri.dblBillQty < ri.dblOpenReceive 
					AND ri.intOwnershipType = @Own
					AND rtnVendor.intEntityVendorId = @intEntityVendorId
		END 

		-- Check if we can convert the RTN to Debit Memo
		IF NOT EXISTS (
			SELECT	TOP 1 1 
			FROM	tblICInventoryReceiptItem ri INNER JOIN @voucherItems vi
						ON ri.intInventoryReceiptItemId = vi.intInventoryReceiptItemId
			WHERE	ISNULL(ri.dblOpenReceive, 0) <> ISNULL(ri.dblBillQty, 0)
		)
		BEGIN 
			-- Debit Memo is no longer needed. All items have Debit Memo.
			EXEC uspICRaiseError 80110;			
			RETURN -80110;
		END 

		-- Call the AP sp to convert the Return to Debit Memo. 
		IF EXISTS (SELECT TOP 1 1 FROM @voucherItems)
		BEGIN 						
			SELECT @intShipFrom_DebitMemo = CASE WHEN @originalEntityVendorId = @intEntityVendorId THEN @intShipFrom ELSE NULL END 

			EXEC [dbo].[uspAPCreateBillData]
				@userId = @intUserId
				,@vendorId = @intEntityVendorId
				,@type = @billTypeToUse
				,@voucherDetailReceipt = @voucherItems
				,@shipTo = @intShipTo
				,@shipFrom = @intShipFrom_DebitMemo
				,@currencyId = @intCurrencyId
				,@throwError = 0
				,@error = NULL 			
				,@billId = @intBillId OUTPUT

			SELECT @strBillIds = 
				ISNULL(@strBillIds, '') + 
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

		FETCH NEXT FROM loopVendor INTO @intEntityVendorId;
	END 
	CLOSE loopVendor;
	DEALLOCATE loopVendor;
END 
ELSE 
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
		RETURN -80111;
	END 

	-- Call the AP sp to convert the IR to Voucher. 
	BEGIN 
		DECLARE @throwedError AS NVARCHAR(1000);

		EXEC [dbo].[uspAPCreateBillData]
			@userId = @intUserId
			,@vendorId = @intEntityVendorId
			,@type = @billTypeToUse
			,@voucherDetailReceipt = @voucherItems
			,@voucherDetailReceiptCharge = @voucherOtherCharges
			,@shipTo = @intShipTo
			,@shipFrom = @intShipFrom
			,@vendorOrderNumber = @strVendorRefNo
			,@currencyId = @intCurrencyId
			,@throwError = 0
			,@error = NULL 			
			,@error = @throwedError OUTPUT
			,@billId = @intBillId OUTPUT

		IF(@throwedError <> '')
		BEGIN
			RAISERROR(@throwedError,16,1);
			GOTO Post_Exit;
		END
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
END 


-- Drop the temp table. 
Post_Exit:
IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpReturnVendors')) 
	DROP TABLE #tmpReturnVendors 
