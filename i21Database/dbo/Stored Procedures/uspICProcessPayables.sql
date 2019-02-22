CREATE PROCEDURE dbo.uspICProcessPayables
	@intReceiptId INT,
	@ysnPost BIT,
	@intEntityUserSecurityId INT
AS
BEGIN
	DECLARE @ReceiptType INT = 4
	-- Generate Payables
	DECLARE @voucherPayable VoucherPayable
	DECLARE @voucherPayableTax VoucherDetailTax
	
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
	FROM dbo.fnICGeneratePayables (@intReceiptId, @ysnPost)
	

	INSERT INTO @voucherPayableTax(
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
	FROM dbo.fnICGeneratePayablesTaxes(@voucherPayable)

	IF @ysnPost = 1
	BEGIN
		EXEC dbo.uspAPUpdateVoucherPayableQty @voucherPayable, @voucherPayableTax
	END
	ELSE
	BEGIN
		EXEC dbo.uspAPRemoveVoucherPayable @voucherPayable
	END
END