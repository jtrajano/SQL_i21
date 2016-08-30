CREATE PROCEDURE [dbo].[uspAPUpdatePrepayAndDebitMemo]
	@billIds NVARCHAR(MAX),
	@post BIT
AS

CREATE TABLE #tmpBillsId (
	[intBillId] [int] PRIMARY KEY,
	UNIQUE (intBillId)
);

BEGIN TRY

DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION

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
	AND B.ysnApplied = 1
	GROUP BY B.intTransactionId
	UNION ALL
	--when posting claims, make sure to update the amount due of prepayment
	SELECT
		DISTINCT C.dblTotal AS dblAmountApplied
	FROM tblAPBill C
	INNER JOIN tblAPBillDetail D ON C.intBillId = D.intBillId
	INNER JOIN tblAPBillDetail E ON D.intContractDetailId = E.intContractDetailId AND D.intContractHeaderId = E.intContractHeaderId --prepayment
	INNER JOIN tblAPBill F ON E.intBillId = F.intBillId --prepayment
	WHERE C.intBillId IN (SELECT intBillId FROM #tmpBillsId)
	AND F.intTransactionType = 2 --prepayment
	AND F.intBillId = A.intBillId
	AND C.intTransactionType = 11 --Claims
) AppliedPayments
WHERE A.intTransactionType IN (2,3,8)
AND 1 = CASE WHEN A.intTransactionType= 3 AND A.ysnPosted != 1 --DEBIT MEMO should be posted
			 THEN 0 ELSE 1 END

--DELETE THE RECORDS THAT HAS NOT BEEN USED IF POSTING
IF @post = 1
BEGIN
	DELETE A
	FROM tblAPAppliedPrepaidAndDebit A
	INNER JOIN #tmpBillsId B ON A.intBillId = B.intBillId
	WHERE A.dblAmountApplied = 0
END

--VALIDATIONS
--MAKE SURE PAYMENT IS CORRECT FOR CURRENT TRANSACTION
DECLARE @error NVARCHAR(200);
SELECT TOP 1
	@error = A.strBillId + ' invalid amount applied.'
FROM tblAPBill A
WHERE (
		(A.intBillId IN (SELECT intBillId FROM #tmpBillsId)) --Bill Transactions
		OR
		EXISTS(SELECT 1 FROM tblAPAppliedPrepaidAndDebit B WHERE B.intBillId IN (SELECT intBillId FROM #tmpBillsId) 
					AND B.intTransactionId = A.intBillId AND B.ysnApplied = 1) --Prepay and Debit Memo transactions
	)
AND (
	A.dblPayment > A.dblTotal
	OR A.dblAmountDue < 0
	OR A.dblAmountDue > A.dblTotal
	OR A.dblPayment < 0
)


IF @error IS NOT NULL
BEGIN
	RAISERROR(@error, 16, 1);
END

IF @transCount = 0 COMMIT TRANSACTION

END TRY
BEGIN CATCH
	DECLARE @ErrorSeverity INT,
			@ErrorNumber   INT,
			@ErrorMessage nvarchar(4000),
			@ErrorState INT,
			@ErrorLine  INT,
			@ErrorProc nvarchar(200);
	-- Grab error information from SQL functions
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorNumber   = ERROR_NUMBER()
	SET @ErrorMessage  = ERROR_MESSAGE()
	SET @ErrorState    = ERROR_STATE()
	SET @ErrorLine     = ERROR_LINE()
	IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION
	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH