/*
	Adds detail to voucher record.
	Note:
	1. If foreign currency, we expect that the amounts were already in foreign currency
*/
CREATE PROCEDURE [dbo].[uspAPAddVoucherDetail]
	@voucherDetails AS VoucherPayable READONLY
	,@voucherPayableTax AS VoucherDetailTax READONLY
	,@throwError BIT = 1
	,@error NVARCHAR(1000) = NULL OUTPUT
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @SavePoint NVARCHAR(32) = 'uspAPAddVoucherDetail';
DECLARE @payablesKey TABLE(intOldPayableId int, intNewPayableId int);
DECLARE @transCount INT = @@TRANCOUNT;
DECLARE @voucherDetailsInfo TABLE(intBillDetailId INT, intVoucherPayableId INT);
DECLARE @voucherDetailIds AS Id;

IF @transCount = 0 BEGIN TRANSACTION
ELSE SAVE TRAN @SavePoint

--MAKE SURE TO ADD FIRST TO THE PAYABLES THE VOUCHER DETAIL BEING ADDED
IF NOT EXISTS(
	SELECT TOP 1 1
		FROM tblAPVoucherPayable A
		INNER JOIN @voucherDetails C
			ON ISNULL(C.intPurchaseDetailId,-1) = ISNULL(A.intPurchaseDetailId,-1)
			AND ISNULL(C.intContractDetailId,-1) = ISNULL(A.intContractDetailId,-1)
			AND ISNULL(C.intContractCostId,-1) = ISNULL(A.intContractCostId,-1)
			AND ISNULL(C.intScaleTicketId,-1) = ISNULL(A.intScaleTicketId,-1)
			AND ISNULL(C.intTicketId,-1) = ISNULL(A.intTicketId,-1)
			AND ISNULL(C.intInventoryReceiptChargeId,-1) = ISNULL(A.intInventoryReceiptChargeId,-1)
			AND ISNULL(C.intInventoryReceiptItemId,-1) = ISNULL(A.intInventoryReceiptItemId,-1)
			--AND ISNULL(C.intInventoryShipmentItemId,-1) = ISNULL(A.intInventoryShipmentItemId,-1)
			AND ISNULL(C.intInventoryShipmentChargeId,-1) = ISNULL(A.intInventoryShipmentChargeId,-1)
			AND ISNULL(C.intLoadShipmentDetailId,-1) = ISNULL(A.intLoadShipmentDetailId,-1)
			AND ISNULL(C.intCustomerStorageId,-1) = ISNULL(A.intCustomerStorageId,-1)
			AND ISNULL(C.intSettleStorageId,-1) = ISNULL(A.intSettleStorageId,-1)
			AND ISNULL(C.intLoadShipmentCostId,-1) = ISNULL(A.intLoadShipmentCostId,-1)
			AND ISNULL(C.intEntityVendorId,-1) = ISNULL(A.intEntityVendorId,-1)
			AND ISNULL(C.intItemId,-1) = ISNULL(A.intItemId,-1)
			AND C.ysnStage = 1
	)
	AND NOT EXISTS(
		SELECT TOP 1 1
		FROM tblAPVoucherPayableCompleted A
		INNER JOIN @voucherDetails C
			ON ISNULL(C.intPurchaseDetailId,-1) = ISNULL(A.intPurchaseDetailId,-1)
			AND ISNULL(C.intContractDetailId,-1) = ISNULL(A.intContractDetailId,-1)
			AND ISNULL(C.intContractCostId,-1) = ISNULL(A.intContractCostId,-1)
			AND ISNULL(C.intScaleTicketId,-1) = ISNULL(A.intScaleTicketId,-1)
			AND ISNULL(C.intTicketId,-1) = ISNULL(A.intTicketId,-1)
			AND ISNULL(C.intInventoryReceiptChargeId,-1) = ISNULL(A.intInventoryReceiptChargeId,-1)
			AND ISNULL(C.intInventoryReceiptItemId,-1) = ISNULL(A.intInventoryReceiptItemId,-1)
			--AND ISNULL(C.intInventoryShipmentItemId,-1) = ISNULL(A.intInventoryShipmentItemId,-1)
			AND ISNULL(C.intInventoryShipmentChargeId,-1) = ISNULL(A.intInventoryShipmentChargeId,-1)
			AND ISNULL(C.intLoadShipmentDetailId,-1) = ISNULL(A.intLoadShipmentDetailId,-1)
			AND ISNULL(C.intLoadShipmentCostId,-1) = ISNULL(A.intLoadShipmentCostId,-1)
			AND ISNULL(C.intCustomerStorageId,-1) = ISNULL(A.intCustomerStorageId,-1)
			AND ISNULL(C.intSettleStorageId,-1) = ISNULL(A.intSettleStorageId,-1)
			AND ISNULL(C.intEntityVendorId,-1) = ISNULL(A.intEntityVendorId,-1)
			AND ISNULL(C.intItemId,-1) = ISNULL(A.intItemId,-1)
			AND C.ysnStage = 1
	)
