CREATE VIEW [dbo].[vyuAPReceivedItems]
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
		,[dblUnitCost]				=	CAST(tblReceived.dblUnitCost AS DECIMAL(38,20))
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
		,[strContractNumber]		=	CAST(G1.strContractNumber AS NVARCHAR(100))
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
		,[dblNetWeight]				=	CAST(tblReceived.dblNetWeight AS DECIMAL(38,20))
		,[strCostUOM]				=	tblReceived.costUOM
		,[strgrossNetUOM]			=	tblReceived.grossNetUOM
  		,[dblWeightUnitQty]			=	CAST(tblReceived.weightUnitQty AS DECIMAL(38,20))
		,[dblCostUnitQty]			=	CAST(tblReceived.costUnitQty AS DECIMAL(38,20))
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
		,[intSubLocationId]			=	tblReceived.intSubLocationId
		,[strSubLocationName]		=	tblReceived.strSubLocationName
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
		,[intFreightTermId]							=	tblReceived.intFreightTermId
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
				,CAST(B1.dblUnitCost AS DECIMAL(38,20)) AS dblUnitCost
				,dbo.fnCalculateQtyBetweenUOM(B1.intUnitMeasureId, B.intUnitOfMeasureId, SUM(ISNULL(B1.dblOpenReceive,0))) dblPOOpenReceive
				,SUM(ISNULL(B1.dblOpenReceive,0)) dblOpenReceive
				,intAccountId = apClearing.intAccountId
				,strAccountId = apClearing.strAccountId
				,strAccountDesc = apClearing.strDescription
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
				,B1.intSubLocationId
				,subLoc.strSubLocationName
				,B1.intStorageLocationId
				,ISL.strName AS strStorageLocationName
				,intLocationId = A1.intLocationId
				,strReceiptLocation = (SELECT strLocationName FROM dbo.tblSMCompanyLocation WHERE intCompanyLocationId = A1.intLocationId)
				,B1.intTaxGroupId
				,A1.intFreightTermId
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
				LEFT JOIN dbo.tblSMCompanyLocationSubLocation subLoc ON B1.intSubLocationId = subLoc.intCompanyLocationSubLocationId
				LEFT JOIN dbo.tblSMCurrencyExchangeRateType RT ON RT.intCurrencyExchangeRateTypeId = B1.intForexRateTypeId
				LEFT JOIN dbo.tblSMTaxGroup TG ON TG.intTaxGroupId = B1.intTaxGroupId
				OUTER APPLY dbo.fnGetItemGLAccountAsTable(B1.intItemId, loc.intItemLocationId, 'AP Clearing') itemAccnt
				LEFT JOIN dbo.tblGLAccount apClearing ON apClearing.intAccountId = itemAccnt.intAccountId
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
				,A1.intFreightTermId
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
				,apClearing.intAccountId
				,apClearing.strAccountId
				,apClearing.strDescription
				,SubCurrency.intCurrencyID
				,SubCurrency.strCurrency
				,A1.intCurrencyId
				,B1.intStorageLocationId
				,B1.intSubLocationId
				,subLoc.strSubLocationName
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
	,[dblPOOpenReceive]			=	B.dblQtyOrdered -ISNULL(Billed.dblQty,0)
	,[dblOpenReceive]			=	B.dblQtyOrdered
	,[dblQuantityToBill]		=	B.dblQtyOrdered - ISNULL(Billed.dblQty,0)
	,[dblQuantityBilled]		=	ISNULL(Billed.dblQty,0)
	,[intLineNo]				=	B.intPurchaseDetailId
	,[intInventoryReceiptItemId]=	NULL --this should be null as this has constraint from IR Receipt item
	,[intInventoryReceiptChargeId]	= NULL
	,[intContractChargeId]		=	NULL  
	,[dblUnitCost]				=	CAST(B.dblCost AS DECIMAL(38,20))
	,[dblDiscount]				=	B.dblDiscount
	,[dblTax]					=	ISNULL(B.dblTax,0)
	,[dblRate]					=	ISNULL(NULLIF(B.dblForexRate,0),1)
	,[strRateType]				=	RT.strCurrencyExchangeRateType
	,[intCurrencyExchangeRateTypeId] =	B.intForexRateTypeId
	,[ysnSubCurrency]			=	0
	,[intSubCurrencyCents]		=	0
	,[intAccountId]				=	CASE WHEN B.intItemId IS NULL THEN D1.intGLAccountExpenseId 
										ELSE  ISNULL(B.intAccountId, otherCharge.intAccountId) END
	,[strAccountId]				=	(SELECT strAccountId FROM tblGLAccount WHERE intAccountId = 
										CASE WHEN B.intItemId IS NULL THEN D1.intGLAccountExpenseId ELSE ISNULL(B.intAccountId, otherCharge.intAccountId) END
									)
	,[strAccountDesc]			=	(SELECT strDescription FROM tblGLAccount WHERE intAccountId = 
										CASE WHEN B.intItemId IS NULL THEN B.intAccountId ELSE ISNULL(B.intAccountId, otherCharge.intAccountId) END
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
	,[dblNetWeight]				=	CAST(0  AS DECIMAL(38,20))
	,[strCostUOM]				=	NULL
	,[strgrossNetUOM]			=	NULL
	,[dblWeightUnitQty]			=	CAST(1 AS DECIMAL(38,20))
	,[dblCostUnitQty]			=	CAST(1 AS DECIMAL(38,20))
	,[dblUnitQty]				=	1
	,[intCurrencyId]			=	ISNULL(A.intCurrencyId,0)
	,[strCurrency]				=	(SELECT TOP 1 strCurrency FROM dbo.tblSMCurrency WHERE intCurrencyID = A.intCurrencyId)
	,[intCostCurrencyId]		=	ISNULL(A.intCurrencyId,0)
	,[strCostCurrency]			=	(SELECT TOP 1 strCurrency FROM dbo.tblSMCurrency WHERE intCurrencyID = A.intCurrencyId)
	,[strVendorLocation]		=	EL.strLocationName
	,[str1099Form]				=	CASE WHEN patron.intEntityId IS NOT NULL 
														AND C.ysn1099Box3 = 1
														AND patron.ysnStockStatusQualified = 1 
														THEN '1099 PATR'
												ELSE D2.str1099Form	END
	,[str1099Type]				=	CASE WHEN patron.intEntityId IS NOT NULL 
														AND C.ysn1099Box3 = 1
														AND patron.ysnStockStatusQualified = 1 
														THEN 'Per-unit retain allocations'
													ELSE D2.str1099Type END
	,[intSubLocationId]			=	NULL
	,[strSubLocationName]		=	NULL
	,[intStorageLocationId]		=	NULL
	,[strStorageLocationName]	=	NULL
	,[dblNetShippedWeight]		=	0.00
	,[dblWeightLoss]			=	0.00
	,[dblFranchiseWeight]		=	0.00 
	,[dblClaimAmount]			=	0.00
	,[intLocationId]			=	A.intShipToId
	,[strReceiptLocation]		= (SELECT strLocationName FROM dbo.tblSMCompanyLocation WHERE intCompanyLocationId = A.intLocationId)
	,[intInventoryShipmentItemId]				=   NULL
	,[intInventoryShipmentChargeId]				=	NULL
	,[intTaxGroupId]							=	B.intTaxGroupId
	,[intFreightTermId]							=	A.intFreightTermId
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
		LEFT JOIN vyuPATEntityPatron patron ON A.intEntityVendorId = patron.intEntityId
		OUTER APPLY dbo.fnGetItemGLAccountAsTable(B.intItemId, loc.intItemLocationId, 'Other Charge Expense') itemAccnt
		LEFT JOIN dbo.tblGLAccount otherCharge ON otherCharge.intAccountId = itemAccnt.intAccountId
		OUTER APPLY
		(
			SELECT SUM(ISNULL(G.dblQtyReceived,0)) AS dblQty FROM tblAPBillDetail G WHERE G.intPurchaseDetailId = B.intPurchaseDetailId
			GROUP BY G.intPurchaseDetailId
		) Billed
		OUTER APPLY
		(
			select strApprovalStatus from tblSMTransaction T
			WHERE T.intRecordId = A.intPurchaseId and T.strTransactionNo = strPurchaseOrderNumber
		) approval
	WHERE 1 = CASE WHEN C.intItemId IS NOT NULL THEN 
				(CASE WHEN C.strType IN ('Service','Software','Non-Inventory','Other Charge') THEN 1 ELSE 0 END )
			ELSE 1
			END
	AND B.dblQtyOrdered != B.dblQtyReceived
	AND ((Billed.dblQty <= B.dblQtyOrdered) OR Billed.dblQty IS NULL) --WILL HANDLE PARTIAL MISC ITEMS
	AND (approval.strApprovalStatus != 'Waiting for Approval' or approval.strApprovalStatus is null) --WILL NOT SHOW FOR APPROVAL TRANSACTION
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
	,[dblOrderQty]				=	CASE WHEN CD.intContractDetailId > 0 THEN ROUND(CD.dblQuantity,2) ELSE B.dblOpenReceive END
	,[dblPOOpenReceive]			=	B.dblReceived
	,[dblOpenReceive]			=	B.dblOpenReceive
	,[dblQuantityToBill]		=	CAST (CASE WHEN CD.intContractDetailId > 0  
											THEN dbo.fnCalculateQtyBetweenUOM((CASE WHEN B.intWeightUOMId > 0 
																						THEN B.intWeightUOMId ELSE B.intUnitMeasureId END),
														 CD.intItemUOMId, (B.dblOpenReceive - B.dblBillQty)) 
									ELSE (B.dblOpenReceive - B.dblBillQty) END AS DECIMAL(18,6)) 
	,[dblQuantityBilled]		=	B.dblBillQty
	,[intLineNo]				=	B.intInventoryReceiptItemId
	,[intInventoryReceiptItemId]=	B.intInventoryReceiptItemId
	,[intInventoryReceiptChargeId]	= NULL
	,[intContractChargeId]		=	NULL
	,[dblUnitCost]				=	CAST(CASE WHEN (B.dblUnitCost IS NULL OR B.dblUnitCost = 0)
												 THEN (CASE WHEN CD.dblCashPrice IS NOT NULL THEN CD.dblCashPrice ELSE B.dblUnitCost END)
												 ELSE B.dblUnitCost
											END AS DECIMAL(38,20))  	
	,[dblDiscount]				=	0
	,[dblTax]					=	ISNULL(B.dblTax,0)
	,[dblRate]					=	ISNULL(NULLIF(B.dblForexRate,0),1)
	,[strRateType]				=	RT.strCurrencyExchangeRateType
	,[intCurrencyExchangeRateTypeId] =	B.intForexRateTypeId
	,[ysnSubCurrency]			=	CASE WHEN B.ysnSubCurrency > 0 THEN 1 ELSE 0 END
	,[intSubCurrencyCents]		=	ISNULL(A.intSubCurrencyCents, 0)
	,[intAccountId]				=	apClearing.intAccountId
	,[strAccountId]				=	apClearing.strAccountId
	,[strAccountDesc]			=	apClearing.strDescription
	,[strName]					=	D2.strName
	,[strVendorId]				=	D1.strVendorId
	,[strShipVia]				=	E.strShipVia
	,[strTerm]					=	NULL
	,[intTermId]				=	NULL
	,[strContractNumber]		=	CH.strContractNumber
	,[strBillOfLading]			=	A.strBillOfLading
	,[intContractHeaderId]		=	CH.intContractHeaderId
	,[intContractDetailId]		=	CASE WHEN A.strReceiptType = 'Purchase Contract' THEN B.intLineNo ELSE NULL END
	,[intContractSequence]		=	CASE WHEN A.strReceiptType = 'Purchase Contract' THEN CD.intContractSeq ELSE NULL END
	,[intScaleTicketId]			=	G.intTicketId
	,[strScaleTicketNumber]		=	CAST(G.strTicketNumber AS NVARCHAR(50))
	,[intShipmentId]			=	0
	,[intLoadDetailId]			=	NULL
  	,[intUnitMeasureId]			=	CASE WHEN CD.intContractDetailId > 0 THEN CD.intItemUOMId ELSE B.intUnitMeasureId END 
	,[strUOM]					=	CASE WHEN CD.intContractDetailId > 0 THEN ctUOM.strUnitMeasure ELSE UOM.strUnitMeasure END
	,[intWeightUOMId]			=	B.intWeightUOMId
	,[intCostUOMId]				=	B.intCostUOMId
	,[dblNetWeight]				=	CAST(CASE WHEN B.intWeightUOMId > 0 THEN  
													(CASE WHEN B.dblBillQty > 0 
															THEN ABS(B.dblOpenReceive - B.dblBillQty) * (ItemUOM.dblUnitQty/ ISNULL(ItemWeightUOM.dblUnitQty ,1)) --THIS IS FOR PARTIAL
														ELSE B.dblNet --THIS IS FOR NO RECEIVED QTY YET BUT HAS NET WEIGHT DIFFERENT FROM GROSS
											END)
									ELSE 0 END AS DECIMAL(38,20))
	,[strCostUOM]				=	CostUOM.strUnitMeasure
	,[strgrossNetUOM]			=	WeightUOM.strUnitMeasure
	,[dblWeightUnitQty]			=	CAST(ISNULL(ItemWeightUOM.dblUnitQty,1)  AS DECIMAL(38,20))
	,[dblCostUnitQty]			=	CAST(ISNULL(ItemCostUOM.dblUnitQty,1) AS DECIMAL(38,20))
	,[dblUnitQty]				=	ISNULL(ItemUOM.dblUnitQty,1)
	,[intCurrencyId]			=	ISNULL(A.intCurrencyId,compPref.intDefaultCurrencyId)
	,[strCurrency]				=   H1.strCurrency
	,[intCostCurrencyId]		=	CASE WHEN B.ysnSubCurrency > 0 THEN ISNULL(SubCurrency.intCurrencyID,0)
										 ELSE ISNULL(A.intCurrencyId,compPref.intDefaultCurrencyId) 
									END	
	,[strCostCurrency]			=	CASE WHEN B.ysnSubCurrency > 0 THEN SubCurrency.strCurrency
									ELSE H1.strCurrency
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
	,[intSubLocationId]			=	B.intSubLocationId
	,[strSubLocationName]		=	subLoc.strSubLocationName
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
	,[strReceiptLocation]		=	compLoc.strLocationName
	,[intInventoryShipmentItemId]				=   NULL
	,[intInventoryShipmentChargeId]				=	NULL
	,[intTaxGroupId]							=	B.intTaxGroupId
	,[intFreightTermId]							=	A.intFreightTermId
	,[ysnReturn]								=	CAST((CASE WHEN A.strReceiptType = 'Inventory Return' THEN 1 ELSE 0 END) AS BIT)
	,[strTaxGroup]								=	TG.strTaxGroup
	FROM tblICInventoryReceipt A
	INNER JOIN tblICInventoryReceiptItem B
		ON A.intInventoryReceiptId = B.intInventoryReceiptId
	INNER JOIN tblICItem C ON B.intItemId = C.intItemId
	INNER JOIN tblICItemLocation loc ON C.intItemId = loc.intItemId AND loc.intLocationId = A.intLocationId
	INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON A.[intEntityVendorId] = D1.[intEntityId]
	CROSS APPLY dbo.tblSMCompanyPreference compPref
	LEFT JOIN (tblCTContractHeader CH INNER JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId)  ON CH.intEntityId = A.intEntityVendorId 
																															AND CH.intContractHeaderId = B.intOrderId 
																															AND CD.intContractDetailId = B.intLineNo 
	LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemUOMId = B.intWeightUOMId
	LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = ItemWeightUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM ItemCostUOM ON ItemCostUOM.intItemUOMId = B.intCostUOMId
	LEFT JOIN tblICUnitMeasure CostUOM ON CostUOM.intUnitMeasureId = ItemCostUOM.intUnitMeasureId
	LEFT JOIN tblSMShipVia E ON A.intShipViaId = E.[intEntityId]
	--FOR REVIEW, JOINING FOR CONTRACT IS ALREADY DEFINED ABOVE
	-- LEFT JOIN (tblCTContractHeader F1 INNER JOIN tblCTContractDetail F2 ON F1.intContractHeaderId = F2.intContractHeaderId) 
	-- 	ON F1.intEntityId = A.intEntityVendorId AND B.intItemId = F2.intItemId AND B.intLineNo = ISNULL(F2.intContractDetailId,0)
	LEFT JOIN tblSCTicket G ON (CASE WHEN A.intSourceType = 1 THEN B.intSourceId ELSE 0 END) = G.intTicketId
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = B.intUnitMeasureId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	LEFT JOIN tblSMCurrencyExchangeRate F ON  F.intFromCurrencyId = compPref.intDefaultCurrencyId AND F.intToCurrencyId = A.intCurrencyId
	LEFT JOIN dbo.tblSMCurrencyExchangeRateDetail G1 ON F.intCurrencyExchangeRateId = G1.intCurrencyExchangeRateId AND G1.dtmValidFromDate = (SELECT CONVERT(char(10), GETDATE(),126))
	LEFT JOIN dbo.tblSMCurrency H1 ON H1.intCurrencyID = A.intCurrencyId
	LEFT JOIN dbo.tblEMEntityLocation EL ON EL.intEntityLocationId = A.intShipFromId
	LEFT JOIN dbo.tblSMCurrency SubCurrency ON SubCurrency.intMainCurrencyId = A.intCurrencyId 
	LEFT JOIN dbo.tblICStorageLocation ISL ON ISL.intStorageLocationId = B.intStorageLocationId 
	LEFT JOIN dbo.tblSMCompanyLocation compLoc ON compLoc.intCompanyLocationId = A.intLocationId
	LEFT JOIN dbo.tblSMCompanyLocationSubLocation subLoc ON B.intSubLocationId = subLoc.intCompanyLocationSubLocationId
	LEFT JOIN dbo.tblCTWeightGrade J ON CH.intWeightId = J.intWeightGradeId
	LEFT JOIN dbo.tblSMCurrencyExchangeRateType RT ON RT.intCurrencyExchangeRateTypeId = B.intForexRateTypeId
	LEFT JOIN dbo.tblSMTaxGroup TG ON TG.intTaxGroupId = B.intTaxGroupId
	LEFT JOIN vyuPATEntityPatron patron ON A.intEntityVendorId = patron.intEntityId
	LEFT JOIN tblICItemUOM ctOrderUOM ON ctOrderUOM.intItemUOMId = CD.intItemUOMId
	LEFT JOIN tblICUnitMeasure ctUOM ON ctUOM.intUnitMeasureId  = ctOrderUOM.intUnitMeasureId
	OUTER APPLY dbo.fnGetItemGLAccountAsTable(B.intItemId, loc.intItemLocationId, 'AP Clearing') itemAccnt
	LEFT JOIN dbo.tblGLAccount apClearing ON apClearing.intAccountId = itemAccnt.intAccountId
	OUTER APPLY 
	(
		SELECT SUM(ISNULL(H.dblQtyReceived,0)) AS dblQty FROM (tblAPBillDetail H INNER JOIN tblAPBill H2 ON H.intBillId = H2.intBillId)
		WHERE H.intInventoryReceiptItemId = B.intInventoryReceiptItemId AND H.intInventoryReceiptChargeId IS NULL
		AND H2.ysnPosted = 1 --Billed Qty should be count only for posted
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
						CASE WHEN ISNULL(CH.intContractTypeId,1) = 1 
									AND CD.intPricingTypeId NOT IN (2, 3, 4,5) --AP-4971
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
		,[intInventoryReceiptItemId]				=	ISNULL (J.intInventoryReceiptItemId, (SELECT TOP 1 intInventoryReceiptItemId from tblICInventoryReceiptItem ri where ri.intInventoryReceiptId = A.intInventoryReceiptId))
		,[intInventoryReceiptChargeId]				=	A.intInventoryReceiptChargeId
		,[intContractChargeId]						=	NULL
		,[dblUnitCost]								=	CASE WHEN A.dblOrderQty > 1 -- PER UNIT
														THEN CASE WHEN A.ysnSubCurrency > 0 THEN CAST(A.dblUnitCost AS DECIMAL(38,20)) / ISNULL(A.intSubCurrencyCents,100) ELSE CAST(A.dblUnitCost AS DECIMAL(38,20))  END
														ELSE CAST(A.dblUnitCost AS DECIMAL(38,20)) END
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
		,[intSubCurrencyCents]						=	ISNULL(A.intSubCurrencyCents,1)
		,[intAccountId]								=	apClearing.intAccountId
		,[strAccountId]								=	apClearing.strAccountId
		,[strAccountDesc]							=	apClearing.strDescription
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
		,[dblNetWeight]								=	CAST(0 AS DECIMAL(38,20))
		,[strCostUOM]								=	A.strCostUnitMeasure
		,[strgrossNetUOM]							=	NULL
		,[dblWeightUnitQty]							=	CAST(1 AS DECIMAL(38,20))
		,[dblCostUnitQty]							=	CAST(1 AS DECIMAL(38,20))
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
		,[str1099Form]								=	CASE WHEN patron.intEntityId IS NOT NULL 
															AND item.ysn1099Box3 = 1
															AND patron.ysnStockStatusQualified = 1 
															THEN '1099 PATR'
														ELSE D2.str1099Form	END
		,[str1099Type]								=	CASE WHEN patron.intEntityId IS NOT NULL 
															AND item.ysn1099Box3 = 1
															AND patron.ysnStockStatusQualified = 1 
															THEN 'Per-unit retain allocations'
														ELSE D2.str1099Type END
		,[intSubLocationId]							=	NULL
		,[strSubLocationName]						=	NULL
		,[intStorageLocationId]						=	NULL
		,[strStorageLocationName]					=	NULL
		,[dblNetShippedWeight]						=	0.00
		,[dblWeightLoss]							=	0.00
		,[dblFranchiseWeight]						=	0.00
		,[dblClaimAmount]							=	0.00
		,[intLocationId]							=	A.intLocationId
		,[strReceiptLocation]						= 	compLoc.strLocationName
		,[intInventoryShipmentItemId]				=   NULL
		,[intInventoryShipmentChargeId]				=	NULL
		,[intTaxGroupId]							=	NULL
		,[intFreightTermId]							=	NULL
		,[ysnReturn]								=	CAST((CASE WHEN A.strReceiptType = 'Inventory Return' THEN 1 ELSE 0 END) AS BIT)
		,[strTaxGroup]								=	NULL
	FROM [vyuICChargesForBilling] A
	--LEFT JOIN tblSMCurrencyExchangeRate F ON  (F.intFromCurrencyId = (SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference) AND F.intToCurrencyId = CASE WHEN A.ysnSubCurrency > 0 
	--																																					   THEN (SELECT ISNULL(intMainCurrencyId,0) FROM dbo.tblSMCurrency WHERE intCurrencyID = ISNULL(A.intCurrencyId,0))
	--																																					   ELSE  ISNULL(A.intCurrencyId,0) END) 
	LEFT JOIN dbo.tblSMCurrency H1 ON H1.intCurrencyID = A.intCurrencyId
	LEFT JOIN dbo.tblSMCurrency SubCurrency ON SubCurrency.intMainCurrencyId = A.intCurrencyId 
	LEFT JOIN dbo.tblSMCompanyLocation compLoc ON compLoc.intCompanyLocationId = A.intLocationId
	INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON A.[intEntityVendorId] = D1.[intEntityId]
	LEFT JOIN dbo.tblSMCurrencyExchangeRateType RT ON RT.intCurrencyExchangeRateTypeId = A.intForexRateTypeId
	LEFT JOIN dbo.tblICInventoryReceipt IR ON IR.intInventoryReceiptId = A.intInventoryReceiptId
	LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = A.intItemId 
		 AND ItemLoc.intLocationId = A.intLocationId
	LEFT JOIN tblICItem item ON item.intItemId = A.intItemId
	LEFT JOIN vyuPATEntityPatron patron ON patron.intEntityId = A.intEntityVendorId
	LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = A.intContractHeaderId
	LEFT JOIN tblCTContractDetail CD ON CD.intContractHeaderId = A.intContractHeaderId   
	OUTER APPLY dbo.fnGetItemGLAccountAsTable(A.intItemId, ItemLoc.intItemLocationId, 'AP Clearing') itemAccnt
	LEFT JOIN dbo.tblGLAccount apClearing ON apClearing.intAccountId = itemAccnt.intAccountId   
	OUTER APPLY
	(
		SELECT TOP 1 ysnCheckoffTax FROM tblICInventoryReceiptChargeTax IRCT
		WHERE IRCT.intInventoryReceiptChargeId = A.intInventoryReceiptChargeId
	)  IRCT
	OUTER APPLY 
	(
		SELECT intEntityVendorId,SUM(ISNULL(dblQtyReceived,0)) AS dblQtyReceived FROM tblAPBillDetail BD
		LEFT JOIN dbo.tblAPBill B ON BD.intBillId = B.intBillId
		WHERE BD.intInventoryReceiptChargeId = A.intInventoryReceiptChargeId
		GROUP BY intEntityVendorId, BD.intInventoryReceiptChargeId

	) Billed
	OUTER APPLY
    (
        SELECT TOP 1 intInventoryReceiptItemId FROM [vyuICChargesForBilling] B
        WHERE B.intInventoryReceiptChargeId = A.intInventoryReceiptChargeId
    ) J

	--OUTER APPLY 
	--(
	--	SELECT SUM(ISNULL(H.dblQtyReceived,0)) AS dblQty FROM tblAPBillDetail H 
	--	INNER JOIN dbo.tblAPBill B ON B.intBillId = H.intBillId
	--	WHERE H.intInventoryReceiptChargeId = A.intInventoryReceiptChargeId
	--	GROUP BY H.intInventoryReceiptChargeId
			
	--) Qty
	WHERE  
		(A.[intEntityVendorId] NOT IN (Billed.intEntityVendorId) AND (A.dblOrderQty != ISNULL(Billed.dblQtyReceived,0)) OR Billed.dblQtyReceived IS NULL)
		--CHARGES SHOULD BE ALLOWED TO VOUCHER EVEN IF THE CONTRACT IS BASIS
		--AND 1 =  CASE WHEN CD.intPricingTypeId IS NOT NULL AND CD.intPricingTypeId IN (2) THEN 0 ELSE 1 END  --EXLCUDE ALL BASIS
		AND 1 = CASE WHEN (A.intEntityVendorId = IR.intEntityVendorId 
						AND CD.intPricingTypeId IS NOT NULL AND CD.intPricingTypeId = 5) THEN 0--EXCLUDE DELAYED PRICING TYPE FOR RECEIPT VENDOR
				ELSE 1 END
	UNION ALL

	--ysnAccrue	= 1
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
		,[dblUnitCost]								=	CAST(ISNULL(CASE	WHEN	CC.strCostMethod = 'Percentage' THEN
																		dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,CD.intPriceItemUOMId,CD.dblQuantity) * CD.dblCashPrice * (CC.dblRate / 100) *
																		CASE WHEN CC.intCurrencyId = CD.intCurrencyId THEN 1 ELSE ISNULL(CC.dblFX,1) END
                                                               		WHEN	CC.strCostMethod = 'Per Unit' THEN       
																			
																			ISNULL(CC.dblRate,0)
																ELSE	ISNULL(CC.dblRate,0) 
														END,0) AS DECIMAL(38,20))
		,[dblDiscount]								=	0
		,[dblTax]									=	0
		,[dblRate]									=	ISNULL(rate.forexRate,1)
		,[strRateType]								=	rtype.strDescription
		,[intCurrencyExchangeRateTypeId]			=	CC.intRateTypeId
		,[ysnSubCurrency]							=	ISNULL(CY.ysnSubCurrency,0)
		,[intSubCurrencyCents]						=	CASE WHEN CY.ysnSubCurrency > 0 THEN CY.intCent ELSE 1 END
		,[intAccountId]								=	apClearing.intAccountId
		,[strAccountId]								=	apClearing.strAccountId
		,[strAccountDesc]							=	apClearing.strDescription
		,[strName]									=	CC.strVendorName
		,[strVendorId]								=	LTRIM(CC.intVendorId)
		,[strShipVia]								=	NULL
		,[strTerm]									=	term.strTerm
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
		,[dblNetWeight]								=	CAST(0 AS DECIMAL(38,20))--ISNULL(CD.dblNetWeight,0)      
		,[strCostUOM]								=	CC.strUOM
		,[strgrossNetUOM]							=	CC.strUOM
		,[dblWeightUnitQty]							=	CAST(1  AS DECIMAL(38,20))
		,[dblCostUnitQty]							=	ISNULL(CostUOM.dblUnitQty,1)
		,[dblUnitQty]								=	ISNULL(ItemUOM.dblUnitQty,1)
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
		,[str1099Form]								=	CASE WHEN patron.intEntityId IS NOT NULL 
															AND item.ysn1099Box3 = 1
															AND patron.ysnStockStatusQualified = 1 
															THEN '1099 PATR'
														ELSE D2.str1099Form	END
		,[str1099Type]								=	CASE WHEN patron.intEntityId IS NOT NULL 
															AND item.ysn1099Box3 = 1
															AND patron.ysnStockStatusQualified = 1 
															THEN 'Per-unit retain allocations'
														ELSE D2.str1099Type END
		,[intSubLocationId]							=	CD.intSubLocationId
		,[strSubLocationName]						=	subLoc.strSubLocationName
		,[intStorageLocationId]						=	CD.intStorageLocationId
		,[strStorageLocationName]					=	SLOC.strName
		,[dblNetShippedWeight]						=	0.00
		,[dblWeightLoss]							=	0.00
		,[dblFranchiseWeight]						=	0.00
		,[dblClaimAmount]							=	0.00
		,[intLocationId]							=	NULL --Contract doesn't have location
		,[strReceiptLocation]						=	NULL
		,[intInventoryShipmentItemId]				=   NULL
		,[intInventoryShipmentChargeId]				=	NULL
		,[intTaxGroupId]							=	NULL
		,[intFreightTermId]							=	NULL
		,[ysnReturn]								=	CAST(RT.Item AS BIT)
		,[strTaxGroup]								=	NULL
	FROM		vyuCTContractCostView		CC
	JOIN		tblCTContractDetail			CD	ON	CD.intContractDetailId	=	CC.intContractDetailId
													AND	CC.ysnAccrue		=	1
	JOIN		tblCTContractHeader			CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
	INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON CC.intVendorId = D1.[intEntityId] 
	INNER JOIN	tblICItem item ON item.intItemId = CC.intItemId 
	CROSS APPLY	tblSMCompanyPreference compPref
	LEFT JOIN	tblSMCurrency				CU	ON	CU.intCurrencyID		=	CD.intCurrencyId
	LEFT JOIN	tblICItemLocation		ItemLoc ON	ItemLoc.intItemId		=	CC.intItemId			AND 
													ItemLoc.intLocationId	=	CD.intCompanyLocationId
	LEFT JOIN	tblICInventoryReceiptCharge RC	ON	RC.intContractId		=	CC.intContractHeaderId	AND 
													RC.intChargeId			=	CC.intItemId
	LEFT JOIN	tblICItemUOM			ItemUOM ON	ItemUOM.intItemUOMId	=	CD.intItemUOMId
	LEFT JOIN	tblICItemUOM			CostUOM ON	CostUOM.intItemId		=	CD.intItemId
												AND	CostUOM.intUnitMeasureId	=	CC.intUnitMeasureId		
	LEFT JOIN	tblICUnitMeasure			UOM ON	UOM.intUnitMeasureId	=	ItemUOM.intUnitMeasureId
	LEFT JOIN	tblICStorageLocation	   SLOC ON	SLOC.intStorageLocationId = CD.intStorageLocationId	
	LEFT JOIN	tblSMCompanyLocationSubLocation	   subLoc ON	CD.intSubLocationId = subLoc.intCompanyLocationSubLocationId
	LEFT JOIN	tblSMCurrencyExchangeRate F ON  (F.intFromCurrencyId = compPref.intDefaultCurrencyId AND F.intToCurrencyId = CC.intCurrencyId) 
	LEFT JOIN	tblSMCurrencyExchangeRateDetail G1 ON F.intCurrencyExchangeRateId = G1.intCurrencyExchangeRateId  AND G1.dtmValidFromDate = (SELECT CONVERT(char(10), GETDATE(),126))
	LEFT JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID		=	CC.intCurrencyId
	LEFT JOIN	tblSMCurrencyExchangeRate Rate ON Rate.intFromCurrencyId = compPref.intDefaultCurrencyId AND Rate.intToCurrencyId = CU.intMainCurrencyId
	LEFT JOIN	tblSMCurrencyExchangeRateDetail RateDetail ON Rate.intCurrencyExchangeRateId = RateDetail.intCurrencyExchangeRateId
	LEFT JOIN 	vyuPATEntityPatron patron ON patron.intEntityId = CC.intItemId
	LEFT JOIN	tblSMCurrencyExchangeRateType rtype ON rtype.intCurrencyExchangeRateTypeId = CC.intRateTypeId
	LEFT JOIN	tblSMTerm term ON term.intTermID =  CC.intTermId
	OUTER APPLY dbo.fnGetItemGLAccountAsTable(CC.intItemId, ItemLoc.intItemLocationId, 'Other Charge Expense') itemAccnt
	LEFT JOIN dbo.tblGLAccount apClearing ON apClearing.intAccountId = itemAccnt.intAccountId
	OUTER APPLY (
		SELECT TOP 1 dblRate as forexRate from tblSMCurrencyExchangeRateDetail G1
		WHERE F.intCurrencyExchangeRateId = G1.intCurrencyExchangeRateId AND G1.dtmValidFromDate < (SELECT CONVERT(char(10), GETDATE(),126))
		ORDER BY G1.dtmValidFromDate DESC
	) rate
	CROSS JOIN  dbo.fnSplitString('0,1',',') RT
	WHERE		RC.intInventoryReceiptChargeId IS NULL AND CC.ysnBasis = 0
	AND NOT EXISTS(SELECT 1 FROM tblICInventoryShipmentCharge WHERE intContractDetailId = CD.intContractDetailId AND intChargeId = CC.intItemId)
	UNION ALL

	--ysnPrice = 1
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
		,[dblUnitCost]								=	CAST(ISNULL(CASE	WHEN	CC.strCostMethod = 'Percentage' THEN
																		dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,CD.intPriceItemUOMId,CD.dblQuantity) * CD.dblCashPrice * (CC.dblRate / 100) *
																		CASE WHEN CC.intCurrencyId = CD.intCurrencyId THEN 1 ELSE ISNULL(CC.dblFX,1) END
                                                               		WHEN	CC.strCostMethod = 'Per Unit' THEN       
																			ISNULL(CC.dblRate,0)
																ELSE	ISNULL(CC.dblRate,0) 
														END,0) AS DECIMAL(38,20))
		,[dblDiscount]								=	0
		,[dblTax]									=	0
		,[dblRate]									=	ISNULL(rate.forexRate,1)
		,[strRateType]								=	rtype.strDescription
		,[intCurrencyExchangeRateTypeId]			=	CC.intRateTypeId
		,[ysnSubCurrency]							=	ISNULL(CY.ysnSubCurrency,0)
		,[intSubCurrencyCents]						=	CASE WHEN CY.ysnSubCurrency > 0 THEN CY.intCent ELSE 1 END
		,[intAccountId]								=	apClearing.intAccountId
		,[strAccountId]								=	apClearing.strAccountId
		,[strAccountDesc]							=	apClearing.strDescription
		,[strName]									=	CC.strVendorName
		,[strVendorId]								=	LTRIM(CC.intVendorId)
		,[strShipVia]								=	NULL
		,[strTerm]									=	(SELECT TOP 1 strTerm FROM tblSMTerm WHERE intTermID =  CC.intTermId)
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
		,[dblNetWeight]								=	CAST(0 AS DECIMAL(38,20))--ISNULL(CD.dblNetWeight,0)      
		,[strCostUOM]								=	CC.strUOM
		,[strgrossNetUOM]							=	CC.strUOM
		,[dblWeightUnitQty]							=	CAST(1  AS DECIMAL(38,20))
		,[dblCostUnitQty]							=	ISNULL(CostUOM.dblUnitQty,1)
		,[dblUnitQty]								=	ISNULL(ItemUOM.dblUnitQty,1)
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
		,[str1099Form]								=	CASE WHEN patron.intEntityId IS NOT NULL 
															AND item.ysn1099Box3 = 1
															AND patron.ysnStockStatusQualified = 1 
															THEN '1099 PATR'
														ELSE D2.str1099Form	END
		,[str1099Type]								=	CASE WHEN patron.intEntityId IS NOT NULL 
															AND item.ysn1099Box3 = 1
															AND patron.ysnStockStatusQualified = 1 
															THEN 'Per-unit retain allocations'
														ELSE D2.str1099Type END
		,[intSubLocationId]							=	CD.intSubLocationId
		,[strSubLocationName]						=	subLoc.strSubLocationName
		,[intStorageLocationId]						=	CD.intStorageLocationId
		,[strStorageLocationName]					=	SLOC.strName
		,[dblNetShippedWeight]						=	0.00
		,[dblWeightLoss]							=	0.00
		,[dblFranchiseWeight]						=	0.00
		,[dblClaimAmount]							=	0.00
		,[intLocationId]							=	NULL --Contract doesn't have location
		,[strReceiptLocation]						=	NULL
		,[intInventoryShipmentItemId]				=   NULL
		,[intInventoryShipmentChargeId]				=	NULL
		,[intTaxGroupId]							=	NULL
		,[intFreightTermId]							=	NULL
		,[ysnReturn]								=	CAST(RT.Item AS BIT)
		,[strTaxGroup]								=	NULL
	FROM		vyuCTContractCostView		CC
	JOIN		tblCTContractDetail			CD	ON	CD.intContractDetailId	=	CC.intContractDetailId
												AND	CC.ysnPrice				=	1
												AND CD.intPricingTypeId		IN	(1,6)
	JOIN		tblCTContractHeader			CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
	INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON CC.intVendorId = D1.[intEntityId]  
	INNER JOIN	tblICItem item ON item.intItemId = CC.intItemId 
	LEFT JOIN	tblSMCurrency				CU	ON	CU.intCurrencyID		=	CD.intCurrencyId
	LEFT JOIN	tblICItemLocation		ItemLoc ON	ItemLoc.intItemId		=	CC.intItemId			AND 
													ItemLoc.intLocationId	=	CD.intCompanyLocationId
	LEFT JOIN	tblICInventoryReceiptCharge RC	ON	RC.intContractId		=	CC.intContractHeaderId	AND 
													RC.intChargeId			=	CC.intItemId
	LEFT JOIN	tblICItemUOM			ItemUOM ON	ItemUOM.intItemUOMId	=	CD.intItemUOMId
	LEFT JOIN	tblICItemUOM			CostUOM ON	CostUOM.intItemId		=	CD.intItemId
												AND	CostUOM.intUnitMeasureId	=	CC.intUnitMeasureId		
	LEFT JOIN	tblICUnitMeasure			UOM ON	UOM.intUnitMeasureId	=	ItemUOM.intUnitMeasureId
	LEFT JOIN	tblICStorageLocation	   SLOC ON	SLOC.intStorageLocationId = CD.intStorageLocationId	
	LEFT JOIN	tblSMCompanyLocationSubLocation	   subLoc ON	CD.intSubLocationId = subLoc.intCompanyLocationSubLocationId
	LEFT JOIN	tblSMCurrencyExchangeRate F ON  (F.intFromCurrencyId = (SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference) AND F.intToCurrencyId = CC.intCurrencyId) 
	LEFT JOIN	tblSMCurrencyExchangeRateDetail G1 ON F.intCurrencyExchangeRateId = G1.intCurrencyExchangeRateId AND G1.dtmValidFromDate = (SELECT CONVERT(char(10), GETDATE(),126))
	LEFT JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID		=	CC.intCurrencyId
	LEFT JOIN	tblSMCurrencyExchangeRate Rate ON  (Rate.intFromCurrencyId = (SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference) AND Rate.intToCurrencyId = CU.intMainCurrencyId) 
	LEFT JOIN	tblSMCurrencyExchangeRateDetail RateDetail ON Rate.intCurrencyExchangeRateId = RateDetail.intCurrencyExchangeRateId
	LEFT JOIN 	vyuPATEntityPatron patron ON patron.intEntityId = CC.intItemId
	LEFT JOIN	tblSMCurrencyExchangeRateType rtype ON rtype.intCurrencyExchangeRateTypeId = CC.intRateTypeId
	OUTER APPLY dbo.fnGetItemGLAccountAsTable(CC.intItemId, ItemLoc.intItemLocationId, 'Other Charge Expense') itemAccnt
	LEFT JOIN dbo.tblGLAccount apClearing ON apClearing.intAccountId = itemAccnt.intAccountId
	OUTER APPLY (
		SELECT TOP 1 dblRate as forexRate from tblSMCurrencyExchangeRateDetail G1
		WHERE F.intCurrencyExchangeRateId = G1.intCurrencyExchangeRateId AND G1.dtmValidFromDate < (SELECT CONVERT(char(10), GETDATE(),126))
		ORDER BY G1.dtmValidFromDate DESC
	) rate
	CROSS JOIN  dbo.fnSplitString('0,1',',') RT
	WHERE		RC.intInventoryReceiptChargeId IS NULL AND CC.ysnBasis = 0

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
		,[dblUnitCost]								=	CAST(ISNULL(A.dblCashPrice,0) AS DECIMAL(38,20))
		,[dblDiscount]								=	0
		,[dblTax]									=	0
		,[dblRate]									=	1
		,[strRateType]								=	NULL
		,[intCurrencyExchangeRateTypeId]			=	NULL
		,[ysnSubCurrency]							=	CASE WHEN ISNULL(A.intSubCurrencyCents,0) > 0 THEN 1 ELSE 0 END --A.ysnSubCurrency
		,[intSubCurrencyCents]						=	ISNULL(A.intSubCurrencyCents,0)
		,[intAccountId]								=	apClearing.intAccountId
		,[strAccountId]								=	apClearing.strAccountId
		,[strAccountDesc]							=	apClearing.strDescription
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
		,[dblCostUnitQty]							=	CAST(ISNULL(ItemCostUOM.dblUnitQty,1) AS DECIMAL(38,20))
		,[dblUnitQty]								=	ISNULL(ItemUOM.dblUnitQty,1)
		,[intCurrencyId]							=	A.intCurrencyId
		,[strCurrency]								=	A.strLoadCurrency
		,[intCostCurrencyId]						=	A.intContractCurrencyId
		,[strCostCurrency]							=	A.strCurrency
		,[strVendorLocation]						=	NULL
		,[str1099Form]								=	CASE WHEN patron.intEntityId IS NOT NULL 
															AND item.ysn1099Box3 = 1
															AND patron.ysnStockStatusQualified = 1 
															THEN '1099 PATR'
														ELSE D2.str1099Form	END
		,[str1099Type]								=	CASE WHEN patron.intEntityId IS NOT NULL 
															AND item.ysn1099Box3 = 1
															AND patron.ysnStockStatusQualified = 1 
															THEN 'Per-unit retain allocations'
														ELSE D2.str1099Type END
		,[intSubLocationId]							=	NULL
		,[strSubLocationName]						=	NULL
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
		,[intFreightTermId]							=	NULL
		,[ysnReturn]								=	CAST(0 AS BIT)
		,[strTaxGroup]								=	NULL
	FROM vyuLGLoadPurchaseContracts A
	INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON A.intVendorEntityId = D1.[intEntityId]  
	LEFT JOIN	tblICItem item ON item.intItemId = A.intItemId 
	LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = A.intItemId and ItemLoc.intLocationId = A.intCompanyLocationId
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = A.intItemUOMId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemUOMId = A.intWeightItemUOMId
	LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = ItemWeightUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM ItemCostUOM ON ItemCostUOM.intItemUOMId = A.intCostUOMId
	LEFT JOIN tblICUnitMeasure CostUOM ON CostUOM.intUnitMeasureId = ItemCostUOM.intUnitMeasureId
	LEFT JOIN vyuPATEntityPatron patron ON patron.intEntityId = A.intItemId
	OUTER APPLY dbo.fnGetItemGLAccountAsTable(A.intItemId, ItemLoc.intItemLocationId, 'AP Clearing') itemAccnt
	LEFT JOIN dbo.tblGLAccount apClearing ON apClearing.intAccountId = itemAccnt.intAccountId
	WHERE A.intLoadDetailId NOT IN 
		(SELECT IsNull(BD.intLoadDetailId, 0) 
			FROM tblAPBillDetail BD 
		JOIN tblICItem Item ON Item.intItemId = BD.intItemId
		WHERE BD.intItemId = A.intItemId AND Item.strType <> 'Other Charge') AND A.dtmPostedDate IS NOT NULL 
	
	UNION ALL
	-- OTHER CHARGES ACCRUAL
	SELECT
		[intEntityVendorId]							=	A.intEntityVendorId
		,[dtmDate]									=	L.dtmPostedDate
		,[strReference]								=	''
		,[strSourceNumber]							=	LTRIM(A.strLoadNumber)
		,[strPurchaseOrderNumber]					=	NULL
		,[intPurchaseDetailId]						=	NULL
		,[intItemId]								=	A.intItemId
		,[strMiscDescription]						=	A.strItemDescription
		,[strItemNo]								=	A.strItemNo
		,[strDescription]							=	A.strItemDescription
		,[intPurchaseTaxGroupId]					=	NULL
		,[dblOrderQty]								=	1--LD.dblQuantity
		,[dblPOOpenReceive]							=	0
		,[dblOpenReceive]							=	1--LD.dblQuantity
		,[dblQuantityToBill]						=	1--LD.dblQuantity
		,[dblQuantityBilled]						=	0
		,[intLineNo]								=	A.intLoadDetailId
		,[intInventoryReceiptItemId]				=	NULL
		,[intInventoryReceiptChargeId]				=	NULL
		,[intContractChargeId]						=	NULL
		,[dblUnitCost]								=	ISNULL(A.dblPrice,0)
		,[dblDiscount]								=	0
		,[dblTax]									=	0
		,[dblRate]									=	1
		,[strRateType]								=	NULL
		,[intCurrencyExchangeRateTypeId]			=	NULL
		,[ysnSubCurrency]							=	CASE WHEN ISNULL((CASE WHEN C.ysnSubCurrency > 0 THEN C.intCent ELSE 1 END),0) > 0 THEN 1 ELSE 0 END --A.ysnSubCurrency
		,[intSubCurrencyCents]						=	ISNULL((CASE WHEN C.ysnSubCurrency > 0 THEN C.intCent ELSE 1 END),0)
		,[intAccountId]								=	apClearing.intAccountId
		,[strAccountId]								=	apClearing.strAccountId
		,[strAccountDesc]							=	apClearing.strDescription
		,[strName]									=	A.strCustomerName
		,[strVendorId]								=	LTRIM(D1.strVendorId)
		,[strShipVia]								=	NULL
		,[strTerm]									=	NULL
		,[intTermId]								=	NULL
		,[strContractNumber]						=	CAST(A.strContractNumber AS NVARCHAR(100))
		,[strBillOfLading]							=	L.strBLNumber
		,[intContractHeaderId]						=	NULL -- A.intContractHeaderId
		,[intContractDetailId]						=	NULL -- A.intPContractDetailId
		,[intContractSequence]						=	A.intContractSeq
		,[intScaleTicketId]							=	NULL
		,[strScaleTicketNumber]						=	CAST(NULL AS NVARCHAR(50))
		,[intShipmentId]							=	A.intLoadId
		,[intShipmentContractQtyId]					=	A.intLoadDetailId
		,[intUnitMeasureId]							=	A.intItemUOMId
		,[strUOM]									=	UOM.strUnitMeasure
		,[intWeightUOMId]							=	A.intWeightItemUOMId
		,[intCostUOMId]								=	A.intPriceItemUOMId
		,[dblNetWeight]								=	ISNULL(1,0)      
		,[strCostUOM]								=	A.strPriceUOM
		,[strgrossNetUOM]							=	NULL
		--,[dblUnitQty]								=	dbo.fnLGGetItemUnitConversion (A.intItemId, A.intPriceItemUOMId, A.intWeightUOMId)
		,[dblWeightUnitQty]							=	ISNULL(ItemWeightUOM.dblUnitQty,1)
		,[dblCostUnitQty]							=	ISNULL(ItemCostUOM.dblUnitQty,1)
		,[dblUnitQty]								=	ISNULL(ItemUOM.dblUnitQty,1)
		,[intCurrencyId]							=	A.intCurrencyId
		,[strCurrency]								=	C.strCurrency
		,[intCostCurrencyId]						=	A.intCurrencyId
		,[strCostCurrency]							=	A.strCurrency
		,[strVendorLocation]						=	NULL
		,[str1099Form]								=	D2.str1099Form			 
		,[str1099Type]								=	D2.str1099Type 
		,[intSubLocationId]							=	NULL
		,[strSubLocationName]						=	NULL
		,[intStorageLocationId]						=	NULL
		,[strStorageLocationName]					=	NULL
		,[dblNetShippedWeight]						=	0.00
		,[dblWeightLoss]							=	0.00
		,[dblFranchiseWeight]						=	0.00
		,[dblClaimAmount]							=	0.00
		,[intLocationId]							=	A.intCompanyLocationId
		,[strReceiptLocation]						=	(SELECT strLocationName FROM dbo.tblSMCompanyLocation CL WHERE CL.intCompanyLocationId = A.intCompanyLocationId)
		,[intInventoryShipmentItemId]				=   NULL
		,[intInventoryShipmentChargeId]				=	NULL
		,[intTaxGroupId]							=	NULL
		,[intFreightTermId]							=	NULL
		,[ysnReturn]								=	CAST(0 AS BIT)
		,[strTaxGroup]								=	NULL
	FROM vyuLGLoadCostForVendor A
	JOIN tblLGLoad L ON L.intLoadId = A.intLoadId
	JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
	JOIN tblSMCurrency C ON C.intCurrencyID = L.intCurrencyId
	LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = A.intItemId and ItemLoc.intLocationId = A.intCompanyLocationId
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = A.intItemUOMId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemUOMId = A.intWeightItemUOMId
	LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = ItemWeightUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM ItemCostUOM ON ItemCostUOM.intItemUOMId = A.intPriceItemUOMId
	LEFT JOIN tblICUnitMeasure CostUOM ON CostUOM.intUnitMeasureId = ItemCostUOM.intUnitMeasureId
	INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON A.[intEntityVendorId] = D1.[intEntityId]
	OUTER APPLY dbo.fnGetItemGLAccountAsTable(A.intItemId, ItemLoc.intItemLocationId, 'AP Clearing') itemAccnt
	LEFT JOIN dbo.tblGLAccount apClearing ON apClearing.intAccountId = itemAccnt.intAccountId
	WHERE A.intLoadDetailId NOT IN 
		(SELECT IsNull(BD.intLoadDetailId, 0) 
			FROM tblAPBillDetail BD 
		JOIN tblICItem Item ON Item.intItemId = BD.intItemId
		WHERE BD.intItemId = A.intItemId AND Item.strType = 'Other Charge' AND ISNULL(A.ysnAccrue,0) = 1) AND ISNULL(L.ysnPosted,0) = 1
   
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
		,[intShipmentId]							=	0--ISNULL(A.intInventoryShipmentItemId,0)
		,[intShipmentContractQtyId]					=	NULL
  		,[intUnitMeasureId]							=	A.intCostUnitMeasureId
		,[strUOM]									=	A.strCostUnitMeasure
		,[intWeightUOMId]							=	NULL
		,[intCostUOMId]								=	A.intCostUnitMeasureId
		,[dblNetWeight]								=	0      
		,[strCostUOM]								=	A.strCostUnitMeasure
		,[strgrossNetUOM]							=	NULL
		,[dblWeightUnitQty]							=	1
		,[dblCostUnitQty]							=	CAST(1 AS DECIMAL(38,20))
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
		,[str1099Form]								=	CASE WHEN patron.intEntityId IS NOT NULL 
															AND I.ysn1099Box3 = 1
															AND patron.ysnStockStatusQualified = 1 
															THEN '1099 PATR'
														ELSE D2.str1099Form	END
		,[str1099Type]								=	CASE WHEN patron.intEntityId IS NOT NULL 
															AND I.ysn1099Box3 = 1
															AND patron.ysnStockStatusQualified = 1 
															THEN 'Per-unit retain allocations'
														ELSE D2.str1099Type END
		,[intSubLocationId]							=	NULL
		,[strSubLocationName]						=	NULL
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
		,[intFreightTermId]							=	NULL
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
	LEFT JOIN	tblICItemLocation		ItemLoc ON	ItemLoc.intItemId		=	A.intItemId			AND 
													ItemLoc.intLocationId	=	A.intLocationId
	LEFT JOIN dbo.tblEMEntityLocation EL ON A.intEntityVendorId = EL.intEntityId AND D1.intShipFromId = EL.intEntityLocationId
	LEFT JOIN dbo.tblAPVendorSpecialTax VST ON VST.intEntityVendorId = A.intEntityVendorId
	LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = (SELECT TOP 1 intCompanyLocationId  FROM tblSMUserRoleCompanyLocationPermission)
	LEFT JOIN tblICCategoryTax B ON I.intCategoryId = B.intCategoryId
	LEFT JOIN tblSMTaxClass C ON B.intTaxClassId = C.intTaxClassId 
	LEFT JOIN tblSMTaxCode D ON D.intTaxClassId = C.intTaxClassId 
	LEFT JOIN dbo.tblSMCurrencyExchangeRateType RT ON RT.intCurrencyExchangeRateTypeId = A.intForexRateTypeId
	LEFT JOIN vyuPATEntityPatron patron ON patron.intEntityId = A.intItemId
	OUTER APPLY fnGetItemTaxComputationForVendor(A.intItemId, A.intEntityVendorId, A.dtmDate, A.dblUnitCost, 1, (CASE WHEN VST.intTaxGroupId > 0 THEN VST.intTaxGroupId
																													  WHEN CL.intTaxGroupId  > 0 THEN CL.intTaxGroupId 
																													  WHEN EL.intTaxGroupId > 0  THEN EL.intTaxGroupId ELSE 0 END), CL.intCompanyLocationId, D1.intShipFromId , 0, 0, NULL, 0, NULL, NULL, NULL, NULL) Taxes
	-- OUTER APPLY 
	-- (
	-- 	SELECT intEntityVendorId FROM tblAPBillDetail BD
	-- 	LEFT JOIN dbo.tblAPBill B ON BD.intBillId = B.intBillId
	-- 	WHERE BD.intInventoryShipmentChargeId = A.intInventoryShipmentChargeId

	-- ) Billed
	-- The exclusion of data is not working in this sub query
	-- Excluding of data when there is a voucher is already part of the vyuICShipmentChargesForBilling
	OUTER APPLY 
	(
		SELECT SUM(ISNULL(H.dblQtyReceived,0)) AS dblQty FROM tblAPBillDetail H 
		INNER JOIN dbo.tblAPBill B ON B.intBillId = H.intBillId
		WHERE H.intInventoryShipmentChargeId = A.intInventoryShipmentChargeId
		GROUP BY H.intInventoryShipmentChargeId
			
	) Qty
	WHERE (A.dblOrderQty != 0)

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
	  ,[dblUnitCost]							= CAST(I.dblInvoiceTotal AS DECIMAL(38,20))
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
	  ,[dblCostUnitQty]							= CAST(1 AS DECIMAL(38,20))
	  ,[dblUnitQty]								= NULL
	  ,[intCurrencyId]							= I.intCurrencyId
	  ,[strCurrency]							= CY.strCurrency
	  ,[intCostCurrencyId]						= NULL
	  ,[strCostCurrency]						= NULL
	  ,[strVendorLocation]						= NULL
	  ,[str1099Form]							= NULL		 
	  ,[str1099Type]							= NULL
	  ,[intSubLocationId]						= NULL	
	  ,[strSubLocationName]						= NULL
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
	  ,[intFreightTermId]						= NULL
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
