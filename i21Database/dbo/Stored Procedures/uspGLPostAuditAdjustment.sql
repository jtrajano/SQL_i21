--=====================================================================================================================================
-- 	CREATE THE STORED PROCEDURE AFTER DELETING IT
---------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[uspGLPostAuditAdjustment]
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
DECLARE @tmpPostJournals JournalIDTableType
DECLARE @tmpValidJournals JournalIDTableType

DECLARE @Debit NUMERIC(18, 6)
DECLARE @Credit NUMERIC(18, 6)
DECLARE @DebitUnit NUMERIC(18, 6)
DECLARE @CreditUnit NUMERIC(18, 6)
DECLARE @GJDates DATETIME

--=====================================================================================================================================
-- 	POPULATE JOURNALS TO POST TEMPORARY TABLE
---------------------------------------------------------------------------------------------------------------------------------------

IF (ISNULL(@Param, '') <> '') 
	INSERT INTO @tmpPostJournals EXEC (@Param)
ELSE
	INSERT INTO @tmpPostJournals SELECT [intJournalId] FROM tblGLJournal	
	

--=====================================================================================================================================
-- 	UNPOSTING JOURNAL TRANSACTIONS
---------------------------------------------------------------------------------------------------------------------------------------
IF ISNULL(@ysnPost, 0) = 0
	BEGIN
		DECLARE @intCount AS INT
		
		SET @Param = (SELECT strJournalId FROM tblGLJournal WHERE intJournalId IN (SELECT intJournalId FROM @tmpPostJournals))
		EXEC [dbo].[uspGLReverseGLEntries] @strBatchId, @Param, @ysnRecap, 'AA', NULL, @intEntityId, @intCount	OUT
		SET @successfulCount = @intCount
				
		IF(@intCount > 0)
		BEGIN
			UPDATE tblGLJournal SET ysnPosted = 0 WHERE intJournalId IN (SELECT intJournalId FROM @tmpPostJournals)
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
					SELECT @strBatchId as strBatchId
							,j.intJournalId as intTransactionId
							,j.strJournalId as strTransactionId
							,strMessage as strDescription
							,GETDATE() as dtmDate
							,@intEntityId
							,@strJournalType
					FROM dbo.[fnGLGetPostErrors] (@tmpPostJournals,@strJournalType, @ysnPost)
					OUTER APPLY(SELECT TOP 1 B.intJournalId,B.strJournalId FROM @tmpPostJournals A JOIN tblGLJournal B ON A.intJournalId = B.intJournalId) j
	END

IF @@ERROR <> 0	GOTO Post_Rollback;

	
--=====================================================================================================================================
-- 	POPULATE VALID JOURNALS TEMPORARY TABLE
---------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO @tmpValidJournals
	SELECT DISTINCT A.[intJournalId]
	FROM tblGLJournal A 
	WHERE	A.[intJournalId] IN (SELECT B.intJournalId FROM @tmpPostJournals  B
						WHERE B.intJournalId NOT IN (SELECT intTransactionId FROM tblGLPostResult WHERE strBatchId = @strBatchId GROUP BY intTransactionId)) 
		AND
		A.[ysnPosted] = 0 AND
		A.[strJournalType] = @strJournalType

IF @@ERROR <> 0	GOTO Post_Rollback;

IF NOT EXISTS(SELECT TOP 1 1 FROM @tmpValidJournals)
	BEGIN
		GOTO Post_Commit;
	END


--=====================================================================================================================================
-- 	CHECK IF THE PROCESS IS RECAP OR NOT
---------------------------------------------------------------------------------------------------------------------------------------
Post_Transaction:

DECLARE @intCurrencyId	INT
DECLARE @dblDailyRate	NUMERIC (18,6)
DECLARE @GLEntries RecapTableType