BEGIN
	EXEC uspAPAddVoucherPayable @voucherPayable = @voucherDetails, @voucherPayableTax = @voucherPayableTax, @throwError = 1
END

IF OBJECT_ID(N'tempdb..#tmpVoucherPayableData') IS NOT NULL DROP TABLE #tmpVoucherPayableData

SELECT TOP 100 PERCENT
	intVoucherPayableId					=	A.intVoucherPayableId
	,intTransactionType					=	A.intTransactionType
	,intBillId							=	A.intBillId
	,strMiscDescription					=	A.strMiscDescription
	,intAccountId						=	CASE WHEN A.intAccountId > 0 THEN A.intAccountId ELSE vendor.intGLAccountExpenseId END
	,intItemId							=	A.intItemId
	,dblDiscount						=	A.dblDiscount
	,ysnSubCurrency						=	ISNULL(A.ysnSubCurrency,0)
	,intCurrencyId						=	A.intCostCurrencyId
	,intLineNo							=	CASE WHEN A.intLineNo IS NULL
												THEN ROW_NUMBER() OVER(PARTITION BY A.intBillId ORDER BY A.intBillId)
											ELSE A.intLineNo END
	,intStorageLocationId				=	A.intStorageLocationId
	,intSubLocationId					=	A.intSubLocationId
	/*Deferred voucher info*/			
	,intDeferredVoucherId				=	A.intDeferredVoucherId
	/*Integration fields*/				
	,intInventoryReceiptItemId			=	A.intInventoryReceiptItemId
	,strBillOfLading					=	A.strBillOfLading
	,intInventoryReceiptChargeId		=	A.intInventoryReceiptChargeId
	,intPaycheckHeaderId				=	A.intPaycheckHeaderId
	,intPurchaseDetailId				=	A.intPurchaseDetailId
	,intCustomerStorageId				=	A.intCustomerStorageId
	,intSettleStorageId					=	A.intSettleStorageId
	,intLocationId						=	ISNULL(A.intItemLocationId, A.intLocationId)
	,intLoadDetailId					=	A.intLoadShipmentDetailId
	,intLoadId							=	A.intLoadShipmentId
	,intLoadShipmentCostId				=	A.intLoadShipmentCostId
	,intScaleTicketId					=	A.intScaleTicketId
	,intTicketId						=	A.intTicketId
	,intCCSiteDetailId					=	A.intCCSiteDetailId
	,intInventoryShipmentChargeId		=	A.intInventoryShipmentChargeId
	,intInvoiceId						=	A.intInvoiceId
	,intBuybackChargeId					=	A.intBuybackChargeId
	,intContractCostId					=	A.intContractCostId
	,intContractHeaderId				=	ctDetail.intContractHeaderId
	,intContractDetailId				=	ctDetail.intContractDetailId
	,intContractSeq						=	ctDetail.intContractSeq
	/*Prepaid info*/					
	,dblPrepayPercentage				=	A.dblPrepayPercentage
	,intPrepayTypeId					=	A.intPrepayTypeId
	,ysnRestricted						=	CASE WHEN B.intTransactionType IN (2,13) THEN 1 ELSE 0 END --default to 1 if basis/prepaid
	/*Basis Advance*/					
	,dblBasis							=	A.dblBasis
	,dblFutures							=	A.dblFutures
	/*Claim info*/						
	,intPrepayTransactionId				=	CASE WHEN A.intTransactionType = 11 THEN prepayRec.intBillId ELSE NULL END
	,dblNetShippedWeight				=	A.dblNetShippedWeight
	,dblWeightLoss						=	A.dblWeightLoss
	,dblFranchiseWeight					=	A.dblFranchiseWeight
	,dblFranchiseAmount					=	A.dblFranchiseAmount
	,dblActual							=	A.dblActual  
	,dblDifference						=	A.dblDifference
	/*Weight info*/						
	,intWeightUOMId						=	NULLIF(A.intWeightUOMId,0)
	,dblWeightUnitQty					=	ISNULL(A.dblWeightUnitQty, 1)
	,dblNetWeight						=	A.dblNetWeight
	,dblWeight							=	A.dblWeight
	/*Cost info*/						
	,intCostUOMId						=	CASE WHEN item.intItemId IS NOT NULL AND item.strType IN ('Inventory','Finished Good','Raw Material') AND A.intTransactionType = 1
												THEN ISNULL(ctDetail.intPriceItemUOMId, A.intCostUOMId)
											ELSE A.intCostUOMId END
	,dblCostUnitQty						=	CASE WHEN item.intItemId IS NOT NULL AND item.strType IN ('Inventory','Finished Good','Raw Material') AND A.intTransactionType = 1
												THEN ISNULL(contractItemCostUOM.dblUnitQty, A.dblCostUnitQty)
											ELSE A.dblCostUnitQty END
	,dblCost							=	CASE WHEN item.intItemId IS NOT NULL AND item.strType IN ('Inventory','Finished Good','Raw Material') AND A.intTransactionType = 1
												THEN (CASE WHEN ctDetail.dblSeqPrice > 0 
														THEN ctDetail.dblSeqPrice
													ELSE 
														(CASE WHEN A.dblCost = 0 AND ctDetail.dblSeqPrice > 0
															THEN ctDetail.dblSeqPrice
															ELSE A.dblCost
														END)
													END)
											ELSE A.dblCost END
	,dblOldCost							=	A.dblOldCost
	/*Quantity info*/					
	,intUnitOfMeasureId					=	CASE WHEN item.intItemId IS NOT NULL AND item.strType IN ('Inventory','Finished Good','Raw Material') AND A.intTransactionType = 1
												THEN ISNULL(ctDetail.intItemUOMId, A.intQtyToBillUOMId)
											ELSE A.intQtyToBillUOMId END
	,dblUnitQty							=	CASE WHEN item.intItemId IS NOT NULL AND item.strType IN ('Inventory','Finished Good','Raw Material') AND A.intTransactionType = 1
												THEN 
												(
													CASE WHEN ctDetail.intContractDetailId IS NOT NULL
														THEN contractItemQtyUOM.dblUnitQty
													ELSE A.dblQtyToBillUnitQty END
												)
											ELSE A.dblQtyToBillUnitQty END
	/*Ordered and Received should always the same*/
	,dblQtyOrdered						=	A.dblOrderQty
	,dblQtyReceived						=	CASE WHEN item.intItemId IS NOT NULL AND item.strType IN ('Inventory','Finished Good','Raw Material') AND A.intTransactionType = 1
												THEN (CASE WHEN ctDetail.intContractDetailId IS NOT NULL
														THEN dbo.fnCalculateQtyBetweenUOM(A.intQtyToBillUOMId, ctDetail.intItemUOMId, A.dblQuantityToBill)
													ELSE A.dblQuantityToBill END)
											ELSE A.dblQuantityToBill END
	/*Contract info*/					
	,dblQtyContract						=	ISNULL(ctDetail.dblDetailQuantity,0)
	,dblContractCost					=	CASE WHEN A.intTransactionType = 13
												THEN A.dblFutures + A.dblBasis
												ELSE ISNULL(ctDetail.dblSeqPrice,0)
												END
	/*1099 info*/						
	,int1099Form						=	CASE WHEN B.intTransactionType IN (1, 3, 9, 14)
											THEN
											ISNULL(A.int1099Form,
												(CASE 
													WHEN item.intCommodityId > 0 THEN 0
													WHEN patron.intEntityId IS NOT NULL 
														AND item.intItemId > 0
														AND item.ysn1099Box3 = 1
														AND patron.ysnStockStatusQualified = 1 
														THEN 4
													WHEN entity.str1099Form = '1099-MISC' THEN 1
													WHEN entity.str1099Form = '1099-INT' THEN 2
													WHEN entity.str1099Form = '1099-B' THEN 3
												ELSE 0 END)
											) ELSE 0 END
	,int1099Category					=	CASE WHEN B.intTransactionType IN (1, 3, 9, 14)
											THEN
											ISNULL(A.int1099Category,
												CASE 	
													WHEN item.intCommodityId > 0 THEN 0
													WHEN patron.intEntityId IS NOT NULL 
														AND item.intItemId > 0
														AND item.ysn1099Box3 = 1
														AND patron.ysnStockStatusQualified = 1 
														THEN 3
												ELSE ISNULL(category1099.int1099CategoryId, 0) END
											) ELSE 0 END
	,dbl1099							=	CASE WHEN B.intTransactionType IN (1, 3, 9, 14)
											THEN ISNULL(A.dbl1099, 0) ELSE 0 END
	,ysn1099Printed						=	0
	/*Exchange rate info*/				
	,intCurrencyExchangeRateTypeId		=	CASE WHEN A.intCurrencyId != compPref.intDefaultCurrencyId --if foreign currency
												THEN (
													CASE WHEN A.intCurrencyExchangeRateTypeId > 0 THEN A.intCurrencyExchangeRateTypeId --use the value we recieved for exchange rate type if valid
													ELSE multiCur.intAccountsPayableRateTypeId
													END
												)
												ELSE NULL
											END
	,dblRate							=	CASE WHEN A.intCurrencyId != compPref.intDefaultCurrencyId
												THEN (
													CASE WHEN A.dblExchangeRate != 0 THEN ISNULL(NULLIF(A.dblExchangeRate,0),1) --use the value we recieved for exchange rate if valid
													ELSE defaultExchangeRate.dblExchangeRate
													END
												)
												ELSE 1
											END
	/*Tax info*/						
	,intTaxGroupId						=	A.intPurchaseTaxGroupId
	,dblTax								=	A.dblTax
	/*Bundle info*/						
	,intBundletUOMId					=	NULL
	,strBundleDescription				=	NULL
	,intItemBundleId					=	NULL
	,dblBundleTotal						=	0
	,dblQtyBundleReceived				=	0
	,dblBundleUnitQty					=	0
	,ysnStage							=	A.ysnStage
