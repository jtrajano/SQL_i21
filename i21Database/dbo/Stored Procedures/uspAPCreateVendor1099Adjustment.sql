CREATE PROCEDURE uspAPCreateVendor1099Adjustment(
	@userId INT,
	@oldVendorId INT,
	@newVendorId INT,
	@locationId INT
)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @SavePoint NVARCHAR(32) = 'uspAPCreateVendor1099Adjustment';
DECLARE @transCount INT = @@TRANCOUNT;
DECLARE @currentYear INT = YEAR(GETDATE())
DECLARE @priorYear INT = @currentYear - 1
DECLARE @currentYearAdjustment DECIMAL(18,6)
DECLARE @priorAdjustment DECIMAL(18,6)
--DECLARE @voucherDetailCurrentYear AS VoucherDetailNonInventory, @voucherDetailPriorYear AS VoucherDetailNonInventory;
DECLARE @voucherDetailCurrentYear AS VoucherPayable, @voucherDetailPriorYear AS VoucherPayable;
DECLARE @createdVoucher NVARCHAR(MAX);

--DO NOT ALLOW TO CREATE IF NOT 1099 SETUP FOR VENDOR
--IF (SELECT TOP 1 ISNULL(str1099Type,'') FROM tblEMEntity WHERE intEntityId = @newVendorId) = ''
--BEGIN
--	RAISERROR('No 1099 setup for vendor', 16, 1);
--	RETURN;
--END

SELECT @currentYearAdjustment = SUM(dbl1099Adjustment)
FROM (
	SELECT
		(voucherDetail.dbl1099 + voucherDetail.dblTax) / voucher.dblTotal * ISNULL(voucher.dblPayment, voucher.dblTotal) as dbl1099Adjustment
	FROM tblAPBill voucher
	LEFT JOIN tblAPBillDetail voucherDetail ON voucher.intBillId = voucherDetail.intBillId
	WHERE voucher.ysnPosted = 1 AND voucher.dblPayment > 0
	AND NULLIF(voucherDetail.int1099Form,0) IS NOT NULL
	AND voucher.intPayToAddressId = @locationId
	AND voucher.intEntityVendorId = @oldVendorId
	AND YEAR(voucher.dtmDate) = @currentYear
) currentYear1099Adjustment

SELECT @priorAdjustment = SUM(dbl1099Adjustment)
FROM (
	SELECT
		(voucherDetail.dbl1099 + voucherDetail.dblTax) / voucher.dblTotal * ISNULL(voucher.dblPayment, voucher.dblTotal) as dbl1099Adjustment
	FROM tblAPBill voucher
	LEFT JOIN tblAPBillDetail voucherDetail ON voucher.intBillId = voucherDetail.intBillId
	WHERE voucher.ysnPosted = 1 AND voucher.dblPayment > 0
	AND NULLIF(voucherDetail.int1099Form,0) IS NOT NULL
	AND voucher.intPayToAddressId = @locationId
	AND voucher.intEntityVendorId = @oldVendorId
	AND YEAR(voucher.dtmDate) = @priorYear
) priorYear1099Adjustment

IF @transCount = 0 BEGIN TRANSACTION
ELSE SAVE TRAN @SavePoint

IF @currentYearAdjustment > 0
BEGIN
	INSERT INTO @voucherDetailCurrentYear(intEntityVendorId, intTransactionType, strMiscDescription, dblQuantityToBill, dblCost)
	SELECT @newVendorId, 9, '1099 Adjustment for ' + CAST(@currentYear AS NVARCHAR), 1, @currentYearAdjustment

	EXEC uspAPCreateVoucher @voucherPayables = @voucherDetailCurrentYear, @userId = @userId, @throwError = 1, @createdVouchersId = @createdVoucher OUT;
	--EXEC uspAPCreateBillData @userId = @userId, @vendorId = @newVendorId, @type = 9, @voucherNonInvDetails = @voucherDetailCurrentYear, @billId = @createdVoucher OUT;

END

IF @priorAdjustment > 0
BEGIN
	INSERT INTO @voucherDetailPriorYear(intEntityVendorId, intTransactionType, strMiscDescription, dblQuantityToBill, dblCost)
	SELECT @newVendorId, 9, '1099 Adjustment for ' + CAST(@priorYear AS NVARCHAR), 1, @priorAdjustment

	EXEC uspAPCreateVoucher @voucherPayables = @voucherDetailPriorYear, @userId = @userId, @throwError = 1, @createdVouchersId = @createdVoucher OUT;
	--EXEC uspAPCreateBillData @userId = @userId, @vendorId = @newVendorId, @type = 9, @voucherNonInvDetails = @voucherDetailPriorYear, @billId = @createdVoucher OUT;
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
	SET @ErrorProc     = ERROR_PROCEDURE()

	SET @ErrorMessage  = 'Error creating deferred payment.' + CHAR(13) + 
		'SQL Server Error Message is: ' + CAST(@ErrorNumber AS VARCHAR(10)) + 
		' in procedure: ' + @ErrorProc + ' Line: ' + CAST(@ErrorLine AS VARCHAR(10)) + ' Error text: ' + @ErrorMessage
	
	IF (XACT_STATE()) = -1
	BEGIN
		ROLLBACK TRANSACTION
	END
	ELSE IF (XACT_STATE()) = 1 AND @transCount = 0
	BEGIN
		ROLLBACK TRANSACTION
	END
	ELSE IF (XACT_STATE()) = 1 AND @transCount > 0
	BEGIN
		ROLLBACK TRANSACTION  @SavePoint
	END

	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH