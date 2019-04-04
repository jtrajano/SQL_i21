CREATE PROCEDURE [dbo].[uspCTManagePayable]
	@id INT,
	@type NVARCHAR(10),
	@remove BIT = 0
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @voucherPayables AS VoucherPayable;
DECLARE @voucherPayableTax AS VoucherDetailTax;

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
SELECT * FROM dbo.fnCTCreateVoucherPayable(@id, @type);

IF @remove = 0
BEGIN
	EXEC uspAPUpdateVoucherPayableQty @voucherPayable = @voucherPayables, @voucherPayableTax = @voucherPayableTax
END
ELSE
BEGIN
	EXEC uspAPRemoveVoucherPayable @voucherPayables, DEFAULT, DEFAULT
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

	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH