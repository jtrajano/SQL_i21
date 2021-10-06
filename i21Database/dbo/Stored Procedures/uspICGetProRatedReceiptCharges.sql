CREATE PROCEDURE [dbo].[uspICGetProRatedReceiptCharges]
	@intInventoryReceiptItemId AS INT 
	,@intBillUOMId AS INT 
	,@dblQtyBilled AS NUMERIC(18, 6)
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
		,@intItemUOMIdIR AS INT
		,@intItemUOMIdVoucher AS INT
		,@dblOpenReceive AS NUMERIC(38, 20) 
		,@dblBilledQty AS NUMERIC(38, 20) 
		,@dblRatio AS NUMERIC(38, 20) 
		
DECLARE 
		@SourceType_STORE AS INT = 7		 
		, @type_Voucher AS INT = 1
		, @type_DebitMemo AS INT = 3
		, @billTypeToUse INT
		, @ItemType_OtherCharge AS NVARCHAR(50) = 'Other Charge'

-- Get the data that will allow us to compute the pro-rate. 
BEGIN 
	SELECT 
		@intInventoryReceiptId = r.intInventoryReceiptId
		,@intContractHeaderId = ri.intContractHeaderId
		,@intContractDetailId  = ri.intContractDetailId
		,@strChargesLink = ri.strChargesLink	
		,@intItemUOMIdIR = ri.intUnitMeasureId
		,@intItemUOMIdVoucher = @intBillUOMId
		,@dblOpenReceive = ri.dblOpenReceive
		,@dblBilledQty = @dblQtyBilled
		,@dblRatio = 
			dbo.fnDivide(
				dbo.fnCalculateQtyBetweenUOM(
					@intBillUOMId
					,ri.intUnitMeasureId
					,@dblQtyBilled
				)
				, ri.dblOpenReceive
			) 
		,@billTypeToUse = 
			CASE 
				WHEN dbo.fnICGetReceiptTotals(r.intInventoryReceiptId, 6) < 0 THEN --AND r.intSourceType = @SourceType_STORE THEN 
					@type_DebitMemo
				ELSE 
					@type_Voucher
			END 
		
	FROM 
		tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
			ON r.intInventoryReceiptId = ri.intInventoryReceiptId
	WHERE
		ri.intInventoryReceiptItemId = @intInventoryReceiptItemId
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


