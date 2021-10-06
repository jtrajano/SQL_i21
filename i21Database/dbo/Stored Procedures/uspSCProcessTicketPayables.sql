CREATE PROCEDURE [dbo].[uspSCProcessTicketPayables]
	@intTicketId INT,
	@intInventoryReceiptId INT,
	@intUserId INT,
	@ysnAdd BIT = 1,
	@strErrorMessage VARCHAR(MAX) = '' OUTPUT,
	@intBillId INT = NULL OUTPUT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DECLARE @voucherItems AS VoucherDetailReceipt 
	   ,@voucherOtherCharges AS VoucherDetailReceiptCharge	   
	   ,@voucherPayable as VoucherPayable
	   ,@voucherTaxDetail as VoucherDetailTax
	   ,@total AS INT
	   ,@prePayId AS Id	
IF OBJECT_ID (N'tempdb.dbo.#tmpReceiptItem') IS NOT NULL
	DROP TABLE #tmpReceiptItem;

CREATE TABLE #tmpReceiptItem (
	 [intInventoryReceiptItemId] INT PRIMARY KEY
	,[intInventoryReceiptId] INT
	,[intEntityVendorId] INT
	,[intContractDetailId] INT
	,[intPricingTypeId] INT
	,[ysnPosted] BIT
	,[strChargesLink] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL
	,[dblQtyReceived] NUMERIC(38,20)
	,[dblCost] NUMERIC(38,20)
	,[intOwnershipType] INT
	UNIQUE ([intInventoryReceiptItemId])
);

INSERT INTO #tmpReceiptItem(
	 [intInventoryReceiptItemId]
	,[intInventoryReceiptId]
	,[intEntityVendorId]
	,[intContractDetailId]
	,[intPricingTypeId]
	,[ysnPosted]
	,[strChargesLink]
	,[dblQtyReceived]
	,[dblCost]
	,[intOwnershipType]
)
SELECT 
	ri.intInventoryReceiptItemId
	,ri.intInventoryReceiptId
	,r.intEntityVendorId
	,CT.intContractDetailId 
	,ISNULL(CT.intPricingTypeId,0)
	,r.ysnPosted 
	,ri.strChargesLink
	,ri.dblOpenReceive - ri.dblBillQty
	,ri.dblUnitCost
	,ri.intOwnershipType
FROM tblICInventoryReceipt r 
INNER JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId AND ri.dblUnitCost > 0
LEFT JOIN tblCTContractDetail CT ON CT.intContractDetailId = ri.intLineNo
LEFT JOIN tblCTPriceFixation CTP ON CTP.intContractDetailId = CT.intContractDetailId
WHERE ri.intInventoryReceiptId = @intInventoryReceiptId AND ri.intOwnershipType = 1 AND CTP.intPriceFixationId IS NULL
	AND ri.ysnAllowVoucher = 1

/* GET VOUCHER ITEMS */

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
				WHEN ri.intOrderId > 0 THEN 2
				ELSE 1
			END 
			,[intInventoryReceiptItemId] = ri.intInventoryReceiptItemId
			,[dblQtyReceived] = ri.dblOpenReceive - ri.dblBillQty
			,[dblCost] = ri.dblUnitCost
			,[intTaxGroupId] = ri.intTaxGroupId
	FROM	tblICInventoryReceiptItem ri
			INNER JOIN #tmpReceiptItem tmp ON tmp.intInventoryReceiptItemId = ri.intInventoryReceiptItemId AND tmp.intPricingTypeId IN (0,1,6)
	WHERE	ri.intInventoryReceiptId = @intInventoryReceiptId
			AND tmp.intOwnershipType = 1
END

/* GET VOUCHER TAX DETAILS */
BEGIN
	INSERT INTO @voucherOtherCharges (
			[intInventoryReceiptChargeId]
			,[dblQtyReceived]
			,[dblCost]
			,[intTaxGroupId]
	)
	SELECT	
			[intInventoryReceiptChargeId] = rc.intInventoryReceiptChargeId
			,[dblQtyReceived] = rc.dblQuantity - ISNULL(-rc.dblQuantityPriced, 0)
			,[dblCost] = 
				CASE 
					WHEN rc.strCostMethod = 'Amount' THEN  rc.dblAmount
					ELSE rc.dblRate
				END 
			,[intTaxGroupId] = rc.intTaxGroupId
	FROM	#tmpReceiptItem tmp 
			INNER JOIN tblICInventoryReceiptCharge rc ON rc.intInventoryReceiptId = tmp.intInventoryReceiptId AND rc.strChargesLink = tmp.strChargesLink AND tmp.intPricingTypeId IN (0,1,6)
	WHERE	tmp.ysnPosted = 1
			AND tmp.intInventoryReceiptId = @intInventoryReceiptId
			AND tmp.intOwnershipType = 1
			AND 
			(
				(
					rc.ysnPrice = 1
					AND ISNULL(-rc.dblAmountPriced, 0) < rc.dblAmount
				)
				OR (
					rc.ysnAccrue = 1 
					AND tmp.intEntityVendorId = rc.intEntityVendorId 
					AND ISNULL(rc.dblAmountBilled, 0) < rc.dblAmount
				)
			)
