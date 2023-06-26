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
		IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpVoucherPayable')) DROP TABLE #tmpVoucherPayable
		SELECT *
		INTO #tmpVoucherPayable
		FROM @voucherPayable

		WHILE EXISTS(SELECT TOP 1 1 FROM #tmpVoucherPayable)
		BEGIN
			DECLARE @voucherPayableId INT
			DECLARE @inventoryReceiptChargeId INT
			DECLARE @loadShipmentCostId INT

			SELECT TOP 1 @voucherPayableId = P.intVoucherPayableId,
					     @inventoryReceiptChargeId = P.intInventoryReceiptChargeId,
					     @loadShipmentCostId = P.intLoadShipmentCostId
			FROM #tmpVoucherPayable P

			EXEC uspAPRemoveVoucherPayableTransaction NULL, NULL, @inventoryReceiptChargeId, NULL, @loadShipmentCostId, @intUserId

			DELETE FROM #tmpVoucherPayable WHERE intVoucherPayableId = @voucherPayableId
		END

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