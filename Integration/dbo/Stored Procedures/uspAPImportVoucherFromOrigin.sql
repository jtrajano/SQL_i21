CREATE PROCEDURE [dbo].[uspAPImportVoucherFromOrigin]
	@userId INT,
	@dateFrom DATETIME = NULL,
	@dateTo DATETIME = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 
	BEGIN TRANSACTION
ELSE 
	SAVE TRANSACTION uspAPImportVoucherFromOrigin

DECLARE @log NVARCHAR(100);
DECLARE @valid BIT = 0;
--DECLARE @dateFrom DATETIME;
--DECLARE @dateTo DATETIME;

--VALIDATE
EXEC uspAPValidateVoucherImport
	@UserId = @userId,
	@DateFrom = @dateFrom,
	@DateTo = @dateTo,
	@logKey = @log OUTPUT,
	@isValid = @valid OUTPUT

IF @valid = 0
BEGIN
	PRINT('Validation failed');
	SELECT * FROM tblAPImportVoucherLog WHERE strLogKey = @log
	RETURN;
END

DECLARE @vendorCreated INT;
EXEC uspAPCreateMissingVendorFromOrigin
	@UserId = @userId,
	@DateFrom = @dateFrom,
	@DateTo = @dateTo,
	@totalCreated = @vendorCreated OUTPUT

EXEC uspGLUpdateAPAccountCategory

DECLARE @totalAPIVCMST INT;
DECLARE @totalAPHGLMST INT;
DECLARE @totalAPTRXMST INT;
DECLARE @totalAPEGLMST INT;
DECLARE @totalAPIVCMSTbak INT;
DECLARE @totalAPHGLMSTbak INT;
EXEC uspAPImportVoucherBackupAPIVCMST
	@DateFrom  = @dateFrom,
	@DateTo  = @dateTo,
	@totalAPIVCMST = @totalAPIVCMST OUTPUT,
	@totalAPHGLMST = @totalAPHGLMST OUTPUT,
	@hasCCReconciliation = 0

EXEC uspAPImportVoucherBackupAPTRXMST
	@DateFrom = @dateFrom,
	@DateTo = @dateTo,
	@totalAPTRXMST = @totalAPTRXMST OUTPUT,
	@totalAPEGLMST = @totalAPEGLMST OUTPUT,
	@totalAPIVCMST = @totalAPIVCMSTbak OUTPUT,
	@totalAPHGLMST = @totalAPHGLMSTbak OUTPUT

DECLARE @postHeadCount INT;
DECLARE @postDetailCount INT;
DECLARE @totalPostAmnt DECIMAL(18,6);
EXEC uspAPImportVoucherFromAPIVCMST
	@UserId = @userId,
	@DateFrom = @dateFrom,
	@DateTo = @dateTo,
	@totalHeaderImported = @postHeadCount OUTPUT,
	@totalDetailImported = @postDetailCount OUTPUT,
	@totalPostedVoucher = @totalPostAmnt OUTPUT

DECLARE @unpostHeadCount INT;
DECLARE @unpostDetailCount INT;
DECLARE @totalUnPostAmnt DECIMAL(18,6);
EXEC uspAPImportVoucherFromAPTRXMST
	@UserId = @userId,
	@DateFrom = @dateFrom,
	@DateTo = @dateTo,
	@totalHeaderImported = @unpostHeadCount OUTPUT,
	@totalDetailImported = @unpostDetailCount OUTPUT,
	@totalUnpostedVoucher = @totalUnPostAmnt OUTPUT

DECLARE @paymentCount INT;
EXEC uspAPImportVoucherPayment
	@UserId = @userId,
	@DateFrom = @dateFrom,
	@DateTo = @dateTo,
	@totalCreated = @paymentCount OUTPUT

DECLARE @importedValid INT
EXEC uspAPValidateImportedVouchers
	@UserId = @userId,
	@logKey = @log OUTPUT,
	@isValid = @importedValid OUTPUT

IF @importedValid = 0
BEGIN
	PRINT('Import failed');
	SELECT * FROM tblAPImportVoucherLog WHERE strLogKey = @log
	RETURN;
END

--VALIDATE RECORD COUNT
IF @totalAPIVCMST <> @postHeadCount
BEGIN
	PRINT('Imported posted voucher count is invalid.');
END

IF @totalAPHGLMST <> @postDetailCount
BEGIN
	PRINT('Imported posted voucher detail count is invalid.');
END

IF @totalAPTRXMST <> @unpostHeadCount
BEGIN
	PRINT('Imported unposted voucher count is invalid.');
END

IF @totalAPEGLMST <> @unpostDetailCount
BEGIN
	PRINT('Imported unposted voucher detail count is invalid.');
END

--CHECK BALANCE
DECLARE @ap DECIMAL(18,6);
DECLARE @gl DECIMAL(18,6);
DECLARE @balLog NVARCHAR(100);

EXEC uspAPBalance @UserId = 1, @balance = @ap OUT, @logKey = @balLog OUT;
EXEC uspAPGLBalance @UserId = 1, @balance = @gl OUT, @logKey = @balLog OUT;

IF @ap != @gl 
BEGIN
	PRINT('AP and GL is not balanced.');
	RETURN;
END

IF @transCount = 0 ROLLBACK TRAN

END TRY
BEGIN CATCH
	DECLARE @errorImport NVARCHAR(500) = ERROR_MESSAGE();
	IF XACT_STATE() = -1
		ROLLBACK TRANSACTION;
	IF @transCount = 0 AND XACT_STATE() = 1
		ROLLBACK TRANSACTION
	IF @transCount > 0 AND XACT_STATE() = 1
		ROLLBACK TRANSACTION uspAPImportVoucherPayment
	RAISERROR(@errorImport, 16, 1);
END CATCH