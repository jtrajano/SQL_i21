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

		,@voucherItems AS VoucherPayable
		--,@voucherItems AS VoucherDetailReceipt 
		--,@voucherOtherCharges AS VoucherDetailReceiptCharge 
		--,@voucherDetailClaim AS VoucherDetailClaim

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
			[intEntityVendorId]
			,[intTransactionType]
			,[intLocationId]
			,[intShipToId]
			,[intShipFromId]
			,[intCurrencyId]
			,[dtmVoucherDate]
			,[strVendorOrderNumber]
			--,[strReference]
			,[strSourceNumber]
			--,[intSubCurrencyCents]
			,[intShipViaId]
			--,[intTermId]
			,[strBillOfLading]
			--,[strCheckComment]
			--,[intAPAccount]
			
			/* Voucher Details */
			,[intItemId]
			,[ysnSubCurrency]
			,[intAccountId]
			,[ysnReturn]
			,[intLineNo]
			,[intStorageLocationId]
			--,[dblBasis]
			--,[dblFutures]
			,[intContractHeaderId]
			,[intContractDetailId]
			,[intContractSeqId]
			,[intInventoryReceiptItemId]
			/*Quantity info*/
			,[dblQuantityToBill]
			,[dblQtyToBillUnitQty]
			,[intQtyToBillUOMId]
			/*Cost info*/
			,[dblCost]
			,[dblCostUnitQty]
			,[intCostUOMId]
			/*Weight info*/
			,[dblWeight]
			,[dblNetWeight]
			,[dblWeightUnitQty]
			,[intWeightUOMId]
			/*Exchange Rate info*/
			,[intCurrencyExchangeRateTypeId]
			,[dblExchangeRate]
			/*Tax info*/
			,[intPurchaseTaxGroupId]
		)
		SELECT
				intEntityVendorId					= IR.intEntityVendorId
				,intTransactionType					= CASE WHEN IR.strReceiptType = 'Inventory Return' THEN 3 ELSE 1 END 
				,intLocationId						= IR.intLocationId
				,intShipToId						= IR.intLocationId
				,intShipFromId						= IR.intShipFromId
				,intCurrencyId						= IR.intCurrencyId
				,dtmVoucherDate						= IR.dtmReceiptDate
				,strVendorOrderNumber				= IR.strBillOfLading
				,strSourceNumber					= IR.strReceiptNumber
				,intShipViaId						= IR.intShipViaId
				,strBillOfLading					= IR.strBillOfLading
				/* Items */
				,intItemId							= IRI.intItemId
				,ysnSubCurrency						= IRI.ysnSubCurrency
				,intAccountId						= [dbo].[fnGetItemGLAccount](IRI.intItemId, ItemLoc.intItemLocationId, 'AP Clearing')
				,ysnReturn							= CAST(CASE WHEN IR.strReceiptType = 'Inventory Return' THEN 1 ELSE 0 END AS BIT)
				,intLineNo							= IRI.intSort
				,intStorageLocationId				= IRI.intStorageLocationId
				,intContractHeaderId				= contractDetail.intContractHeaderId
				,intContractDetailId				= contractDetail.intContractDetailId
				,intContractSeqId					= contractDetail.intContractSeq
				,intInventoryReceiptItemId			= IRI.intInventoryReceiptItemId
				,dblQuantityToBill					= CASE 
														WHEN  IR.strReceiptType = 'Inventory Return' THEN 
															-(IRI.dblOpenReceive - IRI.dblBillQty)
														ELSE 
															IRI.dblOpenReceive - IRI.dblBillQty
													END 
				,dblQtyToBillUnitQty				= ReceiptUOM.dblUnitQty
				,intQtyToBillUOMId					= IRI.intUnitMeasureId
				,dblCost							= IRI.dblUnitCost
				,dblCostUnitQty						= CostUOM.dblUnitQty
				,intCostUOMId						= IRI.intCostUOMId
				,dblWeight							= IRI.dblGross
				,dblNetWeight						= IRI.dblNet
				,dblWeightUnitQty					= WeightUOM.dblUnitQty
				,intWeightUOMId						= IRI.intWeightUOMId
				,intCurrencyExchangeRateTypeId		= IRI.intForexRateTypeId
				,dblExchangeRate					= IRI.dblForexRate
				,intPurchaseTaxGroupId				= IRI.intTaxGroupId

		FROM	tblICInventoryReceipt IR INNER JOIN tblICInventoryReceiptItem IRI
					ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
				INNER JOIN tblICItem Item 
					ON Item.intItemId = IRI.intItemId
				INNER JOIN tblICItemLocation ItemLoc
					ON ItemLoc.intLocationId = IR.intLocationId AND ItemLoc.intItemId = IRI.intItemId
				INNER JOIN tblICItemUOM ReceiptUOM
					ON ReceiptUOM.intItemUOMId = IRI.intUnitMeasureId AND ReceiptUOM.intItemId = Item.intItemId
				INNER JOIN tblICItemUOM CostUOM
					ON CostUOM.intItemUOMId = IRI.intCostUOMId AND CostUOM.intItemId = Item.intItemId
				LEFT JOIN tblICItemUOM WeightUOM
					ON WeightUOM.intItemUOMId = IRI.intWeightUOMId AND WeightUOM.intItemId = Item.intItemId
				LEFT JOIN vyuCTContractDetailView contractDetail 
					ON 	contractDetail.intContractHeaderId = IRI.intOrderId 
					AND contractDetail.intContractDetailId = IRI.intLineNo
		WHERE	IR.ysnPosted = 1
				AND IR.intInventoryReceiptId = @intReceiptId
				AND ABS(IRI.dblBillQty) < ABS(IRI.dblOpenReceive)
				AND IRI.intOwnershipType = @Own
				AND Item.strType <> 'Bundle'
				AND ISNULL(IR.strReceiptType, '') <> 'Transfer Order'
				AND 1 = 
					CASE 
						WHEN @intScreenId = @intScreenId_InventoryReceipt AND IRI.ysnAllowVoucher = 0 THEN 
							0
						ELSE 
							1
					END 
	END 

	-- Assemble the Other Charges
	BEGIN
		INSERT INTO @voucherItems (
			[intEntityVendorId]
			,[intTransactionType]
			,[intLocationId]
			,[intShipToId]
			,[intShipFromId]
			,[intCurrencyId]
			,[dtmVoucherDate]
			,[strVendorOrderNumber]
			--,[strReference]
			,[strSourceNumber]
			,[intShipViaId]
			,[strBillOfLading]
			
			/* Voucher Details */
			,[intItemId]
			,[ysnSubCurrency]
			,[intAccountId]
			,[ysnReturn]
			,[intContractHeaderId]
			,[intContractDetailId]
			,[intContractSeqId]
			,[intInventoryReceiptChargeId]
			/*Quantity info*/
			,[dblQuantityToBill]
			,[dblQtyToBillUnitQty]
			,[intQtyToBillUOMId]
			/*Cost info*/
			,[dblCost]
			,[dblCostUnitQty]
			/*Exchange Rate info*/
			,[intCurrencyExchangeRateTypeId]
			,[dblExchangeRate]
			/*Tax info*/
			,[intPurchaseTaxGroupId]
		)
		SELECT	intEntityVendorId					= IR.intEntityVendorId
				,intTransactionType					= CASE WHEN IR.strReceiptType = 'Inventory Return' THEN 3 ELSE 1 END 
				,intLocationId						= IR.intLocationId
				,intShipToId						= IR.intLocationId
				,intShipFromId						= IR.intShipFromId
				,intCurrencyId						= IR.intCurrencyId
				,dtmVoucherDate						= IR.dtmReceiptDate
				,strVendorOrderNumber				= IR.strBillOfLading
				,strSourceNumber					= IR.strReceiptNumber
				,intShipViaId						= IR.intShipViaId
				,strBillOfLading					= IR.strBillOfLading
				/* Receipt Charges */
				,intItemId							= ReceiptCharges.intItemId
				,ysnSubCurrency						= ReceiptCharges.ysnSubCurrency
				,intAccountId						= ReceiptCharges.intAccountId
				,ysnReturn							= CAST(CASE WHEN IR.strReceiptType = 'Inventory Return' THEN 1 ELSE 0 END AS BIT)
				,intContractHeaderId				= ReceiptCharges.intContractHeaderId
				,intContractDetailId				= ReceiptCharges.intContractDetailId
				,intContractSeqId					= ReceiptCharges.intContractSeq
				,intInventoryReceiptChargeId		= ReceiptCharges.intInventoryReceiptChargeId
				/*Quantity info*/
				,dblQuantityToBill					= CASE 
														WHEN  tblRC.ysnPrice = 1 THEN 
															tblRC.dblQuantity - ISNULL(-tblRC.dblQuantityPriced, 0) 
														ELSE 
															tblRC.dblQuantity - ISNULL(tblRC.dblQuantityBilled, 0) 
													END
				,dblQtyToBillUnitQty				= 1
				,intQtyToBillUOMId					= ReceiptCharges.intCostUnitMeasureId
				/*Cost info*/
				,dblCost							= 1--CASE 
														--WHEN tblRC.strCostMethod = 'Per Unit' THEN tblRC.dblRate
														--WHEN tblRC.strCostMethod = 'Gross Unit' THEN tblRC.dblRate
														--ELSE tblRC.dblAmount
													--END
				,dblCostUnitQty						= 1
				/*Exchange Rate info*/
				,intCurrencyExchangeRateTypeId		= ReceiptCharges.intForexRateTypeId
				,dblExchangeRate					= ReceiptCharges.dblForexRate
				/*Tax info*/
				,intPurchaseTaxGroupId				= ReceiptCharges.intTaxGroupId
		FROM vyuICChargesForBilling ReceiptCharges
		INNER JOIN tblICInventoryReceiptCharge tblRC
			ON tblRC.intInventoryReceiptChargeId = ReceiptCharges.intInventoryReceiptChargeId
		INNER JOIN tblICInventoryReceipt IR 
			ON IR.intInventoryReceiptId = ReceiptCharges.intInventoryReceiptId
			AND IR.intEntityVendorId = ReceiptCharges.intEntityVendorId
		WHERE IR.intInventoryReceiptId = @intReceiptId 
			AND IR.ysnPosted = 1
			AND ISNULL(IR.strReceiptType, '') <> 'Transfer Order'
			AND 1 = 
					CASE 
						WHEN @intScreenId = @intScreenId_InventoryReceipt AND tblRC.ysnAllowVoucher = 0 THEN 
							0
						ELSE 
							1
					END

		--SELECT	
		--		[intInventoryReceiptChargeId] = rc.intInventoryReceiptChargeId
		--		,[dblQtyReceived] = 
		--			CASE 
		--				WHEN rc.ysnPrice = 1 THEN 
		--					rc.dblQuantity - ISNULL(-rc.dblQuantityPriced, 0) 
		--				ELSE 
		--					rc.dblQuantity - ISNULL(rc.dblQuantityBilled, 0) 
		--			END 

		--		,[dblCost] = 
		--			CASE 
		--				WHEN rc.strCostMethod = 'Per Unit' THEN rc.dblRate
		--				WHEN rc.strCostMethod = 'Gross Unit' THEN rc.dblRate
		--				ELSE rc.dblAmount
		--			END 
		--		,[intTaxGroupId] = rc.intTaxGroupId
		--FROM	tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptCharge rc
		--			ON r.intInventoryReceiptId = rc.intInventoryReceiptId
		--WHERE	r.ysnPosted = 1
		--		AND r.intInventoryReceiptId = @intReceiptId
		--		AND ISNULL(r.strReceiptType, '') <> 'Transfer Order'
		--		AND 
		--		(
		--			(
		--				rc.ysnPrice = 1
		--				AND ISNULL(-rc.dblAmountPriced, 0) < rc.dblAmount
		--			)
		--			OR (
		--				rc.ysnAccrue = 1 
		--				AND r.intEntityVendorId = ISNULL(rc.intEntityVendorId, r.intEntityVendorId) 
		--				AND ISNULL(rc.dblAmountBilled, 0) < rc.dblAmount
		--			)
		--		)
		--		AND 1 = 
		--			CASE 
		--				WHEN @intScreenId = @intScreenId_InventoryReceipt AND rc.ysnAllowVoucher = 0 THEN 
		--					0
		--				ELSE 
		--					1
		--			END
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
		AND NOT EXISTS (SELECT TOP 1 1 FROM @voucherItems WHERE intInventoryReceiptItemId IS NOT NULL) 
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
		AND NOT EXISTS (SELECT TOP 1 1 FROM @voucherItems WHERE intInventoryReceiptChargeId IS NOT NULL) 
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
		SELECT TOP 1 1 FROM @voucherItems WHERE intInventoryReceiptChargeId IS NOT NULL
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

		--EXEC [dbo].[uspAPCreateBillData]
		--	@userId = @intEntityUserSecurityId
		--	,@vendorId = @intEntityVendorId
		--	,@type = @billTypeToUse
		--	,@voucherDetailReceipt = @voucherItems
		--	,@voucherDetailReceiptCharge = @voucherOtherCharges
		--	,@shipTo = @intShipTo
		--	,@shipFrom = @intShipFrom
		--	,@vendorOrderNumber = @strVendorRefNo
		--	,@currencyId = @intCurrencyId
		--	,@throwError = 0
		--	,@error = @throwedError OUTPUT
		--	,@billId = @intBillId OUTPUT
		--	,@voucherDate = @dtmReceiptDate


		EXEC [dbo].[uspAPCreateVoucher]
			@voucherPayables = @voucherItems
			,@userId = @intEntityVendorId
			,@throwError = 0
			,@error = @throwedError OUTPUT
			,@createdVouchersId = @intBillId OUTPUT

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