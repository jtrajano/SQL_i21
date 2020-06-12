CREATE FUNCTION [dbo].[fnAPValidateVoucherPrepay]
(
	@voucherPrepayIds AS Id READONLY,
	@post BIT
)
RETURNS @returntable TABLE
(
	strError NVARCHAR(1000),
	strTransactionType NVARCHAR(50),
	strTransactionId NVARCHAR(50),
	intTransactionId INT,
	intErrorKey	INT
)
AS
BEGIN
	IF @post = 1
	BEGIN
		--MAKE SURE IT HAS CORRECT ACCOUNT TO USE
		INSERT INTO @returntable
		SELECT
			'Invalid prepay account used in ' + voucher.strBillId,
			'Bill',
			voucher.strBillId,
			voucher.intBillId,
			24
		FROM tblAPBill voucher
		INNER JOIN @voucherPrepayIds B ON voucher.intBillId = B.intId
		INNER JOIN vyuGLAccountDetail C ON voucher.intAccountId = C.intAccountId
		WHERE C.intAccountCategoryId != 53 --Vendor Prepayments

		INSERT INTO @returntable
		SELECT
			'Invalid AP Account used in detail item of ' + voucher.strBillId,
			'Bill',
			voucher.strBillId,
			voucher.intBillId,
			24
		FROM tblAPBill voucher
		INNER JOIN @voucherPrepayIds B ON voucher.intBillId = B.intId
		INNER JOIN tblAPBillDetail C ON B.intId = C.intBillId
		OUTER APPLY (
			select Se.intAccountCategoryId from tblGLAccount A
			join tblGLAccountSegmentMapping S on A.intAccountId = S.intAccountId
			join tblGLAccountSegment Se on Se.intAccountSegmentId = S.intAccountSegmentId
			join tblGLAccountStructure St on St.intAccountStructureId = Se.intAccountStructureId
			join tblGLAccountCategory Ca on Ca.intAccountCategoryId = Se.intAccountCategoryId
				where  A.intAccountId = C.intAccountId
				and St.strType = 'Primary'
		) accountCategory
		WHERE (accountCategory.intAccountCategoryId != 1 --Vendor Prepayments
		OR accountCategory.intAccountCategoryId IS NULL) 

		--Do not allow posting with 0 cost in one of the details
		INSERT INTO @returntable
		SELECT 
			'The cost in one of the details is 0.',
			'Bill',
			A.strBillId,
			A.intBillId,
			27
		FROM tblAPBill A 
		INNER JOIN @voucherPrepayIds B ON A.intBillId = B.intId
		WHERE EXISTS(SELECT TOP 1 1 FROM tblAPBillDetail C WHERE C.intBillId = A.intBillId AND C.dblCost = 0)
		
		INSERT INTO @returntable
		SELECT 
			'The transaction is already posted.',
			'Bill',
			A.strBillId,
			A.intBillId,
			35
		FROM tblAPBill A 
		INNER JOIN @voucherPrepayIds B ON A.intBillId = B.intId
		WHERE
			A.ysnPosted = 1
	END
	ELSE
	BEGIN
		INSERT INTO @returntable
		SELECT
			'You cannot unpost this prepaid. ' + A.strPaymentRecordNum + ' payment was already made on this prepaid. You must delete the payment first.',
			'Bill',
			C.strBillId,
			C.intBillId,
			28
		FROM tblAPPayment A
			INNER JOIN tblAPPaymentDetail B 
				ON A.intPaymentId = B.intPaymentId
			INNER JOIN tblAPBill C
				ON B.intBillId = C.intBillId
			LEFT JOIN tblCMBankTransaction D
				ON A.strPaymentRecordNum = D.strTransactionId
		WHERE  C.[intBillId] IN (SELECT [intId] FROM @voucherPrepayIds)
		AND 1 = CASE WHEN D.intTransactionId IS NOT NULL
					THEN CASE WHEN D.ysnCheckVoid = 0 THEN 1 ELSE 0 END
				ELSE 1 END
		UNION ALL
		SELECT
			'You cannot unpost this prepaid. ' + A.strRecordNumber + ' payment was already made on this prepaid. You must delete the payment first.',
			'Bill',
			C.strBillId,
			C.intBillId,
			29
		FROM tblARPayment A
			INNER JOIN tblARPaymentDetail B 
				ON A.intPaymentId = B.intPaymentId
			INNER JOIN tblAPBill C
				ON B.intBillId = C.intBillId
		WHERE  C.[intBillId] IN (SELECT [intId] FROM @voucherPrepayIds)
		AND A.ysnPosted = 1
		UNION ALL
		SELECT
			'You cannot unpost a prepaid that has a reversal.',
			'Bill',
			C.strBillId,
			C.intBillId,
			30
		FROM tblARPayment A
			INNER JOIN tblARPaymentDetail B 
				ON A.intPaymentId = B.intPaymentId
			INNER JOIN tblAPBill C
				ON B.intBillId = C.intBillId
		WHERE  C.[intBillId] IN (SELECT [intId] FROM @voucherPrepayIds)
		AND A.ysnPosted = 1
		AND C.intTransactionReversed > 0
	END
	
	RETURN;
END
