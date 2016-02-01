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
	GROUP BY B.intTransactionId
) AppliedPayments
WHERE A.intTransactionType IN (2,3,8)
AND 1 = CASE WHEN A.intTransactionType= 3 AND A.ysnPosted != 1 --DEBIT MEMO should be posted
			 THEN 0 ELSE 1 END

--VALIDATIONS
--MAKE SURE PAYMENT NOT GREATER THAN TO TOTAL
DECLARE @error NVARCHAR(200);
SELECT TOP 1
	@error = A.strBillId + ' invalid amount applied.'
FROM tblAPBill A
WHERE A.intTransactionType IN (2,3,8)
AND A.intBillId IN (SELECT intBillId FROM #tmpBillsId)
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