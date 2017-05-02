CREATE PROCEDURE [dbo].[uspGLPostJournal]
	@Param				AS NVARCHAR(MAX)	= '',	
	@ysnPost			AS BIT				= 0,
	@ysnRecap			AS BIT				= 0,
	@strBatchId			AS NVARCHAR(100)	= '',	
	@strJournalType		AS NVARCHAR(30)		= '',
	@intEntityId		AS INT				= 1,
	@applyCurrentRate	AS BIT				= 1,
	@successfulCount	AS INT				= 0 OUTPUT
	
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN TRANSACTION;

--=====================================================================================================================================
-- 	POPULATE JOURNALS TO POST TEMPORARY TABLE
---------------------------------------------------------------------------------------------------------------------------------------
DECLARE @tmpPostJournals JournalIDTableType
DECLARE @currentDateTime DATETIME =  GETDATE()

IF (ISNULL(@Param, '') <> '') 
	INSERT INTO @tmpPostJournals EXEC (@Param)
ELSE
	INSERT INTO @tmpPostJournals SELECT [intJournalId] FROM tblGLJournal	
	

--=====================================================================================================================================
-- 	UNPOSTING JOURNAL TRANSACTIONS ysnPost = 0
---------------------------------------------------------------------------------------------------------------------------------------
IF ISNULL(@ysnPost, 0) = 0
	BEGIN
		DECLARE @intCount AS INT
		
		IF ISNULL(@ysnRecap, 0) = 0 -- ysnRecap = 0
			BEGIN
				-- DELETE Results 1 DAY OLDER	
				DELETE tblGLPostResult WHERE dtmDate < DATEADD(day, -1, GETDATE())
				
				INSERT INTO tblGLPostResult (strBatchId,intTransactionId,strTransactionId,strDescription,dtmDate,intEntityId,strTransactionType)
					SELECT @strBatchId as strBatchId
							,j.intJournalId as intTransactionId
							,j.strJournalId as strTransactionId
							,strMessage as strDescription
							,GETDATE() as dtmDate
							,@intEntityId
							,@strJournalType
					FROM dbo.[fnGLGetPostErrors] (@tmpPostJournals,@strJournalType,@ysnPost)
					OUTER APPLY(SELECT TOP 1 B.intJournalId,B.strJournalId FROM @tmpPostJournals A JOIN tblGLJournal B ON A.intJournalId = B.intJournalId) j
			END

		IF @@ERROR <> 0	GOTO Post_Rollback;

		IF (NOT EXISTS(SELECT TOP 1 1 FROM tblGLPostResult WHERE strBatchId = @strBatchId))
			BEGIN
				SET @Param = (SELECT strJournalId FROM tblGLJournal WHERE intJournalId IN (SELECT intJournalId FROM @tmpPostJournals))
				EXEC [dbo].[uspGLReverseGLEntries] @strBatchId,@Param, @ysnRecap, 'GJ', NULL, @intEntityId, @intCount	OUT
				SET @successfulCount = @intCount
				
				IF(@intCount > 0)
				BEGIN
					UPDATE tblGLJournal SET ysnPosted = 0 WHERE intJournalId IN (SELECT intJournalId FROM @tmpPostJournals)
					
					--GL REVERSAL
					UPDATE t SET intFiscalYearId = NULL, intFiscalPeriodId = NULL FROM tblGLJournal t JOIN @tmpPostJournals p ON t.intJournalId = p.intJournalId
					
					UPDATE s SET ysnReversed = 0  FROM tblGLJournal t JOIN tblGLJournal s on s.intJournalId = t.intJournalIdToReverse JOIN @tmpPostJournals p ON t.intJournalId = p.intJournalId
				END									
			END
		
		GOTO Post_Commit;
	END


