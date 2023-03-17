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
			INSERT (
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
			VALUES (
				SourceData.[intVoucherPayableId], 
				SourceData.[intTransactionType],
				SourceData.[intEntityVendorId],
				SourceData.[strVendorId],
				SourceData.[strName],
				SourceData.[intLocationId],
				SourceData.[strLocationName],
				SourceData.[intShipToId],
				SourceData.[intShipFromId],
				SourceData.[intShipFromEntityId],
				SourceData.[intPayToAddressId],
				SourceData.[intCurrencyId],
				SourceData.[strCurrency],
				SourceData.[dtmDate],
				SourceData.[dtmVoucherDate],
				SourceData.[strReference],
				SourceData.[strSourceNumber],
				SourceData.[strVendorOrderNumber],
				SourceData.[strCheckComment],
				SourceData.[intPurchaseDetailId],
				SourceData.[strPurchaseOrderNumber],
				SourceData.[intContractHeaderId],
				SourceData.[intContractDetailId],
				SourceData.[intPriceFixationDetailId],
				SourceData.[intContractSeqId],
				SourceData.[intLotId],
				SourceData.[intContractCostId],
				SourceData.[strContractNumber],		
				SourceData.[intScaleTicketId],
				SourceData.[strScaleTicketNumber],
				SourceData.[intInventoryReceiptItemId],
				SourceData.[intInventoryReceiptChargeId],
				SourceData.[intInventoryShipmentItemId],
				SourceData.[intInventoryShipmentChargeId],
				SourceData.[strLoadShipmentNumber],
				SourceData.[intLoadShipmentId],
				SourceData.[intLoadShipmentDetailId],
				SourceData.[intLoadShipmentCostId],
				SourceData.[intWeightClaimId],
				SourceData.[intWeightClaimDetailId],
				SourceData.[intCustomerStorageId],
				SourceData.[intSettleStorageId],
				SourceData.[intTicketId],
				SourceData.[intPaycheckHeaderId],
				SourceData.[intCCSiteDetailId],
				SourceData.[intInvoiceId],
				SourceData.[intBuybackChargeId],
				SourceData.[intItemId],
				SourceData.[intLinkingId],
				SourceData.[intTicketDistributionAllocationId],
				SourceData.[strItemNo],
				SourceData.[intFreightTermId],
				SourceData.[strFreightTerm],
				SourceData.[intPurchaseTaxGroupId],
				SourceData.[strTaxGroup],
				SourceData.[ysnOverrideTaxGroup],
				SourceData.[intItemLocationId],
				SourceData.[strItemLocationName],
				SourceData.[intStorageChargeId],
				SourceData.[intInsuranceChargeDetailId],
				SourceData.[intStorageLocationId],
				SourceData.[strStorageLocationName],	
				SourceData.[intSubLocationId],	
				SourceData.[strSubLocationName],			
				SourceData.[strMiscDescription],		
				SourceData.[dblOrderQty],		
				SourceData.[dblOrderUnitQty],	
				SourceData.[intOrderUOMId],
				SourceData.[strOrderUOM],
				SourceData.[dblQuantityToBill],
				SourceData.[dblQtyToBillUnitQty],	
				SourceData.[intQtyToBillUOMId],	
				SourceData.[strQtyToBillUOM],
				SourceData.[dblQuantityBilled],	
				SourceData.[dblOldCost],
				SourceData.[dblCost],		
				SourceData.[dblCostUnitQty],
				SourceData.[intCostUOMId],
				SourceData.[strCostUOM],
				SourceData.[dblWeight],
				SourceData.[dblNetWeight],
				SourceData.[dblWeightUnitQty],
				SourceData.[intWeightUOMId],	
				SourceData.[strWeightUOM],
				SourceData.[intCostCurrencyId],
				SourceData.[strCostCurrency],
				SourceData.[dblTax],				
				SourceData.[dblDiscount],			
				SourceData.[dblBasis],	
				SourceData.[dblFutures],
				SourceData.[dblDetailDiscountPercent],
				SourceData.[ysnDiscountOverride],
				SourceData.[intDeferredVoucherId],
				SourceData.[dtmDeferredInterestDate],
				SourceData.[dtmInterestAccruedThru],
				SourceData.[dblPrepayPercentage],
				SourceData.[intPrepayTypeId],	
				SourceData.[dblNetShippedWeight],
				SourceData.[dblWeightLoss],
				SourceData.[dblFranchiseWeight],
				SourceData.[dblFranchiseAmount],
				SourceData.[dblActual],	
				SourceData.[dblDifference],
				SourceData.[intCurrencyExchangeRateTypeId],
				SourceData.[strRateType],
				SourceData.[dblExchangeRate],
				SourceData.[ysnSubCurrency],	
				SourceData.[intSubCurrencyCents],
				SourceData.[intAPAccount],
				SourceData.[intAccountId],
				SourceData.[strAccountId],
				SourceData.[strAccountDesc],
				SourceData.[intShipViaId],
				SourceData.[strShipVia],	
				SourceData.[intTermId],
				SourceData.[strTerm],		
				SourceData.[strBillOfLading],
				SourceData.[int1099Form],
				SourceData.[str1099Form],
				SourceData.[int1099Category],
				SourceData.[dbl1099],
				SourceData.[str1099Type],
				SourceData.[dtmDateEntered],
				SourceData.[ysnReturn],
				SourceData.[intLineNo],
				SourceData.[intBookId],
				SourceData.[intSubBookId],
				SourceData.[intComputeTotalOption],
				SourceData.[intPayFromBankAccountId],
				SourceData.[strPayFromBankAccount],
				SourceData.[strFinancingSourcedFrom],
				SourceData.[strFinancingTransactionNumber],
				SourceData.[strFinanceTradeNo],
				SourceData.[intBankId],
				SourceData.[strBankName],
				SourceData.[intBankAccountId],
				SourceData.[strBankAccountNo],
				SourceData.[intBorrowingFacilityId],
				SourceData.[strBorrowingFacilityId],
				SourceData.[strBankReferenceNo],
				SourceData.[intBorrowingFacilityLimitId],
				SourceData.[strBorrowingFacilityLimit],
				SourceData.[intBorrowingFacilityLimitDetailId],
				SourceData.[strLimitDescription],
				SourceData.[strReferenceNo],
				SourceData.[intBankValuationRuleId],
				SourceData.[strBankValuationRule],
				SourceData.[strComments],
				SourceData.[dblQualityPremium],
				SourceData.[dblOptionalityPremium],
				SourceData.[strTaxPoint],
				SourceData.[intTaxLocationId],
				SourceData.[strTaxLocation],
				SourceData.[intConcurrencyId]
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
				SourceData.[intVoucherPayableId],
				SourceData.[intTaxGroupId], 
				SourceData.[intTaxCodeId], 
				SourceData.[intTaxClassId], 
				SourceData.[strTaxableByOtherTaxes], 
				SourceData.[strCalculationMethod], 
				SourceData.[dblRate], 
				SourceData.[intAccountId], 
				SourceData.[dblTax], 
				SourceData.[dblAdjustedTax], 
				SourceData.[ysnTaxAdjusted], 
				SourceData.[ysnSeparateOnBill], 
				SourceData.[ysnCheckOffTax],
				SourceData.[ysnTaxOnly],
				SourceData.[ysnTaxExempt],
				SourceData.[dtmDateEntered]
			);

			--REMOVE PAYABLE
			DECLARE @loadCostIds Id
			INSERT INTO @loadCostIds
			SELECT intLoadShipmentCostId FROM @voucherPayable WHERE intLoadShipmentCostId IS NOT NULL

			WHILE EXISTS(SELECT TOP 1 1 FROM @loadCostIds)
			BEGIN
				DECLARE @loadCostId INT
				SELECT TOP 1 @loadCostId = intId FROM @loadCostIds

				EXEC uspAPRemoveVoucherPayableTransaction NULL, NULL, NULL, NULL, @loadCostId, @intUserId

				DELETE FROM @loadCostIds WHERE intId = @loadCostId
			END

			--CREATE NEW PAYABLE
			EXEC uspAPUpdateVoucherPayableQty @voucherPayable, @voucherPayableTax
		END
		ELSE
		BEGIN
			--REMOVE NEW PAYABLE
			DECLARE @inventoryReceiptChargeIds Id
			INSERT INTO @inventoryReceiptChargeIds
			SELECT intInventoryReceiptChargeId FROM @voucherPayable WHERE intInventoryReceiptChargeId IS NOT NULL

			WHILE EXISTS(SELECT TOP 1 1 FROM @inventoryReceiptChargeIds)
			BEGIN
				DECLARE @inventoryReceiptChargeId INT
				SELECT TOP 1 @inventoryReceiptChargeId = intId FROM @inventoryReceiptChargeIds

				EXEC uspAPRemoveVoucherPayableTransaction NULL, NULL, @inventoryReceiptChargeId, NULL, NULL, @intUserId

				DELETE FROM @inventoryReceiptChargeIds WHERE intId = @inventoryReceiptChargeId
			END

			--REVERSE PAYABLE
			MERGE INTO tblAPVoucherPayable AS DESTINATION
			USING (
				SELECT P.*
				FROM tblAPVoucherPayableReversed P
				INNER JOIN @voucherPayable VP ON VP.intLoadShipmentId = P.intLoadShipmentId AND VP.intLoadShipmentDetailId = P.intLoadShipmentDetailId AND VP.intLoadShipmentCostId = P.intLoadShipmentCostId
			) AS SourceData
			ON (1 = 0)
			WHEN NOT MATCHED THEN
			INSERT (
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
			VALUES ( 
				SourceData.[intTransactionType],
				SourceData.[intEntityVendorId],
				SourceData.[strVendorId],
				SourceData.[strName],
				SourceData.[intLocationId],
				SourceData.[strLocationName],
				SourceData.[intShipToId],
				SourceData.[intShipFromId],
				SourceData.[intShipFromEntityId],
				SourceData.[intPayToAddressId],
				SourceData.[intCurrencyId],
				SourceData.[strCurrency],
				SourceData.[dtmDate],
				SourceData.[dtmVoucherDate],
				SourceData.[strReference],
				SourceData.[strSourceNumber],
				SourceData.[strVendorOrderNumber],
				SourceData.[strCheckComment],
				SourceData.[intPurchaseDetailId],
				SourceData.[strPurchaseOrderNumber],
				SourceData.[intContractHeaderId],
				SourceData.[intContractDetailId],
				SourceData.[intPriceFixationDetailId],
				SourceData.[intContractSeqId],
				SourceData.[intLotId],
				SourceData.[intContractCostId],
				SourceData.[strContractNumber],		
				SourceData.[intScaleTicketId],
				SourceData.[strScaleTicketNumber],
				SourceData.[intInventoryReceiptItemId],
				SourceData.[intInventoryReceiptChargeId],
				SourceData.[intInventoryShipmentItemId],
				SourceData.[intInventoryShipmentChargeId],
				SourceData.[strLoadShipmentNumber],
				SourceData.[intLoadShipmentId],
				SourceData.[intLoadShipmentDetailId],
				SourceData.[intLoadShipmentCostId],
				SourceData.[intWeightClaimId],
				SourceData.[intWeightClaimDetailId],
				SourceData.[intCustomerStorageId],
				SourceData.[intSettleStorageId],
				SourceData.[intTicketId],
				SourceData.[intPaycheckHeaderId],
				SourceData.[intCCSiteDetailId],
				SourceData.[intInvoiceId],
				SourceData.[intBuybackChargeId],
				SourceData.[intItemId],
				SourceData.[intLinkingId],
				SourceData.[intTicketDistributionAllocationId],
				SourceData.[strItemNo],
				SourceData.[intFreightTermId],
				SourceData.[strFreightTerm],
				SourceData.[intPurchaseTaxGroupId],
				SourceData.[strTaxGroup],
				SourceData.[ysnOverrideTaxGroup],
				SourceData.[intItemLocationId],
				SourceData.[strItemLocationName],
				SourceData.[intStorageChargeId],
				SourceData.[intInsuranceChargeDetailId],
				SourceData.[intStorageLocationId],
				SourceData.[strStorageLocationName],	
				SourceData.[intSubLocationId],	
				SourceData.[strSubLocationName],			
				SourceData.[strMiscDescription],		
				SourceData.[dblOrderQty],		
				SourceData.[dblOrderUnitQty],	
				SourceData.[intOrderUOMId],
				SourceData.[strOrderUOM],
				SourceData.[dblQuantityToBill],
				SourceData.[dblQtyToBillUnitQty],	
				SourceData.[intQtyToBillUOMId],	
				SourceData.[strQtyToBillUOM],
				SourceData.[dblQuantityBilled],	
				SourceData.[dblOldCost],
				SourceData.[dblCost],		
				SourceData.[dblCostUnitQty],
				SourceData.[intCostUOMId],
				SourceData.[strCostUOM],
				SourceData.[dblWeight],
				SourceData.[dblNetWeight],
				SourceData.[dblWeightUnitQty],
				SourceData.[intWeightUOMId],	
				SourceData.[strWeightUOM],
				SourceData.[intCostCurrencyId],
				SourceData.[strCostCurrency],
				SourceData.[dblTax],				
				SourceData.[dblDiscount],			
				SourceData.[dblBasis],	
				SourceData.[dblFutures],
				SourceData.[dblDetailDiscountPercent],
				SourceData.[ysnDiscountOverride],
				SourceData.[intDeferredVoucherId],
				SourceData.[dtmDeferredInterestDate],
				SourceData.[dtmInterestAccruedThru],
				SourceData.[dblPrepayPercentage],
				SourceData.[intPrepayTypeId],	
				SourceData.[dblNetShippedWeight],
				SourceData.[dblWeightLoss],
				SourceData.[dblFranchiseWeight],
				SourceData.[dblFranchiseAmount],
				SourceData.[dblActual],	
				SourceData.[dblDifference],
				SourceData.[intCurrencyExchangeRateTypeId],
				SourceData.[strRateType],
				SourceData.[dblExchangeRate],
				SourceData.[ysnSubCurrency],	
				SourceData.[intSubCurrencyCents],
				SourceData.[intAPAccount],
				SourceData.[intAccountId],
				SourceData.[strAccountId],
				SourceData.[strAccountDesc],
				SourceData.[intShipViaId],
				SourceData.[strShipVia],	
				SourceData.[intTermId],
				SourceData.[strTerm],		
				SourceData.[strBillOfLading],
				SourceData.[int1099Form],
				SourceData.[str1099Form],
				SourceData.[int1099Category],
				SourceData.[dbl1099],
				SourceData.[str1099Type],
				SourceData.[dtmDateEntered],
				SourceData.[ysnReturn],
				SourceData.[intLineNo],
				SourceData.[intBookId],
				SourceData.[intSubBookId],
				SourceData.[intComputeTotalOption],
				SourceData.[intPayFromBankAccountId],
				SourceData.[strPayFromBankAccount],
				SourceData.[strFinancingSourcedFrom],
				SourceData.[strFinancingTransactionNumber],
				SourceData.[strFinanceTradeNo],
				SourceData.[intBankId],
				SourceData.[strBankName],
				SourceData.[intBankAccountId],
				SourceData.[strBankAccountNo],
				SourceData.[intBorrowingFacilityId],
				SourceData.[strBorrowingFacilityId],
				SourceData.[strBankReferenceNo],
				SourceData.[intBorrowingFacilityLimitId],
				SourceData.[strBorrowingFacilityLimit],
				SourceData.[intBorrowingFacilityLimitDetailId],
				SourceData.[strLimitDescription],
				SourceData.[strReferenceNo],
				SourceData.[intBankValuationRuleId],
				SourceData.[strBankValuationRule],
				SourceData.[strComments],
				SourceData.[dblQualityPremium],
				SourceData.[dblOptionalityPremium],
				SourceData.[strTaxPoint],
				SourceData.[intTaxLocationId],
				SourceData.[strTaxLocation],
				SourceData.[intConcurrencyId]
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
			DELETE PT
			FROM tblAPVoucherPayableTaxReversed PT
			INNER JOIN @id ID ON ID.intReversedVoucherPayableId = PT.intVoucherPayableId
		END
	END TRY

	BEGIN CATCH	
		DECLARE @ErrorMerssage NVARCHAR(MAX)
		SELECT @ErrorMerssage = ERROR_MESSAGE()									
		RAISERROR(@ErrorMerssage, 11, 1);
		RETURN;
	END CATCH
END