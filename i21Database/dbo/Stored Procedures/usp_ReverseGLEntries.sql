
--=====================================================================================================================================
-- 	CREATE THE STORED PROCEDURE AFTER DELETING IT
---------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE usp_ReverseGLEntries
	 @strBatchID		AS NVARCHAR(50)	= ''
	,@strTransactionID	NVARCHAR(40)	= NULL
	,@Recap				AS BIT			= 0
	,@strCode			NVARCHAR(10)	= NULL
	,@dtmDateReverse	DATETIME		= NULL 
	,@intUserID			INT				= NULL 
	,@successfulID		AS NVARCHAR(50)	= '' OUTPUT
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
IF ISNULL(@Recap, 0) = 0
BEGIN
	SELECT	@strBatchID = MAX(strBatchID)
	FROM	tblGLDetail
	WHERE	strTransactionID = @strTransactionID
			AND ysnIsUnposted = 0
			AND strCode = ISNULL(@strCode, strCode)
END			

--=====================================================================================================================================
-- 	REVERSE THE G/L ENTRIES
---------------------------------------------------------------------------------------------------------------------------------------
IF ISNULL(@Recap, 0) = 0
	BEGIN			
		INSERT INTO tblGLDetail (
				[strTransactionID]
				,[dtmDate]
				,[strBatchID]
				,[intAccountID]
				,[strAccountGroup]
				,[dblDebit]
				,[dblCredit]
				,[dblDebitUnit]
				,[dblCreditUnit]
				,[strDescription]
				,[strCode]
				,[strReference]
				,[strJobID]
				,[intCurrencyID]
				,[dblExchangeRate]
				,[dtmDateEntered]
				,[dtmTransactionDate]
				,[strProductID]
				,[strWarehouseID]
				,[strNum]
				,[strCompanyName]
				,[strBillInvoiceNumber]
				,[strJournalLineDescription]
				,[ysnIsUnposted]
				,[intConcurrencyId]
				,[intUserID]
				,[strTransactionForm]
				,[strModuleName]
				,[strUOMCode]
		)
		SELECT	[strTransactionID]
				,dtmDate			= ISNULL(@dtmDateReverse, [dtmDate]) -- If date is provided, use date reverse as the date for unposting the transaction.
				,[strBatchID]
				,[intAccountID]
				,[strAccountGroup]
				,dblDebit			= [dblCredit]		-- (Debit -> Credit)
				,dblCredit			= [dblDebit]		-- (Debit <- Credit)
				,dblDebitUnit		= [dblCreditUnit]	-- (Debit Unit -> Credit Unit)
				,dblCreditUnit		= [dblDebitUnit]	-- (Debit Unit <- Credit Unit)
				,[strDescription]
				,[strCode]
				,[strReference]
				,[strJobID]
				,[intCurrencyID]
				,[dblExchangeRate]
				,dtmDateEntered		= GETDATE()
				,[dtmTransactionDate]
				,[strProductID]
				,[strWarehouseID]
				,[strNum]
				,[strCompanyName]
				,[strBillInvoiceNumber]
				,[strJournalLineDescription]
				,ysnIsUnposted		= 1
				,[intConcurrencyId]
				,[intUserID]		= @intUserID
				,[strTransactionForm]
				,[strModuleName]
				,[strUOMCode]
		FROM	tblGLDetail 
		WHERE	strBatchID = @strBatchID
		ORDER BY intGLDetailID		

		IF @@ERROR <> 0	GOTO Post_Rollback;
	END
ELSE
	BEGIN
		-- DELETE Results 1 DAYS OLDER	
		DELETE tblGLPostRecap WHERE dtmDateEntered < DATEADD(day, -1, GETDATE()) and intUserID = @intUserID;
		
		WITH Accounts 
		AS 
		(
			SELECT A.[strAccountID], A.[intAccountID], A.[intAccountGroupID], B.[strAccountGroup], C.[dblLbsPerUnit]
			FROM tblGLAccount A LEFT JOIN tblGLAccountGroup B on A.intAccountGroupID = B.intAccountGroupID
								LEFT JOIN tblGLAccountUnit  C on C.intAccountUnitID  = A.intAccountUnitID
		)
		INSERT INTO tblGLPostRecap (
			 [strTransactionID]
			,[intAccountID]
			,[strAccountID]
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
			,[intUserID]
			,[dtmDateEntered]
			,[strBatchID]
			,[strCode]
			,[strModuleName]
		)
		SELECT 
			 [strTransactionID]
			,[intAccountID]			
			,[strAccountID]			= (SELECT [strAccountID] FROM Accounts WHERE [intAccountID] = A.[intAccountID])
			,[strAccountGroup]		= (SELECT [strAccountGroup] FROM Accounts WHERE [intAccountID] = A.[intAccountID])
			,[strDescription]		
			,[strReference]			
			,[dtmTransactionDate]	
			,[dblDebit]				= [dblCredit]
			,[dblCredit]			= [dblDebit]	
			,[dblDebitUnit]			= [dblDebitUnit]
			,[dblCreditUnit]		= [dblCreditUnit]
			,[dtmDate]				
			,[ysnIsUnposted]		
			,[intConcurrencyId]		
			,[dblExchangeRate]		
			,[intUserID]			= @intUserID
			,[dtmDateEntered]		= GETDATE()
			,[strBatchID]			= @strBatchID
			,[strCode]
			,[strModuleName]
		FROM	tblGLDetail A
		WHERE	strTransactionID = @strTransactionID and ysnIsUnposted = 0
		ORDER BY intGLDetailID
				
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
			,[intAccountID]	= A.[intAccountID]
			,[dblDebit]		= CASE	WHEN [dblCredit] < 0 THEN ABS([dblCredit])
									WHEN [dblDebit] < 0 THEN 0
									ELSE [dblDebit] END 
			,[dblCredit]	= CASE	WHEN [dblDebit] < 0 THEN ABS([dblDebit])
									WHEN [dblCredit] < 0 THEN 0
									ELSE [dblCredit] END	
			,[dblDebitUnit]		= CASE	WHEN [dblCreditUnit] < 0 THEN ABS([dblCreditUnit])
									WHEN [dblDebitUnit] < 0 THEN 0
									ELSE [dblDebitUnit] END 
			,[dblCreditUnit]	= CASE	WHEN [dblDebitUnit] < 0 THEN ABS([dblDebitUnit])
									WHEN [dblCreditUnit] < 0 THEN 0
									ELSE [dblCreditUnit] END	
	FROM [dbo].tblGLDetail A WHERE A.[strTransactionID] = @strTransactionID AND ysnIsUnposted = 0 AND strCode = ISNULL(@strCode, strCode)
)
UPDATE	tblGLSummary 
SET		 [dblDebit] = ISNULL(tblGLSummary.[dblDebit], 0) + ISNULL(GLDetailGrouped.[dblDebit], 0)
		,[dblCredit] = ISNULL(tblGLSummary.[dblCredit], 0) + ISNULL(GLDetailGrouped.[dblCredit], 0)
		,[dblDebitUnit] = ISNULL(tblGLSummary.[dblDebitUnit], 0) + ISNULL(GLDetailGrouped.[dblDebitUnit], 0)
		,[dblCreditUnit] = ISNULL(tblGLSummary.[dblCreditUnit], 0) + ISNULL(GLDetailGrouped.[dblCreditUnit], 0)
		,[intConcurrencyId] = ISNULL([intConcurrencyId], 0) + 1
