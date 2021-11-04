CREATE PROCEDURE [dbo].[uspICAddProRatedReceiptChargesToVoucher]
	@intInventoryReceiptItemId AS INT 
	,@intBillId INT
	,@intBillDetailId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DECLARE @voucherDetailReceiptCharge AS [VoucherDetailReceiptCharge] 
		,@intInventoryReceiptId AS INT
		,@intContractHeaderId AS INT
		,@intContractDetailId AS INT 
		,@strChargesLink AS NVARCHAR(50)		
		,@strBillId AS NVARCHAR(50) 
		,@intItemUOMIdIR AS INT
		,@intItemUOMIdVoucher AS INT
		,@dblOpenReceive AS NUMERIC(38, 20) 
		,@dblBilledQty AS NUMERIC(38, 20) 
		,@dblRatio AS NUMERIC(38, 20) 

-- Get the data that will allow us to compute the pro-rate. 
BEGIN 
	SELECT 
		@intInventoryReceiptId = r.intInventoryReceiptId
		,@intContractHeaderId = ri.intContractHeaderId
		,@intContractDetailId  = ri.intContractDetailId
		,@strChargesLink = ri.strChargesLink	
		,@strBillId = b.strBillId
		,@intItemUOMIdIR = ri.intUnitMeasureId
		,@intItemUOMIdVoucher = bd.intUnitOfMeasureId
		,@dblOpenReceive = ri.dblOpenReceive
		,@dblBilledQty = bd.dblQtyReceived
		,@dblRatio = 
			dbo.fnDivide(
				dbo.fnCalculateQtyBetweenUOM(
					bd.intUnitOfMeasureId
					,ri.intUnitMeasureId
					,bd.dblQtyReceived
				)
				, ri.dblOpenReceive
			) 
	FROM 
		tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
			ON r.intInventoryReceiptId = ri.intInventoryReceiptId
		INNER JOIN tblAPBillDetail bd
			ON bd.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
		INNER JOIN tblAPBill b
			ON b.intBillId = bd.intBillId
	WHERE
		ri.intInventoryReceiptItemId = @intInventoryReceiptItemId
		AND bd.intBillId = @intBillId
		AND bd.intBillDetailId = @intBillDetailId	
		AND r.ysnPosted = 1
END 

-- Assemble the 'Other Charges' that will be inserted into Voucher
BEGIN 
	DECLARE @receiptCharges AS TABLE (
		[intInventoryReceiptChargeId] INT 
		,[dblQtyReceived] NUMERIC(38, 20)
		,[dblCost] NUMERIC(38, 20)
		,[dblAmountToBill] NUMERIC(38, 20)
		,[intTaxGroupId] INT 
		,[intItemId] INT
		,[intItemUOMId] INT	NULL 
		,[intEntityVendorId] INT NULL 
	)

	INSERT INTO @receiptCharges (
		[intInventoryReceiptChargeId]
		,[dblQtyReceived]
		,[dblCost]
		,[dblAmountToBill]
		,[intTaxGroupId]
		,[intItemId]
		,[intItemUOMId]
		,[intEntityVendorId]
	)

	SELECT 
		rc.intInventoryReceiptChargeId
		,[dblQtyReceived]  = 
			CASE 
				WHEN rc.strCostMethod IN ('Amount', 'Percentage') THEN 			
					1
				ELSE 
					dbo.fnMultiply(rc.dblQuantity, @dblRatio)
			END 
		,[dblCost]  = 
			CASE 
				WHEN rc.strCostMethod IN ('Amount', 'Percentage') THEN 			
					ROUND(dbo.fnMultiply(rc.dblAmount, @dblRatio), 2) 
				ELSE
					rc.dblRate				
			END 
		,[dblAmountToBill] = 
			CASE 
				WHEN rc.strCostMethod IN ('Amount', 'Percentage') THEN 			
					ROUND(dbo.fnMultiply(rc.dblAmount, @dblRatio), 2) 
				ELSE
					ROUND(
						dbo.fnMultiply(
							dbo.fnMultiply(rc.dblQuantity, @dblRatio)
							,rc.dblRate
						)
						, 2
					) 
			END 			
		,[intTaxGroupId] = rc.intTaxGroupId
		,[intItemId] = rc.intChargeId
		,[intItemUOMId] = rc.intCostUOMId
		,[intEntityVendorId] = r.intEntityVendorId
	FROM 
		tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptCharge rc
			ON r.intInventoryReceiptId = rc.intInventoryReceiptId
	WHERE
		rc.intInventoryReceiptId = @intInventoryReceiptId	
		AND ISNULL(rc.intContractId, 0) = ISNULL(@intContractHeaderId, 0)
		AND ISNULL(rc.intContractDetailId, 0) = ISNULL(@intContractDetailId, 0)
		AND ISNULL(rc.strChargesLink, '') = ISNULL(@strChargesLink, '')
		--AND rc.ysnAllowVoucher = 0 

	INSERT INTO @voucherDetailReceiptCharge (
		[intInventoryReceiptChargeId]
		,[dblQtyReceived]
		,[dblCost]
		,[intTaxGroupId]
	)
	SELECT 
		[intInventoryReceiptChargeId]
		,[dblQtyReceived]
		,[dblCost]
		,[intTaxGroupId]
	FROM 
		@receiptCharges
END

-- Call the AP sp to insert the other charges into an existing voucher. 
IF EXISTS (SELECT TOP 1 1 FROM @voucherDetailReceiptCharge)
BEGIN 
	EXEC uspAPCreateVoucherDetailReceiptCharge  
		@voucherId = @intBillId
		,@voucherDetailReceiptCharge = @voucherDetailReceiptCharge
END 

-- Update the billed qty for newly inserted IR -> Charges. 
IF EXISTS (SELECT TOP 1 1 FROM @receiptCharges) 
BEGIN 
	DECLARE @receiptDetails	AS [InventoryUpdateBillQty]

	INSERT INTO @receiptDetails
	(
		[intInventoryReceiptItemId]
		,[intInventoryReceiptChargeId]
		,[intInventoryShipmentChargeId]
		,[intSourceTransactionNoId]
		,[strSourceTransactionNo]
		,[intItemId]
		,[intToBillUOMId]
		,[dblToBillQty]
		,[dblAmountToBill]
		,[intEntityVendorId]
	)
	SELECT 
		[intInventoryReceiptItemId] = @intInventoryReceiptItemId 
		,[intInventoryReceiptChargeId] = rc.intInventoryReceiptChargeId
		,[intInventoryShipmentChargeId] = NULL 
		,[intSourceTransactionNoId] = @intBillId
		,[strSourceTransactionNo] = @strBillId
		,[intItemId] = rc.intItemId
		,[intToBillUOMId] = rc.intItemUOMId
		,[dblToBillQty] = rc.dblQtyReceived
		,[dblAmountToBill] = 
			CASE 
				WHEN SIGN(A.dblQuantityToBill) = -1 THEN -rc.dblAmountToBill
				ELSE rc.dblAmountToBill
			END 
		,[intEntityVendorId] = rc.intEntityVendorId
	FROM 
		@receiptCharges rc INNER JOIN [vyuICChargesForBilling] A	
			ON rc.intInventoryReceiptChargeId = A.intInventoryReceiptChargeId
	ORDER BY 
		rc.intInventoryReceiptChargeId

	EXEC uspICUpdateBillQty @updateDetails = @receiptDetails
END