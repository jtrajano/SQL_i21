CREATE PROCEDURE [dbo].[uspPOUpdateVoucherPayable]
	@poDetailIds AS Id READONLY,
	@remove BIT = 0
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @SavePoint NVARCHAR(32) = 'uspPOUpdateVoucherPayable';
DECLARE @voucherPayables AS VoucherPayable;
DECLARE @voucherPayableTax AS VoucherDetailTax;
DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION
ELSE SAVE TRAN @SavePoint

INSERT INTO @voucherPayables(
	[intEntityVendorId]			
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
	,[intPurchaseDetailId]				
	,[intContractHeaderId]				
	,[intContractDetailId]				
	,[intContractSeqId]					
	,[intScaleTicketId]					
	,[intInventoryReceiptItemId]		
	,[intInventoryReceiptChargeId]		
	,[intInventoryShipmentItemId]		
	,[intInventoryShipmentChargeId]		
	,[intLoadShipmentId]				
	,[intLoadShipmentDetailId]			
	,[intItemId]						
	,[intPurchaseTaxGroupId]			
	,[strMiscDescription]				
	,[dblOrderQty]						
	,[dblOrderUnitQty]					
	,[intOrderUOMId]					
	,[dblQuantityToBill]				
	,[dblQtyToBillUnitQty]				
	,[intQtyToBillUOMId]				
	,[dblCost]							
	,[dblCostUnitQty]					
	,[intCostUOMId]						
	,[dblNetWeight]						
	,[dblWeightUnitQty]					
	,[intWeightUOMId]					
	,[intCostCurrencyId]
	,[dblTax]							
	,[dblDiscount]
	,[intCurrencyExchangeRateTypeId]	
	,[dblExchangeRate]					
	,[ysnSubCurrency]					
	,[intSubCurrencyCents]				
	,[intAccountId]						
	,[intShipViaId]						
	,[intTermId]						
	,[strBillOfLading]					
	,[ysnReturn]						
)
SELECT * FROM dbo.fnAPCreatePOVoucherPayable(@poDetailIds);

INSERT INTO @voucherPayableTax (
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
	[intVoucherPayableId]		=	payables.intVoucherPayableId,
	[intTaxGroupId]				=	A.intTaxGroupId, 
	[intTaxCodeId]				=	A.intTaxCodeId, 
	[intTaxClassId]				=	A.intTaxClassId, 
	[strTaxableByOtherTaxes]	=	A.strTaxableByOtherTaxes, 
	[strCalculationMethod]		=	A.strCalculationMethod, 
	[dblRate]					=	A.dblRate, 
	[intAccountId]				=	A.intAccountId, 
	[dblTax]					=	A.dblTax, 
	[dblAdjustedTax]			=	ISNULL(A.dblAdjustedTax,0), 
	[ysnTaxAdjusted]			=	A.ysnTaxAdjusted, 
	[ysnSeparateOnBill]			=	A.ysnSeparateOnBill, 
	[ysnCheckOffTax]			=	A.ysnCheckOffTax,
	[ysnTaxExempt]				=	A.ysnTaxExempt,
	[ysnTaxOnly]				=	A.ysnTaxOnly
FROM tblPOPurchaseDetailTax A
INNER JOIN tblPOPurchaseDetail B ON A.intPurchaseDetailId = B.intPurchaseDetailId
INNER JOIN @voucherPayables payables ON B.intPurchaseDetailId = payables.intPurchaseDetailId
LEFT JOIN tblICItem C ON B.intItemId = C.intItemId
WHERE 
	--(C.strType IN ('Service','Software','Non-Inventory','Other Charge') OR B.intItemId IS NULL) 
	(dbo.fnIsStockTrackingItem(C.intItemId) = 0 OR C.intItemId IS NULL)
AND payables.dblTax != 0

IF @remove = 0
BEGIN
	--WE NEED TO DIRECTLY DELETE PAYABLE WITH THE UPDATED ITEM, uspAPRemoveVoucherPayable CAN'T HANDLE IT BECAUSE THE intItemId IS BEING CHANGED
	--WITH OUR CURRENT LOGIC IN uspAPUpdateVoucherPayableQty THE PAYABLE IS ALSO REMOVED FIRST BEFORE READDING
	EXEC uspAPRemoveVoucherPayableTransaction @intPurchaseDetailIds = @poDetailIds
	
	EXEC uspAPUpdateVoucherPayableQty @voucherPayable = @voucherPayables, @voucherPayableTax = @voucherPayableTax
END
ELSE
BEGIN
	EXEC uspAPRemoveVoucherPayable @voucherPayables, DEFAULT, DEFAULT
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