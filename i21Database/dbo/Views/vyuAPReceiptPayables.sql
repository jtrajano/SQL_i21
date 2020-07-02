CREATE VIEW [dbo].[vyuAPReceiptPayables]
AS

--DIRECT TYPE
SELECT
[intEntityVendorId]			=	A.intEntityVendorId
,[dtmDate]					=	A.dtmReceiptDate
,[strReference]				=	A.strVendorRefNo
,[strSourceNumber]			=	A.strReceiptNumber
,[strPurchaseOrderNumber]	=	A.strReceiptNumber
,[intPurchaseDetailId]		=	NULL
,[intItemId]				=	B.intItemId
,[strMiscDescription]		=	C.strDescription
,[strItemNo]				=	C.strItemNo
,[strDescription]			=	C.strDescription
,[intPurchaseTaxGroupId]	=	NULL
,[dblOrderQty]				=	B.dblOpenReceive
,[dblPOOpenReceive]			=	B.dblReceived
,[dblOpenReceive]			=	B.dblOpenReceive
,[dblQuantityToBill]		=	(B.dblOpenReceive - B.dblBillQty)
,[dblQuantityBilled]		=	B.dblBillQty
,[intLineNo]				=	B.intInventoryReceiptItemId
,[intInventoryReceiptItemId]=	B.intInventoryReceiptItemId
,[intInventoryReceiptChargeId]	= NULL
,[dblUnitCost]				=	CASE WHEN (B.dblUnitCost IS NULL OR B.dblUnitCost = 0)
												THEN (CASE WHEN CD.dblCashPrice IS NOT NULL THEN CD.dblCashPrice ELSE B.dblUnitCost END)
												ELSE B.dblUnitCost
										END  	
,[dblTax]					=	ISNULL(B.dblTax,0)
,[dblRate]					=	ISNULL(G1.dblRate,0)
,[ysnSubCurrency]			=	CASE WHEN B.ysnSubCurrency > 0 THEN 1 ELSE 0 END
,[intSubCurrencyCents]		=	ISNULL(A.intSubCurrencyCents, 0)
,[intAccountId]				=	[dbo].[fnGetItemGLAccount](B.intItemId, loc.intItemLocationId, 'AP Clearing')
,[strAccountId]				=	(SELECT strAccountId FROM tblGLAccount WHERE intAccountId = dbo.fnGetItemGLAccount(B.intItemId, loc.intItemLocationId, 'AP Clearing'))
,[strAccountDesc]			=	(SELECT strDescription FROM tblGLAccount WHERE intAccountId = dbo.fnGetItemGLAccount(B.intItemId, loc.intItemLocationId, 'AP Clearing'))
,[strName]					=	D2.strName
,[strVendorId]				=	D1.strVendorId
,[strShipVia]				=	E.strShipVia
,[strTerm]					=	CAST('' AS NVARCHAR) COLLATE Latin1_General_CI_AS
,[strContractNumber]		=	F1.strContractNumber
,[strBillOfLading]			=	A.strBillOfLading
,[intContractHeaderId]		=	F1.intContractHeaderId
,[intContractDetailId]		=	CASE WHEN A.strReceiptType = 'Purchase Contract' THEN B.intLineNo ELSE NULL END
,[intScaleTicketId]			=	G.intTicketId
,[strScaleTicketNumber]		=	G.strTicketNumber
,[intShipmentId]			=	0
,[intShipmentContractQtyId]	=	NULL
,[intUnitMeasureId]			=	B.intUnitMeasureId
,[strUOM]					=	UOM.strUnitMeasure
,[intWeightUOMId]			=	B.intWeightUOMId
,[intCostUOMId]				=	B.intCostUOMId
,[dblNetWeight]				=	B.dblNet
,[strCostUOM]				=	CostUOM.strUnitMeasure
,[strgrossNetUOM]			=	WeightUOM.strUnitMeasure
,[dblWeightUnitQty]			=	ISNULL(ItemWeightUOM.dblUnitQty,1)
,[dblCostUnitQty]			=	ISNULL(ItemCostUOM.dblUnitQty,1)
,[dblUnitQty]				=	ISNULL(ItemUOM.dblUnitQty,1)
,[intCurrencyId]			=	ISNULL(A.intCurrencyId,(SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference))
,[strCurrency]				=   H1.strCurrency
,[intCostCurrencyId]		=	CASE WHEN B.ysnSubCurrency > 0 THEN ISNULL(SubCurrency.intCurrencyID,0)
										ELSE ISNULL(A.intCurrencyId,(SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference)) 
								END	
,[strCostCurrency]			=	CASE WHEN B.ysnSubCurrency > 0 THEN SubCurrency.strCurrency
								ELSE (SELECT TOP 1 strCurrency FROM dbo.tblSMCurrency WHERE intCurrencyID = A.intCurrencyId)
								END
