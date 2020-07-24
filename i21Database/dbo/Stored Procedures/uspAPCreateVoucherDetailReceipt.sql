CREATE PROCEDURE [dbo].[uspAPCreateVoucherDetailReceipt]
	@voucherId INT,
	@voucherDetailReceipt AS [VoucherDetailReceipt] READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @transCount INT = @@TRANCOUNT;
DECLARE @voucherIds AS Id;
DECLARE @voucherCurrency INT;
DECLARE @voucherVendor INT;
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
DECLARE @detailCreated AS TABLE(intBillDetailId INT, intInventoryReceiptItemId INT)
DECLARE @error NVARCHAR(200);

CREATE TABLE #tempBillDetail (
    [intBillId]       				INT             NOT NULL,
    [intItemId]    					INT             NULL,
	[strMiscDescription]			NVARCHAR (500)  COLLATE Latin1_General_CI_AS NULL,
	[intInventoryReceiptItemId]    	INT             NULL,
	[intInventoryReceiptChargeId]   INT             NULL,
	[intPurchaseDetailId]    		INT             NULL,
	[dblQtyOrdered] 				DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dblQtyReceived] 				DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblRate] 						DECIMAL(18, 6) NOT NULL DEFAULT 1, 
	[intCurrencyExchangeRateTypeId] INT NULL,
	[ysnSubCurrency] 				BIT NOT NULL DEFAULT 0 ,
	[intTaxGroupId] 				INT NULL, 
	[intAccountId]    				INT             NULL ,
	[dblTotal]        				DECIMAL (18, 6) NOT NULL DEFAULT 0,
    [dblCost] 						DECIMAL(38, 20) NOT NULL DEFAULT 0, 
	[dblOldCost] 					DECIMAL(38, 20) NULL, 
	[dblNetWeight] 					DECIMAL(38, 20) NOT NULL DEFAULT 0, 
	[dblNetShippedWeight] 			DECIMAL(38, 20) NOT NULL DEFAULT 0, 
	[dblWeightLoss] 				DECIMAL(38, 20) NOT NULL DEFAULT 0, 
	[dblFranchiseWeight] 			DECIMAL(38, 20) NOT NULL DEFAULT 0, 
	[intContractDetailId]    		INT             NULL,
	[intContractHeaderId]    		INT             NULL,
	[intContractSeq] 		   		INT             NULL,
	[intUnitOfMeasureId]    		INT             NULL ,
	[intCostUOMId]    				INT             NULL ,
	[intWeightUOMId]    			INT             NULL ,
	[intLineNo] 					INT NOT NULL DEFAULT 1,
	[dblWeightUnitQty] 				DECIMAL(38, 20) NOT NULL DEFAULT 0, 
	[dblCostUnitQty] 				DECIMAL(38, 20) NOT NULL DEFAULT 0,
	[dblUnitQty] 					DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[intCurrencyId] 				INT NULL,
	[intSubLocationId]				INT NULL,
	[intStorageLocationId] 			INT             NULL,
    [int1099Form] 					INT NOT NULL DEFAULT 0 , 
    [int1099Category] 				INT NOT NULL DEFAULT 0 , 
	[intLoadDetailId]    			INT             NULL,
	[dbl1099] 						DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[strBillOfLading] 				NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[intScaleTicketId]				INT             NULL,
	[intLocationId]					INT             NULL, 
	/*Start - Bund Item Info*/
	[intItemBundleId]				INT				NULL, --Primary key of tblICItemBundle
	[intBundletUOMId]				INT				NULL,
	[dblQtyBundleReceived]			INT				NULL DEFAULT(0),
	[dblBundleUnitQty]				DECIMAL(38, 20)	NULL DEFAULT(0), 
	[strBundleDescription]			NVARCHAR (500)  COLLATE Latin1_General_CI_AS NULL,
	[dblBundleTotal]				DECIMAL(38, 20)	NULL  DEFAULT(0)
	/*End - Bund Item Info*/
)

-- CREATE TABLE #tempBillDetailTax (
--     [intBillDetailId] 			INT NOT NULL, 
--     [intTaxGroupId] 			INT NOT NULL, 
--     [intTaxCodeId] 				INT NOT NULL, 
--     [intTaxClassId] 			INT NOT NULL, 
-- 	[strTaxableByOtherTaxes] 	NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
--     [strCalculationMethod] 		NVARCHAR(15) COLLATE Latin1_General_CI_AS NULL, 
--     [dblRate] 					NUMERIC(18, 6) NOT NULL DEFAULT 0, 
--     [intAccountId] 				INT NOT NULL, 
--     [dblTax] 					NUMERIC(18, 6) NOT NULL DEFAULT 0, 
--     [dblAdjustedTax] 			NUMERIC(18, 6) NOT NULL, 
-- 	[ysnTaxAdjusted] 			BIT NOT NULL DEFAULT 0, 
-- 	[ysnSeparateOnBill] 		BIT NOT NULL DEFAULT 0, 
-- 	[ysnCheckOffTax] 			BIT NOT NULL DEFAULT 0
-- )

EXEC uspAPValidateVoucherDetailReceiptPO @voucherId, @voucherDetailReceipt

SELECT TOP 1
	@voucherCurrency = voucher.intCurrencyId
	,@voucherVendor = voucher.intEntityVendorId
FROM tblAPBill voucher
WHERE voucher.intBillId = @voucherId

