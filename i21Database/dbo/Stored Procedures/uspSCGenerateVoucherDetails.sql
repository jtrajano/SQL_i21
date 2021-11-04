CREATE PROCEDURE [dbo].[uspSCGenerateVoucherDetails]
	@VoucherDetailReceipt AS VoucherDetailReceipt READONLY
	,@VoucherDetailReceiptCharge AS VoucherDetailReceiptCharge READONLY
	,@voucherDetailDirect AS [VoucherDetailDirectInventory] READONLY
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @VoucherPayable AS VoucherPayable;
DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
DECLARE @defaultCurrency INT;
DECLARE @currentDateFilter DATETIME = (SELECT CONVERT(char(10), GETDATE(),126));

DECLARE @receiptItems AS TABLE (
	[intInventoryReceiptType]		INT				NOT NULL,
	[intInventoryReceiptItemId]		INT				NOT NULL,
    [dblQtyReceived]				DECIMAL(18, 6)	NULL, 
    [dblCost]						DECIMAL(38, 20)	NULL, 
	[dblCostUnitQty]				DECIMAL(38, 20)	NULL, 
	[dblTotal]						DECIMAL(18, 6)	NULL, 
	[dblNetWeight]					DECIMAL(18, 6)	NULL, 
	[intUnitOfMeasureId]    		INT             NULL ,
	[dblUnitQty]					DECIMAL(18, 6) NOT NULL DEFAULT 0,
	/*Start - Bund Item Info*/
	[intItemBundleId]				INT				NULL, --Primary key of tblICItemBundle
	[intBundletUOMId]				INT				NULL,
	[dblQtyBundleReceived]			INT				NULL  DEFAULT(0),
	[dblBundleUnitQty]				DECIMAL(38, 20)	NULL  DEFAULT(0), 
	[strBundleDescription]			NVARCHAR (500)  COLLATE Latin1_General_CI_AS NULL,
	[dblBundleTotal]				DECIMAL(38, 20)	NULL  DEFAULT(0), 
	/*End - Bund Item Info*/
	[intCostUOMId]					INT NULL,
    [intTaxGroupId]					INT NULL,
	[int1099Form] 					INT NULL DEFAULT 0 , 
    [int1099Category] 				INT NULL DEFAULT 0 
);

SELECT TOP 1 
	@defaultCurrency = intDefaultCurrencyId
FROM dbo.tblSMCompanyPreference

BEGIN /* Receipt Items */

INSERT INTO @receiptItems(
	[intInventoryReceiptType]		
	,[intInventoryReceiptItemId]		
	,[dblQtyReceived]				
	,[dblCost]						
	,[dblCostUnitQty]				
	,[dblTotal]						
	,[dblNetWeight]					
	,[intCostUOMId]					
	,[intTaxGroupId]					
	,[int1099Form] 					
	,[int1099Category] 		
	/*Start - Bund Item Info*/
	,[intItemBundleId]				
	,[intBundletUOMId]				
	,[dblQtyBundleReceived]			
	,[dblBundleUnitQty]		
	,[strBundleDescription]		
	,[dblBundleTotal]	
	,[intUnitOfMeasureId]
	,[dblUnitQty]			
	/*End - Bund Item Info*/
)		
SELECT 
	[intInventoryReceiptType]		=	A.intInventoryReceiptType,
	[intInventoryReceiptItemId]		=	A.intInventoryReceiptItemId,
	[dblQtyReceived]				=	(CASE WHEN A.dblQtyReceived IS NULL  
												THEN B.dblOpenReceive - B.dblBillQty
												ELSE A.dblQtyReceived END),
	[dblCost]						=	CASE WHEN C.strReceiptType = 'Inventory Return' THEN B.dblUnitCost ELSE -- USE THE RECEIPT COST IF TRANSACTION IS NOT A VOUCHER
														CASE WHEN contractDetail.dblSeqPrice > 0 
														THEN contractDetail.dblSeqPrice
														ELSE 
															(CASE WHEN B.dblUnitCost = 0 AND contractDetail.dblSeqPrice > 0
																THEN contractDetail.dblSeqPrice
																ELSE B.dblUnitCost
																END)
														END --use cash price of contract if unit cost of receipt item is 0,
										END,
	[dblCostUnitQty]				=	ISNULL(CASE WHEN contractDetail.intContractDetailId IS NOT NULL 
											THEN ContractItemCostUOM.dblUnitQty
											ELSE ItemCostUOM.dblUnitQty END, 1),
	[dblTotal]						=	0,
	[dblNetWeight]					=	0,
	[intCostUOMId]					=	CASE WHEN contractDetail.intContractDetailId IS NOT NULL 
											THEN contractDetail.intPriceItemUOMId
											ELSE B.intCostUOMId END,
	[intTaxGroupId]					=	A.intTaxGroupId,
	[int1099Form]					=	CASE 	WHEN patron.intEntityId IS NOT NULL 
													AND B.intItemId > 0
													AND item.ysn1099Box3 = 1
													AND patron.ysnStockStatusQualified = 1 
													THEN 4
												WHEN entity.str1099Form = '1099-MISC' THEN 1
												WHEN entity.str1099Form = '1099-INT' THEN 2
												WHEN entity.str1099Form = '1099-B' THEN 3
										ELSE 0
										END,
	[int1099Category]				=	CASE 	WHEN patron.intEntityId IS NOT NULL 
												AND B.intItemId > 0
												AND item.ysn1099Box3 = 1
												AND patron.ysnStockStatusQualified = 1 
												THEN 3
									ELSE
										ISNULL(F.int1099CategoryId,0)
									END,
	[intItemBundleId]				=	A.intItemBundleId,
	[intBundletUOMId]				=	A.intBundletUOMId,
	[dblQtyBundleReceived]			=	ISNULL(A.dblQtyBundleReceived,0),
	[dblBundleUnitQty]				=	ISNULL(A.dblBundleUnitQty,0),
	[strBundleDescription]			=	itemBundle.strDescription,
	[dblBundleTotal]				=	ISNULL(A.dblBundleTotal,0),
	[intUnitOfMeasureId]			=	CASE WHEN contractDetail.intContractDetailId IS NOT NULL 
											THEN contractDetail.intItemUOMId
											ELSE B.intUnitMeasureId END,
	[dblUnitQty]					=	ISNULL(contractDetail.dblUnitQty, ABS(ISNULL(ItemUOM.dblUnitQty,0)))

FROM @VoucherDetailReceipt A
INNER JOIN tblICInventoryReceiptItem B ON A.intInventoryReceiptItemId = B.intInventoryReceiptItemId
INNER JOIN tblICInventoryReceipt C ON B.intInventoryReceiptId = C.intInventoryReceiptId
INNER JOIN tblEMEntity entity ON C.[intEntityVendorId] = entity.intEntityId
INNER JOIN tblICItem item ON B.intItemId = item.intItemId
LEFT JOIN tblICItemBundle itemBundle ON itemBundle.intItemBundleId = A.intItemBundleId
LEFT JOIN vyuSCGetScaleDistribution D ON D.intInventoryReceiptItemId = B.intInventoryReceiptItemId
LEFT JOIN vyuPATEntityPatron patron ON C.intEntityVendorId = patron.intEntityId
LEFT JOIN tblICItemUOM ItemCostUOM ON ItemCostUOM.intItemUOMId = B.intCostUOMId
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = B.intUnitMeasureId
LEFT JOIN vyuCTContractDetailView contractDetail 
			ON 	contractDetail.intContractHeaderId = B.intOrderId 
				AND contractDetail.intContractDetailId = B.intLineNo
LEFT JOIN tblICItemUOM ContractItemCostUOM ON ContractItemCostUOM.intItemUOMId = contractDetail.intPriceItemUOMId
LEFT JOIN tblAP1099Category F ON entity.str1099Type = F.strCategory

END

BEGIN /* DIRECT IR */

	IF EXISTS(SELECT NULL FROM @receiptItems WHERE intInventoryReceiptType = 1)
	BEGIN
		INSERT INTO @VoucherPayable(
			[intTransactionType],
			[intItemId],
			[strMiscDescription],
			[intInventoryReceiptItemId],
			[dblQuantityToBill],
			[dblOrderQty],
			[dblExchangeRate],
			[intCurrencyExchangeRateTypeId],
			[ysnSubCurrency],
			[intAccountId],
			[dblCost],
			[dblOldCost],
			[dblNetWeight],
			[dblWeightLoss],
			[intQtyToBillUOMId],
			[intCostUOMId],
			[intWeightUOMId],
			[intLineNo],
			[dblWeightUnitQty],
			[dblCostUnitQty],
			[dblQtyToBillUnitQty],
			[intCurrencyId],
			[intStorageLocationId],
			[int1099Form],
			[int1099Category],
			[strBillOfLading],
			[intScaleTicketId],
			[intLocationId],
			[intShipFromId],
			[intShipToId],
			[intEntityVendorId],
			[strVendorOrderNumber],
			[intPurchaseTaxGroupId],
			[dblTax]
		)
		SELECT 
			[intTransactionType]			=   1,
			[intItemId]						=	B.intItemId,
			[strMiscDescription]			=	C.strDescription,
			[intInventoryReceiptItemId]		=	B.intInventoryReceiptItemId,
			[dblQuantityToBill]				=	voucherDetailReceipt.dblQtyReceived,
			[dblOrderQty]					=	voucherDetailReceipt.dblQtyReceived,
			[dblExchangeRate]				=	ISNULL(B.dblForexRate,1),
			[intCurrencyExchangeRateTypeId]	=	B.intForexRateTypeId,
			[ysnSubCurrency]				=	CASE WHEN B.ysnSubCurrency > 0 THEN 1 ELSE 0 END,
			[intAccountId]					=	[dbo].[fnGetItemGLAccount](B.intItemId, D.intItemLocationId, 'AP Clearing'),
			[dblCost]						=	voucherDetailReceipt.dblCost, --voucherDetailReceipt.dblCost,
			[dblOldCost]					=	NULL,
			[dblNetWeight]					=	CASE WHEN B.intWeightUOMId > 0 THEN  
													(CASE WHEN B.dblBillQty > 0 
															THEN voucherDetailReceipt.dblQtyReceived * (ItemUOM.dblUnitQty/ ISNULL(ItemWeightUOM.dblUnitQty ,1)) --THIS IS FOR PARTIAL
														ELSE B.dblNet --THIS IS FOR NO RECEIVED QTY YET BUT HAS NET WEIGHT DIFFERENT FROM GROSS
													END)
												ELSE 0 END,
			[dblWeightLoss]					=	ISNULL(B.dblGross - B.dblNet,0),
			[intQtyToBillUOMId]				=	B.intUnitMeasureId,
			[intCostUOMId]					=	voucherDetailReceipt.intCostUOMId,
			[intWeightUOMId]				=	B.intWeightUOMId,
			[intLineNo]						=	ISNULL(B.intSort,0),
			[dblWeightUnitQty]				=	ISNULL(ItemWeightUOM.dblUnitQty,0),
			[dblCostUnitQty]				=	voucherDetailReceipt.dblCostUnitQty,
			[dblQtyToBillUnitQty]			=	ABS(ISNULL(ItemUOM.dblUnitQty,0)),
			[intCurrencyId]					=	CASE WHEN B.ysnSubCurrency > 0 THEN ISNULL(SubCurrency.intCurrencyID,0)
												ELSE ISNULL(A.intCurrencyId,0) END,
			[intStorageLocationId]			=   B.intStorageLocationId,
			[int1099Form]					=	voucherDetailReceipt.int1099Form,
			[int1099Category]				=	voucherDetailReceipt.int1099Category,
			[strBillOfLading]				= 	A.strBillOfLading,
			[intScaleTicketId]				=	CASE WHEN A.intSourceType = 1 THEN B.intSourceId ELSE NULL END,
			[intLocationId]					=	A.intLocationId,
			[intShipFromId]					=   A.intShipFromId,
			[intShipToId]					=   A.intLocationId,
			[intEntityVendorId]				=   A.intEntityVendorId,
			[strVendorOrderNumber]			=   A.strVendorRefNo,
			[intPurchaseTaxGroupId]			=	B.intTaxGroupId,
			[dblTax]						= B.dblTax
		FROM tblICInventoryReceipt A
		INNER JOIN tblICInventoryReceiptItem B
			ON A.intInventoryReceiptId = B.intInventoryReceiptId
		INNER JOIN @receiptItems voucherDetailReceipt
			ON B.intInventoryReceiptItemId = voucherDetailReceipt.intInventoryReceiptItemId
		INNER JOIN tblICItem C
			ON B.intItemId = C.intItemId
		INNER JOIN tblICItemLocation D
			ON A.intLocationId = D.intLocationId AND B.intItemId = D.intItemId
		LEFT JOIN tblSMCurrencyExchangeRate F ON  (F.intFromCurrencyId = (SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference) AND F.intToCurrencyId = A.intCurrencyId)
		LEFT JOIN dbo.tblSMCurrencyExchangeRateDetail G ON F.intCurrencyExchangeRateId = G.intCurrencyExchangeRateId AND G.dtmValidFromDate = (SELECT CONVERT(char(10), GETDATE(),126))
		LEFT JOIN dbo.tblSMCurrency H ON H.intCurrencyID = A.intCurrencyId
		LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemUOMId = B.intWeightUOMId
		LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = ItemWeightUOM.intUnitMeasureId
		LEFT JOIN tblICItemUOM ItemCostUOM ON ItemCostUOM.intItemUOMId = B.intCostUOMId
		LEFT JOIN tblICUnitMeasure CostUOM ON CostUOM.intUnitMeasureId = ItemCostUOM.intUnitMeasureId
		LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = B.intUnitMeasureId
		LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
		LEFT JOIN tblSMCurrency SubCurrency ON SubCurrency.intMainCurrencyId = A.intCurrencyId 
		LEFT JOIN (tblCTContractHeader CH INNER JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId)  ON CH.intEntityId = A.intEntityVendorId 
																															AND CH.intContractHeaderId = B.intOrderId 
																															AND CD.intContractDetailId = B.intLineNo 
		INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.intEntityId = D2.intEntityId) ON D1.intEntityId = A.intEntityVendorId
		LEFT JOIN vyuSCGetScaleDistribution SD ON SD.intInventoryReceiptItemId = B.intInventoryReceiptItemId
		WHERE A.ysnPosted = 1 AND voucherDetailReceipt.intInventoryReceiptType = 1
	END

