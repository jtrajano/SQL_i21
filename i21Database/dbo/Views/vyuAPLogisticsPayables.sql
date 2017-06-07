CREATE VIEW [dbo].[vyuAPLogisticsPayables]
AS

SELECT
	[intEntityVendorId]							=	A.intVendorEntityId
	,[dtmDate]									=	A.dtmInventorizedDate
	,[strReference]								=	'' COLLATE Latin1_General_CI_AS
	,[strSourceNumber]							=	LTRIM(A.intTrackingNumber) COLLATE Latin1_General_CI_AS
	,[strPurchaseOrderNumber]					=	NULL
	,[intPurchaseDetailId]						=	NULL
	,[intItemId]								=	A.intItemId
	,[strMiscDescription]						=	A.strItemDescription
	,[strItemNo]								=	A.strItemNo
	,[strDescription]							=	A.strItemDescription
	,[intPurchaseTaxGroupId]					=	NULL
	,[dblOrderQty]								=	A.dblQuantity
	,[dblPOOpenReceive]							=	0
	,[dblOpenReceive]							=	A.dblQuantity
	,[dblQuantityToBill]						=	A.dblQuantity
	,[dblQuantityBilled]						=	0
	,[intLineNo]								=	A.intShipmentContractQtyId
	,[intInventoryReceiptItemId]				=	NULL
	,[intInventoryReceiptChargeId]				=	NULL
	,[dblUnitCost]								=	A.dblCashPrice
	,[dblTax]									=	0
	,[dblRate]									=	0
	,[ysnSubCurrency]							=	0
	,[intSubCurrencyCents]						=	0
	,[intAccountId]								=	[dbo].[fnGetItemGLAccount](A.intItemId, ItemLoc.intItemLocationId, 'AP Clearing')
	,[strAccountId]								=	(SELECT strAccountId FROM tblGLAccount WHERE intAccountId = dbo.fnGetItemGLAccount(A.intItemId, ItemLoc.intItemLocationId, 'AP Clearing'))
	,[strAccountDesc]							=	(SELECT strDescription FROM tblGLAccount WHERE intAccountId = dbo.fnGetItemGLAccount(A.intItemId, ItemLoc.intItemLocationId, 'AP Clearing'))
	,[strName]									=	A.strVendor
	,[strVendorId]								=	LTRIM(A.intVendorEntityId) COLLATE Latin1_General_CI_AS
	,[strShipVia]								=	NULL
	,[strTerm]									=	NULL
	,[strContractNumber]						=	A.strContractNumber
	,[strBillOfLading]							=	A.strBLNumber
	,[intContractHeaderId]						=	A.intContractHeaderId
	,[intContractDetailId]						=	A.intContractDetailId
	,[intScaleTicketId]							=	NULL
	,[strScaleTicketNumber]						=	NULL
	,[intShipmentId]							=	A.intShipmentId      
	,[intShipmentContractQtyId]					=	A.intShipmentContractQtyId
	,[intUnitMeasureId]							=	A.intItemUOMId
	,[strUOM]									=	UOM.strUnitMeasure
	,[intWeightUOMId]							=	A.intWeightItemUOMId
	,[intCostUOMId]								=	A.intPriceItemUOMId
	,[dblNetWeight]								=	ISNULL(A.dblNetWt,0)      
	,[strCostUOM]								=	A.strPriceUOM
	,[strgrossNetUOM]							=	A.strWeightUOM
	--,[dblUnitQty]								=	dbo.fnLGGetItemUnitConversion (A.intItemId, A.intPriceItemUOMId, A.intWeightUOMId)
	,[dblWeightUnitQty]							=	ISNULL(ItemWeightUOM.dblUnitQty,1)
	,[dblCostUnitQty]							=	ISNULL(ItemCostUOM.dblUnitQty,1)
	,[dblUnitQty]								=	ISNULL(ItemUOM.dblUnitQty,1)
	,[intCurrencyId]							=	(SELECT TOP 1 ISNULL(intCurrencyID,(SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference)) FROM dbo.tblSMCurrency WHERE strCurrency = A.strCurrency)
	,[strCurrency]								=	A.strCurrency
	,[intCostCurrencyId]						=	(SELECT TOP 1 ISNULL(intCurrencyID,(SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference)) FROM dbo.tblSMCurrency WHERE strCurrency = A.strCurrency)		
	,[strCostCurrency]							=	A.strCurrency
	,[strVendorLocation]						=	NULL
	,[str1099Form]								=	D2.str1099Form			 
	,[str1099Type]								=	D2.str1099Type 
FROM vyuLGShipmentPurchaseContracts A
LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = A.intItemId and ItemLoc.intLocationId = A.intCompanyLocationId
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = A.intItemUOMId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemUOMId = A.intWeightUOMId
LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = ItemWeightUOM.intUnitMeasureId
LEFT JOIN tblICItemUOM ItemCostUOM ON ItemCostUOM.intItemUOMId = A.intCostUOMId
LEFT JOIN tblICUnitMeasure CostUOM ON CostUOM.intUnitMeasureId = ItemCostUOM.intUnitMeasureId
INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON A.[intEntityVendorId] = D1.[intEntityId]
WHERE A.ysnDirectShipment = 1 AND A.dtmInventorizedDate IS NOT NULL AND A.intShipmentContractQtyId NOT IN (SELECT IsNull(intShipmentContractQtyId, 0) FROM tblAPBillDetail)
