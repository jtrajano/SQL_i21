CREATE PROCEDURE [dbo].[uspPATPostIssueStock]
	@intCustomerStockId INT = NULL,
	@ysnPosted BIT = NULL,
	@ysnRecap BIT = NULL,
	@ysnVoting BIT = NULL,
	@ysnRetired BIT = NULL,
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

BEGIN TRANSACTION -- START TRANSACTION

DECLARE @dateToday AS DATETIME = GETDATE();
DECLARE @GLEntries AS RecapTableType;
DECLARE @totalRecords INT;
DECLARE @error NVARCHAR(200);
DECLARE @batchId NVARCHAR(40);

IF(@batchId IS NULL)
	EXEC uspSMGetStartingNumber 3, @batchId OUT

SET @batchIdUsed = @batchId;

IF (@ysnRetired = 1)
BEGIN
	IF(@ysnPosted = 1)
	BEGIN

	------------------------CREATE GL ENTRIES---------------------
		INSERT INTO @GLEntries
		SELECT * FROM [dbo].[fnPATCreateRetireStockGLEntries](@intCustomerStockId, 0, @intUserId, @batchId)

	END
	ELSE
	BEGIN
	------------------------REVERSE GL ENTRIES---------------------
		INSERT INTO @GLEntries
		SELECT * FROM [dbo].[fnPATReverseRetireStockGLEntries](@intCustomerStockId, @dateToday, @intUserId, @batchId)

		UPDATE tblGLDetail SET ysnIsUnposted = 1
		WHERE intTransactionId = @intCustomerStockId 
			AND strModuleName = N'Patronage' AND strTransactionForm = N'Retire Stock'
	END
END
ELSE
BEGIN
	IF(@ysnVoting = 1)
	BEGIN
		IF(@ysnPosted = 1)
		BEGIN

		------------------------CREATE GL ENTRIES---------------------
			INSERT INTO @GLEntries
			SELECT * FROM [dbo].[fnPATCreateIssueStockGLEntries](@intCustomerStockId, @ysnVoting, @intUserId, @batchId)

		END
		ELSE
		BEGIN

		------------------------REVERSE GL ENTRIES---------------------
			INSERT INTO @GLEntries
			SELECT * FROM [dbo].[fnPATReverseIssueStockGLEntries](@intCustomerStockId, @dateToday, @intUserId, @batchId)

			UPDATE tblGLDetail SET ysnIsUnposted = 1
			WHERE intTransactionId = @intCustomerStockId 
				AND strModuleName = N'Patronage' AND strTransactionForm = N'Issue Stock'
		END
	END
END
BEGIN TRY
IF(ISNULL(@ysnRecap, 0) = 0)
BEGIN
	SELECT * FROM @GLEntries
	EXEC uspGLBookEntries @GLEntries, @ysnPosted

	
------------UPDATE CUSTOMER STOCK TABLE---------------

	UPDATE tblPATCustomerStock SET ysnPosted = @ysnPosted WHERE intCustomerStockId = @intCustomerStockId
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
END
END TRY
BEGIN CATCH
	SET @error = ERROR_MESSAGE()
	RAISERROR(@error, 16, 1);
	GOTO Post_Rollback
END CATCH



---------------------------------------------------------------------------------------------------------------------------------------
IF @@ERROR <> 0	GOTO Post_Rollback;

GOTO Post_Commit;

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