INTO #tmpVoucherPayableData
FROM @voucherDetails A
INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
INNER JOIN tblAPVendor vendor ON A.intEntityVendorId = vendor.[intEntityId]
INNER JOIN tblEMEntity entity ON vendor.[intEntityId] = entity.intEntityId
CROSS APPLY (SELECT TOP 1 * FROM tblSMCompanyPreference) compPref
/*Currency info*/
CROSS APPLY (SELECT TOP 1 * FROM tblSMMultiCurrency) multiCur
OUTER APPLY (
	SELECT 
		TOP 1 dblRate AS dblExchangeRate 
	FROM tblSMCurrencyExchangeRate forex
	INNER JOIN tblSMCurrencyExchangeRateDetail forexDetail
		ON forex.intCurrencyExchangeRateId = forexDetail.intCurrencyExchangeRateId
	WHERE forexDetail.intRateTypeId = ISNULL(NULLIF(A.intCurrencyExchangeRateTypeId,0), multiCur.intAccountsPayableRateTypeId) --use default AP rate type if no rate type received
		AND forex.intFromCurrencyId = A.intCurrencyId
		AND forex.intToCurrencyId = compPref.intDefaultCurrencyId
		AND forexDetail.dtmValidFromDate < (SELECT CONVERT(char(10), GETDATE(),126))
	ORDER BY forexDetail.dtmValidFromDate DESC
) defaultExchangeRate
/*Claim join*/
OUTER APPLY (
	SELECT TOP 1
		prepayTransaction.intBillId
	FROM tblAPBill prepayTransaction 
	INNER JOIN tblAPBillDetail prepayDetail ON prepayTransaction.intBillId = prepayDetail.intBillId AND prepayTransaction.intTransactionType = 2
	WHERE prepayDetail.intContractDetailId = A.intContractDetailId AND A.intTransactionType = 11
) prepayRec
LEFT JOIN vyuPATEntityPatron patron ON A.intEntityVendorId = patron.intEntityId
LEFT JOIN tblAP1099Category category1099 ON entity.str1099Type = category1099.strCategory
LEFT JOIN tblICItem item ON A.intItemId = item.intItemId
LEFT JOIN vyuCTContractDetailView ctDetail ON ctDetail.intContractDetailId = A.intContractDetailId
LEFT JOIN tblICItemUOM contractItemCostUOM ON contractItemCostUOM.intItemUOMId = ctDetail.intPriceItemUOMId
LEFT JOIN tblICItemUOM contractItemQtyUOM ON contractItemQtyUOM.intItemUOMId = ctDetail.intItemUOMId

