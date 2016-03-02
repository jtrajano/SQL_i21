CREATE FUNCTION [dbo].[fnAPValidatePrepay]
(
	@paymentIds AS Id READONLY,
	@post BIT,
	@userId INT
)
RETURNS @returntable TABLE
(
	strError NVARCHAR(100),
	strTransactionType NVARCHAR(50),
	strTransactionId NVARCHAR(50),
	intTransactionId INT
)
AS
BEGIN

	DECLARE @tmpPayments TABLE(
		[intPaymentId] [int]
	);
	INSERT INTO @tmpPayments SELECT * FROM [dbo].fnGetRowsFromDelimitedValues(@paymentIds)

	IF @post = 1
	BEGIN
		--MAKE SURE PAYMENT DETAILS ONLY HAS ONE RECORD
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT
			'Multiple prepayment details is not yet supported.',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM tblAPPayment A 
		INNER JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
		WHERE  A.[intPaymentId] IN (SELECT [intPaymentId] FROM @tmpPayments)
		GROUP BY A.strPaymentRecordNum, A.intPaymentId
		HAVING COUNT(B.intPaymentDetailId) > 1 

		--MAKE SURE ysnPrepay set to true.
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT
			'Payment is not a prepayment type.',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM tblAPPayment A 
		WHERE  A.[intPaymentId] IN (SELECT [intPaymentId] FROM @tmpPayments)
		AND A.ysnPrepay = 0
	END
	ELSE
	BEGIN
		--DO NOT ALLOW TO UNPOST/VOID IF IT IS ALREADY APPLIED
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT
			'You cannot post/void this payment. It has been applied to a voucher (' + D.strBillId + ').',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM tblAPPayment A 
		INNER JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
		INNER JOIN tblAPAppliedPrepaidAndDebit C ON B.intBillId = C.intBillId
		INNER JOIN tblAPBill D ON C.intBillId = C.intBillId
		WHERE  A.[intPaymentId] IN (SELECT [intPaymentId] FROM @tmpPayments)
	END

	RETURN;

END