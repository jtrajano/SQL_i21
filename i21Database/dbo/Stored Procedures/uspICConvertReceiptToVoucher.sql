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
		,@voucherItemsTax AS VoucherDetailTax
		--,@voucherItems AS VoucherDetailReceipt 
		--,@voucherOtherCharges AS VoucherDetailReceiptCharge 
		--,@voucherDetailClaim AS VoucherDetailClaim

		,@intShipFrom AS INT
		,@intShipTo AS INT 
		,@strVendorRefNo NVARCHAR(50)
		,@intCurrencyId AS INT 

		,@intShipFrom_DebitMemo AS INT
		,@intReturnValue AS INT


DECLARE @ReceiptType INT = 4;

DECLARE @SourceType_NONE AS INT = 0
		,@SourceType_SCALE AS INT = 1
		,@SourceType_INBOUND_SHIPMENT AS INT = 2
		,@SourceType_TRANSPORT AS INT = 3
		,@SourceType_SETTLE_STORAGE AS INT = 4
		,@SourceType_DELIVERY_SHEET AS INT = 5
		,@SourceType_PURCHASE_ORDER AS INT = 6
		,@SourceType_STORE AS INT = 7

DECLARE @ItemType_OtherCharge AS NVARCHAR(50) = 'Other Charge';

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
		INSERT INTO @voucherItems(
			[intEntityVendorId]			
			,[intTransactionType]		
			,[intLocationId]	
			,[intShipToId]	
			,[intShipFromId]			
			,[intShipFromEntityId]
			,[intPayToAddressId]
			,[intCurrencyId]					
			,[dtmDate]				
			,[strVendorOrderNumber]			
			,[strReference]						
			,[strSourceNumber]					
			,[intPurchaseDetailId]				
			,[intContractHeaderId]				
			,[intContractDetailId]				
			,[intContractSeqId]					
			,[intScaleTicketId]					
			,[intInventoryReceiptItemId]		
			,[intInventoryReceiptChargeId]		
			,[intInventoryShipmentItemId]		
			,[intInventoryShipmentChargeId]		
			,[intLoadShipmentId]				
			,[intLoadShipmentDetailId]			
			,[intItemId]						
			,[intPurchaseTaxGroupId]			
			,[strMiscDescription]				
			,[dblOrderQty]						
			,[dblOrderUnitQty]					
			,[intOrderUOMId]					
			,[dblQuantityToBill]				
			,[dblQtyToBillUnitQty]				
			,[intQtyToBillUOMId]				
			,[dblCost]							
			,[dblCostUnitQty]					
			,[intCostUOMId]						
			,[dblNetWeight]						
			,[dblWeightUnitQty]					
			,[intWeightUOMId]					
			,[intCostCurrencyId]
			,[dblTax]							
			,[dblDiscount]
			,[intCurrencyExchangeRateTypeId]	
			,[dblExchangeRate]					
			,[ysnSubCurrency]					
			,[intSubCurrencyCents]				
			,[intAccountId]						
			,[intShipViaId]						
			,[intTermId]						
			,[strBillOfLading]					
			,[ysnReturn]						
	)
	SELECT 
		[intEntityVendorId]			
		,[intTransactionType] = @ReceiptType
		,[intLocationId]	
		,[intShipToId] = NULL	
		,[intShipFromId] = NULL	 		
		,[intShipFromEntityId] = NULL
		,[intPayToAddressId] = NULL
		,[intCurrencyId]					
		,[dtmDate]				
		,[strVendorOrderNumber]	= NULL		
		,[strReference]						
		,[strSourceNumber]					
		,[intPurchaseDetailId]				
		,[intContractHeaderId]				
		,[intContractDetailId]				
		,[intContractSeqId] = NULL					
		,[intScaleTicketId]					
		,[intInventoryReceiptItemId]		
		,[intInventoryReceiptChargeId]		
		,[intInventoryShipmentItemId]		
		,[intInventoryShipmentChargeId]		
		,[intLoadShipmentId] = NULL				
		,[intLoadShipmentDetailId] = NULL			
		,[intItemId]						
		,[intPurchaseTaxGroupId]			
		,[strMiscDescription]				
		,[dblOrderQty]						
		,[dblOrderUnitQty] = 0.00					
		,[intOrderUOMId] = NULL	 				
		,[dblQuantityToBill]			
		,[dblQtyToBillUnitQty]				
		,[intQtyToBillUOMId]				
		,[dblCost] = dblUnitCost							
		,[dblCostUnitQty]					
		,[intCostUOMId]						
		,[dblNetWeight]						
		,[dblWeightUnitQty]					
		,[intWeightUOMId]					
		,[intCostCurrencyId]
		,[dblTax]							
		,[dblDiscount]
		,[intCurrencyExchangeRateTypeId]	
		,[dblExchangeRate] = dblRate					
		,[ysnSubCurrency]					
		,[intSubCurrencyCents]				
		,[intAccountId]						
		,[intShipViaId]						
		,[intTermId]						
		,[strBillOfLading]					
		,[ysnReturn]	 
	FROM dbo.fnICGeneratePayables (@intReceiptId, 1)
		
	END 

	-- Assemble Item Taxes
	BEGIN
		INSERT INTO @voucherItemsTax(
			[intVoucherPayableId]
			,[intTaxGroupId]				
			,[intTaxCodeId]				
			,[intTaxClassId]				
			,[strTaxableByOtherTaxes]	
			,[strCalculationMethod]		
			,[dblRate]					
			,[intAccountId]				
			,[dblTax]					
			,[dblAdjustedTax]			
			,[ysnTaxAdjusted]			
			,[ysnSeparateOnBill]			
			,[ysnCheckOffTax]		
			,[ysnTaxExempt]	
			,[ysnTaxOnly]
		)
		SELECT [intVoucherPayableId]
				,[intTaxGroupId]				
				,[intTaxCodeId]				
				,[intTaxClassId]				
				,[strTaxableByOtherTaxes]	
				,[strCalculationMethod]		
				,[dblRate]					
				,[intAccountId]				
				,[dblTax]					
				,[dblAdjustedTax]			
				,[ysnTaxAdjusted]			
				,[ysnSeparateOnBill]			
				,[ysnCheckOffTax]		
				,[ysnTaxExempt]	
				,[ysnTaxOnly]	
		FROM dbo.fnICGeneratePayablesTaxes(@voucherItems)
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
		--SELECT 'Convert IR to Voucher @voucherItems',* FROM @voucherItems;


		EXEC [dbo].[uspAPCreateVoucher]
			@voucherPayables = @voucherItems
			,@voucherPayableTax = @voucherItemsTax
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