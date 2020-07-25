CREATE FUNCTION dbo.fnICGeneratePayables (
	@intReceiptId INT
	, @ysnPosted BIT
	, @ysnForVoucher BIT = 0
)
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
	, [intContractCostId]				INT NULL 
	, [intScaleTicketId]				INT NULL 
	, [strScaleTicketNumber]			NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL 
	, [strLoadShipmentNumber]			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL 
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
	, intShipFromId						INT NULL
	, intShipFromEntityId				INT NULL
	, intPayToAddressId					INT NULL
	, [intLoadShipmentId]				INT NULL	
	, [intLoadShipmentDetailId]			INT NULL	
	, [intLoadShipmentCostId]			INT NULL	
)
AS
BEGIN


DECLARE @SourceType_STORE AS INT = 7		 
	, @type_Voucher AS INT = 1
	, @type_DebitMemo AS INT = 3
	, @billTypeToUse INT
	, @intVoucherInvoiceNoOption TINYINT
	,	@voucherInvoiceOption_Blank TINYINT = 1 
	,	@voucherInvoiceOption_BOL TINYINT = 2
	,	@voucherInvoiceOption_VendorRefNo TINYINT = 3
	, @intDebitMemoInvoiceNoOption TINYINT
	,	@debitMemoInvoiceOption_Blank TINYINT = 1
	,	@debitMemoInvoiceOption_BOL TINYINT = 2
	,	@debitMemoInvoiceOption_VendorRefNo TINYINT = 3

SELECT TOP 1 @billTypeToUse = 
		CASE 
			WHEN dbo.fnICGetReceiptTotals(r.intInventoryReceiptId, 6) < 0 AND r.intSourceType = @SourceType_STORE THEN 
				@type_DebitMemo
			ELSE 
				@type_Voucher
		END 
FROM tblICInventoryReceipt r
	INNER JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId
WHERE r.ysnPosted = 1
	AND r.intInventoryReceiptId = @intReceiptId

SELECT TOP 1 
	@intVoucherInvoiceNoOption = intVoucherInvoiceNoOption
	,@intDebitMemoInvoiceNoOption = intDebitMemoInvoiceNoOption
FROM tblAPCompanyPreference