END 

SELECT @total = COUNT(*) FROM @voucherItems;
IF (@total > 0)
BEGIN

	/* Build Payable entries */
	INSERT INTO @voucherPayable(
			[intTransactionType],
			[intItemId],
			[strMiscDescription],
			[intInventoryReceiptItemId],
			[dblQuantityToBill],
			[dblOrderQty],
			[dblExchangeRate],
			[intCurrencyExchangeRateTypeId],
			[ysnSubCurrency],
			[intAccountId],
			[dblCost],
			[dblOldCost],
			[dblNetWeight],
			[dblNetShippedWeight],
			[dblWeightLoss],
			[dblFranchiseWeight],
			[intContractDetailId],
			[intContractHeaderId],
			[intQtyToBillUOMId],
			[intCostUOMId],
			[intWeightUOMId],
			[intLineNo],
			[dblWeightUnitQty],
			[dblCostUnitQty],
			[dblQtyToBillUnitQty],
			[intCurrencyId],
			[intStorageLocationId],
			[int1099Form],
			[int1099Category],
			[intLoadShipmentDetailId],
			[strBillOfLading],
			[intScaleTicketId],
			[intLocationId],			
			[intShipFromId],
			[intShipToId],
			[intInventoryReceiptChargeId],
			[intPurchaseDetailId],
			[intPurchaseTaxGroupId],
			[dblTax],
			[intEntityVendorId],
			[strVendorOrderNumber],
			[intLoadShipmentId])
	EXEC [dbo].[uspSCGenerateVoucherDetails] @voucherItems,@voucherOtherCharges

	IF EXISTS(SELECT NULL FROM @voucherPayable)
		BEGIN
			INSERT INTO @voucherTaxDetail(
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
			SELECT	[intVoucherPayableId]
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
			FROM dbo.fnICGeneratePayablesTaxes(
					@voucherPayable
					,1
					,DEFAULT 
				)
			BEGIN 
				
				IF(@ysnAdd = 1) /* Create Voucher */
					EXEC [dbo].[uspAPCreateVoucher] @voucherPayables = @voucherPayable,@voucherPayableTax = @voucherTaxDetail, @userId = @intUserId,@throwError = 1, @error = @strErrorMessage OUT, @createdVouchersId = @intBillId OUT
				ELSE /*  Delete Voucher */
					BEGIN
						EXEC [dbo].[uspAPUpdateVoucherPayableQty] @voucherPayable = @voucherPayable,@voucherPayableTax = @voucherTaxDetail, @post = 0,@throwError = 1, @error = @strErrorMessage OUT
						EXEC [dbo].[uspAPRemoveVoucherPayable] @voucherPayable = @voucherPayable, @throwError = 1,@error= @strErrorMessage OUT
					END
			
			END
		END

	IF(ISNULL(@intBillId,0) != 0)
	BEGIN
		IF OBJECT_ID (N'tempdb.dbo.#tmpContractPrepay') IS NOT NULL
			DROP TABLE #tmpContractPrepay

		CREATE TABLE #tmpContractPrepay (
			[intPrepayId] INT
		);
		DECLARE @Ids as Id
		
		INSERT INTO @Ids(intId)
		SELECT CT.intContractHeaderId FROM #tmpReceiptItem tmp 
		INNER JOIN tblCTContractDetail CT ON CT.intContractDetailId = tmp.intContractDetailId
		GROUP BY CT.intContractHeaderId 

		INSERT INTO #tmpContractPrepay(
			[intPrepayId]
		) 
		SELECT intTransactionId FROM dbo.fnSCGetPrepaidIds(@Ids)
		
		SELECT @total = COUNT(intPrepayId) FROM #tmpContractPrepay where intPrepayId > 0;
		IF (@total > 0)
		BEGIN
			INSERT INTO @prePayId(
				[intId]
			)
			SELECT [intId] = intPrepayId
			FROM #tmpContractPrepay where intPrepayId > 0
			
			EXEC uspAPApplyPrepaid @intBillId, @prePayId
			update tblAPBillDetail set intScaleTicketId = @intTicketId WHERE intBillId = @intBillId
		END
	END
END