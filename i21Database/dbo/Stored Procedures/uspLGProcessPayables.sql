﻿CREATE PROCEDURE [dbo].[uspLGProcessPayables]
	@intLoadId INT = NULL
	,@intLoadCostId INT = NULL
	,@ysnPost BIT
	,@intEntityUserSecurityId INT
AS
BEGIN
	DECLARE @voucherPayable VoucherPayable
	DECLARE @DefaultCurrencyId INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')
	DECLARE @voucherPayableTax AS VoucherDetailTax
	DECLARE @intTaxGroupId INT

	IF (@intLoadId IS NOT NULL)
	BEGIN
		EXEC uspLGRecalculateLoadCosts @intLoadId, @intEntityUserSecurityId

		-- Get tax group
		SELECT TOP 1
			@intTaxGroupId = dbo.fnGetTaxGroupIdForVendor (
				LD.intVendorEntityId	-- @VendorId
				,ISNULL(L.intCompanyLocationId, CD.intCompanyLocationId)		--,@CompanyLocationId
				,NULL				--,@ItemId
				,EL.intEntityLocationId		--,@VendorLocationId
				,L.intFreightTermId	--,@FreightTermId
				,default --,@FOB
			)
		FROM tblLGLoad L
		INNER JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
		INNER JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
		INNER JOIN tblAPVendor V ON V.intEntityId = LD.intVendorEntityId
		INNER JOIN tblEMEntityLocation EL ON EL.intEntityId = V.intEntityId AND EL.ysnDefaultLocation = 1	
		WHERE L.intLoadId = @intLoadId

		INSERT INTO @voucherPayable(
			[intEntityVendorId]
			,[intTransactionType]
			,[intLocationId]
			,[intCurrencyId]
			,[dtmDate]
			,[strVendorOrderNumber]
			,[strReference]
			,[strSourceNumber]
			,[intContractHeaderId]
			,[intContractDetailId]
			,[intContractSeqId]
			,[intContractCostId]
			,[intInventoryReceiptItemId]
			,[intLoadShipmentId]
			,[strLoadShipmentNumber]
			,[intLoadShipmentDetailId]
			,[intLoadShipmentCostId]
			,[intItemId]
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
			,[intFreightTermId]
			,[dblTax]
			,[dblDiscount]
			,[intCurrencyExchangeRateTypeId]
			,[dblExchangeRate]
			,[ysnSubCurrency]
			,[intSubCurrencyCents]
			,[intAccountId]
			,[strBillOfLading]
			,[ysnReturn]
			,[ysnStage]
			,[intStorageLocationId]
			,[intSubLocationId]
			,[dblOptionalityPremium]
			,[dblQualityPremium]
			,[intPurchaseTaxGroupId]
			,[intPayFromBankAccountId]
			,[strFinancingSourcedFrom]
			,[strFinancingTransactionNumber])
		SELECT
			[intEntityVendorId] = D1.intEntityId
			,[intTransactionType] = 1
			,[intLocationId] = IsNull(L.intCompanyLocationId, CT.intCompanyLocationId)
			,[intCurrencyId] = COALESCE(CY.intMainCurrencyId, CY.intCurrencyID, L.intCurrencyId)
			,[dtmDate] = L.dtmPostedDate
			,[strVendorOrderNumber] = ''
			,[strReference] = ''
			,[strSourceNumber] = LTRIM(L.strLoadNumber)
			,[intContractHeaderId] = CH.intContractHeaderId
			,[intContractDetailId] = LD.intPContractDetailId
			,[intContractSeqId] = CT.intContractSeq
			,[intContractCostId] = NULL
			,[intInventoryReceiptItemId] = receiptItem.intInventoryReceiptItemId
			,[intLoadShipmentId] = L.intLoadId
			,[strLoadShipmentNumber] = LTRIM(L.strLoadNumber)
			,[intLoadShipmentDetailId] = LD.intLoadDetailId
			,[intLoadShipmentCostId] = NULL
			,[intItemId] = LD.intItemId
			,[strMiscDescription] = item.strDescription
			,[dblOrderQty] = LD.dblQuantity
			,[dblOrderUnitQty] = ISNULL(ItemUOM.dblUnitQty,1)
			,[intOrderUOMId] = LD.intItemUOMId
			,[dblQuantityToBill] = LD.dblQuantity
			,[dblQtyToBillUnitQty] = ISNULL(ItemUOM.dblUnitQty,1)
			,[intQtyToBillUOMId] = LD.intItemUOMId
			,[dblCost] = (CASE WHEN intPurchaseSale = 3 THEN COALESCE(AD.dblSeqPrice, dbo.fnCTGetSequencePrice(CT.intContractDetailId, NULL), 0) ELSE ISNULL(LD.dblUnitPrice, 0) END)
			,[dblCostUnitQty] = CAST(ISNULL(ItemCostUOM.dblUnitQty,1) AS DECIMAL(38,20))
			,[intCostUOMId] = (CASE WHEN intPurchaseSale = 3 THEN ISNULL(AD.intSeqPriceUOMId, 0) ELSE ISNULL(AD.intSeqPriceUOMId, LD.intPriceUOMId) END) 
			,[dblNetWeight] = ISNULL(LD.dblNet,0)
			,[dblWeightUnitQty] = ISNULL(ItemWeightUOM.dblUnitQty,1)
			,[intWeightUOMId] = ItemWeightUOM.intItemUOMId
			,[intCostCurrencyId] = (CASE WHEN intPurchaseSale = 3 THEN ISNULL(AD.intSeqCurrencyId, 0) ELSE ISNULL(AD.intSeqCurrencyId, LD.intPriceCurrencyId) END)
			,[intFreightTermId] = L.intFreightTermId
			,[dblTax] = ISNULL(receiptItem.dblTax, 0)
			,[dblDiscount] = 0
			,[intCurrencyExchangeRateTypeId] = ISNULL(LD.intForexRateTypeId,FX.intForexRateTypeId)
			,[dblExchangeRate] = CASE --if contract FX tab is setup
									 WHEN AD.ysnValidFX = 1 THEN 
										CASE WHEN (ISNULL(SC.intMainCurrencyId, SC.intCurrencyID) = @DefaultCurrencyId AND CT.intInvoiceCurrencyId <> @DefaultCurrencyId) 
												THEN dbo.fnDivide(1, ISNULL(LD.dblForexRate, 1)) --functional price to foreign FX, use inverted contract FX rate
											WHEN (ISNULL(SC.intMainCurrencyId, SC.intCurrencyID) <> @DefaultCurrencyId AND CT.intInvoiceCurrencyId = @DefaultCurrencyId)
												THEN 1 --foreign price to functional FX, use 1
											WHEN (ISNULL(SC.intMainCurrencyId, SC.intCurrencyID) <> @DefaultCurrencyId AND CT.intInvoiceCurrencyId <> @DefaultCurrencyId)
												THEN ISNULL(FX.dblFXRate, 1) --foreign price to foreign FX, use master FX rate
											ELSE ISNULL(LD.dblForexRate,1) END
									 ELSE  --if contract FX tab is not setup
										CASE WHEN (@DefaultCurrencyId <> ISNULL(SC.intMainCurrencyId, SC.intCurrencyID)) 
											THEN ISNULL(FX.dblFXRate, 1)
											ELSE ISNULL(LD.dblForexRate,1) END
									 END
			,[ysnSubCurrency] =	AD.ysnSeqSubCurrency
			,[intSubCurrencyCents] = CY.intCent
			,[intAccountId] = apClearing.intAccountId
			,[strBillOfLading] = L.strBLNumber
			,[ysnReturn] = CAST(0 AS BIT)
			,[ysnStage] = CAST(1 AS BIT)
			,[intStorageLocationId] = ISNULL(LW.intStorageLocationId, CT.intStorageLocationId)
			,[intSubLocationId] = ISNULL(LW.intSubLocationId, CT.intSubLocationId)
			,[dblOptionalityPremium] = ISNULL(LD.dblOptionalityPremium, 0)
			,[dblQualityPremium] = ISNULL(LD.dblQualityPremium, 0)
			,[intPurchaseTaxGroupId] = CASE WHEN ISNULL(LD.intTaxGroupId, '') = '' THEN @intTaxGroupId ELSE LD.intTaxGroupId END
			,[intPayFromBankAccountId] = BA.intBankAccountId
			,[strFinancingSourcedFrom] = CASE WHEN (BA.intBankAccountId IS NOT NULL) THEN 'Logistics' ELSE '' END
			,[strFinancingTransactionNumber] = CASE WHEN (BA.intBankAccountId IS NOT NULL) THEN L.strLoadNumber ELSE '' END
		FROM tblLGLoad L
		JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
		JOIN tblCTContractDetail CT ON CT.intContractDetailId = LD.intPContractDetailId
		JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CT.intContractHeaderId
		JOIN vyuLGAdditionalColumnForContractDetailView AD ON AD.intContractDetailId = CT.intContractDetailId
		JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON CH.intEntityId = D1.[intEntityId]  
		LEFT JOIN tblSMCurrency CY ON CY.intCurrencyID = AD.intSeqCurrencyId
		LEFT JOIN (tblICInventoryReceipt receipt 
					INNER JOIN tblICInventoryReceiptItem receiptItem ON receipt.intInventoryReceiptId = receiptItem.intInventoryReceiptId)
					ON LD.intLoadDetailId = receiptItem.intSourceId AND receipt.intSourceType = 2
		LEFT JOIN tblICItem item ON item.intItemId = LD.intItemId 
		LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = LD.intItemId and ItemLoc.intLocationId = IsNull(L.intCompanyLocationId, CT.intCompanyLocationId)
		LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = CT.intItemUOMId
		LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemId = LD.intItemId and ItemWeightUOM.intUnitMeasureId = L.intWeightUnitMeasureId
		LEFT JOIN tblICItemUOM ItemCostUOM ON ItemCostUOM.intItemUOMId = CT.intPriceItemUOMId
		OUTER APPLY dbo.fnGetItemGLAccountAsTable(LD.intItemId, ItemLoc.intItemLocationId, 'AP Clearing') itemAccnt
		OUTER APPLY (SELECT TOP 1 W.intSubLocationId, W.intStorageLocationId, strSubLocation = CLSL.strSubLocationName, strStorageLocation = SL.strName FROM tblLGLoadWarehouse W
					LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = W.intStorageLocationId
					LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = W.intSubLocationId
					WHERE intLoadId = L.intLoadId) LW
		LEFT JOIN tblSMCurrency SC ON SC.intCurrencyID = CT.intCurrencyId
		OUTER APPLY (SELECT	TOP 1  
					intForexRateTypeId = RD.intRateTypeId
					,dblFXRate = CASE WHEN ER.intFromCurrencyId = @DefaultCurrencyId  
								THEN 1/RD.[dblRate] 
								ELSE RD.[dblRate] END 
					FROM tblSMCurrencyExchangeRate ER
					JOIN tblSMCurrencyExchangeRateDetail RD ON RD.intCurrencyExchangeRateId = ER.intCurrencyExchangeRateId
					WHERE @DefaultCurrencyId <> ISNULL(SC.intMainCurrencyId, SC.intCurrencyID)
						AND ((ER.intFromCurrencyId = ISNULL(SC.intMainCurrencyId, SC.intCurrencyID) AND ER.intToCurrencyId = @DefaultCurrencyId) 
							OR (ER.intFromCurrencyId = @DefaultCurrencyId AND ER.intToCurrencyId = ISNULL(SC.intMainCurrencyId, SC.intCurrencyID)))
					ORDER BY RD.dtmValidFromDate DESC) FX
		LEFT JOIN dbo.tblGLAccount apClearing ON apClearing.intAccountId = itemAccnt.intAccountId
		LEFT JOIN tblCMBankAccount BA ON BA.intBankAccountId = L.intBankAccountId
		WHERE L.intLoadId = @intLoadId
			AND CT.intPricingTypeId IN (1, 6)
			AND LD.intLoadDetailId NOT IN (SELECT IsNull(BD.intLoadDetailId, 0) FROM tblAPBillDetail BD JOIN tblICItem Item ON Item.intItemId = BD.intItemId
										  WHERE BD.intItemId = LD.intItemId AND Item.strType <> 'Other Charge')
		
		UNION ALL
		
		SELECT
			[intEntityVendorId] = A.intEntityVendorId
			,[intTransactionType] = 1
			,[intLocationId] = A.intCompanyLocationId
			,[intCurrencyId] = A.intCurrencyId
			,[dtmDate] = A.dtmProcessDate
			,[strVendorOrderNumber] = ''
			,[strReference] = ''
			,[strSourceNumber] = LTRIM(A.strLoadNumber)
			,[intContractHeaderId] = CH.intContractHeaderId
			,[intContractDetailId] = CT.intContractDetailId
			,[intContractSeqId] = CT.intContractSeq
			,[intContractCostId] = CTC.intContractCostId
			,[intInventoryReceiptItemId] = NULL
			,[intLoadShipmentId] = A.intLoadId
			,[strLoadShipmentNumber] = LTRIM(L.strLoadNumber)
			,[intLoadShipmentDetailId] = A.intLoadDetailId
			,[intLoadShipmentCostId] = A.intLoadCostId
			,[intItemId] = A.intItemId
			,[strMiscDescription] = A.strItemDescription
			,[dblOrderQty] = CASE WHEN A.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE LD.dblQuantity END
			,[dblOrderUnitQty] = CASE WHEN A.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE ISNULL(ItemUOM.dblUnitQty,1) END
			,[intOrderUOMId] = A.intItemUOMId
			,[dblQuantityToBill] = CASE WHEN A.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE LD.dblQuantity END
			,[dblQtyToBillUnitQty] = CASE WHEN A.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE ISNULL(ItemUOM.dblUnitQty,1) END
			,[intQtyToBillUOMId] = A.intItemUOMId
			,[dblCost] = CASE WHEN A.strCostMethod IN ('Amount','Percentage') THEN ISNULL(A.dblTotal, A.dblPrice) ELSE ISNULL(A.dblPrice, A.dblTotal) END 
			,[dblCostUnitQty] = CASE WHEN A.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE ISNULL(ItemCostUOM.dblUnitQty,1) END
			,[intCostUOMId] = CASE WHEN A.strCostMethod IN ('Amount','Percentage') THEN NULL ELSE A.intPriceItemUOMId END
			,[dblNetWeight] = 0
			,[dblWeightUnitQty] = 1
			,[intWeightUOMId] = NULL
			,[intCostCurrencyId] = A.intCurrencyId
			,[intFreightTermId] = NULL
			,[dblTax] = 0
			,[dblDiscount] = 0
			,[intCurrencyExchangeRateTypeId] = FX.intForexRateTypeId
			,[dblExchangeRate] = COALESCE(A.dblFX, FX.dblFXRate, 1)
			,[ysnSubCurrency] =	CUR.ysnSubCurrency
			,[intSubCurrencyCents] = ISNULL(CUR.intCent,0)
			,[intAccountId] = apClearing.intAccountId
			,[strBillOfLading] = L.strBLNumber
			,[ysnReturn] = CAST(0 AS BIT)
			,[ysnStage] = CAST(1 AS BIT)
			,[intStorageLocationId] = NULL
			,[intSubLocationId] = NULL
			,[dblOptionalityPremium] = 0
			,[dblQualityPremium] = 0
			,[intPurchaseTaxGroupId] = NULL
			,[intPayFromBankAccountId] = NULL
			,[strFinancingSourcedFrom] = NULL
			,[strFinancingTransactionNumber] = NULL
		FROM vyuLGLoadCostForVendor A
			OUTER APPLY tblLGCompanyPreference CP
			JOIN tblLGLoad L ON L.intLoadId = A.intLoadId
			JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
			JOIN tblCTContractDetail CT ON CT.intContractDetailId = CASE WHEN (CP.ysnEnableAccrualsForOutbound = 1 AND L.intPurchaseSale = 2 AND A.ysnAccrue = 1 AND A.intEntityVendorId IS NOT NULL) 
																	THEN LD.intSContractDetailId ELSE LD.intPContractDetailId END
			JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CT.intContractHeaderId
			JOIN tblSMCurrency C ON C.intCurrencyID = L.intCurrencyId
			LEFT JOIN tblSMCurrency CUR ON CUR.intCurrencyID = A.intCurrencyId
			LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = A.intItemId and ItemLoc.intLocationId = A.intCompanyLocationId
			LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = A.intItemUOMId
			LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
			LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemUOMId = A.intWeightItemUOMId
			LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = ItemWeightUOM.intUnitMeasureId
			LEFT JOIN tblICItemUOM ItemCostUOM ON ItemCostUOM.intItemUOMId = A.intPriceItemUOMId
			LEFT JOIN tblICUnitMeasure CostUOM ON CostUOM.intUnitMeasureId = ItemCostUOM.intUnitMeasureId
			INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON A.[intEntityVendorId] = D1.[intEntityId]
			OUTER APPLY dbo.fnGetItemGLAccountAsTable(
							A.intItemId,
							ItemLoc.intItemLocationId,
							CASE WHEN (CP.ysnEnableAccrualsForOutbound = 1 AND L.intPurchaseSale = 2 AND A.ysnAccrue = 1 AND A.intEntityVendorId IS NOT NULL)
									OR ISNULL(A.ysnInventoryCost, 0) = 1
							THEN 'AP Clearing'
							ELSE 'Other Charge Expense' 
							END) itemAccnt
			LEFT JOIN dbo.tblGLAccount apClearing ON apClearing.intAccountId = itemAccnt.intAccountId
			OUTER APPLY (SELECT TOP 1 ysnCreateOtherCostPayable = ISNULL(ysnCreateOtherCostPayable, 0) FROM tblCTCompanyPreference) COC
			OUTER APPLY (SELECT TOP 1 CTC.intContractCostId FROM tblCTContractCost CTC
						WHERE CT.intContractDetailId = CTC.intContractDetailId
							AND A.intItemId = CTC.intItemId
							AND A.intEntityVendorId = CTC.intVendorId
						) CTC
			OUTER APPLY (SELECT	TOP 1  
					intForexRateTypeId = RD.intRateTypeId
					,dblFXRate = CASE WHEN ER.intFromCurrencyId = @DefaultCurrencyId THEN 1/RD.[dblRate] ELSE RD.[dblRate] END 
					FROM tblSMCurrencyExchangeRate ER
					JOIN tblSMCurrencyExchangeRateDetail RD ON RD.intCurrencyExchangeRateId = ER.intCurrencyExchangeRateId
					WHERE @DefaultCurrencyId <> ISNULL(CUR.intMainCurrencyId, CUR.intCurrencyID)
						AND ((ER.intFromCurrencyId = ISNULL(CUR.intMainCurrencyId, CUR.intCurrencyID) AND ER.intToCurrencyId = @DefaultCurrencyId) 
							OR (ER.intFromCurrencyId = @DefaultCurrencyId AND ER.intToCurrencyId = ISNULL(CUR.intMainCurrencyId, CUR.intCurrencyID)))
					ORDER BY RD.dtmValidFromDate DESC) FX
			WHERE A.intLoadId = @intLoadId
				AND A.intLoadCostId = ISNULL(NULL, A.intLoadCostId)
				AND A.intLoadDetailId NOT IN 
					(SELECT IsNull(BD.intLoadDetailId, 0) FROM tblAPBillDetail BD JOIN tblICItem Item ON Item.intItemId = BD.intItemId
					WHERE BD.intItemId = A.intItemId AND Item.strType = 'Other Charge' AND ISNULL(A.ysnAccrue,0) = 1)
				AND NOT (COC.ysnCreateOtherCostPayable = 1 AND CTC.intContractCostId IS NOT NULL)
		
		-- Assemble Item Taxes
		BEGIN
			INSERT INTO @voucherPayableTax (
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
			SELECT distinct
				[intVoucherPayableId]			= payables.intVoucherPayableId
				,[intTaxGroupId]				= CASE when payables.intLoadShipmentCostId is not null then 
						CASE WHEN ISNULL(CL.intTaxGroupId, '') = '' THEN 
							dbo.fnGetTaxGroupIdForVendor (
								Cost.intVendorId	-- @VendorId
								,ISNULL(L.intCompanyLocationId, CD.intCompanyLocationId)		--,@CompanyLocationId
								,NULL				--,@ItemId
								,LCost.intEntityLocationId		--,@VendorLocationId
								,L.intFreightTermId	--,@FreightTermId
								,default --,@FOB
							)
					
						ELSE CL.intTaxGroupId END				
				WHEN ISNULL(LD.intTaxGroupId, '') = '' THEN @intTaxGroupId ELSE LD.intTaxGroupId END
				,[intTaxCodeId]					= vendorTax.[intTaxCodeId]
				,[intTaxClassId]				= vendorTax.[intTaxClassId]
				,[strTaxableByOtherTaxes]		= vendorTax.[strTaxableByOtherTaxes]
				,[strCalculationMethod]			= vendorTax.[strCalculationMethod]
				,[dblRate]						= vendorTax.[dblRate]
				,[intAccountId]					= vendorTax.[intTaxAccountId]
				,[dblTax]						=	CASE 
														WHEN vendorTax.[strCalculationMethod] = 'Percentage' THEN 
															vendorTax.[dblTax] 
														ELSE 
															CASE 
																WHEN payables.dblExchangeRate <> 0 THEN 
																	ROUND(
																		dbo.fnDivide(
																			-- Convert the tax to the transaction currency. 
																			vendorTax.[dblTax] 
																			, payables.dblExchangeRate
																		)
																	, 2) 
																ELSE 
																	vendorTax.[dblTax] 
															END 
													END 
				,[dblAdjustedTax]				= 
													CASE 
														WHEN vendorTax.[ysnTaxAdjusted] = 1 THEN 
															vendorTax.[dblAdjustedTax]
														WHEN vendorTax.[strCalculationMethod] = 'Percentage' THEN 
															vendorTax.[dblTax] 
														ELSE 
															CASE 
																WHEN payables.dblExchangeRate <> 0 THEN 
																	ROUND(
																		dbo.fnDivide(
																			-- Convert the tax to the transaction currency. 
																			vendorTax.[dblTax] 
																			, payables.dblExchangeRate
																		)
																	, 2) 
																ELSE 
																	vendorTax.[dblTax] 
															END 
													END
				,[ysnTaxAdjusted]				= vendorTax.[ysnTaxAdjusted]
				,[ysnSeparateOnBill]			= vendorTax.[ysnSeparateOnInvoice]
				,[ysnCheckoffTax]				= vendorTax.[ysnCheckoffTax]
				,[ysnTaxExempt]					= vendorTax.[ysnTaxExempt]
				,[ysnTaxOnly]					= 0
			FROM @voucherPayable payables
			INNER JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = payables.intLoadShipmentDetailId
			INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId AND payables.intLoadShipmentId = L.intLoadId
			INNER JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
			INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
			INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
			INNER JOIN tblAPVendor V ON V.intEntityId = LD.intVendorEntityId
			INNER JOIN tblEMEntityLocation EL ON EL.intEntityId = V.intEntityId AND EL.ysnDefaultLocation = 1
			INNER JOIN tblICItem I ON I.intItemId = LD.intItemId
			left join tblLGLoadCost Cost on Cost.intLoadId = LD.intLoadId and payables.intEntityVendorId = Cost.intVendorId
			left join tblEMEntityLocation LCost ON LCost.intEntityId = Cost.intVendorId AND LCost.ysnDefaultLocation = 1
			OUTER APPLY [dbo].[fnGetItemTaxComputationForVendor](
					payables.intItemId,
					payables.intEntityVendorId,
					GETDATE(),
					-- Cost
					CASE WHEN payables.intWeightUOMId IS NOT NULL AND I.intComputeItemTotalOption = 0 THEN
						dbo.fnCalculateCostBetweenUOM(
							COALESCE(payables.intCostUOMId, payables.intOrderUOMId)
							, payables.intWeightUOMId
							, CASE WHEN payables.ysnSubCurrency = 1 AND ISNULL(payables.intSubCurrencyCents, 0) <> 0 THEN 
									dbo.fnDivide(payables.dblCost, payables.intSubCurrencyCents) 
								ELSE
									payables.dblCost
							END
						)
					ELSE 
						dbo.fnCalculateCostBetweenUOM(
							COALESCE(payables.intCostUOMId, payables.intOrderUOMId)
							, LD.intItemUOMId
							, CASE WHEN payables.ysnSubCurrency = 1 AND ISNULL(payables.intSubCurrencyCents, 0) <> 0 THEN 
									dbo.fnDivide(payables.dblCost, payables.intSubCurrencyCents) 
								ELSE
									payables.dblCost
							END
						)
					END,
					-- Qty
					CASE
						WHEN payables.intWeightUOMId IS NOT NULL AND I.intComputeItemTotalOption = 0 THEN 
							payables.dblNetWeight
						ELSE 
							payables.dblOrderQty 
					END,
					CASE when payables.intLoadShipmentCostId is not null then 
						CASE WHEN ISNULL(CL.intTaxGroupId, '') = '' THEN 
							dbo.fnGetTaxGroupIdForVendor (
								Cost.intVendorId	-- @VendorId
								,ISNULL(L.intCompanyLocationId, CD.intCompanyLocationId)		--,@CompanyLocationId
								,NULL				--,@ItemId
								,LCost.intEntityLocationId		--,@VendorLocationId
								,L.intFreightTermId	--,@FreightTermId
								,default --,@FOB
							)
					
						ELSE CL.intTaxGroupId END					
					WHEN ISNULL(LD.intTaxGroupId, '') = '' THEN @intTaxGroupId ELSE LD.intTaxGroupId END,
					CL.intCompanyLocationId,
					EL.intEntityLocationId,
					1,
					0,
					L.intFreightTermId,
					0,
					ISNULL(payables.intWeightUOMId, payables.intOrderUOMId),
					NULL,
					NULL,
					NULL
				) vendorTax
			WHERE vendorTax.intTaxGroupId IS NOT NULL
		END

	END

	IF (@ysnPost = 1)
	BEGIN
		--UPDATE THE TAX FOR VOUCHER PAYABLE
		UPDATE A
			SET A.dblTax = ISNULL(generatedTax.dblTax, A.dblTax)
		FROM @voucherPayable A
		OUTER APPLY 
		(
			SELECT 
				SUM(C.dblTax) dblTax, C.intTaxGroupId 
			FROM @voucherPayableTax C
			WHERE A.intVoucherPayableId = C.intVoucherPayableId
			GROUP BY C.intTaxGroupId
		) generatedTax

		-- Post Voucher Payables
		EXEC uspAPUpdateVoucherPayableQty @voucherPayable, @voucherPayableTax, 1
	END
	ELSE
	BEGIN
		EXEC uspAPRemoveVoucherPayable @voucherPayable, 0, DEFAULT
	END


END

GO