--=====================================================================================================================================
--	JOURNAL VALIDATIONS ysnPost = 1
---------------------------------------------------------------------------------------------------------------------------------------
IF ISNULL(@ysnRecap, 0) = 0
	BEGIN
		-- DELETE Results 2 DAYS OLDER	
		DELETE FROM tblGLPostResult WHERE dtmDate < DATEADD(day, -1, GETDATE())
		
		INSERT INTO tblGLPostResult (strBatchId,intTransactionId,strTransactionId,strDescription,dtmDate,intEntityId,strTransactionType)
			SELECT @strBatchId as strBatchId,tmpBatchResults.intJournalId as intTransactionId,tblB.strJournalId as strTransactionId, strMessage as strDescription,GETDATE() as dtmDate,@intEntityId,@strJournalType
			FROM 
			(SELECT * FROM dbo.[fnGLGetPostErrors] (@tmpPostJournals,@strJournalType,@ysnPost))tmpBatchResults
			LEFT JOIN tblGLJournal tblB ON tmpBatchResults.intJournalId = tblB.intJournalId
	END

IF @@ERROR <> 0	GOTO Post_Rollback;
	
	
--=====================================================================================================================================
-- 	POPULATE VALID JOURNALS TEMPORARY TABLE
---------------------------------------------------------------------------------------------------------------------------------------
DECLARE @tmpValidJournals JournalIDTableType
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

DECLARE @intDefaultCurrencyId	INT, @ysnForeignCurrency BIT = 0
SELECT TOP 1 @intDefaultCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference 

DECLARE @dblDailyRate	NUMERIC (18,6)

IF ISNULL(@ysnRecap, 0) = 0
	BEGIN							
		
		DECLARE @GLEntries RecapTableType
		
		
		
		DELETE FROM @GLEntries
		INSERT INTO @GLEntries (
			 [strTransactionId]
			,[intTransactionId]
			,[intAccountId]
			,[strDescription]
			,[strReference]	
			,[dtmTransactionDate]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitForeign]			
			,[dblCreditForeign]
			,[dblDebitReport]
			,[dblCreditReport]
			,[dblReportingRate]
			,[dblForeignRate]
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
			,[strReference]			= A.[strReference]
			,[dtmTransactionDate]	= A.[dtmDate]
			,[dblDebit]				= CASE	WHEN [dblCredit] < 0 THEN ABS([dblCredit])
											WHEN [dblDebit] < 0 THEN 0
											ELSE [dblDebit] END 
			,[dblCredit]			= CASE	WHEN [dblDebit] < 0 THEN ABS([dblDebit])
											WHEN [dblCredit] < 0 THEN 0
											ELSE [dblCredit] END	
			,[dblDebitForeign]		= CASE	WHEN [dblCreditForeign] < 0 THEN ABS([dblCreditForeign])
											WHEN [dblDebitForeign] < 0 THEN 0
											ELSE [dblDebitForeign] END 
			,[dblCreditForeign]		= CASE	WHEN [dblDebitForeign] < 0 THEN ABS([dblDebitForeign])
											WHEN [dblCreditForeign] < 0 THEN 0
											ELSE [dblCreditForeign] END
			,[dblDebitReport]		= CASE	WHEN [dblCreditReport] < 0 THEN ABS([dblCreditReport])
											WHEN [dblDebitReport] < 0 THEN 0
											ELSE [dblDebitReport] END 
			,[dblCreditReport]		= CASE	WHEN [dblDebitReport] < 0 THEN ABS([dblDebitReport])
											WHEN [dblCreditReport] < 0 THEN 0
											ELSE [dblCreditReport] END
			,[dblReportingRate]		= dblDebitRate
			,[dblForeignRate]		= dblDebitRate
			,[dblDebitUnit]			= ISNULL(A.[dblDebitUnit], 0)
			,[dblCreditUnit]		= ISNULL(A.[dblCreditUnit], 0)
			,[dtmDate]				= ISNULL(B.[dtmDate], @currentDateTime)
			,[ysnIsUnposted]		= 0 
			,[intConcurrencyId]		= 1
			,[intCurrencyId]		= B.intCurrencyId
			,[dblExchangeRate]		= dblDebitRate
			,[intUserId]			= 0
			,[intEntityId]			= @intEntityId			
			,[dtmDateEntered]		= @currentDateTime
			,[strBatchId]			= @strBatchId
			,[strCode]				= CASE	WHEN B.[strJournalType] in ('Origin Journal','Adjusted Origin Journal') THEN REPLACE(B.[strSourceType],' ','')
											ELSE 'GJ' END 
								
			,[strJournalLineDescription] = A.[strDescription]
			,[intJournalLineNo]		= A.[intJournalDetailId]			
			,[strTransactionType]	= B.[strJournalType]
			,[strTransactionForm]	= B.[strTransactionType]
			,[strModuleName]		= 'General Ledger'

		

		FROM [dbo].tblGLJournalDetail A INNER JOIN [dbo].tblGLJournal B 
			ON A.[intJournalId] = B.[intJournalId]
		WHERE B.[intJournalId] IN (SELECT [intJournalId] FROM @tmpValidJournals)
		
		EXEC uspGLBookEntries @GLEntries, @ysnPost
		
		IF @@ERROR <> 0	GOTO Post_Rollback;
	END
ELSE
	BEGIN
		-- DELETE Results 1 DAYS OLDER	
		DELETE FROM tblGLPostRecap WHERE dtmDateEntered < DATEADD(day, -1, GETDATE()) and intEntityId = @intEntityId;
		
		
	
		INSERT INTO @GLEntries (
			 [strTransactionId]
			,[intTransactionId]
			,[intAccountId]
			,[strDescription]
			,[strReference]	
			,[dtmTransactionDate]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitForeign]
			,[dblCreditForeign]
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
			,strRateType		
		)
		SELECT 
			 [strTransactionId]		= B.[strJournalId]
			,[intTransactionId]		= B.[intJournalId]
			,[intAccountId]			= A.[intAccountId]
			,[strDescription]		= A.[strDescription]
			,[strReference]			= A.[strReference]
			,[dtmTransactionDate]	= A.[dtmDate]
			,[dblDebit]				
			,[dblCredit]			
			,[dblDebitForeign]		
			,[dblCreditForeign]		
			,[dblDebitUnit]			= ISNULL(A.[dblDebitUnit], 0)
			,[dblCreditUnit]		= ISNULL(A.[dblCreditUnit], 0)
			,[dtmDate]				= ISNULL(B.[dtmDate], @currentDateTime)
			,[ysnIsUnposted]		= 0 
			,[intConcurrencyId]		= 1
			,[dblExchangeRate]		= dblDebitRate
			,[intUserId]			= 0
			,[intEntityId]			= @intEntityId			
			,[dtmDateEntered]		= @currentDateTime
			,[strBatchId]			= @strBatchId
			,[strCode]				= CASE	WHEN B.[strJournalType] in ('Origin Journal','Adjusted Origin Journal') THEN REPLACE(B.[strSourceType],' ','')
											ELSE 'GJ' END 
			
			,[strTransactionType]	= B.[strJournalType]
			,[strTransactionForm]	= B.[strTransactionType]
			,[strModuleName]		= 'General Ledger' 
			,strCurrencyExchangeRateType
		FROM [dbo].tblGLJournalDetail A INNER JOIN [dbo].tblGLJournal B  ON A.[intJournalId] = B.[intJournalId]
		LEFT JOIN tblSMCurrencyExchangeRateType Rate on A.intCurrencyExchangeRateTypeId = Rate.intCurrencyExchangeRateTypeId
		WHERE B.[intJournalId] IN (SELECT [intJournalId] FROM @tmpValidJournals)

		EXEC dbo.uspGLPostRecap 
			@GLEntries
			,@intEntityId

	

		IF @@ERROR <> 0	GOTO Post_Rollback;

		GOTO Post_Commit;
	END

IF @@ERROR <> 0	GOTO Post_Rollback;


--=====================================================================================================================================
-- 	UPDATE JOURNAL TABLE
---------------------------------------------------------------------------------------------------------------------------------------
UPDATE tblGLJournal
SET [ysnPosted] = 1
	,[dtmPosted] = GETDATE()
WHERE [intJournalId] IN (SELECT [intJournalId] FROM @tmpValidJournals);

UPDATE  b SET ysnReversed = 1 FROM tblGLJournal j
	INNER JOIN @tmpValidJournals v on j.intJournalId = v.intJournalId
	INNER  JOIN tblGLJournal b on j.intJournalIdToReverse = b.intJournalId