-- IF OBJECT_ID(N'tempdb..#tmpVoucherPayableDataStage') IS NOT NULL DROP TABLE #tmpVoucherPayableDataStage

-- SELECT
-- 	*
-- INTO #tmpVoucherPayableDataStage
-- FROM #tmpVoucherPayableData A
-- WHERE A.ysnStage = 1
	
--uspAPUpdateVoucherPayableQty updates the tblAPVoucherPayable table for valid payables only
--make sure to add on tblAPBillDetail the valid payables
INSERT INTO @payablesKey(intOldPayableId, intNewPayableId)
SELECT
	intOldPayableId
	,intNewPayableId
FROM dbo.fnAPGetPayableKeyInfo(@voucherDetails)

--UPDATE THE QTY BASE ON THE QTY BILLED ON STAGING
DECLARE @qtyToBill DECIMAL(38,15);
DECLARE @qtyBilled DECIMAL(38,15);
DECLARE @qtyToBillFromDev DECIMAL(38,15);
UPDATE A
	SET 
		@qtyToBill = ISNULL(
							CASE WHEN item.intItemId IS NOT NULL AND item.strType IN ('Inventory','Finished Good','Raw Material') AND A.intTransactionType = 1
								THEN (CASE WHEN ctDetail.intContractDetailId IS NOT NULL
										THEN dbo.fnCalculateQtyBetweenUOM(A.intUnitOfMeasureId, ctDetail.intItemUOMId, vp.dblQuantityToBill)
									ELSE vp.dblQuantityToBill END)
							ELSE vp.dblQuantityToBill END
							,0),
		@qtyBilled = ISNULL(
							CASE WHEN item.intItemId IS NOT NULL AND item.strType IN ('Inventory','Finished Good','Raw Material') AND A.intTransactionType = 1
								THEN (CASE WHEN ctDetail.intContractDetailId IS NOT NULL
										THEN dbo.fnCalculateQtyBetweenUOM(A.intUnitOfMeasureId, ctDetail.intItemUOMId, vp.dblQuantityBilled)
									ELSE vp.dblQuantityBilled END)
							ELSE vp.dblQuantityBilled END
							,0),
		@qtyToBillFromDev = ISNULL(
							CASE WHEN item.intItemId IS NOT NULL AND item.strType IN ('Inventory','Finished Good','Raw Material') AND A.intTransactionType = 1
								THEN (CASE WHEN ctDetail.intContractDetailId IS NOT NULL
										THEN dbo.fnCalculateQtyBetweenUOM(A.intUnitOfMeasureId, ctDetail.intItemUOMId, A.dblQtyReceived)
									ELSE A.dblQtyReceived END)
							ELSE A.dblQtyReceived END
							,0),
		--LESS THE QTY BILLED ON THE QTY RECEIVED SENT FOR BILLING
		--A.dblQtyOrdered = A.dblQtyOrdered - ISNULL(vp.dblQuantityBilled,0),
		A.dblQtyReceived =  --IF dblQtyReceived EQUALS TO REMAINING QTY TO BILL (dblQuantityToBill), DO NOT SUBTRACT FROM dblQuantityBilled
							--MEANING, THE INTEGRATED DEV ALREADY SENT THE REMAINING QTY TO VOUCHER
							CASE 
								WHEN A.dblQtyReceived >= @qtyToBill 
								THEN @qtyToBill
							ELSE
								--IF LESS THAN THE REMAINING QTY TO BILL,
								--JUST USE IT
								@qtyToBillFromDev
							END,
		A.dblTax = ISNULL(vp.dblTax, A.dblTax), --UPDATE THE TAX IF WE GENERATED IT
		A.intTaxGroupId = ISNULL(vp.intPurchaseTaxGroupId, A.intTaxGroupId)
