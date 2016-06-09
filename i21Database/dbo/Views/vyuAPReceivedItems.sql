CREATE VIEW [dbo].[vyuAPReceivedItems]
AS

SELECT
CAST(ROW_NUMBER() OVER(ORDER BY intInventoryReceiptItemId, intPurchaseDetailId) AS INT) AS intReceivedItemId
,Items.*
FROM
(
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
		,[strScaleTicketNumber]		=	CAST(NULL AS NVARCHAR(50))
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
		,[strVendorLocation]		=	tblReceived.strVendorLocation
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
				,B1.dblTax
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
				,CASE WHEN B1.ysnSubCurrency > 0 THEN ISNULL(SubCurrency.intCurrencyID,0)
					  ELSE ISNULL(A1.intCurrencyId,0) END AS intCurrencyId
				,CASE WHEN B1.ysnSubCurrency > 0 THEN SubCurrency.strCurrency
					  ELSE H.strCurrency END AS strCurrency 
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
		INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.intEntityVendorId = D2.intEntityId) ON A.[intEntityVendorId] = D1.intEntityVendorId
		LEFT JOIN tblSMShipVia E ON A.intShipViaId = E.[intEntityShipViaId]
		LEFT JOIN tblSMTerm F ON A.intTermsId = F.intTermID
		LEFT JOIN (tblCTContractHeader G1 INNER JOIN tblCTContractDetail G2 ON G1.intContractHeaderId = G2.intContractHeaderId) 
				ON G1.intEntityId = D1.intEntityVendorId AND B.intItemId = G2.intItemId AND B.intContractDetailId = G2.intContractDetailId
		OUTER APPLY (
			SELECT SUM(ISNULL(H.dblQtyReceived,0)) AS dblQty FROM tblAPBillDetail H WHERE H.intInventoryReceiptItemId = tblReceived.intInventoryReceiptItemId AND H.intPurchaseDetailId = B.intPurchaseDetailId
			GROUP BY H.intInventoryReceiptItemId, H.intPurchaseDetailId
		) Billed
		WHERE ((Billed.dblQty < tblReceived.dblOpenReceive) OR Billed.dblQty IS NULL)
	UNION ALL
	--Miscellaneous items
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
	,[dblTax]					=	B.dblTax
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
	,[strScaleTicketNumber]		=	CAST(NULL AS NVARCHAR(50))
	,[intShipmentId]			=	0    
	,[intShipmentContractQtyId]	=	NULL
	,[intUnitMeasureId]			=	B.intUnitOfMeasureId
	,[strUOM]					=	UOM.strUnitMeasure
	,[intWeightUOMId]			=	NULL
	,[intCostUOMId]				=	NULL
	,[dblNetWeight]				=	0
	,[strCostUOM]				=	NULL
	,[strgrossNetUOM]			=	NULL
	,[dblWeightUnitQty]			=	1
	,[dblCostUnitQty]			=	1
	,[dblUnitQty]				=	1
	,[intCurrencyId]			=	ISNULL(A.intCurrencyId,0)
	,[strCurrency]				=	(SELECT TOP 1 strCurrency FROM dbo.tblSMCurrency WHERE intCurrencyID = A.intCurrencyId)
	,[strVendorLocation]		=	EL.strLocationName
	FROM tblPOPurchase A
		INNER JOIN tblPOPurchaseDetail B ON A.intPurchaseId = B.intPurchaseId
		INNER JOIN tblICItem C ON B.intItemId = C.intItemId
		INNER JOIN tblICItemLocation loc ON C.intItemId = loc.intItemId AND loc.intLocationId = A.intShipToId
		INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.intEntityVendorId = D2.intEntityId) ON A.[intEntityVendorId] = D1.intEntityVendorId
		LEFT JOIN tblSMShipVia E ON A.intShipViaId = E.[intEntityShipViaId]
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
	UNION ALL
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
	,[dblTax]					=	B.dblTax
	,[dblRate]					=	ISNULL(G1.dblRate,0)
	,[ysnSubCurrency]			=	CASE WHEN B.ysnSubCurrency > 0 THEN 1 ELSE 0 END
	,[intSubCurrencyCents]		=	ISNULL(A.intSubCurrencyCents, 0)
	,[intAccountId]				=	[dbo].[fnGetItemGLAccount](B.intItemId, loc.intItemLocationId, 'AP Clearing')
	,[strAccountId]				=	(SELECT strAccountId FROM tblGLAccount WHERE intAccountId = dbo.fnGetItemGLAccount(B.intItemId, loc.intItemLocationId, 'AP Clearing'))
	,[strAccountDesc]			=	(SELECT strDescription FROM tblGLAccount WHERE intAccountId = dbo.fnGetItemGLAccount(B.intItemId, loc.intItemLocationId, 'AP Clearing'))
	,[strName]					=	D2.strName
	,[strVendorId]				=	D1.strVendorId
	,[strShipVia]				=	E.strShipVia
	,[strTerm]					=	NULL
	,[strContractNumber]		=	F1.strContractNumber
	,[strBillOfLading]			=	A.strBillOfLading
	,[intContractHeaderId]		=	F1.intContractHeaderId
	,[intContractDetailId]		=	CASE WHEN A.strReceiptType = 'Purchase Contract' THEN B.intLineNo ELSE NULL END
	,[intScaleTicketId]			=	G.intTicketId
	,[strScaleTicketNumber]		=	CAST(G.strTicketNumber AS NVARCHAR(50))
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
	,[intCurrencyId]			=	CASE WHEN B.ysnSubCurrency > 0 THEN ISNULL(SubCurrency.intCurrencyID,0)
										 ELSE ISNULL(A.intCurrencyId,0) 
									END	
	,[strCurrency]				=   CASE WHEN B.ysnSubCurrency > 0 THEN SubCurrency.strCurrency
									ELSE (SELECT TOP 1 strCurrency FROM dbo.tblSMCurrency WHERE intCurrencyID = A.intCurrencyId)
									END
	,[strVendorLocation]		=	EL.strLocationName
	FROM tblICInventoryReceipt A
	INNER JOIN tblICInventoryReceiptItem B
		ON A.intInventoryReceiptId = B.intInventoryReceiptId
	INNER JOIN tblICItem C ON B.intItemId = C.intItemId
	INNER JOIN tblICItemLocation loc ON C.intItemId = loc.intItemId AND loc.intLocationId = A.intLocationId
	INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.intEntityVendorId = D2.intEntityId) ON A.[intEntityVendorId] = D1.intEntityVendorId
	LEFT JOIN (tblCTContractHeader CH INNER JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId)  ON CH.intEntityId = A.intEntityVendorId 
																															AND CH.intContractHeaderId = B.intOrderId 
																															AND CD.intContractDetailId = B.intLineNo 
	LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemUOMId = B.intWeightUOMId
	LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = ItemWeightUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM ItemCostUOM ON ItemCostUOM.intItemUOMId = B.intCostUOMId
	LEFT JOIN tblICUnitMeasure CostUOM ON CostUOM.intUnitMeasureId = ItemCostUOM.intUnitMeasureId
	LEFT JOIN tblSMShipVia E ON A.intShipViaId = E.[intEntityShipViaId]
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
		,[dblTax]									=	A.dblTax
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
		,[intScaleTicketId]							=	NULL
		,[strScaleTicketNumber]						=	CAST(NULL AS NVARCHAR(50))
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
															 THEN (SELECT ISNULL(intMainCurrencyId,0) FROM dbo.tblSMCurrency WHERE intCurrencyID = ISNULL(A.intCurrencyId,0))
															 ELSE  ISNULL(A.intCurrencyId,0)
														END			
		,[strCurrency]								=	CASE WHEN A.ysnSubCurrency > 0 
															 THEN (SELECT TOP 1 strCurrency FROM dbo.tblSMCurrency WHERE intCurrencyID IN (SELECT intMainCurrencyId FROM dbo.tblSMCurrency WHERE intCurrencyID = ISNULL(A.intCurrencyId,0)))
															 ELSE  (SELECT TOP 1 strCurrency FROM dbo.tblSMCurrency WHERE intCurrencyID = A.intCurrencyId)
														END	
		,[strVendorLocation]						=	NULL
	FROM [vyuAPChargesForBilling] A
	LEFT JOIN tblSMCurrencyExchangeRate F ON  (F.intFromCurrencyId = (SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference) AND F.intToCurrencyId = CASE WHEN A.ysnSubCurrency > 0 
																																						   THEN (SELECT ISNULL(intMainCurrencyId,0) FROM dbo.tblSMCurrency WHERE intCurrencyID = ISNULL(A.intCurrencyId,0))
																																						   ELSE  ISNULL(A.intCurrencyId,0) END) 
	LEFT JOIN dbo.tblSMCurrencyExchangeRateDetail G1 ON F.intCurrencyExchangeRateId = G1.intCurrencyExchangeRateId
	LEFT JOIN dbo.tblSMCurrency H1 ON H1.intCurrencyID = A.intCurrencyId
	LEFT JOIN dbo.tblSMCurrency SubCurrency ON SubCurrency.intMainCurrencyId = A.intCurrencyId 
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
	
	UNION ALL
	SELECT
		[intEntityVendorId]							=	A.intVendorEntityId
		,[dtmDate]									=	A.dtmInventorizedDate
		,[strReference]								=	''
		,[strSourceNumber]							=	LTRIM(A.intTrackingNumber)
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
		,[strVendorId]								=	LTRIM(A.intVendorEntityId)
		,[strShipVia]								=	NULL
		,[strTerm]									=	NULL
		,[strContractNumber]						=	A.strContractNumber
		,[strBillOfLading]							=	A.strBLNumber
		,[intContractHeaderId]						=	A.intContractHeaderId
		,[intContractDetailId]						=	A.intContractDetailId
		,[intScaleTicketId]							=	NULL
		,[strScaleTicketNumber]						=	CAST(NULL AS NVARCHAR(50))
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
		,[strVendorLocation]						=	NULL
	FROM vyuLGShipmentPurchaseContracts A
	LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = A.intItemId and ItemLoc.intLocationId = A.intCompanyLocationId
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = A.intItemUOMId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemUOMId = A.intWeightUOMId
	LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = ItemWeightUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM ItemCostUOM ON ItemCostUOM.intItemUOMId = A.intCostUOMId
	LEFT JOIN tblICUnitMeasure CostUOM ON CostUOM.intUnitMeasureId = ItemCostUOM.intUnitMeasureId
	WHERE A.ysnDirectShipment = 1 AND A.dtmInventorizedDate IS NOT NULL AND A.intShipmentContractQtyId NOT IN (SELECT IsNull(intShipmentContractQtyId, 0) FROM tblAPBillDetail)
	UNION ALL
	SELECT
	DISTINCT  
		[intEntityVendorId]							=	CC.intVendorId
		,[dtmDate]									=	CD.dtmStartDate
		,[strReference]								=	'' --?
		,[strSourceNumber]							=	LTRIM(CD.strContractNumber)
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
		,[strVendorId]								=	LTRIM(CC.intVendorId)
		,[strShipVia]								=	NULL
		,[strTerm]									=	NULL
		,[strContractNumber]						=	CD.strContractNumber
		,[strBillOfLading]							=	NULL
		,[intContractHeaderId]						=	CD.intContractHeaderId
		,[intContractDetailId]						=	CD.intContractDetailId
		,[intScaleTicketId]							=	NULL
		,[strScaleTicketNumber]						=	CAST(NULL AS NVARCHAR(50))
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
		,[strVendorLocation]						=	NULL
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
	WHERE		RC.intInventoryReceiptChargeId IS NULL
) Items
