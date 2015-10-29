CREATE PROCEDURE [dbo].[uspAPCreateWriteOff]
	@voucherId INT,
	@userId INT,
	@paymentCreated INT OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @vendorId INT;
DECLARE @location INT;
DECLARE @APAccount INT;
DECLARE @bankAccount INT;
DECLARE @voucherDetailNonInv AS VoucherDetailNonInventory
DECLARE @debitMemoCreated INT;
DECLARE @prepayRecord NVARCHAR(100);
DECLARE @paymentMethod INT;
DECLARE @vendorExpense INT;
DECLARE @balance DECIMAL(18,6);
DECLARE @billIdsPostParam NVARCHAR(MAX);
DECLARE @postSuccess BIT;
DECLARE @paymentValid BIT = 0;
DECLARE @postError NVARCHAR(200);
DECLARE @bills AS Id;
DECLARE @batchId NVARCHAR(100);
DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION

SET @paymentMethod = (SELECT TOP 1 intPaymentMethodID FROM tblSMPaymentMethod WHERE strPaymentMethod LIKE '%Write Off%');
IF @paymentMethod IS NULL
BEGIN
	RAISERROR('Write Off payment method is missing.', 16, 1);
END

--Create Payment
SET @billIdsPostParam = CAST(@voucherId AS NVARCHAR(MAX))
EXEC uspAPCreatePayment @userId, DEFAULT, @paymentMethod, @billId = @billIdsPostParam, @createdPaymentId = @paymentCreated OUTPUT

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