FROM	(
			SELECT	 [dblDebit]			= SUM(ISNULL(B.[dblCredit], 0))
					,[dblCredit]		= SUM(ISNULL(B.[dblDebit], 0))
					,[dblDebitUnit]		= SUM(ISNULL(B.[dblCreditUnit], 0))
					,[dblCreditUnit]	= SUM(ISNULL(B.[dblDebitUnit], 0))
					,[intAccountID]		= A.[intAccountID]
					,[dtmDate]			= ISNULL(CONVERT(DATE, A.[dtmDate]), '') 								
			FROM tblGLSummary A 
					INNER JOIN GLDetail B 
					ON CONVERT(DATE, A.[dtmDate]) = CONVERT(DATE, B.[dtmDate]) AND A.[intAccountID] = B.[intAccountID]			
			GROUP BY ISNULL(CONVERT(DATE, A.[dtmDate]), ''), A.[intAccountID]
		) AS GLDetailGrouped
WHERE tblGLSummary.[intAccountID] = GLDetailGrouped.[intAccountID] AND 
	  ISNULL(CONVERT(DATE, tblGLSummary.[dtmDate]), '') = ISNULL(CONVERT(DATE, GLDetailGrouped.[dtmDate]), '');

IF @@ERROR <> 0	GOTO Post_Rollback;

--=====================================================================================================================================
-- 	UPDATE THE Is Unposted Flag IN THE tblGLDetail TABLE. 
---------------------------------------------------------------------------------------------------------------------------------------
UPDATE	tblGLDetail
SET		ysnIsUnposted = 1
WHERE	strTransactionID = @strTransactionID

IF @@ERROR <> 0	GOTO Post_Rollback;

--=====================================================================================================================================
-- 	UPDATE RESULT
---------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO tblGLPostResults (strBatchID,intTransactionID,strTransactionID,strDescription,dtmDate)
	SELECT @strBatchID as strBatchID,NULL,'' as strTransactionID, 'Transaction successfully unposted.' as strDescription, GETDATE() as dtmDate	

--=====================================================================================================================================
-- 	RETURN TOTAL NUMBER OF VALID JOURNALS
---------------------------------------------------------------------------------------------------------------------------------------
SET @successfulID = @strBatchID

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
--	@strBatchID		= 'BATCH-13131'
--	,@strTransactionID	= 'GJ-29'
--	,@Recap					= 0
--	,@strCode			= 'GJ'
--	,@dtmDateReverse	= NULL 
--	,@intUserID			= 1
--	,@successfulCount	= @intCount OUTPUT			
				
--SELECT @intCount


--DECLARE @intCount AS INT

--EXEC [dbo].[usp_PostJournal]
--			@batchId	 = 'BATCH-321',				-- GENERATED BATCH ID
--			@journalType = 'General Journal',		-- TYPE OF JOURNAL (General Journal, Audit Adjustment and ETC)
--			@recap = 0,								-- WHEN SET TO 1, THEN IT WILL POPULATE tblGLPostRecap THAT CAN BE VIEWED VIA BUFFERED STORE IN SENCHA
--			@param = 'select intJournalID from tblGLJournal where strJournalID = ''GJ-24''',							-- COMMA DELIMITED JOURNAL ID TO POST 
--			@userId = 1,							-- USER ID THAT INITIATES POSTING
--			@successfulCount = @intCount OUTPUT		-- OUTPUT PARAMETER THAT RETURNS TOTAL NUMBER OF SUCCESSFUL RECORDS
				
--SELECT @intCount