--Filter the records per currency
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
	[dblQtyReceived]				=	(CASE WHEN A.dblQtyReceived IS NULL --OR
														--A.dblQtyReceived > (B.dblOpenReceive - B.dblBillQty) --handle over paying -- commented as per Erick. 
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
										-- CAST((CASE WHEN contractDetail.dblCashPrice > 0 
										-- 				THEN contractDetail.dblCashPrice
										-- 				ELSE 
										-- 					(CASE WHEN receiptItem.dblUnitCost = 0 AND contractDetail.dblCashPrice > 0
										-- 						THEN contractDetail.dblCashPrice
										-- 						ELSE receiptItem.dblUnitCost
										-- 						END)
										-- 			END) 
										-- 		/ ISNULL(C.intSubCurrencyCents,1)  
										-- 		* (((CASE WHEN A.dblQtyReceived IS NULL OR
										-- 				A.dblQtyReceived > (B.dblOpenReceive - B.dblBillQty) --handle over paying
										-- 				THEN B.dblOpenReceive - receiptItem.dblBillQty
										-- 				ELSE A.dblQtyReceived END))
										-- 			 * (ItemUOM.dblUnitQty/ ISNULL(NULLIF(ItemWeightUOM.dblUnitQty,0) ,1))) 
										-- 			 * ISNULL(NULLIF(ItemWeightUOM.dblUnitQty,0),1) / ISNULL(NULLIF(voucherDetailReceipt.dblCostUnitQty,0),1) 
										-- 	AS DECIMAL(18,2)),
	[dblNetWeight]					=	0,
	[intCostUOMId]					=	CASE WHEN contractDetail.intContractDetailId IS NOT NULL 
											THEN contractDetail.intPriceItemUOMId
											ELSE B.intCostUOMId END,
	[intTaxGroupId]					=	A.intTaxGroupId,
	[int1099Form]					=	CASE 	WHEN item.intItemId > 0 AND item.intCommodityId > 0 THEN 0
												WHEN patron.intEntityId IS NOT NULL 
													AND B.intItemId > 0
													AND item.ysn1099Box3 = 1
													AND patron.ysnStockStatusQualified = 1 
													THEN 4
												WHEN entity.str1099Form = '1099-MISC' THEN 1
												WHEN entity.str1099Form = '1099-INT' THEN 2
												WHEN entity.str1099Form = '1099-B' THEN 3
										ELSE 0
										END,
	[int1099Category]				=	CASE 	WHEN item.intItemId > 0 AND item.intCommodityId > 0 THEN 0
												WHEN patron.intEntityId IS NOT NULL 
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
FROM @voucherDetailReceipt A
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
-- LEFT JOIN (tblCTContractHeader contractHeader INNER JOIN tblCTContractDetail contractDetail 
-- 				ON contractHeader.intContractHeaderId = contractDetail.intContractHeaderId) 
-- 				ON contractHeader.intContractHeaderId = B.intOrderId 
-- 				AND contractDetail.intContractDetailId = B.intLineNo
LEFT JOIN tblICItemUOM ContractItemCostUOM ON ContractItemCostUOM.intItemUOMId = contractDetail.intPriceItemUOMId
LEFT JOIN tblAP1099Category F ON entity.str1099Type = F.strCategory
WHERE C.intCurrencyId = @voucherCurrency --RETURN AND RECEIPT

-- --update quantity and cost to use
-- UPDATE voucherDetailReceipt
-- 	SET voucherDetailReceipt.dblCost = CASE WHEN contractDetail.dblCashPrice > 0 
-- 														THEN contractDetail.dblCashPrice
-- 														ELSE 
-- 															(CASE WHEN receiptItem.dblUnitCost = 0 AND contractDetail.dblCashPrice > 0
-- 																THEN contractDetail.dblCashPrice
-- 																ELSE receiptItem.dblUnitCost
-- 																END)
-- 													END --use cash price of contract if unit cost of receipt item is 0
-- 	,voucherDetailReceipt.dblQtyReceived = (CASE WHEN voucherDetailReceipt.dblQtyReceived IS NULL OR
-- 														voucherDetailReceipt.dblQtyReceived > (receiptItem.dblOpenReceive - receiptItem.dblBillQty) --handle over paying
-- 												THEN receiptItem.dblOpenReceive - receiptItem.dblBillQty
-- 												ELSE voucherDetailReceipt.dblQtyReceived END)
-- FROM @receiptItems voucherDetailReceipt
-- INNER JOIN tblICInventoryReceiptItem receiptItem 
-- 	ON voucherDetailReceipt.intInventoryReceiptItemId = receiptItem.intInventoryReceiptItemId
-- LEFT JOIN (tblCTContractHeader contractHeader INNER JOIN tblCTContractDetail contractDetail 
-- 				ON contractHeader.intContractHeaderId = contractDetail.intContractHeaderId) 
-- 				ON contractHeader.intContractHeaderId = receiptItem.intOrderId 
-- 				AND contractDetail.intContractDetailId = receiptItem.intLineNo

IF @transCount = 0 BEGIN TRANSACTION

	--DIRECT
	IF EXISTS(SELECT TOP 1 1 FROM @receiptItems WHERE intInventoryReceiptType = 1)
	BEGIN
		INSERT INTO #tempBillDetail(
			[intBillId],
			[intItemId],
			[strMiscDescription],
			[intInventoryReceiptItemId],
			[dblQtyOrdered],
			[dblQtyReceived],
			[dblRate],
			[intCurrencyExchangeRateTypeId],
			[ysnSubCurrency],
			[intTaxGroupId],
			[intAccountId],
			[dblTotal],
			[dblCost],
			[dblOldCost],
			[dblNetWeight],
			[dblWeightLoss],
			[intUnitOfMeasureId],
			[intCostUOMId],
			[intWeightUOMId],
			[intLineNo],
			[dblWeightUnitQty],
			[dblCostUnitQty],
			[dblUnitQty],
			[intCurrencyId],
			[intSubLocationId],
			[intStorageLocationId],
			[int1099Form],
			[int1099Category],
			[strBillOfLading],
			[intScaleTicketId],
			[intLocationId],
			[intItemBundleId],
			[intBundletUOMId],
			[dblQtyBundleReceived],
			[dblBundleUnitQty],
			[strBundleDescription],
			[dblBundleTotal]
		)
		SELECT 
			[intBillId]						=	@voucherId,
			[intItemId]						=	B.intItemId,
			[strMiscDescription]			=	C.strDescription,
			[intInventoryReceiptItemId]		=	B.intInventoryReceiptItemId,
			[dblQtyOrdered]					=	voucherDetailReceipt.dblQtyReceived,
			[dblQtyReceived]				=	voucherDetailReceipt.dblQtyReceived,
			[dblRate]						=	ISNULL(NULLIF(B.dblForexRate,0),1),
			[intCurrencyExchangeRateTypeId]	=	B.intForexRateTypeId,
			[ysnSubCurrency]				=	CASE WHEN B.ysnSubCurrency > 0 THEN 1 ELSE 0 END,
			[intTaxGroupId]					=	B.intTaxGroupId,
			[intAccountId]					=	[dbo].[fnGetItemGLAccount](B.intItemId, D.intItemLocationId, 'AP Clearing'),
			[dblTotal]						=	ISNULL((CASE WHEN B.ysnSubCurrency > 0 --CHECK IF SUB-CURRENCY
												THEN (CASE WHEN B.intWeightUOMId > 0 
														THEN CAST(voucherDetailReceipt.dblCost / ISNULL(A.intSubCurrencyCents,1)  
																	* (B.dblNet * (ItemUOM.dblUnitQty/ ISNULL(ItemWeightUOM.dblUnitQty ,1))) 
																	* ItemWeightUOM.dblUnitQty / ISNULL(voucherDetailReceipt.dblCostUnitQty,1) 
															AS DECIMAL(18,2)) --Formula With Weight UOM
														WHEN (B.intUnitMeasureId > 0 AND B.intCostUOMId > 0)
														THEN CAST(voucherDetailReceipt.dblQtyReceived
																	* 
																	(voucherDetailReceipt.dblCost / ISNULL(A.intSubCurrencyCents,1)) 
																	*  
																	(ItemUOM.dblUnitQty/ ISNULL(voucherDetailReceipt.dblCostUnitQty,1)) 
															AS DECIMAL(18,2))  --Formula With Receipt UOM and Cost UOM
														ELSE CAST(voucherDetailReceipt.dblQtyReceived
																	* 
																	(voucherDetailReceipt.dblCost / ISNULL(A.intSubCurrencyCents,1))  AS DECIMAL(18,2))  --Orig Calculation
													END) 
												ELSE (CASE WHEN B.intWeightUOMId > 0
														THEN CAST(voucherDetailReceipt.dblCost 
																	* (B.dblNet * (ItemUOM.dblUnitQty/ ISNULL(ItemWeightUOM.dblUnitQty ,1)))
																	* ItemWeightUOM.dblUnitQty / ISNULL(voucherDetailReceipt.dblCostUnitQty,1) AS DECIMAL(18,2)) --Formula With Weight UOM
														WHEN (B.intUnitMeasureId > 0  AND B.intCostUOMId > 0)
														THEN CAST(voucherDetailReceipt.dblQtyReceived
																	* voucherDetailReceipt.dblCost * (ItemUOM.dblUnitQty/ ISNULL(voucherDetailReceipt.dblCostUnitQty,1))  
															AS DECIMAL(18,2))  --Formula With Receipt UOM and Cost UOM
														ELSE CAST(voucherDetailReceipt.dblQtyReceived
																	* voucherDetailReceipt.dblCost
																AS DECIMAL(18,2))  --Orig Calculation
													END)
												END),0),
			[dblCost]						=	voucherDetailReceipt.dblCost, --voucherDetailReceipt.dblCost,
			[dblOldCost]					=	NULL,
			[dblNetWeight]					=	CASE WHEN B.intWeightUOMId > 0 THEN  
													(CASE WHEN B.dblBillQty > 0 
															THEN voucherDetailReceipt.dblQtyReceived * (ItemUOM.dblUnitQty/ ISNULL(ItemWeightUOM.dblUnitQty ,1)) --THIS IS FOR PARTIAL
														ELSE B.dblNet --THIS IS FOR NO RECEIVED QTY YET BUT HAS NET WEIGHT DIFFERENT FROM GROSS
													END)
											ELSE 0 END,
			[dblWeightLoss]					=	ISNULL(B.dblGross - B.dblNet,0),
			[intUnitOfMeasureId]			=	B.intUnitMeasureId,
			[intCostUOMId]					=	voucherDetailReceipt.intCostUOMId,
			[intWeightUOMId]				=	B.intWeightUOMId,
			[intLineNo]						=	ISNULL(B.intSort,0),
			[dblWeightUnitQty]				=	ISNULL(ItemWeightUOM.dblUnitQty,0),
			[dblCostUnitQty]				=	voucherDetailReceipt.dblCostUnitQty,
			[dblUnitQty]					=	ABS(ISNULL(ItemUOM.dblUnitQty,0)),
			[intCurrencyId]					=	CASE WHEN B.ysnSubCurrency > 0 THEN ISNULL(SubCurrency.intCurrencyID,0)
												ELSE ISNULL(A.intCurrencyId,0) END,
			[intSubLocationId]				=	B.intSubLocationId,
			[intStorageLocationId]			=   B.intStorageLocationId,
			[int1099Form]					=	voucherDetailReceipt.int1099Form,
			[int1099Category]				=	voucherDetailReceipt.int1099Category,
			[strBillOfLading]				= 	A.strBillOfLading,
			[intScaleTicketId]				=	CASE WHEN A.intSourceType = 1 THEN B.intSourceId ELSE NULL END,
			[intLocationId]					=	A.intLocationId,
			[intItemBundleId]				=	voucherDetailReceipt.intItemBundleId,
			[intBundletUOMId]				=	voucherDetailReceipt.intBundletUOMId,
			[dblQtyBundleReceived]			=	voucherDetailReceipt.dblQtyBundleReceived,
			[dblBundleUnitQty]				=	voucherDetailReceipt.dblBundleUnitQty,
			[strBundleDescription]			=	voucherDetailReceipt.strBundleDescription,
			[dblBundleTotal]				=	voucherDetailReceipt.dblBundleTotal
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

	--PURCHASE CONTRACT
	IF EXISTS(SELECT TOP 1 1 FROM @receiptItems WHERE intInventoryReceiptType = 2)
	BEGIN
		INSERT INTO #tempBillDetail(
			[intBillId],
			[intItemId],
			[strMiscDescription],
			[intInventoryReceiptItemId],
			[dblQtyOrdered],
			[dblQtyReceived],
			[dblRate],
			[intCurrencyExchangeRateTypeId],
			[ysnSubCurrency],
			[intTaxGroupId],
			[intAccountId],
			[dblTotal],
			[dblCost],
			[dblOldCost],
			[dblNetWeight],
			[dblNetShippedWeight],
			[dblWeightLoss],
			[dblFranchiseWeight],
			[intContractDetailId],
			[intContractHeaderId],
			[intContractSeq],
			[intUnitOfMeasureId],
			[intCostUOMId],
			[intWeightUOMId],
			[intLineNo],
			[dblWeightUnitQty],
			[dblCostUnitQty],
			[dblUnitQty],
			[intCurrencyId],
			[intSubLocationId],
			[intStorageLocationId],
			[int1099Form],
			[int1099Category],
			[intLoadDetailId],
			[strBillOfLading],
			[intScaleTicketId],
			[intLocationId],
			[intItemBundleId],
			[intBundletUOMId],
			[dblQtyBundleReceived],
			[dblBundleUnitQty],
			[strBundleDescription],
			[dblBundleTotal]
		)
		SELECT 
			[intBillId]					=	@voucherId,
			[intItemId]					=	B.intItemId,
			[strMiscDescription]		=	C.strDescription,
			[intInventoryReceiptItemId]	=	B.intInventoryReceiptItemId,
			[dblQtyOrdered]				=	ISNULL(voucherDetailReceipt.dblQtyReceived, ABS(B.dblOpenReceive - B.dblBillQty)),
			[dblQtyReceived]			=	ISNULL(voucherDetailReceipt.dblQtyReceived, ABS(B.dblOpenReceive - B.dblBillQty)),
			[dblForexRate]				=	ISNULL(NULLIF(B.dblForexRate,0),1),
			[intForexRateTypeId]		=	B.intForexRateTypeId,
			[ysnSubCurrency]			=	CASE WHEN B.ysnSubCurrency > 0 THEN 1 ELSE 0 END,
			[intTaxGroupId]				=	B.intTaxGroupId,
			[intAccountId]				=	[dbo].[fnGetItemGLAccount](B.intItemId, D.intItemLocationId, 'AP Clearing'),
			[dblTotal]						=	ISNULL((CASE WHEN B.ysnSubCurrency > 0 --CHECK IF SUB-CURRENCY
												THEN (CASE WHEN B.intWeightUOMId > 0 
														THEN CAST(voucherDetailReceipt.dblCost / ISNULL(A.intSubCurrencyCents,1)  
																	* (B.dblNet * (ItemUOM.dblUnitQty/ ISNULL(ItemWeightUOM.dblUnitQty ,1))) 
																	* ItemWeightUOM.dblUnitQty / ISNULL(voucherDetailReceipt.dblCostUnitQty,1) 
															AS DECIMAL(18,2)) --Formula With Weight UOM
														WHEN (B.intUnitMeasureId > 0 AND B.intCostUOMId > 0)
														THEN CAST(voucherDetailReceipt.dblQtyReceived
																	* 
																	(voucherDetailReceipt.dblCost / ISNULL(A.intSubCurrencyCents,1)) 
																	*  
																	(ItemUOM.dblUnitQty/ ISNULL(voucherDetailReceipt.dblCostUnitQty,1)) 
															AS DECIMAL(18,2))  --Formula With Receipt UOM and Cost UOM
														ELSE CAST(voucherDetailReceipt.dblQtyReceived
																	* 
																	(voucherDetailReceipt.dblCost / ISNULL(A.intSubCurrencyCents,1))  AS DECIMAL(18,2))  --Orig Calculation
													END) 
												ELSE (CASE WHEN B.intWeightUOMId > 0
														THEN CAST(voucherDetailReceipt.dblCost 
																	* (B.dblNet * (ItemUOM.dblUnitQty/ ISNULL(ItemWeightUOM.dblUnitQty ,1)))   
																	* ItemWeightUOM.dblUnitQty / ISNULL(voucherDetailReceipt.dblCostUnitQty,1) AS DECIMAL(18,2)) --Formula With Weight UOM
														WHEN (B.intUnitMeasureId > 0  AND B.intCostUOMId > 0)
														THEN CAST(voucherDetailReceipt.dblQtyReceived
																	* voucherDetailReceipt.dblCost * (ItemUOM.dblUnitQty/ ISNULL(voucherDetailReceipt.dblCostUnitQty,1))  
															AS DECIMAL(18,2))  --Formula With Receipt UOM and Cost UOM
														ELSE CAST(voucherDetailReceipt.dblQtyReceived
																	* voucherDetailReceipt.dblCost
																AS DECIMAL(18,2))  --Orig Calculation
													END)
												END),0),
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
			[intContractSeq]			=	E1.intContractSeq,
			[intUnitOfMeasureId]		=	voucherDetailReceipt.intUnitOfMeasureId,
			[intCostUOMId]				=	voucherDetailReceipt.intCostUOMId,
			[intWeightUOMId]			=	B.intWeightUOMId,
			[intLineNo]					=	ISNULL(B.intSort,0),
			[dblWeightUnitQty]			=	ISNULL(ItemWeightUOM.dblUnitQty,0),
			[dblCostUnitQty]			=	ABS(ISNULL(voucherDetailReceipt.dblCostUnitQty,0)),
			[dblUnitQty]				=	voucherDetailReceipt.dblUnitQty,
			[intCurrencyId]				=	CASE WHEN B.ysnSubCurrency > 0 THEN ISNULL(SubCurrency.intCurrencyID,0)
											ELSE ISNULL(A.intCurrencyId,0) END,
			[intSubLocationId]			=	B.intSubLocationId,
			[intStorageLocationId]		=   B.intStorageLocationId,
			[int1099Form]				=	voucherDetailReceipt.int1099Form,
			[int1099Category]			=	voucherDetailReceipt.int1099Category,
			[intLoadDetailId]			=	CASE WHEN A.strReceiptType = 'Purchase Contract' AND A.intSourceType = 2 THEN B.intSourceId ELSE NULL END,
			[strBillOfLading]			= 	A.strBillOfLading,
			[intScaleTicketId]			=	CASE WHEN A.intSourceType = 1 THEN B.intSourceId ELSE NULL END,
			[intLocationId]				=	A.intLocationId,
			[intItemBundleId]			=	voucherDetailReceipt.intItemBundleId,
			[intBundletUOMId]			=	voucherDetailReceipt.intBundletUOMId,
			[dblQtyBundleReceived]		=	voucherDetailReceipt.dblQtyBundleReceived,
			[dblBundleUnitQty]			=	voucherDetailReceipt.dblBundleUnitQty,
			[strBundleDescription]		=	voucherDetailReceipt.strBundleDescription,
			[dblBundleTotal]			=	voucherDetailReceipt.dblBundleTotal
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

	--PURCHASE ORDER
	IF EXISTS(SELECT TOP 1 1 FROM @receiptItems WHERE intInventoryReceiptType = 3)
	BEGIN
		INSERT INTO #tempBillDetail(
			[intBillId],
			[intItemId],
			[strMiscDescription],
			[intInventoryReceiptItemId],
			[intPurchaseDetailId],
			[dblQtyOrdered],
			[dblQtyReceived],
			[dblRate],
			[intCurrencyExchangeRateTypeId],
			[ysnSubCurrency],
			[intTaxGroupId],
			[intAccountId],
			[dblTotal],
			[dblCost],
			[dblOldCost],
			[dblNetWeight],
			[dblNetShippedWeight],
			[dblWeightLoss],
			[dblFranchiseWeight],
			[intContractDetailId],
			[intContractHeaderId],
			[intContractSeq],
			[intUnitOfMeasureId],
			[intCostUOMId],
			[intWeightUOMId],
			[intLineNo],
			[dblWeightUnitQty],
			[dblCostUnitQty],
			[dblUnitQty],
			[intCurrencyId],
			[intSubLocationId],
			[intStorageLocationId],
			[int1099Form],
			[int1099Category],
			[intLoadDetailId],
			[strBillOfLading],
			[intItemBundleId],
			[intBundletUOMId],
			[dblQtyBundleReceived],
			[dblBundleUnitQty],
			[strBundleDescription],
			[dblBundleTotal]
		)
		SELECT 
			[intBillId]					=	@voucherId,
			[intItemId]					=	B.intItemId,
			[strMiscDescription]		=	C.strDescription,
			[intInventoryReceiptItemId]	=	B.intInventoryReceiptItemId,
			[intPODetailId]				=	(CASE WHEN B.intLineNo <= 0 THEN NULL ELSE B.intLineNo END),
			[dblQtyOrdered]				=	ISNULL(voucherDetailReceipt.dblQtyReceived, ABS(B.dblOpenReceive - B.dblBillQty)),
			[dblQtyReceived]			=	ISNULL(voucherDetailReceipt.dblQtyReceived, ABS(B.dblOpenReceive - B.dblBillQty)),
			[dblForexRate]				=	ISNULL(NULLIF(B.dblForexRate,0),1),
			[intForexRateTypeId]		=	B.intForexRateTypeId,
			[ysnSubCurrency]			=	CASE WHEN B.ysnSubCurrency > 0 THEN 1 ELSE 0 END,
			[intTaxGroupId]				=	B.intTaxGroupId,
			[intAccountId]				=	[dbo].[fnGetItemGLAccount](B.intItemId, D.intItemLocationId, 'AP Clearing'),
			[dblTotal]						=	ISNULL((CASE WHEN B.ysnSubCurrency > 0 --CHECK IF SUB-CURRENCY
												THEN (CASE WHEN B.intWeightUOMId > 0 
														THEN CAST(voucherDetailReceipt.dblCost / ISNULL(A.intSubCurrencyCents,1)  
																	* (B.dblNet * (ItemUOM.dblUnitQty/ ISNULL(ItemWeightUOM.dblUnitQty ,1))) 
																	* ItemWeightUOM.dblUnitQty / ISNULL(voucherDetailReceipt.dblCostUnitQty,1) 
															AS DECIMAL(18,2)) --Formula With Weight UOM
														WHEN (B.intUnitMeasureId > 0 AND B.intCostUOMId > 0)
														THEN CAST(voucherDetailReceipt.dblQtyReceived
																	* 
																	(voucherDetailReceipt.dblCost / ISNULL(A.intSubCurrencyCents,1)) 
																	*  
																	(ItemUOM.dblUnitQty/ ISNULL(voucherDetailReceipt.dblCostUnitQty,1)) 
															AS DECIMAL(18,2))  --Formula With Receipt UOM and Cost UOM
														ELSE CAST(voucherDetailReceipt.dblQtyReceived
																	* 
																	(voucherDetailReceipt.dblCost / ISNULL(A.intSubCurrencyCents,1))  AS DECIMAL(18,2))  --Orig Calculation
													END) 
												ELSE (CASE WHEN B.intWeightUOMId > 0
														THEN CAST(voucherDetailReceipt.dblCost 
																	* (B.dblNet * (ItemUOM.dblUnitQty/ ISNULL(ItemWeightUOM.dblUnitQty ,1)))   
																	* ItemWeightUOM.dblUnitQty / ISNULL(voucherDetailReceipt.dblCostUnitQty,1) AS DECIMAL(18,2)) --Formula With Weight UOM
														WHEN (B.intUnitMeasureId > 0  AND B.intCostUOMId > 0)
														THEN CAST(voucherDetailReceipt.dblQtyReceived
																	* voucherDetailReceipt.dblCost * (ItemUOM.dblUnitQty/ ISNULL(voucherDetailReceipt.dblCostUnitQty,1))  
															AS DECIMAL(18,2))  --Formula With Receipt UOM and Cost UOM
														ELSE CAST(voucherDetailReceipt.dblQtyReceived
																	* voucherDetailReceipt.dblCost
																AS DECIMAL(18,2))  --Orig Calculation
													END)
												END),0),
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
			[intContractDetailId]		=	POContractItems.intContractDetailId,
			[intContractHeaderId]		=	POContractItems.intContractHeaderId,
			[intContractSeq]			=	E1.intContractSeq,
			[intUnitOfMeasureId]		=	B.intUnitMeasureId,
			[intCostUOMId]				=	B.intCostUOMId,
			[intWeightUOMId]			=	B.intWeightUOMId,
			[intLineNo]					=	ISNULL(B.intSort,0),
			[dblWeightUnitQty]			=	ISNULL(ItemWeightUOM.dblUnitQty,0),
			[dblCostUnitQty]			=	voucherDetailReceipt.dblCostUnitQty,
			[dblUnitQty]				=	ABS(ISNULL(ItemUOM.dblUnitQty,0)),
			[intCurrencyId]				=	CASE WHEN B.ysnSubCurrency > 0 THEN ISNULL(SubCurrency.intCurrencyID,0)
											ELSE ISNULL(A.intCurrencyId,0) END,
			[intSubLocationId]			=	B.intSubLocationId,
			[intStorageLocationId]		=   B.intStorageLocationId,
			[int1099Form]				=	voucherDetailReceipt.int1099Form,
			[int1099Category]			=	voucherDetailReceipt.int1099Category,
			[intLoadDetailId]			=	B.intSourceId,
			[strBillOfLading]			= 	A.strBillOfLading,
			[intItemBundleId]			=	voucherDetailReceipt.intItemBundleId,
			[intBundletUOMId]			=	voucherDetailReceipt.intBundletUOMId,
			[dblQtyBundleReceived]		=	voucherDetailReceipt.dblQtyBundleReceived,
			[dblBundleUnitQty]			=	voucherDetailReceipt.dblBundleUnitQty,
			[strBundleDescription]		=	voucherDetailReceipt.strBundleDescription,
			[dblBundleTotal]			=	voucherDetailReceipt.dblBundleTotal
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
			ON E.intEntityId = A.intEntityVendorId 
					AND E.intContractHeaderId = B.intOrderId 
					AND E1.intContractDetailId = B.intLineNo
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
		LEFT JOIN tblCTWeightGrade J ON E.intWeightId = J.intWeightGradeId
		INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.intEntityId = D2.intEntityId) ON D1.intEntityId = A.intEntityVendorId
		LEFT JOIN tblCTWeightGrade W ON E.intWeightId = W.intWeightGradeId
		LEFT JOIN tblLGLoadContainer loads ON loads.intLoadContainerId = B.intContainerId
		LEFT JOIN vyuPATEntityPatron patron ON A.intEntityVendorId = patron.intEntityId
		OUTER APPLY (
			SELECT
				PODetails.intContractDetailId
				,PODetails.intContractHeaderId
			FROM tblPOPurchaseDetail PODetails
			WHERE intPurchaseDetailId = B.intLineNo
		) POContractItems
		WHERE A.ysnPosted = 1 AND voucherDetailReceipt.intInventoryReceiptType = 3
	END
  
  --INVENTORY RETURN 
	IF EXISTS(SELECT TOP 1 1 FROM @receiptItems WHERE intInventoryReceiptType = 4)
	BEGIN
		INSERT INTO #tempBillDetail(
			[intBillId],
			[intItemId],
			[strMiscDescription],
			[intInventoryReceiptItemId],
			[dblQtyOrdered],
			[dblQtyReceived],
			[dblRate],
			[intCurrencyExchangeRateTypeId],
			[ysnSubCurrency],
			[intTaxGroupId],
			[intAccountId],
			[dblTotal],
			[dblCost],
			[dblOldCost],
			[dblNetWeight],
			[dblNetShippedWeight],
			[dblWeightLoss],
			[dblFranchiseWeight],
			[intContractDetailId],
			[intContractHeaderId],
			[intContractSeq],
			[intUnitOfMeasureId],
			[intCostUOMId],
			[intWeightUOMId],
			[intLineNo],
			[dblWeightUnitQty],
			[dblCostUnitQty],
			[dblUnitQty],
			[intCurrencyId],
			[intSubLocationId],
			[intStorageLocationId],
			[int1099Form],
			[int1099Category],
			[intLoadDetailId],
			[strBillOfLading],
			[intScaleTicketId],
			[intLocationId],
			[intItemBundleId],
			[intBundletUOMId],
			[dblQtyBundleReceived],
			[dblBundleUnitQty],
			[strBundleDescription],
			[dblBundleTotal]
		)
		SELECT 
			[intBillId]					=	@voucherId,
			[intItemId]					=	B.intItemId,
			[strMiscDescription]		=	C.strDescription,
			[intInventoryReceiptItemId]	=	B.intInventoryReceiptItemId,
			[dblQtyOrdered]				=	ISNULL(voucherDetailReceipt.dblQtyReceived, ABS(B.dblOpenReceive - B.dblBillQty)),
			[dblQtyReceived]			=	ISNULL(voucherDetailReceipt.dblQtyReceived, ABS(B.dblOpenReceive - B.dblBillQty)),
			[dblForexRate]				=	ISNULL(NULLIF(B.dblForexRate,0),1),
			[intForexRateTypeId]		=	B.intForexRateTypeId,
			[ysnSubCurrency]			=	CASE WHEN B.ysnSubCurrency > 0 THEN 1 ELSE 0 END,
			[intTaxGroupId]				=	B.intTaxGroupId,
			[intAccountId]				=	[dbo].[fnGetItemGLAccount](B.intItemId, D.intItemLocationId, 'AP Clearing'),
			[dblTotal]						=	ISNULL((CASE WHEN B.ysnSubCurrency > 0 --CHECK IF SUB-CURRENCY
												THEN (CASE WHEN B.intWeightUOMId > 0 
														THEN CAST(voucherDetailReceipt.dblCost / ISNULL(A.intSubCurrencyCents,1)  
																	* (B.dblNet * (ItemUOM.dblUnitQty/ ISNULL(ItemWeightUOM.dblUnitQty ,1))) 
																	* ItemWeightUOM.dblUnitQty / ISNULL(voucherDetailReceipt.dblCostUnitQty,1) 
															AS DECIMAL(18,2)) --Formula With Weight UOM
														WHEN (B.intUnitMeasureId > 0 AND B.intCostUOMId > 0)
														THEN CAST(voucherDetailReceipt.dblQtyReceived
																	* 
																	(voucherDetailReceipt.dblCost / ISNULL(A.intSubCurrencyCents,1)) 
																	*  
																	(ItemUOM.dblUnitQty/ ISNULL(voucherDetailReceipt.dblCostUnitQty,1)) 
															AS DECIMAL(18,2))  --Formula With Receipt UOM and Cost UOM
														ELSE CAST(voucherDetailReceipt.dblQtyReceived
																	* 
																	(voucherDetailReceipt.dblCost / ISNULL(A.intSubCurrencyCents,1))  AS DECIMAL(18,2))  --Orig Calculation
													END) 
												ELSE (CASE WHEN B.intWeightUOMId > 0
														THEN CAST(voucherDetailReceipt.dblCost 
																	* (B.dblNet * (ItemUOM.dblUnitQty/ ISNULL(ItemWeightUOM.dblUnitQty ,1)))   
																	* ItemWeightUOM.dblUnitQty / ISNULL(voucherDetailReceipt.dblCostUnitQty,1) AS DECIMAL(18,2)) --Formula With Weight UOM
														WHEN (B.intUnitMeasureId > 0  AND B.intCostUOMId > 0)
														THEN CAST(voucherDetailReceipt.dblQtyReceived
																	* voucherDetailReceipt.dblCost * (ItemUOM.dblUnitQty/ ISNULL(voucherDetailReceipt.dblCostUnitQty,1))  
															AS DECIMAL(18,2))  --Formula With Receipt UOM and Cost UOM
														ELSE CAST(voucherDetailReceipt.dblQtyReceived
																	* voucherDetailReceipt.dblCost
																AS DECIMAL(18,2))  --Orig Calculation
													END)
												END),0),
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
			[intContractDetailId]		=	CASE WHEN ((A.strReceiptType = 'Purchase Contract') OR
															( A.strReceiptType = 'Inventory Return'))
															THEN E1.intContractDetailId 
												ELSE NULL END,
			[intContractHeaderId]		=	CASE WHEN ((A.strReceiptType = 'Purchase Contract') OR
															( A.strReceiptType = 'Inventory Return' ))
															THEN E.intContractHeaderId 
												ELSE NULL END,
			[intContractSeq]			=	E1.intContractSeq,
			[intUnitOfMeasureId]		=	B.intUnitMeasureId,
			[intCostUOMId]				=	B.intCostUOMId,
			[intWeightUOMId]			=	B.intWeightUOMId,
			[intLineNo]					=	ISNULL(B.intSort,0),
			[dblWeightUnitQty]			=	ISNULL(ItemWeightUOM.dblUnitQty,0),
			[dblCostUnitQty]			=	ABS(ISNULL(voucherDetailReceipt.dblCostUnitQty,0)),
			[dblUnitQty]				=	ABS(ISNULL(ItemUOM.dblUnitQty,0)),
			[intCurrencyId]				=	CASE WHEN B.ysnSubCurrency > 0 THEN ISNULL(SubCurrency.intCurrencyID,0)
											ELSE ISNULL(A.intCurrencyId,0) END,
			[intSubLocationId]			=	B.intSubLocationId,
			[intStorageLocationId]		=   B.intStorageLocationId,
			[int1099Form]				=	voucherDetailReceipt.int1099Form,
			[int1099Category]			=	voucherDetailReceipt.int1099Category,
			[intLoadDetailId]			=	CASE WHEN A.strReceiptType = 'Purchase Contract' AND A.intSourceType = 2 THEN B.intSourceId ELSE NULL END,
			[strBillOfLading]			= 	A.strBillOfLading,
			[intScaleTicketId]			=	CASE WHEN A.intSourceType = 1 THEN B.intSourceId ELSE NULL END,
			[intLocationId]				=	A.intLocationId,
			[intItemBundleId]			=	voucherDetailReceipt.intItemBundleId,
			[intBundletUOMId]			=	voucherDetailReceipt.intBundletUOMId,
			[dblQtyBundleReceived]		=	voucherDetailReceipt.dblQtyBundleReceived,
			[dblBundleUnitQty]			=	voucherDetailReceipt.dblBundleUnitQty,
			[strBundleDescription]		=	voucherDetailReceipt.strBundleDescription,
			[dblBundleTotal]			=	voucherDetailReceipt.dblBundleTotal
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
			ON E.intEntityId = A.intEntityVendorId 
					AND E.intContractHeaderId = B.intOrderId 
					AND E1.intContractDetailId = B.intLineNo
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
		LEFT JOIN tblCTWeightGrade J ON E.intWeightId = J.intWeightGradeId
		INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.intEntityId = D2.intEntityId) ON D1.intEntityId = A.intEntityVendorId
		LEFT JOIN tblCTWeightGrade W ON E.intWeightId = W.intWeightGradeId
		LEFT JOIN tblLGLoadContainer loads ON loads.intLoadContainerId = B.intContainerId
		LEFT JOIN vyuSCGetScaleDistribution SD ON SD.intInventoryReceiptItemId = B.intInventoryReceiptItemId
		WHERE A.ysnPosted = 1 AND voucherDetailReceipt.intInventoryReceiptType = 4
	END  

	INSERT INTO tblAPBillDetail(
		[intBillId],
		[intItemId],
		[strMiscDescription],
		[intInventoryReceiptItemId],
		[intInventoryReceiptChargeId],
		[intPurchaseDetailId],
		[dblQtyOrdered],
		[dblQtyReceived],
		[dblRate],
		[intCurrencyExchangeRateTypeId],
		[ysnSubCurrency],
		[intTaxGroupId],
		[intAccountId],
		[dblTotal],
		[dblCost],
		[dblNetWeight],
		[dblNetShippedWeight],
		[dblWeightLoss],
		[dblFranchiseWeight],
		[intContractDetailId],
		[intContractHeaderId],
		[intContractSeq],
		[intUnitOfMeasureId],
		[intCostUOMId],
		[intWeightUOMId],
		[intLineNo],
		[dblWeightUnitQty],
		[dblCostUnitQty],
		[dblUnitQty],
		[intCurrencyId],
		[intSubLocationId],
		[intStorageLocationId],
		[int1099Form],
		[int1099Category],
		[intLoadDetailId],
		-- [dbl1099],
		[strBillOfLading],
		[intScaleTicketId],
		[intLocationId],
		[intItemBundleId],
		[intBundletUOMId],
		[dblQtyBundleReceived],
		[dblBundleUnitQty],
		[strBundleDescription],
		[dblBundleTotal],
		[ysnStage]
	)
	OUTPUT inserted.intBillDetailId, inserted.intInventoryReceiptItemId INTO @detailCreated(intBillDetailId, intInventoryReceiptItemId)
	SELECT
		[intBillId],
		[intItemId],
		[strMiscDescription],
		[intInventoryReceiptItemId],
		[intInventoryReceiptChargeId],
		[intPurchaseDetailId],
		[dblQtyOrdered],
		[dblQtyReceived],
		[dblRate],
		[intCurrencyExchangeRateTypeId],
		[ysnSubCurrency],
		[intTaxGroupId],
		[intAccountId],
		[dblTotal],
		[dblCost],
		[dblNetWeight],
		[dblNetShippedWeight],
		[dblWeightLoss],
		[dblFranchiseWeight],
		[intContractDetailId],
		[intContractHeaderId],
		[intContractSeq],
		[intUnitOfMeasureId],
		[intCostUOMId],
		[intWeightUOMId],
		[intLineNo],
		[dblWeightUnitQty],
		[dblCostUnitQty],
		[dblUnitQty],
		[intCurrencyId],
		[intSubLocationId],
		[intStorageLocationId],
		[int1099Form],
		[int1099Category],
		[intLoadDetailId],
		-- [dbl1099],
		[strBillOfLading],
		[intScaleTicketId],
		[intLocationId],
		[intItemBundleId],
		[intBundletUOMId],
		[dblQtyBundleReceived],
		[dblBundleUnitQty],
		[strBundleDescription],
		[dblBundleTotal],
		[ysnStage] = 0
	FROM #tempBillDetail

	--ADD TAXES
	INSERT INTO tblAPBillDetailTax(
		[intBillDetailId]		, 
		[intTaxGroupId]			, 
		[intTaxCodeId]			, 
		[intTaxClassId]			, 
		[strTaxableByOtherTaxes], 
		[strCalculationMethod]	, 
		[dblRate]				, 
		[intAccountId]			, 
		[dblTax]				, 
		[dblAdjustedTax]		, 
		[ysnTaxAdjusted]		, 
		[ysnSeparateOnBill]		, 
		[ysnCheckOffTax]
	)
	SELECT
		[intBillDetailId]		=	B.intBillDetailId, 
		[intTaxGroupId]			=	C.intTaxGroupId, 
		[intTaxCodeId]			=	C.intTaxCodeId, 
		[intTaxClassId]			=	C.intTaxClassId, 
		[strTaxableByOtherTaxes]=	C.strTaxableByOtherTaxes, 
		[strCalculationMethod]	=	C.strCalculationMethod, 
		[dblRate]				=	C.dblRate, 
		[intAccountId]			=	C.intTaxAccountId, 
		[dblTax]				=	CAST(((C.dblTax * CASE WHEN C.strCalculationMethod = 'Unit' THEN D.dblLineTotal ELSE  B.dblTotal END) / (D.dblLineTotal)) AS DECIMAL(18,2)), 
		[dblAdjustedTax]		=	CAST(((C.dblTax * CASE WHEN C.strCalculationMethod = 'Unit' THEN D.dblLineTotal ELSE  B.dblTotal END) / (D.dblLineTotal)) AS DECIMAL(18,2)), 
		[ysnTaxAdjusted]		=	C.ysnTaxAdjusted, 
		[ysnSeparateOnBill]		=	C.ysnSeparateOnInvoice, 
		[ysnCheckOffTax]		=	C.ysnCheckoffTax
	FROM @detailCreated A
	INNER JOIN tblAPBillDetail B ON A.intBillDetailId = B.intBillDetailId
	INNER JOIN tblICInventoryReceiptItemTax C ON B.intInventoryReceiptItemId = C.intInventoryReceiptItemId
	INNER JOIN tblICInventoryReceiptItem D ON B.intInventoryReceiptItemId = D.intInventoryReceiptItemId

	UPDATE voucherDetails
		SET voucherDetails.dblTax = ISNULL(taxes.dblTax,0) / (CASE WHEN voucherDetails.ysnSubCurrency = 1 THEN ISNULL(currency.intSubCurrencyCents,1) ELSE 1 END)
		-- ,voucherDetails.dbl1099 = CASE WHEN voucherDetails.int1099Form > 0 THEN voucherDetails.dblTotal ELSE 0 END
	FROM tblAPBillDetail voucherDetails
	OUTER APPLY (
		SELECT SUM(ISNULL(dblTax,0)) dblTax FROM tblAPBillDetailTax WHERE intBillDetailId = voucherDetails.intBillDetailId
	) taxes
	OUTER APPLY (
		SELECT TOP 1 intSubCurrencyCents FROM tblAPBill WHERE intBillId = voucherDetails.intBillId
	) currency 
	WHERE voucherDetails.intBillDetailId IN (SELECT intBillDetailId FROM @detailCreated)
	
	INSERT INTO @voucherIds
	SELECT @voucherId
	EXEC uspAPUpdateVoucherTotal @voucherIds

	IF  EXISTS (SELECT 1 FROM tblAPBillDetail where intBillDetailId  IN (SELECT intBillDetailId FROM @detailCreated) and intContractDetailId > 0)
	BEGIN
		DECLARE @voucherDetailId INT
		DECLARE curr CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
		FOR
			SELECT  intBillDetailId FROM @detailCreated 
		OPEN curr
		FETCH NEXT FROM curr INTO @voucherDetailId
		WHILE @@FETCH_STATUS = 0	
		BEGIN	
			EXEC [uspAPUpdateQty] @voucherDetailId
			FETCH NEXT FROM curr INTO @voucherDetailId
		END
		CLOSE curr
		DEALLOCATE curr
	END

IF @transCount = 0 COMMIT TRANSACTION

END TRY
BEGIN CATCH
	DECLARE @ErrorSeverity INT,
			@ErrorNumber   INT,
			@ErrorMessage nvarchar(4000),
			@ErrorState INT,
			@ErrorLine  INT,
			@ErrorProc nvarchar(200);
	-- Grab error information from SQL functions
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorNumber   = ERROR_NUMBER()
	SET @ErrorMessage  = ERROR_MESSAGE()
	SET @ErrorState    = ERROR_STATE()
	SET @ErrorLine     = ERROR_LINE()
	IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION
	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH