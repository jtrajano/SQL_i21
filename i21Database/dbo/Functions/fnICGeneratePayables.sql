CREATE FUNCTION dbo.fnICGeneratePayables (@intReceiptId INT, @ysnPosted BIT)
RETURNS @table TABLE
(
  [intEntityVendorId]			    INT NULL 
, [intTransactionType]				INT NULL
, [dtmDate]							DATETIME NULL
, [strReference]					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL 
, [strSourceNumber]					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL 
, [strVendorOrderNumber]			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
, [strPurchaseOrderNumber]			NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL 
, [intPurchaseDetailId]				INT NULL 
, [intItemId]						INT NULL 
, [strMiscDescription]				NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL 
, [strItemNo]						NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL 
, [strDescription]					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL 
, [intPurchaseTaxGroupId]			INT NULL 
, [dblOrderQty]						NUMERIC(38, 20) NULL 
, [dblPOOpenReceive]				NUMERIC(38, 20) NULL 
, [dblOpenReceive]					NUMERIC(38, 20) NULL 
, [dblQuantityToBill]				NUMERIC(38, 20) NULL 				
, [dblQtyToBillUnitQty]				NUMERIC(38, 20) NULL 
, [intQtyToBillUOMId]				INT NULL
, [dblQuantityBilled]				NUMERIC(38, 20) NULL 
, [intLineNo]						INT NULL 
, [intInventoryReceiptItemId]		INT NULL 
, [intInventoryReceiptChargeId]		INT NULL 
, [intContractChargeId]				INT NULL 
, [dblUnitCost]						NUMERIC(38, 20) NULL 
, [dblDiscount]						NUMERIC(38, 20) NULL 
, [dblTax]							NUMERIC(38, 20) NULL 
, [dblRate]							NUMERIC(38, 20) NULL 
, [strRateType]						NVARCHAR(200) COLLATE Latin1_General_CI_AS
, [intCurrencyExchangeRateTypeId]	INT NULL 
, [ysnSubCurrency]					BIT NULL 
, [intSubCurrencyCents]				INT NULL 
, [intAccountId]					INT NULL 
, [strAccountId]					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL 
, [strAccountDesc]					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL 
, [strName]							NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL 
, [strVendorId]						NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL 
, [strShipVia]						NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL 
, [strTerm]							NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL 
, [intTermId]						INT NULL 
, [strContractNumber]				NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL 
, [strBillOfLading]					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL 
, [intContractHeaderId]				INT NULL 
, [intContractDetailId]				INT NULL 
, [intContractSequence]				INT NULL 
, [intScaleTicketId]				INT NULL 
, [strScaleTicketNumber]			NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL 
, [intShipmentId]					INT NULL 
, [intLoadDetailId]					INT NULL 
, [intUnitMeasureId]				INT NULL 
, [strUOM]							NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL 
, [intWeightUOMId]					INT NULL 
, [intCostUOMId]					INT NULL 
, [dblNetWeight]					NUMERIC(38, 20) NULL 	
, [strCostUOM]						NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL 
, [strgrossNetUOM]					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL 
, [dblWeightUnitQty]				NUMERIC(38, 20) NULL 
, [dblCostUnitQty]					NUMERIC(38, 20) NULL 
, [dblUnitQty]						NUMERIC(38, 20) NULL 
, [intCurrencyId]					INT NULL 
, [strCurrency]						NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL 
, [intCostCurrencyId]				INT NULL 				
, [strCostCurrency]					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL 		
, [strVendorLocation]				NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL 
, [str1099Form]						NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL 			
, [str1099Type]						NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL 				
, [intSubLocationId]				INT NULL 
, [strSubLocationName]				NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL 
, [intStorageLocationId]			INT NULL 
, [strStorageLocationName]			NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL 
, [dblNetShippedWeight]				NUMERIC(38, 20) NULL 
, [dblWeightLoss]					NUMERIC(38, 20) NULL 
, [dblFranchiseWeight]				NUMERIC(38, 20) NULL 
, [dblClaimAmount]					NUMERIC(38, 20) NULL 			
, [intLocationId]					INT NULL 
, [strReceiptLocation]				NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL 
, [intInventoryShipmentItemId]		INT NULL 
, [intInventoryShipmentChargeId]	INT NULL 
, [intTaxGroupId]					INT NULL 
, [ysnReturn]						BIT NULL 
, [strTaxGroup]						NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL 
, intShipViaId						INT NULL
)
AS
BEGIN