FROM #tmpVoucherPayableData A
LEFT JOIN tblICItem item ON A.intItemId = item.intItemId
LEFT JOIN vyuCTContractDetailView ctDetail ON ctDetail.intContractDetailId = A.intContractDetailId
LEFT JOIN @payablesKey payableKeys
	ON payableKeys.intOldPayableId = A.intVoucherPayableId
LEFT JOIN tblAPVoucherPayable vp 
	ON payableKeys.intNewPayableId = vp.intVoucherPayableId
WHERE A.ysnStage = 1

MERGE INTO tblAPBillDetail AS destination
USING
(
	SELECT --TOP 100 PERCENT
		*
	FROM #tmpVoucherPayableData A
	-- UNION ALL --ysnStage = 0
	-- SELECT TOP 100 PERCENT
	-- 	*
	-- FROM #tmpVoucherPayableData A
	-- WHERE A.ysnStage = 0
) AS SourceData
ON (1=0)
WHEN NOT MATCHED THEN
INSERT 
(
	intBillId							
	,strMiscDescription					
	,intAccountId						
	,intItemId							
	,dblDiscount						
	,ysnSubCurrency	
	,intCurrencyId					
	,intLineNo							
	,intStorageLocationId				
	,intSubLocationId				
	/*Deferred voucher info*/			
	,intDeferredVoucherId				
	/*Integration fields*/				
	,intInventoryReceiptItemId	
	,strBillOfLading		
	,intInventoryReceiptChargeId		
	,intPaycheckHeaderId				
	,intPurchaseDetailId				
	,intCustomerStorageId
	,intSettleStorageId				
	,intLocationId						
	,intLoadDetailId
	,intLoadShipmentCostId					
	,intLoadId							
	,intScaleTicketId					
	,intTicketId					
	,intCCSiteDetailId					
	,intInventoryShipmentChargeId		
	,intInvoiceId						
	,intBuybackChargeId					
	,intContractCostId					
	,intContractHeaderId				
	,intContractDetailId				
	,intContractSeq						
	/*Prepaid info*/					
	,dblPrepayPercentage				
	,intPrepayTypeId					
	,ysnRestricted						
	/*Basis Advance*/					
	,dblBasis							
	,dblFutures							
	/*Claim info*/						
	,intPrepayTransactionId				
	,dblNetShippedWeight				
	,dblWeightLoss						
	,dblFranchiseWeight					
	,dblFranchiseAmount					
	,dblActual							
	,dblDifference						
	/*Weight info*/						
	,intWeightUOMId						
	,dblWeightUnitQty					
	,dblNetWeight						
	,dblWeight							
	/*Cost info*/						
	,intCostUOMId						
	,dblCostUnitQty						
	,dblCost							
	,dblOldCost							
	/*Quantity info*/					
	,intUnitOfMeasureId					
	,dblUnitQty							
	,dblQtyOrdered						
	,dblQtyReceived						
	/*Contract info*/					
	,dblQtyContract						
	,dblContractCost					
	/*1099 info*/						
	,int1099Form						
	,int1099Category		
	,dbl1099			
	,ysn1099Printed						
	/*Exchange rate info*/				
	,intCurrencyExchangeRateTypeId		
	,dblRate							
	/*Tax info*/						
	,intTaxGroupId						
	,dblTax								
	/*Bundle info*/						
	,intBundletUOMId					
	,strBundleDescription				
	,intItemBundleId					
	,dblBundleTotal						
	,dblQtyBundleReceived				
	,dblBundleUnitQty			
	,ysnStage		
)
VALUES
(
	intBillId							
	,strMiscDescription					
	,intAccountId						
	,intItemId							
	,dblDiscount						
	,ysnSubCurrency		
	,intCurrencyId				
	,intLineNo		
	,intStorageLocationId						
	,intSubLocationId				
	/*Deferred voucher info*/			
	,intDeferredVoucherId				
	/*Integration fields*/				
	,intInventoryReceiptItemId		
	,strBillOfLading	
	,intInventoryReceiptChargeId		
	,intPaycheckHeaderId				
	,intPurchaseDetailId				
	,intCustomerStorageId
	,intSettleStorageId				
	,intLocationId						
	,intLoadDetailId	
	,intLoadShipmentCostId				
	,intLoadId							
	,intScaleTicketId					
	,intTicketId					
	,intCCSiteDetailId					
	,intInventoryShipmentChargeId		
	,intInvoiceId						
	,intBuybackChargeId					
	,intContractCostId					
	,intContractHeaderId				
	,intContractDetailId				
	,intContractSeq						
	/*Prepaid info*/					
	,dblPrepayPercentage				
	,intPrepayTypeId					
	,ysnRestricted						
	/*Basis Advance*/					
	,dblBasis							
	,dblFutures							
	/*Claim info*/						
	,intPrepayTransactionId				
	,dblNetShippedWeight				
	,dblWeightLoss						
	,dblFranchiseWeight					
	,dblFranchiseAmount					
	,dblActual							
	,dblDifference						
	/*Weight info*/						
	,intWeightUOMId						
	,dblWeightUnitQty					
	,dblNetWeight						
	,dblWeight							
	/*Cost info*/						
	,intCostUOMId						
	,dblCostUnitQty						
	,dblCost							
	,dblOldCost							
	/*Quantity info*/					
	,intUnitOfMeasureId					
	,dblUnitQty							
	,dblQtyOrdered						
	,dblQtyReceived						
	/*Contract info*/					
	,dblQtyContract						
	,dblContractCost					
	/*1099 info*/						
	,int1099Form						
	,int1099Category	
	,dbl1099				
	,ysn1099Printed						
	/*Exchange rate info*/				
	,intCurrencyExchangeRateTypeId		
	,dblRate							
	/*Tax info*/						
	,intTaxGroupId						
	,dblTax								
	/*Bundle info*/						
	,intBundletUOMId					
	,strBundleDescription				
	,intItemBundleId					
	,dblBundleTotal						
	,dblQtyBundleReceived				
	,dblBundleUnitQty		
	,ysnStage
)
OUTPUT inserted.intBillDetailId, SourceData.intVoucherPayableId INTO @voucherDetailsInfo;

