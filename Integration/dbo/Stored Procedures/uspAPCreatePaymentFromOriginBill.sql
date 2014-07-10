CREATE PROCEDURE [dbo].[uspAPCreatePaymentFromOriginBill]
	@billId NVARCHAR(50) = NULL
AS
BEGIN

	SELECT * FROM apcbkmst
	--IF(@billId IS NULL)
	--BEGIN

	--	INSERT INTO tblAPPayment(
	--		[intAccountId],
	--		[intBankAccountId],
	--		[intPaymentMethodId],
	--		[intCurrencyId],
	--		[strPaymentInfo],
	--		[dtmDatePaid],
	--		[dblAmountPaid],
	--		[ysnPosted],
	--		[dblWithheld],
	--		[intVendorId]
	--	)
	--	SELECT
	--		[intAccountId] = (SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = B.apcbk_gl_cash),
	--		[intBankAccountId] = B.apcbk_no,
	--		[intPaymentMethodId] ,
	--		[intCurrencyId],
	--		[strPaymentInfo],
	--		[dtmDatePaid],
	--		[dblAmountPaid],
	--		[ysnPosted],
	--		[dblWithheld],
	--		[intVendorId]
	--	FROM apivcmst A
	--		INNER JOIN apcbkmst B
	--			ON A.apivc_cbk_no = B.apcbk_no
			

	--END

END