CREATE FUNCTION [dbo].[fnAPValidateBillGLEntries]
(
	@GLEntries AS RecapTableType READONLY,
	@billIds AS Id READONLY
)
RETURNS @returntable TABLE
(
	strError NVARCHAR(1000),
	strTransactionType NVARCHAR(50),
	strTransactionId NVARCHAR(50),
	intTransactionId INT,
	intErrorKey INT
)
AS
BEGIN
	INSERT @returntable
	SELECT
		A.strBillId + ' total do not match with AP Account GL entries total.'
		,'Bill'
		,A.strBillId
		,A.intBillId
		,1
	FROM tblAPBill A
	INNER JOIN @billIds A2 ON A.intBillId = A2.intId
	OUTER APPLY (
		SELECT
			ABS(SUM(dblCredit - dblDebit)) AS dblTotal
		FROM @GLEntries B
		INNER JOIN vyuGLAccountDetail C ON B.intAccountId = C.intAccountId
		WHERE B.strTransactionId = A.strBillId
			AND C.intAccountCategoryId IN (1, 53)
	) glEntries
	WHERE
		A.dblTotal != ISNULL(glEntries.dblTotal,0)
	GROUP BY A.intBillId, A.strBillId
	RETURN;
END
