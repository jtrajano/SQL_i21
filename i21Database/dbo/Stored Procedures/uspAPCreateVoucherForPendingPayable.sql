CREATE PROCEDURE [dbo].[uspAPCreateVoucherForPendingPayable]
	@payableId INT
	,@userId AS INT
	,@billCreated NVARCHAR(MAX) OUTPUT
AS

BEGIN  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF  
  
BEGIN TRY  
  
DECLARE @bills NVARCHAR(MAX);  
DECLARE @payableIds AS Id;
DECLARE @payableIdIdentity INT;
DECLARE @transCount INT = @@TRANCOUNT;  
IF @transCount = 0 BEGIN TRANSACTION; 

DECLARE @payables AS VoucherPayable
DECLARE @payableTaxes AS VoucherDetailTax

INSERT INTO @payableIds
SELECT @payableId

INSERT INTO @payables
(
	[intEntityVendorId]				
	/*
		1 = Voucher
		2 = Vendor Prepayment
		3 = Debit Memo
		9 = 1099 Adjustment
		11= Weight Claim
		13= Basis Advance
		14= Deferred Interest
	*/
	,[intTransactionType]			
	,[intLocationId]					
	,[intShipToId]					
	,[intShipFromId]					
	,[intShipFromEntityId]			
	,[intPayToAddressId]				
	,[intCurrencyId]					
	,[dtmDate]						
	,[dtmVoucherDate]				
	,[dtmDueDate]					
	,[strVendorOrderNumber]			
	,[strReference]					
	,[strLoadShipmentNumber]			
	,[strSourceNumber]				
	,[intSubCurrencyCents]			
	,[intShipViaId]					
	,[intTermId]						
	,[strBillOfLading]				
	,[strCheckComment]				
	,[intAPAccount]					
	/*Detail info*/
	,[strMiscDescription]			
	,[intItemId]						
	,[ysnSubCurrency]				
	,[intAccountId]					
	,[ysnReturn]						
	,[intLineNo]						
	,[intItemLocationId]				
	,[intStorageLocationId]			
	,[intSubLocationId]				
	,[dblBasis]						
	,[dblFutures]					
	/*Integration fields*/
	,[intPurchaseDetailId]			
	,[intContractHeaderId]			
	,[intContractCostId]				
	,[intContractSeqId]				
	,[intContractDetailId]			
	,[intScaleTicketId]				
	,[intInventoryReceiptItemId]		
	,[intInventoryReceiptChargeId]	
	,[intInventoryShipmentItemId]	
	,[intInventoryShipmentChargeId]	
	,[intLoadShipmentId]				
	,[intLoadShipmentDetailId]		
	,[intLoadShipmentCostId]
	,[intWeightClaimId]
	,[intWeightClaimDetailId]
	,[intPaycheckHeaderId]			
	,[intCustomerStorageId]			
	,[intCCSiteDetailId]				
	,[intInvoiceId]					
	,[intBuybackChargeId]			
	,[intTicketId]					
	/*Quantity info*/
	,[dblOrderQty]					
	,[dblOrderUnitQty]				
	,[intOrderUOMId]					
	,[dblQuantityToBill]				
	,[dblQtyToBillUnitQty]			
	,[intQtyToBillUOMId]				
	/*Cost info*/
	,[dblCost]						
	,[dblOldCost]					
	,[dblCostUnitQty]				
	,[intCostUOMId]					
	,[intCostCurrencyId]				
	/*Weight info*/
	,[dblWeight]						
	,[dblNetWeight]					
	,[dblWeightUnitQty]				
	,[intWeightUOMId]				
	/*Exchange Rate info*/
	,[intCurrencyExchangeRateTypeId]	
	,[dblExchangeRate]				
	/*Tax info*/
	,[intPurchaseTaxGroupId]
	,[ysnOverrideTaxGroup]			
	,[dblTax]						
	/*Discount Info*/
	,[dblDiscount]					
	,[dblDetailDiscountPercent]		
	,[ysnDiscountOverride]			
	/*Deferred Voucher*/
	,[intDeferredVoucherId]			
	,[dtmDeferredInterestDate]		
	,[dtmInterestAccruedThru]		
	/*Prepaid Info*/
	,[dblPrepayPercentage]			
	,[intPrepayTypeId]				
	/*Claim info*/
	,[dblNetShippedWeight]			
	,[dblWeightLoss]					
	,[dblFranchiseWeight]			
	,[dblFranchiseAmount]			
	,[dblActual]						
	,[dblDifference]					
	/*1099 Info*/
	,[int1099Form]					
	,[int1099Category]				
	,[dbl1099]						
	,[ysnStage]		
	/*Payment Info*/
	,[intPayFromBankAccountId]
	,[strFinancingSourcedFrom]
	,[strFinancingTransactionNumber]
	/*Trade Finance Info*/
	,[strFinanceTradeNo]
	,[intBankId]
	,[intBankAccountId]
	,[intBorrowingFacilityId]
	,[strBankReferenceNo]
	,[intBorrowingFacilityLimitId]
	,[intBorrowingFacilityLimitDetailId]
	,[strReferenceNo]
	,[intBankValuationRuleId]
	,[strComments]
	/*Quality and Optionality Premium*/
	,[dblQualityPremium]
 	,[dblOptionalityPremium]
	 /*Tax Override*/
	,[strTaxPoint]
	,[intTaxLocationId]			
)
SELECT 
	[intEntityVendorId]				
	,[intTransactionType]			
	,[intLocationId]					
	,[intShipToId]					
	,[intShipFromId]					
	,[intShipFromEntityId]			
	,[intPayToAddressId]				
	,[intCurrencyId]					
	,[dtmDate]						
	,[dtmVoucherDate]				
	,[dtmDueDate]					
	,[strVendorOrderNumber]			
	,[strReference]					
	,[strLoadShipmentNumber]			
	,[strSourceNumber]				
	,[intSubCurrencyCents]			
	,[intShipViaId]					
	,[intTermId]						
	,[strBillOfLading]				
	,[strCheckComment]				
	,[intAPAccount]					
	/*Detail info*/
	,[strMiscDescription]			
	,[intItemId]						
	,[ysnSubCurrency]				
	,[intAccountId]					
	,[ysnReturn]						
	,[intLineNo]						
	,[intItemLocationId]				
	,[intStorageLocationId]			
	,[intSubLocationId]				
	,[dblBasis]						
	,[dblFutures]					
	/*Integration fields*/
	,[intPurchaseDetailId]			
	,[intContractHeaderId]			
	,[intContractCostId]				
	,[intContractSeqId]				
	,[intContractDetailId]			
	,[intScaleTicketId]				
	,[intInventoryReceiptItemId]		
	,[intInventoryReceiptChargeId]	
	,[intInventoryShipmentItemId]	
	,[intInventoryShipmentChargeId]	
	,[intLoadShipmentId]				
	,[intLoadShipmentDetailId]		
	,[intLoadShipmentCostId]
	,[intWeightClaimId]
	,[intWeightClaimDetailId]
	,[intPaycheckHeaderId]			
	,[intCustomerStorageId]			
	,[intCCSiteDetailId]				
	,[intInvoiceId]					
	,[intBuybackChargeId]			
	,[intTicketId]					
	/*Quantity info*/
	,[dblOrderQty]					
	,[dblOrderUnitQty]				
	,[intOrderUOMId]					
	,[dblQuantityToBill]				
	,[dblQtyToBillUnitQty]			
	,[intQtyToBillUOMId]				
	/*Cost info*/
	,[dblCost]						
	,[dblOldCost]					
	,[dblCostUnitQty]				
	,[intCostUOMId]					
	,[intCostCurrencyId]				
	/*Weight info*/
	,[dblWeight]						
	,[dblNetWeight]					
	,[dblWeightUnitQty]				
	,[intWeightUOMId]				
	/*Exchange Rate info*/
	,[intCurrencyExchangeRateTypeId]	
	,[dblExchangeRate]				
	/*Tax info*/
	,[intPurchaseTaxGroupId]
	,[ysnOverrideTaxGroup]		
	,[dblTax]						
	/*Discount Info*/
	,[dblDiscount]					
	,[dblDetailDiscountPercent]		
	,[ysnDiscountOverride]			
	/*Deferred Voucher*/
	,[intDeferredVoucherId]			
	,[dtmDeferredInterestDate]		
	,[dtmInterestAccruedThru]		
	/*Prepaid Info*/
	,[dblPrepayPercentage]			
	,[intPrepayTypeId]				
	/*Claim info*/
	,[dblNetShippedWeight]			
	,[dblWeightLoss]					
	,[dblFranchiseWeight]			
	,[dblFranchiseAmount]			
	,[dblActual]						
	,[dblDifference]					
	/*1099 Info*/
	,[int1099Form]					
	,[int1099Category]				
	,[dbl1099]						
	,[ysnStage]	
	/*Payment Info*/
	,[intPayFromBankAccountId]
	,[strFinancingSourcedFrom]
	,[strFinancingTransactionNumber]
	/*Trade Finance Info*/
	,[strFinanceTradeNo]
	,[intBankId]
	,[intBankAccountId]
	,[intBorrowingFacilityId]
	,[strBankReferenceNo]
	,[intBorrowingFacilityLimitId]
	,[intBorrowingFacilityLimitDetailId]
	,[strReferenceNo]
	,[intBankValuationRuleId]
	,[strComments]
	/*Quality and Optionality Premium*/
	,[dblQualityPremium]
 	,[dblOptionalityPremium]
	 /*Tax Override*/
	,[strTaxPoint]
	,[intTaxLocationId]
