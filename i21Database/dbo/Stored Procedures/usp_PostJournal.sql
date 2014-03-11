
--=====================================================================================================================================
-- 	CREATE THE STORED PROCEDURE AFTER DELETING IT
---------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE usp_PostJournal
	@Param				AS NVARCHAR(MAX)	= '',	
	@ysnPost			AS BIT				= 0,
	@ysnRecap			AS BIT				= 0,
	@strBatchID			AS NVARCHAR(100)	= '',	
	@strJournalType		AS NVARCHAR(30)		= '',
	@intUserID			AS INT				= 1,
	@successfulCount	AS INT				= 0 OUTPUT
	
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN TRANSACTION;

--=====================================================================================================================================
-- 	DECLARE TEMPORARY TABLES
---------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE #tmpPostJournals (
	[intJournalID] [int] PRIMARY KEY,
	UNIQUE (intJournalID)
);

CREATE TABLE #tmpValidJournals (
	[intJournalID] [int] PRIMARY KEY,
	UNIQUE (intJournalID)
);

CREATE TABLE #tmpReverseJournals (
	[intJournalID] [int] PRIMARY KEY,
	UNIQUE (intJournalID)
);


--=====================================================================================================================================
-- 	POPULATE JOURNALS TO POST TEMPORARY TABLE
---------------------------------------------------------------------------------------------------------------------------------------
IF (ISNULL(@Param, '') <> '') 
	INSERT INTO #tmpPostJournals EXEC (@Param)
ELSE
	INSERT INTO #tmpPostJournals SELECT [intJournalID] FROM tblGLJournal	
	
	
