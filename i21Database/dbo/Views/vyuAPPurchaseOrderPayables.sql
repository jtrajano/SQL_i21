CREATE VIEW [dbo].[vyuAPPurchaseOrderPayables]
AS

--PO Items
SELECT
	[intEntityVendorId]			=	A.[intEntityVendorId]
	,[dtmDate]					=	A.dtmDate
	,[strReference]				=	A.strReference
	,[strSourceNumber]			=	tblReceived.strReceiptNumber
	,[strPurchaseOrderNumber]	=	A.strPurchaseOrderNumber
	,[intPurchaseDetailId]		=	B.intPurchaseDetailId
	,[intItemId]				=	B.intItemId
	,[strMiscDescription]		=	B.strMiscDescription
	,[strItemNo]				=	C.strItemNo
	,[strDescription]			=	C.strDescription
	,[intPurchaseTaxGroupId]	=	NULL
	,[dblOrderQty]				=	tblReceived.dblOrderQty
	,[dblPOOpenReceive]			=	tblReceived.dblPOOpenReceive --uom converted received quantity from po to IR
	,[dblOpenReceive]			=	tblReceived.dblOpenReceive
	--,[dblQuantityToBill]		=	(tblReceived.dblPOOpenReceive - tblReceived.dblQuantityBilled) --this will use if Bill will use UOM Of PO
	,[dblQuantityToBill]		=	(tblReceived.dblOpenReceive - tblReceived.dblQuantityBilled)
	,[dblQuantityBilled]		=	tblReceived.dblQuantityBilled
	,[intLineNo]				=	tblReceived.intLineNo
	,[intInventoryReceiptItemId]=	tblReceived.intInventoryReceiptItemId
	,[intInventoryReceiptItemAllocatedChargeId]	= NULL
	,[dblUnitCost]				=	tblReceived.dblUnitCost
	,[dblTax]					=	tblReceived.dblTax
	,[dblRate]					=	tblReceived.dblRate
	,[ysnSubCurrency]			=	tblReceived.ysnSubCurrency
	,[intSubCurrencyCents]		=   tblReceived.intSubCurrencyCents
	,[intAccountId]				=	tblReceived.intAccountId
	,[strAccountId]				=	tblReceived.strAccountId
	,[strAccountDesc]			=	tblReceived.strAccountDesc
	,[strName]					=	D2.strName
	,[strVendorId]				=	D1.strVendorId
	,[strShipVia]				=	E.strShipVia
	,[strTerm]					=	F.strTerm
	,[strContractNumber]		=	G1.strContractNumber
	,[strBillOfLading]			=	tblReceived.strBillOfLading
	,[intContractHeaderId]		=	G1.intContractHeaderId
	,[intContractDetailId]		=	G2.intContractDetailId
	,[intScaleTicketId]			=	NULL
	,[strScaleTicketNumber]		=	N'' COLLATE Latin1_General_CI_AS
	,[intShipmentId]			=	0            
	,[intShipmentContractQtyId]	=	NULL
	,[intUnitMeasureId]			=	tblReceived.intUnitMeasureId
	,[strUOM]					=	tblReceived.strUOM
	,[intWeightUOMId]			=	tblReceived.intWeightUOMId
	,[intCostUOMId]				=	tblReceived.intCostUOMId
	,[dblNetWeight]				=	tblReceived.dblNetWeight
	,[strCostUOM]				=	tblReceived.costUOM
	,[strgrossNetUOM]			=	tblReceived.grossNetUOM
  	,[dblWeightUnitQty]			=	tblReceived.weightUnitQty
	,[dblCostUnitQty]			=	tblReceived.costUnitQty      
	,[dblUnitQty]				=	tblReceived.itemUnitQty
	,[intCurrencyId]			=	tblReceived.intCurrencyId
	,[strCurrency]				=	tblReceived.strCurrency
	,[intCostCurrencyId]		=	tblReceived.intCostCurrencyId		 
	,[strCostCurrency]			=	tblReceived.strCostCurrency
	,[strVendorLocation]		=	tblReceived.strVendorLocation
	,[str1099Form]				=	D2.str1099Form			 
	,[str1099Type]				=	D2.str1099Type
	
FROM tblPOPurchase A
	INNER JOIN tblPOPurchaseDetail B ON A.intPurchaseId = B.intPurchaseId
	CROSS APPLY 
	(
		SELECT
			A1.strReceiptNumber
			,A1.strBillOfLading
			,B1.intInventoryReceiptItemId
			,B1.intItemId
			,B1.intLineNo
			,B1.dblOrderQty
			,B1.dblUnitCost
			,dbo.fnCalculateQtyBetweenUOM(B1.intUnitMeasureId, B.intUnitOfMeasureId, SUM(ISNULL(B1.dblOpenReceive,0))) dblPOOpenReceive
			,SUM(ISNULL(B1.dblOpenReceive,0)) dblOpenReceive
			,intAccountId = [dbo].[fnGetItemGLAccount](B1.intItemId, loc.intItemLocationId, 'AP Clearing')
			,strAccountId = (SELECT strAccountId FROM tblGLAccount WHERE intAccountId = dbo.fnGetItemGLAccount(B1.intItemId, loc.intItemLocationId, 'AP Clearing'))
			,strAccountDesc = (SELECT strDescription FROM tblGLAccount WHERE intAccountId = dbo.fnGetItemGLAccount(B1.intItemId, loc.intItemLocationId, 'AP Clearing'))
			,dblQuantityBilled = SUM(ISNULL(B1.dblBillQty, 0))
			,ISNULL(B1.dblTax,0) AS dblTax
			,ISNULL(G.dblRate,0) AS dblRate
			,CASE WHEN B1.ysnSubCurrency > 0 THEN 1 ELSE 0 END AS ysnSubCurrency
			,ISNULL(A1.intSubCurrencyCents, 0) AS intSubCurrencyCents
			,B1.intUnitMeasureId
			,UOM.strUnitMeasure AS strUOM
			,B1.intWeightUOMId
			,B1.intCostUOMId
			,dblNet AS dblNetWeight
			,CostUOM.strUnitMeasure AS costUOM
			,WeightUOM.strUnitMeasure AS grossNetUOM
			,ISNULL(ItemWeightUOM.dblUnitQty,1) AS weightUnitQty
			,ISNULL(ItemCostUOM.dblUnitQty,1) AS costUnitQty
			,ISNULL(ItemUOM.dblUnitQty,1) AS itemUnitQty
			,ISNULL(A1.intCurrencyId,0) AS intCurrencyId
			,H.strCurrency AS strCurrency
			,CASE WHEN B1.ysnSubCurrency > 0 
				    THEN ISNULL(SubCurrency.intCurrencyID,0)
					ELSE ISNULL(A1.intCurrencyId,0) 
				END AS intCostCurrencyId 
			,CASE WHEN B1.ysnSubCurrency > 0 
					THEN SubCurrency.strCurrency
					ELSE H.strCurrency 
				END AS strCostCurrency					   
			,EL.strLocationName AS strVendorLocation
		FROM tblICInventoryReceipt A1
			INNER JOIN tblICInventoryReceiptItem B1 ON A1.intInventoryReceiptId = B1.intInventoryReceiptId
			INNER JOIN tblICItemLocation loc ON B1.intItemId = loc.intItemId AND A1.intLocationId = loc.intLocationId
			--INNER JOIN dbo.tblICInventoryReceiptItemLot RIL ON RIL.intInventoryReceiptItemId = B1.intInventoryReceiptItemId
			LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemUOMId = B1.intWeightUOMId
			LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = ItemWeightUOM.intUnitMeasureId
			LEFT JOIN tblICItemUOM ItemCostUOM ON ItemCostUOM.intItemUOMId = B1.intCostUOMId
			LEFT JOIN tblICUnitMeasure CostUOM ON CostUOM.intUnitMeasureId = ItemCostUOM.intUnitMeasureId
			LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = B1.intUnitMeasureId
			LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
			LEFT JOIN tblSMCurrencyExchangeRate F ON  (F.intFromCurrencyId = (SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference) AND F.intToCurrencyId = A1.intCurrencyId) 
										--OR (F.intToCurrencyId = (SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference) AND F.intFromCurrencyId = A1.intCurrencyId)
			LEFT JOIN dbo.tblSMCurrencyExchangeRateDetail G ON F.intCurrencyExchangeRateId = G.intCurrencyExchangeRateId
			LEFT JOIN dbo.tblSMCurrency H ON H.intCurrencyID = A1.intCurrencyId
			LEFT JOIN dbo.tblEMEntityLocation EL ON EL.intEntityLocationId = A1.intShipFromId
			LEFT JOIN dbo.tblSMCurrency SubCurrency ON SubCurrency.intMainCurrencyId = A1.intCurrencyId 
		WHERE A1.ysnPosted = 1 AND B1.dblOpenReceive != B1.dblBillQty 
		AND B1.dblOpenReceive > 0 --EXCLUDE NEGATIVE
		AND B.intPurchaseDetailId = B1.intLineNo
		AND A1.strReceiptType = 'Purchase Order'
		GROUP BY
			A1.strReceiptNumber
			,A1.strBillOfLading
			,B1.intInventoryReceiptItemId
			,B1.intItemId 
			,B1.dblUnitCost
			,intLineNo
			,dblOrderQty
			,loc.intItemLocationId
			,B1.dblTax
			,B1.intUnitMeasureId
			,UOM.strUnitMeasure
			,B1.intWeightUOMId
			,B1.intCostUOMId
			,B1.dblNet
			,CostUOM.strUnitMeasure	
			,WeightUOM.strUnitMeasure
			,ItemCostUOM.dblUnitQty
			,ItemWeightUOM.dblUnitQty
			,ItemUOM.dblUnitQty
			,B1.ysnSubCurrency
			,G.dblRate
			,A1.intSubCurrencyCents
			,H.strCurrency
			,EL.strLocationName
			,SubCurrency.intCurrencyID
			,SubCurrency.strCurrency
			,A1.intCurrencyId
	) as tblReceived
	--ON B.intPurchaseDetailId = tblReceived.intLineNo AND B.intItemId = tblReceived.intItemId
	INNER JOIN tblICItem C ON B.intItemId = C.intItemId
	INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON A.[intEntityVendorId] = D1.[intEntityId]
	LEFT JOIN tblSMShipVia E ON A.intShipViaId = E.[intEntityId]
	LEFT JOIN tblSMTerm F ON A.intTermsId = F.intTermID
	LEFT JOIN (tblCTContractHeader G1 INNER JOIN tblCTContractDetail G2 ON G1.intContractHeaderId = G2.intContractHeaderId) 
			ON G1.intEntityId = D1.[intEntityId] AND B.intItemId = G2.intItemId AND B.intContractDetailId = G2.intContractDetailId
	OUTER APPLY (
		SELECT SUM(ISNULL(H.dblQtyReceived,0)) AS dblQty FROM tblAPBillDetail H WHERE H.intInventoryReceiptItemId = tblReceived.intInventoryReceiptItemId AND H.intPurchaseDetailId = B.intPurchaseDetailId
		GROUP BY H.intInventoryReceiptItemId, H.intPurchaseDetailId
	) Billed
	WHERE ((Billed.dblQty < tblReceived.dblOpenReceive) OR Billed.dblQty IS NULL)
	UNION ALL
	--PO MISCELLANEOUS ITEMS
	SELECT
	[intEntityVendorId]			=	A.[intEntityVendorId]
	,[dtmDate]					=	A.dtmDate
	,[strReference]				=	A.strReference
	,[strSourceNumber]			=	A.strPurchaseOrderNumber
	,[strPurchaseOrderNumber]	=	A.strPurchaseOrderNumber
	,[intPurchaseDetailId]		=	B.intPurchaseDetailId
	,[intItemId]				=	B.intItemId
	,[strMiscDescription]		=	B.strMiscDescription
	,[strItemNo]				=	C.strItemNo
	,[strDescription]			=	C.strDescription
	,[intPurchaseTaxGroupId]	=	NULL
	,[dblOrderQty]				=	B.dblQtyOrdered
	,[dblPOOpenReceive]			=	B.dblQtyOrdered -B.dblQtyReceived
	,[dblOpenReceive]			=	B.dblQtyOrdered
	,[dblQuantityToBill]		=	B.dblQtyOrdered -B.dblQtyReceived
	,[dblQuantityBilled]		=	B.dblQtyReceived
	,[intLineNo]				=	B.intPurchaseDetailId
	,[intInventoryReceiptItemId]=	NULL --this should be null as this has constraint from IR Receipt item
	,[intInventoryReceiptChargeId]	= NULL
	,[dblUnitCost]				=	B.dblCost
	,[dblTax]					=	ISNULL(B.dblTax,0)
	,[dblRate]					=	0
	,[ysnSubCurrency]			=	0
	,[intSubCurrencyCents]		=	0
	,[intAccountId]				=	[dbo].[fnGetItemGLAccount](B.intItemId, loc.intItemLocationId, 'Inventory')
	,[strAccountId]				=	(SELECT strAccountId FROM tblGLAccount WHERE intAccountId = dbo.fnGetItemGLAccount(B.intItemId, loc.intItemLocationId, 'Inventory'))
	,[strAccountDesc]			=	(SELECT strDescription FROM tblGLAccount WHERE intAccountId = dbo.fnGetItemGLAccount(B.intItemId, loc.intItemLocationId, 'Inventory'))
	,[strName]					=	D2.strName
	,[strVendorId]				=	D1.strVendorId
	,[strShipVia]				=	E.strShipVia
	,[strTerm]					=	F.strTerm
	,[strContractNumber]		=	NULL
	,[strBillOfLading]			=	NULL
	,[intContractHeaderId]		=	NULL
	,[intContractDetailId]		=	NULL
	,[intScaleTicketId]			=	NULL
	,[strScaleTicketNumber]		=	N''
	,[intShipmentId]			=	0    
	,[intShipmentContractQtyId]	=	NULL
	,[intUnitMeasureId]			=	B.intUnitOfMeasureId
	,[strUOM]					=	UOM.strUnitMeasure
	,[intWeightUOMId]			=	NULL
	,[intCostUOMId]				=	NULL
	,[dblNetWeight]				=	0
	,[strCostUOM]				=	N''
	,[strgrossNetUOM]			=	N''
	,[dblWeightUnitQty]			=	1
	,[dblCostUnitQty]			=	1
	,[dblUnitQty]				=	1
	,[intCurrencyId]			=	ISNULL(A.intCurrencyId,0)
	,[strCurrency]				=	(SELECT TOP 1 strCurrency FROM dbo.tblSMCurrency WHERE intCurrencyID = A.intCurrencyId)
	,[intCostCurrencyId]		=	ISNULL(A.intCurrencyId,0)
	,[strCostCurrency]			=	(SELECT TOP 1 strCurrency FROM dbo.tblSMCurrency WHERE intCurrencyID = A.intCurrencyId)
	,[strVendorLocation]		=	EL.strLocationName
	,[str1099Form]				=	D2.str1099Form			 
	,[str1099Type]				=	D2.str1099Type
	FROM tblPOPurchase A
		INNER JOIN tblPOPurchaseDetail B ON A.intPurchaseId = B.intPurchaseId
		INNER JOIN tblICItem C ON B.intItemId = C.intItemId
		INNER JOIN tblICItemLocation loc ON C.intItemId = loc.intItemId AND loc.intLocationId = A.intShipToId
		INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON A.[intEntityVendorId] = D1.[intEntityId]
		LEFT JOIN tblSMShipVia E ON A.intShipViaId = E.[intEntityId]
		LEFT JOIN tblSMTerm F ON A.intTermsId = F.intTermID
		LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = B.intUnitOfMeasureId
		LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
		LEFT JOIN dbo.tblEMEntityLocation EL ON EL.intEntityLocationId = A.intShipFromId
		OUTER APPLY
		(
			SELECT SUM(ISNULL(G.dblQtyReceived,0)) AS dblQty FROM tblAPBillDetail G WHERE G.intPurchaseDetailId = B.intPurchaseDetailId
			GROUP BY G.intPurchaseDetailId
		) Billed
	WHERE C.strType IN ('Service','Software','Non-Inventory','Other Charge')
	AND B.dblQtyOrdered != B.dblQtyReceived
	AND ((Billed.dblQty < B.dblQtyReceived) OR Billed.dblQty IS NULL)