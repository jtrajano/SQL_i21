CREATE FUNCTION [dbo].[fnCTCreateVoucherDetail]
(
	@intBillId INT,
	@dblQtyToBill NUMERIC(18,6),
	@dblFinalPrice NUMERIC(18,6)
)
RETURNS TABLE AS RETURN
(
	SELECT TOP 1 BD.intBillId
	,B.[intEntityVendorId]			
	,B.[intTransactionType]		
	,[intLocationId]	
	,B.[intShipToId]	
	,B.[intShipFromId]			
	,B.[intShipFromEntityId]
	,B.[intPayToAddressId]
	,B.[intCurrencyId]					
	,B.[dtmDate]				
	,B.[strVendorOrderNumber]			
	,B.[strReference]						
	,BD.[intPurchaseDetailId]				
	,BD.[intContractHeaderId]				
	,BD.[intContractDetailId]				
	,BD.[intContractSeq]					
	,BD.[intScaleTicketId]					
	,BD.[intInventoryReceiptItemId]		
	,BD.[intInventoryReceiptChargeId]		
	,[intInventoryShipmentChargeId]
	,BD.[intLoadShipmentCostId]			
	,BD.[intItemId]						
	,[intPurchaseTaxGroupId] = BD.intTaxGroupId
	,BD.[strMiscDescription]				
	,[dblOrderQty] = BD.dblQtyOrdered
	,[dblOrderUnitQty]  = BD.dblUnitQty
	,[intOrderUOMId] = BD.intUnitOfMeasureId				
	,[dblQuantityToBill] = @dblQtyToBill
	,[dblQtyToBillUnitQty] = BD.dblUnitQty
	,[intQtyToBillUOMId] = BD.intUnitOfMeasureId
	,[dblCost] = @dblFinalPrice							
	,BD.[dblCostUnitQty]					
	,BD.[intCostUOMId]						
	,BD.[dblNetWeight]						
	,BD.[dblWeightUnitQty]					
	,BD.[intWeightUOMId]					
	,[intCostCurrencyId] = BD.intCurrencyId
	,BD.[dblTax]							
	,BD.[dblDiscount]
	,BD.[intCurrencyExchangeRateTypeId]	
	,BD.[ysnSubCurrency]					
	,B.[intSubCurrencyCents]				
	,BD.[intAccountId]						
	,B.[intShipViaId]						
	,[intTermId] = B.intTermsId					
	,BD.[strBillOfLading]					
	,[dtmVoucherDate] = B.dtmBillDate
	,BD.[intStorageLocationId]
	,BD.[intSubLocationId]
	,[ysnStage] = 0
	FROM tblAPBillDetail BD
	INNER JOIN tblAPBill B ON BD.intBillId = B.intBillId
	WHERE BD.intInventoryReceiptChargeId IS NULL
	AND BD.intBillId = @intBillId
)