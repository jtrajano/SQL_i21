CREATE PROCEDURE [dbo].[uspCTDeleteBasisUnAccruedPayable]
	@id INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @voucherPayables AS VoucherPayable;
DECLARE @voucherPayableTax AS VoucherDetailTax;

DECLARE @detailId INT
DECLARE @payables TABLE 
( 
	intPayableKey          INT IDENTITY(1,1),			
	intContractDetailId		INT	
)

INSERT INTO @payables
SELECT intContractCostId
FROM tblCTContractCost
WHERE intContractDetailId IN
(
	SELECT intContractDetailId
	FROM tblCTContractDetail
	WHERE intContractHeaderId = @id
)
AND ysnAccrue = 0 --AND ysnBasis = 1 

DECLARE @intPayableKey INT
SELECT @intPayableKey = MIN(intPayableKey) 
FROM @payables 
	
WHILE @intPayableKey > 0 
BEGIN
	SELECT @detailId = intContractDetailId 
	FROM @payables 
	WHERE intPayableKey = @intPayableKey

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
		,[intContractCostId]
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
	SELECT * FROM dbo.fnCTCreateVoucherPayable(@detailId, 'cost', 0, 1);

	IF EXISTS(SELECT * FROM @voucherPayables)
	BEGIN	
		EXEC uspAPRemoveVoucherPayable @voucherPayables, DEFAULT, DEFAULT
	END



	SELECT @intPayableKey = MIN(intPayableKey)
	FROM @payables
	WHERE intPayableKey > @intPayableKey

	DELETE FROM @voucherPayables
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