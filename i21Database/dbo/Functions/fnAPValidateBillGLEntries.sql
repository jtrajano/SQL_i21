﻿CREATE FUNCTION [dbo].[fnAPValidateBillGLEntries]
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
			SUM(dblCredit) AS dblTotal
		FROM @GLEntries B
		WHERE B.strTransactionId = A.strBillId
	) glEntries
	WHERE
		A.dblAmountDue != ISNULL(glEntries.dblTotal,0)
	GROUP BY A.intBillId, A.strBillId
	RETURN;
END