--ADD TAX DATA
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
	[ysnCheckOffTax]		,
	[ysnTaxOnly]			,
	[ysnTaxExempt]	
)
SELECT
	[intBillDetailId]		=	C.intBillDetailId, 
	[intTaxGroupId]			=	A.intTaxGroupId, 
	[intTaxCodeId]			=	A.intTaxCodeId, 
	[intTaxClassId]			=	A.intTaxClassId, 
	[strTaxableByOtherTaxes]=	A.strTaxableByOtherTaxes, 
	[strCalculationMethod]	=	A.strCalculationMethod, 
	[dblRate]				=	A.dblRate, 
	[intAccountId]			=	A.intAccountId, 
	[dblTax]				=	A.dblTax, 
	[dblAdjustedTax]		=	A.dblAdjustedTax, 
	[ysnTaxAdjusted]		=	A.ysnTaxAdjusted, 
	[ysnSeparateOnBill]		=	A.ysnSeparateOnBill, 
	[ysnCheckOffTax]		=	A.ysnCheckOffTax,
	[ysnTaxOnly]			=	A.ysnTaxOnly,
	[ysnTaxExempt]			=	A.ysnTaxExempt
FROM tblAPVoucherPayableTaxStaging A
INNER JOIN @payablesKey B
	ON A.intVoucherPayableId = B.intNewPayableId
