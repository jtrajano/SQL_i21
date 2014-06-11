
--=====================================================================================================================================
-- 	CREATE THE STORED PROCEDURE AFTER DELETING IT
---------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[uspGLPostJournal]
	@Param				AS NVARCHAR(MAX)	= '',	
	@ysnPost			AS BIT				= 0,
	@ysnRecap			AS BIT				= 0,
	@strBatchId			AS NVARCHAR(100)	= '',	
	@strJournalType		AS NVARCHAR(30)		= '',
	@intEntityId		AS INT				= 1,
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
	[intJournalId] [int] PRIMARY KEY,
	UNIQUE (intJournalId)
);

CREATE TABLE #tmpValidJournals (
	[intJournalId] [int] PRIMARY KEY,
	UNIQUE (intJournalId)
);

CREATE TABLE #tmpReverseJournals (
	[intJournalId] [int] PRIMARY KEY,
	UNIQUE (intJournalId)
);


--=====================================================================================================================================
-- 	POPULATE JOURNALS TO POST TEMPORARY TABLE
---------------------------------------------------------------------------------------------------------------------------------------
IF (ISNULL(@Param, '') <> '') 
	INSERT INTO #tmpPostJournals EXEC (@Param)
ELSE
	INSERT INTO #tmpPostJournals SELECT [intJournalId] FROM tblGLJournal	
	
	