IF ISNULL(@ysnRecap, 0) = 0
	BEGIN			
	
		SET @intCurrencyId		= (SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE intCurrencyID = (CASE WHEN (SELECT TOP 1 strValue FROM tblSMPreferences WHERE strPreference = 'defaultCurrency') > 0 
																		THEN (SELECT TOP 1 strValue FROM tblSMPreferences WHERE strPreference = 'defaultCurrency')
																		ELSE (SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE strCurrency = 'USD') END))
		SET @dblDailyRate		= (SELECT TOP 1 dblDailyRate FROM tblSMCurrency WHERE intCurrencyID = @intCurrencyId);
								
		INSERT INTO @GLEntries (
			 [strTransactionId]
			,[intTransactionId]
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
			,[strJournalLineDescription]
			,[intJournalLineNo]			
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]
		)
		SELECT 
			 [strTransactionId]		= B.[strJournalId]
			,[intTransactionId]		= B.[intJournalId]
			,[intAccountId]			= A.[intAccountId]
			,[strDescription]		= B.[strDescription]
			,[strReference]			= 'AA Audit AdjustmentFY ' + CAST(YEAR(B.[dtmDate]) AS NVARCHAR(50))
			,[dtmTransactionDate]	= A.[dtmDate]
			,[dblDebit]				= CASE	WHEN [dblCredit] < 0 THEN ABS([dblCredit])
											WHEN [dblDebit] < 0 THEN 0
											ELSE [dblDebit] END 
			,[dblCredit]			= CASE	WHEN [dblDebit] < 0 THEN ABS([dblDebit])
											WHEN [dblCredit] < 0 THEN 0
											ELSE [dblCredit] END	
			,[dblDebitUnit]			= ISNULL(A.[dblDebitUnit], 0)
			,[dblCreditUnit]		= ISNULL(A.[dblCreditUnit], 0)
			,[dtmDate]				= ISNULL(B.[dtmDate], GETDATE())
			,[ysnIsUnposted]		= 0 
			,[intConcurrencyId]		= 1
			,[intCurrencyId]		= @intCurrencyId
			,[dblExchangeRate]		= @dblDailyRate
			,[intUserId]			= 0
			,[intEntityId]			= @intEntityId
			,[dtmDateEntered]		= GETDATE()
			,[strBatchId]			= @strBatchId
			,[strCode]				= 'AA'			
			,[strJournalLineDescription] = A.[strDescription]
			,[intJournalLineNo]		= A.[intJournalDetailId]			
			,[strTransactionType]	= B.[strJournalType]
			,[strTransactionForm]	= B.[strTransactionType]
			,[strModuleName]		= 'General Ledger'
						
		FROM [dbo].tblGLJournalDetail A INNER JOIN [dbo].tblGLJournal B 
			ON A.[intJournalId] = B.[intJournalId]
		WHERE B.[intJournalId] IN (SELECT [intJournalId] FROM @tmpValidJournals);
		
		
		SET @GJDates = (SELECT dtmDate FROM tblGLJournal WHERE intJournalId = (SELECT TOP 1 [intJournalId] FROM @tmpValidJournals))
		IF((SELECT ysnStatus FROM tblGLFiscalYear WHERE dtmDateFrom <= @GJDates AND dtmDateTo >= @GJDates) = 0)
		BEGIN
		
			-- ACCOUNT REVENUE AND EXPENSE
			WITH Accounts 
			AS 
			(
				SELECT A.[strAccountId], A.[intAccountId], A.[intAccountGroupId], B.[strAccountGroup]
				FROM tblGLAccount A LEFT JOIN tblGLAccountGroup B on A.intAccountGroupId = B.intAccountGroupId
			)
			INSERT INTO @GLEntries (
				 [strTransactionId]
				,[intTransactionId]
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
				,[strJournalLineDescription]
				,[intJournalLineNo]
				,[strTransactionType]
				,[strTransactionForm]
				,[strModuleName]				
			)
			SELECT
				 [strTransactionId]		= B.[strJournalId]
				,[intTransactionId]		= B.[intJournalId]
				,[intAccountId]			= A.[intAccountId]
				,[strDescription]		= B.[strDescription]
				,[strReference]			= 'AA Audit AdjustmentFY ' + CAST(YEAR(B.[dtmDate]) AS NVARCHAR(50))
				,[dtmTransactionDate]	= A.[dtmDate]
				,[dblDebit]				= CASE	WHEN [dblDebit] < 0 THEN ABS([dblDebit])
												WHEN [dblCredit] < 0 THEN 0
												ELSE [dblCredit] END
				,[dblCredit]			= CASE	WHEN [dblCredit] < 0 THEN ABS([dblCredit])
												WHEN [dblDebit] < 0 THEN 0
												ELSE [dblDebit] END 	
				,[dblDebitUnit]			= ISNULL(A.[dblDebitUnit], 0)
				,[dblCreditUnit]		= ISNULL(A.[dblCreditUnit], 0)
				,[dtmDate]				= ISNULL(B.[dtmDate], GETDATE())
				,[ysnIsUnposted]		= 0 
				,[intConcurrencyId]		= 1
				,[intCurrencyId]		= @intCurrencyId
				,[dblExchangeRate]		= @dblDailyRate
				,[intUserId]			= 0
				,[intEntityId]			= @intEntityId
				,[dtmDateEntered]		= GETDATE()
				,[strBatchId]			= @strBatchId
				,[strCode]				= 'AA'				
				,[strJournalLineDescription] = A.[strDescription]
				,[intJournalLineNo]		= A.[intJournalDetailId]				
				,[strTransactionType]	= B.[strJournalType]
				,[strTransactionForm]	= B.[strTransactionType]
				,[strModuleName]		= 'General Ledger'
				
			FROM [dbo].tblGLJournalDetail A 
				INNER JOIN [dbo].tblGLJournal B 
					ON A.[intJournalId] = B.[intJournalId]
				INNER JOIN [dbo].tblGLAccount C 
					ON A.[intAccountId] = C.[intAccountId]
				INNER JOIN [dbo].tblGLAccountGroup D 
					ON C.[intAccountGroupId] = D.[intAccountGroupId]
			WHERE (D.strAccountType = 'Revenue' OR D.strAccountType = 'Expense')
				AND B.[intJournalId] IN (SELECT [intJournalId] FROM @tmpValidJournals);
			
			-- ACCOUNT RETAINED EARNINGS
			SET @Debit = (SELECT SUM(dblDebit) as dblDebit FROM [dbo].tblGLJournalDetail A 
							INNER JOIN [dbo].tblGLJournal B 
								ON A.[intJournalId] = B.[intJournalId]
							INNER JOIN [dbo].tblGLAccount C 
								ON A.[intAccountId] = C.[intAccountId]
							INNER JOIN [dbo].tblGLAccountGroup D 
								ON C.[intAccountGroupId] = D.[intAccountGroupId]
						WHERE (D.strAccountType <> 'Revenue' AND D.strAccountType <> 'Expense')
							AND B.[intJournalId] IN (SELECT [intJournalId] FROM @tmpValidJournals))	
			SET @Credit = (SELECT SUM(dblCredit) as dblCredit FROM [dbo].tblGLJournalDetail A 
							INNER JOIN [dbo].tblGLJournal B 
								ON A.[intJournalId] = B.[intJournalId]
							INNER JOIN [dbo].tblGLAccount C 
								ON A.[intAccountId] = C.[intAccountId]
							INNER JOIN [dbo].tblGLAccountGroup D 
								ON C.[intAccountGroupId] = D.[intAccountGroupId]
						WHERE (D.strAccountType <> 'Revenue' AND D.strAccountType <> 'Expense')
							AND B.[intJournalId] IN (SELECT [intJournalId] FROM @tmpValidJournals))
			SET @DebitUnit = (SELECT SUM(dblDebitUnit) as dblDebitUnit FROM [dbo].tblGLJournalDetail A 
							INNER JOIN [dbo].tblGLJournal B 
								ON A.[intJournalId] = B.[intJournalId]
							INNER JOIN [dbo].tblGLAccount C 
								ON A.[intAccountId] = C.[intAccountId]
							INNER JOIN [dbo].tblGLAccountGroup D 
								ON C.[intAccountGroupId] = D.[intAccountGroupId]
						WHERE (D.strAccountType <> 'Revenue' AND D.strAccountType <> 'Expense')
							AND B.[intJournalId] IN (SELECT [intJournalId] FROM @tmpValidJournals))
			SET @CreditUnit = (SELECT SUM(dblCreditUnit) as dblCreditUnit FROM [dbo].tblGLJournalDetail A 
							INNER JOIN [dbo].tblGLJournal B 
								ON A.[intJournalId] = B.[intJournalId]
							INNER JOIN [dbo].tblGLAccount C 
								ON A.[intAccountId] = C.[intAccountId]
							INNER JOIN [dbo].tblGLAccountGroup D 
								ON C.[intAccountGroupId] = D.[intAccountGroupId]
						WHERE (D.strAccountType <> 'Revenue' AND D.strAccountType <> 'Expense')
							AND B.[intJournalId] IN (SELECT [intJournalId] FROM @tmpValidJournals))			
			
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
				SELECT A.[strAccountId], A.[intAccountId], A.[strDescription], A.[intAccountGroupId], B.[strAccountGroup]
				FROM tblGLAccount A LEFT JOIN tblGLAccountGroup B on A.intAccountGroupId = B.intAccountGroupId
			)
			INSERT INTO @GLEntries (
				 [strTransactionId]
				,[intTransactionId]
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
				,[strJournalLineDescription]
				,[intJournalLineNo]				
				,[strTransactionType]
				,[strTransactionForm]
				,[strModuleName]
			)
			SELECT
				 [strTransactionId]		= (SELECT TOP 1 strJournalId FROM tblGLJournal WHERE intJournalId = (SELECT TOP 1 [intJournalId] FROM @tmpValidJournals))
				,[intTransactionId]		= (SELECT TOP 1 intJournalId FROM tblGLJournal WHERE intJournalId = (SELECT TOP 1 [intJournalId] FROM @tmpValidJournals))
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
				,[intCurrencyId]		= @intCurrencyId
				,[dblExchangeRate]		= @dblDailyRate
				,[intUserId]			= 0
				,[intEntityId]			= @intEntityId
				,[dtmDateEntered]		= GETDATE()
				,[strBatchId]			= @strBatchId
				,[strCode]				= 'AA'				
				,[strJournalLineDescription] = ''
				,[intJournalLineNo]		= 0			
				,[strTransactionType]	= A.[strJournalType]
				,[strTransactionForm]	= A.[strTransactionType]
				,[strModuleName]		= 'General Ledger'
				
			FROM [dbo].tblGLJournal A 
			WHERE A.[intJournalId] IN (SELECT TOP 1 [intJournalId] FROM @tmpValidJournals)
			
		END
		
		EXEC uspGLBookEntries @GLEntries,1

		IF @@ERROR <> 0	GOTO Post_Rollback;
	END