INNER JOIN @voucherDetailsInfo C
	ON B.intOldPayableId = C.intVoucherPayableId

--GENERATE TAXES FOR ysnStage = 0, AND NO TAX DETAILS
DECLARE @idetailIds AS Id
INSERT INTO @idetailIds
SELECT DISTINCT
	A.intBillDetailId
FROM tblAPBillDetail A
INNER JOIN @voucherDetailsInfo B
	ON A.intBillDetailId = B.intBillDetailId
LEFT JOIN tblAPBillDetailTax C ON A.intBillDetailId = C.intBillDetailId
WHERE A.ysnStage = 0 OR C.intBillDetailTaxId IS NULL

EXEC uspAPUpdateVoucherDetailTax @idetailIds

INSERT INTO @voucherDetailIds
SELECT intBillDetailId FROM @voucherDetailsInfo

--UPDATE ADD PAYABLES AVAILABLE QTY
EXEC uspAPUpdateVoucherPayable @voucherDetailIds = @voucherDetailIds, @decrease = 0

--UPDATE AVAILABLE QTY
EXEC uspAPUpdateIntegrationPayableAvailableQty @billDetailIds = @voucherDetailIds, @decrease = 1

--LOG RISK
EXEC uspAPLogVoucherDetailRisk @voucherDetailIds = @voucherDetailIds, @remove = 0

IF @transCount = 0
	BEGIN
		IF (XACT_STATE()) = -1
		BEGIN
			ROLLBACK TRANSACTION
		END
		ELSE IF (XACT_STATE()) = 1
		BEGIN
			COMMIT TRANSACTION
		END
	END		
	ELSE
	BEGIN
		IF (XACT_STATE()) = -1
		BEGIN
			ROLLBACK TRANSACTION  @SavePoint
		END
	END	

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

	IF @transCount = 0
		BEGIN
			IF (XACT_STATE()) = -1
			BEGIN
				ROLLBACK TRANSACTION
			END
			ELSE IF (XACT_STATE()) = 1
			BEGIN
				COMMIT TRANSACTION
			END
		END		
	-- ELSE
	-- 	BEGIN
	-- 		IF (XACT_STATE()) = -1
	-- 		BEGIN
	-- 			ROLLBACK TRANSACTION  @SavePoint
	-- 		END
	-- 	END	

	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH

END