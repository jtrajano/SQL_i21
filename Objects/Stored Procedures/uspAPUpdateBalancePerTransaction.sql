CREATE PROCEDURE [dbo].[uspAPUpdateBalancePerTransaction]
	@voucherIds Id READONLY,
	@post BIT
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

	DECLARE @CurrentAPBalance DECIMAL(18, 6), @apBalance DECIMAL(18, 6);
	DECLARE @CurrentGLBalance DECIMAL(18, 6), @apGLBalance DECIMAL(18, 6);
	DECLARE @intPayablesCategory INT, @prepaymentCategory INT;
	DECLARE @transCount INT;

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblAPBalance)
	BEGIN
		INSERT INTO tblAPBalance(dblAPBalance, dblGLBalance, ysnBalance)
		SELECT NULL, NULL, NULL
	END

	SELECT TOP 1 
		@CurrentAPBalance = ISNULL(dblAPBalance,0),
		@CurrentGLBalance = ISNULL(dblGLBalance,0)
	FROM tblAPBalance

	SELECT @intPayablesCategory = intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = 'AP Account'
	SELECT @prepaymentCategory = intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = 'Vendor Prepayments'

	SELECT
		@apGLBalance = SUM(ISNULL(A.dblCredit,0)) - SUM(ISNULL(A.dblDebit, 0))
	FROM tblGLDetail A
	INNER JOIN tblGLAccount B ON A.intAccountId = B.intAccountId
	INNER JOIN vyuGLAccountDetail D ON A.intAccountId = D.intAccountId
	INNER JOIN tblAPBill C ON A.strTransactionId = C.strBillId
	INNER JOIN @voucherIds E ON C.intBillId = E.intId
	WHERE D.intAccountCategoryId IN (@prepaymentCategory, @intPayablesCategory)
	--AND A.ysnIsUnposted = 0
	GROUP BY B.strAccountId

	SELECT 
		 @apBalance = SUM(dblAmountDue)
	FROM (
		SELECT
		A.intBillId
		,A.intAccountId
		,D.strAccountId
		,tmpAgingSummaryTotal.dblAmountDue
		FROM  
		(
			SELECT 
			intBillId
			,CAST((SUM(tmpAPPayables.dblTotal) + SUM(tmpAPPayables.dblInterest) - SUM(tmpAPPayables.dblAmountPaid) - SUM(tmpAPPayables.dblDiscount)) AS DECIMAL(18,2)) AS dblAmountDue
			FROM (
					SELECT * 
					FROM dbo.vyuAPPayables
					WHERE intBillId IN (SELECT intId FROM @voucherIds)
			) tmpAPPayables 
			GROUP BY intBillId
			UNION ALL
			SELECT 
			intBillId
			,CAST((SUM(tmpAPPayables2.dblTotal) + SUM(tmpAPPayables2.dblInterest) - SUM(tmpAPPayables2.dblAmountPaid) - SUM(tmpAPPayables2.dblDiscount)) AS DECIMAL(18,2)) AS dblAmountDue
			FROM (
					SELECT * 
					FROM dbo.vyuAPPrepaidPayables
					WHERE intBillId IN (SELECT intId FROM @voucherIds)
			) tmpAPPayables2 
			GROUP BY intBillId
		) AS tmpAgingSummaryTotal
		LEFT JOIN dbo.tblAPBill A
		ON A.intBillId = tmpAgingSummaryTotal.intBillId
		LEFT JOIN dbo.tblGLAccount D ON  A.intAccountId = D.intAccountId
		WHERE tmpAgingSummaryTotal.dblAmountDue <> 0
	) SubQuery

SET @transCount = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION

	UPDATE tblAPBalance SET dblAPBalance = dblAPBalance + (@apBalance * (CASE WHEN @post = 1 THEN 1 ELSE -1 END))

	UPDATE tblAPBalance SET dblGLBalance = dblGLBalance + (@apGLBalance * (CASE WHEN @post = 1 THEN 1 ELSE -1 END))

	UPDATE tblAPBalance SET [ysnBalance] = CASE WHEN (dblGLBalance = dblAPBalance) THEN 1 ELSE 0 END


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
    SET @ErrorProc     = ERROR_PROCEDURE()
    SET @ErrorMessage  = 'Failed to update the ap balance'
    IF @ErrorState  = 0
    SET @ErrorState = 1
    -- If the error renders the transaction as uncommittable or we have open transactions, we may want to rollback
    IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION
    RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH

END