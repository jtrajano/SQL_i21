CREATE FUNCTION [dbo].[fnAPGetVoucherBalance]
(
	@voucherIds Id READONLY,
	@glEntries RecapTableType READONLY,
	@payment BIT,
	@post BIT
)
RETURNS @returntable TABLE(dblAPBalance DECIMAL(18,6), dblAPGLBalance DECIMAL(18,6))
AS
BEGIN

	DECLARE @apBalance DECIMAL(18,6), @apGLBalance DECIMAL(18,6);
	DECLARE @intPayablesCategory INT, @prepaymentCategory INT;

	SELECT @intPayablesCategory = intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = 'AP Account'
	SELECT @prepaymentCategory = intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = 'Vendor Prepayments'

	IF @payment = 0
	BEGIN

		SELECT
			@apBalance = SUM(
							ISNULL(voucher.dblAmountDue,0) 
							* (CASE WHEN voucher.intTransactionType NOT IN (1, 14) THEN 1 ELSE -1 END)
						) 
						* (CASE WHEN @post = 1 THEN 1 ELSE -1 END)
		FROM tblAPBill voucher
		INNER JOIN @voucherIds ids ON voucher.intBillId = ids.intId
		WHERE voucher.dblAmountDue != 0

	END
	ELSE
	BEGIN

		SELECT
			@apBalance = -(SUM(
							ISNULL(paymentDetail.dblPayment,0) 
							* (CASE WHEN voucher.intTransactionType NOT IN (1, 14) THEN 1 ELSE -1 END)
						) 
						* (CASE WHEN @post = 1 THEN 1 ELSE -1 END))
		FROM tblAPPaymentDetail paymentDetail
		INNER JOIN tblAPBill voucher ON paymentDetail.intBillId = voucher.intBillId
		INNER JOIN @voucherIds ids ON voucher.intBillId = ids.intId

	END

	SELECT
		@apGLBalance = SUM(ISNULL(glDetail.dblCredit,0)) - SUM(ISNULL(glDetail.dblDebit, 0))
	FROM @glEntries glDetail
		INNER JOIN vyuGLAccountDetail vwGLDetail ON glDetail.intAccountId = vwGLDetail.intAccountId
	WHERE vwGLDetail.intAccountCategoryId IN (@prepaymentCategory, @intPayablesCategory)
	
	INSERT INTO @returntable
	SELECT @apBalance, @apGLBalance

	RETURN;
END
