CREATE FUNCTION [dbo].[fnCTCreateVoucherPayable]
(
	@id INT,
	@type NVARCHAR(10),
	@accrue BIT = 1,
	@remove BIT = 0
)
RETURNS TABLE AS RETURN
(
	SELECT	DISTINCT
		[intEntityVendorId]							=	ISNULL(entity.intEntityId, payable.intEntityVendorId)
		,[intTransactionType]						=	CASE WHEN RT.Item = 0 THEN 1 ELSE 3 END --voucher
		,[intLocationId]							=	CD.intCompanyLocationId
		,[intShipToId]								=	NULL --?
		,[intShipFromId]							=	NULL --?
		,[intShipFromEntityId]						=	NULL --?
		,[intPayToAddressId]						=	NULL --?
		,[intCurrencyId]							=	CASE WHEN CY.ysnSubCurrency > 0 
														THEN (SELECT ISNULL(intMainCurrencyId,0) FROM dbo.tblSMCurrency WHERE intCurrencyID = ISNULL(CC.intCurrencyId,0))
														ELSE  ISNULL(CC.intCurrencyId,ISNULL(CU.intMainCurrencyId,CD.intCurrencyId))
														END
		,[dtmDate]									=	CD.dtmStartDate
		,[strVendorOrderNumber]						=  	'' --? 
		,[strReference]								=	'' --?
		,[strSourceNumber]							=	LTRIM(CH.strContractNumber)
		,[intPurchaseDetailId]						=	NULL
		,[intContractHeaderId]						=	CD.intContractHeaderId
		,[intContractDetailId]						=	CD.intContractDetailId
		,[intContractSequence]						=	CD.intContractSeq
		,[intContractCostId]						=	CC.intContractCostId
		,[intScaleTicketId]							=	NULL
		,[intInventoryReceiptItemId]				=	NULL
		,[intInventoryReceiptChargeId]				=	NULL
		,[intInventoryShipmentItemId]				=   NULL
		,[intInventoryShipmentChargeId]				=	NULL
		,[intLoadShipmentId]						=	NULL --?
		,[intLoadShipmentDetailId]					=	NULL --?
		,[intItemId]								=	CC.intItemId
		,[intPurchaseTaxGroupId]					=	NULL
		,[strMiscDescription]						=	CC.strItemDescription
		,[dblOrderQty]								=	CASE WHEN CC.strCostMethod = 'Per Unit' THEN ISNULL(CD.dblQuantity,0) ELSE 1 END
		,[dblOrderUnitQty]							=	1
		,[intOrderUOMId]							=	ISNULL(ItemUOM.intItemUOMId,CD.intItemUOMId)
		,[dblQuantityToBill]						=	CASE WHEN CC.strCostMethod = 'Per Unit' THEN ISNULL(CD.dblQuantity,0) ELSE 1 END
		,[dblQtyToBillUnitQty]						=	1
		,[intQtyToBillUOMId]						=	ISNULL(ItemUOM.intItemUOMId,CD.intItemUOMId)
		,[dblCost]									=	CASE WHEN CC.strCostMethod = 'Per Unit' THEN ISNULL(CC.dblRate,0) ELSE ISNULL(CC.dblAmount,0) END
		,[dblCostUnitQty]							=	1
		,[intCostUOMId]								=	ISNULL(CostUOM.intItemUOMId,CD.intItemUOMId)
		,[dblNetWeight]								=	CASE 
															WHEN CC.strCostMethod = 'Per Unit' THEN CAST(dbo.fnMFConvertCostToTargetItemUOM(CostUOM.intItemUOMId,WeightUOM.intItemUOMId,CD.dblNetWeight) AS DECIMAL(38,20)) 
															ELSE 
																CASE WHEN CostUOM.intItemUOMId IS NULL THEN 0
																ELSE ISNULL(CC.dblAmount,0) 
															END
														END
		,[dblWeightUnitQty]							=	CAST(1 AS DECIMAL(38,20))
		,[intWeightUOMId]							=	CASE WHEN CC.strCostMethod = 'Per Unit' THEN ISNULL(CostUOM.intItemUOMId,CD.intItemUOMId) ELSE CostUOM.intItemUOMId END
		,[intCostCurrencyId]						=	ISNULL(CC.intCurrencyId,ISNULL(CU.intMainCurrencyId,CD.intCurrencyId))
		,[dblTax]									=	0
		,[dblDiscount]								=	0
		,[intCurrencyExchangeRateTypeId]			=	CC.intRateTypeId
		,[dblExchangeRate]							=	CC.dblFX
		,[ysnSubCurrency]							=	ISNULL(CY.ysnSubCurrency,0)
		,[intSubCurrencyCents]						=	CASE WHEN CY.ysnSubCurrency > 0 THEN CY.intCent ELSE 1 END
		,[intAccountId]								=	apClearing.intAccountId
		,[intShipViaId]								=	null
		,[intTermId]								=	CC.intTermId	
		,[strBillOfLading]							=	NULL
		,[ysnReturn]								=	CAST(RT.Item AS BIT)	
	FROM vyuCTContractCostView CC	
	CROSS APPLY ( select ysnMultiplePriceFixation from tblCTCompanyPreference ) CPT
	JOIN tblCTContractDetail CD	ON CD.intContractDetailId = CC.intContractDetailId AND (CC.ysnPrice = 1 AND CD.intPricingTypeId IN (1,6) 
			OR CC.ysnAccrue = CASE 
				WHEN CPT.ysnMultiplePriceFixation = 0 AND @accrue = 1 THEN 1 
				ELSE CC.ysnAccrue 
			END
		) 
		AND (CASE WHEN @remove = 0 AND CC.intConcurrencyId <> CC.intPrevConcurrencyId THEN 1 ELSE @remove END = 1)
	JOIN tblCTContractHeader CH	ON	CH.intContractHeaderId = CD.intContractHeaderId
	LEFT JOIN (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON CC.intVendorId = D1.[intEntityId] 

	INNER JOIN tblICItem item ON item.intItemId = CC.intItemId 
	CROSS APPLY tblSMCompanyPreference compPref
	LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = CD.intCurrencyId
	LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = CC.intItemId AND ItemLoc.intLocationId = CD.intCompanyLocationId
	LEFT JOIN tblICInventoryReceiptCharge RC ON	RC.intContractId = CC.intContractHeaderId AND RC.intChargeId = CC.intItemId
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = CD.intItemUOMId
	LEFT JOIN tblICItemUOM CostUOM ON CostUOM.intItemId = CD.intItemId AND CostUOM.intUnitMeasureId = CC.intUnitMeasureId
	LEFT JOIN tblICItemUOM WeightUOM ON WeightUOM.intItemId = CD.intItemId AND WeightUOM.intItemUOMId = CD.intNetWeightUOMId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	LEFT JOIN tblICStorageLocation SLOC ON SLOC.intStorageLocationId = CD.intStorageLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation subLoc ON	CD.intSubLocationId = subLoc.intCompanyLocationSubLocationId
	LEFT JOIN tblSMCurrencyExchangeRate F ON  (F.intFromCurrencyId = compPref.intDefaultCurrencyId AND F.intToCurrencyId = CC.intCurrencyId) 
	LEFT JOIN tblSMCurrencyExchangeRateDetail G1 ON F.intCurrencyExchangeRateId = G1.intCurrencyExchangeRateId AND G1.dtmValidFromDate = (SELECT CONVERT(char(10), GETDATE(),126))
	LEFT JOIN tblSMCurrency CY ON CY.intCurrencyID = CC.intCurrencyId
	LEFT JOIN tblSMCurrencyExchangeRate Rate ON Rate.intFromCurrencyId = compPref.intDefaultCurrencyId AND Rate.intToCurrencyId = CU.intMainCurrencyId
	LEFT JOIN tblSMCurrencyExchangeRateDetail RateDetail ON Rate.intCurrencyExchangeRateId = RateDetail.intCurrencyExchangeRateId
	LEFT JOIN vyuPATEntityPatron patron ON patron.intEntityId = CC.intItemId
	LEFT JOIN tblSMCurrencyExchangeRateType rtype ON rtype.intCurrencyExchangeRateTypeId = CC.intRateTypeId
	LEFT JOIN tblSMTerm term ON term.intTermID =  CC.intTermId
	OUTER APPLY dbo.fnGetItemGLAccountAsTable(CC.intItemId, ItemLoc.intItemLocationId,  case
																						when CC.strCostType = 'Other Charges'
																						or (
																								select
																									count(1)
																								from
																									tblICInventoryReceiptItem a
																									,tblICInventoryReceipt b
																								where
																									a.intOrderId = CD.intContractHeaderId
																									and a.intLineNo = CD.intContractDetailId
																									and b.intInventoryReceiptId = a.intInventoryReceiptId
																							) = 0
																						then 'Other Charge Expense'
																						else 'AP Clearing' 
																						end
											) itemAccnt
	LEFT JOIN dbo.tblGLAccount apClearing ON apClearing.intAccountId = itemAccnt.intAccountId
	OUTER APPLY 
	(
		SELECT TOP 1 dblRate as forexRate from tblSMCurrencyExchangeRateDetail G1
		WHERE F.intCurrencyExchangeRateId = G1.intCurrencyExchangeRateId AND G1.dtmValidFromDate < (SELECT CONVERT(char(10), GETDATE(),126))
		ORDER BY G1.dtmValidFromDate DESC
	) rate
	CROSS JOIN  dbo.fnSplitString('0,1',',') RT
	-- FOR REVIEW
	OUTER APPLY 
	(
		SELECT TOP 1 intEntityVendorId 
		FROM tblAPVoucherPayable
		WHERE CASE 
			WHEN @type = 'header' AND intContractHeaderId = @id THEN 1
			WHEN @type = 'cost' AND intContractCostId = @id THEN 1
			ELSE 0
		END = 1
	) payable
	LEFT JOIN
	(
		SELECT intEntityId 
		FROM tblEMEntity
	) entity ON entity.intEntityId = CC.intVendorId OR entity.intEntityId = (CASE WHEN CC.ysnPrice = 1 AND CH.intContractTypeId = 1 THEN CH.intEntityId ELSE CC.intVendorId END)
	WHERE RC.intInventoryReceiptChargeId IS NULL AND CC.ysnAccrue = @accrue AND --CC.ysnBasis = 0 AND
	NOT EXISTS(SELECT 1 FROM tblICInventoryShipmentCharge WHERE intContractDetailId = CD.intContractDetailId AND intChargeId = CC.intItemId) AND
	CASE 
		WHEN @type = 'header' AND CH.intContractHeaderId = @id THEN 1
		WHEN @type = 'detail' AND CD.intContractDetailId = @id THEN 1
		WHEN @type = 'cost' AND CC.intContractCostId = @id THEN 1
	END = 1 
	AND CASE WHEN @accrue = 0 AND payable.intEntityVendorId IS NOT NULL THEN 1 ELSE @accrue END = 1
	AND ISNULL(CC.ysnBasis, 0) <> 1
	and 1 = case when @remove = 1 and @type = 'header' and payable.intEntityVendorId is null then 0 else 1 end

)