,[strVendorLocation]		=	EL.strLocationName
,[str1099Form]				=	D2.str1099Form			 
,[str1099Type]				=	D2.str1099Type
FROM tblICInventoryReceipt A
INNER JOIN tblICInventoryReceiptItem B
	ON A.intInventoryReceiptId = B.intInventoryReceiptId
INNER JOIN tblICItem C ON B.intItemId = C.intItemId
INNER JOIN tblICItemLocation loc ON C.intItemId = loc.intItemId AND loc.intLocationId = A.intLocationId
INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON A.[intEntityVendorId] = D1.[intEntityId]
LEFT JOIN (tblCTContractHeader CH INNER JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId)  ON CH.intEntityId = A.intEntityVendorId 
																														AND CH.intContractHeaderId = B.intOrderId 
																														AND CD.intContractDetailId = B.intLineNo 
LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemUOMId = B.intWeightUOMId
LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = ItemWeightUOM.intUnitMeasureId
LEFT JOIN tblICItemUOM ItemCostUOM ON ItemCostUOM.intItemUOMId = B.intCostUOMId
LEFT JOIN tblICUnitMeasure CostUOM ON CostUOM.intUnitMeasureId = ItemCostUOM.intUnitMeasureId
LEFT JOIN tblSMShipVia E ON A.intShipViaId = E.[intEntityId]
LEFT JOIN (tblCTContractHeader F1 INNER JOIN tblCTContractDetail F2 ON F1.intContractHeaderId = F2.intContractHeaderId) 
	ON F1.intEntityId = A.intEntityVendorId AND B.intItemId = F2.intItemId AND B.intLineNo = F2.intContractDetailId
LEFT JOIN tblSCTicket G ON (CASE WHEN A.intSourceType = 1 THEN B.intSourceId ELSE 0 END) = G.intTicketId
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = B.intUnitMeasureId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
LEFT JOIN tblSMCurrencyExchangeRate F ON  (F.intFromCurrencyId = (SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference) AND F.intToCurrencyId = A.intCurrencyId) 
										--OR (F.intToCurrencyId = (SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference) AND F.intFromCurrencyId = A.intCurrencyId)
LEFT JOIN dbo.tblSMCurrencyExchangeRateDetail G1 ON F.intCurrencyExchangeRateId = G1.intCurrencyExchangeRateId
LEFT JOIN dbo.tblSMCurrency H1 ON H1.intCurrencyID = A.intCurrencyId
LEFT JOIN dbo.tblEMEntityLocation EL ON EL.intEntityLocationId = A.intShipFromId
LEFT JOIN dbo.tblSMCurrency SubCurrency ON SubCurrency.intMainCurrencyId = A.intCurrencyId 
OUTER APPLY 
(
	SELECT SUM(ISNULL(H.dblQtyReceived,0)) AS dblQty FROM tblAPBillDetail H WHERE H.intInventoryReceiptItemId = B.intInventoryReceiptItemId AND H.intInventoryReceiptChargeId IS NULL
	GROUP BY H.intInventoryReceiptItemId
) Billed
WHERE A.strReceiptType IN ('Direct','Purchase Contract') AND A.ysnPosted = 1 AND B.dblBillQty != B.dblOpenReceive 
AND 1 = (CASE WHEN A.strReceiptType = 'Purchase Contract' THEN
					CASE WHEN F1.intContractTypeId = 1 THEN 1 ELSE 0 END
				ELSE 1 END)