END

BEGIN /* PURCHASE CONTRACT */

	IF EXISTS(SELECT NULL FROM @receiptItems WHERE intInventoryReceiptType = 2)
	BEGIN
		INSERT INTO @VoucherPayable(
			[intTransactionType],
			[intItemId],
			[strMiscDescription],
			[intInventoryReceiptItemId],
			[dblQuantityToBill],
			[dblOrderQty],
			[dblExchangeRate],
			[intCurrencyExchangeRateTypeId],
			[ysnSubCurrency],
			[intAccountId],
			[dblCost],
			[dblOldCost],
			[dblNetWeight],
			[dblNetShippedWeight],
			[dblWeightLoss],
			[dblFranchiseWeight],
			[intContractDetailId],
			[intContractHeaderId],
			[intQtyToBillUOMId],
			[intCostUOMId],
			[intWeightUOMId],
			[intLineNo],
			[dblWeightUnitQty],
			[dblCostUnitQty],
			[dblQtyToBillUnitQty],
			[intCurrencyId],
			[intStorageLocationId],
			[int1099Form],
			[int1099Category],
			[intLoadShipmentDetailId],
			[strBillOfLading],
			[intScaleTicketId],
			[intLocationId],			
			[intShipFromId],
			[intShipToId],
			[intEntityVendorId],
			[strVendorOrderNumber],
			[intPurchaseTaxGroupId],
			[dblTax]
		)
		SELECT 
			[intTransactionType]		=	1,
			[intItemId]					=	B.intItemId,
			[strMiscDescription]		=	C.strDescription,
			[intInventoryReceiptItemId]	=	B.intInventoryReceiptItemId,
			[dblQtyOrdered]				=	ISNULL(voucherDetailReceipt.dblQtyReceived, ABS(B.dblOpenReceive - B.dblBillQty)),
			[dblQtyReceived]			=	ISNULL(voucherDetailReceipt.dblQtyReceived, ABS(B.dblOpenReceive - B.dblBillQty)),
			[dblForexRate]				=	ISNULL(B.dblForexRate,1),
			[intForexRateTypeId]		=	B.intForexRateTypeId,
			[ysnSubCurrency]			=	CASE WHEN B.ysnSubCurrency > 0 THEN 1 ELSE 0 END,
			[intAccountId]				=	[dbo].[fnGetItemGLAccount](B.intItemId, D.intItemLocationId, 'AP Clearing'),
			[dblCost]						=	voucherDetailReceipt.dblCost,
			[dblOldCost]					=	NULL,
			[dblNetWeight]					=	CASE WHEN B.intWeightUOMId > 0 THEN  
													-- voucherDetailReceipt.dblQtyReceived * (ItemUOM.dblUnitQty/ ISNULL(ItemWeightUOM.dblUnitQty ,1))
													(CASE WHEN B.dblBillQty > 0 
															THEN voucherDetailReceipt.dblQtyReceived * (ItemUOM.dblUnitQty/ ISNULL(ItemWeightUOM.dblUnitQty ,1)) --THIS IS FOR PARTIAL
														ELSE B.dblNet --THIS IS FOR NO RECEIVED QTY YET BUT HAS NET WEIGHT DIFFERENT FROM GROSS
											END)
											ELSE 0 END,
			[dblNetShippedWeight]		=	(CASE WHEN A.intSourceType = 2 AND loads.intLoadContainerId = B.intContainerId --Inbound Shipment
												THEN loads.dblNetWt ELSE 0 END),
			[dblWeightLoss]				=	ISNULL(B.dblGross - B.dblNet,0),
			[dblFranchiseWeight]		=	CASE WHEN J.dblFranchise > 0 THEN ISNULL(B.dblGross,0) * (J.dblFranchise / 100) ELSE 0 END,
			[intContractDetailId]		=	E1.intContractDetailId,
			[intContractHeaderId]		=	E.intContractHeaderId,
			[intQtyToBillUOMId]			=	voucherDetailReceipt.intUnitOfMeasureId,
			[intCostUOMId]				=	voucherDetailReceipt.intCostUOMId,
			[intWeightUOMId]			=	B.intWeightUOMId,
			[intLineNo]					=	ISNULL(B.intSort,0),
			[dblWeightUnitQty]			=	ISNULL(ItemWeightUOM.dblUnitQty,0),
			[dblCostUnitQty]			=	ABS(ISNULL(voucherDetailReceipt.dblCostUnitQty,0)),
			[dblQtyToBillUnitQty]		=	voucherDetailReceipt.dblUnitQty,
			[intCurrencyId]				=	CASE WHEN B.ysnSubCurrency > 0 THEN ISNULL(SubCurrency.intCurrencyID,0)
											ELSE ISNULL(A.intCurrencyId,0) END,
			[intStorageLocationId]		=   B.intStorageLocationId,
			[int1099Form]				=	voucherDetailReceipt.int1099Form,
			[int1099Category]			=	voucherDetailReceipt.int1099Category,
			[intLoadDetailId]			=	CASE WHEN A.strReceiptType = 'Purchase Contract' AND A.intSourceType = 2 THEN B.intSourceId ELSE NULL END,
			[strBillOfLading]			= 	A.strBillOfLading,
			[intScaleTicketId]			=	CASE WHEN A.intSourceType = 1 THEN B.intSourceId ELSE NULL END,
			[intLocationId]				=	A.intLocationId,
			[intShipFromId]				=   A.intShipFromId,
			[intShipToId]				=  A.intLocationId,
			[intEntityVendorId]			=  A.intEntityVendorId,
			[strVendorOrderNumber]		=   A.strVendorRefNo,
			[intPurchaseTaxGroupId]		= B.intTaxGroupId,
			[dblTax]					= B.dblTax
		FROM tblICInventoryReceipt A
		INNER JOIN tblICInventoryReceiptItem B
			ON A.intInventoryReceiptId = B.intInventoryReceiptId
		INNER JOIN @receiptItems voucherDetailReceipt
			ON B.intInventoryReceiptItemId = voucherDetailReceipt.intInventoryReceiptItemId
		INNER JOIN tblICItem C
			ON B.intItemId = C.intItemId
		INNER JOIN tblICItemLocation D
			ON A.intLocationId = D.intLocationId AND B.intItemId = D.intItemId
		LEFT JOIN (tblCTContractHeader E INNER JOIN tblCTContractDetail E1 ON E.intContractHeaderId = E1.intContractHeaderId) 
			ON  
					E.intContractHeaderId = B.intOrderId 
					AND E1.intContractDetailId = B.intLineNo
		LEFT JOIN tblSMCurrencyExchangeRate F ON  (F.intFromCurrencyId = (SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference) AND F.intToCurrencyId = A.intCurrencyId)
		LEFT JOIN dbo.tblSMCurrencyExchangeRateDetail G ON F.intCurrencyExchangeRateId = G.intCurrencyExchangeRateId AND G.dtmValidFromDate = (SELECT CONVERT(char(10), GETDATE(),126))
		LEFT JOIN dbo.tblSMCurrency H ON H.intCurrencyID = A.intCurrencyId
		LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemUOMId = B.intWeightUOMId
		LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = ItemWeightUOM.intUnitMeasureId
		LEFT JOIN tblICItemUOM ItemCostUOM ON ItemCostUOM.intItemUOMId = B.intCostUOMId
		LEFT JOIN tblICUnitMeasure CostUOM ON CostUOM.intUnitMeasureId = ItemCostUOM.intUnitMeasureId
		LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = B.intUnitMeasureId
		LEFT JOIN tblICItemUOM ItemContractUOM ON ItemContractUOM.intItemUOMId = E1.intItemUOMId 
														AND E1.intContractDetailId = B.intLineNo AND E.intContractHeaderId = B.intOrderId
		LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
		LEFT JOIN tblSMCurrency SubCurrency ON SubCurrency.intMainCurrencyId = A.intCurrencyId 
		LEFT JOIN tblCTWeightGrade J ON E.intWeightId = J.intWeightGradeId
		INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.intEntityId = D2.intEntityId) ON D1.intEntityId = A.intEntityVendorId
		LEFT JOIN tblCTWeightGrade W ON E.intWeightId = W.intWeightGradeId
		LEFT JOIN tblLGLoadContainer loads ON loads.intLoadContainerId = B.intContainerId
		LEFT JOIN vyuSCGetScaleDistribution SD ON SD.intInventoryReceiptItemId = B.intInventoryReceiptItemId
		WHERE A.ysnPosted = 1 AND voucherDetailReceipt.intInventoryReceiptType = 2
	END

