CREATE PROCEDURE [dbo].[uspAPCreateWriteOff]
	@billIds AS Id READONLY,
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

SET @bills = @billIds;

SELECT TOP 1
	@vendorId = A.intEntityVendorId
	,@location = A.intShipToId
	,@prepayRecord = A.strBillId
	,@vendorExpense = B.intGLAccountExpenseId
	,@balance = A.dblAmountDue
FROM tblAPBill A
INNER JOIN tblAPVendor B ON  A.intEntityVendorId = B.intEntityVendorId
WHERE A.intBillId IN (SELECT intId FROM @bills)
AND A.intTransactionType IN (2)

IF @balance <= 0
BEGIN
	RAISERROR('Cannot clear balance. Prepaid was fully applied.', 16, 1);
END

IF @vendorExpense IS NULL OR @vendorExpense <= 0
BEGIN
	RAISERROR('Please setup default vendor expense account.', 16, 1);
END

IF @location IS NULL
BEGIN
	SET @location = (SELECT intCompanyLocationId FROM tblSMUserSecurity A WHERE A.intEntityUserSecurityId = @userId)
	IF @location IS NULL
	BEGIN
		RAISERROR('Default location setup for user is missing.', 16, 1);
	END
END

SELECT 
	@bankAccount = B.intBankAccountId
FROM tblSMCompanyLocation A 
INNER JOIN tblCMBankAccount B ON A.intCashAccount = B.intGLAccountId
WHERE B.intGLAccountId IS NOT NULL AND A.intCashAccount IS NOT NULL

IF @bankAccount IS NULL
BEGIN
	RAISERROR('Cash account setup is missing on location.', 16, 1);
END

SET @paymentMethod = (SELECT TOP 1 intPaymentMethodID FROM tblSMPaymentMethod WHERE strPaymentMethod LIKE '%Write Off%');
IF @paymentMethod IS NULL
BEGIN
	RAISERROR('Write Off payment method is missing.', 16, 1);
END

--Create Payment
EXEC uspAPCreatePayment @userId, @bankAccount, @paymentMethod, @billId = @billIds, @createdPaymentId = @paymentCreated OUTPUT

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