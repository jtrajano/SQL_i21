/*
	Use this stored procedure to update the tblAPVoucherPayable from tblAPBillDetail
	This usually usually call when payables has been added on tblAPBillDetail
	It will reduce/increase the tblAPVoucherPayable base on certain events happened on voucher(edit, delete, add)
*/
CREATE PROCEDURE [dbo].[uspAPUpdateVoucherPayable]
	@voucherDetailIds AS Id READONLY,
	@decrease BIT = 0
AS


SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @SavePoint NVARCHAR(32) = 'uspAPUpdateVoucherPayable';
DECLARE @voucherPayables AS VoucherPayable;
DECLARE @voucherPayableTax AS VoucherDetailTax;
DECLARE @post BIT = ~@decrease;
DECLARE @transCount INT = @@TRANCOUNT;

INSERT INTO @voucherPayables(
	[intBillId]
	,[intEntityVendorId]                
	,[intTransactionType]                
	,[intLocationId]                    
	,[intShipToId]                        
	,[intShipFromId]                    
	,[intShipFromEntityId]                
	,[intPayToAddressId]                
	,[intCurrencyId]                    
	,[dtmDate]                            
	,[strVendorOrderNumber]                
	,[strReference]                        
	,[strSourceNumber]                    
	,[intSubCurrencyCents]                
	,[intShipViaId]                        
	,[intTermId]                        
	,[strBillOfLading]                    
	,[intAPAccount]                        
	,[strMiscDescription]                
	,[intItemId]                        
	,[ysnSubCurrency]                    
	,[intAccountId]                        
	,[ysnReturn]                        
	,[intLineNo]                        
	,[intStorageLocationId]                
	,[dblBasis]                            
	,[dblFutures]                        
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
	,[intPaycheckHeaderId]                
	,[intCustomerStorageId]   
	,[intSettleStorageId]             
	,[intCCSiteDetailId]                
	,[intInvoiceId]                        
	,[intBuybackChargeId]                
	,[dblOrderQty]                        
	,[dblOrderUnitQty]                    
	,[intOrderUOMId]                    
	,[dblQuantityToBill]                
	,[dblQtyToBillUnitQty]                
	,[intQtyToBillUOMId]                
	,[dblCost]                            
	,[dblOldCost]                        
	,[dblCostUnitQty]                    
	,[intCostUOMId]                        
	,[intCostCurrencyId]                
	,[dblWeight]                        
	,[dblNetWeight]                        
	,[dblWeightUnitQty]                    
	,[intWeightUOMId]                    
	,[intCurrencyExchangeRateTypeId]    
	,[dblExchangeRate]                    
	,[intPurchaseTaxGroupId]            
	,[dblTax]                            
	,[dblDiscount]                        
	,[dblDetailDiscountPercent]            
	,[ysnDiscountOverride]                
	,[intDeferredVoucherId]                
	,[dblPrepayPercentage]                
	,[intPrepayTypeId]                    
	,[dblNetShippedWeight]                
	,[dblWeightLoss]                    
	,[dblFranchiseWeight]                
	,[dblFranchiseAmount]                
	,[dblActual]                        
	,[dblDifference]  
	,[intFreightTermId]
)
SELECT
	[intBillId]
	,[intEntityVendorId]                
	,[intTransactionType]                
	,[intLocationId]                    
	,[intShipToId]                        
	,[intShipFromId]                    
	,[intShipFromEntityId]                
	,[intPayToAddressId]                
	,[intCurrencyId]                    
	,[dtmDate]                            
	,[strVendorOrderNumber]                
	,[strReference]                        
	,[strSourceNumber]                    
	,[intSubCurrencyCents]                
	,[intShipViaId]                        
	,[intTermId]                        
	,[strBillOfLading]                    
	,[intAPAccount]                        
	,[strMiscDescription]                
	,[intItemId]                        
	,[ysnSubCurrency]                    
	,[intAccountId]                        
	,[ysnReturn]                        
	,[intLineNo]                        
	,[intStorageLocationId]                
	,[dblBasis]                            
	,[dblFutures]                        
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
	,[intPaycheckHeaderId]                
	,[intCustomerStorageId]   
	,[intSettleStorageId]             
	,[intCCSiteDetailId]                
	,[intInvoiceId]                        
	,[intBuybackChargeId]                
	,[dblOrderQty]                        
	,[dblOrderUnitQty]                    
	,[intOrderUOMId]                    
	,[dblQuantityToBill]                
	,[dblQtyToBillUnitQty]                
	,[intQtyToBillUOMId]                
	,[dblCost]                            
	,[dblOldCost]                        
	,[dblCostUnitQty]                    
	,[intCostUOMId]                        
	,[intCostCurrencyId]                
	,[dblWeight]                        
	,[dblNetWeight]                        
	,[dblWeightUnitQty]                    
	,[intWeightUOMId]                    
	,[intCurrencyExchangeRateTypeId]    
	,[dblExchangeRate]                    
	,[intPurchaseTaxGroupId]            
	,[dblTax]                            
	,[dblDiscount]                        
	,[dblDetailDiscountPercent]            
	,[ysnDiscountOverride]                
	,[intDeferredVoucherId]                
	,[dblPrepayPercentage]                
	,[intPrepayTypeId]                    
	,[dblNetShippedWeight]                
	,[dblWeightLoss]                    
	,[dblFranchiseWeight]                
	,[dblFranchiseAmount]                
	,[dblActual]                        
	,[dblDifference]
	,[intFreightTermId]
FROM dbo.fnAPCreateVoucherPayableFromDetail(@voucherDetailIds)

INSERT INTO @voucherPayableTax
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
	B.[intVoucherPayableId]       
	,A.[intTaxGroupId]				
	,A.[intTaxCodeId]				
	,A.[intTaxClassId]				
	,A.[strTaxableByOtherTaxes]	
	,A.[strCalculationMethod]		
	,A.[dblRate]					
	,A.[intAccountId]				
	,A.[dblTax]					
	,A.[dblAdjustedTax]			
	,A.[ysnTaxAdjusted]			
	,A.[ysnSeparateOnBill]			
	,A.[ysnCheckOffTax]			
	,A.[ysnTaxExempt]              
	,A.[ysnTaxOnly]
FROM dbo.fnAPCreateVoucherPayableTaxFromDetail(@voucherDetailIds) A
INNER JOIN @primaryKeys B ON A.intBillDetailId = B.intBillDetailId
WHERE ysnStage = 1

IF NOT EXISTS(SELECT TOP 1 1 FROM @voucherPayables) RETURN;

IF @transCount = 0 BEGIN TRANSACTION
ELSE SAVE TRAN @SavePoint

EXEC uspAPUpdateVoucherPayableQty 
	@voucherPayable = @voucherPayables,
	@post = @post,
	@throwError = 1,
	@error = NULL

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