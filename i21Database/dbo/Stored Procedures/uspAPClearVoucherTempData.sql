CREATE PROCEDURE [dbo].[uspAPClearVoucherTempData]
	@voucherIds NVARCHAR(MAX)
AS
BEGIN

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	BEGIN TRY

	DECLARE @recordsToUpdate INT;
	DECLARE @recordsUpdated INT;
	DECLARE @transCount INT = @@TRANCOUNT;
	IF @transCount = 0 BEGIN TRANSACTION

	DECLARE @ids AS Id;

	INSERT INTO @ids
	SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@voucherIds)

	SET @recordsToUpdate = (SELECT COUNT(*) FROM @ids);

	UPDATE voucher
		SET voucher.ysnReadyForPayment = 0, voucher.dblTempPayment = 0, voucher.strTempPaymentInfo = null
	FROM tblAPBill voucher
	INNER JOIN @ids ids ON voucher.intBillId = ids.intId
	WHERE voucher.ysnPosted = 1
	AND voucher.ysnPaid = 0
	
	SET @recordsUpdated = @@ROWCOUNT;

	IF @recordsToUpdate != @recordsUpdated
	BEGIN
		RAISERROR('PAYVOUCHERINVALIDROWSAFFECTED', 16, 1);
		RETURN;
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

END