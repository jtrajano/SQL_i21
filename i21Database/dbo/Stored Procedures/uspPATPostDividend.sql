CREATE PROCEDURE [dbo].[uspPATPostDividend] 
	@intDividendId INT = NULL,
	@ysnPosted BIT = NULL,
	@intUserId INT = NULL,
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
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Dividend'
DECLARE @MODULE_CODE NVARCHAR(5)  = 'PAT'
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

SELECT TOP 1 @intAPClearingId = intAPClearingGLAccount FROM tblPATCompanyPreference;

IF ISNULL(@ysnPosted,0) = 1
BEGIN
	INSERT INTO @GLEntries(
			[dtmDate], 
			[strBatchID], 
			[intAccountId],
			[dblDebit],
			[dblCredit],
			[dblDebitUnit],
			[dblCreditUnit],
			[strDescription],
			[strCode],
			[strReference],
			[intCurrencyId],
			[dtmDateEntered],
			[dtmTransactionDate],
			[strJournalLineDescription],
			[intJournalLineNo],
			[ysnIsUnposted],
			[intUserId],
			[intEntityId],
			[strTransactionId],
			[intTransactionId],
			[strTransactionType],
			[strTransactionForm],
			[strModuleName],
			[dblDebitForeign],
			[dblDebitReport],
			[dblCreditForeign],
			[dblCreditReport],
			[dblReportingRate],
			[dblForeignRate],
			[strRateType]
	)
	SELECT	DISTINCT
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmProcessDate), 0),
		[strBatchID]					=	@batchId COLLATE Latin1_General_CI_AS,
		[intAccountId]					=	D.intDividendsGLAccount,
		[dblDebit]						=	ROUND(C.dblDividendAmount,2),
		[dblCredit]						=	0,
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	0,
		[strDescription]				=	'Posted Dividend GL - ' + D.strStockName,
		[strCode]						=	@MODULE_CODE,
		[strReference]					=	A.strDividendNo,
		[intCurrencyId]					=	1,
		[dtmDateEntered]				=	GETDATE(),
		[dtmTransactionDate]			=	A.dtmProcessDate,
		[strJournalLineDescription]		=	'Dividend GL',
		[intJournalLineNo]				=	1,
		[ysnIsUnposted]					=	0,
		[intUserId]						=	@intUserId,
		[intEntityId]					=	@intUserId,
		[strTransactionId]				=	A.strDividendNo, 
		[intTransactionId]				=	A.intDividendId, 
		[strTransactionType]			=	'Dividend GL',
		[strTransactionForm]			=	@SCREEN_NAME,
		[strModuleName]					=	@MODULE_NAME,
		[dblDebitForeign]				=	0,      
		[dblDebitReport]				=	0,
		[dblCreditForeign]				=	0,
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]				=	0,
		[strRateType]					=	NULL
	FROM	[dbo].tblPATDividends A
		INNER JOIN tblPATDividendsCustomer B
				ON A.intDividendId = B.intDividendId
		INNER JOIN tblPATDividendsStock C
				ON B.intDividendCustomerId = C.intDividendCustomerId
		INNER JOIN tblPATStockClassification D
				ON D.intStockId = C.intStockId
	WHERE	A.intDividendId IN (SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@intDividendId))
	UNION ALL
	--AP Clearing
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmProcessDate), 0),
		[strBatchID]					=	@batchId COLLATE Latin1_General_CI_AS,
		[intAccountId]					=	@intAPClearingId, 
		[dblDebit]						=	0,
		[dblCredit]						=	ROUND(B.dblDividendAmount,2),
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	0,
		[strDescription]				=	'Posted Dividends GL',
		[strCode]						=	@MODULE_CODE,
		[strReference]					=	A.strDividendNo,
		[intCurrencyId]					=	1,
		[dtmDateEntered]				=	GETDATE(),
		[dtmTransactionDate]			=	A.dtmProcessDate,
		[strJournalLineDescription]		=	'AP Clearing',
		[intJournalLineNo]				=	1,
		[ysnIsUnposted]					=	0,
		[intUserId]						=	@intUserId,
		[intEntityId]					=	@intUserId,
		[strTransactionId]				=	A.strDividendNo, 
		[intTransactionId]				=	A.intDividendId, 
		[strTransactionType]			=	'AP Clearing - Dividends',
		[strTransactionForm]			=	@SCREEN_NAME,
		[strModuleName]					=	@MODULE_NAME,
		[dblDebitForeign]				=	0,      
		[dblDebitReport]				=	0,
		[dblCreditForeign]				=	0,
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]				=	0,
		[strRateType]					=	NULL
	FROM	[dbo].tblPATDividends A
	INNER JOIN tblPATDividendsCustomer B
			ON A.intDividendId = B.intDividendId
	INNER JOIN tblAPVendor APV
			ON APV.intEntityId = B.intCustomerId
	WHERE	A.intDividendId IN (SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@intDividendId))
