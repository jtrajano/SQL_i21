﻿CREATE PROCEDURE [dbo].[uspAPReverseVoucherPayable]
	@voucherPayable AS VoucherPayable READONLY,
	@voucherPayableTax AS VoucherDetailTax READONLY,
	@post AS BIT = 0,
	@intUserId INT
AS
BEGIN
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT OFF
	SET ANSI_WARNINGS OFF

	DECLARE @id TABLE(intVoucherPayableId INT, intReversedVoucherPayableId INT);

	BEGIN TRY
		IF @post = 1
		BEGIN
			--REVERSE PAYABLE
			MERGE INTO tblAPVoucherPayableReversed AS DESTINATION
			USING (
				SELECT P.*
				FROM tblAPVoucherPayable P
				INNER JOIN @voucherPayable VP ON VP.intLoadShipmentId = P.intLoadShipmentId AND VP.intLoadShipmentDetailId = P.intLoadShipmentDetailId AND VP.intLoadShipmentCostId = P.intLoadShipmentCostId
			) AS SourceData
			ON (1 = 0)
			WHEN NOT MATCHED THEN
			INSERT
			VALUES (
				[intVoucherPayableId], 
				[intTransactionType],
				[intEntityVendorId],
				[strVendorId],
				[strName],
				[intLocationId],
				[strLocationName],
				[intShipToId],
				[intShipFromId],
				[intShipFromEntityId],
				[intPayToAddressId],
				[intCurrencyId],
				[strCurrency],
				[dtmDate],
				[dtmVoucherDate],
				[strReference],
				[strSourceNumber],
				[strVendorOrderNumber],
				[strCheckComment],
				[intPurchaseDetailId],
				[strPurchaseOrderNumber],
				[intContractHeaderId],
				[intContractDetailId],
				[intPriceFixationDetailId],
				[intContractSeqId],
				[intLotId],
				[intContractCostId],
				[strContractNumber],		
				[intScaleTicketId],
				[strScaleTicketNumber],
				[intInventoryReceiptItemId],
				[intInventoryReceiptChargeId],
				[intInventoryShipmentItemId],
				[intInventoryShipmentChargeId],
				[strLoadShipmentNumber],
				[intLoadShipmentId],
				[intLoadShipmentDetailId],
				[intLoadShipmentCostId],
				[intWeightClaimId],
				[intWeightClaimDetailId],
				[intCustomerStorageId],
				[intSettleStorageId],
				[intTicketId],
				[intPaycheckHeaderId],
				[intCCSiteDetailId],
				[intInvoiceId],
				[intBuybackChargeId],
				[intItemId],
				[intLinkingId],
				[intTicketDistributionAllocationId],
				[strItemNo],
				[intFreightTermId],
				[strFreightTerm],
				[intPurchaseTaxGroupId],
				[strTaxGroup],
				[ysnOverrideTaxGroup],
				[intItemLocationId],
				[strItemLocationName],
				[intStorageChargeId],
				[intInsuranceChargeDetailId],
				[intStorageLocationId],
				[strStorageLocationName],	
				[intSubLocationId],	
				[strSubLocationName],			
				[strMiscDescription],		
				[dblOrderQty],		
				[dblOrderUnitQty],	
				[intOrderUOMId],
				[strOrderUOM],
				[dblQuantityToBill],
				[dblQtyToBillUnitQty],	
				[intQtyToBillUOMId],	
				[strQtyToBillUOM],
				[dblQuantityBilled],	
				[dblOldCost],
				[dblCost],		
				[dblCostUnitQty],
				[intCostUOMId],
				[strCostUOM],
				[dblWeight],
				[dblNetWeight],
				[dblWeightUnitQty],
				[intWeightUOMId],	
				[strWeightUOM],
				[intCostCurrencyId],
				[strCostCurrency],
				[dblTax],				
				[dblDiscount],			
				[dblBasis],	
				[dblFutures],
				[dblDetailDiscountPercent],
				[ysnDiscountOverride],
				[intDeferredVoucherId],
				[dtmDeferredInterestDate],
				[dtmInterestAccruedThru],
				[dblPrepayPercentage],
				[intPrepayTypeId],	
				[dblNetShippedWeight],
				[dblWeightLoss],
				[dblFranchiseWeight],
				[dblFranchiseAmount],
				[dblActual],	
				[dblDifference],
				[intCurrencyExchangeRateTypeId],
				[strRateType],
				[dblExchangeRate],
				[ysnSubCurrency],	
				[intSubCurrencyCents],
				[intAPAccount],
				[intAccountId],
				[strAccountId],
				[strAccountDesc],
				[intShipViaId],
				[strShipVia],	
				[intTermId],
				[strTerm],		
				[strBillOfLading],
				[int1099Form],
				[str1099Form],
				[int1099Category],
				[dbl1099],
				[str1099Type],
				[dtmDateEntered],
				[ysnReturn],
				[intLineNo],
				[intBookId],
				[intSubBookId],
				[intComputeTotalOption],

				[intPayFromBankAccountId],
				[strPayFromBankAccount],
				[strFinancingSourcedFrom],
				[strFinancingTransactionNumber],

				[strFinanceTradeNo],
				[intBankId],
				[strBankName],
				[intBankAccountId],
				[strBankAccountNo],
				[intBorrowingFacilityId],
				[strBorrowingFacilityId],
				[strBankReferenceNo],
				[intBorrowingFacilityLimitId],
				[strBorrowingFacilityLimit],
				[intBorrowingFacilityLimitDetailId],
				[strLimitDescription],
				[strReferenceNo],
				[intBankValuationRuleId],
				[strBankValuationRule],
				[strComments],

				[dblQualityPremium],
				[dblOptionalityPremium],

				[strTaxPoint],
				[intTaxLocationId],
				[strTaxLocation],

				[intConcurrencyId]
			)
			OUTPUT
				SourceData.intVoucherPayableId,
				inserted.intVoucherPayableId
			INTO @id;

			--REVERSE TAXES
			MERGE INTO tblAPVoucherPayableTaxReversed AS DESTINATION
			USING (
				SELECT PT.*
				FROM tblAPVoucherPayableTaxStaging PT
				INNER JOIN @id ID ON ID.intVoucherPayableId = PT.intVoucherPayableId
			) AS SourceData
			ON (1 = 0)
			WHEN NOT MATCHED THEN
			INSERT
			VALUES (
				[intVoucherPayableId],
				[intTaxGroupId], 
				[intTaxCodeId], 
				[intTaxClassId], 
				[strTaxableByOtherTaxes], 
				[strCalculationMethod], 
				[dblRate], 
				[intAccountId], 
				[dblTax], 
				[dblAdjustedTax], 
				[ysnTaxAdjusted], 
				[ysnSeparateOnBill], 
				[ysnCheckOffTax],
				[ysnTaxOnly],
				[ysnTaxExempt],
				[dtmDateEntered]
			);

			--DELETE PAYABLE	
			DELETE P
			FROM tblAPVoucherPayable P
			INNER JOIN @id ID ON ID.intVoucherPayableId = P.intVoucherPayableId

			--DELETE TAXES
			DELETE T
			FROM tblAPVoucherPayableTaxStaging PT
			INNER JOIN @id ID ON ID.intVoucherPayableId = PT.intVoucherPayableId

			--CREATE NEW PAYABLE
			EXEC uspAPUpdateVoucherPayableQty @voucherPayable, @voucherPayableTax
		END
		ELSE
		BEGIN
			--REVERSE PAYABLE
			MERGE INTO tblAPVoucherPayable AS DESTINATION
			USING (
				SELECT P.*
				FROM tblAPVoucherPayableReversed P
				INNER JOIN @voucherPayable VP ON VP.intLoadShipmentId = P.intLoadShipmentId AND VP.intLoadShipmentDetailId = P.intLoadShipmentDetailId AND VP.intLoadShipmentCostId = P.intLoadShipmentCostId
			) AS SourceData
			ON (1 = 0)
			WHEN NOT MATCHED THEN
			INSERT
			VALUES ( 
				[intTransactionType],
				[intEntityVendorId],
				[strVendorId],
				[strName],
				[intLocationId],
				[strLocationName],
				[intShipToId],
				[intShipFromId],
				[intShipFromEntityId],
				[intPayToAddressId],
				[intCurrencyId],
				[strCurrency],
				[dtmDate],
				[dtmVoucherDate],
				[strReference],
				[strSourceNumber],
				[strVendorOrderNumber],
				[strCheckComment],
				[intPurchaseDetailId],
				[strPurchaseOrderNumber],
				[intContractHeaderId],
				[intContractDetailId],
				[intPriceFixationDetailId],
				[intContractSeqId],
				[intLotId],
				[intContractCostId],
				[strContractNumber],		
				[intScaleTicketId],
				[strScaleTicketNumber],
				[intInventoryReceiptItemId],
				[intInventoryReceiptChargeId],
				[intInventoryShipmentItemId],
				[intInventoryShipmentChargeId],
				[strLoadShipmentNumber],
				[intLoadShipmentId],
				[intLoadShipmentDetailId],
				[intLoadShipmentCostId],
				[intWeightClaimId],
				[intWeightClaimDetailId],
				[intCustomerStorageId],
				[intSettleStorageId],
				[intTicketId],
				[intPaycheckHeaderId],
				[intCCSiteDetailId],
				[intInvoiceId],
				[intBuybackChargeId],
				[intItemId],
				[intLinkingId],
				[intTicketDistributionAllocationId],
				[strItemNo],
				[intFreightTermId],
				[strFreightTerm],
				[intPurchaseTaxGroupId],
				[strTaxGroup],
				[ysnOverrideTaxGroup],
				[intItemLocationId],
				[strItemLocationName],
				[intStorageChargeId],
				[intInsuranceChargeDetailId],
				[intStorageLocationId],
				[strStorageLocationName],	
				[intSubLocationId],	
				[strSubLocationName],			
				[strMiscDescription],		
				[dblOrderQty],		
				[dblOrderUnitQty],	
				[intOrderUOMId],
				[strOrderUOM],
				[dblQuantityToBill],
				[dblQtyToBillUnitQty],	
				[intQtyToBillUOMId],	
				[strQtyToBillUOM],
				[dblQuantityBilled],	
				[dblOldCost],
				[dblCost],		
				[dblCostUnitQty],
				[intCostUOMId],
				[strCostUOM],
				[dblWeight],
				[dblNetWeight],
				[dblWeightUnitQty],
				[intWeightUOMId],	
				[strWeightUOM],
				[intCostCurrencyId],
				[strCostCurrency],
				[dblTax],				
				[dblDiscount],			
				[dblBasis],	
				[dblFutures],
				[dblDetailDiscountPercent],
				[ysnDiscountOverride],
				[intDeferredVoucherId],
				[dtmDeferredInterestDate],
				[dtmInterestAccruedThru],
				[dblPrepayPercentage],
				[intPrepayTypeId],	
				[dblNetShippedWeight],
				[dblWeightLoss],
				[dblFranchiseWeight],
				[dblFranchiseAmount],
				[dblActual],	
				[dblDifference],
				[intCurrencyExchangeRateTypeId],
				[strRateType],
				[dblExchangeRate],
				[ysnSubCurrency],	
				[intSubCurrencyCents],
				[intAPAccount],
				[intAccountId],
				[strAccountId],
				[strAccountDesc],
				[intShipViaId],
				[strShipVia],	
				[intTermId],
				[strTerm],		
				[strBillOfLading],
				[int1099Form],
				[str1099Form],
				[int1099Category],
				[dbl1099],
				[str1099Type],
				[dtmDateEntered],
				[ysnReturn],
				[intLineNo],
				[intBookId],
				[intSubBookId],
				[intComputeTotalOption],

				[intPayFromBankAccountId],
				[strPayFromBankAccount],
				[strFinancingSourcedFrom],
				[strFinancingTransactionNumber],

				[strFinanceTradeNo],
				[intBankId],
				[strBankName],
				[intBankAccountId],
				[strBankAccountNo],
				[intBorrowingFacilityId],
				[strBorrowingFacilityId],
				[strBankReferenceNo],
				[intBorrowingFacilityLimitId],
				[strBorrowingFacilityLimit],
				[intBorrowingFacilityLimitDetailId],
				[strLimitDescription],
				[strReferenceNo],
				[intBankValuationRuleId],
				[strBankValuationRule],
				[strComments],

				[dblQualityPremium],
				[dblOptionalityPremium],

				[strTaxPoint],
				[intTaxLocationId],
				[strTaxLocation],

				[intConcurrencyId]
			)
			OUTPUT
				inserted.intVoucherPayableId,
				SourceData.intVoucherPayableId
			INTO @id;

			--REVERSE TAXES
			MERGE INTO tblAPVoucherPayableTaxStaging AS DESTINATION
			USING (
				SELECT ID.[intVoucherPayableId],
					   PT.[intTaxGroupId], 
					   PT.[intTaxCodeId], 
					   PT.[intTaxClassId], 
					   PT.[strTaxableByOtherTaxes], 
					   PT.[strCalculationMethod], 
					   PT.[dblRate], 
					   PT.[intAccountId], 
					   PT.[dblTax], 
					   PT.[dblAdjustedTax], 
					   PT.[ysnTaxAdjusted], 
					   PT.[ysnSeparateOnBill], 
					   PT.[ysnCheckOffTax],
					   PT.[ysnTaxOnly],
					   PT.[ysnTaxExempt],
					   PT.[dtmDateEntered]
				FROM tblAPVoucherPayableTaxReversed PT
				INNER JOIN @id ID ON ID.intReversedVoucherPayableId = PT.intVoucherPayableId
			) AS SourceData
			ON (1 = 0)
			WHEN NOT MATCHED THEN
			INSERT
			VALUES (
				[intVoucherPayableId],
				[intTaxGroupId], 
				[intTaxCodeId], 
				[intTaxClassId], 
				[strTaxableByOtherTaxes], 
				[strCalculationMethod], 
				[dblRate], 
				[intAccountId], 
				[dblTax], 
				[dblAdjustedTax], 
				[ysnTaxAdjusted], 
				[ysnSeparateOnBill], 
				[ysnCheckOffTax],
				[ysnTaxOnly],
				[ysnTaxExempt],
				[dtmDateEntered]
			);

			--DELETE PAYABLE	
			DELETE P
			FROM tblAPVoucherPayableReversed P
			INNER JOIN @id ID ON ID.intReversedVoucherPayableId = P.intVoucherPayableId

			--DELETE TAXES
			DELETE T
			FROM tblAPVoucherPayableTaxStaging PT
			INNER JOIN @id ID ON ID.intReversedVoucherPayableId = PT.intVoucherPayableId

			--REMOVE NEW PAYABLE
			DECLARE @inventoryReceiptId INT

			SELECT @inventoryReceiptId = IR.intInventoryReceiptId
			FROM @voucherPayable P
			INNER JOIN tblICInventoryReceiptItem IRI ON IRI.intInventoryReceiptItemId = P.intInventoryReceiptItemId
			INNER JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId

			EXEC uspAPRemoveVoucherPayableTransaction @inventoryReceiptId, NULL, @intUserId
		END
	END TRY

	BEGIN CATCH	
		DECLARE @ErrorMerssage NVARCHAR(MAX)
		SELECT @ErrorMerssage = ERROR_MESSAGE()									
		RAISERROR(@ErrorMerssage, 11, 1);
		RETURN;
	END CATCH
END