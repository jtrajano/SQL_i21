CREATE FUNCTION [dbo].[fnAPValidateRecapBill]
(
	@billIds NVARCHAR(MAX),
	@post BIT
)
RETURNS @returntable TABLE
(
	strError NVARCHAR(200),
	strTransactionType NVARCHAR(50),
	strTransactionId NVARCHAR(50),
	intTransactionId INT,
	intErrorKey INT
)
AS
BEGIN
	
	DECLARE @tmpBills TABLE(
		[intBillId] [int] PRIMARY KEY,
	UNIQUE (intBillId)
	);
	INSERT INTO @tmpBills SELECT * FROM [dbo].fnGetRowsFromDelimitedValues(@billIds)

	IF @post = 0
	BEGIN

		--BILL WAS POSTED FROM ORIGIN
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId, intErrorKey)
		SELECT 
			'No recap available. Transaction was posted from Origin System.',
			'Bill',
			A.strBillId,
			A.intBillId,
			22
		FROM tblAPBill A 
		OUTER APPLY (
			SELECT intGLDetailId FROM tblGLDetail B
			WHERE B.strTransactionId = A.strBillId AND A.intBillId = B.intTransactionId AND B.strModuleName = 'Accounts Payable'
		) GLEntries
		WHERE  A.[intBillId] IN (SELECT [intBillId] FROM @tmpBills) 
		AND GLEntries.intGLDetailId IS NULL

	END
	

	RETURN
END
