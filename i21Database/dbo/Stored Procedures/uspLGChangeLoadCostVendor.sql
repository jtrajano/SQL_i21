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
			,[dblExchangeRate] = CASE WHEN (A.intCurrencyId <> @DefaultCurrencyId) THEN 0 ELSE 1 END
			,[ysnSubCurrency] =	CC.ysnSubCurrency
			,[intSubCurrencyCents] = ISNULL(CC.intCent,0)
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
			LEFT JOIN tblSMCurrency CC ON CC.intCurrencyID = A.intCurrencyId
			LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = A.intItemId and ItemLoc.intLocationId = A.intCompanyLocationId
			LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = A.intItemUOMId
			LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
			LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemUOMId = A.intWeightItemUOMId
			LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = ItemWeightUOM.intUnitMeasureId
			LEFT JOIN tblICItemUOM ItemCostUOM ON ItemCostUOM.intItemUOMId = A.intPriceItemUOMId
			LEFT JOIN tblICUnitMeasure CostUOM ON CostUOM.intUnitMeasureId = ItemCostUOM.intUnitMeasureId
			INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON @intNewVendorEntityId = D1.[intEntityId]
			OUTER APPLY dbo.fnGetItemGLAccountAsTable(
							A.intItemId,
							ItemLoc.intItemLocationId,
							CASE WHEN (CP.ysnEnableAccrualsForOutbound = 1 AND L.intPurchaseSale = 2 AND A.ysnAccrue = 1 AND A.intEntityVendorId IS NOT NULL)
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
			WHERE A.intLoadCostId = @intLoadCostId
            AND A.intLoadDetailId NOT IN 
                (SELECT IsNull(BD.intLoadDetailId, 0) FROM tblAPBillDetail BD JOIN tblICItem Item ON Item.intItemId = BD.intItemId
                WHERE BD.intItemId = A.intItemId AND Item.strType = 'Other Charge' AND ISNULL(A.ysnAccrue,0) = 1)
            AND NOT (COC.ysnCreateOtherCostPayable = 1 AND CTC.intContractCostId IS NOT NULL)

            -- Call SP from AP to update the vendor in the payables
            EXEC uspAPUpdateVoucherPayableVendor
                @voucherPayable
                ,DEFAULT
                ,@intEntityUserSecurityId
	END TRY

	BEGIN CATCH	
		DECLARE @ErrorMerssage NVARCHAR(MAX)
		SELECT @ErrorMerssage = ERROR_MESSAGE()									
		RAISERROR(@ErrorMerssage, 11, 1);
	END CATCH
END
GO