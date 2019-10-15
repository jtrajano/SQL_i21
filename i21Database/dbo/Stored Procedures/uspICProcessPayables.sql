CREATE PROCEDURE dbo.uspICProcessPayables
	@intReceiptId INT = NULL,
	@intShipmentId INT = NULL,
	@ysnPost BIT,
	@intEntityUserSecurityId INT
AS
BEGIN
	-- Generate Payables
	DECLARE @voucherPayable VoucherPayable
	DECLARE @voucherPayableTax VoucherDetailTax

	IF(@intReceiptId IS NOT NULL)
	BEGIN
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
			,[strBillOfLading]					
			,[ysnReturn]		
		)
		SELECT 
			 GP.[intEntityVendorId]			
			,GP.[intTransactionType]
			,GP.[intLocationId]	
			,[intShipToId] = GP.intShipFromId	
			,[intShipFromId] = GP.intShipFromId	 		
			,[intShipFromEntityId] = GP.intShipFromEntityId
			,[intPayToAddressId] = GP.intPayToAddressId
			,GP.[intCurrencyId]					
			,GP.[dtmDate]				
			,GP.[strVendorOrderNumber]		
			,GP.[strReference]						
			,GP.[strSourceNumber]					
			,GP.[intPurchaseDetailId]				
			,GP.[intContractHeaderId]				
			,GP.[intContractDetailId]				
			,[intContractSeqId]	= GP.intContractSequence				
			,GP.[intScaleTicketId]					
			,GP.[intInventoryReceiptItemId]		
			,GP.[intInventoryReceiptChargeId]		
			,GP.[intInventoryShipmentItemId]		
			,GP.[intInventoryShipmentChargeId]		
			,[intLoadShipmentId] = GP.intLoadShipmentId			
			,[intLoadShipmentDetailId] = GP.intLoadShipmentDetailId
			,[intLoadShipmentCostId] = GP.intLoadShipmentCostId
			,GP.[intItemId]						
			,GP.[intPurchaseTaxGroupId]			
			,GP.[strMiscDescription]				
			,GP.[dblOrderQty]						
			,[dblOrderUnitQty] = 0.00					
			,[intOrderUOMId] = NULL	 				
			,GP.[dblQuantityToBill]				
			,GP.[dblQtyToBillUnitQty]				
			,GP.[intQtyToBillUOMId]				
			,[dblCost] = GP.dblUnitCost							
			,GP.[dblCostUnitQty]					
			,GP.[intCostUOMId]						
			,GP.[dblNetWeight]						
			,GP.[dblWeightUnitQty]					
			,GP.[intWeightUOMId]					
			,GP.[intCostCurrencyId]
			,GP.[dblTax]							
			,GP.[dblDiscount]
			,GP.[intCurrencyExchangeRateTypeId]	
			,[dblExchangeRate] = GP.dblRate					
			,GP.[ysnSubCurrency]					
			,GP.[intSubCurrencyCents]				
			,GP.[intAccountId]						
			,GP.[intShipViaId]						
			,GP.[intTermId]						
			,GP.[strBillOfLading]					
			,GP.[ysnReturn]	 
		FROM dbo.fnICGeneratePayables (@intReceiptId, @ysnPost, DEFAULT) GP
	END
	
	/* Get Shipment Charges */
	IF(@intShipmentId IS NOT NULL)
	BEGIN
		
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
				,[intTransactionType] = 1
				,ShipmentCharges.[intLocationId]	
				,[intShipToId] = NULL	
				,[intShipFromId] = NULL	 		
				,[intShipFromEntityId] = NULL
				,[intPayToAddressId] = NULL
				,[intCurrencyId] = ISNULL(ShipmentCharges.intCurrencyId, (SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference))					
				,[dtmDate]				
				,[strVendorOrderNumber] = Shipment.strBOLNumber
				,[strReference]						
				,[strSourceNumber]					
				,[intPurchaseDetailId] = NULL				
				,[intContractHeaderId]				
				,[intContractDetailId]				
				,[intContractSeqId] = NULL					
				,[intScaleTicketId]					
				,[intInventoryReceiptItemId] = NULL	
				,[intInventoryReceiptChargeId] = NULL
				,[intInventoryShipmentItemId]		
				,[intInventoryShipmentChargeId]		
				,[intLoadShipmentId] = NULL				
				,[intLoadShipmentDetailId] = NULL			
				,ShipmentCharges.[intItemId]						
				,[intPurchaseTaxGroupId] = NULL		
				,[strMiscDescription]				
				,[dblOrderQty]						
				,[dblOrderUnitQty] = 0.00					
				,[intOrderUOMId] = NULL	 				
				,[dblQuantityToBill] 			
				,[dblQtyToBillUnitQty] = CAST(1 AS DECIMAL(38,20))				
				,[intQtyToBillUOMId] = NULL		
				,[dblCost] = CASE WHEN ShipmentCharges.dblOrderQty > 1 -- PER UNIT
								THEN CASE WHEN ShipmentCharges.ysnSubCurrency > 0 THEN CAST(ShipmentCharges.dblUnitCost AS DECIMAL(38,20)) / ISNULL(ShipmentCharges.intSubCurrencyCents,100) ELSE CAST(ShipmentCharges.dblUnitCost AS DECIMAL(38,20))  END
								ELSE CAST(ShipmentCharges.dblUnitCost AS DECIMAL(38,20))
							 END							
				,[dblCostUnitQty] = CAST(1 AS DECIMAL(38,20))
				,[intCostUOMId]	= ShipmentCharges.intCostUnitMeasureId
				,[dblNetWeight]	= CAST(0 AS DECIMAL(38,20))
				,[dblWeightUnitQty]	= CAST(1 AS DECIMAL(38,20))				
				,[intWeightUOMId] = NULL
				,[intCostCurrencyId] = ShipmentCharges.intCurrencyId
				,[dblTax]							
				,[dblDiscount] = 0
				,[intCurrencyExchangeRateTypeId] = ShipmentCharges.intForexRateTypeId
				,[dblExchangeRate] = ShipmentCharges.dblForexRate
				,[ysnSubCurrency]					
				,[intSubCurrencyCents]				
				,[dbo].[fnGetItemGLAccount](ShipmentCharges.intItemId, ItemLocation.intItemLocationId, 'AP Clearing')					
				,Shipment.[intShipViaId]						
				,[intTermId] = NULL 			
				,[strBillOfLading] = Shipment.strBOLNumber
				,[ysnReturn] = 0 
			FROM vyuICShipmentChargesForBilling ShipmentCharges
			INNER JOIN tblICInventoryShipment Shipment
				ON Shipment.intInventoryShipmentId = ShipmentCharges.intInventoryShipmentId
			INNER JOIN tblICItemLocation ItemLocation 
				ON ItemLocation.intItemId = ShipmentCharges.intItemId
				AND ItemLocation.intLocationId = ShipmentCharges.intLocationId
			WHERE Shipment.intInventoryShipmentId = @intShipmentId
				AND Shipment.ysnPosted = 1
				AND (ShipmentCharges.intContractDetailId IS NULL OR 
					(
						CASE WHEN ShipmentCharges.intContractDetailId IS NOT NULL 
							AND EXISTS(
								SELECT TOP 1 1 
								FROM tblAPVoucherPayable 
								WHERE intEntityVendorId = ShipmentCharges.intEntityVendorId 
								AND intContractDetailId = ShipmentCharges.intContractDetailId
								AND strSourceNumber != ShipmentCharges.strSourceNumber
							)
							THEN 0 ELSE 1 
						END = 1
					)
				)

	END


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
		DECLARE @voucherPayableForRemoval VoucherPayable
		INSERT INTO @voucherPayableForRemoval(
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
			,[strBillOfLading]					
			,[ysnReturn]		
		)
		SELECT 
			 GP.[intEntityVendorId]			
			,GP.[intTransactionType]
			,GP.[intLocationId]	
			,[intShipToId] = GP.intShipFromId	
			,[intShipFromId] = GP.intShipFromId	 		
			,[intShipFromEntityId] = GP.intShipFromEntityId
			,[intPayToAddressId] = GP.intPayToAddressId
			,GP.[intCurrencyId]					
			,GP.[dtmDate]				
			,GP.[strVendorOrderNumber]		
			,GP.[strReference]						
			,GP.[strSourceNumber]					
			,GP.[intPurchaseDetailId]				
			,GP.[intContractHeaderId]				
			,GP.[intContractDetailId]				
			,[intContractSeqId]	= GP.intContractSequence				
			,GP.[intScaleTicketId]					
			,GP.[intInventoryReceiptItemId]		
			,GP.[intInventoryReceiptChargeId]		
			,GP.[intInventoryShipmentItemId]		
			,GP.[intInventoryShipmentChargeId]		
			,GP.[intLoadShipmentId]				
			,GP.[intLoadShipmentDetailId]	
			,GP.[intLoadShipmentCostId]			
			,GP.[intItemId]						
			,GP.[intPurchaseTaxGroupId]			
			,GP.[strMiscDescription]				
			,GP.[dblOrderQty]						
			,[dblOrderUnitQty] = 0.00					
			,[intOrderUOMId] = NULL	 				
			,GP.[dblQuantityToBill]				
			,GP.[dblQtyToBillUnitQty]				
			,GP.[intQtyToBillUOMId]				
			,[dblCost] = GP.dblUnitCost							
			,GP.[dblCostUnitQty]					
			,GP.[intCostUOMId]						
			,GP.[dblNetWeight]						
			,GP.[dblWeightUnitQty]					
			,GP.[intWeightUOMId]					
			,GP.[intCostCurrencyId]
			,GP.[dblTax]							
			,GP.[dblDiscount]
			,GP.[intCurrencyExchangeRateTypeId]	
			,[dblExchangeRate] = GP.dblRate					
			,GP.[ysnSubCurrency]					
			,GP.[intSubCurrencyCents]				
			,GP.[intAccountId]						
			,GP.[intShipViaId]						
			,GP.[intTermId]						
			,GP.[strBillOfLading]					
			,GP.[ysnReturn]	 
		FROM dbo.fnICGeneratePayables (@intReceiptId, @ysnPost, DEFAULT) GP
		EXEC dbo.uspAPRemoveVoucherPayable @voucherPayableForRemoval
	END
END