
--=====================================================================================================================================
-- 	CREATE THE STORED PROCEDURE AFTER DELETING IT
---------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE usp_PostAuditAdjustment
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
	INSERT INTO #tmpPostJournals SELECT [intJournalID] FROM tblGLJournal	
	

--=====================================================================================================================================
-- 	UNPOSTING JOURNAL TRANSACTIONS
---------------------------------------------------------------------------------------------------------------------------------------
IF ISNULL(@ysnPost, 0) = 0
	BEGIN
		DECLARE @intCount AS INT
		
		SET @Param = (SELECT strJournalID FROM tblGLJournal WHERE intJournalID IN (SELECT intJournalID FROM #tmpPostJournals))
		EXEC [dbo].[usp_ReverseGLEntries] @strBatchID, @Param, @ysnRecap, 'AA', NULL, @intUserID, @intCount	OUT
		SET @successfulCount = @intCount
				
		IF(@intCount > 0)
		BEGIN
			UPDATE tblGLJournal SET ysnPosted = 0 WHERE intJournalID IN (SELECT intJournalID FROM #tmpPostJournals)
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
					'Unable to find an open fiscal year period to match the transaction date.' AS strMessage
				FROM tblGLJournal A 
				WHERE A.intJournalID IN (SELECT intJournalID FROM #tmpPostJournals) AND ISNULL([dbo].isOpenAccountingDate(A.dtmDate), 0) = 0  
				UNION
				SELECT DISTINCT A.intJournalID,
					'Unable to find an open fiscal year period to match the reverse date.' AS strMessage
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
				UNION
				SELECT DISTINCT A.intJournalID,
					'Retained Earnings is required.' AS strMessage
				FROM tblGLJournal A 
				WHERE 0 = CASE WHEN ISNULL((SELECT TOP 1 1 FROM tblGLFiscalYear WHERE dtmDateFrom <= A.dtmDate and dtmDateTo >= A.dtmDate),1) = 0 THEN 0 
							ELSE 
								CASE WHEN 
									ISNULL((SELECT TOP 1 1 FROM tblGLFiscalYear WHERE dtmDateFrom <= A.dtmDate and dtmDateTo >= A.dtmDate and intRetainAccount IS NULL),0) = 1 THEN 0
								ELSE 1
							END 
						END AND A.intJournalID IN (SELECT intJournalID FROM #tmpPostJournals)																
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
			,[strReference]			= 'AA Audit AdjustmentFY ' + CAST(YEAR(B.[dtmDate]) AS NVARCHAR(50))
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
			,[dblExchangeRate]		= 1
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
		WHERE B.[intJournalID] IN (SELECT [intJournalID] FROM #tmpValidJournals);
		
		
		SET @GJDates = (SELECT dtmDate FROM tblGLJournal WHERE intJournalID = (SELECT TOP 1 [intJournalID] FROM #tmpValidJournals))
		IF((SELECT ysnStatus FROM tblGLFiscalYear WHERE dtmDateFrom <= @GJDates AND dtmDateTo >= @GJDates) = 0)
		BEGIN
		
			-- ACCOUNT REVENUE AND EXPENSE
			WITH Accounts 
			AS 
			(
				SELECT A.[strAccountID], A.[intAccountID], A.[intAccountGroupID], B.[strAccountGroup], C.[dblLbsPerUnit]
				FROM tblGLAccount A LEFT JOIN tblGLAccountGroup B on A.intAccountGroupID = B.intAccountGroupID
									LEFT JOIN tblGLAccountUnit  C on C.intAccountUnitID  = A.intAccountUnitID
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
				,[strReference]			= 'AA Audit AdjustmentFY ' + CAST(YEAR(B.[dtmDate]) AS NVARCHAR(50))
				,[dtmTransactionDate]	= A.[dtmDate]
				,[dblDebit]				= CASE	WHEN [dblDebit] < 0 THEN ABS([dblDebit])
												WHEN [dblCredit] < 0 THEN 0
												ELSE [dblCredit] END
				,[dblCredit]			= CASE	WHEN [dblCredit] < 0 THEN ABS([dblCredit])
												WHEN [dblDebit] < 0 THEN 0
												ELSE [dblDebit] END 	
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
				,[strJournalLineDescription] = A.[strDescription]
				,[intJournalLineNo]		= A.intLineNo
				
			FROM [dbo].tblGLJournalDetail A 
				INNER JOIN [dbo].tblGLJournal B 
					ON A.[intJournalID] = B.[intJournalID]
				INNER JOIN [dbo].tblGLAccount C 
					ON A.[intAccountID] = C.[intAccountID]
				INNER JOIN [dbo].tblGLAccountGroup D 
					ON C.[intAccountGroupID] = D.[intAccountGroupID]
			WHERE (D.strAccountType = 'Revenue' OR D.strAccountType = 'Expense')
				AND B.[intJournalID] IN (SELECT [intJournalID] FROM #tmpValidJournals);
			
			-- ACCOUNT RETAINED EARNINGS
			SET @Debit = (SELECT SUM(dblDebit) as dblDebit FROM [dbo].tblGLJournalDetail A 
							INNER JOIN [dbo].tblGLJournal B 
								ON A.[intJournalID] = B.[intJournalID]
							INNER JOIN [dbo].tblGLAccount C 
								ON A.[intAccountID] = C.[intAccountID]
							INNER JOIN [dbo].tblGLAccountGroup D 
								ON C.[intAccountGroupID] = D.[intAccountGroupID]
						WHERE (D.strAccountType <> 'Revenue' AND D.strAccountType <> 'Expense')
							AND B.[intJournalID] IN (SELECT [intJournalID] FROM #tmpValidJournals))	
			SET @Credit = (SELECT SUM(dblCredit) as dblCredit FROM [dbo].tblGLJournalDetail A 
							INNER JOIN [dbo].tblGLJournal B 
								ON A.[intJournalID] = B.[intJournalID]
							INNER JOIN [dbo].tblGLAccount C 
								ON A.[intAccountID] = C.[intAccountID]
							INNER JOIN [dbo].tblGLAccountGroup D 
								ON C.[intAccountGroupID] = D.[intAccountGroupID]
						WHERE (D.strAccountType <> 'Revenue' AND D.strAccountType <> 'Expense')
							AND B.[intJournalID] IN (SELECT [intJournalID] FROM #tmpValidJournals))
			SET @DebitUnit = (SELECT SUM(dblDebitUnit) as dblDebitUnit FROM [dbo].tblGLJournalDetail A 
							INNER JOIN [dbo].tblGLJournal B 
								ON A.[intJournalID] = B.[intJournalID]
							INNER JOIN [dbo].tblGLAccount C 
								ON A.[intAccountID] = C.[intAccountID]
							INNER JOIN [dbo].tblGLAccountGroup D 
								ON C.[intAccountGroupID] = D.[intAccountGroupID]
						WHERE (D.strAccountType <> 'Revenue' AND D.strAccountType <> 'Expense')
							AND B.[intJournalID] IN (SELECT [intJournalID] FROM #tmpValidJournals))
			SET @CreditUnit = (SELECT SUM(dblCreditUnit) as dblCreditUnit FROM [dbo].tblGLJournalDetail A 
							INNER JOIN [dbo].tblGLJournal B 
								ON A.[intJournalID] = B.[intJournalID]
							INNER JOIN [dbo].tblGLAccount C 
								ON A.[intAccountID] = C.[intAccountID]
							INNER JOIN [dbo].tblGLAccountGroup D 
								ON C.[intAccountGroupID] = D.[intAccountGroupID]
						WHERE (D.strAccountType <> 'Revenue' AND D.strAccountType <> 'Expense')
							AND B.[intJournalID] IN (SELECT [intJournalID] FROM #tmpValidJournals))			
			
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
				SELECT A.[strAccountID], A.[intAccountID], A.[strDescription], A.[intAccountGroupID], B.[strAccountGroup], C.[dblLbsPerUnit]
				FROM tblGLAccount A LEFT JOIN tblGLAccountGroup B on A.intAccountGroupID = B.intAccountGroupID
									LEFT JOIN tblGLAccountUnit  C on C.intAccountUnitID  = A.intAccountUnitID
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
				 [strTransactionID]		= (SELECT TOP 1 strJournalID FROM tblGLJournal WHERE intJournalID = (SELECT TOP 1 [intJournalID] FROM #tmpValidJournals))
				,[intAccountID]			= (SELECT TOP 1 [intRetainAccount] FROM tblGLFiscalYear WHERE dtmDateFrom <= @GJDates AND dtmDateTo >= @GJDates)
				,[strDescription]		= (SELECT TOP 1 [strDescription] FROM Accounts WHERE [intAccountID] = (SELECT TOP 1 intRetainAccount FROM tblGLFiscalYear WHERE dtmDateFrom <= @GJDates AND dtmDateTo >= @GJDates))
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
				,[intUserID]			= @intUserID
				,[dtmDateEntered]		= GETDATE()
				,[strBatchID]			= @strBatchID
				,[strCode]				= A.[strSourceType]
				,[strModuleName]		= 'General Ledger'
				,[strTransactionForm]	= A.[strTransactionType]
				,[strJournalLineDescription] = NULL
				,[intJournalLineNo]		= NULL
				
			FROM [dbo].tblGLJournal A 
			WHERE A.[intJournalID] IN (SELECT TOP 1 [intJournalID] FROM #tmpValidJournals)
			
		END
		

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
			,[strReference]			= 'AA Audit AdjustmentFY ' + CAST(YEAR(B.[dtmDate]) AS NVARCHAR(50))
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
		WHERE B.[intJournalID] IN (SELECT [intJournalID] FROM #tmpValidJournals);
		
		
		SET @GJDates = (SELECT dtmDate FROM tblGLJournal WHERE intJournalID = (SELECT TOP 1 [intJournalID] FROM #tmpValidJournals))
		IF((SELECT ysnStatus FROM tblGLFiscalYear WHERE dtmDateFrom <= @GJDates AND dtmDateTo >= @GJDates) = 0)
		BEGIN
		
			-- ACCOUNT REVENUE AND EXPENSE
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
				,[strReference]			= 'AA Audit AdjustmentFY ' + CAST(YEAR(B.[dtmDate]) AS NVARCHAR(50))
				,[dtmTransactionDate]	= A.[dtmDate]
				,[dblDebit]				= CASE	WHEN [dblDebit] < 0 THEN ABS([dblDebit])
												WHEN [dblCredit] < 0 THEN 0
												ELSE [dblCredit] END
				,[dblCredit]			= CASE	WHEN [dblCredit] < 0 THEN ABS([dblCredit])
												WHEN [dblDebit] < 0 THEN 0
												ELSE [dblDebit] END 	
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
			FROM [dbo].tblGLJournalDetail A 
				INNER JOIN [dbo].tblGLJournal B 
					ON A.[intJournalID] = B.[intJournalID]
				INNER JOIN [dbo].tblGLAccount C 
					ON A.[intAccountID] = C.[intAccountID]
				INNER JOIN [dbo].tblGLAccountGroup D 
					ON C.[intAccountGroupID] = D.[intAccountGroupID]
			WHERE (D.strAccountType = 'Revenue' OR D.strAccountType = 'Expense')
				AND B.[intJournalID] IN (SELECT [intJournalID] FROM #tmpValidJournals);
			
			-- ACCOUNT RETAINED EARNINGS
			SET @Debit = (SELECT SUM(dblDebit) as dblDebit FROM [dbo].tblGLJournalDetail A 
							INNER JOIN [dbo].tblGLJournal B 
								ON A.[intJournalID] = B.[intJournalID]
							INNER JOIN [dbo].tblGLAccount C 
								ON A.[intAccountID] = C.[intAccountID]
							INNER JOIN [dbo].tblGLAccountGroup D 
								ON C.[intAccountGroupID] = D.[intAccountGroupID]
						WHERE (D.strAccountType <> 'Revenue' AND D.strAccountType <> 'Expense')
							AND B.[intJournalID] IN (SELECT [intJournalID] FROM #tmpValidJournals))	
			SET @Credit = (SELECT SUM(dblCredit) as dblCredit FROM [dbo].tblGLJournalDetail A 
							INNER JOIN [dbo].tblGLJournal B 
								ON A.[intJournalID] = B.[intJournalID]
							INNER JOIN [dbo].tblGLAccount C 
								ON A.[intAccountID] = C.[intAccountID]
							INNER JOIN [dbo].tblGLAccountGroup D 
								ON C.[intAccountGroupID] = D.[intAccountGroupID]
						WHERE (D.strAccountType <> 'Revenue' AND D.strAccountType <> 'Expense')
							AND B.[intJournalID] IN (SELECT [intJournalID] FROM #tmpValidJournals))
			SET @DebitUnit = (SELECT SUM(dblDebitUnit) as dblDebitUnit FROM [dbo].tblGLJournalDetail A 
							INNER JOIN [dbo].tblGLJournal B 
								ON A.[intJournalID] = B.[intJournalID]
							INNER JOIN [dbo].tblGLAccount C 
								ON A.[intAccountID] = C.[intAccountID]
							INNER JOIN [dbo].tblGLAccountGroup D 
								ON C.[intAccountGroupID] = D.[intAccountGroupID]
						WHERE (D.strAccountType <> 'Revenue' AND D.strAccountType <> 'Expense')
							AND B.[intJournalID] IN (SELECT [intJournalID] FROM #tmpValidJournals))
			SET @CreditUnit = (SELECT SUM(dblCreditUnit) as dblCreditUnit FROM [dbo].tblGLJournalDetail A 
							INNER JOIN [dbo].tblGLJournal B 
								ON A.[intJournalID] = B.[intJournalID]
							INNER JOIN [dbo].tblGLAccount C 
								ON A.[intAccountID] = C.[intAccountID]
							INNER JOIN [dbo].tblGLAccountGroup D 
								ON C.[intAccountGroupID] = D.[intAccountGroupID]
						WHERE (D.strAccountType <> 'Revenue' AND D.strAccountType <> 'Expense')
							AND B.[intJournalID] IN (SELECT [intJournalID] FROM #tmpValidJournals))			
			
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
				SELECT A.[strAccountID], A.[intAccountID], A.[strDescription], A.[intAccountGroupID], B.[strAccountGroup], C.[dblLbsPerUnit]
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
				 [strTransactionID]		= (SELECT TOP 1 strJournalID FROM tblGLJournal WHERE intJournalID = (SELECT TOP 1 [intJournalID] FROM #tmpValidJournals))
				,[intTransactionID]		= (SELECT TOP 1 [intJournalID] FROM #tmpValidJournals)
				,[intAccountID]			= (SELECT TOP 1 [intRetainAccount] FROM tblGLFiscalYear WHERE dtmDateFrom <= @GJDates AND dtmDateTo >= @GJDates)
				,[strAccountID]			= (SELECT TOP 1 [strAccountID] FROM Accounts WHERE [intAccountID] = (SELECT TOP 1 intRetainAccount FROM tblGLFiscalYear WHERE dtmDateFrom <= @GJDates AND dtmDateTo >= @GJDates))
				,[strAccountGroup]		= (SELECT [strAccountGroup] FROM Accounts WHERE [intAccountID] = (SELECT TOP 1 [intRetainAccount] FROM tblGLFiscalYear WHERE dtmDateFrom <= @GJDates AND dtmDateTo >= @GJDates))
				,[strDescription]		= (SELECT TOP 1 [strDescription] FROM Accounts WHERE [intAccountID] = (SELECT TOP 1 intRetainAccount FROM tblGLFiscalYear WHERE dtmDateFrom <= @GJDates AND dtmDateTo >= @GJDates))
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
				,[intUserID]			= @intUserID
				,[dtmDateEntered]		= GETDATE()
				,[strBatchID]			= @strBatchID
				,[strCode]				= A.[strSourceType]
				,[strModuleName]		= 'General Ledger'
				,[strTransactionForm]	= A.[strTransactionType]
			FROM [dbo].tblGLJournal A 
			WHERE A.[intJournalID] IN (SELECT TOP 1 [intJournalID] FROM #tmpValidJournals)
			
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
			,[intAccountID]		= A.[intAccountID]
			,[dblDebit]			= CASE	WHEN [dblCredit] < 0 THEN ABS([dblCredit])
										WHEN [dblDebit] < 0 THEN 0
										ELSE [dblDebit] END 
			,[dblCredit]		= CASE	WHEN [dblDebit] < 0 THEN ABS([dblDebit])
										WHEN [dblCredit] < 0 THEN 0
										ELSE [dblCredit] END
			,[dblDebitUnit]		= [dblDebitUnit]
			,[dblCreditUnit]	= [dblDebitUnit]	
	FROM [dbo].tblGLDetail A
	WHERE A.strBatchID = @strBatchID
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
					,[intAccountID] = A.[intAccountID]
					,[dtmDate]		= ISNULL(CONVERT(DATE, A.[dtmDate]), '') 								
			FROM tblGLSummary A 
					INNER JOIN JournalDetail B 
					ON CONVERT(DATE, A.[dtmDate]) = CONVERT(DATE, B.[dtmDate]) AND A.[intAccountID] = B.[intAccountID] AND A.[strCode] = 'AA'			
			GROUP BY ISNULL(CONVERT(DATE, A.[dtmDate]), ''), A.[intAccountID]
		) AS GLDetailGrouped
WHERE tblGLSummary.[intAccountID] = GLDetailGrouped.[intAccountID] AND tblGLSummary.[strCode] = 'AA' AND 
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
	SELECT [dtmDate]		= ISNULL(A.[dtmDate], GETDATE())
		,[intAccountID]		= A.[intAccountID]
		,[dblDebit]			= CASE	WHEN [dblCredit] < 0 THEN ABS([dblCredit])
									WHEN [dblDebit] < 0 THEN 0
									ELSE [dblDebit] END 
		,[dblCredit]		= CASE	WHEN [dblDebit] < 0 THEN ABS([dblDebit])
									WHEN [dblCredit] < 0 THEN 0
									ELSE [dblCredit] END	
		,[dblDebitUnit]		= ISNULL(A.[dblDebitUnit], 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountID] = A.[intAccountID]), 0)
		,[dblCreditUnit]	= ISNULL(A.[dblCreditUnit], 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountID] = A.[intAccountID]), 0)
	FROM [dbo].tblGLDetail A
	WHERE A.strBatchID = @strBatchID
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
	,[strCode] = 'AA'
	,[intConcurrencyId] = 1
FROM JournalDetail A
WHERE NOT EXISTS 
		(
			SELECT TOP 1 1
			FROM tblGLSummary B
			WHERE ISNULL(CONVERT(DATE, A.[dtmDate]), '') = ISNULL(CONVERT(DATE, B.[dtmDate]), '') AND 
				  A.[intAccountID] = B.[intAccountID] AND B.[strCode] = 'AA'
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
GO


--=====================================================================================================================================
-- 	SCRIPT EXECUTION 
---------------------------------------------------------------------------------------------------------------------------------------
--DECLARE @intCount AS INT

--EXEC [dbo].[usp_PostAuditAdjustment]
--			@Param	 = 'select intJournalID from tblGLJournal where strJournalID = ''AA-2''',				-- GENERATED BATCH ID
--			@ysnPost = 1,
--			@ysnRecap = 1,								-- WHEN SET TO 1, THEN IT WILL POPULATE tblGLPostRecap THAT CAN BE VIEWED VIA BUFFERED STORE IN SENCHA
--			@strBatchID = 'BATCH-AA1',							-- COMMA DELIMITED JOURNAL ID TO POST 
--			@strJournalType = 'Audit Adjustment',
--			@intUserID = 1,							-- USER ID THAT INITIATES POSTING
--			@successfulCount = @intCount OUTPUT		-- OUTPUT PARAMETER THAT RETURNS TOTAL NUMBER OF SUCCESSFUL RECORDS
				
--SELECT @intCount
	