INSERT INTO @table
SELECT DISTINCT
	[intEntityVendorId]			=	A.intEntityVendorId
	,[intTransactionType]		=	CASE WHEN A.strReceiptType = 'Inventory Return' THEN 3 ELSE ISNULL(@billTypeToUse, 1)	 END 
	,[dtmDate]					=	A.dtmReceiptDate
	,[strReference]				=	A.strVendorRefNo
	,[strSourceNumber]			=	A.strReceiptNumber
	,[strVendorOrderNumber]		=	
				CASE 
					WHEN A.strReceiptType = 'Inventory Return' THEN 
						CASE 
							WHEN @intDebitMemoInvoiceNoOption = @debitMemoInvoiceOption_Blank THEN NULL 
							WHEN @intDebitMemoInvoiceNoOption = @debitMemoInvoiceOption_BOL THEN A.strBillOfLading 
							WHEN @intDebitMemoInvoiceNoOption = @debitMemoInvoiceOption_VendorRefNo THEN A.strVendorRefNo 
							ELSE  ISNULL(NULLIF(LTRIM(RTRIM(A.strBillOfLading)), ''), A.strVendorRefNo)
						END 
					ELSE
						CASE 
							WHEN @intVoucherInvoiceNoOption = @voucherInvoiceOption_Blank THEN NULL 
							WHEN @intVoucherInvoiceNoOption = @voucherInvoiceOption_BOL THEN A.strBillOfLading 
							WHEN @intVoucherInvoiceNoOption = @voucherInvoiceOption_VendorRefNo THEN A.strVendorRefNo 
							ELSE  ISNULL(NULLIF(LTRIM(RTRIM(A.strBillOfLading)), ''), A.strVendorRefNo)
						END 						
				END 
	,[strPurchaseOrderNumber]	=	PurchaseOrder.strPurchaseOrderNumber
	,[intPurchaseDetailId]		=	PurchaseOrder.intPurchaseDetailId
	,[intItemId]				=	B.intItemId
	,[strMiscDescription]		=	CASE WHEN A.strReceiptType IN ('Purchase Order') THEN PurchaseOrder.strDescription ELSE C.strDescription END
	,[strItemNo]				=	C.strItemNo
	,[strDescription]			=	C.strDescription
	,[intPurchaseTaxGroupId]	=	B.intTaxGroupId
	,[dblOrderQty]				=	
		--CASE WHEN Contracts.intContractDetailId > 0 THEN ROUND(Contracts.dblQuantity,2) ELSE B.dblOpenReceive END
		CASE 
			WHEN @billTypeToUse = @type_DebitMemo THEN 
				-CASE WHEN Contracts.intContractDetailId > 0 THEN ROUND(Contracts.dblQuantity,2) ELSE B.dblOpenReceive END
			ELSE 
				CASE WHEN Contracts.intContractDetailId > 0 THEN ROUND(Contracts.dblQuantity,2) ELSE B.dblOpenReceive END
		END 

	,[dblPOOpenReceive]			=	B.dblReceived
	,[dblOpenReceive]			=	
		--B.dblOpenReceive 
		CASE 
			WHEN @billTypeToUse = @type_DebitMemo THEN -B.dblOpenReceive 
			ELSE B.dblOpenReceive 
		END 
	,[dblQuantityToBill]		=	
		-- B.dblOpenReceive - ISNULL(B.dblBillQty, 0) 
		CASE 
			WHEN @billTypeToUse = @type_DebitMemo THEN -(B.dblOpenReceive - ISNULL(B.dblBillQty, 0) )
			ELSE B.dblOpenReceive - ISNULL(B.dblBillQty, 0) 
		END 
	,[dblQtyToBillUnitQty]		=	ISNULL(ItemUOM.dblUnitQty, 1)
	,[intQtyToBillUOMId]		=	B.intUnitMeasureId
	,[dblQuantityBilled]		=	
		--B.dblBillQty
		CASE 
			WHEN @billTypeToUse = @type_DebitMemo THEN -B.dblBillQty
			ELSE B.dblBillQty
		END 
	,[intLineNo]				=	B.intInventoryReceiptItemId
	,[intInventoryReceiptItemId]=	B.intInventoryReceiptItemId
	,[intInventoryReceiptChargeId]	= NULL
	,[intContractChargeId]		=	NULL
	,[dblUnitCost]				=	CAST(CASE WHEN (B.dblUnitCost IS NULL OR B.dblUnitCost = 0)
												 THEN (CASE WHEN Contracts.dblCashPrice IS NOT NULL THEN Contracts.dblCashPrice ELSE B.dblUnitCost END)
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
	,[strContractNumber]		=	Contracts.strContractNumber
	,[strBillOfLading]			=	A.strBillOfLading
	,[intContractHeaderId]		=	Contracts.intContractHeaderId
	,[intContractDetailId]		=	CASE WHEN A.strReceiptType IN ('Purchase Contract', 'Inventory Return') THEN Contracts.intContractDetailId ELSE NULL END
	,[intContractSequence]		=	CASE WHEN A.strReceiptType IN ('Purchase Contract', 'Inventory Return') THEN Contracts.intContractSeq ELSE NULL END
	,[intContractCostId]		= 	NULL
	,[intScaleTicketId]			=	ScaleTicket.intTicketId
	,[strScaleTicketNumber]		=	CAST(ScaleTicket.strTicketNumber AS NVARCHAR(200))
	,[strLoadShipmentNumber]	=   COALESCE(LogisticsView2.strLoadNumber, LogisticsView.strLoadNumber, '')
	,[intShipmentId]			=	0
	,[intLoadDetailId]			=	B.intSourceId 
  	,[intUnitMeasureId]			=	CASE WHEN Contracts.intContractDetailId > 0 THEN Contracts.intItemUOMId ELSE B.intUnitMeasureId END 
	,[strUOM]					=	CASE WHEN Contracts.intContractDetailId > 0 THEN Contracts.strUnitMeasure ELSE UOM.strUnitMeasure END
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
	,[dblNetShippedWeight]		=	ISNULL(CASE WHEN A.strReceiptType = 'Purchase Contract' AND A.intSourceType = 2 THEN LogisticsView.dblNetWt ELSE B.dblGross END,0)
	,[dblWeightLoss]			=	CASE WHEN A.strReceiptType = 'Purchase Contract' AND A.intSourceType = 2 THEN ISNULL(ISNULL(LogisticsView.dblNetWt,0) - B.dblNet,0) ELSE 0 END
	,[dblFranchiseWeight]		=	CASE WHEN Contracts.dblFranchise > 0 THEN ISNULL(B.dblGross,0) * (Contracts.dblFranchise / 100) ELSE 0 END
	,[dblClaimAmount]			=	CASE WHEN A.strReceiptType = 'Purchase Contract' AND A.intSourceType = 2 THEN
										(CASE WHEN (ISNULL(ISNULL(LogisticsView.dblNetWt,0) - B.dblNet,0) > 0) THEN 
										(
											(ISNULL(B.dblGross - B.dblNet,0) - (CASE WHEN Contracts.dblFranchise > 0 THEN ISNULL(B.dblGross,0) * (Contracts.dblFranchise / 100) ELSE 0 END)) * 
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
	,[ysnReturn]								=	
		CAST(
			CASE 
				WHEN A.strReceiptType = 'Inventory Return' OR @billTypeToUse = @type_DebitMemo THEN 1 
				ELSE 0 
			END
		AS BIT)
	,[strTaxGroup]								=	TG.strTaxGroup
	,intShipViaId                               =	E.intEntityId
	,intShipFromId = A.intShipFromId
	,intShipFromEntityId = A.intShipFromEntityId 
	,intPaytoAddressId				 = payToAddress.intEntityLocationId
	,[intLoadShipmentId]			 = B.intLoadShipmentId
	,[intLoadShipmentDetailId]	     = B.intLoadShipmentDetailId
	,[intLoadShipmentCostId]	     = NULL 

FROM tblICInventoryReceipt A INNER JOIN tblICInventoryReceiptItem B
		ON A.intInventoryReceiptId = B.intInventoryReceiptId
	INNER JOIN tblICItem C 
		ON B.intItemId = C.intItemId
	INNER JOIN tblICItemLocation loc 
		ON C.intItemId = loc.intItemId AND loc.intLocationId = A.intLocationId
	INNER JOIN  (
		tblAPVendor D1 INNER JOIN tblEMEntity D2 
			ON D1.[intEntityId] = D2.intEntityId
	) ON A.[intEntityVendorId] = D1.[intEntityId]
	
	LEFT JOIN (
		tblICItemUOM ItemWeightUOM INNER JOIN tblICUnitMeasure WeightUOM 
			ON WeightUOM.intUnitMeasureId = ItemWeightUOM.intUnitMeasureId		
	)
		ON ItemWeightUOM.intItemUOMId = B.intWeightUOMId
	LEFT JOIN (
		tblICItemUOM ItemCostUOM INNER JOIN tblICUnitMeasure CostUOM 
			ON CostUOM.intUnitMeasureId = ItemCostUOM.intUnitMeasureId
	)
		ON ItemCostUOM.intItemUOMId = B.intCostUOMId

	LEFT JOIN (
		tblICItemUOM ItemUOM INNER JOIN tblICUnitMeasure UOM 
			ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	)
		ON ItemUOM.intItemUOMId = B.intUnitMeasureId

	LEFT JOIN tblSMShipVia E 
		ON A.intShipViaId = E.[intEntityId]
		
	LEFT JOIN dbo.tblSMCurrency H1 ON H1.intCurrencyID = A.intCurrencyId
	LEFT JOIN dbo.tblEMEntityLocation EL ON EL.intEntityLocationId = A.intShipFromId
	LEFT JOIN dbo.tblSMCurrency SubCurrency ON SubCurrency.intMainCurrencyId = A.intCurrencyId 
	LEFT JOIN dbo.tblICStorageLocation ISL ON ISL.intStorageLocationId = B.intStorageLocationId 
	LEFT JOIN dbo.tblSMCompanyLocationSubLocation subLoc ON B.intSubLocationId = subLoc.intCompanyLocationSubLocationId	
	LEFT JOIN dbo.tblSMCurrencyExchangeRateType RT ON RT.intCurrencyExchangeRateTypeId = B.intForexRateTypeId
	LEFT JOIN dbo.tblSMTaxGroup TG ON TG.intTaxGroupId = B.intTaxGroupId
	LEFT JOIN vyuPATEntityPatron patron ON A.intEntityVendorId = patron.intEntityId
	LEFT JOIN tblSMFreightTerms FreightTerms ON FreightTerms.intFreightTermId = A.intFreightTermId
		
	LEFT JOIN tblAPVendor payToVendor ON payToVendor.intEntityId = A.intEntityVendorId
	LEFT JOIN tblEMEntityLocation payToAddress 
		ON payToAddress.intEntityId = payToVendor.intEntityId
		AND payToAddress.ysnDefaultLocation = 1

	OUTER APPLY (
		SELECT	dblQtyReturned = ri.dblOpenReceive - ISNULL(ri.dblQtyReturned, 0) 
				,r.strReceiptType
				,r.strReceiptNumber
				,ri.intOrderId 
				,ri.intLineNo 
		FROM	tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
					ON r.intInventoryReceiptId = ri.intInventoryReceiptId				
		WHERE	A.strReceiptType = 'Inventory Return'		
				AND r.intInventoryReceiptId = A.intSourceInventoryReceiptId
				AND ri.intInventoryReceiptItemId = B.intSourceInventoryReceiptItemId				
	) rtn

	OUTER APPLY (
		SELECT 
			CH.intContractHeaderId
			,CD.intContractDetailId			
			,CD.intContractSeq
			,CD.dblCashPrice
			,CD.intPricingTypeId
			,CD.dblFutures
			,CD.dblQuantity
			,CH.strContractNumber
			,CD.intItemUOMId
			,ctUOM.strUnitMeasure
			,J.dblFranchise
			,CD.intPricingStatus
		FROM 
			tblCTContractHeader CH INNER JOIN tblCTContractDetail CD 
				ON CH.intContractHeaderId = CD.intContractHeaderId
			LEFT JOIN dbo.tblCTWeightGrade J 
				ON J.intWeightGradeId = CH.intWeightId
			LEFT JOIN tblICItemUOM ctOrderUOM 
				ON ctOrderUOM.intItemUOMId = CD.intItemUOMId
			LEFT JOIN tblICUnitMeasure ctUOM 
				ON ctUOM.intUnitMeasureId  = ctOrderUOM.intUnitMeasureId
		WHERE
			(
				A.strReceiptType = 'Purchase Contract'
				OR (
					A.strReceiptType = 'Inventory Return'
					AND rtn.strReceiptType = 'Purchase Contract'
				)
			)
			AND CH.intContractHeaderId = ISNULL(B.intContractHeaderId, B.intOrderId)
			AND CD.intContractDetailId = ISNULL(B.intContractDetailId, B.intLineNo) 
	) Contracts		

	OUTER APPLY (		
		SELECT 
			G.intTicketId
			,G.strTicketNumber 
		FROM 
			tblSCTicket G 
		WHERE 
			A.intSourceType = 1 
			AND G.intTicketId = B.intSourceId 
	) ScaleTicket		
	
	OUTER APPLY 
	(
		SELECT 
			--SUM(ISNULL(billDetail.dblQtyReceived,0)) AS dblQty 
			dblQty = SUM(
				CASE 
					WHEN @billTypeToUse = @type_DebitMemo THEN -ISNULL(billDetail.dblQtyReceived,0)
					ELSE ISNULL(billDetail.dblQtyReceived,0)
				END 
			)
		FROM 
			tblAPBillDetail billDetail INNER JOIN tblAPBill bill
				ON billDetail.intBillId = bill.intBillId 
		WHERE 
			billDetail.intInventoryReceiptItemId = B.intInventoryReceiptItemId 
			AND billDetail.intInventoryReceiptChargeId IS NULL
			AND bill.intTransactionType NOT IN (13)  
			/*
				CASE A.intTransactionType
						WHEN 1 THEN 'Voucher'
						WHEN 2 THEN 'Vendor Prepayment'
						WHEN 3 THEN 'Debit Memo'
						WHEN 7 THEN 'Invalid Type'
						WHEN 9 THEN '1099 Adjustment'
						WHEN 11 THEN 'Claim'
						WHEN 12 THEN 'Prepayment Reversal'
						WHEN 13 THEN 'Basis Advance'
						WHEN 14 THEN 'Deferred Interest'
						ELSE 'Invalid Type'
				END		
			*/
		GROUP BY 
			billDetail.intInventoryReceiptItemId
	) Billed
	
	OUTER APPLY (
		SELECT	
				LogisticsView.strLoadNumber
				,LogisticsView.dblNetWt
		FROM	vyuICLoadContainersSearch LogisticsView 
		WHERE	
				(
					A.strReceiptType = 'Purchase Contract'
					OR (
						A.strReceiptType = 'Inventory Return'
						AND rtn.strReceiptType = 'Purchase Contract'
					)
				)		
				AND A.intSourceType = 2
				AND LogisticsView.intLoadDetailId = B.intSourceId 
				AND LogisticsView.intLoadContainerId = B.intContainerId
				
	) LogisticsView

	OUTER APPLY (
		SELECT	TOP 1 
				LogisticsView.strLoadNumber
		FROM	vyuICLoadContainersSearch LogisticsView 
		WHERE	
			A.intSourceType = 2
			AND LogisticsView.intLoadDetailId = B.intLoadShipmentDetailId
	) LogisticsView2

	OUTER APPLY (
		SELECT 
			po.strPurchaseOrderNumber
			,po.intPurchaseDetailId	 
			,po.strDescription
		FROM 
			vyuPODetails po 
		WHERE 
			(A.strReceiptType = 'Purchase Order' OR rtn.strReceiptType = 'Purchase Order')
			AND po.intPurchaseId = ISNULL(rtn.intOrderId, B.intOrderId)
			AND po.intPurchaseDetailId = ISNULL(rtn.intLineNo, B.intLineNo) 
	) PurchaseOrder

WHERE 
	A.intInventoryReceiptId = @intReceiptId
	AND A.strReceiptType IN ('Direct','Purchase Contract','Inventory Return','Purchase Order') 
	AND A.ysnPosted = @ysnPosted 
	AND (
		Billed.dblQty IS NULL
		OR 1 = 		
		(
			CASE 
				WHEN SIGN(B.dblOpenReceive) = -1 AND B.dblOpenReceive < Billed.dblQty THEN 1 
				WHEN SIGN(B.dblOpenReceive) = 1 AND B.dblOpenReceive > Billed.dblQty THEN 1 
				ELSE 0
			END 
		) 
	)
	AND B.dblUnitCost <> 0 --EXCLUDE ZERO RECEIPT COST 
	AND ISNULL(A.ysnOrigin, 0) = 0
	AND B.intOwnershipType <> 2	
	AND C.strType <> 'Bundle'
	AND ISNULL(A.strReceiptType, '') <> 'Transfer Order'
	AND ISNULL(B.ysnAllowVoucher, 1) = 1
	AND NOT (
		A.strReceiptType = 'Purchase Contract'
		AND ISNULL(Contracts.intPricingTypeId, 0) = 2 -- 2 is Basis. 		
		AND ISNULL(Contracts.intPricingStatus, 0) = 0 -- NOT IN (1, 2) -- 1 is Partially Priced, 2 is Fully Priced. 
	)
	/*
		LG-2384
		If there's a contract involved and it already generated payables for items, don't re-generate them during posting but remove all of them during unposting.
	*/
	AND (
		Contracts.intContractDetailId IS NULL OR 
		(
			CASE WHEN 
				Contracts.intContractDetailId IS NOT NULL 
				AND A.strReceiptType = 'Purchase Contract' 				
				AND EXISTS(
					SELECT TOP 1 1 
					FROM tblAPVoucherPayable 
					WHERE intEntityVendorId = A.intEntityVendorId 
					AND intContractDetailId = Contracts.intContractDetailId
					AND strSourceNumber <> A.strReceiptNumber
					AND intInventoryReceiptItemId IS NULL
					AND intInventoryReceiptChargeId IS NULL 
					AND intInventoryShipmentChargeId IS NULL
					AND intItemId = B.intItemId
				)
				THEN 0 ELSE 1 
			END = 1
		)
)
ORDER BY 
	B.intInventoryReceiptItemId ASC 

--RECEIPT OTHER CHARGES
INSERT INTO @table
SELECT DISTINCT
		[intEntityVendorId]							=	A.intEntityVendorId
		,[intTransactionType]						=	CASE WHEN A.strReceiptType = 'Inventory Return' THEN 3 ELSE ISNULL(@billTypeToUse, 1) END 
		,[dtmDate]									=	A.dtmDate
		,[strReference]								=	A.strReference
		,[strSourceNumber]							=	A.strSourceNumber
		,[strVendorOrderNumber]						=	
				CASE 
					WHEN IR.strReceiptType = 'Inventory Return' THEN 
						CASE 
							WHEN @intDebitMemoInvoiceNoOption = @debitMemoInvoiceOption_Blank THEN NULL 
							WHEN @intDebitMemoInvoiceNoOption = @debitMemoInvoiceOption_BOL THEN IR.strBillOfLading
							WHEN @intDebitMemoInvoiceNoOption = @debitMemoInvoiceOption_VendorRefNo THEN IR.strVendorRefNo 
							ELSE  ISNULL(NULLIF(LTRIM(RTRIM(IR.strBillOfLading)), ''), IR.strVendorRefNo)
						END 
					ELSE
						CASE 
							WHEN @intVoucherInvoiceNoOption = @voucherInvoiceOption_Blank THEN NULL 
							WHEN @intVoucherInvoiceNoOption = @voucherInvoiceOption_BOL THEN IR.strBillOfLading 
							WHEN @intVoucherInvoiceNoOption = @voucherInvoiceOption_VendorRefNo THEN IR.strVendorRefNo 
							ELSE  ISNULL(NULLIF(LTRIM(RTRIM(IR.strBillOfLading)), ''), IR.strVendorRefNo)
						END 						
				END 
		,[strPurchaseOrderNumber]					=	NULL
		,[intPurchaseDetailId]						=	NULL
		,[intItemId]								=	A.intItemId
		,[strMiscDescription]						=	A.strMiscDescription
		,[strItemNo]								=	A.strItemNo
		,[strDescription]							=	A.strDescription
		,[intPurchaseTaxGroupId]					=	A.intTaxGroupId
		,[dblOrderQty]								=	
			--A.dblOrderQty
			CASE 
				WHEN @billTypeToUse = @type_DebitMemo AND A.intEntityVendorId = IR.intEntityVendorId THEN -A.dblOrderQty
				ELSE A.dblOrderQty
			END 				

		,[dblPOOpenReceive]							=	A.dblPOOpenReceive
		,[dblOpenReceive]							=	
			--A.dblOpenReceive
			CASE 
				WHEN @billTypeToUse = @type_DebitMemo AND A.intEntityVendorId = IR.intEntityVendorId THEN -A.dblOpenReceive
				ELSE A.dblOpenReceive
			END 
		,[dblQuantityToBill]						=	
			--A.dblQuantityToBill
			CASE 
				WHEN @billTypeToUse = @type_DebitMemo AND A.intEntityVendorId = IR.intEntityVendorId THEN -A.dblQuantityToBill
				ELSE A.dblQuantityToBill
			END 
		,[dblQtyToBillUnitQty]						=	1
		,[intQtyToBillUOMId]						=	A.intCostUnitMeasureId
		,[dblQuantityBilled]						=	A.dblQuantityBilled
		,[intLineNo]								=	A.intLineNo
		,[intInventoryReceiptItemId]				=	A.intInventoryReceiptItemId
		,[intInventoryReceiptChargeId]				=	A.intInventoryReceiptChargeId
		,[intContractChargeId]						=	NULL
		,[dblUnitCost]								=	CAST(A.dblUnitCost AS DECIMAL(38,20))
		,[dblDiscount]								=	0
		,[dblTax]									=	ISNULL((CASE WHEN ISNULL(A.intEntityVendorId, IR.intEntityVendorId) <> IR.intEntityVendorId
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
		,[intContractSequence]						=	A.intContractSeq
		,[intContractCostId]						= 	NULL
		,[intScaleTicketId]							=	A.intScaleTicketId
		,[strScaleTicketNumber]						=	A.strScaleTicketNumber
		,[strLoadShipmentNumber]					=	A.strLoadNumber 
		,[intShipmentId]							=	0      
		,[intLoadDetailId]							=	A.intLoadDetailId
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
		,[ysnReturn]								=			
			--CAST((CASE WHEN A.strReceiptType = 'Inventory Return' THEN 1 ELSE 0 END) AS BIT)
			CAST(
				CASE 
					WHEN A.strReceiptType = 'Inventory Return' THEN 1 
					WHEN @billTypeToUse = @type_DebitMemo AND A.ysnPrice = 1 THEN 1 
					WHEN @billTypeToUse = @type_DebitMemo AND A.intEntityVendorId = IR.intEntityVendorId THEN 1 
					ELSE 0 
				END
			AS BIT)
		,[strTaxGroup]								=	TG.strTaxGroup
		,intShipViaId								=   NULL 
		,intShipFromId								=	IR.intShipFromId 
		,intShipFromEntityId						=	IR.intShipFromEntityId 
		,intPaytoAddressId							=	payToAddress.intEntityLocationId
		,[intLoadShipmentId]			 			= A.intLoadShipmentId     
		,[intLoadShipmentDetailId]	     			= NULL 
		,[intLoadShipmentCostId]	     			= A.intLoadShipmentCostId
FROM [vyuICChargesForBilling] A
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
	LEFT JOIN tblCTContractDetail CD 
		ON CD.intContractHeaderId = A.intContractHeaderId
		AND CD.intContractDetailId = A.intContractDetailId
	LEFT JOIN tblSMTaxGroup TG ON TG.intTaxGroupId = A.intTaxGroupId
	LEFT OUTER JOIN tblAPVendor payToVendor ON payToVendor.intEntityId = A.intEntityVendorId
	LEFT OUTER JOIN tblEMEntityLocation payToAddress ON payToAddress.intEntityId = payToVendor.intEntityId
		AND payToAddress.ysnDefaultLocation = 1
	OUTER APPLY
	(
		SELECT TOP 1 ysnCheckoffTax FROM tblICInventoryReceiptChargeTax IRCT
		WHERE IRCT.intInventoryReceiptChargeId = A.intInventoryReceiptChargeId
	)  IRCT
	OUTER APPLY 
	(
		SELECT 
			intEntityVendorId
			,SUM(ISNULL(dblQtyReceived,0)) AS dblQtyReceived 
		FROM 
			tblAPBillDetail BD INNER JOIN dbo.tblAPBill B 
				ON BD.intBillId = B.intBillId
		WHERE 
			BD.intInventoryReceiptChargeId = A.intInventoryReceiptChargeId
			AND B.intTransactionType NOT IN (13)  
			/*
				CASE A.intTransactionType
						WHEN 1 THEN 'Voucher'
						WHEN 2 THEN 'Vendor Prepayment'
						WHEN 3 THEN 'Debit Memo'
						WHEN 7 THEN 'Invalid Type'
						WHEN 9 THEN '1099 Adjustment'
						WHEN 11 THEN 'Claim'
						WHEN 12 THEN 'Prepayment Reversal'
						WHEN 13 THEN 'Basis Advance'
						WHEN 14 THEN 'Deferred Interest'
						ELSE 'Invalid Type'
				END		
			*/
		GROUP BY 
			intEntityVendorId
			, BD.intInventoryReceiptChargeId

	) Billed
WHERE
	-- This part is used to convert the IR to Voucher. It should not include the 3rd party vendors
	(
		@ysnForVoucher = 1 
		AND A.intInventoryReceiptId = @intReceiptId 
		AND (A.intEntityVendorId = IR.intEntityVendorId)		
		AND (
			(
				A.[intEntityVendorId] NOT IN (Billed.intEntityVendorId) 
				AND (A.dblOrderQty <> ISNULL(Billed.dblQtyReceived,0)) 
				OR Billed.dblQtyReceived IS NULL
			)
			AND 1 =  CASE WHEN CD.intPricingTypeId IS NOT NULL AND CD.intPricingTypeId IN (2) THEN 0 ELSE 1 END  --EXLCUDE ALL BASIS
			AND 1 = CASE WHEN (A.intEntityVendorId = IR.intEntityVendorId AND CD.intPricingTypeId IS NOT NULL AND CD.intPricingTypeId = 5) THEN 0 ELSE 1 END --EXCLUDE DELAYED PRICING TYPE FOR RECEIPT VENDOR
		)	
		AND ISNULL(A.ysnAllowVoucher, 1) = 1
	)
	-- This condition is used to insert the other charges, including the 3rd party vendors, to the payable table. 
	OR (
		ISNULL(@ysnForVoucher,0) = 0
		AND A.intInventoryReceiptId = @intReceiptId 
		AND (A.intEntityVendorId IS NOT NULL)		
		AND (
			(
				A.[intEntityVendorId] NOT IN (Billed.intEntityVendorId) 
				AND (A.dblOrderQty <> ISNULL(Billed.dblQtyReceived,0)) 
				OR Billed.dblQtyReceived IS NULL
			)
			AND 1 =  CASE WHEN CD.intPricingTypeId IS NOT NULL AND CD.intPricingTypeId IN (2) THEN 0 ELSE 1 END  --EXLCUDE ALL BASIS
			AND 1 = CASE WHEN (A.intEntityVendorId = IR.intEntityVendorId AND CD.intPricingTypeId IS NOT NULL AND CD.intPricingTypeId = 5) THEN 0 ELSE 1 END --EXCLUDE DELAYED PRICING TYPE FOR RECEIPT VENDOR
		)
		/*
			IC-7556
			If there's a contract involved and it already generated payables for costs/charges, don't re-generate them during posting but remove all of them during unposting.
		*/
		AND (
			CD.intContractDetailId IS NULL OR 
			(
				CASE WHEN CD.intContractDetailId IS NOT NULL AND A.strReceiptType = 'Purchase Contract' 
					AND EXISTS(
						SELECT TOP 1 1 
						FROM tblAPVoucherPayable 
						WHERE intEntityVendorId = A.intEntityVendorId 
						AND intContractDetailId = CD.intContractDetailId
						AND strSourceNumber <> A.strSourceNumber
						AND intInventoryReceiptItemId IS NULL 
						AND intInventoryReceiptChargeId IS NULL 
						AND intInventoryShipmentChargeId IS NULL						
					)
					THEN 0 ELSE 1 
				END = 1
			)
		)
		AND ISNULL(A.ysnAllowVoucher, 1) = 1
	)
RETURN

END
GO
