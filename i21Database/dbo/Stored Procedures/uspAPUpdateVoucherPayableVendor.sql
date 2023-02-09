CREATE PROCEDURE [dbo].[uspAPUpdateVoucherPayableVendor]
	@voucherPayable AS VoucherPayable READONLY,
	@voucherPayableTax AS VoucherDetailTax READONLY,
	@intUserId INT
AS
BEGIN
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT OFF
	SET ANSI_WARNINGS OFF

	BEGIN TRY
		--DELETE INITIAL CHARGE PAYABLE
		DECLARE @inventoryReceiptChargeId INT
		DECLARE @loadShipmentCostId INT

		SELECT @inventoryReceiptChargeId = P.intInventoryReceiptChargeId,
			   @loadShipmentCostId = P.intLoadShipmentCostId
		FROM @voucherPayable P

		EXEC uspAPRemoveVoucherPayableTransaction NULL, NULL, @inventoryReceiptChargeId, NULL, @loadShipmentCostId, @intUserId

		--CREATE PAYABLE WITH NEW VENDOR
		EXEC uspAPUpdateVoucherPayableQty @voucherPayable, @voucherPayableTax
	END TRY

	BEGIN CATCH	
		DECLARE @ErrorMerssage NVARCHAR(MAX)
		SELECT @ErrorMerssage = ERROR_MESSAGE()									
		RAISERROR(@ErrorMerssage, 11, 1);
		RETURN;
	END CATCH
END