END

BEGIN /* RECEIPT CHARGES */
	
	INSERT INTO @VoucherPayable(
		[intTransactionType],
		[intItemId],
		[strMiscDescription],
		[intInventoryReceiptItemId],
		[intInventoryReceiptChargeId],
		[intPurchaseDetailId],
		[dblQuantityToBill],
		[dblOrderQty],
		[dblTax],
		[dblExchangeRate],
		[intCurrencyExchangeRateTypeId],
		[ysnSubCurrency],
		[intAccountId],
		[dblCost],
		[dblOldCost],
		[dblNetWeight],
		[dblNetShippedWeight],
		[dblWeightLoss],
		[dblFranchiseWeight],
		[intContractDetailId],
		[intContractHeaderId],
		[intQtyToBillUOMId],
		[intCostUOMId],
		[intWeightUOMId],
		[intLineNo],
		[dblWeightUnitQty],
		[dblCostUnitQty],
		[dblQtyToBillUnitQty],
		[intCurrencyId],
		[intStorageLocationId],
		[int1099Form],
		[int1099Category],
		[intScaleTicketId],
		[intLocationId],
		[intEntityVendorId],
		[intPurchaseTaxGroupId]
	)
	SELECT DISTINCT
		[intTransactionType]			=	1,
		[intItemId]						=	A.intItemId,
		[strMiscDescription]			=	item.strDescription,
		[intInventoryReceiptItemId]  	= 	J.intInventoryReceiptItemId,
		[intInventoryReceiptChargeId]	=	A.[intInventoryReceiptChargeId],
		[intPurchaseDetailId]			=	NULL,
		[dblQuantityToBill]				=	A.dblOrderQty,
		[dblOrderQty]					=	A.dblOrderQty, --ISNULL(charges.dblQtyReceived, A.dblQuantityToBill),
		[dblTax]						=	ISNULL((CASE WHEN ISNULL(A.intEntityVendorId, IR.intEntityVendorId) != IR.intEntityVendorId
																		THEN (CASE WHEN IRCT.ysnCheckoffTax = 0 THEN ABS(A.dblTax) 
																				ELSE A.dblTax END) --THIRD PARTY TAX SHOULD RETAIN NEGATIVE IF CHECK OFF
																	 ELSE (CASE WHEN A.ysnPrice = 1 AND IRCT.ysnCheckoffTax = 1 THEN A.dblTax * -1 
																	 		WHEN A.ysnPrice = 1 AND IRCT.ysnCheckoffTax = 0 THEN -A.dblTax --negate, inventory receipt will bring postive tax
																	 		ELSE A.dblTax END ) END),0),
		[dblExchangeRate]				=	ISNULL(A.dblForexRate,1),
		[intCurrencyExchangeRateTypeId]	=   A.intForexRateTypeId,
		[ysnSubCurrency]				=	ISNULL(A.ysnSubCurrency,0),
		[intAccountId]					=	[dbo].[fnGetItemGLAccount](A.intItemId,D.intItemLocationId, 'AP Clearing'),
		[dblCost]						=	CASE WHEN charges.dblCost > 0 THEN charges.dblCost ELSE ABS((A.dblUnitCost /  ISNULL(A.intSubCurrencyCents,1))) END,
		[dblOldCost]					=	CASE WHEN charges.dblCost != A.dblUnitCost THEN A.dblUnitCost ELSE NULL END,
		[dblNetWeight]					=	0,
		[dblNetShippedWeight]			=	0,
		[dblWeightLoss]					=	0,
		[dblFranchiseWeight]			=	0,
		[intContractDetailId]			=	A.intContractDetailId,
		[intContractHeaderId]			=	A.intContractHeaderId,
		[intQtyToBillUOMId]				=	A.intCostUnitMeasureId,  --CASE WHEN A.intContractDetailId IS NOT NULL THEN cd.intItemUOMId ELSE A.intCostUnitMeasureId END),
		[intCostUOMId]              	=   A.intCostUnitMeasureId,
		[intWeightUOMId]				=	NULL,
		[intLineNo]						=	1,
		[dblWeightUnitQty]				=	1,
		[dblCostUnitQty]				=	1,
		[dblQtyToBillUnitQty]			=	1,
		[intCurrencyId]					=	ISNULL(A.intCurrencyId,0),
		[intStorageLocationId]			=	NULL,
		[int1099Form]					=	CASE 	WHEN patron.intEntityId IS NOT NULL 
														AND A.intItemId > 0
														AND item.ysn1099Box3 = 1
														AND patron.ysnStockStatusQualified = 1 
														THEN 4
													WHEN entity.str1099Form = '1099-MISC' THEN 1
													WHEN entity.str1099Form = '1099-INT' THEN 2
													WHEN entity.str1099Form = '1099-B' THEN 3
											ELSE 0
											END,
		[int1099Category]				=	CASE 	WHEN patron.intEntityId IS NOT NULL 
													AND A.intItemId > 0
													AND item.ysn1099Box3 = 1
													AND patron.ysnStockStatusQualified = 1 
													THEN 3
											ELSE
												ISNULL(H.int1099CategoryId,0)
											END,
		[intScaleTicketId]				=	CASE WHEN IR.intSourceType = 1 THEN A.intScaleTicketId ELSE NULL END,
		[intLocationId]					=	IR.intLocationId,
		[intEntityVendorId]				=   A.intEntityVendorId,
		[intPurchaseTaxGroupId]			= A.intTaxGroupId
	FROM [vyuICChargesForBilling] A
	INNER JOIN @VoucherDetailReceiptCharge charges
		ON A.intInventoryReceiptChargeId = charges.intInventoryReceiptChargeId
	INNER JOIN dbo.tblICInventoryReceipt IR ON IR.intInventoryReceiptId = A.intInventoryReceiptId
	INNER JOIN tblEMEntity entity ON A.intEntityVendorId = entity.intEntityId
	INNER JOIN tblICItem item ON A.intItemId = item.intItemId
	INNER JOIN tblICItemLocation D
		ON A.intLocationId = D.intLocationId AND A.intItemId = D.intItemId
	LEFT JOIN tblSMCurrencyExchangeRate F 
		ON  (F.intFromCurrencyId = @defaultCurrency AND F.intToCurrencyId = A.intCurrencyId) 
	LEFT JOIN dbo.tblSMCurrencyExchangeRateDetail G 
		ON F.intCurrencyExchangeRateId = G.intCurrencyExchangeRateId AND G.dtmValidFromDate = @currentDateFilter
	LEFT JOIN vyuPATEntityPatron patron ON IR.intEntityVendorId = patron.intEntityId
	LEFT JOIN tblAP1099Category H ON entity.str1099Type = H.strCategory
	LEFT JOIN tblCTContractDetail cd ON cd.intContractDetailId = A.intContractDetailId 
	OUTER APPLY
	(
		SELECT TOP 1 ysnCheckoffTax FROM tblICInventoryReceiptChargeTax IRCT
		WHERE IRCT.intInventoryReceiptChargeId = A.intInventoryReceiptChargeId
	)  IRCT
	OUTER APPLY
	(
		SELECT TOP 1 intInventoryReceiptItemId FROM [vyuICChargesForBilling] B
		WHERE B.intInventoryReceiptChargeId = A.intInventoryReceiptChargeId
	) J
	WHERE A.intEntityVendorId = IR.intEntityVendorId

