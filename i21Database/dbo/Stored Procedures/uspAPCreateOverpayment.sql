CREATE PROCEDURE [dbo].[uspAPCreateOverpayment]
	@paymentId INT,
	@userId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @overpay NUMERIC(18,6);
DECLARE @vendorId INT;
DECLARE @billId INT;
DECLARE @paymentRecord NVARCHAR(50);

SELECT 
	@overpay = dblUnapplied,
	@vendorId = intEntityVendorId,
	@paymentRecord = strPaymentRecordNum
FROM tblAPPayment WHERE intPaymentId = @paymentId;

IF (@overpay > 0)
BEGIN
	INSERT INTO tblAPBill
	EXEC uspAPCreateBillData  @userId, @vendorId

	SET @billId = SCOPE_IDENTITY();

	UPDATE A
	SET dblTotal = @overpay,
		dblAmountDue = @overpay,
		intTransactionType = 8,
		strReference = @paymentRecord
	FROM tblAPBill A
	WHERE A.intBillId = @billId
END