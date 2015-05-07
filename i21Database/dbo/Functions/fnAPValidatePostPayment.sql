CREATE FUNCTION [dbo].[fnAPValidatePostPayment]
(
	@paymentIds NVARCHAR(MAX),
	@post BIT
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
		--Make sure it has setup for default withhold account if vendor is set for withholding
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			'There is no account setup for withholding.',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM tblAPPayment A 
		INNER JOIN tblAPVendor B
			ON A.intEntityVendorId = B.intEntityVendorId AND B.ysnWithholding = 1
		WHERE  A.[intPaymentId] IN (SELECT [intPaymentId] FROM @tmpPayments)
		AND 1 = (CASE WHEN (SELECT intWithholdAccountId FROM tblAPPreference) IS NULL THEN 1 ELSE 0 END)

		--Make sure it ha setup for default discount account
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			'There is no account setup for discount.',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM	[dbo].tblAPPayment A 
			INNER JOIN tblAPPaymentDetail B
				ON A.intPaymentId = B.intPaymentId
			INNER JOIN tblAPVendor C
				ON A.intEntityVendorId = C.intEntityVendorId
		WHERE	A.intPaymentId IN (SELECT intPaymentId FROM @tmpPayments)
		AND B.dblAmountDue = ((B.dblPayment + B.dblDiscount) - B.dblInterest)--fully paid
		AND B.dblDiscount <> 0
		AND B.dblPayment <> 0
		AND 1 = (CASE WHEN (SELECT intDiscountAccountId FROM tblAPPreference) IS NULL THEN 1 ELSE 0 END)
		GROUP BY A.[strPaymentRecordNum],
		A.intPaymentId,
		C.strVendorId,
		A.dtmDatePaid

		--Make sure it ha setup for default discount account
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			'There is no account setup for interest.',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM	[dbo].tblAPPayment A 
			INNER JOIN tblAPPaymentDetail B
				ON A.intPaymentId = B.intPaymentId
			INNER JOIN tblAPVendor C
				ON A.intEntityVendorId = C.intEntityVendorId
		WHERE	A.intPaymentId IN (SELECT intPaymentId FROM @tmpPayments)
		AND B.dblAmountDue = ((B.dblPayment + B.dblDiscount) - B.dblInterest) --fully paid
		AND B.dblInterest <> 0
		AND B.dblPayment <> 0
		AND 1 = (CASE WHEN (SELECT intInterestAccountId FROM tblAPPreference) IS NULL THEN 1 ELSE 0 END)
		GROUP BY A.[strPaymentRecordNum],
		A.intPaymentId,
		C.strVendorId,
		A.dtmDatePaid

		----Payment without payment on detail
		--INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		--SELECT 
		--	'There was no bill to pay on this payment.',
		--	'Payable',
		--	A.strPaymentRecordNum,
		--	A.intPaymentId
		--FROM tblAPPayment A 
		--LEFT JOIN tblAPPaymentDetail B
		--	ON A.intPaymentId = B.intPaymentId
		--WHERE  A.[intPaymentId] IN (SELECT [intPaymentId] FROM @tmpPayments)
		--GROUP BY A.intPaymentId, A.strPaymentRecordNum
		--HAVING SUM(B.dblPayment) = 0

		--Payment without detail
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			'There was no bill to pay on this payment.',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM tblAPPayment A 
		LEFT JOIN tblAPPaymentDetail B
			ON A.intPaymentId = B.intPaymentId
		WHERE  A.[intPaymentId] IN (SELECT [intPaymentId] FROM @tmpPayments)
		AND B.intPaymentId IS NULL

		--Fiscal Year
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			'Unable to find an open fiscal year period to match the transaction date.',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM tblAPPayment A 
		WHERE  A.[intPaymentId] IN (SELECT [intPaymentId] FROM @tmpPayments) AND 
			0 = ISNULL([dbo].isOpenAccountingDate(A.[dtmDatePaid]), 0)

		--NOT BALANCE
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			'The debit and credit amounts are not balanced.',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM tblAPPayment A 
		WHERE  A.[intPaymentId] IN (SELECT [intPaymentId] FROM @tmpPayments) AND 
			(A.dblAmountPaid + A.dblWithheld 
			+ (SELECT SUM(CASE WHEN dblAmountDue = (dblDiscount + dblPayment) THEN dblDiscount ELSE 0 END) FROM tblAPPaymentDetail WHERE intPaymentId = A.intPaymentId)) 
			<> ((SELECT SUM(dblPayment) FROM tblAPPaymentDetail WHERE intPaymentId = A.intPaymentId) 
					+ (SELECT SUM(CASE WHEN dblAmountDue = (dblDiscount + dblPayment) THEN dblDiscount ELSE 0 END) FROM tblAPPaymentDetail WHERE intPaymentId = A.intPaymentId))
			--include over payment

		--ALREADY POSTED
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			'The transaction is already posted.',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM tblAPPayment A 
		WHERE  A.[intPaymentId] IN (SELECT [intPaymentId] FROM @tmpPayments) AND 
			A.ysnPosted = 1

		--BILL(S) ALREADY PAID IN FULL
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			C.strBillId + ' already paid in full.',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM tblAPPayment A
			INNER JOIN tblAPPaymentDetail B
				ON A.intPaymentId = B.intPaymentId
			INNER JOIN tblAPBill C
				ON B.intBillId = C.intBillId
		WHERE  A.[intPaymentId] IN (SELECT [intPaymentId] FROM @tmpPayments)
			AND C.ysnPaid = 1 AND B.dblPayment <> 0
				
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			'Payment on ' + C.strBillId + ' is over the transaction''s amount due',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM tblAPPayment A
			INNER JOIN tblAPPaymentDetail B
				ON A.intPaymentId = B.intPaymentId
			INNER JOIN tblAPBill C
				ON B.intBillId = C.intBillId
		WHERE  A.[intPaymentId] IN (SELECT [intPaymentId] FROM @tmpPayments)
		AND B.dblPayment <> 0 AND C.ysnPaid = 0 AND C.dblAmountDue < (B.dblPayment + B.dblDiscount - B.dblInterest)

		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			'You cannot post with negative amount if payment method is not a Refund.',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM tblAPPayment A
		WHERE A.dblAmountPaid < 0 
		AND (SELECT TOP 1 strPaymentMethod FROM tblSMPaymentMethod WHERE intPaymentMethodID = A.intPaymentMethodId) != 'Refund'
		AND A.[intPaymentId] IN (SELECT [intPaymentId] FROM @tmpPayments)
			
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			C.strBillId + ' belongs to other vendor.',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM tblAPPayment A
		INNER JOIN tblAPPaymentDetail B
			ON A.intPaymentId = B.intPaymentId
		INNER JOIN tblAPBill C
			ON B.intBillId = C.intBillId
		WHERE C.intEntityVendorId <> A.intEntityVendorId
		AND A.[intPaymentId] IN (SELECT [intPaymentId] FROM @tmpPayments)
	END
	ELSE
	BEGIN
		--CM Voiding Validation
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT C.strText,
				'Payable',
				A.strPaymentRecordNum,
				A.intPaymentId
		FROM    tblAPPayment A INNER JOIN tblCMBankTransaction B
					ON A.strPaymentRecordNum = B.strTransactionId
					AND intPaymentId IN (SELECT intPaymentId FROM @tmpPayments)
				CROSS APPLY dbo.fnGetBankTransactionReversalErrors(B.intTransactionId) C

		--Fiscal Year
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			'Unable to find an open fiscal year period to match the transaction date.',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM tblAPPayment A 
		WHERE  A.[intPaymentId] IN (SELECT [intPaymentId] FROM @tmpPayments) AND 
			0 = ISNULL([dbo].isOpenAccountingDate(A.[dtmDatePaid]), 0)

		--Do not allow to unpost if there is latest payment made
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			'You cannot unpost ' + A.strPaymentRecordNum + '. Unpost first ' + LatestPayment.strPaymentRecordNum + '.',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM tblAPPayment A 
		INNER JOIN (
			SELECT * FROM (
				SELECT 
					A1.intPaymentId, 
					OtherPayments.intPostPaymentId,
					strPaymentRecordNum, 
					dtmDatePaid,
					ROW_NUMBER() OVER(PARTITION BY A2.intBillId ORDER BY A1.intPaymentId DESC) rowNum
				FROM tblAPPayment A1
					INNER JOIN tblAPPaymentDetail A2 ON A1.intPaymentId = A2.intPaymentId
					INNER JOIN 
					(
						SELECT intBillId, A3.intPaymentId, tmpPayments.intPaymentId AS intPostPaymentId
						FROM tblAPPaymentDetail A3 INNER JOIN @tmpPayments AS tmpPayments ON A3.intPaymentId = tmpPayments.intPaymentId
					) OtherPayments ON A2.intBillId = OtherPayments.intBillId
				WHERE A1.intPaymentId NOT IN (SELECT [intPaymentId] FROM @tmpPayments) --exclude the for posted on results
				AND A1.ysnPosted = 1 --get only the posted
				) OtherPaymentsFiltered WHERE rowNum = 1
			) LatestPayment ON A.intPaymentId = LatestPayment.intPostPaymentId
		WHERE  A.[intPaymentId] IN (SELECT [intPaymentId] FROM @tmpPayments) 
		AND A.intPaymentId < LatestPayment.intPaymentId
	END

	RETURN
END