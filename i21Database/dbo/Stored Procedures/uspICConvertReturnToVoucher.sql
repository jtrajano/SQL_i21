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
				,dblQuantityToBill					= IRI.dblOpenReceive - IRI.dblBillQty 
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
				INNER JOIN #tmpReturnVendors rtnVendor
					ON rtnVendor.intInventoryReceiptItemId = IRI.intInventoryReceiptItemId
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
					AND IRI.dblBillQty < IRI.dblOpenReceive 
					AND IRI.intOwnershipType = @Own
					AND rtnVendor.intEntityVendorId = @intEntityVendorId
					AND ISNULL(IR.strReceiptType, '') = 'Inventory Return'
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
		FROM dbo.fnICGeneratePayablesTaxes(@voucherItems)
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
				,@createdVouchersId = @intBillId OUTPUT

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