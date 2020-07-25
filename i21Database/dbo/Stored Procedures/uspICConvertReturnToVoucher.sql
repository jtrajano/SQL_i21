CREATE PROCEDURE [dbo].[uspICConvertReturnToVoucher]
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
		,@originalEntityVendorId AS INT 

		
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

DECLARE @Own AS INT = 1
		,@Storage AS INT = 2
		,@ConsignedPurchase AS INT = 3

SELECT	@intEntityVendorId = intEntityVendorId
		,@originalEntityVendorId = intEntityVendorId
		,@billTypeToUse = @type_DebitMemo
		,@intShipFrom = r.intShipFromId
		,@intShipTo = r.intLocationId
		,@strVendorRefNo = r.strVendorRefNo
		,@intCurrencyId = r.intCurrencyId
FROM	tblICInventoryReceipt r
WHERE	r.ysnPosted = 1
		AND r.intInventoryReceiptId = @intReceiptId		

-- Create the temp table if it does not exists. 
IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpReturnVendors')) 
BEGIN 
	CREATE TABLE #tmpReturnVendors (
		intEntityVendorId INT
		,intInventoryReceiptItemId INT
	)
END 

BEGIN 
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
			AND ISNULL(rtn.strReceiptType, '') = 'Inventory Return'

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
			,[intTransactionType]
			,[intLocationId]	
			,[intShipToId] = NULL	
			,[intShipFromId] = NULL	 		
			,[intShipFromEntityId] = NULL
			,[intPayToAddressId] = NULL
			,[intCurrencyId]					
			,[dtmDate]				
			,[strVendorOrderNumber]		
			,[strReference]						
			,[strSourceNumber]					
			,[intPurchaseDetailId]				
			,[intContractHeaderId]				
			,[intContractDetailId]				
			,[intContractSeqId] = intContractSequence					
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
		FROM dbo.fnICGeneratePayables (@intReceiptId, 1, 1)

		END 


		BEGIN 
			DELETE FROM @voucherItemsTax
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
		FROM	dbo.fnICGeneratePayablesTaxes(
					@voucherItems
					,@intReceiptId
					,DEFAULT 
				)
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
			SET @intReturnValue = -80110;
			GOTO Post_Exit;
		END 

		-- Call the AP sp to convert the Return to Debit Memo. 
		IF EXISTS (SELECT TOP 1 1 FROM @voucherItems)
		BEGIN 				
			DECLARE @throwedError AS NVARCHAR(1000);		
			SELECT @intShipFrom_DebitMemo = CASE WHEN @originalEntityVendorId = @intEntityVendorId THEN @intShipFrom ELSE NULL END 
			
			EXEC [dbo].[uspAPCreateVoucher]
				@voucherPayables = @voucherItems
				,@voucherPayableTax = @voucherItemsTax
				,@userId = @intEntityVendorId
				,@throwError = 0
				,@error = @throwedError OUTPUT
				,@createdVouchersId = @strBillIds OUTPUT

			--THIS ASSUMES THAT THE VOUCHER CREATED IS ONLY ONE
			SET @intBillId = CAST(@strBillIds AS INT)

			--EXEC [dbo].[uspAPCreateBillData]
			--	@userId = @intEntityUserSecurityId
			--	,@vendorId = @intEntityVendorId
			--	,@type = @billTypeToUse
			--	,@voucherDetailReceipt = @voucherItems
			--	,@shipTo = @intShipTo
			--	,@shipFrom = @intShipFrom_DebitMemo
			--	,@currencyId = @intCurrencyId
			--	,@throwError = 0
			--	,@error = NULL 			
			--	,@billId = @intBillId OUTPUT

			IF(@throwedError <> '')
			BEGIN
				RAISERROR(@throwedError, 16, 1);
				SET @intReturnValue = -89999;
				GOTO Post_Exit;
			END
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

Post_Exit:
IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpReturnVendors')) 
	DROP TABLE #tmpReturnVendors 

RETURN @intReturnValue; 