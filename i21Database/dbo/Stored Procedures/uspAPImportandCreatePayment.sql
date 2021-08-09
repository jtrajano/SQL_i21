CREATE PROCEDURE [dbo].[uspAPImportandCreatePayment]
	@locationId INT,
	@bankAccountId INT,
	@datePaid DATETIME,
	@userId INT,
	@createdPaymentId INT OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT OFF
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @transCount INT = @@TRANCOUNT;
	IF @transCount = 0 BEGIN TRANSACTION

	DECLARE @billIds AS NVARCHAR(4000);
	SELECT @billIds = COALESCE(@billIds + ',', '') +  CONVERT(VARCHAR(12), B.intBillId)
	FROM tblAPImportPaidVouchersForPayment I
	INNER JOIN tblAPBill B ON B.strBillId = I.strBillId

	EXEC uspAPCreatePayment @userId, @bankAccountId, DEFAULT, DEFAULT, DEFAULT, DEFAULT, @datePaid, DEFAULT, DEFAULT, @billIds, @createdPaymentId OUTPUT

	UPDATE PD
	SET PD.dblPayment = I.dblPayment,
		PD.dblDiscount = I.dblDiscount,
		PD.dblInterest = I.dblInterest
	FROM tblAPPaymentDetail PD
	INNER JOIN tblAPPayment P ON P.intPaymentId = PD.intPaymentId
	INNER JOIN tblAPBill B ON B.intBillId = PD.intBillId
	INNER JOIN tblAPImportPaidVouchersForPayment I ON I.strBillId = B.strBillId
	WHERE P.intPaymentId = @createdPaymentId
	
	TRUNCATE TABLE tblAPImportPaidVouchersForPayment
	
	EXEC uspAPUpdateVoucherPayment @createdPaymentId, 1

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