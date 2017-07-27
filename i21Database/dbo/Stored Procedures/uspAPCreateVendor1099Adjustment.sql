CREATE PROCEDURE uspAPCreateVendor1099Adjustment(
	@userId INT,
	@oldVendorId INT,
	@newVendorId INT
)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @currentYear INT = YEAR(GETDATE())
DECLARE @priorYear INT = @currentYear - 1
DECLARE @currentYearAdjustment DECIMAL(18,6)
DECLARE @priorAdjustment DECIMAL(18,6)
DECLARE @voucherDetailCurrentYear AS VoucherDetailNonInventory, @voucherDetailPriorYear AS VoucherDetailNonInventory;
DECLARE @createdVoucher INT;

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
	AND NULLIF(voucherDetail.int1099Form,0) <= 0
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
	AND NULLIF(voucherDetail.int1099Form,0) <= 0
	AND voucher.intEntityVendorId = @oldVendorId
	AND YEAR(voucher.dtmDate) = @priorYear
) priorYear1099Adjustment

IF @currentYearAdjustment > 0
BEGIN
	INSERT INTO @voucherDetailCurrentYear(strMiscDescription, dblQtyReceived, dblCost)
	SELECT '1099 Adjustment for ' + @currentYear, 1, @currentYearAdjustment

	EXEC uspAPCreateBillData @userId = @userId, @vendorId = @newVendorId, @type = 9, @voucherNonInvDetails = @voucherDetailCurrentYear, @billId = @createdVoucher OUT;

END

IF @priorAdjustment > 0
BEGIN
	INSERT INTO @voucherDetailPriorYear(strMiscDescription, dblQtyReceived, dblCost)
	SELECT '1099 Adjustment for ' + @priorYear, 1, @priorAdjustment

	EXEC uspAPCreateBillData @userId = @userId, @vendorId = @newVendorId, @type = 9, @voucherNonInvDetails = @voucherDetailPriorYear, @billId = @createdVoucher OUT;
END
