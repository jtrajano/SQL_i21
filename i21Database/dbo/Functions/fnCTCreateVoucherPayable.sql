CREATE FUNCTION [dbo].[fnCTCreateVoucherPayable]
(
	@id INT,
	@type NVARCHAR(10)
)
RETURNS TABLE AS RETURN
(
	SELECT	DISTINCT
		[intEntityVendorId]							=	CASE  
															WHEN CC.ysnPrice = 1 AND CD.intPricingTypeId IN (1,6) THEN CH.intEntityId
															WHEN CC.ysnAccrue = 1 THEN CC.intVendorId
														END
		,[intTransactionType]						=	1 --voucher
		,[intLocationId]							=	NULL --Contract doesn't have location
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
		,[dblOrderQty]								=	1
		,[dblOrderUnitQty]							=	0
		,[intOrderUOMId]							=	0
		,[dblQuantityToBill]						=	CASE WHEN CC.strCostMethod = 'Per Unit' THEN ISNULL(CD.dblQuantity,0) ELSE 1 END
		,[dblQtyToBillUnitQty]						=	0
		,[intQtyToBillUOMId]						=	0
		,[dblCost]									=	0
		,[dblCostUnitQty]							=	ISNULL(CostUOM.dblUnitQty,1)
		,[intCostUOMId]								=	CostUOM.intItemUOMId
		,[dblNetWeight]								=	CAST(0 AS DECIMAL(38,20))--ISNULL(CD.dblNetWeight,0)      
		,[dblWeightUnitQty]							=	CAST(1  AS DECIMAL(38,20))
		,[intWeightUOMId]							=	0
		,[intCostCurrencyId]						=	ISNULL(CC.intCurrencyId,ISNULL(CU.intMainCurrencyId,CD.intCurrencyId))	
		,[dblTax]									=	0
		,[dblDiscount]								=	0
		,[intCurrencyExchangeRateTypeId]			=	CC.intRateTypeId
		,[dblExchangeRate]							=	0
		,[ysnSubCurrency]							=	ISNULL(CY.ysnSubCurrency,0)
		,[intSubCurrencyCents]						=	CASE WHEN CY.ysnSubCurrency > 0 THEN CY.intCent ELSE 1 END
		,[intAccountId]								=	apClearing.intAccountId
		,[intShipViaId]								=	0
		,[intTermId]								=	CC.intTermId	
		,[strBillOfLading]							=	NULL
		,[ysnReturn]								=	CAST(RT.Item AS BIT)	
	FROM vyuCTContractCostView CC
	JOIN tblCTContractDetail CD	ON CD.intContractDetailId = CC.intContractDetailId AND (CC.ysnPrice = 1 AND CD.intPricingTypeId IN (1,6) OR CC.ysnAccrue = 1)
	JOIN tblCTContractHeader CH	ON	CH.intContractHeaderId = CD.intContractHeaderId
	INNER JOIN (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON CC.intVendorId = D1.[intEntityId] 
	INNER JOIN tblICItem item ON item.intItemId = CC.intItemId 
	CROSS APPLY tblSMCompanyPreference compPref
	LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = CD.intCurrencyId
	LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = CC.intItemId AND ItemLoc.intLocationId = CD.intCompanyLocationId
	LEFT JOIN tblICInventoryReceiptCharge RC ON	RC.intContractId = CC.intContractHeaderId AND RC.intChargeId = CC.intItemId
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = CD.intItemUOMId
	LEFT JOIN tblICItemUOM CostUOM ON CostUOM.intItemId = CD.intItemId AND CostUOM.intUnitMeasureId = CC.intUnitMeasureId
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
	OUTER APPLY dbo.fnGetItemGLAccountAsTable(CC.intItemId, ItemLoc.intItemLocationId, 'AP Clearing') itemAccnt
	LEFT JOIN dbo.tblGLAccount apClearing ON apClearing.intAccountId = itemAccnt.intAccountId
	OUTER APPLY 
	(
		SELECT TOP 1 dblRate as forexRate from tblSMCurrencyExchangeRateDetail G1
		WHERE F.intCurrencyExchangeRateId = G1.intCurrencyExchangeRateId AND G1.dtmValidFromDate < (SELECT CONVERT(char(10), GETDATE(),126))
		ORDER BY G1.dtmValidFromDate DESC
	) rate
	CROSS JOIN  dbo.fnSplitString('0,1',',') RT
	WHERE RC.intInventoryReceiptChargeId IS NULL AND CC.ysnBasis = 0 AND
	CASE 
		WHEN @type = 'header' AND CH.intContractHeaderId = @id THEN 1
		WHEN @type = 'detail' AND CD.intContractDetailId = @id THEN 1
		WHEN @type = 'cost' AND CC.intContractCostId = @id THEN 1
	END = 1
)