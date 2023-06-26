CREATE PROCEDURE [dbo].[uspLGChangeLoadCostVendor]
	@intLoadCostId INT
    ,@intNewVendorEntityId INT
	,@intEntityUserSecurityId INT
AS
BEGIN
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT OFF
	SET ANSI_WARNINGS OFF

    BEGIN TRY
        DECLARE @voucherPayable VoucherPayable		
		DECLARE @voucherPayableTax AS VoucherDetailTax
        DECLARE @DefaultCurrencyId INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')

        -- The following logic was copied from uspLGProcessPayables
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
			,[dblExchangeRate]
			,[intCurrencyExchangeRateTypeId]
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
			,[intLocationId] = LD.intCompanyLocationId
			,[intCurrencyId] = LD.intCurrencyID
			,[dtmDate] = L.dtmScheduledDate
			,[strVendorOrderNumber] = ''
			,[strReference] = ''
			,[strSourceNumber] = LTRIM(L.strLoadNumber)
			,[intContractHeaderId] = LD.intContractHeaderId
			,[intContractDetailId] = LD.intContractDetailId
			,[intContractSeqId] = LD.intContractSeq
			,[intContractCostId] = LD.intContractCostId
			,[intInventoryReceiptItemId] = NULL
			,[intLoadShipmentId] = L.intLoadId
			,[strLoadShipmentNumber] = LTRIM(L.strLoadNumber)
			,[intLoadShipmentDetailId] = NULL--A.intLoadDetailId
			,[intLoadShipmentCostId] = LC.intLoadCostId
			,[intItemId] = LC.intItemId
			,[strMiscDescription] = CASE WHEN ISNULL(ICI.[strDescription], '') = ''
										THEN ICI.[strItemNo]
										ELSE ICI.[strDescription]
									END
			,[dblOrderQty] = CASE WHEN LC.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE LD.dblQuantity END
			,[dblOrderUnitQty] = CASE WHEN LC.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE ISNULL(LD.dblUnitQty,1) END
			,[intOrderUOMId] = LD.intItemUOMId
			,[dblQuantityToBill] = CASE WHEN LC.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE LD.dblQuantity END
			,[dblQtyToBillUnitQty] = CASE WHEN LC.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE ISNULL(LD.dblUnitQty,1) END
			,[intQtyToBillUOMId] = LD.intItemUOMId
			,[dblCost] = CASE WHEN LC.strCostMethod IN ('Amount','Percentage') THEN ISNULL(LC.dblAmount, LC.dblRate) ELSE ISNULL(LC.dblRate, LC.dblAmount) END 
			,[dblCostUnitQty] = CASE WHEN LC.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE ISNULL(ItemCostUOM.dblUnitQty,1) END
			,[intCostUOMId] = CASE WHEN LC.strCostMethod IN ('Amount','Percentage') THEN NULL ELSE LC.intItemUOMId END
			,[dblNetWeight] = 0
			,[dblWeightUnitQty] = 1
			,[intWeightUOMId] = NULL
			,[intCostCurrencyId] = LD.intCurrencyID
			,[intFreightTermId] = NULL
			,[dblTax] = 0
			,[dblDiscount] = 0
			,[dblExchangeRate] = LC.dblFX
			,[intCurrencyExchangeRateTypeId] = FX.intForexRateTypeId
			,[ysnSubCurrency] =	LD.ysnSubCurrency
			,[intSubCurrencyCents] = ISNULL(LD.intCent,0)
			,[intAccountId] = LD.intAccountId
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
		FROM tblLGLoadCost LC
			OUTER APPLY tblLGCompanyPreference CP
			JOIN tblLGLoad L ON L.intLoadId = LC.intLoadId
			JOIN tblAPVendor ARC ON LC.intVendorId = ARC.intEntityId
			JOIN tblICItem ICI ON ICI.intItemId = LC.intItemId
			CROSS APPLY (
				SELECT SUM(LD.dblQuantity) dblQuantity
					,CUR.intCurrencyID
					,CTC.intContractCostId
					,CH.intContractHeaderId
					,CT.intContractDetailId
					,CT.intContractSeq
					,IUOM.intItemUOMId
					,ItemUOM.dblUnitQty
					,CC.ysnSubCurrency
					,CC.intCent
					,apClearing.intAccountId
					,[intCompanyLocationId] = CASE WHEN (L.intPurchaseSale = 2) THEN LD.intSCompanyLocationId ELSE LD.intPCompanyLocationId END
				FROM tblLGLoadDetail LD
				JOIN tblCTContractDetail CT ON CT.intContractDetailId = CASE WHEN (CP.ysnEnableAccrualsForOutbound = 1 AND L.intPurchaseSale = 2 AND LC.ysnAccrue = 1 AND LC.intVendorId IS NOT NULL) 
																	THEN LD.intSContractDetailId ELSE LD.intPContractDetailId END
				JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CT.intContractHeaderId
				JOIN tblSMCurrency C ON C.intCurrencyID = L.intCurrencyId
				LEFT JOIN tblSMCurrency CUR ON CUR.intCurrencyID = COALESCE(LC.intCurrencyId, ARC.[intCurrencyId],
					(SELECT TOP 1 intDefaultCurrencyId
					FROM tblSMCompanyPreference
					WHERE intDefaultCurrencyId IS NOT NULL
						AND intDefaultCurrencyId <> 0
					))
				LEFT JOIN tblSMCurrency CC ON CC.intCurrencyID = CUR.intCurrencyID
				LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = LC.intItemId and ItemLoc.intLocationId = CASE WHEN (L.intPurchaseSale = 2) THEN LD.intSCompanyLocationId ELSE LD.intPCompanyLocationId END
				OUTER APPLY (
					SELECT intItemUOMId = dbo.fnGetMatchingItemUOMId(ICI.[intItemId], LD.intItemUOMId)
				) IUOM
				OUTER APPLY (
					SELECT intWeightItemUOMId = dbo.fnGetMatchingItemUOMId(ICI.[intItemId], LD.intWeightItemUOMId)
				) WUOM
				LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = IUOM.intItemUOMId
				LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
				LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemUOMId = WUOM.intWeightItemUOMId
				LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = ItemWeightUOM.intUnitMeasureId
				OUTER APPLY dbo.fnGetItemGLAccountAsTable(
							LC.intItemId,
							ItemLoc.intItemLocationId,
							'AP Clearing'
						) itemAccnt
				LEFT JOIN dbo.tblGLAccount apClearing ON apClearing.intAccountId = itemAccnt.intAccountId
				OUTER APPLY (SELECT TOP 1 CTC.intContractCostId FROM tblCTContractCost CTC
						WHERE CT.intContractDetailId = CTC.intContractDetailId
							AND LC.intItemId = CTC.intItemId
							AND LC.intVendorId = CTC.intVendorId
						) CTC
				WHERE LD.intLoadId = L.intLoadId
					AND LD.intLoadDetailId NOT IN 
					(SELECT IsNull(BD.intLoadDetailId, 0) FROM tblAPBillDetail BD JOIN tblICItem Item ON Item.intItemId = BD.intItemId
					WHERE BD.intItemId = LC.intItemId AND Item.strType = 'Other Charge' AND ISNULL(LC.ysnAccrue,0) = 1)
				GROUP BY
					CUR.intCurrencyID
					,CTC.intContractCostId
					,CH.intContractHeaderId
					,CT.intContractDetailId
					,CT.intContractSeq
					,IUOM.intItemUOMId
					,ItemUOM.dblUnitQty
					,CC.ysnSubCurrency
					,CC.intCent
					,apClearing.intAccountId
					,LD.intSCompanyLocationId
					,LD.intPCompanyLocationId
			) LD
			LEFT JOIN tblICItemUOM ItemCostUOM ON ItemCostUOM.intItemUOMId = LC.intItemUOMId
			LEFT JOIN tblICUnitMeasure CostUOM ON CostUOM.intUnitMeasureId = ItemCostUOM.intUnitMeasureId
			INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON @intNewVendorEntityId = D1.[intEntityId]
			
			LEFT JOIN tblSMCurrency SC ON SC.intCurrencyID = LD.intCurrencyID
			OUTER APPLY (SELECT TOP 1 ysnCreateOtherCostPayable = ISNULL(ysnCreateOtherCostPayable, 0) FROM tblCTCompanyPreference) COC
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
			WHERE LC.intLoadCostId = @intLoadCostId
            
            AND NOT (COC.ysnCreateOtherCostPayable = 1 AND LD.intContractCostId IS NOT NULL)


			-- Assemble Item Taxes  @@@Copied From uspLGProcessPayables
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
				SELECT 
					[intVoucherPayableId]			= payables.intVoucherPayableId
					,[intTaxGroupId]				= CL.intTaxGroupId
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
				LEFT JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = payables.intLoadShipmentDetailId
				INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId AND payables.intLoadShipmentId = L.intLoadId
				LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
				LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
				LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
				LEFT JOIN tblAPVendor V ON V.intEntityId = LD.intVendorEntityId
				LEFT JOIN tblEMEntityLocation EL ON EL.intEntityId = V.intEntityId AND EL.ysnDefaultLocation = 1
				LEFT JOIN tblICItem I ON I.intItemId = LD.intItemId
				left join tblLGLoadCost Cost on Cost.intLoadId = LD.intLoadId and @intNewVendorEntityId = Cost.intVendorId
				left join tblEMEntityLocation LCost ON LCost.intEntityId =@intNewVendorEntityId AND LCost.ysnDefaultLocation = 1
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
						CL.intTaxGroupId,
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

			--UPDATE THE TAX FOR VOUCHER PAYABLE  @@@Copied From uspLGProcessPayables
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

            -- Call SP from AP to update the vendor in the payables
            EXEC uspAPUpdateVoucherPayableVendor
                @voucherPayable
                ,@voucherPayableTax
                ,@intEntityUserSecurityId
	END TRY

	BEGIN CATCH	
		DECLARE @ErrorMerssage NVARCHAR(MAX)
		SELECT @ErrorMerssage = ERROR_MESSAGE()									
		RAISERROR(@ErrorMerssage, 11, 1);
	END CATCH
END
GO