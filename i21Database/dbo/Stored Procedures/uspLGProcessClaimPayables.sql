CREATE PROCEDURE [dbo].[uspLGProcessClaimPayables]
	@intWeightClaimId INT = NULL
	,@intWeightClaimChargeId INT = NULL
	,@ysnPost BIT
	,@intEntityUserSecurityId INT = NULL
AS
BEGIN
	DECLARE @voucherPayable VoucherPayable
	DECLARE @DefaultCurrencyId INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')
	DECLARE @voucherPayableTax AS VoucherDetailTax
	DECLARE @intTaxGroupId INT
	DECLARE @intFunctionalCurrencyId AS INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')

	IF (@intWeightClaimId IS NOT NULL)
	BEGIN
		-- Get tax group
		--SELECT TOP 1
		--	@intTaxGroupId = dbo.fnGetTaxGroupIdForVendor (
		--		WCD.intPartyEntityId
		--		,ISNULL(L.intCompanyLocationId, CD.intCompanyLocationId)
		--		,NULL
		--		,EL.intEntityLocationId
		--		,L.intFreightTermId
		--		,default
		--	)
		--FROM tblLGWeightClaim WC
		--INNER JOIN tblLGWeightClaimDetail WCD ON WCD.intWeightClaimId = WC.intWeightClaimId
		--INNER JOIN tblLGLoad L ON L.intLoadId = WC.intLoadId
		--OUTER APPLY (SELECT TOP 1 ld.intLoadDetailId FROM tblLGLoadDetail ld 
		--				 LEFT JOIN tblLGLoadDetailContainerLink ldcl on ldcl.intLoadDetailId = ld.intLoadDetailId 
		--					AND ld.intPContractDetailId = WCD.intContractDetailId
		--				 WHERE ld.intLoadId = L.intLoadId 
		--					AND (WCD.intLoadContainerId IS NULL 
		--					 OR (WCD.intLoadContainerId IS NOT NULL AND WCD.intLoadContainerId = ldcl.intLoadContainerId))) LD
		--INNER JOIN tblCTContractDetail CD ON CD.intContractDetailId = WCD.intContractDetailId
		--INNER JOIN tblAPVendor V ON V.intEntityId = WCD.intPartyEntityId
		--INNER JOIN tblEMEntityLocation EL ON EL.intEntityId = V.intEntityId AND EL.ysnDefaultLocation = 1	
		--WHERE WC.intWeightClaimId = @intWeightClaimId

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
			,[intLoadShipmentId]
			,[intLoadShipmentDetailId]
			,[strLoadShipmentNumber]
			,[strBillOfLading]
			,[intWeightClaimId]
			,[intWeightClaimDetailId]
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
			,[dblNetShippedWeight]
			,[dblWeightLoss]		
			,[dblFranchiseWeight]
			,[dblFranchiseAmount]	
			,[dblWeightUnitQty]
			,[intWeightUOMId]
			,[intCostCurrencyId]
			,[dblTax]
			,[dblDiscount]
			,[dblExchangeRate]
			,[ysnSubCurrency]
			,[intSubCurrencyCents]
			,[intAccountId]
			,[ysnReturn]
			,[ysnStage]
			,[intSubLocationId]
			,[intStorageLocationId])
		SELECT
			[intEntityVendorId] = WCD.intPartyEntityId
			,[intTransactionType] = CASE WHEN WCD.dblWeightLoss < 0 THEN 11 ELSE 1 END
			,[intLocationId] = CD.intCompanyLocationId
			,[intCurrencyId] = ISNULL(CU.intMainCurrencyId, CU.intCurrencyID)
			,[dtmDate] = GETDATE()
			,[strVendorOrderNumber] = ''
			,[strReference] = ''
			,[strSourceNumber] = LTRIM(WC.strReferenceNumber)
			,[intContractHeaderId] = CH.intContractHeaderId
			,[intContractDetailId] = CD.intContractDetailId
			,[intContractSeqId] = CD.intContractSeq
			,[intLoadShipmentId] = WC.intLoadId
			,[intLoadShipmentDetailId] = LD.intLoadDetailId
			,[strLoadShipmentNumber] = LTRIM(L.strLoadNumber)
			,[strBillOfLading] = L.strBLNumber
			,[intWeightClaimId] = WC.intWeightClaimId
			,[intWeightClaimDetailId] = WCD.intWeightClaimDetailId
			,[intItemId] = WCD.intItemId
			,[strMiscDescription] = I.strDescription
			,[dblOrderQty] = ABS(WCD.dblClaimableWt)
			,[dblOrderUnitQty] = ItemUOM.dblUnitQty
			,[intOrderUOMId] = ItemUOM.intItemUOMId
			,[dblQuantityToBill] = ABS(WCD.dblClaimableWt)
			,[dblQtyToBillUnitQty] = ItemUOM.dblUnitQty
			,[intQtyToBillUOMId] = ItemUOM.intItemUOMId
			,[dblCost] = WCD.dblUnitPrice
			,[dblCostUnitQty] = IU.dblUnitQty
			,[intCostUOMId] = WCD.intPriceItemUOMId
			,[dblNetWeight] = ABS(WCD.dblClaimableWt) --CASE WHEN (strCondition = 'Missing') THEN WCD.dblFromNet ELSE WCD.dblToNet END
			,[dblNetShippedWeight] = WCD.dblFromNet
			,[dblWeightLoss] = ABS(WCD.dblWeightLoss)
			,[dblFranchiseWeight] = CASE WHEN WCD.dblWeightLoss > 0 THEN 0 ELSE WCD.dblFranchiseWt END
			,[dblFranchiseAmount] = ROUND((dbo.fnCTConvertQtyToTargetItemUOM(ItemUOM.intItemUOMId, WCD.intPriceItemUOMId, dblUnitPrice) * dblFranchiseWt)
										/ CASE WHEN (CU.ysnSubCurrency = 1) THEN 100 ELSE 1 END, 2)
			,[dblWeightUnitQty] = ItemUOM.dblUnitQty
			,[intWeightUOMId] = ItemUOM.intItemUOMId
			,[intCostCurrencyId] = CU.intCurrencyID
			,[dblTax] = 0
			,[dblDiscount] = 0
			,[dblExchangeRate] = CASE WHEN (@intFunctionalCurrencyId <> ISNULL(CU.intMainCurrencyId, CU.intCurrencyID)) 
								THEN ISNULL(FX.dblFXRate, 1) ELSE 1 END
			,[ysnSubCurrency] = CU.ysnSubCurrency
			,[intSubCurrencyCents] = CU.intCent
			,[intAccountId] = CASE WHEN (WCD.dblWeightLoss < 0) THEN dbo.fnGetItemGLAccount(I.intItemId, IL.intItemLocationId, 'AP Clearing') ELSE V.intGLAccountExpenseId END 
			,[ysnReturn] = CAST(CASE WHEN (WCD.dblWeightLoss < 0) THEN 1 ELSE 0 END AS BIT)
			,[ysnStage] = CAST(1 AS BIT)
			,[intSubLocationId] = CD.intSubLocationId
			,[intStorageLocationId] = CD.intStorageLocationId
		FROM tblLGWeightClaim WC
			JOIN tblLGWeightClaimDetail WCD ON WC.intWeightClaimId = WCD.intWeightClaimId
			JOIN tblLGLoad L ON L.intLoadId = WC.intLoadId
			JOIN tblCTContractDetail CD ON CD.intContractDetailId = WCD.intContractDetailId
			JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
			LEFT JOIN tblAPVendor V ON V.intEntityId = WCD.intPartyEntityId
			LEFT JOIN tblICItem I ON I.intItemId = WCD.intItemId
			LEFT JOIN tblICItemLocation IL ON IL.intItemId = WCD.intItemId AND IL.intLocationId = CD.intCompanyLocationId
			LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = WCD.intPriceItemUOMId
			LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = WCD.intCurrencyId
			LEFT JOIN tblICUnitMeasure WUOM ON WUOM.intUnitMeasureId = L.intWeightUnitMeasureId
			LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemId = WCD.intItemId AND ItemUOM.intUnitMeasureId = WUOM.intUnitMeasureId
			OUTER APPLY (SELECT TOP 1 ld.intLoadDetailId FROM tblLGLoadDetail ld 
						 LEFT JOIN tblLGLoadDetailContainerLink ldcl on ldcl.intLoadDetailId = ld.intLoadDetailId 
							AND ld.intPContractDetailId = WCD.intContractDetailId
						 WHERE ld.intLoadId = L.intLoadId 
							AND (WCD.intLoadContainerId IS NULL 
							 OR (WCD.intLoadContainerId IS NOT NULL AND WCD.intLoadContainerId = ldcl.intLoadContainerId))) LD
			OUTER APPLY (
				SELECT	TOP 1  
					intForexRateTypeId = ERD.intRateTypeId
					,strRateType = ERT.strCurrencyExchangeRateType
					,dblFXRate = CASE WHEN ER.intFromCurrencyId = @intFunctionalCurrencyId  
								THEN 1/ERD.[dblRate] 
								ELSE ERD.[dblRate] END 
					FROM tblSMCurrencyExchangeRate ER JOIN tblSMCurrencyExchangeRateDetail ERD ON ERD.intCurrencyExchangeRateId = ER.intCurrencyExchangeRateId
					LEFT JOIN tblSMCurrencyExchangeRateType ERT ON ERT.intCurrencyExchangeRateTypeId = ERD.intRateTypeId
					WHERE @intFunctionalCurrencyId <> WCD.intCurrencyId
						AND ((ER.intFromCurrencyId = ISNULL(CU.intMainCurrencyId, CU.intCurrencyID) AND ER.intToCurrencyId = @intFunctionalCurrencyId) 
							OR (ER.intFromCurrencyId = @intFunctionalCurrencyId AND ER.intToCurrencyId = ISNULL(CU.intMainCurrencyId, CU.intCurrencyID)))
					ORDER BY ERD.dtmValidFromDate DESC) FX
		WHERE WC.intWeightClaimId = @intWeightClaimId
		AND ISNULL(WCD.ysnNoClaim, 0) = 0
		AND ISNULL(WCD.dblClaimAmount, 0) <> 0
		
		
		-- Assemble Item Taxes
		--BEGIN
		--	INSERT INTO @voucherPayableTax (
		--		[intVoucherPayableId]
		--		,[intTaxGroupId]				
		--		,[intTaxCodeId]				
		--		,[intTaxClassId]				
		--		,[strTaxableByOtherTaxes]	
		--		,[strCalculationMethod]		
		--		,[dblRate]					
		--		,[intAccountId]				
		--		,[dblTax]					
		--		,[dblAdjustedTax]			
		--		,[ysnTaxAdjusted]			
		--		,[ysnSeparateOnBill]			
		--		,[ysnCheckOffTax]		
		--		,[ysnTaxExempt]	
		--		,[ysnTaxOnly]
		--	)
		--	SELECT 
		--		[intVoucherPayableId]			= payables.intVoucherPayableId
		--		,[intTaxGroupId]				= CASE WHEN ISNULL(LD.intTaxGroupId, '') = '' THEN @intTaxGroupId ELSE LD.intTaxGroupId END
		--		,[intTaxCodeId]					= vendorTax.[intTaxCodeId]
		--		,[intTaxClassId]				= vendorTax.[intTaxClassId]
		--		,[strTaxableByOtherTaxes]		= vendorTax.[strTaxableByOtherTaxes]
		--		,[strCalculationMethod]			= vendorTax.[strCalculationMethod]
		--		,[dblRate]						= vendorTax.[dblRate]
		--		,[intAccountId]					= vendorTax.[intTaxAccountId]
		--		,[dblTax]						=	CASE 
		--												WHEN vendorTax.[strCalculationMethod] = 'Percentage' THEN 
		--													vendorTax.[dblTax] 
		--												ELSE 
		--													CASE 
		--														WHEN payables.dblExchangeRate <> 0 THEN 
		--															ROUND(
		--																dbo.fnDivide(
		--																	-- Convert the tax to the transaction currency. 
		--																	vendorTax.[dblTax] 
		--																	, payables.dblExchangeRate
		--																)
		--															, 2) 
		--														ELSE 
		--															vendorTax.[dblTax] 
		--													END 
		--											END 
		--		,[dblAdjustedTax]				= 
		--											CASE 
		--												WHEN vendorTax.[ysnTaxAdjusted] = 1 THEN 
		--													vendorTax.[dblAdjustedTax]
		--												WHEN vendorTax.[strCalculationMethod] = 'Percentage' THEN 
		--													vendorTax.[dblTax] 
		--												ELSE 
		--													CASE 
		--														WHEN payables.dblExchangeRate <> 0 THEN 
		--															ROUND(
		--																dbo.fnDivide(
		--																	-- Convert the tax to the transaction currency. 
		--																	vendorTax.[dblTax] 
		--																	, payables.dblExchangeRate
		--																)
		--															, 2) 
		--														ELSE 
		--															vendorTax.[dblTax] 
		--													END 
		--											END
		--		,[ysnTaxAdjusted]				= vendorTax.[ysnTaxAdjusted]
		--		,[ysnSeparateOnBill]			= vendorTax.[ysnSeparateOnInvoice]
		--		,[ysnCheckoffTax]				= vendorTax.[ysnCheckoffTax]
		--		,[ysnTaxExempt]					= vendorTax.[ysnTaxExempt]
		--		,[ysnTaxOnly]					= 0
		--	FROM @voucherPayable payables
		--	INNER JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = payables.intLoadShipmentDetailId
		--	INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId AND payables.intLoadShipmentId = L.intLoadId
		--	INNER JOIN tblCTContractDetail CD ON CD.intContractDetailId = payables.intContractDetailId
		--	INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		--	INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
		--	INNER JOIN tblAPVendor V ON V.intEntityId = payables.intEntityVendorId
		--	INNER JOIN tblEMEntityLocation EL ON EL.intEntityId = V.intEntityId AND EL.ysnDefaultLocation = 1
		--	INNER JOIN tblICItem I ON I.intItemId = LD.intItemId
		--	OUTER APPLY [dbo].[fnGetItemTaxComputationForVendor](
		--			payables.intItemId,
		--			payables.intEntityVendorId,
		--			GETDATE(),
		--			-- Cost
		--			CASE WHEN payables.intWeightUOMId IS NOT NULL AND I.intComputeItemTotalOption = 0 THEN
		--				dbo.fnCalculateCostBetweenUOM(
		--					COALESCE(payables.intCostUOMId, payables.intOrderUOMId)
		--					, payables.intWeightUOMId
		--					, CASE WHEN payables.ysnSubCurrency = 1 AND ISNULL(payables.intSubCurrencyCents, 0) <> 0 THEN 
		--							dbo.fnDivide(payables.dblCost, payables.intSubCurrencyCents) 
		--						ELSE
		--							payables.dblCost
		--					END
		--				)
		--			ELSE 
		--				dbo.fnCalculateCostBetweenUOM(
		--					COALESCE(payables.intCostUOMId, payables.intOrderUOMId)
		--					, LD.intItemUOMId
		--					, CASE WHEN payables.ysnSubCurrency = 1 AND ISNULL(payables.intSubCurrencyCents, 0) <> 0 THEN 
		--							dbo.fnDivide(payables.dblCost, payables.intSubCurrencyCents) 
		--						ELSE
		--							payables.dblCost
		--					END
		--				)
		--			END,
		--			-- Qty
		--			CASE
		--				WHEN payables.intWeightUOMId IS NOT NULL AND I.intComputeItemTotalOption = 0 THEN 
		--					payables.dblNetWeight
		--				ELSE 
		--					payables.dblOrderQty 
		--			END,
		--			CASE WHEN ISNULL(LD.intTaxGroupId, '') = '' THEN @intTaxGroupId ELSE LD.intTaxGroupId END,
		--			CL.intCompanyLocationId,
		--			EL.intEntityLocationId,
		--			1,
		--			0,
		--			L.intFreightTermId,
		--			0,
		--			ISNULL(payables.intWeightUOMId, payables.intOrderUOMId),
		--			NULL,
		--			NULL,
		--			NULL
		--		) vendorTax
		--	WHERE vendorTax.intTaxGroupId IS NOT NULL
		--END

	END

	IF (@ysnPost = 1)
	BEGIN
		--UPDATE THE TAX FOR VOUCHER PAYABLE
		--UPDATE A
		--	SET A.dblTax = ISNULL(generatedTax.dblTax, A.dblTax)
		--FROM @voucherPayable A
		--OUTER APPLY 
		--(
		--	SELECT 
		--		SUM(C.dblTax) dblTax, C.intTaxGroupId 
		--	FROM @voucherPayableTax C
		--	WHERE A.intVoucherPayableId = C.intVoucherPayableId
		--	GROUP BY C.intTaxGroupId
		--) generatedTax

		-- Post Voucher Payables
		EXEC uspAPUpdateVoucherPayableQty @voucherPayable, DEFAULT, 1
	END
	ELSE
	BEGIN
		EXEC uspAPRemoveVoucherPayable @voucherPayable, 0, DEFAULT
	END


END

GO