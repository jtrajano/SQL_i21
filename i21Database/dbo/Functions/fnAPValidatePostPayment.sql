CREATE FUNCTION [dbo].[fnAPValidatePostPayment]
(
	@paymentIds Id READONLY,
	@post BIT,
	@userId INT
)
RETURNS @returntable TABLE
(
	strError NVARCHAR(1000),
	strTransactionType NVARCHAR(50),
	strTransactionId NVARCHAR(50),
	intTransactionId INT
)
AS
BEGIN

	DECLARE @WithholdAccount INT, @DiscountAccount INT, @InterestAccount INT, @CashAccount INT, @APAccount INT;
	DECLARE @userLocation INT;
	DECLARE @intFunctionalCurrencyId  AS INT;
	DECLARE @gainLossAccount INT;

	SET @intFunctionalCurrencyId = dbo.fnSMGetDefaultCurrency('FUNCTIONAL') 
	-- SET @gainLossAccount = (SELECT TOP 1 intAccountsPayableRealizedId FROM tblSMMultiCurrency)
	--DECLARE @tmpPayments TABLE(
	--	[intPaymentId] [int]
	--);
	--INSERT INTO @tmpPayments SELECT * FROM [dbo].fnGetRowsFromDelimitedValues(@paymentIds)

	SELECT TOP 1 @userLocation = intCompanyLocationId FROM tblSMUserSecurity WHERE [intEntityId] = @userId;
	IF (@userLocation IS NOT NULL AND @userLocation > 0)
	BEGIN
		SELECT TOP 1
			@WithholdAccount = intWithholdAccountId
			,@DiscountAccount = intDiscountAccountId
			,@InterestAccount = intInterestAccountId
			,@CashAccount = intCashAccount
			,@APAccount  = intAPAccount
		FROM tblSMCompanyLocation
		WHERE intCompanyLocationId = @userLocation
	END

	--Make sure that there is default location setup for user if
	--1. It has discount
	--2. It has overpayment
	--3. It has withheld
	--4. It has interest

	IF @post = 1
	BEGIN
		--INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		--SELECT 'Posting different Currency are not yet implemented.',
		--		'Payable',
		--	   A.strPaymentRecordNum,
		--	   A.intPaymentId
		--FROM dbo.tblAPPayment A 
		--INNER JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
		--INNER JOIN dbo.tblAPBill C ON B.intBillId = C.intBillId
		--CROSS APPLY
		--(
		--	SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference
		--) BaseCurrency
		--WHERE A.intPaymentId IN (SELECT intId FROM @paymentIds) AND C.intCurrencyId != BaseCurrency.intDefaultCurrencyId
		--AND B.dblPayment > 0

		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			'Please setup user default location.',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM tblAPPayment A 
		WHERE  A.[intPaymentId] IN (SELECT intId FROM @paymentIds)
		AND @userLocation IS NULL
		--AND A.intPaymentId IN (SELECT A.intPaymentId FROM tblAPPayment A
		--						INNER JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
		--						INNER JOIN tblAPVendor C ON A.intEntityVendorId = C.intEntityVendorId
		--						WHERE (A.dblUnapplied > 0 --Overpayment
		--						OR C.ysnWithholding = 1 --Withhold
		--						OR B.dblDiscount <> 0 --Discount
		--						OR B.dblInterest <> 0) --Interest
		--						AND A.intPaymentId IN (SELECT intId FROM @paymentIds)
		--					)

		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT
			'Bank account is inactive.',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM tblAPPayment A 
		INNER JOIN tblCMBankAccount B
			ON A.intBankAccountId = B.intBankAccountId
		WHERE  A.[intPaymentId] IN (SELECT intId FROM @paymentIds)
		AND B.ysnActive = 0

		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT
			'Overpayment requires to have default AP account setup.',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM tblAPPayment A 
		WHERE  A.[intPaymentId] IN (SELECT intId FROM @paymentIds)
		AND (@APAccount IS NULL OR @APAccount <= 0) AND A.dblUnapplied > 0

		--Make sure it has setup for default withhold account if vendor is set for withholding
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			'There is no account setup for withholding.',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM tblAPPayment A 
		INNER JOIN tblAPVendor B
			ON A.intEntityVendorId = B.[intEntityId]
		WHERE  A.[intPaymentId] IN (SELECT intId FROM @paymentIds)
		AND @WithholdAccount IS NULL
		 AND B.ysnWithholding = 1

		 --Removed, cash account already setup in Payment table.
		--INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		--SELECT 
		--	'The Cash Account setup is missing.',
		--	'Payable',
		--	A.strPaymentRecordNum,
		--	A.intPaymentId
		--FROM tblAPPayment A 
		--INNER JOIN tblAPVendor B
		--	ON A.intEntityVendorId = B.intEntityVendorId AND B.ysnWithholding = 1
		--WHERE  A.[intPaymentId] IN (SELECT intId FROM @paymentIds)
		--AND @CashAccount IS NULL

		--Make sure it ha setup for default discount account
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			'The Discount Account setup is missing.',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM	[dbo].tblAPPayment A 
			INNER JOIN tblAPPaymentDetail B
				ON A.intPaymentId = B.intPaymentId
			INNER JOIN tblAPVendor C
				ON A.intEntityVendorId = C.[intEntityId]
		WHERE	A.intPaymentId IN (SELECT intId FROM @paymentIds)
		AND B.dblAmountDue = CAST(((B.dblPayment + B.dblDiscount) - B.dblInterest) AS DECIMAL(18,2))--fully paid
		AND B.dblDiscount <> 0
		AND B.dblPayment <> 0
		AND @DiscountAccount IS NULL
		GROUP BY A.[strPaymentRecordNum],
		A.intPaymentId,
		C.strVendorId,
		A.dtmDatePaid

		--Make sure it ha setup for default discount account
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			'The Interest Account setup is missing.',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM	[dbo].tblAPPayment A 
			INNER JOIN tblAPPaymentDetail B
				ON A.intPaymentId = B.intPaymentId
			INNER JOIN tblAPVendor C
				ON A.intEntityVendorId = C.[intEntityId]
		WHERE	A.intPaymentId IN (SELECT intId FROM @paymentIds)
		-- AND B.dblAmountDue = CAST(((B.dblPayment + B.dblDiscount) - B.dblInterest) AS DECIMAL(18,2)) --fully paid
		AND B.dblInterest <> 0
		AND B.dblPayment <> 0
		AND @InterestAccount IS NULL
		GROUP BY A.[strPaymentRecordNum],
		A.intPaymentId,
		C.strVendorId,
		A.dtmDatePaid

		--Payment without payment on detail
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			'There was no bill to pay on this payment.',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM tblAPPayment A 
		OUTER APPLY (
			SELECT intPaymentDetailId FROM tblAPPaymentDetail B
			WHERE B.dblPayment != 0 AND B.intPaymentId = A.intPaymentId
		) PaymentDetails
		WHERE A.[intPaymentId] IN (SELECT intId FROM @paymentIds)
		AND PaymentDetails.intPaymentDetailId IS NULL

		--duplicate payment detail
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			'Unable to post. Duplicate vouchers found in details.',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM tblAPPayment A 
		CROSS APPLY (
			SELECT COUNT(*) intVouchers FROM tblAPPaymentDetail B
			WHERE B.dblPayment != 0 AND B.intPaymentId = A.intPaymentId
			AND B.intPayScheduleId IS NULL
			GROUP BY B.intBillId, B.intInvoiceId
		) PaymentDetails
		WHERE A.[intPaymentId] IN (SELECT intId FROM @paymentIds)
		AND PaymentDetails.intVouchers > 1

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
		WHERE  A.[intPaymentId] IN (SELECT intId FROM @paymentIds)
		AND B.intPaymentId IS NULL

		--Fiscal Year
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			'Unable to find an open fiscal year period to match the transaction date.',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM tblAPPayment A 
		WHERE  A.[intPaymentId] IN (SELECT intId FROM @paymentIds) AND 
			0 = ISNULL([dbo].isOpenAccountingDate(A.[dtmDatePaid]), 0)

		--This is currently doing by the uspGLBookEntries
		--Add this temporarily as uspGLBookEntries validates the balance, however it throws an error, this should put in a result table
		--NOT BALANCE
		--INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		--SELECT 
		--'The debit and credit amounts are not balanced.',
		--'Payable',
		--A.strPaymentRecordNum,
		--A.intPaymentId
		--FROM tblAPPayment A 
		--WHERE  A.[intPaymentId] IN (SELECT intId FROM @paymentIds) AND 
		--((A.dblAmountPaid + A.dblWithheld - A.dblUnapplied) --deduct the overpayment
		--+ (SELECT SUM(CASE WHEN dblAmountDue = (dblDiscount + dblPayment) THEN dblDiscount ELSE 0 END) FROM tblAPPaymentDetail WHERE intPaymentId = A.intPaymentId)) 
		--<> ((SELECT SUM(CASE WHEN B2.intTransactionType != 1 AND B1.dblPayment > 0 THEN B1.dblPayment * -1 ELSE B1.dblPayment END) FROM tblAPPaymentDetail B1 INNER JOIN tblAPBill B2 ON B1.intBillId = B2.intBillId
		--	WHERE B1.intPaymentId = A.intPaymentId) 
		--	+ (SELECT SUM(CASE WHEN dblAmountDue = (dblDiscount + dblPayment) THEN dblDiscount ELSE 0 END) FROM tblAPPaymentDetail WHERE intPaymentId = A.intPaymentId))
		--include over payment

		--ALREADY POSTED
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			'The transaction is already posted.',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM tblAPPayment A 
		WHERE  A.[intPaymentId] IN (SELECT intId FROM @paymentIds) AND 
			A.ysnPosted = 1

		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			'Posting negative amount is not allowed. You may want to create a deposit instead.',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM tblAPPayment A 
		WHERE  A.[intPaymentId] IN (SELECT intId FROM @paymentIds) AND 
			A.dblAmountPaid < 0

		--BILL(S) ALREADY PAID IN FULL
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			(CASE WHEN B.intBillId > 0 THEN C.strBillId  WHEN B.intInvoiceId > 0 THEN D.strInvoiceNumber END) + ' already paid in full.',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM tblAPPayment A
			INNER JOIN tblAPPaymentDetail B
				ON A.intPaymentId = B.intPaymentId
			LEFT JOIN tblAPBill C
				ON B.intBillId = C.intBillId
			LEFT JOIN tblARInvoice D
				ON B.intInvoiceId = D.intInvoiceId
		WHERE  A.[intPaymentId] IN (SELECT intId FROM @paymentIds)
			AND ((B.intBillId > 0 AND C.ysnPaid = 1) OR (B.intInvoiceId IS NOT NULL AND D.ysnPaid = 1))
			AND B.dblPayment != 0 --Validate all those selected transaction	
				
		--MAKE SURE YOU WILL NOT PAY OVER ON THE AMOUNT DUE
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			'Payment on ' + (CASE WHEN B.intBillId > 0 THEN C.strBillId  WHEN B.intInvoiceId > 0 THEN D.strInvoiceNumber END) + ' is over the transaction''s amount due',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM tblAPPayment A
			INNER JOIN tblAPPaymentDetail B
				ON A.intPaymentId = B.intPaymentId
			LEFT JOIN tblAPBill C
				ON B.intBillId = C.intBillId
			LEFT JOIN tblARInvoice D
				ON B.intInvoiceId = D.intInvoiceId
		WHERE  A.[intPaymentId] IN (SELECT intId FROM @paymentIds)
		AND 
		(
			(B.intBillId > 0 AND B.dblPayment <> 0 AND C.ysnPaid = 0 AND CAST(C.dblAmountDue AS DECIMAL(18,2)) < (CAST((B.dblPayment + B.dblDiscount - B.dblInterest) AS DECIMAL(18,2))))
			OR
			(B.intInvoiceId > 0 AND B.dblPayment <> 0 AND D.ysnPaid = 0 AND CAST(D.dblAmountDue AS DECIMAL(18,2)) < (CAST((B.dblPayment + B.dblDiscount - B.dblInterest) AS DECIMAL(18,2))))
		)

		--handle over paying on batch posting
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			'Payment on ' + (CASE WHEN B.intBillId > 0 THEN C.strBillId  WHEN B.intInvoiceId > 0 THEN D.strInvoiceNumber END) + ' will be over on the transaction''s amount due',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM tblAPPayment A
			INNER JOIN tblAPPaymentDetail B
				ON A.intPaymentId = B.intPaymentId
			LEFT JOIN tblAPBill C
				ON B.intBillId = C.intBillId
			LEFT JOIN tblARInvoice D
				ON B.intInvoiceId = D.intInvoiceId
			OUTER APPLY 
			(
				SELECT
					SUM(payDetail.dblPayment + payDetail.dblDiscount - payDetail.dblInterest) AS dblBillPayment
				FROM tblAPPaymentDetail payDetail
				WHERE payDetail.intPaymentId IN (SELECT intId FROM @paymentIds)
				AND payDetail.intBillId = C.intBillId
			) payment
			OUTER APPLY 
			(
				SELECT
					SUM(payDetail.dblPayment + payDetail.dblDiscount - payDetail.dblInterest) AS dblBillPayment
				FROM tblAPPaymentDetail payDetail
				WHERE payDetail.intPaymentId IN (SELECT intId FROM @paymentIds)
				AND payDetail.intInvoiceId = D.intInvoiceId
			) arPayment
		WHERE  A.[intPaymentId] IN (SELECT intId FROM @paymentIds)
		AND B.dblPayment <> 0
		AND (payment.dblBillPayment > C.dblAmountDue OR arPayment.dblBillPayment > D.dblAmountDue)
		AND B.dblPayment <> 0


		-- INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		-- SELECT 
		-- 	A.strPaymentRecordNum + ' payment have vouchers with different pay to address.',
		-- 	'Payable',
		-- 	A.strPaymentRecordNum,
		-- 	A.intPaymentId
		-- FROM tblAPPayment A
		-- 	INNER JOIN tblAPPaymentDetail B
		-- 		ON A.intPaymentId = B.intPaymentId
		-- 	INNER JOIN tblAPBill C
		-- 		ON B.intBillId = C.intBillId
		-- WHERE  A.[intPaymentId] IN (SELECT intId FROM @paymentIds)
		-- AND B.dblPayment != 0
		-- GROUP BY A.strPaymentRecordNum, A.intPaymentId
		-- HAVING COUNT(DISTINCT C.intPayToAddressId) > 1

		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			'You cannot post with negative amount if payment method is not a Refund.',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM tblAPPayment A
		WHERE A.dblAmountPaid < 0 
		AND (SELECT TOP 1 strPaymentMethod FROM tblSMPaymentMethod WHERE intPaymentMethodID = A.intPaymentMethodId) != 'Refund'
		AND (NOT EXISTS(SELECT 1 FROM tblAPPaymentDetail B INNER JOIN tblAPBill C ON B.intBillId = C.intBillId WHERE (C.intTransactionType = 2 OR C.intTransactionType = 13) AND B.intPaymentId IN (SELECT intId FROM @paymentIds))
				AND (SELECT COUNT(*) FROM tblAPPaymentDetail WHERE intPaymentId IN (SELECT intId FROM @paymentIds)) = 1)
		AND A.[intPaymentId] IN (SELECT intId FROM @paymentIds)
		
			
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
		AND A.[intPaymentId] IN (SELECT intId FROM @paymentIds)

		--DO NOT ALLOW TO POST DEBIT MEMOS AND PAYMENTS IF AMOUNT PAID IS NOT EQUAL TO ZERO
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			'Payment ' + A.strPaymentRecordNum + ' has incorrect payment method.',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM tblAPPayment A
		INNER JOIN tblSMPaymentMethod B ON A.intPaymentMethodId = B.intPaymentMethodID
		WHERE A.[intPaymentId] IN (SELECT intId FROM @paymentIds)
		AND A.dblAmountPaid = 0
		AND LOWER(B.strPaymentMethod) != 'debit memos and payments'

		--DO NOT ALLOW TO POST PAYMENT IF IT HAS ASSOCIATED PREPAYMENT FOR CONTRACT OR IT IS RESTRICTED
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT DISTINCT
			'Payment ' + A.strPaymentRecordNum + ' has prepayment for contract/ticket associated. Please use Prepaid tab of voucher to offset.',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM tblAPPayment A
		INNER JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
		INNER JOIN tblAPBill C ON B.intBillId = C.intBillId
		INNER JOIN tblAPBillDetail D ON C.intBillId = D.intBillId
		WHERE A.[intPaymentId] IN (SELECT intId FROM @paymentIds)
		AND B.ysnOffset = 1
		AND B.dblPayment != 0 
		AND (D.ysnRestricted = 1 
			AND ((C.intTransactionType = 2 AND D.intContractDetailId > 0) 
				OR (C.intTransactionType = 13 AND D.intScaleTicketId > 0))
			)

		--DO NOT ALLOW TO POST NOT PAY TO ADDRESS SPECIFIED AND MULTIPLE PAY TO HAS BEEN ON THE DETAILS
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			'Invalid pay to address. Multiple pay to address has been set to payment details.',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM tblAPPayment A 
		WHERE  A.[intPaymentId] IN (SELECT intId FROM @paymentIds)
		AND EXISTS (
			SELECT 1 FROM tblAPPaymentDetail B
			INNER JOIN tblAPBill C ON B.intBillId = C.intBillId
			WHERE A.intPaymentId = B.intPaymentId
			AND B.dblPayment != 0
			AND B.intInvoiceId IS NULL --invoice do not have pay to address
			GROUP BY C.intPayToAddressId
			HAVING COUNT(DISTINCT C.intPayToAddressId) > 1
		)

		--MAKE SURE GAIN/LOSS ACCOUNT SETUP CONFIGURATION IS EXISTS WHEN GAIN/LOSS ACCOUNT
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			'Gain/Loss account setup is missing on company configuration',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM tblAPPayment A 
		CROSS APPLY tblSMMultiCurrency B
		WHERE  A.[intPaymentId] IN (SELECT intId FROM @paymentIds)
		AND A.intCurrencyId != @intFunctionalCurrencyId
		AND EXISTS (
			SELECT 1 FROM tblAPPaymentDetail B 
			INNER JOIN tblAPBill C ON B.intBillId = C.intBillId
			INNER JOIN tblAPBillDetail D ON D.intBillId = C.intBillId
			WHERE B.intPaymentId = A.intPaymentId
			AND ISNULL(NULLIF(D.dblRate, 0), 1) <> ISNULL(NULLIF(A.dblExchangeRate,0), 1)
		)
		AND (B.intAccountsPayableRealizedId IS NULL OR B.intAccountsPayableRealizedId = 0)

		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			'You cannot Post/Unpost transactions you did not create. Please contact your local administrator.',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM tblAPPayment A 
		OUTER APPLY ( 
			SELECT ysnAllowUserSelfPost FROM tblSMUserPreference WHERE intEntityUserSecurityId = @userId
		) userPref 
		WHERE  A.[intPaymentId] IN (SELECT intId FROM @paymentIds)
		AND userPref.ysnAllowUserSelfPost = 1
		AND A.intEntityId != @userId

		--DO NOT ALLOW TO OFFSET PREPAYMENT IF DOES NOT HAVE ACTUAL PAY
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			'You cannot offset ' + payDetails.strBillId + ' because is not paid yet.',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM tblAPPayment A 
		CROSS APPLY 
		(
			SELECT
				voucher.strBillId
			FROM tblAPPaymentDetail payDetail
			INNER JOIN tblAPBill voucher
				ON payDetail.intBillId = voucher.intBillId
			WHERE 
				voucher.intTransactionType = 2
			AND payDetail.intPaymentId = A.intPaymentId
			AND payDetail.ysnOffset = 1
			AND payDetail.dblPayment <> 0
			AND NOT EXISTS
			(
				SELECT
					1
				FROM tblAPPaymentDetail prepayDetail
				INNER JOIN tblAPPayment prepay
					ON prepayDetail.intPaymentId = prepay.intPaymentId AND prepay.ysnPosted = 1
				INNER JOIN tblCMBankTransaction bankTran
					ON prepay.strPaymentRecordNum = bankTran.strTransactionId AND bankTran.ysnCheckVoid = 0
				WHERE prepayDetail.intBillId = voucher.intBillId
				AND
					prepayDetail.dblPayment <> 0
			)
		) payDetails
		WHERE  A.[intPaymentId] IN (SELECT intId FROM @paymentIds)

		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			'Amount due for ' + B.strBillId + ' is greater than its total.',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM tblAPPayment A 
		INNER JOIN tblAPPaymentDetail A2 ON A.intPaymentId = A2.intPaymentId
		INNER JOIN tblAPBill B ON A2.intBillId = B.intBillId
		WHERE 
			A.[intPaymentId] IN (SELECT intId FROM @paymentIds)
		AND A2.dblPayment != 0
		AND (
			A2.dblAmountDue > A2.dblTotal
			)
		AND A2.ysnOffset = 0

		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			'Amount due for ' + B.strBillId + ' is greater than its total.',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM tblAPPayment A 
		INNER JOIN tblAPPaymentDetail A2 ON A.intPaymentId = A2.intPaymentId
		INNER JOIN tblAPBill B ON A2.intBillId = B.intBillId
		WHERE 
			A.[intPaymentId] IN (SELECT intId FROM @paymentIds)
		AND A2.dblPayment != 0
		AND (
			A2.dblAmountDue < A2.dblTotal
			)
		AND A2.ysnOffset = 1

		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			'Payment for ' + B.strBillId + ' is greater than its total.',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM tblAPPayment A 
		INNER JOIN tblAPPaymentDetail A2 ON A.intPaymentId = A2.intPaymentId
		INNER JOIN tblAPBill B ON A2.intBillId = B.intBillId
		WHERE 
			A.[intPaymentId] IN (SELECT intId FROM @paymentIds)
		AND A2.dblPayment != 0
		AND (
			ROUND((A2.dblPayment - A2.dblInterest + A2.dblDiscount),2) > A2.dblTotal
			)
		AND A2.ysnOffset = 0

		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			'Payment for ' + B.strBillId + ' is greater than its total.',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM tblAPPayment A 
		INNER JOIN tblAPPaymentDetail A2 ON A.intPaymentId = A2.intPaymentId
		INNER JOIN tblAPBill B ON A2.intBillId = B.intBillId
		WHERE 
			A.[intPaymentId] IN (SELECT intId FROM @paymentIds)
		AND A2.dblPayment != 0
		AND (
			ROUND((A2.dblPayment - A2.dblInterest + A2.dblDiscount),2) < A2.dblTotal
			)
		AND A2.ysnOffset = 1

		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			'Amount Paid is not equal with the total payment made on details.',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM tblAPPayment A 
		OUTER APPLY (
			SELECT
				SUM(B.dblPayment * 
					(CASE 
						WHEN C.intTransactionType IN (3) THEN -1
						WHEN C.intTransactionType IN (2, 13) AND (C.ysnPrepayHasPayment = 1 OR B.ysnOffset = 1) THEN -1
						ELSE 1
						END
					)
				) AS dblPayment
			FROM tblAPPaymentDetail B
			INNER JOIN tblAPBill C ON B.intBillId = C.intBillId
			WHERE A.intPaymentId = B.intPaymentId
			AND B.dblPayment != 0
		) payDetails
		WHERE 
			A.[intPaymentId] IN (SELECT intId FROM @paymentIds)
		AND payDetails.dblPayment != A.dblAmountPaid
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
					AND intPaymentId IN (SELECT intId FROM @paymentIds)
				CROSS APPLY dbo.fnGetBankTransactionReversalErrors(B.intTransactionId) C

		--Fiscal Year
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			'Unable to find an open fiscal year period to match the transaction date.',
			'Payable',
			A.strPaymentRecordNum,
			A.intPaymentId
		FROM tblAPPayment A 
		WHERE  A.[intPaymentId] IN (SELECT intId FROM @paymentIds) AND 
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
						SELECT intBillId, A3.intPaymentId, tmpPayments.intId AS intPostPaymentId
						FROM tblAPPaymentDetail A3 INNER JOIN @paymentIds AS tmpPayments ON A3.intPaymentId = tmpPayments.intId
					) OtherPayments ON A2.intBillId = OtherPayments.intBillId
				WHERE A1.intPaymentId NOT IN (SELECT intId FROM @paymentIds) --exclude the for posted on results
				AND A1.ysnPosted = 1 --get only the posted
				) OtherPaymentsFiltered WHERE rowNum = 1
			) LatestPayment ON A.intPaymentId = LatestPayment.intPostPaymentId
		WHERE  A.[intPaymentId] IN (SELECT intId FROM @paymentIds) 
		AND A.intPaymentId < LatestPayment.intPaymentId
	END

	RETURN
END