INSERT INTO @table
SELECT DISTINCT
	[intEntityVendorId]			=	A.intEntityVendorId
	,[intTransactionType]		=	CASE WHEN A.strReceiptType = 'Inventory Return' THEN 3 ELSE 1 END 
	,[dtmDate]					=	A.dtmReceiptDate
	,[strReference]				=	A.strVendorRefNo
	,[strSourceNumber]			=	A.strReceiptNumber
	,[strVendorOrderNumber]		=	A.strBillOfLading
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
	,[dblQtyToBillUnitQty]		=	ISNULL(ItemUOM.dblUnitQty, 1)
	,[intQtyToBillUOMId]		=	B.intUnitMeasureId
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
	,[strScaleTicketNumber]		=	CAST(G.strTicketNumber AS NVARCHAR(200))
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
	,[strReceiptLocation]		= (SELECT strLocationName FROM dbo.tblSMCompanyLocation WHERE intCompanyLocationId = A.intLocationId)
	,[intInventoryShipmentItemId]				=   NULL
	,[intInventoryShipmentChargeId]				=	NULL
	,[intTaxGroupId]							=	B.intTaxGroupId
	,[ysnReturn]								=	CAST((CASE WHEN A.strReceiptType = 'Inventory Return' THEN 1 ELSE 0 END) AS BIT)
	,[strTaxGroup]								=	TG.strTaxGroup
	,intShipViaId                                = E.intEntityId
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
	LEFT JOIN dbo.tblSMCompanyLocationSubLocation subLoc ON B.intSubLocationId = subLoc.intCompanyLocationSubLocationId
	LEFT JOIN dbo.tblCTWeightGrade J ON CH.intWeightId = J.intWeightGradeId
	LEFT JOIN dbo.tblSMCurrencyExchangeRateType RT ON RT.intCurrencyExchangeRateTypeId = B.intForexRateTypeId
	LEFT JOIN dbo.tblSMTaxGroup TG ON TG.intTaxGroupId = B.intTaxGroupId
	LEFT JOIN vyuPATEntityPatron patron ON A.intEntityVendorId = patron.intEntityId
	LEFT JOIN tblICItemUOM ctOrderUOM ON ctOrderUOM.intItemUOMId = CD.intItemUOMId
	LEFT JOIN tblICUnitMeasure ctUOM ON ctUOM.intUnitMeasureId  = ctOrderUOM.intUnitMeasureId
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
	WHERE A.strReceiptType IN ('Direct','Purchase Contract','Inventory Return','Purchase Order') AND A.ysnPosted = @ysnPosted AND B.dblBillQty != B.dblOpenReceive 
	AND 1 = (CASE WHEN A.strReceiptType = 'Purchase Contract' THEN
						CASE WHEN ISNULL(F1.intContractTypeId,1) = 1 
									AND F2.intPricingTypeId NOT IN (2, 3, 4,5) --AP-4971
							THEN 1 ELSE 0 END
					ELSE 1 END)
	AND B.dblOpenReceive > 0 --EXCLUDE NEGATIVE
	AND ((Billed.dblQty < B.dblOpenReceive) OR Billed.dblQty IS NULL)
	AND (CD.dblCashPrice != 0 OR CD.dblCashPrice IS NULL) --EXCLUDE ALL THE BASIS CONTRACT WITH 0 CASH PRICE
	AND B.dblUnitCost != 0 --EXCLUDE ZERO RECEIPT COST 
	AND ISNULL(A.ysnOrigin, 0) = 0
	AND B.intOwnershipType != 2
	AND A.intInventoryReceiptId = @intReceiptId
	
	UNION ALL

	--RECEIPT OTHER CHARGES
	SELECT DISTINCT
		[intEntityVendorId]							=	A.intEntityVendorId
		,[intTransactionType]						=	CASE WHEN A.strReceiptType = 'Inventory Return' THEN 3 ELSE 1 END 
		,[dtmDate]									=	A.dtmDate
		,[strReference]								=	A.strReference
		,[strSourceNumber]							=	A.strSourceNumber
		,[strVendorOrderNumber]						=	IR.strBillOfLading
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
		,[dblQtyToBillUnitQty]						=	1
		,[intQtyToBillUOMId]						=	NULL
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
		,[strReceiptLocation]						= (SELECT strLocationName FROM dbo.tblSMCompanyLocation WHERE intCompanyLocationId = A.intLocationId)
		,[intInventoryShipmentItemId]				=   NULL
		,[intInventoryShipmentChargeId]				=	NULL
		,[intTaxGroupId]							=	A.intTaxGroupId
		,[ysnReturn]								=	CAST((CASE WHEN A.strReceiptType = 'Inventory Return' THEN 1 ELSE 0 END) AS BIT)
		,[strTaxGroup]								=	TG.strTaxGroup
		,intShipViaId								=   NULL
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
	LEFT JOIN tblICItem item ON item.intItemId = A.intItemId
	LEFT JOIN vyuPATEntityPatron patron ON patron.intEntityId = A.intEntityVendorId
	LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = A.intContractHeaderId
	LEFT JOIN tblCTContractDetail CD ON CD.intContractHeaderId = A.intContractHeaderId      
	LEFT JOIN tblSMTaxGroup TG ON TG.intTaxGroupId = A.intTaxGroupId
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
	WHERE A.intInventoryReceiptId = @intReceiptId AND (
		(A.[intEntityVendorId] NOT IN (Billed.intEntityVendorId) AND (A.dblOrderQty != ISNULL(Billed.dblQtyReceived,0)) OR Billed.dblQtyReceived IS NULL)
		AND 1 =  CASE WHEN CD.intPricingTypeId IS NOT NULL AND CD.intPricingTypeId IN (2) THEN 0 ELSE 1 END  --EXLCUDE ALL BASIS
		AND 1 = CASE WHEN (A.intEntityVendorId = IR.intEntityVendorId 
						AND CD.intPricingTypeId IS NOT NULL AND CD.intPricingTypeId = 5) THEN 0--EXCLUDE DELAYED PRICING TYPE FOR RECEIPT VENDOR
				ELSE 1 END
	    )
RETURN
END