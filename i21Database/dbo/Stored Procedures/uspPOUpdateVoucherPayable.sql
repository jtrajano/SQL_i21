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
DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION
ELSE SAVE TRAN @SavePoint

INSERT INTO @voucherPayables(
	[intEntityVendorId]					
	,[intLocationId]					
	,[intCurrencyId]					
	,[dtmDate]							
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

IF @remove = 0
BEGIN
	EXEC uspAPUpdateVoucherPayableQty @voucherPayables, NULL
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
	ELSE
		BEGIN
			IF (XACT_STATE()) = -1
			BEGIN
				ROLLBACK TRANSACTION  @SavePoint
			END
		END	

	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH