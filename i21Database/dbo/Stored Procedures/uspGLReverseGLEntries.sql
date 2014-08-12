
--=====================================================================================================================================
-- 	CREATE THE STORED PROCEDURE AFTER DELETING IT
---------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[uspGLReverseGLEntries]
	 @strBatchId		AS NVARCHAR(100)	= ''
	,@strTransactionId	NVARCHAR(40)	= NULL
	,@ysnRecap			AS BIT			= 0
	,@strCode			NVARCHAR(10)	= NULL
	,@dtmDateReverse	DATETIME		= NULL 
	,@intEntityId		INT				= NULL 
	,@successfulCount	AS INT			= 0 OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRANSACTION;

--=====================================================================================================================================
-- 	INITIALIZATION 
---------------------------------------------------------------------------------------------------------------------------------------
IF ISNULL(@ysnRecap, 0) = 0
BEGIN
	SELECT	@strBatchId = MAX(strBatchId)
	FROM	tblGLDetail
	WHERE	strTransactionId = @strTransactionId
			AND ysnIsUnposted = 0
			AND strCode = ISNULL(@strCode, strCode)
END			

--=====================================================================================================================================
-- 	REVERSE THE G/L ENTRIES
---------------------------------------------------------------------------------------------------------------------------------------
IF ISNULL(@ysnRecap, 0) = 0
	BEGIN			
		INSERT INTO tblGLDetail (
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
				,[intConcurrencyId]
				,[intUserId]
				,[intEntityId]
				,[strTransactionType]
				,[strTransactionForm]
				,[strModuleName]
		)
		SELECT	 [strTransactionId]
				,[intTransactionId]
				,dtmDate			= ISNULL(@dtmDateReverse, [dtmDate]) -- If date is provided, use date reverse as the date for unposting the transaction.
				,[strBatchId]
				,[intAccountId]
				,dblDebit			= [dblCredit]		-- (Debit -> Credit)
				,dblCredit			= [dblDebit]		-- (Debit <- Credit)
				,dblDebitUnit		= [dblCreditUnit]	-- (Debit Unit -> Credit Unit)
				,dblCreditUnit		= [dblDebitUnit]	-- (Debit Unit <- Credit Unit)
				,[strDescription]
				,[strCode]
				,[strReference]
				,[intCurrencyId]
				,[dblExchangeRate]
				,dtmDateEntered		= GETDATE()
				,[dtmTransactionDate]
				,[strJournalLineDescription]
				,[intJournalLineNo]
				,ysnIsUnposted		= 1
				,[intConcurrencyId]
				,[intUserId]		= 0
				,[intEntityId]		= @intEntityId
				,[strTransactionType]
				,[strTransactionForm]
				,[strModuleName]
		FROM	tblGLDetail 
		WHERE	strTransactionId = @strTransactionId and ysnIsUnposted = 0
		ORDER BY intGLDetailId		

		IF @@ERROR <> 0	GOTO Post_Rollback;
	END
ELSE
	BEGIN
		-- DELETE Results 1 DAYS OLDER	
		DELETE tblGLPostRecap WHERE dtmDateEntered < DATEADD(day, -1, GETDATE()) and intEntityId = @intEntityId;
		
		WITH Accounts 
		AS 
		(
			SELECT A.[strAccountId], A.[intAccountId], A.[intAccountGroupId], B.[strAccountGroup]
			FROM tblGLAccount A LEFT JOIN tblGLAccountGroup B on A.intAccountGroupId = B.intAccountGroupId
		)
		INSERT INTO tblGLPostRecap (
			 [strTransactionId]
			,[intTransactionId]
			,[intAccountId]
			,[strAccountId]
			,[strAccountGroup]
			,[strDescription]
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
			,[intEntityId]
			,[dtmDateEntered]
			,[strBatchId]
			,[strCode]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]
		)
		SELECT 
			 [strTransactionId]
			,[intTransactionId]
			,[intAccountId]			
			,[strAccountId]			= (SELECT [strAccountId] FROM Accounts WHERE [intAccountId] = A.[intAccountId])
			,[strAccountGroup]		= (SELECT [strAccountGroup] FROM Accounts WHERE [intAccountId] = A.[intAccountId])
			,[strDescription]		
			,[strReference]			
			,[dtmTransactionDate]	
			,[dblDebit]				= [dblCredit]
			,[dblCredit]			= [dblDebit]	
			,[dblDebitUnit]			= [dblCreditUnit]
			,[dblCreditUnit]		= [dblDebitUnit]
			,[dtmDate]				
			,[ysnIsUnposted]		
			,[intConcurrencyId]		
			,[dblExchangeRate]		
			,[intUserId]			= 0
			,[intEntityId]			= @intEntityId
			,[dtmDateEntered]		= GETDATE()
			,[strBatchId]			= @strBatchId
			,[strCode]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]
		FROM	tblGLDetail A
		WHERE	strTransactionId = @strTransactionId and ysnIsUnposted = 0
		ORDER BY intGLDetailId
				
		IF @@ERROR <> 0	GOTO Post_Rollback;

		GOTO Post_Commit;

	END

IF @@ERROR <> 0	GOTO Post_Rollback;

