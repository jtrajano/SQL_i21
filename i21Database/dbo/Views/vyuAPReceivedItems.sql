﻿CREATE VIEW [dbo].[vyuAPReceivedItems]
AS

SELECT
CAST(ROW_NUMBER() OVER(ORDER BY intInventoryShipmentItemId, intInventoryReceiptItemId, intPurchaseDetailId) AS INT) AS intReceivedItemId
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
		,[intContractChargeId]		=	NULL
		,[dblUnitCost]				=	tblReceived.dblUnitCost
		,[dblDiscount]				=	B.dblDiscount
		,[dblTax]					=	tblReceived.dblTax
		,[dblRate]					=	tblReceived.dblRate
		,[strRateType]				=	tblReceived.strCurrencyExchangeRateType
		,[intCurrencyExchangeRateTypeId] =	tblReceived.intForexRateTypeId
		,[ysnSubCurrency]			=	tblReceived.ysnSubCurrency
		,[intSubCurrencyCents]		=   tblReceived.intSubCurrencyCents
		,[intAccountId]				=	tblReceived.intAccountId
		,[strAccountId]				=	tblReceived.strAccountId
		,[strAccountDesc]			=	tblReceived.strAccountDesc
		,[strName]					=	D2.strName
		,[strVendorId]				=	D1.strVendorId
		,[strShipVia]				=	E.strShipVia
		,[strTerm]					=	F.strTerm
		,[intTermId]				=	A.intTermsId
		,[strContractNumber]		=	G1.strContractNumber
		,[strBillOfLading]			=	tblReceived.strBillOfLading
		,[intContractHeaderId]		=	G1.intContractHeaderId
		,[intContractDetailId]		=	G2.intContractDetailId
		,[intContractSequence]		=	G2.intContractSeq
		,[intScaleTicketId]			=	NULL
		,[strScaleTicketNumber]		=	CAST(NULL AS NVARCHAR(50))
		,[intShipmentId]			=	0            
		,[intLoadDetailId]			=	NULL
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
		,[str1099Form]				=	CASE 	WHEN patron.intEntityId IS NOT NULL 
														AND tblReceived.ysn1099Box3 = 1
														AND patron.ysnStockStatusQualified = 1 
														THEN '1099 PATR'
												ELSE D2.str1099Form	END
		,[str1099Type]				=	CASE 	WHEN patron.intEntityId IS NOT NULL 
														AND tblReceived.ysn1099Box3 = 1
														AND patron.ysnStockStatusQualified = 1 
														THEN 'Per-unit retain allocations'
													ELSE D2.str1099Type END
		,[intStorageLocationId]		=	tblReceived.intStorageLocationId		 
		,[strStorageLocationName]	=	tblReceived.strStorageLocationName
	
		,[dblNetShippedWeight]		=	0.00
		,[dblWeightLoss]			=	0.00
		,[dblFranchiseWeight]		=	0.00
		,[dblClaimAmount]			=	0.00
		,[intLocationId]			=	tblReceived.intLocationId
		,[strReceiptLocation]		=	tblReceived.strReceiptLocation
		,[intInventoryShipmentItemId]				=   NULL
		,[intInventoryShipmentChargeId]				=	NULL
		,[intTaxGroupId]							=	tblReceived.intTaxGroupId
		,[ysnReturn]								=	CAST(0 AS BIT)
		,[strTaxGroup]								=	tblReceived.strTaxGroup
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
				,ISNULL(NULLIF(B1.dblForexRate,0),1) AS dblRate
				,B1.intForexRateTypeId
				,RT.strCurrencyExchangeRateType
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
				,B1.intStorageLocationId
				,ISL.strName AS strStorageLocationName
				,intLocationId = A1.intLocationId
				,strReceiptLocation = (SELECT strLocationName FROM dbo.tblSMCompanyLocation WHERE intCompanyLocationId = A1.intLocationId)
				,B1.intTaxGroupId
				,TG.strTaxGroup
				,item.ysn1099Box3
			FROM tblICInventoryReceipt A1
				INNER JOIN tblICInventoryReceiptItem B1 ON A1.intInventoryReceiptId = B1.intInventoryReceiptId
				INNER JOIN tblICItemLocation loc ON B1.intItemId = loc.intItemId AND A1.intLocationId = loc.intLocationId
				LEFT JOIN tblICItem item ON B1.intItemId = item.intItemId
				--INNER JOIN dbo.tblICInventoryReceiptItemLot RIL ON RIL.intInventoryReceiptItemId = B1.intInventoryReceiptItemId
				LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemUOMId = B1.intWeightUOMId
				LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = ItemWeightUOM.intUnitMeasureId
				LEFT JOIN tblICItemUOM ItemCostUOM ON ItemCostUOM.intItemUOMId = B1.intCostUOMId
				LEFT JOIN tblICUnitMeasure CostUOM ON CostUOM.intUnitMeasureId = ItemCostUOM.intUnitMeasureId
				LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = B1.intUnitMeasureId
				LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
				LEFT JOIN tblSMCurrencyExchangeRate F ON  (F.intFromCurrencyId = (SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference) AND F.intToCurrencyId = A1.intCurrencyId) 
											--OR (F.intToCurrencyId = (SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference) AND F.intFromCurrencyId = A1.intCurrencyId)
				LEFT JOIN dbo.tblSMCurrencyExchangeRateDetail G ON F.intCurrencyExchangeRateId = G.intCurrencyExchangeRateId AND G.dtmValidFromDate = (SELECT CONVERT(char(10), GETDATE(),126)) 
				LEFT JOIN dbo.tblSMCurrency H ON H.intCurrencyID = A1.intCurrencyId
				LEFT JOIN dbo.tblEMEntityLocation EL ON EL.intEntityLocationId = A1.intShipFromId
				LEFT JOIN dbo.tblSMCurrency SubCurrency ON SubCurrency.intMainCurrencyId = A1.intCurrencyId AND SubCurrency.ysnSubCurrency = 1
				LEFT JOIN dbo.tblICStorageLocation ISL ON ISL.intStorageLocationId = B1.intStorageLocationId
				LEFT JOIN dbo.tblSMCurrencyExchangeRateType RT ON RT.intCurrencyExchangeRateTypeId = B1.intForexRateTypeId
				LEFT JOIN dbo.tblSMTaxGroup TG ON TG.intTaxGroupId = B1.intTaxGroupId
			WHERE A1.ysnPosted = 1 AND B1.dblOpenReceive != B1.dblBillQty 
			AND B1.dblOpenReceive > 0 --EXCLUDE NEGATIVE
			AND B.intPurchaseDetailId = B1.intLineNo
			AND A1.strReceiptType = 'Purchase Order'
			AND ISNULL(A1.ysnOrigin, 0) = 0
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
				,B1.intTaxGroupId
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
				,B1.intStorageLocationId
				,ISL.strName
				,A1.intLocationId
				,B1.intForexRateTypeId
				,B1.dblForexRate
				,RT.strCurrencyExchangeRateType
				,TG.strTaxGroup
				,item.ysn1099Box3
		) as tblReceived
		--ON B.intPurchaseDetailId = tblReceived.intLineNo AND B.intItemId = tblReceived.intItemId
		INNER JOIN tblICItem C ON B.intItemId = C.intItemId
		INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON A.[intEntityVendorId] = D1.[intEntityId]
		LEFT JOIN tblSMShipVia E ON A.intShipViaId = E.[intEntityId]
		LEFT JOIN tblSMTerm F ON A.intTermsId = F.intTermID
		LEFT JOIN vyuPATEntityPatron patron ON A.intEntityVendorId = patron.intEntityId
		LEFT JOIN (tblCTContractHeader G1 INNER JOIN tblCTContractDetail G2 ON G1.intContractHeaderId = G2.intContractHeaderId) 
				ON G1.intEntityId = D1.[intEntityId] AND B.intItemId = G2.intItemId AND B.intContractDetailId = G2.intContractDetailId
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
	,[intContractChargeId]		=	NULL  
	,[dblUnitCost]				=	B.dblCost
	,[dblDiscount]				=	B.dblDiscount
	,[dblTax]					=	ISNULL(B.dblTax,0)
	,[dblRate]					=	ISNULL(NULLIF(B.dblForexRate,0),1)
	,[strRateType]				=	RT.strCurrencyExchangeRateType
	,[intCurrencyExchangeRateTypeId] =	B.intForexRateTypeId
	,[ysnSubCurrency]			=	0
	,[intSubCurrencyCents]		=	0
	,[intAccountId]				=	CASE WHEN B.intItemId IS NULL THEN D1.intGLAccountExpenseId ELSE [dbo].[fnGetItemGLAccount](B.intItemId, loc.intItemLocationId, 'Other Charge Expense') END
	,[strAccountId]				=	(SELECT strAccountId FROM tblGLAccount WHERE intAccountId = 
										CASE WHEN B.intItemId IS NULL THEN D1.intGLAccountExpenseId ELSE dbo.fnGetItemGLAccount(B.intItemId, loc.intItemLocationId, 'Other Charge Expense') END
									)
	,[strAccountDesc]			=	(SELECT strDescription FROM tblGLAccount WHERE intAccountId = 
										CASE WHEN B.intItemId IS NULL THEN D1.intGLAccountExpenseId ELSE dbo.fnGetItemGLAccount(B.intItemId, loc.intItemLocationId, 'Other Charge Expense') END
									)
	,[strName]					=	D2.strName
	,[strVendorId]				=	D1.strVendorId
	,[strShipVia]				=	E.strShipVia
	,[strTerm]					=	F.strTerm
	,[intTermId]				=	A.intTermsId
	,[strContractNumber]		=	NULL
	,[strBillOfLading]			=	NULL
	,[intContractHeaderId]		=	NULL
	,[intContractDetailId]		=	NULL
	,[intContractSequence]		=	NULL
	,[intScaleTicketId]			=	NULL
	,[strScaleTicketNumber]		=	CAST(NULL AS NVARCHAR(50))
	,[intShipmentId]			=	0    
	,[intLoadDetailId]	=	NULL
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
	,[intCostCurrencyId]		=	ISNULL(A.intCurrencyId,0)
	,[strCostCurrency]			=	(SELECT TOP 1 strCurrency FROM dbo.tblSMCurrency WHERE intCurrencyID = A.intCurrencyId)
	,[strVendorLocation]		=	EL.strLocationName
	,[str1099Form]				=	D2.str1099Form			 
	,[str1099Type]				=	D2.str1099Type
	,[intStorageLocationId]		=	loc.intStorageLocationId	 
	,[strStorageLocationName]	=	(SELECT TOP 1 strName FROM dbo.tblICStorageLocation WHERE intStorageLocationId =loc.intStorageLocationId)
	,[dblNetShippedWeight]		=	0.00
	,[dblWeightLoss]			=	0.00
	,[dblFranchiseWeight]		=	0.00 
	,[dblClaimAmount]			=	0.00
	,[intLocationId]			=	A.intShipToId
	,[strReceiptLocation]		= (SELECT strLocationName FROM dbo.tblSMCompanyLocation WHERE intCompanyLocationId = A.intLocationId)
	,[intInventoryShipmentItemId]				=   NULL
	,[intInventoryShipmentChargeId]				=	NULL
	,[intTaxGroupId]							=	B.intTaxGroupId
	,[ysnReturn]								=	CAST(0 AS BIT)
	,[strTaxGroup]								=	TG.strTaxGroup
	FROM tblPOPurchase A
		INNER JOIN tblPOPurchaseDetail B ON A.intPurchaseId = B.intPurchaseId
		INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON A.[intEntityVendorId] = D1.[intEntityId]
		LEFT JOIN tblICItem C ON B.intItemId = C.intItemId
		LEFT JOIN tblICItemLocation loc ON C.intItemId = loc.intItemId AND loc.intLocationId = A.intShipToId
		LEFT JOIN tblSMShipVia E ON A.intShipViaId = E.[intEntityId]
		LEFT JOIN tblSMTerm F ON A.intTermsId = F.intTermID
		LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = B.intUnitOfMeasureId
		LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
		LEFT JOIN dbo.tblEMEntityLocation EL ON EL.intEntityLocationId = A.intShipFromId
		LEFT JOIN dbo.tblSMCurrencyExchangeRateType RT ON RT.intCurrencyExchangeRateTypeId = B.intForexRateTypeId
		LEFT JOIN dbo.tblSMTaxGroup TG ON TG.intTaxGroupId = B.intTaxGroupId
		OUTER APPLY
		(
			SELECT SUM(ISNULL(G.dblQtyReceived,0)) AS dblQty FROM tblAPBillDetail G WHERE G.intPurchaseDetailId = B.intPurchaseDetailId
			GROUP BY G.intPurchaseDetailId
		) Billed
	WHERE 1 = CASE WHEN C.intItemId IS NOT NULL THEN 
				(CASE WHEN C.strType IN ('Service','Software','Non-Inventory','Other Charge') THEN 1 ELSE 0 END )
			ELSE 1
			END
	AND B.dblQtyOrdered != B.dblQtyReceived
	AND ((Billed.dblQty < B.dblQtyReceived) OR Billed.dblQty IS NULL)
	UNION ALL
	--DIRECT TYPE
	SELECT DISTINCT
	[intEntityVendorId]			=	A.intEntityVendorId
	,[dtmDate]					=	A.dtmReceiptDate
	,[strReference]				=	A.strVendorRefNo
	,[strSourceNumber]			=	A.strReceiptNumber
	,[strPurchaseOrderNumber]	=	NULL--A.strReceiptNumber
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
	,[intContractChargeId]		=	NULL
	,[dblUnitCost]				=	CASE WHEN (B.dblUnitCost IS NULL OR B.dblUnitCost = 0)
												 THEN (CASE WHEN CD.dblCashPrice IS NOT NULL THEN CD.dblCashPrice ELSE B.dblUnitCost END)
												 ELSE B.dblUnitCost
											END  	
	,[dblDiscount]				=	0
	,[dblTax]					=	ISNULL(B.dblTax,0)
	,[dblRate]					=	ISNULL(NULLIF(B.dblForexRate,0),1)
	,[strRateType]				=	RT.strCurrencyExchangeRateType
	,[intCurrencyExchangeRateTypeId] =	B.intForexRateTypeId
	,[ysnSubCurrency]			=	CASE WHEN B.ysnSubCurrency > 0 THEN 1 ELSE 0 END
	,[intSubCurrencyCents]		=	ISNULL(A.intSubCurrencyCents, 0)
	,[intAccountId]				=	[dbo].[fnGetItemGLAccount](B.intItemId, loc.intItemLocationId, 'AP Clearing')
	,[strAccountId]				=	(SELECT strAccountId FROM tblGLAccount WHERE intAccountId = dbo.fnGetItemGLAccount(B.intItemId, loc.intItemLocationId, 'AP Clearing'))
	,[strAccountDesc]			=	(SELECT strDescription FROM tblGLAccount WHERE intAccountId = dbo.fnGetItemGLAccount(B.intItemId, loc.intItemLocationId, 'AP Clearing'))
	,[strName]					=	D2.strName
	,[strVendorId]				=	D1.strVendorId
	,[strShipVia]				=	E.strShipVia
	,[strTerm]					=	NULL
	,[intTermId]				=	NULL
	,[strContractNumber]		=	F1.strContractNumber
	,[strBillOfLading]			=	A.strBillOfLading
	,[intContractHeaderId]		=	F1.intContractHeaderId
	,[intContractDetailId]		=	CASE WHEN A.strReceiptType = 'Purchase Contract' THEN B.intLineNo ELSE NULL END
	,[intContractSequence]		=	CASE WHEN A.strReceiptType = 'Purchase Contract' THEN CD.intContractSeq ELSE NULL END
	,[intScaleTicketId]			=	G.intTicketId
	,[strScaleTicketNumber]		=	CAST(G.strTicketNumber AS NVARCHAR(50))
	,[intShipmentId]			=	0
	,[intLoadDetailId]			=	NULL
  	,[intUnitMeasureId]			=	B.intUnitMeasureId
	,[strUOM]					=	UOM.strUnitMeasure
	,[intWeightUOMId]			=	B.intWeightUOMId
	,[intCostUOMId]				=	B.intCostUOMId
	,[dblNetWeight]				=	CASE WHEN B.intWeightUOMId > 0 THEN  
													(CASE WHEN B.dblBillQty > 0 
															THEN ABS(B.dblOpenReceive - B.dblBillQty) * (ItemUOM.dblUnitQty/ ISNULL(ItemWeightUOM.dblUnitQty ,1)) --THIS IS FOR PARTIAL
														ELSE B.dblNet --THIS IS FOR NO RECEIVED QTY YET BUT HAS NET WEIGHT DIFFERENT FROM GROSS
											END)
									ELSE 0 END
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
		,[str1099Form]				=	CASE 	WHEN patron.intEntityId IS NOT NULL 
														AND C.ysn1099Box3 = 1
														AND patron.ysnStockStatusQualified = 1 
														THEN '1099 PATR'
												ELSE D2.str1099Form	END
		,[str1099Type]				=	CASE 	WHEN patron.intEntityId IS NOT NULL 
														AND C.ysn1099Box3 = 1
														AND patron.ysnStockStatusQualified = 1 
														THEN 'Per-unit retain allocations'
													ELSE D2.str1099Type END
	,[intStorageLocationId]		=	B.intStorageLocationId	 
	,[strStorageLocationName]	=	ISL.strName
	,[dblNetShippedWeight]		=	ISNULL(CASE WHEN A.strReceiptType = 'Purchase Contract' AND A.intSourceType = 2 THEN Loads.dblNet ELSE B.dblGross END,0)
	,[dblWeightLoss]			=	CASE WHEN A.strReceiptType = 'Purchase Contract' AND A.intSourceType = 2 THEN ISNULL(ISNULL(Loads.dblNet,0) - B.dblNet,0) ELSE 0 END
	,[dblFranchiseWeight]		=	CASE WHEN J.dblFranchise > 0 THEN ISNULL(B.dblGross,0) * (J.dblFranchise / 100) ELSE 0 END
	,[dblClaimAmount]			=	CASE WHEN A.strReceiptType = 'Purchase Contract' AND A.intSourceType = 2 THEN
										(CASE WHEN (ISNULL(ISNULL(Loads.dblNet,0) - B.dblNet,0) > 0) THEN 
										(
											(ISNULL(B.dblGross - B.dblNet,0) - (CASE WHEN J.dblFranchise > 0 THEN ISNULL(B.dblGross,0) * (J.dblFranchise / 100) ELSE 0 END)) * 
											(CASE WHEN B.dblNet > 0 THEN B.dblUnitCost * (CAST(ItemWeightUOM.dblUnitQty AS DECIMAL(18,6)) / CAST(ISNULL(ItemCostUOM.dblUnitQty,1) AS DECIMAL(18,6))) 
												  WHEN B.intCostUOMId > 0 THEN B.dblUnitCost * (CAST(ItemUOM.dblUnitQty AS DECIMAL(18,6)) / CAST(ISNULL(ItemCostUOM.dblUnitQty,1) AS DECIMAL(18,6))) 
											  ELSE B.dblUnitCost END) / CASE WHEN B.ysnSubCurrency > 0 THEN ISNULL(A.intSubCurrencyCents,1) ELSE 1 END
										) ELSE 0.00 END)
									ELSE 0 END
	,[intLocationId]			=	A.intLocationId
	,[strReceiptLocation]		= (SELECT strLocationName FROM dbo.tblSMCompanyLocation WHERE intCompanyLocationId = A.intLocationId)
	,[intInventoryShipmentItemId]				=   NULL
	,[intInventoryShipmentChargeId]				=	NULL
	,[intTaxGroupId]							=	B.intTaxGroupId
	,[ysnReturn]								=	CAST((CASE WHEN A.strReceiptType = 'Inventory Return' THEN 1 ELSE 0 END) AS BIT)
	,[strTaxGroup]								=	TG.strTaxGroup
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
	--FOR REVIEW, JOINING FOR CONTRACT IS ALREADY DEFINED ABOVE
	LEFT JOIN (tblCTContractHeader F1 INNER JOIN tblCTContractDetail F2 ON F1.intContractHeaderId = F2.intContractHeaderId) 
		ON F1.intEntityId = A.intEntityVendorId AND B.intItemId = F2.intItemId AND B.intLineNo = ISNULL(F2.intContractDetailId,0)
	LEFT JOIN tblSCTicket G ON (CASE WHEN A.intSourceType = 1 THEN B.intSourceId ELSE 0 END) = G.intTicketId
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = B.intUnitMeasureId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	LEFT JOIN tblSMCurrencyExchangeRate F ON  (F.intFromCurrencyId = (SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference) AND F.intToCurrencyId = A.intCurrencyId) 
	LEFT JOIN dbo.tblSMCurrencyExchangeRateDetail G1 ON F.intCurrencyExchangeRateId = G1.intCurrencyExchangeRateId AND G1.dtmValidFromDate = (SELECT CONVERT(char(10), GETDATE(),126))
	LEFT JOIN dbo.tblSMCurrency H1 ON H1.intCurrencyID = A.intCurrencyId
	LEFT JOIN dbo.tblEMEntityLocation EL ON EL.intEntityLocationId = A.intShipFromId
	LEFT JOIN dbo.tblSMCurrency SubCurrency ON SubCurrency.intMainCurrencyId = A.intCurrencyId 
	LEFT JOIN dbo.tblICStorageLocation ISL ON ISL.intStorageLocationId = B.intStorageLocationId 
	LEFT JOIN dbo.tblCTWeightGrade J ON CH.intWeightId = J.intWeightGradeId
	LEFT JOIN dbo.tblSMCurrencyExchangeRateType RT ON RT.intCurrencyExchangeRateTypeId = B.intForexRateTypeId
	LEFT JOIN dbo.tblSMTaxGroup TG ON TG.intTaxGroupId = B.intTaxGroupId
	LEFT JOIN vyuPATEntityPatron patron ON A.intEntityVendorId = patron.intEntityId
	OUTER APPLY 
	(
		SELECT SUM(ISNULL(H.dblQtyReceived,0)) AS dblQty FROM tblAPBillDetail H WHERE H.intInventoryReceiptItemId = B.intInventoryReceiptItemId AND H.intInventoryReceiptChargeId IS NULL
		GROUP BY H.intInventoryReceiptItemId
	) Billed
	OUTER APPLY (
		SELECT 
			K.dblNetWt AS dblNet
		FROM tblLGLoadContainer K
		WHERE K.intLoadContainerId = B.intContainerId
		--WHERE 1 = (CASE WHEN A.strReceiptType = 'Purchase Contract' AND A.intSourceType = 2
		--					AND K.intLoadContainerId = B.intContainerId 
		--				THEN 1
		--				ELSE 0 END)
	) Loads
	WHERE A.strReceiptType IN ('Direct','Purchase Contract','Inventory Return') AND A.ysnPosted = 1 AND B.dblBillQty != B.dblOpenReceive 
	AND 1 = (CASE WHEN A.strReceiptType = 'Purchase Contract' THEN
						CASE WHEN ISNULL(F1.intContractTypeId,1) = 1 
									AND F1.intPricingTypeId NOT IN (2, 3, 4) --AP-4971
							THEN 1 ELSE 0 END
					ELSE 1 END)
	AND B.dblOpenReceive > 0 --EXCLUDE NEGATIVE
	AND ((Billed.dblQty < B.dblOpenReceive) OR Billed.dblQty IS NULL)
	AND (CD.dblCashPrice != 0 OR CD.dblCashPrice IS NULL) --EXCLUDE ALL THE BASIS CONTRACT WITH 0 CASH PRICE
	AND B.dblUnitCost != 0 --EXCLUDE ZERO RECEIPT COST 
	AND ISNULL(A.ysnOrigin, 0) = 0
	AND B.intOwnershipType != 2
	UNION ALL

	--RECEIPT OTHER CHARGES
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
		,[intContractChargeId]						=	NULL
		,[dblUnitCost]								=	A.dblUnitCost
		,[dblDiscount]								=	0
		,[dblTax]									=	ISNULL((CASE WHEN ISNULL(A.intEntityVendorId, IR.intEntityVendorId) != IR.intEntityVendorId
																		THEN (CASE WHEN IRCT.ysnCheckoffTax = 0 THEN ABS(A.dblTax) 
																				ELSE A.dblTax END) --THIRD PARTY TAX SHOULD RETAIN NEGATIVE IF CHECK OFF
																	 ELSE (CASE WHEN A.ysnPrice = 1 AND IRCT.ysnCheckoffTax = 1 THEN A.dblTax * -1 
																	 		WHEN A.ysnPrice = 1 AND IRCT.ysnCheckoffTax = 0 THEN -A.dblTax --negate, inventory receipt will bring postive tax
																	 		ELSE A.dblTax END )
																	  END),0) -- RECEIPT VENDOR: WILL NEGATE THE TAX IF PRCE DOWN 
		,[dblRate]									=	ISNULL(NULLIF(A.dblForexRate,0),1)
		,[strRateType]								=	RT.strCurrencyExchangeRateType
		,[intCurrencyExchangeRateTypeId]			=	A.intForexRateTypeId
		,[ysnSubCurrency]							=	ISNULL(A.ysnSubCurrency,0)
		,[intSubCurrencyCents]						=	ISNULL(A.intSubCurrencyCents,0)
		,[intAccountId]								=	[dbo].[fnGetItemGLAccount](A.intItemId, ItemLoc.intItemLocationId, 'AP Clearing')
		,[strAccountId]								=	(SELECT strAccountId FROM tblGLAccount WHERE intAccountId = dbo.fnGetItemGLAccount(A.intItemId, ItemLoc.intItemLocationId, 'AP Clearing'))
		,[strAccountDesc]							=	(SELECT strDescription FROM tblGLAccount WHERE intAccountId = dbo.fnGetItemGLAccount(A.intItemId, ItemLoc.intItemLocationId, 'AP Clearing'))
		,[strName]									=	A.strName
		,[strVendorId]								=	A.strVendorId
		,[strShipVia]								=	NULL
		,[strTerm]									=	NULL
		,[intTermId]								=	NULL
		,[strContractNumber]						=	A.strContractNumber
		,[strBillOfLading]							=	NULL
		,[intContractHeaderId]						=	A.intContractHeaderId
		,[intContractDetailId]						=	A.intContractDetailId
		,[intContractSequence]						=	NULL
		,[intScaleTicketId]							=	A.intScaleTicketId
		,[strScaleTicketNumber]						=	A.strScaleTicketNumber
		,[intShipmentId]							=	0      
		,[intLoadDetailId]							=	NULL
  		,[intUnitMeasureId]							=	A.intCostUnitMeasureId
		,[strUOM]									=	A.strCostUnitMeasure
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
		,[str1099Form]								=	D2.str1099Form			 
		,[str1099Type]								=	D2.str1099Type
		,[intStorageLocationId]						=	NULL
		,[strStorageLocationName]					=	NULL
		,[dblNetShippedWeight]						=	0.00
		,[dblWeightLoss]							=	0.00
		,[dblFranchiseWeight]						=	0.00
		,[dblClaimAmount]							=	0.00
		,[intLocationId]							=	A.intLocationId
		,[strReceiptLocation]						= (SELECT strLocationName FROM dbo.tblSMCompanyLocation WHERE intCompanyLocationId = A.intLocationId)
		,[intInventoryShipmentItemId]				=   NULL
		,[intInventoryShipmentChargeId]				=	NULL
		,[intTaxGroupId]							=	NULL
		,[ysnReturn]								=	CAST((CASE WHEN A.strReceiptType = 'Inventory Return' THEN 1 ELSE 0 END) AS BIT)
		,[strTaxGroup]								=	NULL
	FROM [vyuICChargesForBilling] A
	--LEFT JOIN tblSMCurrencyExchangeRate F ON  (F.intFromCurrencyId = (SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference) AND F.intToCurrencyId = CASE WHEN A.ysnSubCurrency > 0 
	--																																					   THEN (SELECT ISNULL(intMainCurrencyId,0) FROM dbo.tblSMCurrency WHERE intCurrencyID = ISNULL(A.intCurrencyId,0))
	--																																					   ELSE  ISNULL(A.intCurrencyId,0) END) 
	LEFT JOIN dbo.tblSMCurrency H1 ON H1.intCurrencyID = A.intCurrencyId
	LEFT JOIN dbo.tblSMCurrency SubCurrency ON SubCurrency.intMainCurrencyId = A.intCurrencyId 
	INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON A.[intEntityVendorId] = D1.[intEntityId]
	LEFT JOIN dbo.tblSMCurrencyExchangeRateType RT ON RT.intCurrencyExchangeRateTypeId = A.intForexRateTypeId
	LEFT JOIN dbo.tblICInventoryReceipt IR ON IR.intInventoryReceiptId = A.intInventoryReceiptId
	LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = A.intItemId 
		 AND ItemLoc.intLocationId = A.intLocationId
	OUTER APPLY
	(
		SELECT TOP 1 ysnCheckoffTax FROM tblICInventoryReceiptChargeTax IRCT
		WHERE IRCT.intInventoryReceiptChargeId = A.intInventoryReceiptChargeId
	)  IRCT
	OUTER APPLY 
	(
		SELECT intEntityVendorId FROM tblAPBillDetail BD
		LEFT JOIN dbo.tblAPBill B ON BD.intBillId = B.intBillId
		WHERE BD.intInventoryReceiptChargeId = A.intInventoryReceiptChargeId

	) Billed
	--OUTER APPLY 
	--(
	--	SELECT SUM(ISNULL(H.dblQtyReceived,0)) AS dblQty FROM tblAPBillDetail H 
	--	INNER JOIN dbo.tblAPBill B ON B.intBillId = H.intBillId
	--	WHERE H.intInventoryReceiptChargeId = A.intInventoryReceiptChargeId
	--	GROUP BY H.intInventoryReceiptChargeId
			
	--) Qty
	WHERE  
		A.[intEntityVendorId] NOT IN (Billed.intEntityVendorId) OR (A.dblOrderQty > 0)
	UNION ALL
	SELECT
	DISTINCT  
		[intEntityVendorId]							=	CC.intVendorId
		,[dtmDate]									=	CD.dtmStartDate
		,[strReference]								=	'' --?
		,[strSourceNumber]							=	LTRIM(CH.strContractNumber)
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
		,[dblQuantityToBill]						=	CASE WHEN CC.strCostMethod = 'Per Unit' THEN ISNULL(CD.dblQuantity,0) ELSE 1 END
		,[dblQuantityBilled]						=	0
		,[intLineNo]								=	CD.intContractDetailId
		,[intInventoryReceiptItemId]				=	NULL
		,[intInventoryReceiptChargeId]				=	NULL
		,[intContractChargeId]						=	CC.intContractCostId      
		,[dblUnitCost]								=	ISNULL(CASE	WHEN	CC.strCostMethod = 'Percentage' THEN
																		dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,CD.intPriceItemUOMId,CD.dblQuantity) * CD.dblCashPrice * (CC.dblRate / 100) *
																		CASE WHEN CC.intCurrencyId = CD.intCurrencyId THEN 1 ELSE ISNULL(CC.dblFX,1) END
                                                               		WHEN	CC.strCostMethod = 'Per Unit' THEN       
																			
																			ISNULL(CC.dblRate,0)
																ELSE	ISNULL(CC.dblRate,0) 
														END,0)
		,[dblDiscount]								=	0
		,[dblTax]									=	0
		,[dblRate]									=	CASE WHEN CY.ysnSubCurrency > 0  THEN  ISNULL(RateDetail.dblRate,1) ELSE ISNULL(G1.dblRate,1) END
		,[strRateType]								=	NULL
		,[intCurrencyExchangeRateTypeId]			=	NULL
		,[ysnSubCurrency]							=	ISNULL(CY.ysnSubCurrency,0)
		,[intSubCurrencyCents]						=	CASE WHEN CY.ysnSubCurrency > 0 THEN CY.intCent ELSE 1 END
		,[intAccountId]								=	[dbo].[fnGetItemGLAccount](CC.intItemId, ItemLoc.intItemLocationId, 'AP Clearing')
		,[strAccountId]								=	(SELECT strAccountId FROM tblGLAccount WHERE intAccountId = dbo.fnGetItemGLAccount(CC.intItemId, ItemLoc.intItemLocationId, 'AP Clearing'))
		,[strAccountDesc]							=	(SELECT strDescription FROM tblGLAccount WHERE intAccountId = dbo.fnGetItemGLAccount(CC.intItemId, ItemLoc.intItemLocationId, 'AP Clearing'))
		,[strName]									=	CC.strVendorName
		,[strVendorId]								=	LTRIM(CC.intVendorId)
		,[strShipVia]								=	NULL
		,[strTerm]									=	NULL
		,[intTermId]								=	CC.intTermId	
		,[strContractNumber]						=	CH.strContractNumber
		,[strBillOfLading]							=	NULL
		,[intContractHeaderId]						=	CD.intContractHeaderId
		,[intContractDetailId]						=	CD.intContractDetailId
		,[intContractSequence]						=	CD.intContractSeq
		,[intScaleTicketId]							=	NULL
		,[strScaleTicketNumber]						=	CAST(NULL AS NVARCHAR(50))
		,[intShipmentId]							=	0     
		,[intShipmentContractQtyId]					=	NULL
		,[intUnitMeasureId]							=	CD.intItemUOMId
		,[strUOM]									=	UOM.strUnitMeasure
		,[intWeightUOMId]							=	NULL--CD.intNetWeightUOMId
		,[intCostUOMId]								=	CostUOM.intItemUOMId
		,[dblNetWeight]								=	0--ISNULL(CD.dblNetWeight,0)      
		,[strCostUOM]								=	CC.strUOM
		,[strgrossNetUOM]							=	CC.strUOM
		,[dblWeightUnitQty]							=	1
		,[dblCostUnitQty]							=	CostUOM.dblUnitQty
		,[dblUnitQty]								=	ItemUOM.dblUnitQty
		,[intCurrencyId]							=	CASE WHEN CY.ysnSubCurrency > 0 
															 THEN (SELECT ISNULL(intMainCurrencyId,0) FROM dbo.tblSMCurrency WHERE intCurrencyID = ISNULL(CC.intCurrencyId,0))
															 ELSE  ISNULL(CC.intCurrencyId,ISNULL(CU.intMainCurrencyId,CD.intCurrencyId))
														END		
		,[strCurrency]								=	CASE WHEN CY.ysnSubCurrency > 0 
															 THEN (SELECT TOP 1 strCurrency FROM dbo.tblSMCurrency WHERE intCurrencyID IN (SELECT intMainCurrencyId FROM dbo.tblSMCurrency WHERE intCurrencyID = ISNULL(CC.intCurrencyId,0)))
															 ELSE  ISNULL(CC.strCurrency, ((SELECT TOP 1 strCurrency FROM dbo.tblSMCurrency WHERE intCurrencyID = ISNULL(CU.intMainCurrencyId,CD.intCurrencyId))))
														END	
		,[intCostCurrencyId]						=	ISNULL(CC.intCurrencyId,ISNULL(CU.intMainCurrencyId,CD.intCurrencyId))	
		,[strCostCurrency]							=	ISNULL(CC.strCurrency, ((SELECT TOP 1 strCurrency FROM dbo.tblSMCurrency WHERE intCurrencyID = ISNULL(CU.intMainCurrencyId,CD.intCurrencyId))))
		,[strVendorLocation]						=	NULL
		,[str1099Form]								=	D2.str1099Form			 
		,[str1099Type]								=	D2.str1099Type 
		,[intStorageLocationId]						=	NULL
		,[strStorageLocationName]					=	NULL
		,[dblNetShippedWeight]						=	0.00
		,[dblWeightLoss]							=	0.00
		,[dblFranchiseWeight]						=	0.00
		,[dblClaimAmount]							=	0.00
		,[intLocationId]							=	NULL --Contract doesn't have location
		,[strReceiptLocation]						=	NULL
		,[intInventoryShipmentItemId]				=   NULL
		,[intInventoryShipmentChargeId]				=	NULL
		,[intTaxGroupId]							=	NULL
		,[ysnReturn]								=	CAST(0 AS BIT)
		,[strTaxGroup]								=	NULL
	FROM		vyuCTContractCostView		CC
	JOIN		tblCTContractDetail			CD	ON	CD.intContractDetailId	=	CC.intContractDetailId
													AND	CC.ysnAccrue		=	1
	JOIN		tblCTContractHeader			CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
	LEFT JOIN	tblSMCurrency				CU	ON	CU.intCurrencyID		=	CD.intCurrencyId
	LEFT JOIN	tblICItemLocation		ItemLoc ON	ItemLoc.intItemId		=	CC.intItemId			AND 
													ItemLoc.intLocationId	=	CD.intCompanyLocationId
	LEFT JOIN	tblICInventoryReceiptCharge RC	ON	RC.intContractId		=	CC.intContractHeaderId	AND 
													RC.intChargeId			=	CC.intItemId
	LEFT JOIN	tblICItemUOM			ItemUOM ON	ItemUOM.intItemUOMId	=	CD.intItemUOMId
	LEFT JOIN	tblICItemUOM			CostUOM ON	CostUOM.intItemId		=	CD.intItemId
												AND	CostUOM.intUnitMeasureId	=	CC.intUnitMeasureId		
	LEFT JOIN	tblICUnitMeasure			UOM ON	UOM.intUnitMeasureId	=	ItemUOM.intUnitMeasureId
	LEFT JOIN	tblSMCurrencyExchangeRate F ON  (F.intFromCurrencyId = (SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference) AND F.intToCurrencyId = CC.intCurrencyId) 
	LEFT JOIN	tblSMCurrencyExchangeRateDetail G1 ON F.intCurrencyExchangeRateId = G1.intCurrencyExchangeRateId
	LEFT JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID		=	CC.intCurrencyId
	LEFT JOIN	tblSMCurrencyExchangeRate Rate ON  (Rate.intFromCurrencyId = (SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference) AND Rate.intToCurrencyId = CU.intMainCurrencyId) 
	LEFT JOIN	tblSMCurrencyExchangeRateDetail RateDetail ON Rate.intCurrencyExchangeRateId = RateDetail.intCurrencyExchangeRateId
	INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON CC.intVendorId = D1.[intEntityId]  
	WHERE		RC.intInventoryReceiptChargeId IS NULL AND CC.ysnBasis = 0
	AND ysnBilled = 0 AND CC.ysnPrice = 1
	UNION ALL

	SELECT
	DISTINCT  
		 [intEntityVendorId]						=	CH.intEntityId
		,[dtmDate]									=	CD.dtmStartDate
		,[strReference]								=	'' --?
		,[strSourceNumber]							=	LTRIM(CH.strContractNumber)
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
		,[dblQuantityToBill]						=	CASE WHEN CC.strCostMethod = 'Per Unit' THEN ISNULL(CD.dblQuantity,0) ELSE 1 END
		,[dblQuantityBilled]						=	0
		,[intLineNo]								=	CD.intContractDetailId
		,[intInventoryReceiptItemId]				=	NULL
		,[intInventoryReceiptChargeId]				=	NULL
		,[intContractChargeId]						=	CC.intContractCostId      
		,[dblUnitCost]								=	ISNULL(CASE	WHEN	CC.strCostMethod = 'Percentage' THEN
																		dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,CD.intPriceItemUOMId,CD.dblQuantity) * CD.dblCashPrice * (CC.dblRate / 100) *
																		CASE WHEN CC.intCurrencyId = CD.intCurrencyId THEN 1 ELSE ISNULL(CC.dblFX,1) END
                                                               		WHEN	CC.strCostMethod = 'Per Unit' THEN       
																			ISNULL(CC.dblRate,0)
																ELSE	ISNULL(CC.dblRate,0) 
														END,0)
		,[dblDiscount]								=	0
		,[dblTax]									=	0
		,[dblRate]									=	CASE WHEN CY.ysnSubCurrency > 0  THEN  ISNULL(RateDetail.dblRate,1) ELSE ISNULL(G1.dblRate,1) END
		,[strRateType]								=	NULL
		,[intCurrencyExchangeRateTypeId]			=	NULL
		,[ysnSubCurrency]							=	ISNULL(CY.ysnSubCurrency,0)
		,[intSubCurrencyCents]						=	CASE WHEN CY.ysnSubCurrency > 0 THEN CY.intCent ELSE 1 END
		,[intAccountId]								=	[dbo].[fnGetItemGLAccount](CC.intItemId, ItemLoc.intItemLocationId, 'AP Clearing')
		,[strAccountId]								=	(SELECT strAccountId FROM tblGLAccount WHERE intAccountId = dbo.fnGetItemGLAccount(CC.intItemId, ItemLoc.intItemLocationId, 'AP Clearing'))
		,[strAccountDesc]							=	(SELECT strDescription FROM tblGLAccount WHERE intAccountId = dbo.fnGetItemGLAccount(CC.intItemId, ItemLoc.intItemLocationId, 'AP Clearing'))
		,[strName]									=	CC.strVendorName
		,[strVendorId]								=	LTRIM(CC.intVendorId)
		,[strShipVia]								=	NULL
		,[strTerm]									=	NULL
		,[intTermId]								=	CC.intTermId	
		,[strContractNumber]						=	CH.strContractNumber
		,[strBillOfLading]							=	NULL
		,[intContractHeaderId]						=	CD.intContractHeaderId
		,[intContractDetailId]						=	CD.intContractDetailId
		,[intContractSequence]						=	CD.intContractSeq
		,[intScaleTicketId]							=	NULL
		,[strScaleTicketNumber]						=	CAST(NULL AS NVARCHAR(50))
		,[intShipmentId]							=	0     
		,[intShipmentContractQtyId]					=	NULL
		,[intUnitMeasureId]							=	CD.intItemUOMId
		,[strUOM]									=	UOM.strUnitMeasure
		,[intWeightUOMId]							=	NULL--CD.intNetWeightUOMId
		,[intCostUOMId]								=	CostUOM.intItemUOMId
		,[dblNetWeight]								=	0--ISNULL(CD.dblNetWeight,0)      
		,[strCostUOM]								=	CC.strUOM
		,[strgrossNetUOM]							=	CC.strUOM
		,[dblWeightUnitQty]							=	1
		,[dblCostUnitQty]							=	CostUOM.dblUnitQty
		,[dblUnitQty]								=	ItemUOM.dblUnitQty
		,[intCurrencyId]							=	CASE WHEN CY.ysnSubCurrency > 0 
															 THEN (SELECT ISNULL(intMainCurrencyId,0) FROM dbo.tblSMCurrency WHERE intCurrencyID = ISNULL(CC.intCurrencyId,0))
															 ELSE  ISNULL(CC.intCurrencyId,ISNULL(CU.intMainCurrencyId,CD.intCurrencyId))
														END		
		,[strCurrency]								=	CASE WHEN CY.ysnSubCurrency > 0 
															 THEN (SELECT TOP 1 strCurrency FROM dbo.tblSMCurrency WHERE intCurrencyID IN (SELECT intMainCurrencyId FROM dbo.tblSMCurrency WHERE intCurrencyID = ISNULL(CC.intCurrencyId,0)))
															 ELSE  ISNULL(CC.strCurrency, ((SELECT TOP 1 strCurrency FROM dbo.tblSMCurrency WHERE intCurrencyID = ISNULL(CU.intMainCurrencyId,CD.intCurrencyId))))
														END	
		,[intCostCurrencyId]						=	ISNULL(CC.intCurrencyId,ISNULL(CU.intMainCurrencyId,CD.intCurrencyId))	
		,[strCostCurrency]							=	ISNULL(CC.strCurrency, ((SELECT TOP 1 strCurrency FROM dbo.tblSMCurrency WHERE intCurrencyID = ISNULL(CU.intMainCurrencyId,CD.intCurrencyId))))
		,[strVendorLocation]						=	NULL
		,[str1099Form]								=	D2.str1099Form			 
		,[str1099Type]								=	D2.str1099Type 
		,[intStorageLocationId]						=	NULL
		,[strStorageLocationName]					=	NULL
		,[dblNetShippedWeight]						=	0.00
		,[dblWeightLoss]							=	0.00
		,[dblFranchiseWeight]						=	0.00
		,[dblClaimAmount]							=	0.00
		,[intLocationId]							=	NULL --Contract doesn't have location
		,[strReceiptLocation]						=	NULL
		,[intInventoryShipmentItemId]				=   NULL
		,[intInventoryShipmentChargeId]				=	NULL
		,[intTaxGroupId]							=	NULL
		,[ysnReturn]								=	CAST(0 AS BIT)
		,[strTaxGroup]								=	NULL
	FROM		vyuCTContractCostView		CC
	JOIN		tblCTContractDetail			CD	ON	CD.intContractDetailId	=	CC.intContractDetailId
												AND	CC.ysnPrice				=	1
												AND CD.intPricingTypeId		IN	(1,6)
	JOIN		tblCTContractHeader			CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
	LEFT JOIN	tblSMCurrency				CU	ON	CU.intCurrencyID		=	CD.intCurrencyId
	LEFT JOIN	tblICItemLocation		ItemLoc ON	ItemLoc.intItemId		=	CC.intItemId			AND 
													ItemLoc.intLocationId	=	CD.intCompanyLocationId
	LEFT JOIN	tblICInventoryReceiptCharge RC	ON	RC.intContractId		=	CC.intContractHeaderId	AND 
													RC.intChargeId			=	CC.intItemId
	LEFT JOIN	tblICItemUOM			ItemUOM ON	ItemUOM.intItemUOMId	=	CD.intItemUOMId
	LEFT JOIN	tblICItemUOM			CostUOM ON	CostUOM.intItemId		=	CD.intItemId
												AND	CostUOM.intUnitMeasureId	=	CC.intUnitMeasureId		
	LEFT JOIN	tblICUnitMeasure			UOM ON	UOM.intUnitMeasureId	=	ItemUOM.intUnitMeasureId
	LEFT JOIN	tblSMCurrencyExchangeRate F ON  (F.intFromCurrencyId = (SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference) AND F.intToCurrencyId = CC.intCurrencyId) 
	LEFT JOIN	tblSMCurrencyExchangeRateDetail G1 ON F.intCurrencyExchangeRateId = G1.intCurrencyExchangeRateId
	LEFT JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID		=	CC.intCurrencyId
	LEFT JOIN	tblSMCurrencyExchangeRate Rate ON  (Rate.intFromCurrencyId = (SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference) AND Rate.intToCurrencyId = CU.intMainCurrencyId) 
	LEFT JOIN	tblSMCurrencyExchangeRateDetail RateDetail ON Rate.intCurrencyExchangeRateId = RateDetail.intCurrencyExchangeRateId
	INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON CC.intVendorId = D1.[intEntityId]  
	WHERE		RC.intInventoryReceiptChargeId IS NULL AND CC.ysnBasis = 0
	AND ysnBilled = 0
	UNION ALL

	SELECT
	DISTINCT  
		[intEntityVendorId]							=	CC.intVendorId
		,[dtmDate]									=	CD.dtmStartDate
		,[strReference]								=	'' --?
		,[strSourceNumber]							=	LTRIM(CH.strContractNumber)
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
		,[dblQuantityToBill]						=	CASE WHEN CC.strCostMethod = 'Per Unit' THEN ISNULL(CD.dblQuantity,0) ELSE 1 END
		,[dblQuantityBilled]						=	0
		,[intLineNo]								=	CD.intContractDetailId
		,[intInventoryReceiptItemId]				=	NULL
		,[intInventoryReceiptChargeId]				=	NULL
		,[intContractChargeId]						=	CC.intContractCostId      
		,[dblUnitCost]								=	ISNULL(CASE	WHEN	CC.strCostMethod = 'Percentage' THEN
																		dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,CD.intPriceItemUOMId,CD.dblQuantity) * CD.dblCashPrice * (CC.dblRate / 100) *
																		CASE WHEN CC.intCurrencyId = CD.intCurrencyId THEN 1 ELSE ISNULL(CC.dblFX,1) END
                                                               		WHEN	CC.strCostMethod = 'Per Unit' THEN       
																			
																			ISNULL(CC.dblRate,0)
																ELSE	ISNULL(CC.dblRate,0) 
														END,0)
		,[dblDiscount]								=	0
		,[dblTax]									=	0
		,[dblRate]									=	CASE WHEN CY.ysnSubCurrency > 0  THEN  ISNULL(RateDetail.dblRate,1) ELSE ISNULL(G1.dblRate,1) END
		,[strRateType]								=	NULL
		,[intCurrencyExchangeRateTypeId]			=	NULL
		,[ysnSubCurrency]							=	ISNULL(CY.ysnSubCurrency,0)
		,[intSubCurrencyCents]						=	CASE WHEN CY.ysnSubCurrency > 0 THEN CY.intCent ELSE 1 END
		,[intAccountId]								=	[dbo].[fnGetItemGLAccount](CC.intItemId, ItemLoc.intItemLocationId, 'AP Clearing')
		,[strAccountId]								=	(SELECT strAccountId FROM tblGLAccount WHERE intAccountId = dbo.fnGetItemGLAccount(CC.intItemId, ItemLoc.intItemLocationId, 'AP Clearing'))
		,[strAccountDesc]							=	(SELECT strDescription FROM tblGLAccount WHERE intAccountId = dbo.fnGetItemGLAccount(CC.intItemId, ItemLoc.intItemLocationId, 'AP Clearing'))
		,[strName]									=	CC.strVendorName
		,[strVendorId]								=	LTRIM(CC.intVendorId)
		,[strShipVia]								=	NULL
		,[strTerm]									=	NULL
		,[intTermId]								=	CC.intTermId	
		,[strContractNumber]						=	CH.strContractNumber
		,[strBillOfLading]							=	NULL
		,[intContractHeaderId]						=	CD.intContractHeaderId
		,[intContractDetailId]						=	CD.intContractDetailId
		,[intContractSequence]						=	CD.intContractSeq
		,[intScaleTicketId]							=	NULL
		,[strScaleTicketNumber]						=	CAST(NULL AS NVARCHAR(50))
		,[intShipmentId]							=	0     
		,[intShipmentContractQtyId]					=	NULL
		,[intUnitMeasureId]							=	CD.intItemUOMId
		,[strUOM]									=	UOM.strUnitMeasure
		,[intWeightUOMId]							=	NULL--CD.intNetWeightUOMId
		,[intCostUOMId]								=	CostUOM.intItemUOMId
		,[dblNetWeight]								=	0--ISNULL(CD.dblNetWeight,0)      
		,[strCostUOM]								=	CC.strUOM
		,[strgrossNetUOM]							=	CC.strUOM
		,[dblWeightUnitQty]							=	1
		,[dblCostUnitQty]							=	CostUOM.dblUnitQty
		,[dblUnitQty]								=	ItemUOM.dblUnitQty
		,[intCurrencyId]							=	CASE WHEN CY.ysnSubCurrency > 0 
															 THEN (SELECT ISNULL(intMainCurrencyId,0) FROM dbo.tblSMCurrency WHERE intCurrencyID = ISNULL(CC.intCurrencyId,0))
															 ELSE  ISNULL(CC.intCurrencyId,ISNULL(CU.intMainCurrencyId,CD.intCurrencyId))
														END		
		,[strCurrency]								=	CASE WHEN CY.ysnSubCurrency > 0 
															 THEN (SELECT TOP 1 strCurrency FROM dbo.tblSMCurrency WHERE intCurrencyID IN (SELECT intMainCurrencyId FROM dbo.tblSMCurrency WHERE intCurrencyID = ISNULL(CC.intCurrencyId,0)))
															 ELSE  ISNULL(CC.strCurrency, ((SELECT TOP 1 strCurrency FROM dbo.tblSMCurrency WHERE intCurrencyID = ISNULL(CU.intMainCurrencyId,CD.intCurrencyId))))
														END	
		,[intCostCurrencyId]						=	ISNULL(CC.intCurrencyId,ISNULL(CU.intMainCurrencyId,CD.intCurrencyId))	
		,[strCostCurrency]							=	ISNULL(CC.strCurrency, ((SELECT TOP 1 strCurrency FROM dbo.tblSMCurrency WHERE intCurrencyID = ISNULL(CU.intMainCurrencyId,CD.intCurrencyId))))
		,[strVendorLocation]						=	NULL
		,[str1099Form]								=	D2.str1099Form			 
		,[str1099Type]								=	D2.str1099Type 
		,[intStorageLocationId]						=	NULL
		,[strStorageLocationName]					=	NULL
		,[dblNetShippedWeight]						=	0.00
		,[dblWeightLoss]							=	0.00
		,[dblFranchiseWeight]						=	0.00
		,[dblClaimAmount]							=	0.00
		,[intLocationId]							=	NULL --Contract doesn't have location
		,[strReceiptLocation]						=	NULL
		,[intInventoryShipmentItemId]				=   NULL
		,[intInventoryShipmentChargeId]				=	NULL
		,[intTaxGroupId]							=	NULL
		,[ysnReturn]								=	CAST(1 AS BIT)
		,[strTaxGroup]								=	NULL
	FROM		vyuCTContractCostView		CC
	JOIN		tblCTContractDetail			CD	ON	CD.intContractDetailId	=	CC.intContractDetailId
													AND	CC.ysnAccrue		=	1
	JOIN		tblCTContractHeader			CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
	LEFT JOIN	tblSMCurrency				CU	ON	CU.intCurrencyID		=	CD.intCurrencyId
	LEFT JOIN	tblICItemLocation		ItemLoc ON	ItemLoc.intItemId		=	CC.intItemId			AND 
													ItemLoc.intLocationId	=	CD.intCompanyLocationId
	LEFT JOIN	tblICInventoryReceiptCharge RC	ON	RC.intContractId		=	CC.intContractHeaderId	AND 
													RC.intChargeId			=	CC.intItemId
	LEFT JOIN	tblICItemUOM			ItemUOM ON	ItemUOM.intItemUOMId	=	CD.intItemUOMId
	LEFT JOIN	tblICItemUOM			CostUOM ON	CostUOM.intItemId		=	CD.intItemId
												AND	CostUOM.intUnitMeasureId	=	CC.intUnitMeasureId		
	LEFT JOIN	tblICUnitMeasure			UOM ON	UOM.intUnitMeasureId	=	ItemUOM.intUnitMeasureId
	LEFT JOIN	tblSMCurrencyExchangeRate F ON  (F.intFromCurrencyId = (SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference) AND F.intToCurrencyId = CC.intCurrencyId) 
	LEFT JOIN	tblSMCurrencyExchangeRateDetail G1 ON F.intCurrencyExchangeRateId = G1.intCurrencyExchangeRateId
	LEFT JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID		=	CC.intCurrencyId
	LEFT JOIN	tblSMCurrencyExchangeRate Rate ON  (Rate.intFromCurrencyId = (SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference) AND Rate.intToCurrencyId = CU.intMainCurrencyId) 
	LEFT JOIN	tblSMCurrencyExchangeRateDetail RateDetail ON Rate.intCurrencyExchangeRateId = RateDetail.intCurrencyExchangeRateId
	INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON CC.intVendorId = D1.[intEntityId]  
	WHERE		RC.intInventoryReceiptChargeId IS NULL AND CC.ysnBasis = 0
	AND ysnBilled = 0 
	AND CC.strCostStatus = 'Open'
	
	UNION ALL

	SELECT
	DISTINCT  
		 [intEntityVendorId]						=	CH.intEntityId
		,[dtmDate]									=	CD.dtmStartDate
		,[strReference]								=	'' --?
		,[strSourceNumber]							=	LTRIM(CH.strContractNumber)
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
		,[dblQuantityToBill]						=	CASE WHEN CC.strCostMethod = 'Per Unit' THEN ISNULL(CD.dblQuantity,0) ELSE 1 END
		,[dblQuantityBilled]						=	0
		,[intLineNo]								=	CD.intContractDetailId
		,[intInventoryReceiptItemId]				=	NULL
		,[intInventoryReceiptChargeId]				=	NULL
		,[intContractChargeId]						=	CC.intContractCostId      
		,[dblUnitCost]								=	ISNULL(CASE	WHEN	CC.strCostMethod = 'Percentage' THEN
																		dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,CD.intPriceItemUOMId,CD.dblQuantity) * CD.dblCashPrice * (CC.dblRate / 100) *
																		CASE WHEN CC.intCurrencyId = CD.intCurrencyId THEN 1 ELSE ISNULL(CC.dblFX,1) END
                                                               		WHEN	CC.strCostMethod = 'Per Unit' THEN       
																			ISNULL(CC.dblRate,0)
																ELSE	ISNULL(CC.dblRate,0) 
														END,0)
		,[dblDiscount]								=	0
		,[dblTax]									=	0
		,[dblRate]									=	CASE WHEN CY.ysnSubCurrency > 0  THEN  ISNULL(RateDetail.dblRate,1) ELSE ISNULL(G1.dblRate,1) END
		,[strRateType]								=	NULL
		,[intCurrencyExchangeRateTypeId]			=	NULL
		,[ysnSubCurrency]							=	ISNULL(CY.ysnSubCurrency,0)
		,[intSubCurrencyCents]						=	CASE WHEN CY.ysnSubCurrency > 0 THEN CY.intCent ELSE 1 END
		,[intAccountId]								=	[dbo].[fnGetItemGLAccount](CC.intItemId, ItemLoc.intItemLocationId, 'AP Clearing')
		,[strAccountId]								=	(SELECT strAccountId FROM tblGLAccount WHERE intAccountId = dbo.fnGetItemGLAccount(CC.intItemId, ItemLoc.intItemLocationId, 'AP Clearing'))
		,[strAccountDesc]							=	(SELECT strDescription FROM tblGLAccount WHERE intAccountId = dbo.fnGetItemGLAccount(CC.intItemId, ItemLoc.intItemLocationId, 'AP Clearing'))
		,[strName]									=	CC.strVendorName
		,[strVendorId]								=	LTRIM(CC.intVendorId)
		,[strShipVia]								=	NULL
		,[strTerm]									=	NULL
		,[intTermId]								=	CC.intTermId	
		,[strContractNumber]						=	CH.strContractNumber
		,[strBillOfLading]							=	NULL
		,[intContractHeaderId]						=	CD.intContractHeaderId
		,[intContractDetailId]						=	CD.intContractDetailId
		,[intContractSequence]						=	CD.intContractSeq
		,[intScaleTicketId]							=	NULL
		,[strScaleTicketNumber]						=	CAST(NULL AS NVARCHAR(50))
		,[intShipmentId]							=	0     
		,[intShipmentContractQtyId]					=	NULL
		,[intUnitMeasureId]							=	CD.intItemUOMId
		,[strUOM]									=	UOM.strUnitMeasure
		,[intWeightUOMId]							=	NULL--CD.intNetWeightUOMId
		,[intCostUOMId]								=	CostUOM.intItemUOMId
		,[dblNetWeight]								=	0--ISNULL(CD.dblNetWeight,0)      
		,[strCostUOM]								=	CC.strUOM
		,[strgrossNetUOM]							=	CC.strUOM
		,[dblWeightUnitQty]							=	1
		,[dblCostUnitQty]							=	CostUOM.dblUnitQty
		,[dblUnitQty]								=	ItemUOM.dblUnitQty
		,[intCurrencyId]							=	CASE WHEN CY.ysnSubCurrency > 0 
															 THEN (SELECT ISNULL(intMainCurrencyId,0) FROM dbo.tblSMCurrency WHERE intCurrencyID = ISNULL(CC.intCurrencyId,0))
															 ELSE  ISNULL(CC.intCurrencyId,ISNULL(CU.intMainCurrencyId,CD.intCurrencyId))
														END		
		,[strCurrency]								=	CASE WHEN CY.ysnSubCurrency > 0 
															 THEN (SELECT TOP 1 strCurrency FROM dbo.tblSMCurrency WHERE intCurrencyID IN (SELECT intMainCurrencyId FROM dbo.tblSMCurrency WHERE intCurrencyID = ISNULL(CC.intCurrencyId,0)))
															 ELSE  ISNULL(CC.strCurrency, ((SELECT TOP 1 strCurrency FROM dbo.tblSMCurrency WHERE intCurrencyID = ISNULL(CU.intMainCurrencyId,CD.intCurrencyId))))
														END	
		,[intCostCurrencyId]						=	ISNULL(CC.intCurrencyId,ISNULL(CU.intMainCurrencyId,CD.intCurrencyId))	
		,[strCostCurrency]							=	ISNULL(CC.strCurrency, ((SELECT TOP 1 strCurrency FROM dbo.tblSMCurrency WHERE intCurrencyID = ISNULL(CU.intMainCurrencyId,CD.intCurrencyId))))
		,[strVendorLocation]						=	NULL
		,[str1099Form]								=	D2.str1099Form			 
		,[str1099Type]								=	D2.str1099Type 
		,[intStorageLocationId]						=	NULL
		,[strStorageLocationName]					=	NULL
		,[dblNetShippedWeight]						=	0.00
		,[dblWeightLoss]							=	0.00
		,[dblFranchiseWeight]						=	0.00
		,[dblClaimAmount]							=	0.00
		,[intLocationId]							=	NULL --Contract doesn't have location
		,[strReceiptLocation]						=	NULL
		,[intInventoryShipmentItemId]				=   NULL
		,[intInventoryShipmentChargeId]				=	NULL
		,[intTaxGroupId]							=	NULL
		,[ysnReturn]								=	CAST(1 AS BIT)
		,[strTaxGroup]								=	NULL
	FROM		vyuCTContractCostView		CC
	JOIN		tblCTContractDetail			CD	ON	CD.intContractDetailId	=	CC.intContractDetailId
												AND	CC.ysnPrice				=	1
												AND CD.intPricingTypeId		IN	(1,6)
	JOIN		tblCTContractHeader			CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
	LEFT JOIN	tblSMCurrency				CU	ON	CU.intCurrencyID		=	CD.intCurrencyId
	LEFT JOIN	tblICItemLocation		ItemLoc ON	ItemLoc.intItemId		=	CC.intItemId			AND 
													ItemLoc.intLocationId	=	CD.intCompanyLocationId
	LEFT JOIN	tblICInventoryReceiptCharge RC	ON	RC.intContractId		=	CC.intContractHeaderId	AND 
													RC.intChargeId			=	CC.intItemId
	LEFT JOIN	tblICItemUOM			ItemUOM ON	ItemUOM.intItemUOMId	=	CD.intItemUOMId
	LEFT JOIN	tblICItemUOM			CostUOM ON	CostUOM.intItemId		=	CD.intItemId
												AND	CostUOM.intUnitMeasureId	=	CC.intUnitMeasureId		
	LEFT JOIN	tblICUnitMeasure			UOM ON	UOM.intUnitMeasureId	=	ItemUOM.intUnitMeasureId
	LEFT JOIN	tblSMCurrencyExchangeRate F ON  (F.intFromCurrencyId = (SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference) AND F.intToCurrencyId = CC.intCurrencyId) 
	LEFT JOIN	tblSMCurrencyExchangeRateDetail G1 ON F.intCurrencyExchangeRateId = G1.intCurrencyExchangeRateId
	LEFT JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID		=	CC.intCurrencyId
	LEFT JOIN	tblSMCurrencyExchangeRate Rate ON  (Rate.intFromCurrencyId = (SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference) AND Rate.intToCurrencyId = CU.intMainCurrencyId) 
	LEFT JOIN	tblSMCurrencyExchangeRateDetail RateDetail ON Rate.intCurrencyExchangeRateId = RateDetail.intCurrencyExchangeRateId
	INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON CC.intVendorId = D1.[intEntityId]  
	WHERE		RC.intInventoryReceiptChargeId IS NULL AND CC.ysnBasis = 0
	AND ysnBilled = 0
	
	UNION ALL
	SELECT
		[intEntityVendorId]							=	A.intVendorEntityId
		,[dtmDate]									=	A.dtmPostedDate
		,[strReference]								=	''
		,[strSourceNumber]							=	LTRIM(A.strLoadNumber)
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
		,[intLineNo]								=	A.intLoadDetailId
		,[intInventoryReceiptItemId]				=	A.intInventoryReceiptItemId
		,[intInventoryReceiptChargeId]				=	NULL
		,[intContractChargeId]						=	NULL
		,[dblUnitCost]								=	ISNULL(A.dblCashPrice,0)
		,[dblDiscount]								=	0
		,[dblTax]									=	0
		,[dblRate]									=	1
		,[strRateType]								=	NULL
		,[intCurrencyExchangeRateTypeId]			=	NULL
		,[ysnSubCurrency]							=	CASE WHEN ISNULL(A.intSubCurrencyCents,0) > 0 THEN 1 ELSE 0 END --A.ysnSubCurrency
		,[intSubCurrencyCents]						=	ISNULL(A.intSubCurrencyCents,0)
		,[intAccountId]								=	[dbo].[fnGetItemGLAccount](A.intItemId, ItemLoc.intItemLocationId, 'AP Clearing')
		,[strAccountId]								=	(SELECT strAccountId FROM tblGLAccount WHERE intAccountId = dbo.fnGetItemGLAccount(A.intItemId, ItemLoc.intItemLocationId, 'AP Clearing'))
		,[strAccountDesc]							=	(SELECT strDescription FROM tblGLAccount WHERE intAccountId = dbo.fnGetItemGLAccount(A.intItemId, ItemLoc.intItemLocationId, 'AP Clearing'))
		,[strName]									=	A.strVendor
		,[strVendorId]								=	LTRIM(A.intVendorEntityId)
		,[strShipVia]								=	NULL
		,[strTerm]									=	NULL
		,[intTermId]								=	NULL
		,[strContractNumber]						=	A.strContractNumber
		,[strBillOfLading]							=	A.strBLNumber
		,[intContractHeaderId]						=	A.intContractHeaderId
		,[intContractDetailId]						=	A.intPContractDetailId
		,[intContractSequence]						=	A.intContractSeq
		,[intScaleTicketId]							=	NULL
		,[strScaleTicketNumber]						=	CAST(NULL AS NVARCHAR(50))
		,[intShipmentId]							=	A.intLoadId
		,[intShipmentContractQtyId]					=	A.intLoadDetailId
		,[intUnitMeasureId]							=	A.intItemUOMId
		,[strUOM]									=	UOM.strUnitMeasure
		,[intWeightUOMId]							=	A.intWeightItemUOMId
		,[intCostUOMId]								=	A.intPriceItemUOMId
		,[dblNetWeight]								=	ISNULL(A.dblNet,0)      
		,[strCostUOM]								=	A.strPriceUOM
		,[strgrossNetUOM]							=	A.strWeightUOM
		--,[dblUnitQty]								=	dbo.fnLGGetItemUnitConversion (A.intItemId, A.intPriceItemUOMId, A.intWeightUOMId)
		,[dblWeightUnitQty]							=	ISNULL(ItemWeightUOM.dblUnitQty,1)
		,[dblCostUnitQty]							=	ISNULL(ItemCostUOM.dblUnitQty,1)
		,[dblUnitQty]								=	ISNULL(ItemUOM.dblUnitQty,1)
		,[intCurrencyId]							=	A.intCurrencyId
		,[strCurrency]								=	A.strLoadCurrency
		,[intCostCurrencyId]						=	A.intContractCurrencyId
		,[strCostCurrency]							=	A.strCurrency
		,[strVendorLocation]						=	NULL
		,[str1099Form]								=	D2.str1099Form			 
		,[str1099Type]								=	D2.str1099Type 
		,[intStorageLocationId]						=	NULL
		,[strStorageLocationName]					=	NULL
		,[dblNetShippedWeight]						=	0.00
		,[dblWeightLoss]							=	0.00
		,[dblFranchiseWeight]						=	0.00
		,[dblClaimAmount]							=	0.00
		,[intLocationId]							=	A.intCompanyLocationId
		,[strReceiptLocation]						=	(SELECT strLocationName FROM dbo.tblSMCompanyLocation WHERE intCompanyLocationId = A.intCompanyLocationId)
		,[intInventoryShipmentItemId]				=   NULL
		,[intInventoryShipmentChargeId]				=	NULL
		,[intTaxGroupId]							=	NULL
		,[ysnReturn]								=	CAST(0 AS BIT)
		,[strTaxGroup]								=	NULL
	FROM vyuLGLoadPurchaseContracts A
	LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = A.intItemId and ItemLoc.intLocationId = A.intCompanyLocationId
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = A.intItemUOMId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemUOMId = A.intWeightItemUOMId
	LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = ItemWeightUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM ItemCostUOM ON ItemCostUOM.intItemUOMId = A.intCostUOMId
	LEFT JOIN tblICUnitMeasure CostUOM ON CostUOM.intUnitMeasureId = ItemCostUOM.intUnitMeasureId
	INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON A.[intEntityVendorId] = D1.[intEntityId]
	WHERE A.intLoadDetailId NOT IN 
		(SELECT IsNull(BD.intLoadDetailId, 0) 
			FROM tblAPBillDetail BD 
		JOIN tblICItem Item ON Item.intItemId = BD.intItemId
		WHERE BD.intItemId = A.intItemId AND Item.strType <> 'Other Charge') AND A.dtmPostedDate IS NOT NULL 
	
	UNION ALL

	--SHIPMENT OTHER CHARGES
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
		,[intInventoryReceiptItemId]				=	NULL
		,[intInventoryReceiptChargeId]				=	NULL
		,[intContractChargeId]						=	NULL
		,[dblUnitCost]								=	A.dblUnitCost
		,[dblDiscount]								=	0
		,[dblTax]									=	ISNULL(Taxes.dblTax,0)
		,[dblRate]									=	ISNULL(NULLIF(A.dblForexRate,0),1)
		,[strRateType]								=	RT.strCurrencyExchangeRateType
		,[intCurrencyExchangeRateTypeId]			=	A.intForexRateTypeId
		,[ysnSubCurrency]							=	ISNULL(A.ysnSubCurrency,0)
		,[intSubCurrencyCents]						=	ISNULL(A.intSubCurrencyCents,0)
		,[intAccountId]								=	A.intAccountId
		,[strAccountId]								=	A.strAccountId
		,[strAccountDesc]							=	(SELECT strDescription FROM tblGLAccount WHERE intAccountId = A.intAccountId)
		,[strName]									=	A.strName
		,[strVendorId]								=	A.strVendorId
		,[strShipVia]								=	NULL
		,[strTerm]									=	NULL
		,[intTermId]								=	NULL
		,[strContractNumber]						=	A.strContractNumber
		,[strBillOfLading]							=	NULL
		,[intContractHeaderId]						=	A.intContractHeaderId
		,[intContractDetailId]						=	A.intContractDetailId
		,[intContractSequence]						=	NULL
		,[intScaleTicketId]							=	A.intScaleTicketId
		,[strScaleTicketNumber]						=	A.strScaleTicketNumber
		,[intShipmentId]							=	0--ISNULL(A.intInventoryShipmentItemId,0)
		,[intShipmentContractQtyId]					=	NULL
  		,[intUnitMeasureId]							=	A.intCostUnitMeasureId
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
		,[str1099Form]								=	D2.str1099Form			 
		,[str1099Type]								=	D2.str1099Type
		,[intStorageLocationId]						=	NULL
		,[strStorageLocationName]					=	NULL
		,[dblNetShippedWeight]						=	0.00
		,[dblWeightLoss]							=	0.00
		,[dblFranchiseWeight]						=	0.00
		,[dblClaimAmount]							=	0.00
		,[intLocationId]							=	A.intLocationId
		,[strReceiptLocation]						=	NULL
		,[intInventoryShipmentItemId]				=	A.intInventoryShipmentItemId
		,[intInventoryShipmentChargeId]				=	A.intInventoryShipmentChargeId
		,[intTaxGroupId]							=	NULL
		,[ysnReturn]								=	CAST(0 AS BIT)
		,[strTaxGroup]								=	NULL
	FROM vyuICShipmentChargesForBilling A
	LEFT JOIN tblSMCurrencyExchangeRate F ON  (F.intFromCurrencyId = (SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference) AND F.intToCurrencyId = CASE WHEN A.ysnSubCurrency > 0 
																																						   THEN (SELECT ISNULL(intMainCurrencyId,0) FROM dbo.tblSMCurrency WHERE intCurrencyID = ISNULL(A.intCurrencyId,0))
																																						   ELSE  ISNULL(A.intCurrencyId,0) END) 
	LEFT JOIN dbo.tblSMCurrencyExchangeRateDetail G1 ON F.intCurrencyExchangeRateId = G1.intCurrencyExchangeRateId
	LEFT JOIN dbo.tblSMCurrency H1 ON H1.intCurrencyID = A.intCurrencyId
	LEFT JOIN dbo.tblSMCurrency SubCurrency ON SubCurrency.intMainCurrencyId = A.intCurrencyId 
	INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON A.[intEntityVendorId] = D1.[intEntityId]
	INNER JOIN dbo.tblICItem I ON I.intItemId = A.intItemId
	LEFT JOIN dbo.tblEMEntityLocation EL ON A.intEntityVendorId = EL.intEntityId AND D1.intShipFromId = EL.intEntityLocationId
	LEFT JOIN dbo.tblAPVendorSpecialTax VST ON VST.intEntityVendorId = A.intEntityVendorId
	LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = (SELECT TOP 1 intCompanyLocationId  FROM tblSMUserRoleCompanyLocationPermission)
	LEFT JOIN tblICCategoryTax B ON I.intCategoryId = B.intCategoryId
	LEFT JOIN tblSMTaxClass C ON B.intTaxClassId = C.intTaxClassId 
	LEFT JOIN tblSMTaxCode D ON D.intTaxClassId = C.intTaxClassId 
	LEFT JOIN dbo.tblSMCurrencyExchangeRateType RT ON RT.intCurrencyExchangeRateTypeId = A.intForexRateTypeId
	OUTER APPLY fnGetItemTaxComputationForVendor(A.intItemId, A.intEntityVendorId, A.dtmDate, A.dblUnitCost, 1, (CASE WHEN VST.intTaxGroupId > 0 THEN VST.intTaxGroupId
																													  WHEN CL.intTaxGroupId  > 0 THEN CL.intTaxGroupId 
																													  WHEN EL.intTaxGroupId > 0  THEN EL.intTaxGroupId ELSE 0 END), CL.intCompanyLocationId, D1.intShipFromId , 0, NULL, 0, NULL) Taxes
	OUTER APPLY 
	(
		SELECT intEntityVendorId FROM tblAPBillDetail BD
		LEFT JOIN dbo.tblAPBill B ON BD.intBillId = B.intBillId
		WHERE BD.intInventoryShipmentChargeId = A.intInventoryShipmentChargeId

	) Billed
	OUTER APPLY 
	(
		SELECT SUM(ISNULL(H.dblQtyReceived,0)) AS dblQty FROM tblAPBillDetail H 
		INNER JOIN dbo.tblAPBill B ON B.intBillId = H.intBillId
		WHERE H.intInventoryShipmentChargeId = A.intInventoryShipmentChargeId
		GROUP BY H.intInventoryShipmentChargeId
			
	) Qty
	WHERE A.[intEntityVendorId] NOT IN (Billed.intEntityVendorId) OR (A.dblOrderQty > 0)

	UNION ALL
	SELECT [intEntityVendorId] = I.intEntityCustomerId
	  ,[dtmDate]								= I.dtmDate
	  ,[strReference]							= I.strInvoiceNumber
	  ,[strSourceNumber]						= I.strInvoiceNumber
	  ,[strPurchaseOrderNumber]					= NULL
	  ,[intPurchaseOrderDetailId]				= NULL
	  ,[intItemId]								= NULL
	  ,[strMiscDescription]						= 'Cash Refund'
	  ,[strItemNo]								= NULL	
	  ,[strDescription]							= ''
	  ,[intPurchaseTaxGroupId]					= NULL	
	  ,[dblOrderQty]							= 1	
	  ,[dblPOOpenReceive]						= 0	
	  ,[dblOpenReceive]							= 1
	  ,[dblQuantityToBill]						= 1	
	  ,[dblQuantityBilled]						= 0
	  ,[intLineNo]								= I.intInvoiceId	
	  ,[intInventoryReceiptItemId]				= NULL
	  ,[intInventoryReceiptChargeId]			= NULL	
	  ,[intContractChargeId]					= NULL	
	  ,[dblUnitCost]							= I.dblInvoiceTotal	
	  ,[dblDiscount]							= 0	
	  ,[dblTax]									= 0	
	  ,[dblRate]								= 1	
	  ,[strRateType]							= RT.strCurrencyExchangeRateType	
	  ,[intCurrencyExchangeRateTypeId]			= ID.intCurrencyExchangeRateTypeId	
	  ,[ysnSubCurrency]							= 0	
	  ,[intSubCurrencyCents]					= 0
	  ,[intAccountId]							= GLA.[intAccountId]
	  ,[strAccountId]							= GLA.strAccountId	
	  ,[strAccountDesc]							= GLA.strDescription	
	  ,[strName]								= E.strName
	  ,[strVendorId]							= CAST(I.intEntityCustomerId AS VARCHAR)
	  ,[strShipVia]								= NULL
	  ,[strTerm]								= NULL
	  ,[intTermId]								= I.intTermId
	  ,[strContractNumber]						= NULL	
	  ,[strBillOfLading]						= NULL	
	  ,[intContractHeaderId]					= NULL	
	  ,[intContractDetailId]					= NULL	
	  ,[intContractSequence]					= NULL	
	  ,[intScaleTicketId]						= NULL	
	  ,[strScaleTicketNumber]					= CAST(NULL AS NVARCHAR(50))	
	  ,[intShipmentId]							= 0
	  ,[intShipmentContractQtyId]				= NULL
	  ,[intUnitMeasureId]						= NULL
	  ,[strUOM]									= NULL
	  ,[intWeightUOMId]							= NULL
	  ,[intCostUOMId]							= NULL
	  ,[dblNetWeight]							= NULL
	  ,[strCostUOM]								= NULL
	  ,[strgrossNetUOM]							= NULL
	  ,[dblWeightUnitQty]						= NULL
	  ,[dblCostUnitQty]							= NULL
	  ,[dblUnitQty]								= NULL
	  ,[intCurrencyId]							= I.intCurrencyId
	  ,[strCurrency]							= CY.strCurrency
	  ,[intCostCurrencyId]						= NULL
	  ,[strCostCurrency]						= NULL
	  ,[strVendorLocation]						= NULL
	  ,[str1099Form]							= NULL		 
	  ,[str1099Type]							= NULL
	  ,[intStorageLocationId]					= NULL
	  ,[strStorageLocationName]					= NULL
	  ,[dblNetShippedWeight]					= 0.00
	  ,[dblWeightLoss]							= 0.00
	  ,[dblFranchiseWeight]						= 0.00
	  ,[dblClaimAmount]							= 0.00
	  ,[intLocationId]							= NULL 
	  ,[strReceiptLocation]						= NULL
	  ,[intInventoryShipmentItemId]				= NULL
	  ,[intInventoryShipmentChargeId]			= NULL
	  ,[intTaxGroupId]							= NULL
	  ,[ysnReturn]								= CAST(0 AS BIT)
	  ,[strTaxGroup]							= NULL
	FROM tblARInvoice I
	INNER JOIN tblARInvoiceDetail ID
		ON ID.intInvoiceId = I.intInvoiceId
	INNER JOIN tblARPaymentDetail PD
		ON PD.intInvoiceId = I.intInvoiceId
	INNER JOIN tblARPayment P
		ON P.intPaymentId = PD.intPaymentId
	LEFT JOIN tblARInvoice SourceInvoice
		ON SourceInvoice.intInvoiceId = I.intSourceId
	LEFT JOIN dbo.tblSMCurrencyExchangeRateType RT ON RT.intCurrencyExchangeRateTypeId = ID.intCurrencyExchangeRateId
	--CROSS APPLY(SELECT TOP 1 intAPClearingAccountId, strAccountId, strDescription FROM tblARCompanyPreference ACP INNER JOIN tblGLAccount GL ON ACP.intAPClearingAccountId = GL.intAccountId) APC
	LEFT OUTER JOIN tblSMCompanyLocation SMCL
		ON I.[intCompanyLocationId] = SMCL.[intCompanyLocationId]
	LEFT OUTER JOIN tblGLAccount GLA
		ON SMCL.[intAPAccount] = GLA.[intAccountId] 		
	LEFT JOIN (tblAPVendor V INNER JOIN tblEMEntity E ON V.intEntityId = E.intEntityId)
		ON I.intEntityCustomerId = V.intEntityId
	LEFT JOIN tblSMCurrency CY	
		ON	CY.intCurrencyID = I.intCurrencyId
WHERE 
I.ysnPosted = 1 AND P.ysnPosted = 1 and I.strTransactionType = 'Cash Refund' and I.intInvoiceId NOT IN(SELECT intInvoiceId FROM tblAPBillDetail WHERE intInvoiceId IS NOT NULL)
) Items
GO
