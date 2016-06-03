CREATE PROCEDURE [dbo].[uspAPCreateVoucherDetail]
	@billId INT,
	@voucherPODetails AS VoucherPODetail READONLY,
	@voucherNonInvDetails AS VoucherDetailNonInventory READONLY,
	@voucherDetailReceiptPO AS [VoucherDetailReceipt] READONLY,
	@voucherNonInvDetailContracts AS VoucherDetailNonInvContract READONLY,
	@voucherDetailCC AS VoucherDetailCC READONLY,
	@voucherDetailStorage AS VoucherDetailStorage READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION

	IF EXISTS(SELECT 1 FROM @voucherPODetails)
	BEGIN
		EXEC uspAPCreateVoucherPODetail @billId, @voucherPODetails
	END

	IF EXISTS(SELECT 1 FROM @voucherNonInvDetails)
	BEGIN
		EXEC uspAPCreateVoucherNonInvDetail @billId, @voucherNonInvDetails
	END

	IF EXISTS(SELECT 1 FROM @voucherDetailReceiptPO)
	BEGIN
		EXEC uspAPCreateVoucherDetailReceiptPO @billId, @voucherDetailReceiptPO
	END 

	IF EXISTS(SELECT 1 FROM @voucherNonInvDetailContracts)
	BEGIN
		EXEC uspAPCreateVoucherDetailNonInvContract @billId, @voucherNonInvDetailContracts
	END 

	IF EXISTS(SELECT 1 FROM @voucherDetailCC)
	BEGIN
		EXEC uspAPCreateVoucherDetailCC @billId, @voucherDetailCC
	END 

	IF EXISTS(SELECT 1 FROM @voucherDetailStorage)
	BEGIN
		EXEC uspAPCreateVoucherDetailStorage  @billId, @voucherDetailStorage
	END 

IF @transCount = 0 COMMIT TRANSACTION

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
	IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION
	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH