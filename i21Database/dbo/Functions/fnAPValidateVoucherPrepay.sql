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
	DECLARE	 @AllowSingleEntries BIT
			,@AllowIntraEntries BIT
			,@DueToAccountId	INT
			,@DueFromAccountId  INT
			,@OverrideCompanySegment  BIT
			,@OverrideLocationSegment  BIT
			,@OverrideLineOfBusinessSegment  BIT
	SELECT TOP 1
		  @AllowSingleEntries = ysnAllowSingleLocationEntries,
		  @AllowIntraEntries= CASE WHEN ISNULL(ysnAllowIntraCompanyEntries, 0) = 1 OR ISNULL(ysnAllowIntraLocationEntries, 0) = 1 THEN 1 ELSE 0 END, 
		  @DueToAccountId	= ISNULL([intDueToAccountId], 0), 
		  @DueFromAccountId = ISNULL([intDueFromAccountId], 0),
		  @OverrideCompanySegment = ISNULL([ysnOverrideCompanySegment], 0),
		  @OverrideLocationSegment = ISNULL([ysnOverrideLocationSegment], 0),
		  @OverrideLineOfBusinessSegment = ISNULL([ysnOverrideLineOfBusinessSegment], 0)
	FROM tblAPCompanyPreference

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

		--VALIDATE THE AMOUNT DUE
		INSERT INTO @returntable
		SELECT
			A.strBillId + ' has invalid amount due.',
			'Bill',
			A.strBillId,
			A.intBillId,
			34
		FROM tblAPBill A
		WHERE 
		A.intBillId IN (SELECT intId FROM @voucherPrepayIds) 
		AND 
		(
			--amount due should be total less payment
			(A.dblAmountDue != (A.dblTotal - A.dblPayment))
			OR
			--amount due cannot be greater than the total
			(A.dblAmountDue > A.dblTotal)
			OR
			--amount due cannot be negative
			(A.dblAmountDue < 0)
		)

		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId, intErrorKey)
		SELECT
			'You cannot post for approved transaction.',
			'Bill',
			A.strBillId,
			A.intBillId,
			36
		FROM tblAPBill A 
		WHERE  A.intBillId IN (SELECT [intId] FROM @voucherPrepayIds) 
		AND EXISTS (
			SELECT 1 FROM vyuAPForApprovalTransaction B WHERE A.intBillId = B.intTransactionId --AND B.strScreenName = 'Voucher'
		)

		--You cannot post intra-location transaction without due to account. 
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId, intErrorKey)
		SELECT 
			'Unable to find the due to account that matches the account segment/s of the AP Account. Please add ' + OVERRIDESEGMENT.strOverrideAccount + ' to the chart of accounts.',
			'Bill',
			A.strBillId,
			A.intBillId,
			40
		FROM tblAPBill A 
		INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
		OUTER APPLY (
			SELECT * FROM dbo.[fnARGetOverrideAccount](A.[intAccountId], @DueToAccountId, @OverrideCompanySegment, @OverrideLocationSegment, @OverrideLineOfBusinessSegment)
		) OVERRIDESEGMENT
		WHERE A.intBillId IN (SELECT [intId] FROM @voucherPrepayIds)
		AND @AllowIntraEntries = 1
		AND OVERRIDESEGMENT.bitOverriden = 0
		AND (
			(OVERRIDESEGMENT.bitSameCompanySegment = 0 AND @OverrideCompanySegment = 1) OR
			(OVERRIDESEGMENT.bitSameLocationSegment = 0 AND @OverrideLocationSegment = 1) OR
			(OVERRIDESEGMENT.bitSameLineOfBusinessSegment = 0 AND @OverrideLineOfBusinessSegment = 1)
		)

		--You cannot post intra-location transaction without due from account. 
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId, intErrorKey)
		SELECT 
			'Unable to find the due from account that matches the account segment/s of the Payables Account. Please add ' + OVERRIDESEGMENT.strOverrideAccount + ' to the chart of accounts.',
			'Bill',
			A.strBillId,
			A.intBillId,
			41
		FROM tblAPBill A 
		INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
		OUTER APPLY (
			SELECT * FROM dbo.[fnARGetOverrideAccount](A.[intAccountId], @DueFromAccountId, @OverrideCompanySegment, @OverrideLocationSegment, @OverrideLineOfBusinessSegment)
		) OVERRIDESEGMENT
		WHERE A.intBillId IN (SELECT [intId] FROM @voucherPrepayIds)
		AND @AllowIntraEntries = 1
		AND OVERRIDESEGMENT.bitOverriden = 0
		AND (
			(OVERRIDESEGMENT.bitSameCompanySegment = 0 AND @OverrideCompanySegment = 1) OR
			(OVERRIDESEGMENT.bitSameLocationSegment = 0 AND @OverrideLocationSegment = 1) OR
			(OVERRIDESEGMENT.bitSameLineOfBusinessSegment = 0 AND @OverrideLineOfBusinessSegment = 1)
		)

		--VALIDATE DETAIL ACCOUNT OVERRIDE
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId, intErrorKey)
		SELECT 
			'Unable to find the purchasing account that matches the account segment/s of the Payables Account. Please add ' + OVERRIDESEGMENT.strOverrideAccount + ' to the chart of accounts.',
			'Bill',
			A.strBillId,
			A.intBillId,
			42
		FROM tblAPBill A 
		INNER JOIN tblAPBillDetail B ON B.intBillId = A.intBillId
		OUTER APPLY (
			SELECT * FROM dbo.[fnARGetOverrideAccount](A.[intAccountId], B.intAccountId, @OverrideCompanySegment, @OverrideLocationSegment, @OverrideLineOfBusinessSegment)
		) OVERRIDESEGMENT
		WHERE A.intBillId IN (SELECT [intId] FROM @voucherPrepayIds)
		AND OVERRIDESEGMENT.bitOverriden = 0
		AND (
			(OVERRIDESEGMENT.bitSameCompanySegment = 0 AND @OverrideCompanySegment = 1) OR
			(OVERRIDESEGMENT.bitSameLocationSegment = 0 AND @OverrideLocationSegment = 1) OR
			(OVERRIDESEGMENT.bitSameLineOfBusinessSegment = 0 AND @OverrideLineOfBusinessSegment = 1)
		)

		--VALIDATE TAX ACCOUNT OVERRIDE
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId, intErrorKey)
		SELECT 
			'Unable to find the tax account that matches the account segment/s of the Payables Account. Please add ' + OVERRIDESEGMENT.strOverrideAccount + ' to the chart of accounts.',
			'Bill',
			A.strBillId,
			A.intBillId,
			43
		FROM tblAPBill A 
		INNER JOIN tblAPBillDetail B ON B.intBillId = A.intBillId
		INNER JOIN tblAPBillDetailTax C ON C.intBillDetailId = B.intBillDetailId
		OUTER APPLY (
			SELECT * FROM dbo.[fnARGetOverrideAccount](A.[intAccountId], C.intAccountId, @OverrideCompanySegment, @OverrideLocationSegment, @OverrideLineOfBusinessSegment)
		) OVERRIDESEGMENT
		WHERE A.intBillId IN (SELECT [intId] FROM @voucherPrepayIds)
		AND OVERRIDESEGMENT.bitOverriden = 0
		AND (
			(OVERRIDESEGMENT.bitSameCompanySegment = 0 AND @OverrideCompanySegment = 1) OR
			(OVERRIDESEGMENT.bitSameLocationSegment = 0 AND @OverrideLocationSegment = 1) OR
			(OVERRIDESEGMENT.bitSameLineOfBusinessSegment = 0 AND @OverrideLineOfBusinessSegment = 1)
		)

		--You cannot post if location segment of AP Account and Payable Account when single location entry is enabled. 
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId, intErrorKey)
		SELECT 
			'Purchase and AP Account should have the same location segment.',
			'Bill',
			A.strBillId,
			A.intBillId,
			44
		FROM tblAPBill A 
		INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
		OUTER APPLY (
			SELECT *
			FROM dbo.[fnARGetOverrideAccount](A.[intAccountId], B.intAccountId, 0, @OverrideLocationSegment, 0)
		) OVERRIDESEGMENT
		WHERE A.intBillId IN (SELECT [intId] FROM @voucherPrepayIds)
		AND @AllowSingleEntries = 1
		AND [dbo].[fnARCompareAccountSegment](A.[intAccountId], OVERRIDESEGMENT.intOverrideAccount, 3) = 0

		--VALIDATE PAY TO BANK ACCOUNT
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId, intErrorKey)
		SELECT
			'Pay To Bank Account is required.',
			'Bill',
			A.strBillId,
			A.intBillId,
			45
		FROM tblAPBill A
		INNER JOIN vyuAPVendor B ON B.intEntityId = A.intEntityVendorId
		WHERE 
			A.intBillId IN (SELECT [intId] FROM @voucherPrepayIds) 
		AND A.intPayToBankAccountId IS NULL
		AND B.intPaymentMethodId = 2 --ACH
		AND A.intTransactionType NOT IN (3)
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