FROM dbo.fnAPCreateVoucherPayable(@payableIds);

SET @payableIdIdentity = SCOPE_IDENTITY();

INSERT INTO @payableTaxes
(
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
	,[ysnTaxExempt]             
	,[ysnTaxOnly]				
)
SELECT 
	@payableIdIdentity   
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
	,[ysnTaxExempt]             
	,[ysnTaxOnly]		
FROM tblAPVoucherPayableTaxStaging WHERE intVoucherPayableId = @payableId

IF NOT EXISTS(SELECT TOP 1 1 FROM @payables)
BEGIN
	RAISERROR('Payable is already vouchered.', 16, 1);
END

EXEC uspAPCreateVoucher @voucherPayables = @payables, @voucherPayableTax = @payableTaxes, @userId = @userId, @createdVouchersId = @bills OUT

SET @billCreated = @bills;

IF @transCount = 0 COMMIT TRANSACTION;  
  
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
	SET @ErrorProc     = ERROR_PROCEDURE()  

	-- SET @ErrorMessage  = 'Error creating voucher.' + CHAR(13) +   
	-- 'SQL Server Error Message is: ' + CAST(@ErrorNumber AS VARCHAR(10)) +   
	-- ' in procedure: ' + @ErrorProc + ' Line: ' + CAST(@ErrorLine AS VARCHAR(10)) + ' Error text: ' + @ErrorMessage  

	IF (XACT_STATE()) = -1  
	BEGIN  
		ROLLBACK TRANSACTION  
	END  
	ELSE IF (XACT_STATE()) = 1 AND @transCount = 0  
	BEGIN  
		ROLLBACK TRANSACTION  
	END  

	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)  
END CATCH  
  
RETURN 0  
END  