AND B.dblOpenReceive > 0 --EXCLUDE NEGATIVE
AND ((Billed.dblQty < B.dblOpenReceive) OR Billed.dblQty IS NULL)
AND (CD.dblCashPrice != 0 OR CD.dblCashPrice IS NULL AND B.dblUnitCost != 0) --EXCLUDE ALL THE BASIS CONTRACT WITH 0 CASH PRICE AND 0 RECEIPT COST
UNION ALL
--OTHER CHARGES
SELECT DISTINCT
	[intEntityVendorId]							=	A.intEntityVendorId
	,[dtmDate]									=	A.dtmDate
	,[strReference]								=	A.strReference
	,[strSourceNumber]							=	A.strSourceNumber
	,[strPurchaseOrderNumber]					=	NULL
	,[intPurchaseDetailId]						=	NULL
	,[intItemId]								=	A.intItemId
	,[strMiscDescription]						=	A.strMiscDescription
	,[strItemNo]								=	A.strItemNo
	,[strDescription]							=	A.strDescription
	,[intPurchaseTaxGroupId]					=	NULL
	,[dblOrderQty]								=	A.dblOrderQty
	,[dblPOOpenReceive]							=	A.dblPOOpenReceive
	,[dblOpenReceive]							=	A.dblOpenReceive
	,[dblQuantityToBill]						=	A.dblQuantityToBill
	,[dblQuantityBilled]						=	A.dblQuantityBilled
	,[intLineNo]								=	A.intLineNo
	,[intInventoryReceiptItemId]				=	A.intInventoryReceiptItemId
	,[intInventoryReceiptChargeId]				=	A.intInventoryReceiptChargeId
	,[dblUnitCost]								=	A.dblUnitCost
	,[dblTax]									=	ISNULL(A.dblTax,0)
	,[dblRate]									=	ISNULL(G1.dblRate,0)
	,[ysnSubCurrency]							=	ISNULL(A.ysnSubCurrency,0)
	,[intSubCurrencyCents]						=	ISNULL(A.intSubCurrencyCents,0)
	,[intAccountId]								=	A.intAccountId
	,[strAccountId]								=	A.strAccountId
	,[strAccountDesc]							=	(SELECT strDescription FROM tblGLAccount WHERE intAccountId = A.intAccountId)
	,[strName]									=	A.strName
	,[strVendorId]								=	A.strVendorId
	,[strShipVia]								=	NULL
	,[strTerm]									=	NULL
	,[strContractNumber]						=	A.strContractNumber
	,[strBillOfLading]							=	NULL
	,[intContractHeaderId]						=	A.intContractHeaderId
	,[intContractDetailId]						=	A.intContractDetailId
	,[intScaleTicketId]							=	A.intScaleTicketId
	,[strScaleTicketNumber]						=	A.strScaleTicketNumber --CAST(NULL AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS
	,[intShipmentId]							=	0      
	,[intShipmentContractQtyId]					=	NULL
  	,[intUnitMeasureId]							=	NULL
	,[strUOM]									=	NULL
	,[intWeightUOMId]							=	NULL
	,[intCostUOMId]								=	A.intCostUnitMeasureId
	,[dblNetWeight]								=	0      
	,[strCostUOM]								=	A.strCostUnitMeasure
	,[strgrossNetUOM]							=	NULL
	,[dblWeightUnitQty]							=	1
	,[dblCostUnitQty]							=	1
	,[dblUnitQty]								=	1
	,[intCurrencyId]							=	CASE WHEN A.ysnSubCurrency > 0 
															THEN (SELECT ISNULL(intMainCurrencyId,A.intCurrencyId) FROM dbo.tblSMCurrency WHERE intCurrencyID = ISNULL(A.intCurrencyId,0))
															ELSE  ISNULL(A.intCurrencyId,0)
													END	
	,[strCurrency]								=	CASE WHEN A.ysnSubCurrency > 0 
															THEN (SELECT TOP 1 strCurrency FROM dbo.tblSMCurrency WHERE intCurrencyID IN (SELECT ISNULL(intMainCurrencyId, A.intCurrencyId) FROM dbo.tblSMCurrency WHERE intCurrencyID = ISNULL(A.intCurrencyId,0)))
															ELSE  (SELECT TOP 1 strCurrency FROM dbo.tblSMCurrency WHERE intCurrencyID = A.intCurrencyId)
													END
	,[intCostCurrencyId]						=	ISNULL(A.intCurrencyId,0)		
	,[strCostCurrency]							=	(SELECT TOP 1 strCurrency FROM dbo.tblSMCurrency WHERE intCurrencyID = A.intCurrencyId)	
	,[strVendorLocation]						=	NULL
	,[str1099Form]				=	D2.str1099Form			 
	,[str1099Type]				=	D2.str1099Type      
FROM [vyuICChargesForBilling] A
LEFT JOIN tblSMCurrencyExchangeRate F ON  (F.intFromCurrencyId = (SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference) AND F.intToCurrencyId = CASE WHEN A.ysnSubCurrency > 0 
																																						THEN (SELECT ISNULL(intMainCurrencyId,0) FROM dbo.tblSMCurrency WHERE intCurrencyID = ISNULL(A.intCurrencyId,0))
																																						ELSE  ISNULL(A.intCurrencyId,0) END) 
LEFT JOIN dbo.tblSMCurrencyExchangeRateDetail G1 ON F.intCurrencyExchangeRateId = G1.intCurrencyExchangeRateId
LEFT JOIN dbo.tblSMCurrency H1 ON H1.intCurrencyID = A.intCurrencyId
LEFT JOIN dbo.tblSMCurrency SubCurrency ON SubCurrency.intMainCurrencyId = A.intCurrencyId 
INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON A.[intEntityVendorId] = D1.[intEntityId]
OUTER APPLY 
(
	SELECT intEntityVendorId FROM tblAPBillDetail BD
	LEFT JOIN dbo.tblAPBill B ON BD.intBillId = B.intBillId
	WHERE BD.intInventoryReceiptChargeId = A.intInventoryReceiptChargeId

) Billed
OUTER APPLY 
(
	SELECT SUM(ISNULL(H.dblQtyReceived,0)) AS dblQty FROM tblAPBillDetail H 
	INNER JOIN dbo.tblAPBill B ON B.intBillId = H.intBillId
	WHERE H.intInventoryReceiptChargeId = A.intInventoryReceiptChargeId
	GROUP BY H.intInventoryReceiptChargeId
			
) Qty
WHERE A.[intEntityVendorId] NOT IN (Billed.intEntityVendorId) OR (Qty.dblQty IS NULL)