--=====================================================================================================================================
-- 	UNPOSTING JOURNAL TRANSACTIONS
---------------------------------------------------------------------------------------------------------------------------------------
IF ISNULL(@ysnPost, 0) = 0
	BEGIN
		DECLARE @intCount AS INT
		
		IF ISNULL(@ysnRecap, 0) = 0
			BEGIN
				-- DELETE Results 1 DAY OLDER	
				DELETE tblGLPostResult WHERE dtmDate < DATEADD(day, -1, GETDATE())
				
				INSERT INTO tblGLPostResult (strBatchId,intTransactionId,strTransactionId,strDescription,dtmDate,intEntityId,strTransactionType)
					SELECT @strBatchId as strBatchId
							,(SELECT TOP 1 intJournalId FROM #tmpPostJournals) as intTransactionId
							,(SELECT TOP 1 strJournalId FROM tblGLJournal WHERE intJournalId IN (SELECT intJournalId FROM #tmpPostJournals)) as strTransactionId
							,strMessage as strDescription
							,GETDATE() as dtmDate
							,@intEntityId
							,@strJournalType
					FROM (
						SELECT DISTINCT A.intJournalId,
							'You cannot Unpost this General Journal. You must Unpost and Delete the Reversing transaction: ' + A.strJournalId + ' first!' AS strMessage
						FROM tblGLJournal A 
						WHERE A.strReverseLink IN (SELECT strJournalId FROM tblGLJournal WHERE intJournalId IN (SELECT intJournalId FROM #tmpPostJournals))
					) tmpBatchResults
			END

		IF @@ERROR <> 0	GOTO Post_Rollback;
		
		IF (NOT EXISTS(SELECT TOP 1 1 FROM tblGLJournal A WHERE A.strReverseLink IN (SELECT strJournalId FROM tblGLJournal WHERE intJournalId IN (SELECT intJournalId FROM #tmpPostJournals))) OR ISNULL(@ysnRecap, 0) = 1)
			BEGIN
				SET @Param = (SELECT strJournalId FROM tblGLJournal WHERE intJournalId IN (SELECT intJournalId FROM #tmpPostJournals))
				EXEC [dbo].[uspGLReverseGLEntries] @strBatchId, @Param, @ysnRecap, 'GJ', NULL, @intEntityId, @intCount	OUT
				SET @successfulCount = @intCount
				
				IF(@intCount > 0)
				BEGIN
					UPDATE tblGLJournal SET ysnPosted = 0 WHERE intJournalId IN (SELECT intJournalId FROM #tmpPostJournals)
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
		DELETE tblGLPostResult WHERE dtmDate < DATEADD(day, -1, GETDATE())
		
		INSERT INTO tblGLPostResult (strBatchId,intTransactionId,strTransactionId,strDescription,dtmDate,intEntityId,strTransactionType)
			SELECT @strBatchId as strBatchId,tmpBatchResults.intJournalId as intTransactionId,tblB.strJournalId as strTransactionId, strMessage as strDescription,GETDATE() as dtmDate,@intEntityId,@strJournalType
			FROM (
				SELECT DISTINCT A.intJournalId,
					'Unable to find an open accounting period to match the transaction date.' AS strMessage
				FROM tblGLJournal A 
				WHERE A.intJournalId IN (SELECT intJournalId FROM #tmpPostJournals) AND ISNULL([dbo].isOpenAccountingDate(A.dtmDate), 0) = 0  
				UNION
				SELECT DISTINCT A.intJournalId,
					'Unable to find an open accounting period to match the reverse date.' AS strMessage
				FROM tblGLJournal A 
				WHERE 0 = CASE WHEN ISNULL(A.dtmReverseDate, '') = '' THEN 1 ELSE ISNULL([dbo].isOpenAccountingDate(A.dtmReverseDate), 0) END 
					  AND A.intJournalId IN (SELECT intJournalId FROM #tmpPostJournals)
				UNION
				SELECT DISTINCT A.intJournalId,
					'This transaction cannot be posted because the posting date is empty.' AS strMessage
				FROM tblGLJournal A 
				WHERE 0 = CASE WHEN ISNULL(A.dtmDate, '') = '' THEN 0 ELSE 1 END 
					  AND A.intJournalId IN (SELECT intJournalId FROM #tmpPostJournals)
				UNION
				SELECT DISTINCT A.intJournalId,
					'Reverse date must be later than Post Date.' AS strMessage
				FROM tblGLJournal A 
				WHERE 0 = CASE WHEN ISNULL(A.dtmReverseDate, '') = '' THEN 1 ELSE 
							CASE WHEN A.dtmReverseDate <= A.dtmDate THEN 0 ELSE 1 END
						END AND A.intJournalId IN (SELECT intJournalId FROM #tmpPostJournals)
				UNION
				SELECT DISTINCT A.intJournalId,
					'You cannot post this transaction because it has inactive account id ' + B.strAccountId + '.' AS strMessage
				FROM tblGLJournalDetail A 
					LEFT OUTER JOIN tblGLAccount B ON A.intAccountId = B.intAccountId
				WHERE ISNULL(B.ysnActive, 0) = 0 AND A.intJournalId IN (SELECT intJournalId FROM #tmpPostJournals)
				UNION
				SELECT DISTINCT A.intJournalId,
					'You cannot post this transaction because it has invalid account(s).' AS strMessage
				FROM tblGLJournalDetail A 
					LEFT OUTER JOIN tblGLAccount B ON A.intAccountId = B.intAccountId
				WHERE (A.intAccountId IS NULL OR 0 = CASE WHEN ISNULL(A.intAccountId, '') = '' THEN 0 ELSE 1 END) AND A.intJournalId IN (SELECT intJournalId FROM #tmpPostJournals)								
				UNION
				SELECT DISTINCT A.intJournalId,
					'You cannot post empty transaction.' AS strMessage
				FROM tblGLJournal A 
				LEFT JOIN tblGLJournalDetail B ON A.intJournalId = B.intJournalId
				WHERE A.intJournalId IN (SELECT intJournalId FROM #tmpPostJournals)	
				GROUP BY A.intJournalId						
				HAVING COUNT(B.intJournalId) < 1				
				UNION 
				SELECT DISTINCT A.intJournalId,
					'Unable to post. The transaction is out of balance.' AS strMessage
				FROM tblGLJournalDetail A 
				WHERE A.intJournalId IN (SELECT intJournalId FROM #tmpPostJournals)	
				GROUP BY A.intJournalId		
				HAVING SUM(ISNULL(A.dblCredit,0)) <> SUM(ISNULL(A.dblDebit,0)) 
				--UNION 
				--SELECT DISTINCT B.intJournalId,
				--	'You cannot post this transaction because Accounting Unit setup does not match account id ' + C.strAccountId + ' setup.' AS strMessage
				--FROM tblGLJournalDetail B 
				--	LEFT OUTER JOIN tblGLAccount C ON B.intAccountId = C.intAccountId
				--WHERE (ISNULL(B.dblCreditUnit, 0) > 0 OR ISNULL(B.dblDebitUnit, 0) > 0) AND ISNULL(C.intAccountUnitId, 0) = 0 
				--	AND B.intJournalId IN (SELECT intJournalId FROM #tmpPostJournals)
				--	GROUP BY B.intJournalId, C.intAccountId, C.strAccountId
			) tmpBatchResults
		LEFT JOIN tblGLJournal tblB ON tmpBatchResults.intJournalId = tblB.intJournalId
	END

IF @@ERROR <> 0	GOTO Post_Rollback;
	
	
--=====================================================================================================================================
-- 	POPULATE VALID JOURNALS TEMPORARY TABLE
---------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO #tmpValidJournals
	SELECT DISTINCT A.[intJournalId]
	FROM tblGLJournal A 
	WHERE	A.[intJournalId] IN (SELECT B.intJournalId FROM #tmpPostJournals  B
						WHERE B.intJournalId NOT IN (SELECT intTransactionId FROM tblGLPostResult WHERE strBatchId = @strBatchId GROUP BY intTransactionId)) 
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
	
		DECLARE @intCurrencyId	INT
		DECLARE @dblDailyRate	NUMERIC (18,6)
		
		SET @intCurrencyId		= (SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE intCurrencyID = (CASE WHEN (SELECT TOP 1 strValue FROM tblSMPreferences WHERE strPreference = 'defaultCurrency') > 0 
																		THEN (SELECT TOP 1 strValue FROM tblSMPreferences WHERE strPreference = 'defaultCurrency')
																		ELSE (SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE strCurrency = 'USD') END))
		SET @dblDailyRate		= (SELECT TOP 1 dblDailyRate FROM tblSMCurrency WHERE intCurrencyID = @intCurrencyId);

	
		WITH Units 
		AS 
		(
			SELECT	A.[dblLbsPerUnit], B.[intAccountId] 
			FROM tblGLAccountUnit A INNER JOIN tblGLAccount B ON A.[intAccountUnitId] = B.[intAccountUnitId]
		)
		INSERT INTO tblGLDetail (
			 [strTransactionId]
			,[intAccountId]
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
			,[intCurrencyId]
			,[dblExchangeRate]
			,[intUserId]
			,[intEntityId]			
			,[dtmDateEntered]
			,[strBatchId]
			,[strCode]
			,[strModuleName]
			,[strTransactionForm]
			,[strJournalLineDescription]
			,[intJournalLineNo]
		)
		SELECT 
			 [strTransactionId]		= B.[strJournalId]
			,[intAccountId]			= A.[intAccountId]
			,[strDescription]		= A.[strDescription]
			,[strReference]			= A.[strReference]
			,[dtmTransactionDate]	= A.[dtmDate]
			,[dblDebit]				= CASE	WHEN [dblCredit] < 0 THEN ABS([dblCredit])
											WHEN [dblDebit] < 0 THEN 0
											ELSE [dblDebit] END 
			,[dblCredit]			= CASE	WHEN [dblDebit] < 0 THEN ABS([dblDebit])
											WHEN [dblCredit] < 0 THEN 0
											ELSE [dblCredit] END	
			,[dblDebitUnit]			= ISNULL(A.[dblDebitUnit], 0)  * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0)
			,[dblCreditUnit]		= ISNULL(A.[dblCreditUnit], 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0)
			,[dtmDate]				= ISNULL(B.[dtmDate], GETDATE())
			,[ysnIsUnposted]		= 0 
			,[intConcurrencyId]		= 1
			,[intCurrencyId]		= @intCurrencyId
			,[dblExchangeRate]		= @dblDailyRate
			,[intUserId]			= 0
			,[intEntityId]			= @intEntityId			
			,[dtmDateEntered]		= GETDATE()
			,[strBatchId]			= @strBatchId
			,[strCode]				= 'GJ'
			,[strModuleName]		= 'General Ledger'
			,[strTransactionForm]	= B.[strTransactionType]
			,[strJournalLineDescription] = A.[strDescription]
			,[intJournalLineNo]		= A.intLineNo

		FROM [dbo].tblGLJournalDetail A INNER JOIN [dbo].tblGLJournal B 
			ON A.[intJournalId] = B.[intJournalId]
		WHERE B.[intJournalId] IN (SELECT [intJournalId] FROM #tmpValidJournals)

		IF @@ERROR <> 0	GOTO Post_Rollback;
	END
ELSE
	BEGIN
		-- DELETE Results 1 DAYS OLDER	
		DELETE tblGLPostRecap WHERE dtmDateEntered < DATEADD(day, -1, GETDATE()) and intEntityId = @intEntityId;
		
		WITH Accounts 
		AS 
		(
			SELECT A.[strAccountId], A.[intAccountId], A.[intAccountGroupId], B.[strAccountGroup], C.[dblLbsPerUnit]
			FROM tblGLAccount A LEFT JOIN tblGLAccountGroup B on A.intAccountGroupId = B.intAccountGroupId
								LEFT JOIN tblGLAccountUnit  C on C.intAccountUnitId  = A.intAccountUnitId
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
			,[strModuleName]
			,[strTransactionForm]
		)
		SELECT 
			 [strTransactionId]		= B.[strJournalId]
			,[intTransactionId]		= B.[intJournalId]
			,[intAccountId]			= A.[intAccountId]
			,[strAccountId]			= (SELECT [strAccountId] FROM Accounts WHERE [intAccountId] = A.[intAccountId])
			,[strAccountGroup]		= (SELECT [strAccountGroup] FROM Accounts WHERE [intAccountId] = A.[intAccountId])
			,[strDescription]		= A.[strDescription]
			,[strReference]			= A.[strReference]
			,[dtmTransactionDate]	= A.[dtmDate]
			,[dblDebit]				= CASE	WHEN [dblCredit] < 0 THEN ABS([dblCredit])
											WHEN [dblDebit] < 0 THEN 0
											ELSE [dblDebit] END 
			,[dblCredit]			= CASE	WHEN [dblDebit] < 0 THEN ABS([dblDebit])
											WHEN [dblCredit] < 0 THEN 0
											ELSE [dblCredit] END	
			,[dblDebitUnit]			= ISNULL(A.[dblDebitUnit], 0)  * ISNULL((SELECT [dblLbsPerUnit] FROM Accounts WHERE [intAccountId] = A.[intAccountId]), 0)
			,[dblCreditUnit]		= ISNULL(A.[dblCreditUnit], 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Accounts WHERE [intAccountId] = A.[intAccountId]), 0)
			,[dtmDate]				= ISNULL(B.[dtmDate], GETDATE())
			,[ysnIsUnposted]		= 0 
			,[intConcurrencyId]		= 1
			,[dblExchangeRate]		= 1
			,[intUserId]			= 0
			,[intEntityId]			= @intEntityId			
			,[dtmDateEntered]		= GETDATE()
			,[strBatchId]			= @strBatchId
			,[strCode]				= 'GJ'
			,[strModuleName]		= 'General Ledger'
			,[strTransactionForm]	= B.[strTransactionType]
		FROM [dbo].tblGLJournalDetail A INNER JOIN [dbo].tblGLJournal B 
			ON A.[intJournalId] = B.[intJournalId]
		WHERE B.[intJournalId] IN (SELECT [intJournalId] FROM #tmpValidJournals)

	IF((SELECT COUNT(*) FROM #tmpValidJournals) > 1)
		BEGIN
		
			--SUMMARY GROUP
			INSERT INTO tblGLPostRecap (
				 [strTransactionId]
				,[intTransactionId]
				,[dblDebit]
				,[dblCredit]
				,[dblDebitUnit]
				,[dblCreditUnit]
				,[dtmDate]
				,[dblExchangeRate]
				,[dtmDateEntered]
				,[ysnIsUnposted]
				,[intUserId]
				,[intEntityId]				
				,[strBatchId]
				,[strCode]
				,[strModuleName]
				,[strTransactionForm]
			)
			SELECT 
				 [strTransactionId]
				,[intTransactionId]		
				,SUM([dblDebit])
				,SUM([dblCredit])
				,SUM([dblDebitUnit])
				,SUM([dblCreditUnit])
				,[dtmDate]
				,[dblExchangeRate]
				,[dtmDateEntered]
				,[ysnIsUnposted]
				,[intUserId]	
				,[intEntityId]					
				,[strBatchId]	
				,[strCode]				
				,[strModuleName]
				,[strTransactionForm]
			FROM [dbo].tblGLPostRecap A
			WHERE A.[strBatchId] = @strBatchId and A.[intEntityId] = @intEntityId
			GROUP BY [strTransactionId],[intTransactionId],[dtmDate],[dblExchangeRate],[dtmDateEntered],[ysnIsUnposted],[intUserId],[intEntityId],[strBatchId],[strCode],[strModuleName],[strTransactionForm]

			IF @@ERROR <> 0	GOTO Post_Rollback;
					
		END

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
	SELECT	A.[dblLbsPerUnit], B.[intAccountId] 
	FROM tblGLAccountUnit A INNER JOIN tblGLAccount B ON A.[intAccountUnitId] = B.[intAccountUnitId]
),
JournalDetail
AS
(
	SELECT   [dtmDate]			= ISNULL(B.[dtmDate], GETDATE())
			,[intAccountId]		= A.[intAccountId]
			,[dblDebit]			= CASE	WHEN [dblCredit] < 0 THEN ABS([dblCredit])
										WHEN [dblDebit] < 0 THEN 0
										ELSE [dblDebit] END 
			,[dblCredit]		= CASE	WHEN [dblDebit] < 0 THEN ABS([dblDebit])
										WHEN [dblCredit] < 0 THEN 0
										ELSE [dblCredit] END	
			,[dblDebitUnit]		= ISNULL([dblDebitUnit], 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0)
			,[dblCreditUnit]	= ISNULL([dblCreditUnit], 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0)
	FROM [dbo].tblGLJournalDetail A INNER JOIN [dbo].tblGLJournal B ON A.[intJournalId] = B.[intJournalId]
	WHERE B.[intJournalId] IN (SELECT [intJournalId] FROM #tmpValidJournals)
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
					,[intAccountId]		= A.[intAccountId]
					,[dtmDate]			= ISNULL(CONVERT(DATE, A.[dtmDate]), '') 								
			FROM tblGLSummary A 
					INNER JOIN JournalDetail B 
					ON CONVERT(DATE, A.[dtmDate]) = CONVERT(DATE, B.[dtmDate]) AND A.[intAccountId] = B.[intAccountId] AND A.[strCode] = 'GJ'			
			GROUP BY ISNULL(CONVERT(DATE, A.[dtmDate]), ''), A.[intAccountId]
		) AS GLDetailGrouped
WHERE tblGLSummary.[intAccountId] = GLDetailGrouped.[intAccountId] AND tblGLSummary.[strCode] = 'GJ' AND
	  ISNULL(CONVERT(DATE, tblGLSummary.[dtmDate]), '') = ISNULL(CONVERT(DATE, GLDetailGrouped.[dtmDate]), '');

IF @@ERROR <> 0	GOTO Post_Rollback;


--=====================================================================================================================================
-- 	INSERT TO GL SUMMARY RECORDS
---------------------------------------------------------------------------------------------------------------------------------------
WITH Units
AS 
(
	SELECT	A.[dblLbsPerUnit], B.[intAccountId] 
	FROM tblGLAccountUnit A INNER JOIN tblGLAccount B ON A.[intAccountUnitId] = B.[intAccountUnitId]
),
JournalDetail 
AS
(
	SELECT [dtmDate]		= ISNULL(B.[dtmDate], GETDATE())
		,[intAccountId]		= A.[intAccountId]
		,[dblDebit]			= CASE	WHEN [dblCredit] < 0 THEN ABS([dblCredit])
									WHEN [dblDebit] < 0 THEN 0
									ELSE [dblDebit] END 
		,[dblCredit]		= CASE	WHEN [dblDebit] < 0 THEN ABS([dblDebit])
									WHEN [dblCredit] < 0 THEN 0
									ELSE [dblCredit] END	
		,[dblDebitUnit]		= ISNULL(A.[dblDebitUnit], 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0)
		,[dblCreditUnit]	= ISNULL(A.[dblCreditUnit], 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0)
	FROM [dbo].tblGLJournalDetail A INNER JOIN [dbo].tblGLJournal B ON A.[intJournalId] = B.[intJournalId]
	WHERE B.intJournalId IN (SELECT [intJournalId] FROM #tmpValidJournals)
)
INSERT INTO tblGLSummary (
	 [intAccountId]
	,[dtmDate]
	,[dblDebit]
	,[dblCredit]
	,[dblDebitUnit]
	,[dblCreditUnit]
	,[strCode]
	,[intConcurrencyId]
)
SELECT	
	 [intAccountId]		= A.[intAccountId]
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
				  A.[intAccountId] = B.[intAccountId] AND B.[strCode] = 'GJ'
		)
GROUP BY ISNULL(CONVERT(DATE, A.[dtmDate]), ''), A.[intAccountId];

IF @@ERROR <> 0	GOTO Post_Rollback;


--=====================================================================================================================================
-- 	UPDATE JOURNAL TABLE
---------------------------------------------------------------------------------------------------------------------------------------
UPDATE tblGLJournal
SET [ysnPosted] = 1
	,[dtmPosted] = GETDATE()
WHERE [intJournalId] IN (SELECT [intJournalId] FROM #tmpValidJournals);

IF @@ERROR <> 0	GOTO Post_Rollback;


--=====================================================================================================================================
-- 	UPDATE RESULT
---------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO tblGLPostResult (strBatchId,intTransactionId,strTransactionId,strDescription,dtmDate,intEntityId,strTransactionType)
	SELECT @strBatchId as strBatchId,intJournalId as intTransactionId,strJournalId as strTransactionId, strMessage as strDescription,GETDATE() as dtmDate,@intEntityId,@strJournalType
	FROM (
		SELECT DISTINCT A.intJournalId,A.strJournalId,
			'Transaction successfully posted.' AS strMessage
		FROM tblGLJournal A 
		WHERE A.intJournalId IN (SELECT intJournalId FROM #tmpValidJournals)
	) B

IF @@ERROR <> 0	GOTO Post_Rollback;


--=====================================================================================================================================
-- 	RETURN TOTAL NUMBER OF VALID JOURNALS
---------------------------------------------------------------------------------------------------------------------------------------
SET @successfulCount = ISNULL(@successfulCount,0) + (SELECT COUNT(*) FROM #tmpValidJournals)


--=====================================================================================================================================
-- 	REVERSE JOURNAL
---------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO #tmpReverseJournals (intJournalId)
SELECT A.intJournalId FROM #tmpValidJournals A
	INNER JOIN tblGLJournal B ON A.intJournalId = B.intJournalId	
	WHERE B.dtmReverseDate IS NOT NULL

IF EXISTS (SELECT 1 FROM #tmpReverseJournals)
BEGIN
	DELETE #tmpValidJournals

	WHILE EXISTS(SELECT 1 FROM #tmpReverseJournals)
	BEGIN
		DECLARE @intJournalId INT = (SELECT TOP 1 intJournalId FROM #tmpReverseJournals)
		DECLARE @strJournalId NVARCHAR(100) = ''
		
		EXEC [dbo].uspSMGetStartingNumber 5, @strJournalId OUTPUT 		
		
		INSERT INTO tblGLJournal (
				 [dtmReverseDate]
				,[strJournalId]
				,[strTransactionType]
				,[dtmDate]
				,[strReverseLink]
				,[intCurrencyId]
				,[dblExchangeRate]
				,[dtmPosted]
				,[strDescription]
				,[ysnPosted]
				,[intConcurrencyId]
				,[dtmJournalDate]
				,[intUserId]
				,[intEntityId]				
				,[strSourceId]
				,[strJournalType]
				,[strRecurringStatus]
				,[strSourceType]
				)
			SELECT 
				 NULL
				,@strJournalId
				,[strTransactionType]
				,[dtmReverseDate]
				,A.strJournalId
				,[intCurrencyId]
				,[dblExchangeRate]
				,0
				,'Reversing transaction for ' + A.strJournalId
				,[ysnPosted]
				,[intConcurrencyId]
				,[dtmJournalDate]
				,[intUserId]
				,[intEntityId]
				,[strSourceId]
				,'Reversal Journal'
				,NULL
				,[strSourceType]
			FROM [dbo].tblGLJournal A
			WHERE A.intJournalId = @intJournalId
			
			DECLARE @intJournalId_NEW INT = (SELECT TOP 1 intJournalId FROM tblGLJournal WHERE strJournalId = @strJournalId)
			INSERT INTO #tmpValidJournals (intJournalId) SELECT @intJournalId_NEW
		 
		 INSERT INTO tblGLJournalDetail (
				 [intLineNo]
				,[intJournalId]
				,[dtmDate]
				,[intAccountId]
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
				,@intJournalId_NEW
				,[dtmDate]
				,[intAccountId]			
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
			WHERE A.intJournalId = @intJournalId
							
		DELETE #tmpReverseJournals WHERE intJournalId = @intJournalId
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
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = object_id('tempdb..#tmpPostJournals')) DROP TABLE #tmpPostJournals
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = object_id('tempdb..#tmpValidJournals')) DROP TABLE #tmpValidJournals
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = object_id('tempdb..#tmpReverseJournals')) DROP TABLE #tmpReverseJournals		
GO


--=====================================================================================================================================
-- 	SCRIPT EXECUTION 
---------------------------------------------------------------------------------------------------------------------------------------
--DECLARE @intCount AS INT

--EXEC [dbo].[usp_PostJournal]
--			@Param	 = 'select intJournalId from tblGLJournal where strJournalId = ''GJ-20''',				-- GENERATED BATCH Id
--			@ysnPost = 1,
--			@ysnRecap = 0,								-- WHEN SET TO 1, THEN IT WILL POPULATE tblGLPostRecap THAT CAN BE VIEWED VIA BUFFERED STORE IN SENCHA
--			@strBatchId = 'BATCH-11231',							-- COMMA DELIMITED JOURNAL Id TO POST 
--			@strJournalType = 'General Journal',
--			@intEntityId = 1,							-- USER Id THAT INITIATES POSTING
--			@successfulCount = @intCount OUTPUT		-- OUTPUT PARAMETER THAT RETURNS TOTAL NUMBER OF SUCCESSFUL RECORDS
				
--SELECT @intCount
