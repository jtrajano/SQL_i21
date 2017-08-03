CREATE PROCEDURE [dbo].[uspPATPostDividend] 
	@intDividendId INT = NULL,
	@ysnPosted BIT = NULL,
	@ysnRecap BIT = NULL,
	@intUserId INT = NULL,
	@batchIdUsed NVARCHAR(40) = NULL OUTPUT,
	@successfulCount INT = 0 OUTPUT,
	@invalidCount INT = 0 OUTPUT,
	@success BIT = 0 OUTPUT 
AS
BEGIN


SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

--DECLARE VARIABLES
DECLARE @PostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully posted.'
DECLARE @UnpostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully unposted.'
DECLARE @MODULE_NAME NVARCHAR(25) = 'Patronage'
DECLARE @TRAN_TYPE NVARCHAR(25) = 'Dividend'
DECLARE @totalRecords INT
DECLARE @GLEntries AS RecapTableType 
DECLARE @error NVARCHAR(200)
DECLARE @batchId NVARCHAR(40)
DECLARE @intAPClearingId AS INT;

---------------------------------------------------------------------------------------------------------------------------------------
BEGIN TRANSACTION
--=====================================================================================================================================
-- 	CREATE GL ENTRIES
---------------------------------------------------------------------------------------------------------------------------------------
IF(@batchId IS NULL)
	EXEC uspSMGetStartingNumber 3, @batchId OUT

SET @batchIdUsed = @batchId;

SELECT TOP 1 @intAPClearingId = intAPClearingGLAccount FROM tblPATCompanyPreference;

IF ISNULL(@ysnPosted,0) = 1
BEGIN
	INSERT INTO @GLEntries
	SELECT * FROM dbo.fnPATCreateDividendGLEntries(@intDividendId, @batchId, @intUserId, @intAPClearingId)
END
ELSE
BEGIN
	INSERT INTO @GLEntries
	SELECT * FROM dbo.fnPATReverseGLDividendEntries(@intDividendId, @batchId, GETDATE(), @intUserId)
END

BEGIN TRY

	IF(ISNULL(@ysnRecap,0) = 0)
	BEGIN
		EXEC uspGLBookEntries @GLEntries, @ysnPosted
	END
	ELSE
	BEGIN
			SELECT * FROM @GLEntries
			INSERT INTO tblGLPostRecap(
				[strTransactionId]
				,[intTransactionId]
				,[intAccountId]
				,[strDescription]
				,[strJournalLineDescription]
				,[strReference]	
				,[dtmTransactionDate]
				,[dblDebit]
				,[dblCredit]
				,[dblDebitUnit]
				,[dblCreditUnit]
				,[dtmDate]
				,[ysnIsUnposted]
				,[intConcurrencyId]	
				,[dblExchangeRate]
				,[intUserId]
				,[dtmDateEntered]
				,[strBatchId]
				,[strCode]
				,[strModuleName]
				,[strTransactionForm]
				,[strTransactionType]
				,[strAccountId]
				,[strAccountGroup]
			)
			SELECT
				[strTransactionId]
				,A.[intTransactionId]
				,A.[intAccountId]
				,A.[strDescription]
				,A.[strJournalLineDescription]
				,A.[strReference]	
				,A.[dtmTransactionDate]
				,A.[dblDebit]
				,A.[dblCredit]
				,A.[dblDebitUnit]
				,A.[dblCreditUnit]
				,A.[dtmDate]
				,A.[ysnIsUnposted]
				,A.[intConcurrencyId]	
				,A.[dblExchangeRate]
				,A.[intUserId]
				,A.[dtmDateEntered]
				,A.[strBatchId]
				,A.[strCode]
				,A.[strModuleName]
				,A.[strTransactionForm]
				,A.[strTransactionType]
				,B.strAccountId
				,C.strAccountGroup
			FROM @GLEntries A
			INNER JOIN dbo.tblGLAccount B 
				ON A.intAccountId = B.intAccountId
			INNER JOIN dbo.tblGLAccountGroup C
				ON B.intAccountGroupId = C.intAccountGroupId

			GOTO Post_Commit;
	END
END TRY
BEGIN CATCH
	SET @error = ERROR_MESSAGE()
	RAISERROR(@error, 16, 1);
	GOTO Post_Rollback
END CATCH

IF (ISNULL(@ysnPosted,0) = 0)
BEGIN
	
	UPDATE tblGLDetail SET ysnIsUnposted = 1
		WHERE intTransactionId = @intDividendId 
			AND strModuleName = @MODULE_NAME
			AND strTransactionForm = @TRAN_TYPE
END

--=====================================================================================================================================
-- 	UPDATE DIVIDENDS TABLE
---------------------------------------------------------------------------------------------------------------------------------------

	UPDATE tblPATDividends 
	   SET ysnPosted = ISNULL(@ysnPosted,0)
	  FROM tblPATDividends R
	 WHERE R.intDividendId = @intDividendId


IF @@ERROR <> 0	GOTO Post_Rollback;

GOTO Post_Commit;

--=====================================================================================================================================
-- 	FINALIZING STAGE
---------------------------------------------------------------------------------------------------------------------------------------
Post_Commit:
	COMMIT TRANSACTION
	SET @success = 1
	SET @successfulCount = @totalRecords
	GOTO Post_Exit

Post_Rollback:
	ROLLBACK TRANSACTION	
	SET @success = 0
	GOTO Post_Exit

Post_Exit:

END

GO