END

BEGIN /* Direct Inventory */
	INSERT INTO @VoucherPayable(
		[intTransactionType]			,
		[intAccountId]					,
		[intItemId]						,
		[strMiscDescription]			,
		[intQtyToBillUOMId]				,
		[dblQuantityToBill]				,
		[dblQtyToBillUnitQty]			,
		[dblOrderQty]					,
		[dblDiscount]					,
		[intCostUOMId]					,
		[dblCost]						,
		[dblCostUnitQty]				,
		[int1099Form]					,
		[int1099Category]				,
		[intLineNo]						,
		[intContractDetailId]			,
		[intContractHeaderId]			,
		[intLoadShipmentDetailId]		,
		[intLoadShipmentId]				,
		[intScaleTicketId]				,
		[intPurchaseTaxGroupId]			,
		--[dblTax]						,
		[intEntityVendorId]				,
		strVendorOrderNumber			,
		strReference					,
		strSourceNumber					,
		intLocationId					,
		intSubLocationId				,
		intStorageLocationId			,
		intItemLocationId				,
		ysnSubCurrency					,
		intCurrencyId
		,ysnStage
		,intTicketDistributionAllocationId
		)
		SELECT
		[intTransactionType]			=	1,
		[intAccountId]					=	dbo.[fnGetItemGLAccount](A.intItemId, loc.intItemLocationId, 'AP Clearing'),
		[intItemId]						=	A.[intItemId],					
		[strMiscDescription]			=	ISNULL(A.strMiscDescription, C.strDescription),
		[intQtyToBillUOMId]				=	ICUOM.intItemUOMId
											-- CASE WHEN ctd.intItemUOMId > 0 
											-- 	THEN ctd.intItemUOMId
											-- 	ELSE A.intUnitOfMeasureId
											-- END,
		
		
		,[dblQuantityToBill]			=	A.dblQtyReceived
		,[dblQtyToBillUnitQty]			=	ISNULL(ICUOM.dblUnitQty,1) --CASE WHEN ctd.intItemUOMId > 0 THEN ctd.dblUnitQty ELSE ISNULL(A.dblUnitQty,1) END,
		,[dblOrderQty]					=	(CASE WHEN lgDetail.dblQuantity IS NULL
												THEN
													A.dblQtyReceived
												ELSE
													lgDetail.dblQuantity 
											END),
		[dblDiscount]					=	A.[dblDiscount],
		[intCostUOMId]					=	A.intCostUOMId --CASE WHEN ctd.intPriceItemUOMId > 0 THEN ctd.intPriceItemUOMId ELSE A.intCostUOMId END,
		,[dblCost]						=	ISNULL(A.dblCost, ISNULL(C.dblReceiveLastCost,0))
											-- dbo.fnCalculateCostBetweenUOM(A.intCostUOMId
											-- 							,CASE WHEN ctd.intPriceItemUOMId > 0 THEN ctd.intPriceItemUOMId ELSE A.intCostUOMId END
											-- 							,ISNULL(A.dblCost, ISNULL(C.dblReceiveLastCost,0))),
		,[dblCostUnitQty]				=	A.dblCostUnitQty, --CASE WHEN ctd.intPriceItemUOMId > 0 THEN ctd.dblCostUnitQty ELSE A.dblCostUnitQty END,
		[int1099Form]					=	(CASE WHEN patron.intEntityId IS NOT NULL 
														AND C.intItemId > 0
														AND C.ysn1099Box3 = 1
														AND patron.ysnStockStatusQualified = 1 
														THEN 4
													WHEN E.str1099Form = '1099-MISC' THEN 1
													WHEN E.str1099Form = '1099-INT' THEN 2
													WHEN E.str1099Form = '1099-B' THEN 3
												ELSE 0 END),
		[int1099Category]				=	CASE 	WHEN patron.intEntityId IS NOT NULL 
														AND C.intItemId > 0
														AND C.ysn1099Box3 = 1
														AND patron.ysnStockStatusQualified = 1 
														THEN 3
											ELSE ISNULL(F.int1099CategoryId, 0) END,
		[intLineNo]						=	ROW_NUMBER() OVER(ORDER BY (SELECT 1)),
		[intContractDetailId]			=	ctd.intContractDetailId,
		[intContractHeaderId]			=	ctd.intContractHeaderId,
		[intLoadDetailId]				=	A.intLoadDetailId,
		[intLoadId]						=	lgDetail.intLoadId,
		[intScaleTicketId]				=	A.[intScaleTicketId],
		[intPurchaseTaxGroupId]			=	A.intTaxGroupId,
		--[dblTax]						=	B.dblTax,
		[intEntityVendorId]				=	SC.intEntityId,
		[strVendorOrderNumber]			=	'TKT-' + SC.strTicketNumber,
		strReference					=	'TKT-' + SC.strTicketNumber,
		strSourceNumber					=	SC.strTicketNumber,
		intLocationId					=	SC.intProcessingLocationId,
		intSubLocationId				=	SC.intSubLocationId,
		intStorageLocationId			=   SC.intStorageLocationId,
		intItemLocationId				=	C.intItemLocationId,
		ysnSubCurrency					=	0,
		intCurrencyId					=	SC.intCurrencyId
		,ysnStage 						= 0
		,intTicketDistributionAllocationId
	FROM @voucherDetailDirect A
	INNER JOIN tblSCTicket SC ON A.intScaleTicketId = SC.intTicketId
	INNER JOIN tblAPVendor D ON SC.intEntityId = D.[intEntityId]
	INNER JOIN tblEMEntity E ON D.[intEntityId] = E.intEntityId
	INNER JOIN tblICItemUOM ICUOM
		ON A.intUnitOfMeasureId = ICUOM.intItemUOMId
	LEFT JOIN vyuCTContractDetailView ctd ON A.intContractDetailId = ctd.intContractDetailId
	LEFT JOIN tblLGLoadDetail lgDetail ON A.intLoadDetailId = lgDetail.intLoadDetailId
	LEFT JOIN vyuICGetItemStock C ON C.intItemId = A.intItemId AND SC.intProcessingLocationId = C.intLocationId
	LEFT JOIN tblICItemLocation loc ON loc.intItemId = A.intItemId AND loc.intLocationId = SC.intProcessingLocationId
	LEFT JOIN vyuPATEntityPatron patron ON SC.intEntityId = patron.intEntityId
	LEFT JOIN tblAP1099Category F ON E.str1099Type = F.strCategory
	
