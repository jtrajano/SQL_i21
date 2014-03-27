
--=====================================================================================================================================
-- 	CREATE THE STORED PROCEDURE AFTER DELETING IT
---------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[uspGLPostAuditAdjustment]
	@Param				AS NVARCHAR(MAX)	= '',	
	@ysnPost			AS BIT				= 0,
	@ysnRecap			AS BIT				= 0,
	@strBatchId			AS NVARCHAR(100)	= '',	
	@strJournalType		AS NVARCHAR(30)		= '',
	@intUserId			AS INT				= 1,
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

DECLARE @Debit NUMERIC(18, 6)
DECLARE @Credit NUMERIC(18, 6)
DECLARE @DebitUnit NUMERIC(18, 6)
DECLARE @CreditUnit NUMERIC(18, 6)
DECLARE @GJDates DATETIME

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
		
		SET @Param = (SELECT strJournalId FROM tblGLJournal WHERE intJournalId IN (SELECT intJournalId FROM #tmpPostJournals))
		EXEC [dbo].[uspGLReverseGLEntries] @strBatchId, @Param, @ysnRecap, 'AA', NULL, @intUserId, @intCount	OUT
		SET @successfulCount = @intCount
				
		IF(@intCount > 0)
		BEGIN
			UPDATE tblGLJournal SET ysnPosted = 0 WHERE intJournalId IN (SELECT intJournalId FROM #tmpPostJournals)
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
		
		INSERT INTO tblGLPostResults (strBatchId,intTransactionId,strTransactionId,strDescription,dtmDate)
			SELECT @strBatchId as strBatchId,tmpBatchResults.intJournalId as intTransactionId,tblB.strJournalId as strTransactionId, strMessage as strDescription,GETDATE() as dtmDate
			FROM (
				SELECT DISTINCT A.intJournalId,
					'Unable to find an open fiscal year period to match the transaction date.' AS strMessage
				FROM tblGLJournal A 
				WHERE A.intJournalId IN (SELECT intJournalId FROM #tmpPostJournals) AND ISNULL([dbo].isOpenAccountingDate(A.dtmDate), 0) = 0  
				UNION
				SELECT DISTINCT A.intJournalId,
					'Unable to find an open fiscal year period to match the reverse date.' AS strMessage
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
				WHERE A.intAccountId IS NULL OR 0 = CASE WHEN ISNULL(A.intAccountId, '') = '' THEN 0 ELSE 1 END AND A.intJournalId IN (SELECT intJournalId FROM #tmpPostJournals)					
				UNION 
				SELECT DISTINCT A.intJournalId,
					'Unable to post. The transaction is out of balance.' AS strMessage
				FROM tblGLJournalDetail A 
				WHERE A.intJournalId IN (SELECT intJournalId FROM #tmpPostJournals)	
				GROUP BY A.intJournalId		
				HAVING SUM(ISNULL(A.dblCredit,0)) <> SUM(ISNULL(A.dblDebit,0)) 
				UNION
				SELECT DISTINCT A.intJournalId,
					'Retained Earnings is required.' AS strMessage
				FROM tblGLJournal A 
				WHERE 0 = CASE WHEN ISNULL((SELECT TOP 1 1 FROM tblGLFiscalYear WHERE dtmDateFrom <= A.dtmDate and dtmDateTo >= A.dtmDate),1) = 0 THEN 0 
							ELSE 
								CASE WHEN 
									ISNULL((SELECT TOP 1 1 FROM tblGLFiscalYear WHERE dtmDateFrom <= A.dtmDate and dtmDateTo >= A.dtmDate and intRetainAccount IS NULL),0) = 1 THEN 0
								ELSE 1
							END 
						END AND A.intJournalId IN (SELECT intJournalId FROM #tmpPostJournals)																
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
						WHERE B.intJournalId NOT IN (SELECT intTransactionId FROM tblGLPostResults WHERE strBatchId = @strBatchId GROUP BY intTransactionId)) 
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
			,[dblExchangeRate]
			,[intUserId]
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
			,[strReference]			= 'AA Audit AdjustmentFY ' + CAST(YEAR(B.[dtmDate]) AS NVARCHAR(50))
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
			,[dblExchangeRate]		= 1
			,[intUserId]			= @intUserId
			,[dtmDateEntered]		= GETDATE()
			,[strBatchId]			= @strBatchId
			,[strCode]				= B.[strSourceType]
			,[strModuleName]		= 'General Ledger'
			,[strTransactionForm]	= B.[strTransactionType]
			,[strJournalLineDescription] = A.[strDescription]
			,[intJournalLineNo]		= A.intLineNo
						
		FROM [dbo].tblGLJournalDetail A INNER JOIN [dbo].tblGLJournal B 
			ON A.[intJournalId] = B.[intJournalId]
		WHERE B.[intJournalId] IN (SELECT [intJournalId] FROM #tmpValidJournals);
		
		
		SET @GJDates = (SELECT dtmDate FROM tblGLJournal WHERE intJournalId = (SELECT TOP 1 [intJournalId] FROM #tmpValidJournals))
		IF((SELECT ysnStatus FROM tblGLFiscalYear WHERE dtmDateFrom <= @GJDates AND dtmDateTo >= @GJDates) = 0)
		BEGIN
		
			-- ACCOUNT REVENUE AND EXPENSE
			WITH Accounts 
			AS 
			(
				SELECT A.[strAccountId], A.[intAccountId], A.[intAccountGroupId], B.[strAccountGroup], C.[dblLbsPerUnit]
				FROM tblGLAccount A LEFT JOIN tblGLAccountGroup B on A.intAccountGroupId = B.intAccountGroupId
									LEFT JOIN tblGLAccountUnit  C on C.intAccountUnitId  = A.intAccountUnitId
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
				,[dblExchangeRate]
				,[intUserId]
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
				,[strReference]			= 'AA Audit AdjustmentFY ' + CAST(YEAR(B.[dtmDate]) AS NVARCHAR(50))
				,[dtmTransactionDate]	= A.[dtmDate]
				,[dblDebit]				= CASE	WHEN [dblDebit] < 0 THEN ABS([dblDebit])
												WHEN [dblCredit] < 0 THEN 0
												ELSE [dblCredit] END
				,[dblCredit]			= CASE	WHEN [dblCredit] < 0 THEN ABS([dblCredit])
												WHEN [dblDebit] < 0 THEN 0
												ELSE [dblDebit] END 	
				,[dblDebitUnit]			= ISNULL(A.[dblDebitUnit], 0)  * ISNULL((SELECT [dblLbsPerUnit] FROM Accounts WHERE [intAccountId] = A.[intAccountId]), 0)
				,[dblCreditUnit]		= ISNULL(A.[dblCreditUnit], 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Accounts WHERE [intAccountId] = A.[intAccountId]), 0)
				,[dtmDate]				= ISNULL(B.[dtmDate], GETDATE())
				,[ysnIsUnposted]		= 0 
				,[intConcurrencyId]		= 1
				,[dblExchangeRate]		= 1
				,[intUserId]			= @intUserId
				,[dtmDateEntered]		= GETDATE()
				,[strBatchId]			= @strBatchId
				,[strCode]				= B.[strSourceType]
				,[strModuleName]		= 'General Ledger'
				,[strTransactionForm]	= B.[strTransactionType]
				,[strJournalLineDescription] = A.[strDescription]
				,[intJournalLineNo]		= A.intLineNo
				
			FROM [dbo].tblGLJournalDetail A 
				INNER JOIN [dbo].tblGLJournal B 
					ON A.[intJournalId] = B.[intJournalId]
				INNER JOIN [dbo].tblGLAccount C 
					ON A.[intAccountId] = C.[intAccountId]
				INNER JOIN [dbo].tblGLAccountGroup D 
					ON C.[intAccountGroupId] = D.[intAccountGroupId]
			WHERE (D.strAccountType = 'Revenue' OR D.strAccountType = 'Expense')
				AND B.[intJournalId] IN (SELECT [intJournalId] FROM #tmpValidJournals);
			
			-- ACCOUNT RETAINED EARNINGS
			SET @Debit = (SELECT SUM(dblDebit) as dblDebit FROM [dbo].tblGLJournalDetail A 
							INNER JOIN [dbo].tblGLJournal B 
								ON A.[intJournalId] = B.[intJournalId]
							INNER JOIN [dbo].tblGLAccount C 
								ON A.[intAccountId] = C.[intAccountId]
							INNER JOIN [dbo].tblGLAccountGroup D 
								ON C.[intAccountGroupId] = D.[intAccountGroupId]
						WHERE (D.strAccountType <> 'Revenue' AND D.strAccountType <> 'Expense')
							AND B.[intJournalId] IN (SELECT [intJournalId] FROM #tmpValidJournals))	
			SET @Credit = (SELECT SUM(dblCredit) as dblCredit FROM [dbo].tblGLJournalDetail A 
							INNER JOIN [dbo].tblGLJournal B 
								ON A.[intJournalId] = B.[intJournalId]
							INNER JOIN [dbo].tblGLAccount C 
								ON A.[intAccountId] = C.[intAccountId]
							INNER JOIN [dbo].tblGLAccountGroup D 
								ON C.[intAccountGroupId] = D.[intAccountGroupId]
						WHERE (D.strAccountType <> 'Revenue' AND D.strAccountType <> 'Expense')
							AND B.[intJournalId] IN (SELECT [intJournalId] FROM #tmpValidJournals))
			SET @DebitUnit = (SELECT SUM(dblDebitUnit) as dblDebitUnit FROM [dbo].tblGLJournalDetail A 
							INNER JOIN [dbo].tblGLJournal B 
								ON A.[intJournalId] = B.[intJournalId]
							INNER JOIN [dbo].tblGLAccount C 
								ON A.[intAccountId] = C.[intAccountId]
							INNER JOIN [dbo].tblGLAccountGroup D 
								ON C.[intAccountGroupId] = D.[intAccountGroupId]
						WHERE (D.strAccountType <> 'Revenue' AND D.strAccountType <> 'Expense')
							AND B.[intJournalId] IN (SELECT [intJournalId] FROM #tmpValidJournals))
			SET @CreditUnit = (SELECT SUM(dblCreditUnit) as dblCreditUnit FROM [dbo].tblGLJournalDetail A 
							INNER JOIN [dbo].tblGLJournal B 
								ON A.[intJournalId] = B.[intJournalId]
							INNER JOIN [dbo].tblGLAccount C 
								ON A.[intAccountId] = C.[intAccountId]
							INNER JOIN [dbo].tblGLAccountGroup D 
								ON C.[intAccountGroupId] = D.[intAccountGroupId]
						WHERE (D.strAccountType <> 'Revenue' AND D.strAccountType <> 'Expense')
							AND B.[intJournalId] IN (SELECT [intJournalId] FROM #tmpValidJournals))			
			
			IF (@Debit > @Credit)
            BEGIN
                SET @Credit = @Debit - @Credit
                SET @Debit = 0
            END
            ELSE IF (@Credit > @Debit)
            BEGIN
                SET @Debit = @Credit - @Debit
                SET @Credit = 0
            END;
			
			WITH Accounts 
			AS 
			(
				SELECT A.[strAccountId], A.[intAccountId], A.[strDescription], A.[intAccountGroupId], B.[strAccountGroup], C.[dblLbsPerUnit]
				FROM tblGLAccount A LEFT JOIN tblGLAccountGroup B on A.intAccountGroupId = B.intAccountGroupId
									LEFT JOIN tblGLAccountUnit  C on C.intAccountUnitId  = A.intAccountUnitId
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
				,[dblExchangeRate]
				,[intUserId]
				,[dtmDateEntered]
				,[strBatchId]
				,[strCode]
				,[strModuleName]
				,[strTransactionForm]
				,[strJournalLineDescription]
				,[intJournalLineNo]
			)
			SELECT
				 [strTransactionId]		= (SELECT TOP 1 strJournalId FROM tblGLJournal WHERE intJournalId = (SELECT TOP 1 [intJournalId] FROM #tmpValidJournals))
				,[intAccountId]			= (SELECT TOP 1 [intRetainAccount] FROM tblGLFiscalYear WHERE dtmDateFrom <= @GJDates AND dtmDateTo >= @GJDates)
				,[strDescription]		= (SELECT TOP 1 [strDescription] FROM Accounts WHERE [intAccountId] = (SELECT TOP 1 intRetainAccount FROM tblGLFiscalYear WHERE dtmDateFrom <= @GJDates AND dtmDateTo >= @GJDates))
				,[strReference]			= 'AA Audit AdjustmentFY ' + CAST(YEAR(@GJDates) AS NVARCHAR(50))
				,[dtmTransactionDate]	= @GJDates
				,[dblDebit]				= @Debit
				,[dblCredit]			= @Credit	
				,[dblDebitUnit]			= @DebitUnit
				,[dblCreditUnit]		= @CreditUnit
				,[dtmDate]				= ISNULL(@GJDates, GETDATE())
				,[ysnIsUnposted]		= 0 
				,[intConcurrencyId]		= 1
				,[dblExchangeRate]		= 1
				,[intUserId]			= @intUserId
				,[dtmDateEntered]		= GETDATE()
				,[strBatchId]			= @strBatchId
				,[strCode]				= A.[strSourceType]
				,[strModuleName]		= 'General Ledger'
				,[strTransactionForm]	= A.[strTransactionType]
				,[strJournalLineDescription] = NULL
				,[intJournalLineNo]		= NULL
				
			FROM [dbo].tblGLJournal A 
			WHERE A.[intJournalId] IN (SELECT TOP 1 [intJournalId] FROM #tmpValidJournals)
			
		END
		

		IF @@ERROR <> 0	GOTO Post_Rollback;
	END
ELSE
	BEGIN
		-- DELETE Results 1 DAYS OLDER	
		DELETE tblGLPostRecap WHERE dtmDateEntered < DATEADD(day, -1, GETDATE()) and intUserId = @intUserId;
		
		
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
			,[strReference]			= 'AA Audit AdjustmentFY ' + CAST(YEAR(B.[dtmDate]) AS NVARCHAR(50))
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
			,[intUserId]			= @intUserId
			,[dtmDateEntered]		= GETDATE()
			,[strBatchId]			= @strBatchId
			,[strCode]				= B.[strSourceType]
			,[strModuleName]		= 'General Ledger'
			,[strTransactionForm]	= B.[strTransactionType]
		FROM [dbo].tblGLJournalDetail A INNER JOIN [dbo].tblGLJournal B 
			ON A.[intJournalId] = B.[intJournalId]
		WHERE B.[intJournalId] IN (SELECT [intJournalId] FROM #tmpValidJournals);
		
		
		SET @GJDates = (SELECT dtmDate FROM tblGLJournal WHERE intJournalId = (SELECT TOP 1 [intJournalId] FROM #tmpValidJournals))
		IF((SELECT ysnStatus FROM tblGLFiscalYear WHERE dtmDateFrom <= @GJDates AND dtmDateTo >= @GJDates) = 0)
		BEGIN
		
			-- ACCOUNT REVENUE AND EXPENSE
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
				,[strReference]			= 'AA Audit AdjustmentFY ' + CAST(YEAR(B.[dtmDate]) AS NVARCHAR(50))
				,[dtmTransactionDate]	= A.[dtmDate]
				,[dblDebit]				= CASE	WHEN [dblDebit] < 0 THEN ABS([dblDebit])
												WHEN [dblCredit] < 0 THEN 0
												ELSE [dblCredit] END
				,[dblCredit]			= CASE	WHEN [dblCredit] < 0 THEN ABS([dblCredit])
												WHEN [dblDebit] < 0 THEN 0
												ELSE [dblDebit] END 	
				,[dblDebitUnit]			= ISNULL(A.[dblDebitUnit], 0)  * ISNULL((SELECT [dblLbsPerUnit] FROM Accounts WHERE [intAccountId] = A.[intAccountId]), 0)
				,[dblCreditUnit]		= ISNULL(A.[dblCreditUnit], 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Accounts WHERE [intAccountId] = A.[intAccountId]), 0)
				,[dtmDate]				= ISNULL(B.[dtmDate], GETDATE())
				,[ysnIsUnposted]		= 0 
				,[intConcurrencyId]		= 1
				,[dblExchangeRate]		= 1
				,[intUserId]			= @intUserId
				,[dtmDateEntered]		= GETDATE()
				,[strBatchId]			= @strBatchId
				,[strCode]				= B.[strSourceType]
				,[strModuleName]		= 'General Ledger'
				,[strTransactionForm]	= B.[strTransactionType]
			FROM [dbo].tblGLJournalDetail A 
				INNER JOIN [dbo].tblGLJournal B 
					ON A.[intJournalId] = B.[intJournalId]
				INNER JOIN [dbo].tblGLAccount C 
					ON A.[intAccountId] = C.[intAccountId]
				INNER JOIN [dbo].tblGLAccountGroup D 
					ON C.[intAccountGroupId] = D.[intAccountGroupId]
			WHERE (D.strAccountType = 'Revenue' OR D.strAccountType = 'Expense')
				AND B.[intJournalId] IN (SELECT [intJournalId] FROM #tmpValidJournals);
			
			-- ACCOUNT RETAINED EARNINGS
			SET @Debit = (SELECT SUM(dblDebit) as dblDebit FROM [dbo].tblGLJournalDetail A 
							INNER JOIN [dbo].tblGLJournal B 
								ON A.[intJournalId] = B.[intJournalId]
							INNER JOIN [dbo].tblGLAccount C 
								ON A.[intAccountId] = C.[intAccountId]
							INNER JOIN [dbo].tblGLAccountGroup D 
								ON C.[intAccountGroupId] = D.[intAccountGroupId]
						WHERE (D.strAccountType <> 'Revenue' AND D.strAccountType <> 'Expense')
							AND B.[intJournalId] IN (SELECT [intJournalId] FROM #tmpValidJournals))	
			SET @Credit = (SELECT SUM(dblCredit) as dblCredit FROM [dbo].tblGLJournalDetail A 
							INNER JOIN [dbo].tblGLJournal B 
								ON A.[intJournalId] = B.[intJournalId]
							INNER JOIN [dbo].tblGLAccount C 
								ON A.[intAccountId] = C.[intAccountId]
							INNER JOIN [dbo].tblGLAccountGroup D 
								ON C.[intAccountGroupId] = D.[intAccountGroupId]
						WHERE (D.strAccountType <> 'Revenue' AND D.strAccountType <> 'Expense')
							AND B.[intJournalId] IN (SELECT [intJournalId] FROM #tmpValidJournals))
			SET @DebitUnit = (SELECT SUM(dblDebitUnit) as dblDebitUnit FROM [dbo].tblGLJournalDetail A 
							INNER JOIN [dbo].tblGLJournal B 
								ON A.[intJournalId] = B.[intJournalId]
							INNER JOIN [dbo].tblGLAccount C 
								ON A.[intAccountId] = C.[intAccountId]
							INNER JOIN [dbo].tblGLAccountGroup D 
								ON C.[intAccountGroupId] = D.[intAccountGroupId]
						WHERE (D.strAccountType <> 'Revenue' AND D.strAccountType <> 'Expense')
							AND B.[intJournalId] IN (SELECT [intJournalId] FROM #tmpValidJournals))
			SET @CreditUnit = (SELECT SUM(dblCreditUnit) as dblCreditUnit FROM [dbo].tblGLJournalDetail A 
							INNER JOIN [dbo].tblGLJournal B 
								ON A.[intJournalId] = B.[intJournalId]
							INNER JOIN [dbo].tblGLAccount C 
								ON A.[intAccountId] = C.[intAccountId]
							INNER JOIN [dbo].tblGLAccountGroup D 
								ON C.[intAccountGroupId] = D.[intAccountGroupId]
						WHERE (D.strAccountType <> 'Revenue' AND D.strAccountType <> 'Expense')
							AND B.[intJournalId] IN (SELECT [intJournalId] FROM #tmpValidJournals))			
			
			IF (@Debit > @Credit)
            BEGIN
                SET @Credit = @Debit - @Credit
                SET @Debit = 0
            END
            ELSE IF (@Credit > @Debit)
            BEGIN
                SET @Debit = @Credit - @Debit
                SET @Credit = 0
            END;
			
			WITH Accounts 
			AS 
			(
				SELECT A.[strAccountId], A.[intAccountId], A.[strDescription], A.[intAccountGroupId], B.[strAccountGroup], C.[dblLbsPerUnit]
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
				,[dtmDateEntered]
				,[strBatchId]
				,[strCode]
				,[strModuleName]
				,[strTransactionForm]
			)
			SELECT
				 [strTransactionId]		= (SELECT TOP 1 strJournalId FROM tblGLJournal WHERE intJournalId = (SELECT TOP 1 [intJournalId] FROM #tmpValidJournals))
				,[intTransactionId]		= (SELECT TOP 1 [intJournalId] FROM #tmpValidJournals)
				,[intAccountId]			= (SELECT TOP 1 [intRetainAccount] FROM tblGLFiscalYear WHERE dtmDateFrom <= @GJDates AND dtmDateTo >= @GJDates)
				,[strAccountId]			= (SELECT TOP 1 [strAccountId] FROM Accounts WHERE [intAccountId] = (SELECT TOP 1 intRetainAccount FROM tblGLFiscalYear WHERE dtmDateFrom <= @GJDates AND dtmDateTo >= @GJDates))
				,[strAccountGroup]		= (SELECT [strAccountGroup] FROM Accounts WHERE [intAccountId] = (SELECT TOP 1 [intRetainAccount] FROM tblGLFiscalYear WHERE dtmDateFrom <= @GJDates AND dtmDateTo >= @GJDates))
				,[strDescription]		= (SELECT TOP 1 [strDescription] FROM Accounts WHERE [intAccountId] = (SELECT TOP 1 intRetainAccount FROM tblGLFiscalYear WHERE dtmDateFrom <= @GJDates AND dtmDateTo >= @GJDates))
				,[strReference]			= 'AA Audit AdjustmentFY ' + CAST(YEAR(@GJDates) AS NVARCHAR(50))
				,[dtmTransactionDate]	= @GJDates
				,[dblDebit]				= @Debit
				,[dblCredit]			= @Credit	
				,[dblDebitUnit]			= @DebitUnit
				,[dblCreditUnit]		= @CreditUnit
				,[dtmDate]				= ISNULL(@GJDates, GETDATE())
				,[ysnIsUnposted]		= 0 
				,[intConcurrencyId]		= 1
				,[dblExchangeRate]		= 1
				,[intUserId]			= @intUserId
				,[dtmDateEntered]		= GETDATE()
				,[strBatchId]			= @strBatchId
				,[strCode]				= A.[strSourceType]
				,[strModuleName]		= 'General Ledger'
				,[strTransactionForm]	= A.[strTransactionType]
			FROM [dbo].tblGLJournal A 
			WHERE A.[intJournalId] IN (SELECT TOP 1 [intJournalId] FROM #tmpValidJournals)
			
			END
				
		IF @@ERROR <> 0	GOTO Post_Rollback;

		GOTO Post_Commit;
	END

IF @@ERROR <> 0	GOTO Post_Rollback;


--=====================================================================================================================================
-- 	UPDATE GL SUMMARY RECORDS
---------------------------------------------------------------------------------------------------------------------------------------
WITH JournalDetail
AS
(
	SELECT   [dtmDate]			= ISNULL(A.[dtmDate], GETDATE())
			,[intAccountId]		= A.[intAccountId]
			,[dblDebit]			= CASE	WHEN [dblCredit] < 0 THEN ABS([dblCredit])
										WHEN [dblDebit] < 0 THEN 0
										ELSE [dblDebit] END 
			,[dblCredit]		= CASE	WHEN [dblDebit] < 0 THEN ABS([dblDebit])
										WHEN [dblCredit] < 0 THEN 0
										ELSE [dblCredit] END
			,[dblDebitUnit]		= [dblDebitUnit]
			,[dblCreditUnit]	= [dblDebitUnit]	
	FROM [dbo].tblGLDetail A
	WHERE A.strBatchId = @strBatchId
)
UPDATE	tblGLSummary 
SET		 [dblDebit]			= ISNULL(tblGLSummary.[dblDebit], 0) + ISNULL(GLDetailGrouped.[dblDebit], 0)
		,[dblCredit]		= ISNULL(tblGLSummary.[dblCredit], 0) + ISNULL(GLDetailGrouped.[dblCredit], 0)
		,[dblDebitUnit]		= ISNULL(tblGLSummary.[dblDebitUnit], 0) + ISNULL(GLDetailGrouped.[dblDebitUnit], 0)
		,[dblCreditUnit]	= ISNULL(tblGLSummary.[dblCreditUnit], 0) + ISNULL(GLDetailGrouped.[dblCreditUnit], 0)
		,[intConcurrencyId] = ISNULL([intConcurrencyId], 0) + 1
FROM	(
			SELECT	 [dblDebit]		= SUM(ISNULL(B.[dblDebit], 0))
					,[dblCredit]	= SUM(ISNULL(B.[dblCredit], 0))
					,[dblDebitUnit]		= SUM(ISNULL(B.[dblDebitUnit], 0))
					,[dblCreditUnit]	= SUM(ISNULL(B.[dblCreditUnit], 0))
					,[intAccountId] = A.[intAccountId]
					,[dtmDate]		= ISNULL(CONVERT(DATE, A.[dtmDate]), '') 								
			FROM tblGLSummary A 
					INNER JOIN JournalDetail B 
					ON CONVERT(DATE, A.[dtmDate]) = CONVERT(DATE, B.[dtmDate]) AND A.[intAccountId] = B.[intAccountId] AND A.[strCode] = 'AA'			
			GROUP BY ISNULL(CONVERT(DATE, A.[dtmDate]), ''), A.[intAccountId]
		) AS GLDetailGrouped
WHERE tblGLSummary.[intAccountId] = GLDetailGrouped.[intAccountId] AND tblGLSummary.[strCode] = 'AA' AND 
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
	SELECT [dtmDate]		= ISNULL(A.[dtmDate], GETDATE())
		,[intAccountId]		= A.[intAccountId]
		,[dblDebit]			= CASE	WHEN [dblCredit] < 0 THEN ABS([dblCredit])
									WHEN [dblDebit] < 0 THEN 0
									ELSE [dblDebit] END 
		,[dblCredit]		= CASE	WHEN [dblDebit] < 0 THEN ABS([dblDebit])
									WHEN [dblCredit] < 0 THEN 0
									ELSE [dblCredit] END	
		,[dblDebitUnit]		= ISNULL(A.[dblDebitUnit], 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0)
		,[dblCreditUnit]	= ISNULL(A.[dblCreditUnit], 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0)
	FROM [dbo].tblGLDetail A
	WHERE A.strBatchId = @strBatchId
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
	,[strCode] = 'AA'
	,[intConcurrencyId] = 1
FROM JournalDetail A
WHERE NOT EXISTS 
		(
			SELECT TOP 1 1
			FROM tblGLSummary B
			WHERE ISNULL(CONVERT(DATE, A.[dtmDate]), '') = ISNULL(CONVERT(DATE, B.[dtmDate]), '') AND 
				  A.[intAccountId] = B.[intAccountId] AND B.[strCode] = 'AA'
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
INSERT INTO tblGLPostResults (strBatchId,intTransactionId,strTransactionId,strDescription,dtmDate)
	SELECT @strBatchId as strBatchId,intJournalId as intTransactionId,strJournalId as strTransactionId, strMessage as strDescription,GETDATE() as dtmDate
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
GO


--=====================================================================================================================================
-- 	SCRIPT EXECUTION 
---------------------------------------------------------------------------------------------------------------------------------------
--DECLARE @intCount AS INT

--EXEC [dbo].[usp_PostAuditAdjustment]
--			@Param	 = 'select intJournalId from tblGLJournal where strJournalId = ''AA-2''',				-- GENERATED BATCH Id
--			@ysnPost = 1,
--			@ysnRecap = 1,								-- WHEN SET TO 1, THEN IT WILL POPULATE tblGLPostRecap THAT CAN BE VIEWED VIA BUFFERED STORE IN SENCHA
--			@strBatchId = 'BATCH-AA1',							-- COMMA DELIMITED JOURNAL Id TO POST 
--			@strJournalType = 'Audit Adjustment',
--			@intUserId = 1,							-- USER Id THAT INITIATES POSTING
--			@successfulCount = @intCount OUTPUT		-- OUTPUT PARAMETER THAT RETURNS TOTAL NUMBER OF SUCCESSFUL RECORDS
				
--SELECT @intCount
	