ELSE
	BEGIN
		-- DELETE Results 1 DAYS OLDER	
		DELETE tblGLPostRecap WHERE dtmDateEntered < DATEADD(day, -1, GETDATE()) and intEntityId = @intEntityId;
		
		SET @intCurrencyId		= (SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE intCurrencyID = (CASE WHEN (SELECT TOP 1 strValue FROM tblSMPreferences WHERE strPreference = 'defaultCurrency') > 0 
																		THEN (SELECT TOP 1 strValue FROM tblSMPreferences WHERE strPreference = 'defaultCurrency')
																		ELSE (SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE strCurrency = 'USD') END))
		SET @dblDailyRate		= (SELECT TOP 1 dblDailyRate FROM tblSMCurrency WHERE intCurrencyID = @intCurrencyId);
		
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
			,[dblDebitUnit]			= ISNULL(A.[dblDebitUnit], 0)
			,[dblCreditUnit]		= ISNULL(A.[dblCreditUnit], 0)
			,[dtmDate]				= ISNULL(B.[dtmDate], GETDATE())
			,[ysnIsUnposted]		= 0 
			,[intConcurrencyId]		= 1
			,[dblExchangeRate]		= @dblDailyRate
			,[intUserId]			= 0
			,[intEntityId]			= @intEntityId
			,[dtmDateEntered]		= GETDATE()
			,[strBatchId]			= @strBatchId
			,[strCode]				= 'AA'
			,[strTransactionType]	= B.[strJournalType]
			,[strTransactionForm]	= B.[strTransactionType]			
			,[strModuleName]		= 'General Ledger'			
		FROM [dbo].tblGLJournalDetail A INNER JOIN [dbo].tblGLJournal B 
			ON A.[intJournalId] = B.[intJournalId]
		WHERE B.[intJournalId] IN (SELECT [intJournalId] FROM @tmpValidJournals);
		
		
		SET @GJDates = (SELECT dtmDate FROM tblGLJournal WHERE intJournalId = (SELECT TOP 1 [intJournalId] FROM @tmpValidJournals))
		IF((SELECT ysnStatus FROM tblGLFiscalYear WHERE dtmDateFrom <= @GJDates AND dtmDateTo >= @GJDates) = 0)
		BEGIN
		
			-- ACCOUNT REVENUE AND EXPENSE
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
				,[dblDebitUnit]			= ISNULL(A.[dblDebitUnit], 0)
				,[dblCreditUnit]		= ISNULL(A.[dblCreditUnit], 0)
				,[dtmDate]				= ISNULL(B.[dtmDate], GETDATE())
				,[ysnIsUnposted]		= 0 
				,[intConcurrencyId]		= 1
				,[dblExchangeRate]		= @dblDailyRate
				,[intUserId]			= 0
				,[intEntityId]			= @intEntityId
				,[dtmDateEntered]		= GETDATE()
				,[strBatchId]			= @strBatchId
				,[strCode]				= 'AA'
				,[strTransactionType]	= B.[strJournalType]
				,[strTransactionForm]	= B.[strTransactionType]	
				,[strModuleName]		= 'General Ledger'
			FROM [dbo].tblGLJournalDetail A 
				INNER JOIN [dbo].tblGLJournal B 
					ON A.[intJournalId] = B.[intJournalId]
				INNER JOIN [dbo].tblGLAccount C 
					ON A.[intAccountId] = C.[intAccountId]
				INNER JOIN [dbo].tblGLAccountGroup D 
					ON C.[intAccountGroupId] = D.[intAccountGroupId]
			WHERE (D.strAccountType = 'Revenue' OR D.strAccountType = 'Expense')
				AND B.[intJournalId] IN (SELECT [intJournalId] FROM @tmpValidJournals);
			
			-- ACCOUNT RETAINED EARNINGS
			SET @Debit = (SELECT SUM(dblDebit) as dblDebit FROM [dbo].tblGLJournalDetail A 
							INNER JOIN [dbo].tblGLJournal B 
								ON A.[intJournalId] = B.[intJournalId]
							INNER JOIN [dbo].tblGLAccount C 
								ON A.[intAccountId] = C.[intAccountId]
							INNER JOIN [dbo].tblGLAccountGroup D 
								ON C.[intAccountGroupId] = D.[intAccountGroupId]
						WHERE (D.strAccountType <> 'Revenue' AND D.strAccountType <> 'Expense')
							AND B.[intJournalId] IN (SELECT [intJournalId] FROM @tmpValidJournals))	
			SET @Credit = (SELECT SUM(dblCredit) as dblCredit FROM [dbo].tblGLJournalDetail A 
							INNER JOIN [dbo].tblGLJournal B 
								ON A.[intJournalId] = B.[intJournalId]
							INNER JOIN [dbo].tblGLAccount C 
								ON A.[intAccountId] = C.[intAccountId]
							INNER JOIN [dbo].tblGLAccountGroup D 
								ON C.[intAccountGroupId] = D.[intAccountGroupId]
						WHERE (D.strAccountType <> 'Revenue' AND D.strAccountType <> 'Expense')
							AND B.[intJournalId] IN (SELECT [intJournalId] FROM @tmpValidJournals))
			SET @DebitUnit = (SELECT SUM(dblDebitUnit) as dblDebitUnit FROM [dbo].tblGLJournalDetail A 
							INNER JOIN [dbo].tblGLJournal B 
								ON A.[intJournalId] = B.[intJournalId]
							INNER JOIN [dbo].tblGLAccount C 
								ON A.[intAccountId] = C.[intAccountId]
							INNER JOIN [dbo].tblGLAccountGroup D 
								ON C.[intAccountGroupId] = D.[intAccountGroupId]
						WHERE (D.strAccountType <> 'Revenue' AND D.strAccountType <> 'Expense')
							AND B.[intJournalId] IN (SELECT [intJournalId] FROM @tmpValidJournals))
			SET @CreditUnit = (SELECT SUM(dblCreditUnit) as dblCreditUnit FROM [dbo].tblGLJournalDetail A 
							INNER JOIN [dbo].tblGLJournal B 
								ON A.[intJournalId] = B.[intJournalId]
							INNER JOIN [dbo].tblGLAccount C 
								ON A.[intAccountId] = C.[intAccountId]
							INNER JOIN [dbo].tblGLAccountGroup D 
								ON C.[intAccountGroupId] = D.[intAccountGroupId]
						WHERE (D.strAccountType <> 'Revenue' AND D.strAccountType <> 'Expense')
							AND B.[intJournalId] IN (SELECT [intJournalId] FROM @tmpValidJournals))			
			
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
				SELECT A.[strAccountId], A.[intAccountId], A.[strDescription], A.[intAccountGroupId], B.[strAccountGroup]
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
				 [strTransactionId]		= (SELECT TOP 1 strJournalId FROM tblGLJournal WHERE intJournalId = (SELECT TOP 1 [intJournalId] FROM @tmpValidJournals))
				,[intTransactionId]		= (SELECT TOP 1 [intJournalId] FROM @tmpValidJournals)
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
				,[dblExchangeRate]		= @dblDailyRate
				,[intUserId]			= 0
				,[intEntityId]			= @intEntityId
				,[dtmDateEntered]		= GETDATE()
				,[strBatchId]			= @strBatchId
				,[strCode]				= 'AA'
				,[strTransactionType]	= A.[strJournalType]
				,[strTransactionForm]	= A.[strTransactionType]
				,[strModuleName]		= 'General Ledger'				
			FROM [dbo].tblGLJournal A 
			WHERE A.[intJournalId] IN (SELECT TOP 1 [intJournalId] FROM @tmpValidJournals)
			
			END
				
		IF @@ERROR <> 0	GOTO Post_Rollback;
		
		
		IF((SELECT COUNT(*) FROM @tmpValidJournals) > 1)
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
				,[strTransactionType]
				,[strTransactionForm]
				,[strModuleName]				
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
				,[strTransactionType]
				,[strTransactionForm]		
				,[strModuleName]				
			FROM [dbo].tblGLPostRecap A
			WHERE A.[strBatchId] = @strBatchId and A.[intEntityId] = @intEntityId
			GROUP BY [strTransactionId],[intTransactionId],[dtmDate],[dblExchangeRate],[dtmDateEntered],[ysnIsUnposted],[intUserId],[intEntityId],[strBatchId],[strCode],[strTransactionType],[strTransactionForm],[strModuleName]

			IF @@ERROR <> 0	GOTO Post_Rollback;
					
		END
		

		GOTO Post_Commit;
	END

IF @@ERROR <> 0	GOTO Post_Rollback;


UPDATE tblGLJournal
SET [ysnPosted] = 1
	,[dtmPosted] = GETDATE()
WHERE [intJournalId] IN (SELECT [intJournalId] FROM @tmpValidJournals);

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
		WHERE A.intJournalId IN (SELECT intJournalId FROM @tmpValidJournals)
	) B

IF @@ERROR <> 0	GOTO Post_Rollback;


--=====================================================================================================================================
-- 	RETURN TOTAL NUMBER OF VALID JOURNALS
---------------------------------------------------------------------------------------------------------------------------------------
SET @successfulCount = ISNULL(@successfulCount,0) + (SELECT COUNT(*) FROM @tmpValidJournals)


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
	