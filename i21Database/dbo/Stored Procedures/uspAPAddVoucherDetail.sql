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
DECLARE @transCount INT = @@TRANCOUNT;

IF @transCount = 0 BEGIN TRANSACTION
ELSE SAVE TRAN @SavePoint

MERGE INTO tblAPBillDetail AS destination
USING
(
	SELECT TOP 100 PERCENT
		intBillId							=	A.intBillId
		,strMiscDescription					=	A.strMiscDescription
		,intAccountId						=	CASE WHEN A.intAccountId > 0 THEN A.intAccountId ELSE vendor.intGLAccountExpenseId END
		,intItemId							=	A.intItemId
		,dblDiscount						=	A.dblDiscount
		,ysnSubCurrency						=	ISNULL(A.ysnSubCurrency,0)
		,intLineNo							=	CASE WHEN A.intLineNo IS NULL
													THEN ROW_NUMBER() OVER(PARTITION BY A.intBillId ORDER BY A.intBillId)
												ELSE A.intLineNo END
		,intStorageLocationId				=	A.intStorageLocationId
		/*Deferred voucher info*/			
		,intDeferredVoucherId				=	A.intDeferredVoucherId
		/*Integration fields*/				
		,intInventoryReceiptItemId			=	A.intInventoryReceiptItemId
		,intInventoryReceiptChargeId		=	A.intInventoryReceiptChargeId
		,intPaycheckHeaderId				=	A.intPaycheckHeaderId
		,intPurchaseDetailId				=	A.intPurchaseDetailId
		,intCustomerStorageId				=	A.intCustomerStorageId
		,intLocationId						=	A.intLocationId
		,intLoadDetailId					=	A.intLoadShipmentDetailId
		,intLoadId							=	A.intLoadShipmentId
		,intScaleTicketId					=	A.intScaleTicketId
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
		,intPrepayTransactionId				=	prepayTransaction.intBillId
		,dblNetShippedWeight				=	A.dblNetShippedWeight
		,dblWeightLoss						=	A.dblWeightLoss
		,dblFranchiseWeight					=	A.dblFranchiseWeight
		,dblFranchiseAmount					=	A.dblFranchiseAmount
		,dblActual							=	A.dblActual
		,dblDifference						=	A.dblDifference
		/*Weight info*/						
		,intWeightUOMId						=	A.intWeightUOMId
		,dblWeightUnitQty					=	A.dblWeightUnitQty
		,dblNetWeight						=	A.dblNetWeight
		,dblWeight							=	A.dblWeight
		/*Cost info*/						
		,intCostUOMId						=	A.intCostUOMId
		,dblCostUnitQty						=	A.dblCostUnitQty
		,dblCost							=	A.dblCost
		,dblOldCost							=	A.dblOldCost
		/*Quantity info*/					
		,intUnitOfMeasureId					=	ISNULL(ctDetail.intItemUOMId, A.intQtyToBillUOMId)
		,dblUnitQty							=	A.dblQtyToBillUnitQty
		,dblQtyOrdered						=	A.dblOrderQty
		,dblQtyReceived						=	CASE WHEN ctDetail.intContractDetailId IS NOT NULL
													THEN dbo.fnCalculateQtyBetweenUOM(A.intQtyToBillUOMId, ctDetail.intItemUOMId, A.dblQuantityToBill)
												ELSE A.dblQuantityToBill END
		/*Contract info*/					
		,dblQtyContract						=	ISNULL(ctDetail.dblDetailQuantity,0)
		,dblContractCost					=	ISNULL(ctDetail.dblSeqPrice,0)
		/*1099 info*/						
		,int1099Form						=	(CASE WHEN patron.intEntityId IS NOT NULL 
														AND item.intItemId > 0
														AND item.ysn1099Box3 = 1
														AND patron.ysnStockStatusQualified = 1 
														THEN 4
													WHEN entity.str1099Form = '1099-MISC' THEN 1
													WHEN entity.str1099Form = '1099-INT' THEN 2
													WHEN entity.str1099Form = '1099-B' THEN 3
												ELSE 0 END)
		,int1099Category					=	CASE 	WHEN patron.intEntityId IS NOT NULL 
														AND item.intItemId > 0
														AND item.ysn1099Box3 = 1
														AND patron.ysnStockStatusQualified = 1 
														THEN 3
												ELSE ISNULL(category1099.int1099CategoryId, 0) END
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
														CASE WHEN A.dblExchangeRate != 0 THEN A.dblExchangeRate --use the value we recieved for exchange rate if valid
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
	LEFT JOIN (tblAPBill prepayTransaction 
					INNER JOIN tblAPBillDetail prepayDetail ON prepayTransaction.intBillId = prepayDetail.intBillId AND prepayTransaction.intTransactionType = 2)
			ON prepayDetail.intContractDetailId = A.intContractDetailId
	LEFT JOIN vyuPATEntityPatron patron ON A.intEntityVendorId = patron.intEntityId
	LEFT JOIN tblAP1099Category category1099 ON entity.str1099Type = category1099.strCategory
	LEFT JOIN tblICItem item ON A.intItemId = item.intItemId
	LEFT JOIN vyuCTContractDetailView ctDetail ON ctDetail.intContractDetailId = A.intContractDetailId
	ORDER BY A.intBillId ASC
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
	,intLineNo							
	,intStorageLocationId				
	/*Deferred voucher info*/			
	,intDeferredVoucherId				
	/*Integration fields*/				
	,intInventoryReceiptItemId			
	,intInventoryReceiptChargeId		
	,intPaycheckHeaderId				
	,intPurchaseDetailId				
	,intCustomerStorageId				
	,intLocationId						
	,intLoadDetailId					
	,intLoadId							
	,intScaleTicketId					
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
)
VALUES
(
	intBillId							
	,strMiscDescription					
	,intAccountId						
	,intItemId							
	,dblDiscount						
	,ysnSubCurrency						
	,intLineNo							
	,intStorageLocationId				
	/*Deferred voucher info*/			
	,intDeferredVoucherId				
	/*Integration fields*/				
	,intInventoryReceiptItemId			
	,intInventoryReceiptChargeId		
	,intPaycheckHeaderId				
	,intPurchaseDetailId				
	,intCustomerStorageId				
	,intLocationId						
	,intLoadDetailId					
	,intLoadId							
	,intScaleTicketId					
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
);

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
	ELSE
		BEGIN
			IF (XACT_STATE()) = -1
			BEGIN
				ROLLBACK TRANSACTION  @SavePoint
			END
		END	

	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH

END