END
ELSE
BEGIN
	INSERT INTO @GLEntries(
			[strTransactionId]
			,[intTransactionId]
			,[dtmDate]
			,[strBatchId]
			,[intAccountId]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[strDescription]
			,[strCode]
			,[strReference]
			,[intCurrencyId]
			,[dblExchangeRate]
			,[dtmDateEntered]
			,[dtmTransactionDate]
			,[strJournalLineDescription]
			,[intJournalLineNo]
			,[ysnIsUnposted]
			,[intUserId]
			,[intEntityId]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]
			,[dblDebitForeign]           
			,[dblDebitReport]            
			,[dblCreditForeign]          
			,[dblCreditReport]           
			,[dblReportingRate]          
			,[dblForeignRate]
			,[strRateType]
	)
	SELECT	
		[strTransactionId]
		,[intTransactionId]
		,[dtmDate]
		,strBatchId = @batchId COLLATE Latin1_General_CI_AS
		,[intAccountId]
		,[dblDebit] = [dblCredit]		-- (Debit -> Credit)
		,[dblCredit] = [dblDebit]		-- (Debit <- Credit)
		,[dblDebitUnit] = [dblCreditUnit]	-- (Debit Unit -> Credit Unit)
		,[dblCreditUnit] = [dblDebitUnit]	-- (Debit Unit <- Credit Unit)
		,'Unposted Dividend GL'
		,[strCode]
		,[strReference]
		,[intCurrencyId]
		,[dblExchangeRate]
		,dtmDateEntered = GETDATE()
		,[dtmTransactionDate]
		,[strJournalLineDescription]
		,[intJournalLineNo]
		,ysnIsUnposted = 1
		,intUserId = @intUserId
		,[intEntityId]
		,[strTransactionType]
		,[strTransactionForm]
		,[strModuleName]
		,[dblDebitForeign]           
		,[dblDebitReport]            
		,[dblCreditForeign]          
		,[dblCreditReport]           
		,[dblReportingRate]          
		,[dblForeignRate]
		,NULL
	FROM	tblGLDetail 
	WHERE	intTransactionId IN (SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@intDividendId))
	AND ysnIsUnposted = 0
	AND strModuleName = @MODULE_NAME
	AND strTransactionForm = @SCREEN_NAME
	ORDER BY intGLDetailId
END

BEGIN TRY

EXEC uspGLBookEntries @GLEntries, @ysnPosted
END TRY
BEGIN CATCH
	SET @error = ERROR_MESSAGE()
	RAISERROR(@error, 16, 1);
	GOTO Post_Rollback
END CATCH

IF ISNULL(@ysnPosted,0) = 0
BEGIN
	
	UPDATE tblGLDetail SET ysnIsUnposted = 1
		WHERE intTransactionId = @intDividendId 
			AND strModuleName = @MODULE_NAME
			AND strTransactionForm = @SCREEN_NAME
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
