CREATE PROCEDURE [dbo].[uspAPUpdatePrepayAndDebitMemo]
	@billIds NVARCHAR(MAX),
	@post BIT
AS

CREATE TABLE #tmpBillsId (
	[intBillId] [int] PRIMARY KEY,
	UNIQUE (intBillId)
);

INSERT INTO #tmpBillsId SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@billIds)

UPDATE A
	SET dblAmountDue = CASE WHEN @post = 0 
			THEN A.dblAmountDue + AppliedPayments.dblAmountApplied
			ELSE A.dblAmountDue - AppliedPayments.dblAmountApplied END
	,dblPayment = CASE WHEN @post = 0 
			THEN dblPayment - AppliedPayments.dblAmountApplied
			ELSE dblPayment + AppliedPayments.dblAmountApplied END
	,ysnPaid = CASE WHEN @post = 1
			THEN CASE WHEN (A.dblAmountDue - AppliedPayments.dblAmountApplied) = 0 THEN 1 ELSE 0 END
			ELSE 0 END
FROM tblAPBill A
CROSS APPLY
(
	SELECT 
		SUM(B.dblAmountApplied) AS dblAmountApplied
	FROM tblAPAppliedPrepaidAndDebit B
	WHERE A.intBillId = B.intTransactionId
	AND B.intBillId IN (SELECT intBillId FROM #tmpBillsId)
	GROUP BY B.intTransactionId
) AppliedPayments
WHERE A.intTransactionType IN (2,3,8)
AND 1 = CASE WHEN A.intTransactionType= 3 AND A.ysnPosted != 1 --DEBIT MEMO should be posted
			 THEN 0 ELSE 1 END