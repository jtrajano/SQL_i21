﻿CREATE PROCEDURE [dbo].[uspAPUpdateVoucherPayableQty]
	@voucherPayable AS VoucherPayable READONLY,
	@voucherPayableTax AS VoucherDetailTax READONLY,
	@post BIT = NULL,
	@throwError BIT = 1,
	@error NVARCHAR(1000) = NULL OUTPUT
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
--SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

/**
intVoucherPayableId = key of deleted payable
intNewPayableId = key of the inserted payable
intVoucherPayableKey = key of VoucherPayable parameter
*/
DECLARE @deleted TABLE(intVoucherPayableId INT, intNewPayableId INT, intVoucherPayableKey INT);
DECLARE @taxDeleted TABLE(intVoucherPayableId INT);
DECLARE @invalidPayables TABLE(intVoucherPayableId INT, strError NVARCHAR(1000));
DECLARE @validPayables AS VoucherPayable
DECLARE @validPayablesTax AS VoucherDetailTax
DECLARE @payablesKey TABLE(intOldPayableId int, intNewPayableId int);
DECLARE @payablesKeyPartial TABLE(intOldPayableId int, intNewPayableId int);
DECLARE @invalidCount INT;
DECLARE @SavePoint NVARCHAR(32) = 'uspAPUpdateVoucherPayableQty';
DECLARE @recordCountToReturn INT = 0;
DECLARE @recordCountReturned INT = 0;
DECLARE @taxCompleted INT = 0;

--uncomment if integrated modules already implemented the new approach
-- --VALIDATE
-- INSERT INTO @invalidPayables
-- SELECT 
-- 	intVoucherPayableId
-- 	,strError
-- FROM dbo.fnAPValidateVoucherPayableQty(@voucherPayable)

SET @invalidCount = @@ROWCOUNT;

SELECT TOP 1
	@error = strError
FROM @invalidPayables

--FILTER VALID PAYABLES
IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpVoucherValidPayables')) DROP TABLE #tmpVoucherValidPayables

SELECT
*
INTO #tmpVoucherValidPayables
FROM @voucherPayable C
WHERE NOT EXISTS (
	SELECT 1 FROM @invalidPayables D
	WHERE D.intVoucherPayableId = C.intVoucherPayableId
)

ALTER TABLE #tmpVoucherValidPayables DROP COLUMN intVoucherPayableId
INSERT INTO @validPayables
SELECT * FROM #tmpVoucherValidPayables

--FILTER VALID PAYABLES TAX
IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpVoucherValidPayablesTax')) DROP TABLE #tmpVoucherValidPayablesTax

SELECT
	[intVoucherPayableId]    	=	B.intVoucherPayableId,   
	[intTaxGroupId]				=	A.intTaxGroupId,	
	[intTaxCodeId]				=	A.intTaxCodeId,		
	[intTaxClassId]				=	A.intTaxClassId,	
	[strTaxableByOtherTaxes]	=	A.strTaxableByOtherTaxes,
	[strCalculationMethod]		=	A.strCalculationMethod,
	[dblRate]					=	A.dblRate,
	[intAccountId]				=	A.intAccountId,
	[dblTax]					=	A.dblTax,
	[dblAdjustedTax]			=	A.dblAdjustedTax,
	[ysnTaxAdjusted]			=	A.ysnTaxAdjusted,
	[ysnSeparateOnBill]			=	A.ysnSeparateOnBill,
	[ysnCheckOffTax]			=	A.ysnCheckOffTax,
	[ysnTaxExempt]              =	A.ysnTaxExempt,
	[ysnTaxOnly]				=	A.ysnTaxOnly
INTO #tmpVoucherValidPayablesTax
FROM @voucherPayableTax A
INNER JOIN @validPayables B
	ON A.intVoucherPayableId = B.intVoucherPayableId

INSERT INTO @validPayablesTax
SELECT * FROM #tmpVoucherValidPayablesTax

IF @error IS NOT NULL
BEGIN
	IF @throwError = 1 
	BEGIN
		RAISERROR(@error, 16, 1);
		RETURN;
	END
	--IF NO VALID PAYABLES
	IF @invalidCount = (SELECT COUNT(*) FROM @voucherPayable)
	RETURN;
END

DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION
ELSE SAVE TRAN @SavePoint

	--IF PAYABLE HAVE NEVER BEEN ADDED YET
	IF NOT EXISTS(
		SELECT TOP 1 1
			FROM tblAPVoucherPayable A
			INNER JOIN @voucherPayable C
				ON	A.intTransactionType = CASE WHEN C.intTransactionType = 16 THEN 1 ELSE C.intTransactionType END
				AND	ISNULL(C.intPurchaseDetailId,-1) = ISNULL(A.intPurchaseDetailId,-1)
				AND ISNULL(C.intContractDetailId,-1) = ISNULL(A.intContractDetailId,-1)
				AND ISNULL(C.intContractCostId,-1) = ISNULL(A.intContractCostId,-1)
				AND ISNULL(C.intScaleTicketId,-1) = ISNULL(A.intScaleTicketId,-1)
				AND ISNULL(C.intInventoryReceiptChargeId,-1) = ISNULL(A.intInventoryReceiptChargeId,-1)
				AND ISNULL(C.intInventoryReceiptItemId,-1) = ISNULL(A.intInventoryReceiptItemId,-1)
				--AND ISNULL(C.intInventoryShipmentItemId,-1) = ISNULL(A.intInventoryShipmentItemId,-1)
				AND ISNULL(C.intInventoryShipmentChargeId,-1) = ISNULL(A.intInventoryShipmentChargeId,-1)
				AND ISNULL(C.intLoadShipmentDetailId,-1) = ISNULL(A.intLoadShipmentDetailId,-1)
				AND ISNULL(C.intTicketDistributionAllocationId,-1) = ISNULL(A.intTicketDistributionAllocationId,-1)
				AND ISNULL(C.intLoadShipmentCostId,-1) = ISNULL(A.intLoadShipmentCostId,-1)
				AND ISNULL(C.intWeightClaimDetailId,-1) = ISNULL(A.intWeightClaimDetailId,-1)
				AND ISNULL(C.intEntityVendorId,-1) = ISNULL(A.intEntityVendorId,-1)
				AND ISNULL(C.intCustomerStorageId,-1) = ISNULL(A.intCustomerStorageId,-1)
				AND ISNULL(C.intSettleStorageId,-1) = ISNULL(A.intSettleStorageId,-1)
				AND ISNULL(C.intPriceFixationDetailId,-1) = ISNULL(A.intPriceFixationDetailId,-1)
				AND ISNULL(C.intInsuranceChargeDetailId,-1) = ISNULL(A.intInsuranceChargeDetailId,-1)
				AND ISNULL(C.intStorageChargeId,-1) = ISNULL(A.intStorageChargeId,-1)
				AND ISNULL(C.intItemId,-1) = ISNULL(A.intItemId,-1)
		)
		AND NOT EXISTS(
			SELECT TOP 1 1
			FROM tblAPVoucherPayableCompleted A
			INNER JOIN @voucherPayable C
				ON 	A.intTransactionType = CASE WHEN C.intTransactionType = 16 THEN 1 ELSE C.intTransactionType END
				AND	ISNULL(C.intPurchaseDetailId,-1) = ISNULL(A.intPurchaseDetailId,-1)
				AND ISNULL(C.intContractDetailId,-1) = ISNULL(A.intContractDetailId,-1)
				AND ISNULL(C.intContractCostId,-1) = ISNULL(A.intContractCostId,-1)
				AND ISNULL(C.intScaleTicketId,-1) = ISNULL(A.intScaleTicketId,-1)
				AND ISNULL(C.intInventoryReceiptChargeId,-1) = ISNULL(A.intInventoryReceiptChargeId,-1)
				AND ISNULL(C.intInventoryReceiptItemId,-1) = ISNULL(A.intInventoryReceiptItemId,-1)
				--AND ISNULL(C.intInventoryShipmentItemId,-1) = ISNULL(A.intInventoryShipmentItemId,-1)
				AND ISNULL(C.intInventoryShipmentChargeId,-1) = ISNULL(A.intInventoryShipmentChargeId,-1)
				AND ISNULL(C.intTicketDistributionAllocationId,-1) = ISNULL(A.intTicketDistributionAllocationId,-1)
				AND ISNULL(C.intLoadShipmentDetailId,-1) = ISNULL(A.intLoadShipmentDetailId,-1)
				AND ISNULL(C.intLoadShipmentCostId,-1) = ISNULL(A.intLoadShipmentCostId,-1)
				AND ISNULL(C.intWeightClaimDetailId,-1) = ISNULL(A.intWeightClaimDetailId,-1)
				AND ISNULL(C.intEntityVendorId,-1) = ISNULL(A.intEntityVendorId,-1)
				AND ISNULL(C.intCustomerStorageId,-1) = ISNULL(A.intCustomerStorageId,-1)
				AND ISNULL(C.intSettleStorageId,-1) = ISNULL(A.intSettleStorageId,-1)
				AND ISNULL(C.intPriceFixationDetailId,-1) = ISNULL(A.intPriceFixationDetailId,-1)
				AND ISNULL(C.intInsuranceChargeDetailId,-1) = ISNULL(A.intInsuranceChargeDetailId,-1)
				AND ISNULL(C.intStorageChargeId,-1) = ISNULL(A.intStorageChargeId,-1)
				AND ISNULL(C.intItemId,-1) = ISNULL(A.intItemId,-1)
		)
	BEGIN
		--ADD PAYABLES IN CASE IF NOT EXISTS
		--THIS IS USEFUL WHEN DELETING VOUCHER BUT THERE IS NO RECORD IN tblAPVoucherPayableCompleted
		--THAT WAY, WE WILL HAVE PAYABLE RECORDS THAT WOULD ALLOW USER TO CREATE VOUCHER VIA 'Add Payables' SCREEN
		--IN THIS CASE tblAPBillDetail.ysnStage IS 0 BUT IT IS A VALID PAYABLES
		EXEC uspAPAddVoucherPayable @voucherPayable = @voucherPayable, @voucherPayableTax = @voucherPayableTax, @throwError = 1
		
		IF @transCount = 0
		BEGIN
			COMMIT TRANSACTION;
		END

		RETURN;
	END

	IF @post = 1
	BEGIN

		--IF ALREADY EXISTS GET PAYABLES KEY
		INSERT INTO @payablesKey(intOldPayableId, intNewPayableId)
		SELECT
			intOldPayableId
			,intNewPayableId
		FROM dbo.fnAPGetPayableKeyInfo(@voucherPayable)

		--SET THE REMAINING TAX TO VOUCHER
		UPDATE T
		SET T.dblTax = T.dblTax - T2.dblTax,
			T.dblAdjustedTax = T.dblAdjustedTax - T2.dblAdjustedTax
		FROM tblAPVoucherPayableTaxStaging T
		INNER JOIN (
			SELECT PK.intNewPayableId, VT.intTaxGroupId, VT.intTaxCodeId, SUM(VT.dblTax) dblTax, SUM(VT.dblAdjustedTax) dblAdjustedTax
			FROM @payablesKey PK
			INNER JOIN @voucherPayableTax VT ON VT.intVoucherPayableId = PK.intOldPayableId
			GROUP BY PK.intNewPayableId, VT.intTaxGroupId, VT.intTaxCodeId
		) T2 ON T2.intNewPayableId = T.intVoucherPayableId AND T2.intTaxGroupId = T.intTaxGroupId AND T2.intTaxCodeId = T.intTaxCodeId

		--UPDATE THE QTY BEFORE BACKING UP AND DELETING, SO WE COULD ACTUAL QTY WHEN RE-INSERTING
		--UPDATE QTY IF THERE ARE STILL QTY LEFT TO BILL	
		UPDATE P
		SET P.dblQuantityToBill = (P.dblQuantityToBill - P2.dblQuantityToBill),
			P.dblQuantityBilled = (P.dblQuantityBilled + P2.dblQuantityToBill),
			P.dblNetWeight = (P.dblNetWeight - P2.dblNetWeight),
			P.dblTax = ISNULL(PT.dblRemainingTax, 0)
		FROM tblAPVoucherPayable P
		INNER JOIN (
			SELECT PK.intNewPayableId, SUM(dblQuantityToBill) dblQuantityToBill, SUM(dblNetWeight) dblNetWeight
			FROM @payablesKey PK
			INNER JOIN @voucherPayable VP ON VP.intVoucherPayableId = PK.intOldPayableId
			GROUP BY PK.intNewPayableId
		) P2 ON P2.intNewPayableId = P.intVoucherPayableId
		OUTER APPLY (
			SELECT SUM(dblAdjustedTax) dblRemainingTax
			FROM tblAPVoucherPayableTaxStaging
			WHERE intVoucherPayableId = P.intVoucherPayableId
		) PT

		--AS THE VALUES ARE NOW CORRECTLY SUMMED AND GROUPED REMOVE ENTRY IF SAME PAYABLE
		;WITH CTE AS (
			SELECT intCount = ROW_NUMBER() OVER(PARTITION BY intNewPayableId ORDER BY intNewPayableId) FROM @payablesKey
		) DELETE FROM CTE WHERE intCount > 1

		--back up to tblAPVoucherPayableCompleted if qty to bill is 0
		MERGE INTO tblAPVoucherPayableCompleted AS destination
		USING (
			SELECT
				B.intTransactionType
				,B.[intEntityVendorId]				
				,B.[strVendorId]					
				,B.[strName]						
				,B.[intLocationId]					
				,B.[strLocationName] 				
				,B.[intCurrencyId]					
				,B.[strCurrency]					
				,B.[dtmDate]						
				,B.[strReference]	
				,B.[strLoadShipmentNumber]				
				,B.[strSourceNumber]				
				,B.[intPurchaseDetailId]			
				,B.[strPurchaseOrderNumber]		
				,B.[intContractHeaderId]			
				,B.[intContractDetailId]
				,B.[intPriceFixationDetailId]			
				,B.[intInsuranceChargeDetailId]	
				,B.[intStorageChargeId]	
				,B.[intContractSeqId]				
				,B.[intContractCostId]				
				,B.[strContractNumber]				
				,B.[intScaleTicketId]				
				,B.[strScaleTicketNumber]			
				,B.[intInventoryReceiptItemId]		
				,B.[intInventoryReceiptChargeId]	
				,B.[intInventoryShipmentItemId]	
				,B.[intInventoryShipmentChargeId]
				,B.[intLoadShipmentId]				
				,B.[intLoadShipmentDetailId]	
				,B.[intLoadShipmentCostId]	
				,B.[intWeightClaimId]
				,B.[intWeightClaimDetailId]
				,B.[intCustomerStorageId]	
				,B.[intSettleStorageId]
				,B.[intItemId]						
				,B.[intLinkingId]		
				,B.[intComputeTotalOption]	
				,B.[intLotId]	
				,B.[intTicketDistributionAllocationId]
				,B.[strItemNo]						
				,B.[intPurchaseTaxGroupId]			
				,B.[strTaxGroup]	
				,B.[ysnOverrideTaxGroup]		
				,B.[intItemLocationId]			
				,B.[strItemLocationName]		
				,B.[intStorageLocationId]			
				,B.[strStorageLocationName]		
				,B.[intSubLocationId]			
				,B.[strSubLocationName]				
				,B.[strMiscDescription]			
				,B.[dblOrderQty]					
				,B.[dblOrderUnitQty]				
				,B.[intOrderUOMId]					
				,B.[strOrderUOM]					
				,B.[dblQuantityToBill]				
				,B.[dblQtyToBillUnitQty]			
				,B.[intQtyToBillUOMId]				
				,B.[strQtyToBillUOM]				
				,B.[dblCost]						
				,B.[dblCostUnitQty]				
				,B.[intCostUOMId]					
				,B.[strCostUOM]					
				,B.[dblNetWeight]					
				,B.[dblWeightUnitQty]				
				,B.[intWeightUOMId]				
				,B.[strWeightUOM]					
				,B.[intCostCurrencyId]				
				,B.[strCostCurrency]				
				,B.[dblTax]						
				,B.[dblDiscount]					
				,B.[intCurrencyExchangeRateTypeId]
				,B.[strRateType]					
				,B.[dblExchangeRate]				
				,B.[ysnSubCurrency]				
				,B.[intSubCurrencyCents]			
				,B.[intAccountId]					
				,B.[strAccountId]					
				,B.[strAccountDesc]				
				,B.[intShipViaId]					
				,B.[strShipVia]					
				,B.[intTermId]						
				,B.[strTerm]						
				,B.[strBillOfLading]				
				,B.[int1099Form]					
				,B.[str1099Form]					
				,B.[int1099Category]
				,B.[dbl1099]
				,B.[str1099Type]					
				,B.[ysnReturn]	
				,B.[intFreightTermId]
				,B.[strFreightTerm]
				,B.[intBookId]
				,B.[intSubBookId]
				,B.[intPayFromBankAccountId]
				,B.[strPayFromBankAccount]
				,B.[strFinancingSourcedFrom]
				,B.[strFinancingTransactionNumber]
				,B.[strFinanceTradeNo]
				,B.[intBankId]
				,B.[strBankName]
				,B.[intBankAccountId]
				,B.[strBankAccountNo]
				,B.[intBorrowingFacilityId]
				,B.[strBorrowingFacilityId]
				,B.[strBankReferenceNo]
				,B.[intBorrowingFacilityLimitId]
				,B.[strBorrowingFacilityLimit]
				,B.[intBorrowingFacilityLimitDetailId]
				,B.[strLimitDescription]
				,B.[strReferenceNo]
				,B.[intBankValuationRuleId]
				,B.[strBankValuationRule]
				,B.[strComments]
				,B.[dblQualityPremium]
				,B.[dblOptionalityPremium]
				,B.[strTaxPoint]
				,B.[intTaxLocationId]
				,B.[strTaxLocation]
				,B.[intVoucherPayableId]
				,C.intOldPayableId AS intVoucherPayableKey
			FROM tblAPVoucherPayable B
			INNER JOIN @payablesKey C
				ON B.intVoucherPayableId = C.intNewPayableId
			-- ON 		C.intTransactionType = B.intTransactionType
			-- 	AND	ISNULL(C.intPurchaseDetailId,-1) = ISNULL(B.intPurchaseDetailId,-1)
			-- 	AND ISNULL(C.intContractDetailId,-1) = ISNULL(B.intContractDetailId,-1)
			-- 	AND ISNULL(C.intScaleTicketId,-1) = ISNULL(B.intScaleTicketId,-1)
			-- 	AND ISNULL(C.intEntityVendorId,-1) = ISNULL(B.intEntityVendorId,-1)
			-- 	AND ISNULL(C.intInventoryReceiptChargeId,-1) = ISNULL(B.intInventoryReceiptChargeId,-1)
			-- 	AND ISNULL(C.intInventoryReceiptItemId,-1) = ISNULL(B.intInventoryReceiptItemId,-1)
			-- 	--AND ISNULL(C.intLoadDetailId,-1) = ISNULL(B.intLoadShipmentDetailId,-1)
			-- 	AND ISNULL(C.intLoadShipmentDetailId,-1) = ISNULL(B.intLoadShipmentDetailId,-1)
			-- 	AND ISNULL(C.intInventoryShipmentChargeId,-1) = ISNULL(B.intInventoryShipmentChargeId,-1)
			--WHERE C.intBillId IN (SELECT intId FROM @voucherIds)
			WHERE B.dblQuantityToBill = 0
		) AS SourceData
		ON (1=0)
		WHEN NOT MATCHED THEN
		INSERT (
			[intTransactionType]
			,[intEntityVendorId]				
			,[strVendorId]					
			,[strName]						
			,[intLocationId]					
			,[strLocationName] 				
			,[intCurrencyId]					
			,[strCurrency]					
			,[dtmDate]						
			,[strReference]		
			,[strLoadShipmentNumber]			
			,[strSourceNumber]				
			,[intPurchaseDetailId]			
			,[strPurchaseOrderNumber]		
			,[intContractHeaderId]			
			,[intContractDetailId]	
			,[intPriceFixationDetailId]		
			,[intInsuranceChargeDetailId]	
			,[intStorageChargeId]	
			,[intContractSeqId]				
			,[intContractCostId]				
			,[strContractNumber]				
			,[intScaleTicketId]				
			,[strScaleTicketNumber]			
			,[intInventoryReceiptItemId]		
			,[intInventoryReceiptChargeId]	
			,[intInventoryShipmentItemId]	
			,[intInventoryShipmentChargeId]
			,[intLoadShipmentId]				
			,[intLoadShipmentDetailId]	
			,[intLoadShipmentCostId]	
			,[intWeightClaimId]
			,[intWeightClaimDetailId]
			,[intCustomerStorageId]	
			,[intSettleStorageId]
			,[intItemId]						
			,[intLinkingId]		
			,[intComputeTotalOption]	
			,[intLotId]
			,[intTicketDistributionAllocationId]	
			,[strItemNo]						
			,[intPurchaseTaxGroupId]			
			,[strTaxGroup]		
			,[ysnOverrideTaxGroup]			
			,[intItemLocationId]			
			,[strItemLocationName]	
			,[intStorageLocationId]			
			,[strStorageLocationName]	
			,[intSubLocationId]			
			,[strSubLocationName]					
			,[strMiscDescription]			
			,[dblOrderQty]					
			,[dblOrderUnitQty]				
			,[intOrderUOMId]					
			,[strOrderUOM]					
			,[dblQuantityToBill]				
			,[dblQtyToBillUnitQty]			
			,[intQtyToBillUOMId]				
			,[strQtyToBillUOM]				
			,[dblCost]						
			,[dblCostUnitQty]				
			,[intCostUOMId]					
			,[strCostUOM]					
			,[dblNetWeight]					
			,[dblWeightUnitQty]				
			,[intWeightUOMId]				
			,[strWeightUOM]					
			,[intCostCurrencyId]				
			,[strCostCurrency]				
			,[dblTax]						
			,[dblDiscount]					
			,[intCurrencyExchangeRateTypeId]
			,[strRateType]					
			,[dblExchangeRate]				
			,[ysnSubCurrency]				
			,[intSubCurrencyCents]			
			,[intAccountId]					
			,[strAccountId]					
			,[strAccountDesc]				
			,[intShipViaId]					
			,[strShipVia]					
			,[intTermId]						
			,[strTerm]						
			,[strBillOfLading]				
			,[int1099Form]					
			,[str1099Form]					
			,[int1099Category]	
			,[dbl1099]			
			,[str1099Type]					
			,[ysnReturn]		
			,[intFreightTermId]
			,[strFreightTerm]
			,[intBookId]
			,[intSubBookId]
			,[intPayFromBankAccountId]
			,[strPayFromBankAccount]
			,[strFinancingSourcedFrom]
			,[strFinancingTransactionNumber]
			,[strFinanceTradeNo]
			,[intBankId]
			,[strBankName]
			,[intBankAccountId]
			,[strBankAccountNo]
			,[intBorrowingFacilityId]
			,[strBorrowingFacilityId]
			,[strBankReferenceNo]
			,[intBorrowingFacilityLimitId]
			,[strBorrowingFacilityLimit]
			,[intBorrowingFacilityLimitDetailId]
			,[strLimitDescription]
			,[strReferenceNo]
			,[intBankValuationRuleId]
			,[strBankValuationRule]
			,[strComments]
			,[dblQualityPremium]
			,[dblOptionalityPremium]
			,[strTaxPoint]
			,[intTaxLocationId]
			,[strTaxLocation]
		)
		VALUES (
			[intTransactionType]
			,[intEntityVendorId]				
			,[strVendorId]					
			,[strName]						
			,[intLocationId]					
			,[strLocationName] 				
			,[intCurrencyId]					
			,[strCurrency]					
			,[dtmDate]						
			,[strReference]	
			,[strLoadShipmentNumber]				
			,[strSourceNumber]				
			,[intPurchaseDetailId]			
			,[strPurchaseOrderNumber]		
			,[intContractHeaderId]			
			,[intContractDetailId]
			,[intPriceFixationDetailId]		
			,[intInsuranceChargeDetailId]	
			,[intStorageChargeId]	
			,[intContractSeqId]				
			,[intContractCostId]				
			,[strContractNumber]				
			,[intScaleTicketId]				
			,[strScaleTicketNumber]			
			,[intInventoryReceiptItemId]		
			,[intInventoryReceiptChargeId]	
			,[intInventoryShipmentItemId]	
			,[intInventoryShipmentChargeId]
			,[intLoadShipmentId]				
			,[intLoadShipmentDetailId]	
			,[intLoadShipmentCostId]	
			,[intWeightClaimId]
			,[intWeightClaimDetailId]
			,[intCustomerStorageId]	
			,[intSettleStorageId]
			,[intItemId]						
			,[intLinkingId]		
			,[intComputeTotalOption]	
			,[intLotId]	
			,[intTicketDistributionAllocationId]		
			,[strItemNo]						
			,[intPurchaseTaxGroupId]			
			,[strTaxGroup]		
			,[ysnOverrideTaxGroup]			
			,[intItemLocationId]			
			,[strItemLocationName]	
			,[intStorageLocationId]			
			,[strStorageLocationName]	
			,[intSubLocationId]			
			,[strSubLocationName]						
			,[strMiscDescription]			
			,[dblOrderQty]					
			,[dblOrderUnitQty]				
			,[intOrderUOMId]					
			,[strOrderUOM]					
			,[dblQuantityToBill]				
			,[dblQtyToBillUnitQty]			
			,[intQtyToBillUOMId]				
			,[strQtyToBillUOM]				
			,[dblCost]						
			,[dblCostUnitQty]				
			,[intCostUOMId]					
			,[strCostUOM]					
			,[dblNetWeight]					
			,[dblWeightUnitQty]				
			,[intWeightUOMId]				
			,[strWeightUOM]					
			,[intCostCurrencyId]				
			,[strCostCurrency]				
			,[dblTax]						
			,[dblDiscount]					
			,[intCurrencyExchangeRateTypeId]
			,[strRateType]					
			,[dblExchangeRate]				
			,[ysnSubCurrency]				
			,[intSubCurrencyCents]			
			,[intAccountId]					
			,[strAccountId]					
			,[strAccountDesc]				
			,[intShipViaId]					
			,[strShipVia]					
			,[intTermId]						
			,[strTerm]						
			,[strBillOfLading]				
			,[int1099Form]					
			,[str1099Form]					
			,[int1099Category]	
			,[dbl1099]			
			,[str1099Type]					
			,[ysnReturn]	
			,[intFreightTermId]	
			,[strFreightTerm]
			,[intBookId]
			,[intSubBookId]	
			,[intPayFromBankAccountId]
			,[strPayFromBankAccount]
			,[strFinancingSourcedFrom]
			,[strFinancingTransactionNumber]
			,[strFinanceTradeNo]
			,[intBankId]
			,[strBankName]
			,[intBankAccountId]
			,[strBankAccountNo]
			,[intBorrowingFacilityId]
			,[strBorrowingFacilityId]
			,[strBankReferenceNo]
			,[intBorrowingFacilityLimitId]
			,[strBorrowingFacilityLimit]
			,[intBorrowingFacilityLimitDetailId]
			,[strLimitDescription]
			,[strReferenceNo]
			,[intBankValuationRuleId]
			,[strBankValuationRule]
			,[strComments]
			,[dblQualityPremium]
			,[dblOptionalityPremium]
			,[strTaxPoint]
			,[intTaxLocationId]
			,[strTaxLocation]
		)
		OUTPUT
			SourceData.intVoucherPayableId,
			inserted.intVoucherPayableId,
			SourceData.intVoucherPayableKey
		INTO @deleted;

		--Back up taxes with 0 tax amount
		MERGE INTO tblAPVoucherPayableTaxCompleted AS destination
		USING (
			SELECT
				del.[intNewPayableId]
				,taxes.intVoucherPayableId
				,taxes.[intTaxGroupId]				
				,taxes.[intTaxCodeId]				
				,taxes.[intTaxClassId]				
				,taxes.[strTaxableByOtherTaxes]	
				,taxes.[strCalculationMethod]		
				,taxes.[dblRate]					
				,taxes.[intAccountId]				
				,taxes.[dblTax]					
				,taxes.[dblAdjustedTax]			
				,taxes.[ysnTaxAdjusted]			
				,taxes.[ysnSeparateOnBill]			
				,taxes.[ysnCheckOffTax]			
				,taxes.[ysnTaxOnly]
				,taxes.[ysnTaxExempt]
			FROM tblAPVoucherPayableTaxStaging taxes
			INNER JOIN @deleted del ON taxes.intVoucherPayableId = del.intVoucherPayableId
			WHERE 
				(taxes.dblTax = 0 AND taxes.ysnTaxExempt = 0) 
			OR taxes.ysnTaxExempt = 1
		) AS SourceData
		 --handle key clashing, there could be already payable id exists on tax completed
		ON (destination.intVoucherPayableId = SourceData.intNewPayableId)
		WHEN MATCHED THEN
		UPDATE 
			SET 
			[intTaxGroupId]				=	SourceData.intTaxGroupId,				
			[intTaxCodeId]				=	SourceData.intTaxCodeId,				
			[intTaxClassId]				=	SourceData.intTaxClassId,		
			[strTaxableByOtherTaxes]	=	SourceData.strTaxableByOtherTaxes,
			[strCalculationMethod]		=	SourceData.strCalculationMethod,
			[dblRate]					=	SourceData.dblRate,
			[intAccountId]				=	SourceData.intAccountId,
			[dblTax]					=	SourceData.dblTax,
			[dblAdjustedTax]			=	SourceData.dblAdjustedTax,
			[ysnTaxAdjusted]			=	SourceData.ysnTaxAdjusted,
			[ysnSeparateOnBill]			=	SourceData.ysnSeparateOnBill,
			[ysnCheckOffTax]			=	SourceData.ysnCheckOffTax,
			[ysnTaxOnly]				=	SourceData.ysnTaxOnly,
			[ysnTaxExempt]				=	SourceData.ysnTaxExempt
		WHEN NOT MATCHED THEN
		INSERT (
			[intVoucherPayableId]		
			,[intTaxGroupId]				
			,[intTaxCodeId]				
			,[intTaxClassId]				
			,[strTaxableByOtherTaxes]	
			,[strCalculationMethod]		
			,[dblRate]					
			,[intAccountId]				
			,[dblTax]					
			,[dblAdjustedTax]			
			,[ysnTaxAdjusted]			
			,[ysnSeparateOnBill]			
			,[ysnCheckOffTax]			
			,[ysnTaxOnly]
			,[ysnTaxExempt]
		)
		VALUES (
			[intNewPayableId]		
			,[intTaxGroupId]				
			,[intTaxCodeId]				
			,[intTaxClassId]				
			,[strTaxableByOtherTaxes]	
			,[strCalculationMethod]		
			,[dblRate]					
			,[intAccountId]				
			,[dblTax]					
			,[dblAdjustedTax]			
			,[ysnTaxAdjusted]			
			,[ysnSeparateOnBill]			
			,[ysnCheckOffTax]			
			,[ysnTaxOnly]
			,[ysnTaxExempt]
		)
		OUTPUT 
			SourceData.intVoucherPayableId
		INTO @taxDeleted;

		--if post, remove if the available qty is 0
		DELETE A
		FROM tblAPVoucherPayable A
		INNER JOIN @deleted B ON A.intVoucherPayableId = B.intVoucherPayableId

		DELETE A
		FROM tblAPVoucherPayableTaxStaging A
		INNER JOIN @taxDeleted B ON A.intVoucherPayableId = B.intVoucherPayableId

		SET @taxCompleted = @@ROWCOUNT;

		IF @taxCompleted != (SELECT COUNT(*) FROM @taxDeleted)
		BEGIN
			--IF TAXES MOVED TO tblAPVoucherPayableTaxCompleted IS NOT EQUAL TO TAX DELETED IN STAGING
			RAISERROR('Invalid tax record deleted/inserted.', 16, 1);
			RETURN;
		END
	END
	ELSE IF @post = 0
	BEGIN
	
		--GET PAYABLES FOR PARTIAL
		INSERT INTO @payablesKeyPartial(intOldPayableId, intNewPayableId)
		SELECT
			intOldPayableId
			,intNewPayableId
		FROM dbo.fnAPGetPayableKeyInfo(@voucherPayable)

		UPDATE A
			SET 
				A.dblTax = A.dblTax + taxData.dblTax,
				A.dblAdjustedTax = A.dblAdjustedTax + taxData.dblAdjustedTax
		FROM tblAPVoucherPayableTaxStaging A
		INNER JOIN @payablesKeyPartial A2
			ON A2.intNewPayableId = A.intVoucherPayableId
		-- INNER JOIN @validPayables B
		-- 	ON B.intVoucherPayableId = A2.intOldPayableId
		-- INNER JOIN tblAPVoucherPayable C
		-- 	ON A2.intNewPayableId = C.intVoucherPayableId
		INNER JOIN @voucherPayableTax taxData
			ON A2.intOldPayableId = taxData.intVoucherPayableId
			AND A.intTaxGroupId = taxData.intTaxGroupId
			AND A.intTaxCodeId = taxData.intTaxCodeId
		-- CROSS APPLY (
		-- 	SELECT
		-- 		*
		-- 	FROM dbo.fnAPRecomputeStagingTaxes(A.intVoucherPayableId, B.dblCost, C.dblQuantityToBill) taxes
		-- 	WHERE A.intTaxCodeId = taxes.intTaxCodeId AND A.intTaxGroupId = taxes.intTaxGroupId
		-- ) taxData

		--UPDATE QTY FOR PARTIAL
		UPDATE B
			SET B.dblQuantityToBill = (B.dblQuantityToBill + C.dblQuantityToBill),
				B.dblNetWeight = (B.dblNetWeight + C.dblNetWeight),
				B.dblQuantityBilled = 0, --when returning to tblAPVoucherPayable, we expect that qty to billed is 0
				B.dblTax = ISNULL(PT.dblRemainingTax, 0)
		FROM tblAPVoucherPayable B
		INNER JOIN @payablesKeyPartial B2
			ON B2.intNewPayableId = B.intVoucherPayableId
		INNER JOIN @voucherPayable C
			ON C.intVoucherPayableId = B2.intOldPayableId
		OUTER APPLY (
			SELECT SUM(dblAdjustedTax) dblRemainingTax
			FROM tblAPVoucherPayableTaxStaging
			WHERE intVoucherPayableId = B.intVoucherPayableId
		) PT

		SET @recordCountReturned = @recordCountReturned + @@ROWCOUNT;

		--IF ALREADY EXISTS GET PAYABLES KEY
		INSERT INTO @payablesKey(intOldPayableId, intNewPayableId)
		SELECT
			intOldPayableId
			,intNewPayableId
		FROM dbo.fnAPGetPayableCompletedKeyInfo(@voucherPayable) A
		WHERE A.intOldPayableId NOT IN
		(
			--exclude the partial
			SELECT intOldPayableId FROM @payablesKeyPartial
		)
		
		--if unpost and the record were already removed because it has 0 qty, re-insert
		MERGE INTO tblAPVoucherPayable AS destination
		USING (
			SELECT
				D.[intTransactionType]
				,D.[intEntityVendorId]				
				,D.[strVendorId]					
				,D.[strName]						
				,D.[intLocationId]					
				,D.[strLocationName] 				
				,D.[intCurrencyId]					
				,D.[strCurrency]					
				,D.[dtmDate]						
				,D.[strReference]		
				,D.[strLoadShipmentNumber]			
				,D.[strSourceNumber]				
				,D.[intPurchaseDetailId]			
				,D.[strPurchaseOrderNumber]		
				,D.[intContractHeaderId]			
				,D.[intContractDetailId]
				,D.[intPriceFixationDetailId]			
				,D.[intInsuranceChargeDetailId]			
				,D.[intStorageChargeId]			
				,D.[intContractSeqId]				
				,D.[intContractCostId]				
				,D.[strContractNumber]				
				,D.[intScaleTicketId]				
				,D.[strScaleTicketNumber]			
				,D.[intInventoryReceiptItemId]		
				,D.[intInventoryReceiptChargeId]	
				,D.[intInventoryShipmentItemId]	
				,D.[intInventoryShipmentChargeId]
				,D.[intLoadShipmentId]				
				,D.[intLoadShipmentDetailId]	
				,D.[intLoadShipmentCostId]	
				,D.[intWeightClaimId]
				,D.[intWeightClaimDetailId]
				,D.[intItemId]						
				,D.[intLinkingId]		
				,D.[intComputeTotalOption]
				,D.[intLotId]
				,D.[intTicketDistributionAllocationId]			
				,D.[strItemNo]						
				,D.[intPurchaseTaxGroupId]			
				,D.[strTaxGroup]		
				,D.[ysnOverrideTaxGroup]					
				,D.[intItemLocationId]			
				,D.[strItemLocationName]	
				,D.[intStorageLocationId]			
				,D.[strStorageLocationName]		
				,D.[intSubLocationId]			
				,D.[strSubLocationName]		
				,D.[strMiscDescription]			
				,D.[dblOrderQty]					
				,D.[dblOrderUnitQty]				
				,D.[intOrderUOMId]					
				,D.[strOrderUOM]					
				,D.[dblQuantityToBill]	
				,D.[dblQtyToBillUnitQty]			
				,D.[intQtyToBillUOMId]				
				,D.[strQtyToBillUOM]				
				,D.[dblCost]						
				,D.[dblCostUnitQty]				
				,D.[intCostUOMId]					
				,D.[strCostUOM]					
				,D.[dblNetWeight]					
				,D.[dblWeightUnitQty]				
				,D.[intWeightUOMId]				
				,D.[strWeightUOM]					
				,D.[intCostCurrencyId]				
				,D.[strCostCurrency]				
				,D.[dblTax]						
				,D.[dblDiscount]					
				,D.[intCurrencyExchangeRateTypeId]
				,D.[strRateType]					
				,D.[dblExchangeRate]				
				,D.[ysnSubCurrency]				
				,D.[intSubCurrencyCents]			
				,D.[intAccountId]					
				,D.[strAccountId]					
				,D.[strAccountDesc]				
				,D.[intShipViaId]					
				,D.[strShipVia]					
				,D.[intTermId]						
				,D.[strTerm]						
				,D.[strBillOfLading]				
				,D.[int1099Form]					
				,D.[str1099Form]					
				,D.[int1099Category]	
				,D.[dbl1099]			
				,D.[str1099Type]					
				,D.[ysnReturn]		
				,D.[intFreightTermId]
				,D.[strFreightTerm]
				,D.[intBookId]
				,D.[intSubBookId]
				,D.[intPayFromBankAccountId]
				,D.[strPayFromBankAccount]
				,D.[strFinancingSourcedFrom]
				,D.[strFinancingTransactionNumber]
				,D.[strFinanceTradeNo]
				,D.[intBankId]
				,D.[strBankName]
				,D.[intBankAccountId]
				,D.[strBankAccountNo]
				,D.[intBorrowingFacilityId]
				,D.[strBorrowingFacilityId]
				,D.[strBankReferenceNo]
				,D.[intBorrowingFacilityLimitId]
				,D.[strBorrowingFacilityLimit]
				,D.[intBorrowingFacilityLimitDetailId]
				,D.[strLimitDescription]
				,D.[strReferenceNo]
				,D.[intBankValuationRuleId]
				,D.[strBankValuationRule]
				,D.[strComments]
				,D.[dblQualityPremium]
				,D.[dblOptionalityPremium]
				,D.[strTaxPoint]
				,D.[intTaxLocationId]
				,D.[strTaxLocation]
				,D.[intVoucherPayableId]	
				,B.intVoucherPayableId AS intVoucherPayableKey
			-- FROM tblAPBillDetail A
			-- INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
			-- INNER JOIN @voucherIds C ON B.intBillId = C.intId
			FROM @voucherPayable B
			INNER JOIN @payablesKey B2
				ON B.intVoucherPayableId = B2.intOldPayableId
			INNER JOIN tblAPVoucherPayableCompleted D --ON A.intBillDetailId = D.intBillDetailId
				ON B2.intNewPayableId = D.intVoucherPayableId
			-- 		ON D.intTransactionType = B.intTransactionType
			-- AND	ISNULL(D.intPurchaseDetailId,-1) = ISNULL(B.intPurchaseDetailId,-1)
			-- AND ISNULL(D.intContractDetailId,-1) = ISNULL(B.intContractDetailId,-1)
			-- AND ISNULL(D.intEntityVendorId,-1) = ISNULL(B.intEntityVendorId,-1)
			-- AND ISNULL(D.intScaleTicketId,-1) = ISNULL(B.intScaleTicketId,-1)
			-- AND ISNULL(D.intInventoryReceiptChargeId,-1) = ISNULL(B.intInventoryReceiptChargeId,-1)
			-- AND ISNULL(D.intInventoryReceiptItemId,-1) = ISNULL(B.intInventoryReceiptItemId,-1)
			-- --AND ISNULL(C.intLoadDetailId,-1) = ISNULL(B.intLoadShipmentDetailId,-1)
			-- AND ISNULL(D.intLoadShipmentDetailId,-1) = ISNULL(B.intLoadShipmentDetailId,-1)
			-- AND ISNULL(D.intInventoryShipmentChargeId,-1) = ISNULL(B.intInventoryShipmentChargeId,-1)
		) AS SourceData
		ON (1=0)
		WHEN NOT MATCHED THEN
		INSERT (
			[intTransactionType]
			,[intEntityVendorId]				
			,[strVendorId]					
			,[strName]						
			,[intLocationId]					
			,[strLocationName] 				
			,[intCurrencyId]					
			,[strCurrency]					
			,[dtmDate]						
			,[strReference]		
			,[strLoadShipmentNumber]			
			,[strSourceNumber]				
			,[intPurchaseDetailId]			
			,[strPurchaseOrderNumber]		
			,[intContractHeaderId]			
			,[intContractDetailId]	
			,[intPriceFixationDetailId]		
			,[intInsuranceChargeDetailId]		
			,[intStorageChargeId]		
			,[intContractSeqId]				
			,[intContractCostId]				
			,[strContractNumber]				
			,[intScaleTicketId]				
			,[strScaleTicketNumber]			
			,[intInventoryReceiptItemId]		
			,[intInventoryReceiptChargeId]	
			,[intInventoryShipmentItemId]	
			,[intInventoryShipmentChargeId]
			,[intLoadShipmentId]				
			,[intLoadShipmentDetailId]	
			,[intLoadShipmentCostId]
			,[intWeightClaimId]
			,[intWeightClaimDetailId]
			,[intItemId]						
			,[intLinkingId]			
			,[intComputeTotalOption]
			,[intLotId]
			,[intTicketDistributionAllocationId]		
			,[strItemNo]						
			,[intPurchaseTaxGroupId]			
			,[strTaxGroup]			
			,[ysnOverrideTaxGroup]		
			,[intItemLocationId]			
			,[strItemLocationName]		
			,[intStorageLocationId]			
			,[strStorageLocationName]		
			,[intSubLocationId]			
			,[strSubLocationName]		
			,[strMiscDescription]			
			,[dblOrderQty]					
			,[dblOrderUnitQty]				
			,[intOrderUOMId]					
			,[strOrderUOM]					
			,[dblQuantityToBill]
			,[dblQtyToBillUnitQty]			
			,[intQtyToBillUOMId]				
			,[strQtyToBillUOM]				
			,[dblCost]						
			,[dblCostUnitQty]				
			,[intCostUOMId]					
			,[strCostUOM]					
			,[dblNetWeight]					
			,[dblWeightUnitQty]				
			,[intWeightUOMId]				
			,[strWeightUOM]					
			,[intCostCurrencyId]				
			,[strCostCurrency]				
			,[dblTax]						
			,[dblDiscount]					
			,[intCurrencyExchangeRateTypeId]
			,[strRateType]					
			,[dblExchangeRate]				
			,[ysnSubCurrency]				
			,[intSubCurrencyCents]			
			,[intAccountId]					
			,[strAccountId]					
			,[strAccountDesc]				
			,[intShipViaId]					
			,[strShipVia]					
			,[intTermId]						
			,[strTerm]						
			,[strBillOfLading]				
			,[int1099Form]					
			,[str1099Form]					
			,[int1099Category]	
			,[dbl1099]			
			,[str1099Type]					
			,[ysnReturn]	
			,[intFreightTermId]
			,[strFreightTerm]
			,[intBookId]
			,[intSubBookId]
			,[intPayFromBankAccountId]
			,[strPayFromBankAccount]
			,[strFinancingSourcedFrom]
			,[strFinancingTransactionNumber]
			,[strFinanceTradeNo]
			,[intBankId]
			,[strBankName]
			,[intBankAccountId]
			,[strBankAccountNo]
			,[intBorrowingFacilityId]
			,[strBorrowingFacilityId]
			,[strBankReferenceNo]
			,[intBorrowingFacilityLimitId]
			,[strBorrowingFacilityLimit]
			,[intBorrowingFacilityLimitDetailId]
			,[strLimitDescription]
			,[strReferenceNo]
			,[intBankValuationRuleId]
			,[strBankValuationRule]
			,[strComments]
			,[dblQualityPremium]
			,[dblOptionalityPremium]
			,[strTaxPoint]
			,[intTaxLocationId]
			,[strTaxLocation]
		)
		VALUES(
			[intTransactionType]
			,[intEntityVendorId]				
			,[strVendorId]					
			,[strName]						
			,[intLocationId]					
			,[strLocationName] 				
			,[intCurrencyId]					
			,[strCurrency]					
			,[dtmDate]						
			,[strReference]	
			,[strLoadShipmentNumber]				
			,[strSourceNumber]				
			,[intPurchaseDetailId]			
			,[strPurchaseOrderNumber]		
			,[intContractHeaderId]			
			,[intContractDetailId]	
			,[intPriceFixationDetailId]	
			,[intInsuranceChargeDetailId]		
			,[intStorageChargeId]				
			,[intContractSeqId]				
			,[intContractCostId]				
			,[strContractNumber]				
			,[intScaleTicketId]				
			,[strScaleTicketNumber]			
			,[intInventoryReceiptItemId]		
			,[intInventoryReceiptChargeId]	
			,[intInventoryShipmentItemId]	
			,[intInventoryShipmentChargeId]
			,[intLoadShipmentId]				
			,[intLoadShipmentDetailId]		
			,[intLoadShipmentCostId]	
			,[intWeightClaimId]
			,[intWeightClaimDetailId]
			,[intItemId]						
			,[intLinkingId]	
			,[intComputeTotalOption]			
			,[intLotId]			
			,[intTicketDistributionAllocationId]	
			,[strItemNo]						
			,[intPurchaseTaxGroupId]			
			,[strTaxGroup]		
			,[ysnOverrideTaxGroup]			
			,[intItemLocationId]			
			,[strItemLocationName]
			,[intStorageLocationId]			
			,[strStorageLocationName]
			,[intSubLocationId]			
			,[strSubLocationName]				
			,[strMiscDescription]			
			,[dblOrderQty]					
			,[dblOrderUnitQty]				
			,[intOrderUOMId]					
			,[strOrderUOM]					
			,[dblQuantityToBill]
			,[dblQtyToBillUnitQty]			
			,[intQtyToBillUOMId]				
			,[strQtyToBillUOM]				
			,[dblCost]						
			,[dblCostUnitQty]				
			,[intCostUOMId]					
			,[strCostUOM]					
			,[dblNetWeight]					
			,[dblWeightUnitQty]				
			,[intWeightUOMId]				
			,[strWeightUOM]					
			,[intCostCurrencyId]				
			,[strCostCurrency]				
			,[dblTax]						
			,[dblDiscount]					
			,[intCurrencyExchangeRateTypeId]
			,[strRateType]					
			,[dblExchangeRate]				
			,[ysnSubCurrency]				
			,[intSubCurrencyCents]			
			,[intAccountId]					
			,[strAccountId]					
			,[strAccountDesc]				
			,[intShipViaId]					
			,[strShipVia]					
			,[intTermId]						
			,[strTerm]						
			,[strBillOfLading]				
			,[int1099Form]					
			,[str1099Form]					
			,[int1099Category]		
			,[dbl1099]		
			,[str1099Type]					
			,[ysnReturn]	
			,[intFreightTermId]
			,[strFreightTerm]
			,[intBookId]
			,[intSubBookId]
			,[intPayFromBankAccountId]
			,[strPayFromBankAccount]
			,[strFinancingSourcedFrom]
			,[strFinancingTransactionNumber]
			,[strFinanceTradeNo]
			,[intBankId]
			,[strBankName]
			,[intBankAccountId]
			,[strBankAccountNo]
			,[intBorrowingFacilityId]
			,[strBorrowingFacilityId]
			,[strBankReferenceNo]
			,[intBorrowingFacilityLimitId]
			,[strBorrowingFacilityLimit]
			,[intBorrowingFacilityLimitDetailId]
			,[strLimitDescription]
			,[strReferenceNo]
			,[intBankValuationRuleId]
			,[strBankValuationRule]
			,[strComments]
			,[dblQualityPremium]
			,[dblOptionalityPremium]
			,[strTaxPoint]
			,[intTaxLocationId]
			,[strTaxLocation]
		)
		OUTPUT SourceData.intVoucherPayableId, inserted.intVoucherPayableId, SourceData.intVoucherPayableKey INTO @deleted;

		SET @recordCountReturned = @recordCountReturned + @@ROWCOUNT;

		MERGE INTO tblAPVoucherPayableTaxStaging AS destination
		USING (
			SELECT
				del.[intNewPayableId]
				,taxes.intVoucherPayableId	
				,taxes.[intTaxGroupId]				
				,taxes.[intTaxCodeId]				
				,taxes.[intTaxClassId]				
				,taxes.[strTaxableByOtherTaxes]	
				,taxes.[strCalculationMethod]		
				,taxes.[dblRate]					
				,taxes.[intAccountId]				
				,taxes.[dblTax]					
				,taxes.[dblAdjustedTax]			
				,taxes.[ysnTaxAdjusted]			
				,taxes.[ysnSeparateOnBill]			
				,taxes.[ysnCheckOffTax]			
				,taxes.[ysnTaxOnly]
				,taxes.[ysnTaxExempt]
			FROM tblAPVoucherPayableTaxCompleted taxes
			INNER JOIN @deleted del ON taxes.intVoucherPayableId = del.intVoucherPayableId
		) AS SourceData
		ON (1=0)
		WHEN NOT MATCHED THEN
		INSERT (
			[intVoucherPayableId]		
			,[intTaxGroupId]				
			,[intTaxCodeId]				
			,[intTaxClassId]				
			,[strTaxableByOtherTaxes]	
			,[strCalculationMethod]		
			,[dblRate]					
			,[intAccountId]				
			,[dblTax]					
			,[dblAdjustedTax]			
			,[ysnTaxAdjusted]			
			,[ysnSeparateOnBill]			
			,[ysnCheckOffTax]			
			,[ysnTaxOnly]
			,[ysnTaxExempt]
		)
		VALUES (
			[intNewPayableId]		
			,[intTaxGroupId]				
			,[intTaxCodeId]				
			,[intTaxClassId]				
			,[strTaxableByOtherTaxes]	
			,[strCalculationMethod]		
			,[dblRate]					
			,[intAccountId]				
			,[dblTax]					
			,[dblAdjustedTax]			
			,[ysnTaxAdjusted]			
			,[ysnSeparateOnBill]			
			,[ysnCheckOffTax]			
			,[ysnTaxOnly]
			,[ysnTaxExempt]
		);

		--when deleting voucher we should remove the payables on completed
		DELETE A
		FROM tblAPVoucherPayableCompleted A
		INNER JOIN @deleted B ON A.intVoucherPayableId = B.intVoucherPayableId

		DELETE A
		FROM tblAPVoucherPayableTaxCompleted A
		INNER JOIN @deleted B ON A.intVoucherPayableId = B.intVoucherPayableId

		UPDATE A
			SET A.dblTax = A.dblTax + taxData.dblTax, A.dblAdjustedTax = A.dblAdjustedTax + taxData.dblAdjustedTax
		FROM tblAPVoucherPayableTaxStaging A
		INNER JOIN @deleted del
			ON del.intNewPayableId = A.intVoucherPayableId
		-- INNER JOIN @validPayables B
		-- 	ON del.intVoucherPayableKey = B.intVoucherPayableId
		-- INNER JOIN tblAPVoucherPayable C
		-- 	ON del.intNewPayableId = C.intVoucherPayableId
		INNER JOIN @voucherPayableTax taxData
			ON del.intVoucherPayableKey = taxData.intVoucherPayableId
			AND A.intTaxClassId = taxData.intTaxClassId
				AND A.intTaxCodeId = taxData.intTaxCodeId
				AND A.intTaxGroupId = taxData.intTaxGroupId
		-- CROSS APPLY (
		-- 	SELECT
		-- 		*
		-- 	FROM dbo.fnAPRecomputeStagingTaxes(A.intVoucherPayableId, B.dblCost, C.dblQuantityToBill) taxes
		-- 	WHERE A.intTaxCodeId = taxes.intTaxCodeId AND A.intTaxGroupId = taxes.intTaxGroupId
		-- ) taxData

		--UPDATE QTY AFTER REINSERTING
		--UPDATE QTY IF THERE ARE STILL QTY LEFT TO BILL	
		UPDATE B
			SET B.dblQuantityToBill = (B.dblQuantityToBill + C.dblQuantityToBill),
				B.dblNetWeight = (B.dblNetWeight + C.dblNetWeight),
				B.dblQuantityBilled = 0, --when returning to tblAPVoucherPayable, we expect that qty to billed is 0
				B.dblTax = ISNULL(PT.dblRemainingTax, 0)
		FROM tblAPVoucherPayable B
		INNER JOIN @deleted B2
			ON B.intVoucherPayableId = B2.intNewPayableId
		INNER JOIN @voucherPayable C
			ON B2.intVoucherPayableKey = C.intVoucherPayableId
		OUTER APPLY (
			SELECT SUM(dblAdjustedTax) dblRemainingTax
			FROM tblAPVoucherPayableTaxStaging
			WHERE intVoucherPayableId = B.intVoucherPayableId
		) PT
	END
	ELSE
	BEGIN

		--PROVISION ON EDITING THE VoucherPayable,
		--If allowed, what data will be allowed to edit?
		--Ex, if cost, it is not valid as there might be a voucher already created on that cost

		BEGIN
			-- --IF NOT VOUCHER POSTING, THE PROCEDURE WAS CALLED BY INTEGRATED MODULE, EDITED THE DATA
			-- UPDATE B
			-- 	SET B.dblQuantityToBill = C.dblQuantityToBill
			-- 	,B.dblCost = C.dblCost
			-- FROM tblAPVoucherPayable B
			-- INNER JOIN @voucherPayable C
			-- --LEFT JOIN (tblAPBillDetail C INNER JOIN tblAPBill C2 ON C.intBillId = C2.intBillId)
			-- 	ON ISNULL(C.intPurchaseDetailId,-1) = ISNULL(B.intPurchaseDetailId,-1)
			-- 	AND ISNULL(C.intContractDetailId,-1) = ISNULL(B.intContractDetailId,-1)
			-- 	AND ISNULL(C.intScaleTicketId,-1) = ISNULL(B.intScaleTicketId,-1)
			-- 	AND ISNULL(C.intInventoryReceiptChargeId,-1) = ISNULL(B.intInventoryReceiptChargeId,-1)
			-- 	AND ISNULL(C.intInventoryReceiptItemId,-1) = ISNULL(B.intInventoryReceiptItemId,-1)
			-- 	--AND ISNULL(C.intLoadDetailId,-1) = ISNULL(B.intLoadShipmentDetailId,-1)
			-- 	AND ISNULL(C.intLoadShipmentDetailId,-1) = ISNULL(B.intLoadShipmentDetailId,-1)
			-- 	AND ISNULL(C.intInventoryShipmentChargeId,-1) = ISNULL(B.intInventoryShipmentChargeId,-1)

			-- --VALIDATE
			-- --QTY OF VOUCHER PAYABLE SHOULD NOT BE GREATER THAN THE QTY VOUCHERED
			-- DECLARE @overQtyError NVARCHAR(1000);
			-- SELECT TOP 1
			-- 	@overQtyError = C2.strBillId
			-- FROM tblAPBill C2 
			-- INNER JOIN tblAPBillDetail C ON C.intBillId = C2.intBillId
			-- INNER JOIN @voucherPayable B
			-- 	ON ISNULL(C.intPurchaseDetailId,-1) = ISNULL(B.intPurchaseDetailId,-1)
			-- 	AND ISNULL(C.intContractDetailId,-1) = ISNULL(B.intContractDetailId,-1)
			-- 	AND ISNULL(C.intScaleTicketId,-1) = ISNULL(B.intScaleTicketId,-1)
			-- 	AND ISNULL(C.intInventoryReceiptChargeId,-1) = ISNULL(B.intInventoryReceiptChargeId,-1)
			-- 	AND ISNULL(C.intInventoryReceiptItemId,-1) = ISNULL(B.intInventoryReceiptItemId,-1)
			-- 	AND ISNULL(C.intLoadDetailId,-1) = ISNULL(B.intLoadShipmentDetailId,-1)
			-- 	AND ISNULL(C.intInventoryShipmentChargeId,-1) = ISNULL(B.intInventoryShipmentChargeId,-1)
			-- GROUP BY C.intPurchaseDetailId
			-- ,C.intContractDetailId
			-- ,C.intScaleTicketId
			-- ,C.intInventoryReceiptChargeId
			-- ,C.intInventoryReceiptItemId
			-- ,C.intLoadDetailId
			-- ,C.intInventoryShipmentChargeId
			-- ,C2.strBillId
			-- HAVING SUM(C.dblQtyReceived) > SUM(DISTINCT B.dblQuantityToBill)

			-- IF @overQtyError IS NOT NULL
			-- BEGIN
			-- 	SET @overQtyError = 'Unable to update the payable quantity. Please check the quantity of vouchers created.'
			-- 	RETURN;
			-- END

			--CALL REMOVE, TO CLEAN UP THE PAYABLES
			EXEC uspAPRemoveVoucherPayable @voucherPayable = @voucherPayable, @throwError = 1
			EXEC uspAPAddVoucherPayable @voucherPayable = @voucherPayable, @voucherPayableTax = @voucherPayableTax,  @throwError = 1
		END

	END

	SELECT @recordCountToReturn = COUNT(*) FROM @voucherPayable
	IF @recordCountToReturn > 0 AND @recordCountToReturn != @recordCountReturned AND @post = 0
	BEGIN
		RAISERROR('Error occured while updating Voucher Payables.', 16, 1);
		RETURN;
	END

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