UPDATE j SET intFiscalPeriodId = f.intGLFiscalYearPeriodId, intFiscalYearId = f.intFiscalYearId
	FROM tblGLJournal j, tblGLFiscalYearPeriod f, @tmpValidJournals t
	WHERE j.dtmDate >= f.dtmStartDate and j.dtmDate <= f.dtmEndDate
	AND j.ysnPosted = 1
	AND t.intJournalId = j.intJournalId


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
-- 	REVERSE JOURNAL
---------------------------------------------------------------------------------------------------------------------------------------
DECLARE @tmpReverseJournals JournalIDTableType
INSERT INTO @tmpReverseJournals (intJournalId)
SELECT A.intJournalId FROM @tmpValidJournals A
	INNER JOIN tblGLJournal B ON A.intJournalId = B.intJournalId	
	WHERE B.dtmReverseDate IS NOT NULL

IF EXISTS (SELECT 1 FROM @tmpReverseJournals)
BEGIN
	DELETE FROM @tmpValidJournals

	WHILE EXISTS(SELECT 1 FROM @tmpReverseJournals)
	BEGIN
		DECLARE @intJournalId INT = (SELECT TOP 1 intJournalId FROM @tmpReverseJournals)
		
		DECLARE @strJournalId NVARCHAR(100) = ''
				
		EXEC [dbo].uspGLGetNewID 5, @strJournalId OUTPUT 		
		
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
				,[dtmDateEntered]
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
				,[dtmDateEntered]
				,[intUserId]
				,[intEntityId]
				,[strSourceId]
				,'Reversal Journal'
				,NULL
				,[strSourceType]
			FROM [dbo].tblGLJournal A
			WHERE A.intJournalId = @intJournalId
			
		DECLARE @intJournalId_NEW INT = (SELECT TOP 1 intJournalId FROM tblGLJournal WHERE strJournalId = @strJournalId)
		DECLARE @intCurrencylId INT = (SELECT TOP 1 intCurrencyId FROM tblGLJournal WHERE strJournalId = @strJournalId)
		DECLARE @dtmDate_NEW DATETIME = (SELECT TOP 1 dtmDate FROM tblGLJournal WHERE strJournalId = @strJournalId)
		INSERT INTO @tmpValidJournals (intJournalId) SELECT @intJournalId_NEW
		 
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
				,[dblDebitForeign]			
				,[dblCreditForeign]
				,[dblCreditReport]
				,[dblDebitReport]
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
				,[intCurrencyExchangeRateTypeId]
				)
			SELECT 
				 [intLineNo]
				,@intJournalId_NEW
				,@dtmDate_NEW
				,[intAccountId]			
				,[dblCredit]  =CASE WHEN @intDefaultCurrencyId <> C.intCurrencyId AND @applyCurrentRate = 1 THEN (dblCreditForeign * B.dblRate) else dblCredit end
				,[dblCreditRate] = CASE WHEN @applyCurrentRate = 1 THEN  B.dblRate ELSE dblCreditRate END 
				,[dblDebit] =   CASE WHEN @intDefaultCurrencyId <> C.intCurrencyId AND @applyCurrentRate = 1 THEN (dblDebitForeign * B.dblRate) else dblDebit end
				,[dblDebitRate]	 = CASE WHEN @applyCurrentRate = 1 THEN  B.dblRate ELSE dblDebitRate END 
				,[dblCreditUnit]
				,[dblDebitUnit]
				,[dblCreditForeign]
				,[dblDebitForeign]	
				,[dblDebitReport]
				,[dblCreditReport]
				,A.[strDescription]
				,A.[intConcurrencyId]
				,[dblUnitsInLBS]
				,[strDocument]
				,[strComments]
				,[strReference]
				,[dblDebitUnitsInLBS]
				,[strCorrecting]
				,[strSourcePgm]
				,[strCheckBookNo]
				,[strWorkArea]
				,[intCurrencyExchangeRateTypeId]
			FROM [dbo].tblGLJournalDetail A
			INNER join tblGLJournal C on A. intJournalId = C.intJournalId
			OUTER APPLY dbo.fnGLGetExchangeRate(@intCurrencylId,A.intCurrencyExchangeRateTypeId,@dtmDate_NEW) B
			WHERE A.intJournalId = @intJournalId
							
		DELETE FROM @tmpReverseJournals WHERE intJournalId = @intJournalId
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