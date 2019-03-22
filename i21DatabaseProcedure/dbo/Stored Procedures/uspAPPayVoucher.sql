CREATE PROCEDURE [dbo].[uspAPPayVoucher](
	@voucherId INT = NULL,
	@payment DECIMAL(18,6) = 0,
	@payAll BIT = 0,
	@clearAll BIT = 0
)
AS
BEGIN
	--Store all vouchers that is for payment
	DECLARE @voucherIds AS Id

	IF @voucherId IS NOT NULL
	BEGIN
		INSERT INTO @voucherIds
		SELECT @voucherId
	END

	IF @payAll = 1 OR @clearAll = 1
	BEGIN
		INSERT INTO @voucherIds
		SELECT
			voucher.intBillId
		FROM tblAPBill voucher
		WHERE voucher.ysnPosted = 1 
		AND voucher.ysnPaid = 0
		AND voucher.intTransactionType NOT IN (11, 12)
		AND voucher.intTransactionReversed IS NULL
	END

	IF @voucherId > 0
	BEGIN
		UPDATE voucher
			SET voucher.ysnReadyForPayment = 1
				,voucher.dblPayment = CASE WHEN @payment > 0 THEN @payment 
								ELSE CAST(voucher.dblAmountDue  - voucher.dblTempDiscount + voucher.dblTempInterest AS DECIMAL(18,2))
								END
		FROM tblAPBill voucher
		WHERE voucher.intBillId = @voucherId AND voucher.ysnPaid = 0 AND voucher.ysnPosted = 1
	END

	IF EXISTS(SELECT 1 FROM @voucherIds)
	BEGIN
		UPDATE voucher
			SET voucher.ysnReadyForPayment = 1
				,voucher.dblPayment = CASE WHEN @payment > 0 THEN @payment 
								ELSE CAST(voucher.dblAmountDue  - voucher.dblTempDiscount + voucher.dblTempInterest AS DECIMAL(18,2))
								END
		FROM tblAPBill voucher
		INNER JOIN @voucherIds ids ON voucher.intBillId = ids.intId
	END

END	