--=====================================================================================================================================
-- 	UNPOSTING JOURNAL TRANSACTIONS
---------------------------------------------------------------------------------------------------------------------------------------
IF ISNULL(@ysnPost, 0) = 0
	BEGIN
		DECLARE @intCount AS INT
		
		IF ISNULL(@ysnRecap, 0) = 0
			BEGIN
				-- DELETE Results 1 DAY OLDER	
				DELETE tblGLPostResults WHERE dtmDate < DATEADD(day, -1, GETDATE())
				
				INSERT INTO tblGLPostResults (strBatchID,intTransactionID,strTransactionID,strDescription,dtmDate)
					SELECT @strBatchID as strBatchID
							,(SELECT TOP 1 intJournalID FROM #tmpPostJournals) as intTransactionID
							,(SELECT TOP 1 strJournalID FROM tblGLJournal WHERE intJournalID IN (SELECT intJournalID FROM #tmpPostJournals)) as strTransactionID
							,strMessage as strDescription
							,GETDATE() as dtmDate
					FROM (
						SELECT DISTINCT A.intJournalID,
							'You cannot Unpost this General Journal. You must Unpost and Delete the Reversing transaction: ' + A.strJournalID + ' first!' AS strMessage
						FROM tblGLJournal A 
						WHERE A.strReverseLink IN (SELECT strJournalID FROM tblGLJournal WHERE intJournalID IN (SELECT intJournalID FROM #tmpPostJournals))
					) tmpBatchResults
			END

		IF @@ERROR <> 0	GOTO Post_Rollback;
		
		IF (NOT EXISTS(SELECT TOP 1 1 FROM tblGLJournal A WHERE A.strReverseLink IN (SELECT strJournalID FROM tblGLJournal WHERE intJournalID IN (SELECT intJournalID FROM #tmpPostJournals))) OR ISNULL(@ysnRecap, 0) = 1)
			BEGIN
				SET @Param = (SELECT strJournalID FROM tblGLJournal WHERE intJournalID IN (SELECT intJournalID FROM #tmpPostJournals))
				EXEC [dbo].[usp_ReverseGLEntries] @strBatchID, @Param, @ysnRecap, 'GJ', NULL, @intUserID, @intCount	OUT
				SET @successfulCount = @intCount
				
				IF(@intCount > 0)
				BEGIN
					UPDATE tblGLJournal SET ysnPosted = 0 WHERE intJournalID IN (SELECT intJournalID FROM #tmpPostJournals)
				END									
			END
		
		GOTO Post_Commit;
	END


--=====================================================================================================================================
--	JOURNAL VALIDATIONS
---------------------------------------------------------------------------------------------------------------------------------------
IF ISNULL(@ysnRecap, 0) = 0
	BEGIN
		-- DELETE Results 2 DAYS OLDER	
		DELETE tblGLPostResults WHERE dtmDate < DATEADD(day, -1, GETDATE())
		
		INSERT INTO tblGLPostResults (strBatchID,intTransactionID,strTransactionID,strDescription,dtmDate)
			SELECT @strBatchID as strBatchID,tmpBatchResults.intJournalID as intTransactionID,tblB.strJournalID as strTransactionID, strMessage as strDescription,GETDATE() as dtmDate
			FROM (
				SELECT DISTINCT A.intJournalID,
					'Unable to find an open accounting period to match the transaction date.' AS strMessage
				FROM tblGLJournal A 
				WHERE A.intJournalID IN (SELECT intJournalID FROM #tmpPostJournals) AND ISNULL([dbo].isOpenAccountingDate(A.dtmDate), 0) = 0  
				UNION
				SELECT DISTINCT A.intJournalID,
					'Unable to find an open accounting period to match the reverse date.' AS strMessage
				FROM tblGLJournal A 
				WHERE 0 = CASE WHEN ISNULL(A.dtmReverseDate, '') = '' THEN 1 ELSE ISNULL([dbo].isOpenAccountingDate(A.dtmReverseDate), 0) END 
					  AND A.intJournalID IN (SELECT intJournalID FROM #tmpPostJournals)
				UNION
				SELECT DISTINCT A.intJournalID,
					'This transaction cannot be posted because the posting date is empty.' AS strMessage
				FROM tblGLJournal A 
				WHERE 0 = CASE WHEN ISNULL(A.dtmDate, '') = '' THEN 0 ELSE 1 END 
					  AND A.intJournalID IN (SELECT intJournalID FROM #tmpPostJournals)
				UNION
				SELECT DISTINCT A.intJournalID,
					'Reverse date must be later than Post Date.' AS strMessage
				FROM tblGLJournal A 
				WHERE 0 = CASE WHEN ISNULL(A.dtmReverseDate, '') = '' THEN 1 ELSE 
							CASE WHEN A.dtmReverseDate <= A.dtmDate THEN 0 ELSE 1 END
						END AND A.intJournalID IN (SELECT intJournalID FROM #tmpPostJournals)
				UNION
				SELECT DISTINCT A.intJournalID,
					'You cannot post this transaction because it has inactive account id ' + B.strAccountID + '.' AS strMessage
				FROM tblGLJournalDetail A 
					LEFT OUTER JOIN tblGLAccount B ON A.intAccountID = B.intAccountID
				WHERE ISNULL(B.ysnActive, 0) = 0 AND A.intJournalID IN (SELECT intJournalID FROM #tmpPostJournals)
				UNION
				SELECT DISTINCT A.intJournalID,
					'You cannot post this transaction because it has invalid account(s).' AS strMessage
				FROM tblGLJournalDetail A 
					LEFT OUTER JOIN tblGLAccount B ON A.intAccountID = B.intAccountID
				WHERE A.intAccountID IS NULL OR 0 = CASE WHEN ISNULL(A.intAccountID, '') = '' THEN 0 ELSE 1 END AND A.intJournalID IN (SELECT intJournalID FROM #tmpPostJournals)					
				UNION 
				SELECT DISTINCT A.intJournalID,
					'Unable to post. The transaction is out of balance.' AS strMessage
				FROM tblGLJournalDetail A 
				WHERE A.intJournalID IN (SELECT intJournalID FROM #tmpPostJournals)	
				GROUP BY A.intJournalID		
				HAVING SUM(ISNULL(A.dblCredit,0)) <> SUM(ISNULL(A.dblDebit,0)) 
				--UNION 
				--SELECT DISTINCT B.intJournalID,
				--	'You cannot post this transaction because Accounting Unit setup does not match account id ' + C.strAccountID + ' setup.' AS strMessage
				--FROM tblGLJournalDetail B 
				--	LEFT OUTER JOIN tblGLAccount C ON B.intAccountID = C.intAccountID
				--WHERE (ISNULL(B.dblCreditUnit, 0) > 0 OR ISNULL(B.dblDebitUnit, 0) > 0) AND ISNULL(C.intAccountUnitID, 0) = 0 
				--	AND B.intJournalID IN (SELECT intJournalID FROM #tmpPostJournals)
				--	GROUP BY B.intJournalID, C.intAccountID, C.strAccountID
			) tmpBatchResults
		LEFT JOIN tblGLJournal tblB ON tmpBatchResults.intJournalID = tblB.intJournalID
	END

IF @@ERROR <> 0	GOTO Post_Rollback;
	
	
--=====================================================================================================================================
-- 	POPULATE VALID JOURNALS TEMPORARY TABLE
---------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO #tmpValidJournals
	SELECT DISTINCT A.[intJournalID]
	FROM tblGLJournal A 
	WHERE	A.[intJournalID] IN (SELECT B.intJournalID FROM #tmpPostJournals  B
						WHERE B.intJournalID NOT IN (SELECT intTransactionID FROM tblGLPostResults WHERE strBatchID = @strBatchID GROUP BY intTransactionID)) 
		AND
		A.[ysnPosted] = 0 AND
		A.[strJournalType] = @strJournalType

IF @@ERROR <> 0	GOTO Post_Rollback;

IF NOT EXISTS(SELECT TOP 1 1 FROM #tmpValidJournals)
	BEGIN
		GOTO Post_Commit;
	END


--=====================================================================================================================================
-- 	CHECK IF THE PROCESS IS RECAP OR NOT
---------------------------------------------------------------------------------------------------------------------------------------
Post_Transaction:

IF ISNULL(@ysnRecap, 0) = 0
	BEGIN							
	
		DECLARE @intCurrencyID	INT
		DECLARE @dblDailyRate	NUMERIC (18,6)
		
		SET @intCurrencyID		= (SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE intCurrencyID = (CASE WHEN (SELECT TOP 1 strValue FROM tblSMPreferences WHERE strPreference = 'defaultCurrency') > 0 
																		THEN (SELECT TOP 1 strValue FROM tblSMPreferences WHERE strPreference = 'defaultCurrency')
																		ELSE (SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE strCurrency = 'USD') END))
		SET @dblDailyRate		= (SELECT TOP 1 dblDailyRate FROM tblSMCurrency WHERE intCurrencyID = @intCurrencyID);

	
		WITH Units 
		AS 
		(
			SELECT	A.[dblLbsPerUnit], B.[intAccountID] 
			FROM tblGLAccountUnit A INNER JOIN tblGLAccount B ON A.[intAccountUnitID] = B.[intAccountUnitID]
		)
		INSERT INTO tblGLDetail (
			 [strTransactionID]
			,[intAccountID]
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
			,[intCurrencyID]
			,[dblExchangeRate]
			,[intUserID]
			,[dtmDateEntered]
			,[strBatchID]
			,[strCode]
			,[strModuleName]
			,[strTransactionForm]
			,[strJournalLineDescription]
			,[intJournalLineNo]
		)
		SELECT 
			 [strTransactionID]		= B.[strJournalID]
			,[intAccountID]			= A.[intAccountID]
			,[strDescription]		= A.[strDescription]
			,[strReference]			= A.[strReference]
			,[dtmTransactionDate]	= A.[dtmDate]
			,[dblDebit]				= CASE	WHEN [dblCredit] < 0 THEN ABS([dblCredit])
											WHEN [dblDebit] < 0 THEN 0
											ELSE [dblDebit] END 
			,[dblCredit]			= CASE	WHEN [dblDebit] < 0 THEN ABS([dblDebit])
											WHEN [dblCredit] < 0 THEN 0
											ELSE [dblCredit] END	
			,[dblDebitUnit]			= ISNULL(A.[dblDebitUnit], 0)  * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountID] = A.[intAccountID]), 0)
			,[dblCreditUnit]		= ISNULL(A.[dblCreditUnit], 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountID] = A.[intAccountID]), 0)
			,[dtmDate]				= ISNULL(B.[dtmDate], GETDATE())
			,[ysnIsUnposted]		= 0 
			,[intConcurrencyId]		= 1
			,[intCurrencyID]		= @intCurrencyID
			,[dblExchangeRate]		= @dblDailyRate
			,[intUserID]			= @intUserID
			,[dtmDateEntered]		= GETDATE()
			,[strBatchID]			= @strBatchID
			,[strCode]				= B.[strSourceType]
			,[strModuleName]		= 'General Ledger'
			,[strTransactionForm]	= B.[strTransactionType]
			,[strJournalLineDescription] = A.[strDescription]
			,[intJournalLineNo]		= A.intLineNo

		FROM [dbo].tblGLJournalDetail A INNER JOIN [dbo].tblGLJournal B 
			ON A.[intJournalID] = B.[intJournalID]
		WHERE B.[intJournalID] IN (SELECT [intJournalID] FROM #tmpValidJournals)

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
			,[intTransactionID]
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
			,[strTransactionForm]
		)
		SELECT 
			 [strTransactionID]		= B.[strJournalID]
			,[intTransactionID]		= B.[intJournalID]
			,[intAccountID]			= A.[intAccountID]
			,[strAccountID]			= (SELECT [strAccountID] FROM Accounts WHERE [intAccountID] = A.[intAccountID])
			,[strAccountGroup]		= (SELECT [strAccountGroup] FROM Accounts WHERE [intAccountID] = A.[intAccountID])
			,[strDescription]		= A.[strDescription]
			,[strReference]			= A.[strReference]
			,[dtmTransactionDate]	= A.[dtmDate]
			,[dblDebit]				= CASE	WHEN [dblCredit] < 0 THEN ABS([dblCredit])
											WHEN [dblDebit] < 0 THEN 0
											ELSE [dblDebit] END 
			,[dblCredit]			= CASE	WHEN [dblDebit] < 0 THEN ABS([dblDebit])
											WHEN [dblCredit] < 0 THEN 0
											ELSE [dblCredit] END	
			,[dblDebitUnit]			= ISNULL(A.[dblDebitUnit], 0)  * ISNULL((SELECT [dblLbsPerUnit] FROM Accounts WHERE [intAccountID] = A.[intAccountID]), 0)
			,[dblCreditUnit]		= ISNULL(A.[dblCreditUnit], 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Accounts WHERE [intAccountID] = A.[intAccountID]), 0)
			,[dtmDate]				= ISNULL(B.[dtmDate], GETDATE())
			,[ysnIsUnposted]		= 0 
			,[intConcurrencyId]		= 1
			,[dblExchangeRate]		= 1
			,[intUserID]			= @intUserID
			,[dtmDateEntered]		= GETDATE()
			,[strBatchID]			= @strBatchID
			,[strCode]				= B.[strSourceType]
			,[strModuleName]		= 'General Ledger'
			,[strTransactionForm]	= B.[strTransactionType]
		FROM [dbo].tblGLJournalDetail A INNER JOIN [dbo].tblGLJournal B 
			ON A.[intJournalID] = B.[intJournalID]
		WHERE B.[intJournalID] IN (SELECT [intJournalID] FROM #tmpValidJournals)

		--SUMMARY GROUP
		INSERT INTO tblGLPostRecap (
			 [strTransactionID]
			,[intTransactionID]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[dtmDate]
			,[dblExchangeRate]
			,[dtmDateEntered]
			,[ysnIsUnposted]
			,[intUserID]
			,[strBatchID]
			,[strCode]
			,[strModuleName]
			,[strTransactionForm]
		)
		SELECT 
			 [strTransactionID]
			,[intTransactionID]		
			,SUM([dblDebit])
			,SUM([dblCredit])
			,SUM([dblDebitUnit])
			,SUM([dblCreditUnit])
			,[dtmDate]
			,[dblExchangeRate]
			,[dtmDateEntered]
			,[ysnIsUnposted]
			,[intUserID]	
			,[strBatchID]	
			,[strCode]				
			,[strModuleName]
			,[strTransactionForm]
		FROM [dbo].tblGLPostRecap A
		WHERE A.[strBatchID] = @strBatchID and A.[intUserID] = @intUserID
		GROUP BY [strTransactionID],[intTransactionID],[dtmDate],[dblExchangeRate],[dtmDateEntered],[ysnIsUnposted],[intUserID],[strBatchID],[strCode],[strModuleName],[strTransactionForm]

		IF @@ERROR <> 0	GOTO Post_Rollback;

		GOTO Post_Commit;
	END

IF @@ERROR <> 0	GOTO Post_Rollback;


--=====================================================================================================================================
-- 	UPDATE GL SUMMARY RECORDS
---------------------------------------------------------------------------------------------------------------------------------------
WITH Units
AS 
(
	SELECT	A.[dblLbsPerUnit], B.[intAccountID] 
	FROM tblGLAccountUnit A INNER JOIN tblGLAccount B ON A.[intAccountUnitID] = B.[intAccountUnitID]
),
JournalDetail
AS
(
	SELECT   [dtmDate]			= ISNULL(B.[dtmDate], GETDATE())
			,[intAccountID]		= A.[intAccountID]
			,[dblDebit]			= CASE	WHEN [dblCredit] < 0 THEN ABS([dblCredit])
										WHEN [dblDebit] < 0 THEN 0
										ELSE [dblDebit] END 
			,[dblCredit]		= CASE	WHEN [dblDebit] < 0 THEN ABS([dblDebit])
										WHEN [dblCredit] < 0 THEN 0
										ELSE [dblCredit] END	
			,[dblDebitUnit]		= ISNULL([dblDebitUnit], 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountID] = A.[intAccountID]), 0)
			,[dblCreditUnit]	= ISNULL([dblCreditUnit], 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountID] = A.[intAccountID]), 0)
	FROM [dbo].tblGLJournalDetail A INNER JOIN [dbo].tblGLJournal B ON A.[intJournalID] = B.[intJournalID]
	WHERE B.[intJournalID] IN (SELECT [intJournalID] FROM #tmpValidJournals)
)
UPDATE	tblGLSummary 
SET		 [dblDebit]			= ISNULL(tblGLSummary.[dblDebit], 0) + ISNULL(GLDetailGrouped.[dblDebit], 0)
		,[dblCredit]		= ISNULL(tblGLSummary.[dblCredit], 0) + ISNULL(GLDetailGrouped.[dblCredit], 0)
		,[dblDebitUnit]		= ISNULL(tblGLSummary.[dblDebitUnit], 0) + ISNULL(GLDetailGrouped.[dblDebitUnit], 0)
		,[dblCreditUnit]	= ISNULL(tblGLSummary.[dblCreditUnit], 0) + ISNULL(GLDetailGrouped.[dblCreditUnit], 0)
		,[intConcurrencyId] = ISNULL([intConcurrencyId], 0) + 1
FROM	(
			SELECT	 [dblDebit]			= SUM(ISNULL(B.[dblDebit], 0))
					,[dblCredit]		= SUM(ISNULL(B.[dblCredit], 0))
					,[dblDebitUnit]		= SUM(ISNULL(B.[dblDebitUnit], 0))
					,[dblCreditUnit]	= SUM(ISNULL(B.[dblCreditUnit], 0))
					,[intAccountID]		= A.[intAccountID]
					,[dtmDate]			= ISNULL(CONVERT(DATE, A.[dtmDate]), '') 								
			FROM tblGLSummary A 
					INNER JOIN JournalDetail B 
					ON CONVERT(DATE, A.[dtmDate]) = CONVERT(DATE, B.[dtmDate]) AND A.[intAccountID] = B.[intAccountID] AND A.[strCode] = 'GJ'			
			GROUP BY ISNULL(CONVERT(DATE, A.[dtmDate]), ''), A.[intAccountID]
		) AS GLDetailGrouped
WHERE tblGLSummary.[intAccountID] = GLDetailGrouped.[intAccountID] AND tblGLSummary.[strCode] = 'GJ' AND
	  ISNULL(CONVERT(DATE, tblGLSummary.[dtmDate]), '') = ISNULL(CONVERT(DATE, GLDetailGrouped.[dtmDate]), '');

IF @@ERROR <> 0	GOTO Post_Rollback;


--=====================================================================================================================================
-- 	INSERT TO GL SUMMARY RECORDS
---------------------------------------------------------------------------------------------------------------------------------------
WITH Units
AS 
(
	SELECT	A.[dblLbsPerUnit], B.[intAccountID] 
	FROM tblGLAccountUnit A INNER JOIN tblGLAccount B ON A.[intAccountUnitID] = B.[intAccountUnitID]
),
JournalDetail 
AS
(
	SELECT [dtmDate]		= ISNULL(B.[dtmDate], GETDATE())
		,[intAccountID]		= A.[intAccountID]
		,[dblDebit]			= CASE	WHEN [dblCredit] < 0 THEN ABS([dblCredit])
									WHEN [dblDebit] < 0 THEN 0
									ELSE [dblDebit] END 
		,[dblCredit]		= CASE	WHEN [dblDebit] < 0 THEN ABS([dblDebit])
									WHEN [dblCredit] < 0 THEN 0
									ELSE [dblCredit] END	
		,[dblDebitUnit]		= ISNULL(A.[dblDebitUnit], 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountID] = A.[intAccountID]), 0)
		,[dblCreditUnit]	= ISNULL(A.[dblCreditUnit], 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountID] = A.[intAccountID]), 0)
	FROM [dbo].tblGLJournalDetail A INNER JOIN [dbo].tblGLJournal B ON A.[intJournalID] = B.[intJournalID]
	WHERE B.intJournalID IN (SELECT [intJournalID] FROM #tmpValidJournals)
)
INSERT INTO tblGLSummary (
	 [intAccountID]
	,[dtmDate]
	,[dblDebit]
	,[dblCredit]
	,[dblDebitUnit]
	,[dblCreditUnit]
	,[strCode]
	,[intConcurrencyId]
)
SELECT	
	 [intAccountID]		= A.[intAccountID]
	,[dtmDate]			= ISNULL(CONVERT(DATE, A.[dtmDate]), '')
	,[dblDebit]			= SUM(A.[dblDebit])
	,[dblCredit]		= SUM(A.[dblCredit])
	,[dblDebitUnit]		= SUM(A.[dblDebitUnit])
	,[dblCreditUnit]	= SUM(A.[dblCreditUnit])
	,[strCode] = 'GJ'
	,[intConcurrencyId] = 1
FROM JournalDetail A
WHERE NOT EXISTS 
		(
			SELECT TOP 1 1
			FROM tblGLSummary B
			WHERE ISNULL(CONVERT(DATE, A.[dtmDate]), '') = ISNULL(CONVERT(DATE, B.[dtmDate]), '') AND 
				  A.[intAccountID] = B.[intAccountID] AND B.[strCode] = 'GJ'
		)
GROUP BY ISNULL(CONVERT(DATE, A.[dtmDate]), ''), A.[intAccountID];

IF @@ERROR <> 0	GOTO Post_Rollback;


--=====================================================================================================================================
-- 	UPDATE JOURNAL TABLE
---------------------------------------------------------------------------------------------------------------------------------------
UPDATE tblGLJournal
SET [ysnPosted] = 1
	,[dtmPosted] = GETDATE()
WHERE [intJournalID] IN (SELECT [intJournalID] FROM #tmpValidJournals);

IF @@ERROR <> 0	GOTO Post_Rollback;


--=====================================================================================================================================
-- 	UPDATE RESULT
---------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO tblGLPostResults (strBatchID,intTransactionID,strTransactionID,strDescription,dtmDate)
	SELECT @strBatchID as strBatchID,intJournalID as intTransactionID,strJournalID as strTransactionID, strMessage as strDescription,GETDATE() as dtmDate
	FROM (
		SELECT DISTINCT A.intJournalID,A.strJournalID,
			'Transaction successfully posted.' AS strMessage
		FROM tblGLJournal A 
		WHERE A.intJournalID IN (SELECT intJournalID FROM #tmpValidJournals)
	) B

IF @@ERROR <> 0	GOTO Post_Rollback;


--=====================================================================================================================================
-- 	RETURN TOTAL NUMBER OF VALID JOURNALS
---------------------------------------------------------------------------------------------------------------------------------------
SET @successfulCount = ISNULL(@successfulCount,0) + (SELECT COUNT(*) FROM #tmpValidJournals)


--=====================================================================================================================================
-- 	REVERSE JOURNAL
---------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO #tmpReverseJournals (intJournalID)
SELECT A.intJournalID FROM #tmpValidJournals A
	INNER JOIN tblGLJournal B ON A.intJournalID = B.intJournalID	
	WHERE B.dtmReverseDate IS NOT NULL

IF EXISTS (SELECT 1 FROM #tmpReverseJournals)
BEGIN
	DELETE #tmpValidJournals

	WHILE EXISTS(SELECT 1 FROM #tmpReverseJournals)
	BEGIN
		DECLARE @intJournalID INT = (SELECT TOP 1 intJournalID FROM #tmpReverseJournals)
		DECLARE @strJournalID NVARCHAR(100) = ''
		
		EXEC [dbo].uspSMGetStartingNumber 5, @strJournalID OUTPUT 		
		
		INSERT INTO tblGLJournal (
				 [dtmReverseDate]
				,[strJournalID]
				,[strTransactionType]
				,[dtmDate]
				,[strReverseLink]
				,[intCurrencyID]
				,[dblExchangeRate]
				,[dtmPosted]
				,[strDescription]
				,[ysnPosted]
				,[intConcurrencyId]
				,[dtmJournalDate]
				,[intUserID]
				,[strSourceID]
				,[strJournalType]
				,[strRecurringStatus]
				,[strSourceType]
				)
			SELECT 
				 NULL
				,@strJournalID
				,[strTransactionType]
				,[dtmReverseDate]
				,A.strJournalID
				,[intCurrencyID]
				,[dblExchangeRate]
				,0
				,'Reversing transaction for ' + A.strJournalID
				,[ysnPosted]
				,[intConcurrencyId]
				,[dtmJournalDate]
				,[intUserID]
				,[strSourceID]
				,'Reversal Journal'
				,NULL
				,[strSourceType]
			FROM [dbo].tblGLJournal A
			WHERE A.intJournalID = @intJournalID
			
			DECLARE @intJournalID_NEW INT = (SELECT TOP 1 intJournalID FROM tblGLJournal WHERE strJournalID = @strJournalID)
			INSERT INTO #tmpValidJournals (intJournalID) SELECT @intJournalID_NEW
		 
		 INSERT INTO tblGLJournalDetail (
				 [intLineNo]
				,[intJournalID]
				,[dtmDate]
				,[intAccountID]
				,[dblDebit]
				,[dblDebitRate]
				,[dblCredit]
				,[dblCreditRate]
				,[dblDebitUnit]
				,[dblCreditUnit]
				,[strDescription]
				,[intConcurrencyId]
				,[dblUnitsInLBS]
				,[strDocument]
				,[strComments]
				,[strReference]
				,[dblDebitUnitsInLBS]
				,[strCorrecting]
				,[strSourcePgm]
				,[strCheckBookNo]
				,[strWorkArea]
				)
			SELECT 
				 [intLineNo]
				,@intJournalID_NEW
				,[dtmDate]
				,[intAccountID]			
				,[dblCredit]
				,[dblCreditRate]
				,[dblDebit]
				,[dblDebitRate]			
				,[dblCreditUnit]
				,[dblDebitUnit]
				,[strDescription]
				,[intConcurrencyId]
				,[dblUnitsInLBS]
				,[strDocument]
				,[strComments]
				,[strReference]
				,[dblDebitUnitsInLBS]
				,[strCorrecting]
				,[strSourcePgm]
				,[strCheckBookNo]
				,[strWorkArea]
			FROM [dbo].tblGLJournalDetail A
			WHERE A.intJournalID = @intJournalID
							
		DELETE #tmpReverseJournals WHERE intJournalID = @intJournalID
	END 	
	
	GOTO Post_Transaction;
	
END

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
	IF EXISTS (SELECT 1 FROM TEMPDB..SYSOBJECTS WHERE ID = OBJECT_ID('TEMPDB..#tmpPostJournals')) DROP TABLE #tmpPostJournals
	IF EXISTS (SELECT 1 FROM TEMPDB..SYSOBJECTS WHERE ID = OBJECT_ID('TEMPDB..#tmpValidJournals')) DROP TABLE #tmpValidJournals
	IF EXISTS (SELECT 1 FROM TEMPDB..SYSOBJECTS WHERE ID = OBJECT_ID('TEMPDB..#tmpReverseJournals')) DROP TABLE #tmpReverseJournals		
GO


--=====================================================================================================================================
-- 	SCRIPT EXECUTION 
---------------------------------------------------------------------------------------------------------------------------------------
--DECLARE @intCount AS INT

--EXEC [dbo].[usp_PostJournal]
--			@Param	 = 'select intJournalID from tblGLJournal where strJournalID = ''GJ-20''',				-- GENERATED BATCH ID
--			@ysnPost = 1,
--			@ysnRecap = 0,								-- WHEN SET TO 1, THEN IT WILL POPULATE tblGLPostRecap THAT CAN BE VIEWED VIA BUFFERED STORE IN SENCHA
--			@strBatchID = 'BATCH-11231',							-- COMMA DELIMITED JOURNAL ID TO POST 
--			@strJournalType = 'General Journal',
--			@intUserID = 1,							-- USER ID THAT INITIATES POSTING
--			@successfulCount = @intCount OUTPUT		-- OUTPUT PARAMETER THAT RETURNS TOTAL NUMBER OF SUCCESSFUL RECORDS
				
--SELECT @intCount