END



BEGIN /* RESULT */
	SELECT	DISTINCT
			[intTransactionType],
			[intItemId],
			[strMiscDescription],
			[intInventoryReceiptItemId],
			[dblQuantityToBill],
			[dblOrderQty],
			[dblExchangeRate],
			[intCurrencyExchangeRateTypeId],
			[ysnSubCurrency],
			[intAccountId],
			[dblCost],
			[dblOldCost],
			[dblNetWeight],
			[dblNetShippedWeight],
			[dblWeightLoss],
			[dblFranchiseWeight],
			[intContractDetailId],
			[intContractHeaderId],
			[intQtyToBillUOMId],
			[intCostUOMId],
			[intWeightUOMId],
			[intLineNo],
			[dblWeightUnitQty],
			[dblCostUnitQty],
			[dblQtyToBillUnitQty],
			[intCurrencyId],
			[intStorageLocationId],
			[int1099Form],
			[int1099Category],
			[intLoadShipmentDetailId],
			[strBillOfLading],
			[intScaleTicketId],
			[intLocationId],			
			[intShipFromId],
			[intShipToId],
			[intInventoryReceiptChargeId],
			[intPurchaseDetailId],
			[intPurchaseTaxGroupId],
			[dblTax],
			[intEntityVendorId],
			[strVendorOrderNumber],
			[intLoadShipmentId],
			[strReference],
			[strSourceNumber],
			[intSubLocationId],
			[intItemLocationId]
			,ysnStage
			,intTicketDistributionAllocationId
	FROM @VoucherPayable
END