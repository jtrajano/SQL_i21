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
		OUTER APPLY (
			select Se.intAccountCategoryId from tblGLAccount A
			join tblGLAccountSegmentMapping S on A.intAccountId = S.intAccountId
			join tblGLAccountSegment Se on Se.intAccountSegmentId = S.intAccountSegmentId
			join tblGLAccountStructure St on St.intAccountStructureId = Se.intAccountStructureId
			join tblGLAccountCategory Ca on Ca.intAccountCategoryId = Se.intAccountCategoryId
				where  A.intAccountId = voucher.intAccountId
				and St.strType = 'Primary'
		) accountCategory
		WHERE accountCategory.intAccountCategoryId != 53 --Vendor Prepayments

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
	END
	
	RETURN;
END
