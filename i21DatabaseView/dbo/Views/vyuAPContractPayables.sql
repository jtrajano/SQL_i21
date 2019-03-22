CREATE VIEW [dbo].[vyuAPContractPayables]
AS

SELECT
DISTINCT  
	[intEntityVendorId]							=	CC.intVendorId
	,[dtmDate]									=	CD.dtmStartDate
	,[strReference]								=	'' COLLATE Latin1_General_CI_AS
	,[strSourceNumber]							=	LTRIM(CD.strContractNumber) COLLATE Latin1_General_CI_AS
	,[strPurchaseOrderNumber]					=	NULL
	,[intPurchaseDetailId]						=	NULL
	,[intItemId]								=	CC.intItemId
	,[strMiscDescription]						=	CC.strItemDescription
	,[strItemNo]								=	CC.strItemNo
	,[strDescription]							=	CC.strItemDescription
	,[intPurchaseTaxGroupId]					=	NULL
	,[dblOrderQty]								=	1
	,[dblPOOpenReceive]							=	0
	,[dblOpenReceive]							=	1
	,[dblQuantityToBill]						=	1
	,[dblQuantityBilled]						=	0
	,[intLineNo]								=	CD.intContractDetailId
	,[intInventoryReceiptItemId]				=	NULL
	,[intInventoryReceiptChargeId]				=	NULL
	,[dblUnitCost]								=	ISNULL(CC.dblRate,0)
	,[dblTax]									=	0
	,[dblRate]									=	CASE WHEN CY.ysnSubCurrency > 0  THEN  ISNULL(RateDetail.dblRate,0) ELSE ISNULL(G1.dblRate,0) END
	,[ysnSubCurrency]							=	ISNULL(CY.ysnSubCurrency,0)
	,[intSubCurrencyCents]						=	ISNULL(RC.intCent,0)
	,[intAccountId]								=	[dbo].[fnGetItemGLAccount](CC.intItemId, ItemLoc.intItemLocationId, 'AP Clearing')
	,[strAccountId]								=	(SELECT strAccountId FROM tblGLAccount WHERE intAccountId = dbo.fnGetItemGLAccount(CC.intItemId, ItemLoc.intItemLocationId, 'AP Clearing'))
	,[strAccountDesc]							=	(SELECT strDescription FROM tblGLAccount WHERE intAccountId = dbo.fnGetItemGLAccount(CC.intItemId, ItemLoc.intItemLocationId, 'AP Clearing'))
	,[strName]									=	CC.strVendorName
	,[strVendorId]								=	LTRIM(CC.intVendorId) COLLATE Latin1_General_CI_AS
	,[strShipVia]								=	NULL
	,[strTerm]									=	NULL
	,[strContractNumber]						=	CD.strContractNumber
	,[strBillOfLading]							=	NULL
	,[intContractHeaderId]						=	CD.intContractHeaderId
	,[intContractDetailId]						=	CD.intContractDetailId
	,[intScaleTicketId]							=	NULL
	,[strScaleTicketNumber]						=	NULL
	,[intShipmentId]							=	0     
	,[intShipmentContractQtyId]					=	NULL
	,[intUnitMeasureId]							=	CC.intUnitMeasureId
	,[strUOM]									=	UOM.strUnitMeasure
	,[intWeightUOMId]							=	NULL--CD.intNetWeightUOMId
	,[intCostUOMId]								=	CC.intItemUOMId
	,[dblNetWeight]								=	0--ISNULL(CD.dblNetWeight,0)      
	,[strCostUOM]								=	CC.strUOM
	,[strgrossNetUOM]							=	CC.strUOM
	,[dblWeightUnitQty]							=	1
	,[dblCostUnitQty]							=	1
	,[dblUnitQty]								=	1
	,[intCurrencyId]							=	CASE WHEN CY.ysnSubCurrency > 0 
															THEN (SELECT ISNULL(intMainCurrencyId,0) FROM dbo.tblSMCurrency WHERE intCurrencyID = ISNULL(CC.intCurrencyId,0))
															ELSE  ISNULL(CC.intCurrencyId,ISNULL(CD.intMainCurrencyId,CD.intCurrencyId))
													END		
	,[strCurrency]								=	CASE WHEN CY.ysnSubCurrency > 0 
															THEN (SELECT TOP 1 strCurrency FROM dbo.tblSMCurrency WHERE intCurrencyID IN (SELECT intMainCurrencyId FROM dbo.tblSMCurrency WHERE intCurrencyID = ISNULL(CC.intCurrencyId,0)))
															ELSE  ISNULL(CC.strCurrency, ((SELECT TOP 1 strCurrency FROM dbo.tblSMCurrency WHERE intCurrencyID = ISNULL(CD.intMainCurrencyId,CD.intCurrencyId))))
													END	
	,[intCostCurrencyId]						=	ISNULL(CC.intCurrencyId,ISNULL(CD.intMainCurrencyId,CD.intCurrencyId))	
	,[strCostCurrency]							=	ISNULL(CC.strCurrency, ((SELECT TOP 1 strCurrency FROM dbo.tblSMCurrency WHERE intCurrencyID = ISNULL(CD.intMainCurrencyId,CD.intCurrencyId))))
	,[strVendorLocation]						=	NULL
	,[str1099Form]								=	D2.str1099Form			 
	,[str1099Type]								=	D2.str1099Type 
FROM		vyuCTContractCostView		CC
JOIN		vyuCTContractDetailView		CD	ON	CD.intContractDetailId	=	CC.intContractDetailId
LEFT JOIN	tblICItemLocation		ItemLoc ON	ItemLoc.intItemId		=	CC.intItemId			AND 
												ItemLoc.intLocationId	=	CD.intCompanyLocationId
LEFT JOIN	tblICInventoryReceiptCharge RC	ON	RC.intContractId		=	CC.intContractHeaderId	AND 
												RC.intChargeId			=	CC.intItemId
LEFT JOIN	tblICItemUOM			ItemUOM ON	ItemUOM.intItemUOMId	=	CD.intUnitMeasureId
LEFT JOIN	tblICUnitMeasure			UOM ON	UOM.intUnitMeasureId	=	ItemUOM.intUnitMeasureId
LEFT JOIN	tblSMCurrencyExchangeRate F ON  (F.intFromCurrencyId = (SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference) AND F.intToCurrencyId = CC.intCurrencyId) 
LEFT JOIN	tblSMCurrencyExchangeRateDetail G1 ON F.intCurrencyExchangeRateId = G1.intCurrencyExchangeRateId
LEFT JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID		=	CC.intCurrencyId
LEFT JOIN	tblSMCurrencyExchangeRate Rate ON  (Rate.intFromCurrencyId = (SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference) AND Rate.intToCurrencyId = CD.intMainCurrencyId) 
LEFT JOIN	tblSMCurrencyExchangeRateDetail RateDetail ON Rate.intCurrencyExchangeRateId = RateDetail.intCurrencyExchangeRateId
INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON CC.intVendorId = D1.[intEntityId]  
WHERE		RC.intInventoryReceiptChargeId IS NULL