--=====================================================================================================================================
-- 	UPDATE GL SUMMARY RECORDS
---------------------------------------------------------------------------------------------------------------------------------------
WITH GLDetail
AS
(
	SELECT   [dtmDate]		= ISNULL(A.[dtmDate], GETDATE())
			,[intAccountId]	= A.[intAccountId]
			,[dblDebit]		= CASE	WHEN [dblDebit] < 0 THEN ABS([dblDebit])
									WHEN [dblCredit] < 0 THEN 0
									ELSE [dblCredit] END 
			,[dblCredit]	= CASE	WHEN [dblCredit] < 0 THEN ABS([dblCredit])
									WHEN [dblDebit] < 0 THEN 0
									ELSE [dblDebit] END									
			,[dblDebitUnit]		= CASE	WHEN [dblDebitUnit] < 0 THEN ABS([dblDebitUnit])
									WHEN [dblCreditUnit] < 0 THEN 0
									ELSE [dblCreditUnit] END
			,[dblCreditUnit]	= CASE	WHEN [dblCreditUnit] < 0 THEN ABS([dblCreditUnit])
									WHEN [dblDebitUnit] < 0 THEN 0
									ELSE [dblDebitUnit] END	
	FROM [dbo].tblGLDetail A WHERE A.[strTransactionId] = @strTransactionId AND ysnIsUnposted = 0 AND strCode = ISNULL(@strCode, strCode)
)
UPDATE	tblGLSummary 
SET		 [dblDebit] = ISNULL(tblGLSummary.[dblDebit], 0) - ISNULL(GLDetailGrouped.[dblDebit], 0)
		,[dblCredit] = ISNULL(tblGLSummary.[dblCredit], 0) - ISNULL(GLDetailGrouped.[dblCredit], 0)
		,[dblDebitUnit] = ISNULL(tblGLSummary.[dblDebitUnit], 0) - ISNULL(GLDetailGrouped.[dblDebitUnit], 0)
		,[dblCreditUnit] = ISNULL(tblGLSummary.[dblCreditUnit], 0) - ISNULL(GLDetailGrouped.[dblCreditUnit], 0)
		,[intConcurrencyId] = ISNULL([intConcurrencyId], 0) + 1
FROM	(
			SELECT	 [dblDebit]			= SUM(ISNULL(B.[dblCredit], 0))
					,[dblCredit]		= SUM(ISNULL(B.[dblDebit], 0))
					,[dblDebitUnit]		= SUM(ISNULL(B.[dblCreditUnit], 0))
					,[dblCreditUnit]	= SUM(ISNULL(B.[dblDebitUnit], 0))
					,[intAccountId]		= A.[intAccountId]
					,[dtmDate]			= ISNULL(CONVERT(DATE, A.[dtmDate]), '') 								
			FROM tblGLSummary A 
					INNER JOIN GLDetail B 
					ON CONVERT(DATE, A.[dtmDate]) = CONVERT(DATE, B.[dtmDate]) AND A.[intAccountId] = B.[intAccountId] AND A.[strCode] = ISNULL(@strCode, '')
			GROUP BY ISNULL(CONVERT(DATE, A.[dtmDate]), ''), A.[intAccountId]
		) AS GLDetailGrouped
WHERE tblGLSummary.[intAccountId] = GLDetailGrouped.[intAccountId] AND tblGLSummary.[strCode] = ISNULL(@strCode, '') AND
	  ISNULL(CONVERT(DATE, tblGLSummary.[dtmDate]), '') = ISNULL(CONVERT(DATE, GLDetailGrouped.[dtmDate]), '');

IF @@ERROR <> 0	GOTO Post_Rollback;

--=====================================================================================================================================
-- 	UPDATE THE Is Unposted Flag IN THE tblGLDetail TABLE. 
---------------------------------------------------------------------------------------------------------------------------------------
UPDATE	tblGLDetail
SET		ysnIsUnposted = 1
WHERE	strTransactionId = @strTransactionId

IF @@ERROR <> 0	GOTO Post_Rollback;

--=====================================================================================================================================
-- 	RETURN TOTAL NUMBER OF VALID GL ENTRIES
---------------------------------------------------------------------------------------------------------------------------------------
SET @successfulCount = (SELECT COUNT(*) FROM tblGLDetail WHERE strTransactionId = @strTransactionId)

IF @@ERROR <> 0	GOTO Post_Rollback;

--=====================================================================================================================================
-- 	FINALIZING STAGE
---------------------------------------------------------------------------------------------------------------------------------------
Post_Commit:
	COMMIT TRANSACTION
	GOTO Post_Exit

Post_Rollback:
	ROLLBACK TRANSACTION		            
	GOTO Post_Exit

Post_Exit:
	
GO


----=====================================================================================================================================
---- 	SCRIPT EXECUTION 
-----------------------------------------------------------------------------------------------------------------------------------------
--DECLARE @intCount AS INT

--EXEC [dbo].[usp_ReverseGLEntries]
--	@strBatchId		= 'BATCH-13131'
--	,@strTransactionId	= 'GJ-29'
--	,@ysnRecap					= 0
--	,@strCode			= 'GJ'
--	,@dtmDateReverse	= NULL 
--	,@intEntityId			= 1
--	,@successfulCount	= @intCount OUTPUT			
				
--SELECT @intCount
