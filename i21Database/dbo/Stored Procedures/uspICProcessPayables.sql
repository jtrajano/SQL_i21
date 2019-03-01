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
		UNION ALL
		/* To get the unposted Receipt Charges */
		SELECT 
			VoucherPayable.[intEntityVendorId]
			,[intTransactionType] =	CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN 3 ELSE 1 END 
			,Receipt.[intLocationId]	
			,[intShipToId] = NULL	
			,[intShipFromId] = NULL	 		
			,[intShipFromEntityId] = NULL
			,[intPayToAddressId] = NULL
			,ReceiptCharge.[intCurrencyId]					
			,Receipt.[dtmReceiptDate]				
			,Receipt.[strBillOfLading]
			,Receipt.[strVendorRefNo]					
			,Receipt.[strReceiptNumber]
			,[intPurchaseDetailId] = NULL	
			,ReceiptCharge.[intContractId]				
			,ReceiptCharge.[intContractDetailId]				
			,vReceiptCharge.[intContractSeq]					
			,ScaleTicket.[intScaleTicketId]					
			,[intInventoryReceiptItemId] = ISNULL(ChargesLink.intInventoryReceiptItemId, ISNULL(ComputedChargesLink.intInventoryReceiptItemId, VoucherPayable.intInventoryReceiptItemId)) 
			,ReceiptCharge.[intInventoryReceiptChargeId]		
			,[intInventoryShipmentItemId]
			,[intInventoryShipmentChargeId]		
			,[intLoadShipmentId] = NULL				
			,[intLoadShipmentDetailId] = NULL			
			,ReceiptCharge.[intChargeId]
			,[intPurchaseTaxGroupId] = NULL		
			,vReceiptCharge.[strItemDescription]	
			,[dblOrderQty]						
			,[dblOrderUnitQty] = 0.00					
			,[intOrderUOMId] = NULL	 				
			,[dblQuantityToBill]				
			,[dblQtyToBillUnitQty]				
			,[intQtyToBillUOMId]				
			,VoucherPayable.[dblCost]
			,[dblCostUnitQty]					
			,ReceiptCharge.[intCostUOMId]						
			,[dblNetWeight]						
			,[dblWeightUnitQty]					
			,[intWeightUOMId]					
			,[intCostCurrencyId]
			,ReceiptCharge.[dblTax]							
			,VoucherPayable.[dblDiscount]
			,VoucherPayable.[intCurrencyExchangeRateTypeId]	
			,ReceiptCharge.[dblForexRate]
			,ReceiptCharge.[ysnSubCurrency]					
			,VoucherPayable.[intSubCurrencyCents]				
			,[intAccountId]						
			,VoucherPayable.[intShipViaId]						
			,[intTermId]						
			,VoucherPayable.[strBillOfLading]					
			,VoucherPayable.[ysnReturn]	 
		FROM tblICInventoryReceiptCharge ReceiptCharge 
		INNER JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
		INNER JOIN vyuICGetInventoryReceiptCharge vReceiptCharge
			ON ReceiptCharge.intInventoryReceiptChargeId = vReceiptCharge.intInventoryReceiptChargeId
		LEFT JOIN tblAPVoucherPayable VoucherPayable ON VoucherPayable.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
			OUTER APPLY (
			SELECT	A.intInventoryReceiptItemId
					,A.intOwnershipType
					,c = COUNT(1) 
			FROM	tblICInventoryReceiptItem A		
			WHERE	A.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
					AND A.strChargesLink = ReceiptCharge.strChargesLink
			GROUP BY A.intInventoryReceiptItemId
					,A.intOwnershipType
			HAVING	COUNT(1) = 1 

		) ChargesLink  

		OUTER APPLY (
			SELECT	A.intInventoryReceiptChargeId				
					,c = COUNT(1) 
			FROM	tblICInventoryReceiptChargePerItem A 
			WHERE	A.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
			GROUP BY 
					A.intInventoryReceiptChargeId
			HAVING	COUNT(1) = 1 

		) ChargesPerItem 

		OUTER APPLY (
			SELECT	B.intInventoryReceiptItemId
			FROM	tblICInventoryReceiptChargePerItem B
			WHERE	B.intInventoryReceiptChargeId = ChargesPerItem.intInventoryReceiptChargeId
		) ComputedChargesLink

		OUTER APPLY dbo.fnICGetScaleTicketIdForReceiptCharge(Receipt.intInventoryReceiptId, Receipt.strReceiptNumber) ScaleTicket
		WHERE Receipt.intInventoryReceiptId = @intReceiptId
			AND Receipt.ysnPosted = 0
	
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
				,[intLocationId]	
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
				,[intItemId]						
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
				,[intAccountId]						
				,[intShipViaId]						
				,[intTermId] = NULL 			
				,[strBillOfLading] = Shipment.strBOLNumber
				,[ysnReturn] = 0 
			FROM vyuICShipmentChargesForBilling ShipmentCharges
			INNER JOIN tblICInventoryShipment Shipment
				ON Shipment.intInventoryShipmentId = ShipmentCharges.intInventoryShipmentId
			WHERE Shipment.intInventoryShipmentId = @intShipmentId
				AND Shipment.ysnPosted = 1
			UNION ALL
			/* To get the unposted Receipt Charges */
			SELECT 
				VoucherPayable.[intEntityVendorId]
				,[intTransactionType] =	1
				,Shipment.[intShipFromLocationId]
				,[intShipToId] = NULL	
				,[intShipFromId] = NULL	 		
				,[intShipFromEntityId] = NULL
				,[intPayToAddressId] = NULL
				,ShipmentCharge.[intCurrencyId]					
				,Shipment.[dtmShipDate]				
				,Shipment.[strBOLNumber]
				,Shipment.[strReferenceNumber]					
				,Shipment.[strShipmentNumber]
				,[intPurchaseDetailId] = NULL	
				,ShipmentCharge.[intContractId]				
				,ShipmentCharge.[intContractDetailId]				
				,[intContractSeq] = NULL
				,ScaleTicket.[intScaleTicketId]					
				,[intInventoryReceiptItemId] = NULL
				,[intInventoryReceiptChargeId] = NULL
				,ShipmentItem.[intInventoryShipmentItemId]
				,ShipmentCharge.[intInventoryShipmentChargeId]		
				,[intLoadShipmentId] = NULL				
				,[intLoadShipmentDetailId] = NULL			
				,ShipmentCharge.[intChargeId]
				,[intPurchaseTaxGroupId] = NULL		
				,vShipmentCharge.[strItemDescription]	
				,[dblOrderQty]						
				,[dblOrderUnitQty] = 0.00					
				,[intOrderUOMId] = NULL	 				
				,[dblQuantityToBill]				
				,[dblQtyToBillUnitQty]				
				,[intQtyToBillUOMId]				
				,VoucherPayable.[dblCost]
				,[dblCostUnitQty]					
				,ShipmentCharge.[intCostUOMId]						
				,[dblNetWeight]						
				,[dblWeightUnitQty]					
				,[intWeightUOMId]					
				,[intCostCurrencyId]
				,ShipmentCharge.[dblTax]							
				,VoucherPayable.[dblDiscount]
				,VoucherPayable.[intCurrencyExchangeRateTypeId]	
				,ShipmentCharge.[dblForexRate]
				,ShipmentCharge.[ysnSubCurrency]					
				,VoucherPayable.[intSubCurrencyCents]				
				,[intAccountId]						
				,VoucherPayable.[intShipViaId]						
				,[intTermId]						
				,VoucherPayable.[strBillOfLading]					
				,VoucherPayable.[ysnReturn]	 
			FROM tblICInventoryShipmentCharge ShipmentCharge 
			INNER JOIN tblICInventoryShipment Shipment 
				ON Shipment.intInventoryShipmentId = ShipmentCharge.intInventoryShipmentId
			INNER JOIN vyuICGetInventoryShipmentCharge vShipmentCharge
				ON vShipmentCharge.intInventoryShipmentChargeId = ShipmentCharge.intInventoryShipmentChargeId
			LEFT JOIN tblAPVoucherPayable VoucherPayable 
				ON VoucherPayable.intInventoryShipmentChargeId = ShipmentCharge.intInventoryShipmentChargeId
		
			OUTER APPLY (
				SELECT
					A.intInventoryShipmentItemId
				FROM tblICInventoryShipmentItem A
				WHERE A.intInventoryShipmentId = Shipment.intInventoryShipmentId
			) ShipmentItem 

			OUTER APPLY dbo.fnICGetScaleTicketIdForShipmentCharge(Shipment.intInventoryShipmentId, Shipment.strShipmentNumber) ScaleTicket
			WHERE Shipment.intInventoryShipmentId = @intShipmentId
				AND Shipment.ysnPosted = 0

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
		EXEC dbo.uspAPRemoveVoucherPayable @voucherPayable
	END
END