BEGIN 
	-- Generate Payables
	DECLARE @voucherPayable VoucherPayable

	INSERT INTO @voucherPayable(
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
		--,[strLoadShipmentNumber]
		,[intLoadShipmentId]				
		,[intLoadShipmentDetailId]	
		,[intLoadShipmentCostId]		
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
		,[intFreightTermId]				
		,[strBillOfLading]					
		,[ysnReturn]
		,[ysnStage]
		,[dblRatio]
	)
	SELECT
		[intEntityVendorId]	= A.intEntityVendorId
		,[intTransactionType] = CASE WHEN A.strReceiptType = 'Inventory Return' THEN 3 ELSE ISNULL(@billTypeToUse, 1) END 
		,[intLocationId] = A.intLocationId
		,[intShipToId] = A.intLocationId
		,[intShipFromId] = r.intShipFromId
		,[intShipFromEntityId] = r.intShipFromEntityId
		,[intPayToAddressId] = payToAddress.intEntityLocationId
		,[intCurrencyId] = A.intCurrencyId
		,[dtmDate]	= A.dtmDate
		,[strVendorOrderNumber] = ISNULL(NULLIF(LTRIM(RTRIM(r.strBillOfLading)), ''), r.strVendorRefNo) 
		,[strReference] = r.strVendorRefNo
		,[strSourceNumber] = A.strSourceNumber			
		,[intPurchaseDetailId] = NULL --PurchaseOrder.intPurchaseDetailId
		,[intContractHeaderId] = A.intContractHeaderId				
		,[intContractDetailId] = A.intContractDetailId
		,[intContractSeqId] = A.intContractSeq
		,[intScaleTicketId] = A.intScaleTicketId
		,[intInventoryReceiptItemId] = A.intInventoryReceiptItemId
		,[intInventoryReceiptChargeId] = A.intInventoryReceiptChargeId
		,[intInventoryShipmentItemId] = NULL 
		,[intInventoryShipmentChargeId] = NULL 		
		--,[strLoadShipmentNumber]
		,[intLoadShipmentId] = A.intLoadShipmentId				
		,[intLoadShipmentDetailId] = NULL 
		,[intLoadShipmentCostId] = A.intLoadShipmentCostId
		,[intItemId] = A.intItemId						
		,[intPurchaseTaxGroupId] = A.intTaxGroupId
		,[strMiscDescription] = A.strMiscDescription
		,[dblOrderQty]	= 
			CASE 
				WHEN @billTypeToUse = @type_DebitMemo AND A.intEntityVendorId = r.intEntityVendorId THEN 						
					-A.dblOrderQty
				ELSE 
					A.dblOrderQty
			END 	

		,[dblOrderUnitQty] = 0.00
		,[intOrderUOMId] = NULL 
		,[dblQuantityToBill] = 	
				CASE 
					WHEN @billTypeToUse = @type_DebitMemo AND A.intEntityVendorId = r.intEntityVendorId THEN 						
						CASE 
							WHEN A.strCostMethod IN ('Amount', 'Percentage') THEN 
								-A.dblOrderQty
							ELSE 
								-dbo.fnMultiply(A.dblOrderQty, @dblRatio)
						END 
					ELSE 
						CASE 
							WHEN A.strCostMethod IN ('Amount', 'Percentage') THEN 
								A.dblOrderQty
							ELSE 
								dbo.fnMultiply(A.dblOrderQty, @dblRatio)
						END 
				END 
		,[dblQtyToBillUnitQty] = 1				
		,[intQtyToBillUOMId] = A.intCostUnitMeasureId 				
		,[dblCost] = 
			CASE 
				WHEN A.strCostMethod IN ('Per Unit', 'Gross Unit') THEN 					
					rc.dblRate
				ELSE 
					ROUND(dbo.fnMultiply(rc.dblAmount, @dblRatio), 2)
					--CASE 
					--	WHEN @billTypeToUse = @type_DebitMemo AND A.intEntityVendorId = r.intEntityVendorId THEN 
					--		-ROUND(dbo.fnMultiply(rc.dblAmount, @dblRatio), 2)
					--	ELSE 
					--		ROUND(dbo.fnMultiply(rc.dblAmount, @dblRatio), 2)
					--END 
			END
		,[dblCostUnitQty] = CAST(1 AS DECIMAL(38,20))					
		,[intCostUOMId]	= A.intCostUnitMeasureId					
		,[dblNetWeight] = CAST(0 AS DECIMAL(38,20))
		,[dblWeightUnitQty] = CAST(1 AS DECIMAL(38,20))
		,[intWeightUOMId] = NULL 
		,[intCostCurrencyId] = ISNULL(A.intCurrencyId, 0)
		,[dblTax] = 
			ISNULL(
				CASE
					--THIRD PARTY TAX SHOULD RETAIN NEGATIVE IF CHECK OFF
					WHEN ISNULL(A.intEntityVendorId, r.intEntityVendorId) <> r.intEntityVendorId THEN 
						CASE 
							WHEN IRCT.ysnCheckoffTax = 0 THEN 
								ROUND(dbo.fnMultiply(ABS(A.dblTax), @dblRatio), 2) 
							ELSE 
								ROUND(dbo.fnMultiply(A.dblTax, @dblRatio), 2) 
						END 
					-- RECEIPT VENDOR
					ELSE 					
						CASE 
							WHEN @billTypeToUse = @type_DebitMemo THEN 
								-ROUND(dbo.fnMultiply((CASE WHEN A.ysnPrice = 1 THEN -A.dblTax ELSE A.dblTax END), @dblRatio), 2) 
							ELSE
								ROUND(dbo.fnMultiply((CASE WHEN A.ysnPrice = 1 THEN -A.dblTax ELSE A.dblTax END), @dblRatio), 2) 
						END
				END
			,0) 		
		,[dblDiscount] = 0 
		,[intCurrencyExchangeRateTypeId] = A.intForexRateTypeId
		,[dblExchangeRate] = ISNULL(NULLIF(A.dblForexRate,0), 1)				
		,[ysnSubCurrency] = ISNULL(A.ysnSubCurrency,0)					
		,[intSubCurrencyCents] = ISNULL(A.intSubCurrencyCents,1)
		,[intAccountId] = [dbo].[fnGetItemGLAccount](A.intItemId, ItemLoc.intItemLocationId, 'AP Clearing')
		,[intShipViaId]	= NULL 
		,[intTermId] = NULL		
		,[intFreightTermId] = r.intFreightTermId
		,[strBillOfLading] = NULL					
		,[ysnReturn] = 
			CAST(
				CASE 
					WHEN A.strReceiptType = 'Inventory Return' THEN 1 
					WHEN @billTypeToUse = @type_DebitMemo AND A.ysnPrice = 1 THEN 1 
					WHEN @billTypeToUse = @type_DebitMemo AND A.intEntityVendorId = r.intEntityVendorId THEN 1 
					ELSE 0 
				END
			AS BIT)
		,ysnStage = 
			CASE WHEN hasExistingPayable.intVoucherPayableId IS NOT NULL THEN 1 ELSE 0 END 
		,dblRatio = @dblRatio
	FROM 
		vyuICChargesForBilling A 
		INNER JOIN tblICInventoryReceipt r
			ON A.intInventoryReceiptId = r.intInventoryReceiptId
		INNER JOIN tblICInventoryReceiptCharge rc 
			ON A.intInventoryReceiptChargeId = rc.intInventoryReceiptChargeId
		LEFT JOIN dbo.tblSMCurrency H1 
			ON H1.intCurrencyID = A.intCurrencyId
		LEFT JOIN dbo.tblSMCurrency SubCurrency 
			ON SubCurrency.intMainCurrencyId = A.intCurrencyId 		
		LEFT JOIN tblAPVendor payToVendor 
			ON payToVendor.intEntityId = A.intEntityVendorId
		LEFT JOIN tblEMEntityLocation payToAddress 
			ON payToAddress.intEntityId = payToVendor.intEntityId
			AND payToAddress.ysnDefaultLocation = 1

		LEFT JOIN tblICItemLocation ItemLoc 
			ON ItemLoc.intItemId = A.intItemId 
			AND ItemLoc.intLocationId = A.intLocationId

		OUTER APPLY
		(
			SELECT TOP 1 
				ysnCheckoffTax 
			FROM 
				tblICInventoryReceiptChargeTax IRCT
			WHERE 
				IRCT.intInventoryReceiptChargeId = A.intInventoryReceiptChargeId
		)  IRCT

		OUTER APPLY (
			SELECT TOP 1 
				ap.intVoucherPayableId
			FROM
				tblAPVoucherPayable ap
			WHERE
				ap.strSourceNumber = r.strReceiptNumber
				AND ap.intInventoryReceiptItemId = A.intInventoryReceiptItemId
				AND ap.intInventoryReceiptChargeId = A.intInventoryReceiptChargeId		
		) hasExistingPayable
	WHERE
		A.intInventoryReceiptId = @intInventoryReceiptId
		AND A.intEntityVendorId = r.intEntityVendorId 
		AND ISNULL(A.intContractHeaderId, 0) = ISNULL(@intContractHeaderId, 0)
		AND ISNULL(A.intContractDetailId, 0) = ISNULL(@intContractDetailId, 0)
		AND ISNULL(rc.strChargesLink, '') = ISNULL(@strChargesLink, '')
END 

SELECT 
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
	,[intLoadShipmentCostId]		
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
	,[intFreightTermId]				
	,[strBillOfLading]					
	,[ysnReturn]
	,[ysnStage]
	,[dblRatio]
FROM 
	@voucherPayable
