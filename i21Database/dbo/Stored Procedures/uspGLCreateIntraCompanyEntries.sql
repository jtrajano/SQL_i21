CREATE PROCEDURE [dbo].[uspGLCreateIntraCompanyEntries]
	@JournalIds		AS JournalIDTableType READONLY,
	@strBatchId		AS NVARCHAR(100)	= '',
	@intEntityId	AS INT = 1,
	@ysnAudit		AS BIT = 0	

AS
	DECLARE 
		@strHeaderCode NVARCHAR(20),
		@strCode NVARCHAR(20),
		@msg NVARCHAR(255),
		@currentDateTime DATETIME =  GETDATE(),
		@intDefaultCurrencyId INT

	SELECT TOP 1 @intDefaultCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference

	DECLARE @tblIntraCompanyEntries TABLE (
		intJournalId INT,
		intCompanySegmentId INT,
		dblDebitCredit NUMERIC(18, 6)
	)

	DECLARE @tblIntraAccounts TABLE
	(
		intAccountId INT NULL,
		strAccountId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
		strAccountType NVARCHAR(60) COLLATE Latin1_General_CI_AS,
		intTransactionCompanySegmentId INT,
		intInterCompanySegmentId INT
	)

	INSERT INTO @tblIntraAccounts
	SELECT * FROM [dbo].[fnGLGetIntraCompanyAccounts]() WHERE intAccountId IS NOT NULL

	-- Validate Transaction and Inter Company Account Setup
	IF EXISTS(SELECT TOP 1 1 FROM tblGLJournalDetail A 
		JOIN tblGLJournal J ON J.intJournalId = A.intJournalId
		JOIN tblGLAccount B ON A.intAccountId = B.intAccountId
		LEFT JOIN @tblIntraAccounts C ON B.intCompanySegmentId = C.intInterCompanySegmentId AND C.intTransactionCompanySegmentId = J.intCompanySegmentId
		WHERE A.[intJournalId] IN (SELECT [intJournalId] FROM @JournalIds) AND C.intInterCompanySegmentId IS NULL AND C.intTransactionCompanySegmentId IS NULL
		AND J.intCompanySegmentId <> B.intCompanySegmentId)
	BEGIN
		SELECT TOP 1  @strCode = S.strCode, @strHeaderCode = JS.strCode 
		FROM tblGLJournalDetail A 
		JOIN tblGLJournal J ON J.intJournalId = A.intJournalId
		JOIN tblGLAccount B ON A.intAccountId = B.intAccountId
		JOIN tblGLAccountSegment S ON B.intCompanySegmentId = S.intAccountSegmentId
		JOIN tblGLAccountSegment JS ON JS.intAccountSegmentId = J.intCompanySegmentId
		LEFT JOIN @tblIntraAccounts C ON B.intCompanySegmentId = C.intInterCompanySegmentId AND C.intTransactionCompanySegmentId = J.intCompanySegmentId
		WHERE A.[intJournalId] IN (SELECT [intJournalId] FROM @JournalIds) AND C.intInterCompanySegmentId IS NULL AND C.intTransactionCompanySegmentId IS NULL
		AND J.intCompanySegmentId <> B.intCompanySegmentId

		SET @msg = 'No Intra Company accounts setup for Transaction Company '+''''+ @strHeaderCode +''' with Inter Company ' + ''''+ @strCode +'''.';
				
		RAISERROR(@msg, 11, 1);
	END

	-- Validate Transaction Company Entries
	IF ((SELECT SUM(ISNULL(dblDebit,0)) - SUM(ISNULL(dblCredit,0)) 
		FROM [dbo].tblGLJournalDetail A 
		INNER JOIN [dbo].tblGLJournal B ON A.[intJournalId] = B.[intJournalId]
		OUTER APPLY ( SELECT intCompanySegmentId FROM [dbo].[tblGLAccount] WHERE [intAccountId] = A.[intAccountId]) Acc
		WHERE B.[intJournalId] IN (SELECT [intJournalId] FROM @JournalIds) AND Acc.intCompanySegmentId = B.intCompanySegmentId
		GROUP BY B.[intJournalId], B.intCompanySegmentId, Acc.intCompanySegmentId
	) <> 0)
	BEGIN
		SELECT TOP 1  @strCode = S.strCode 
		FROM tblGLJournalDetail A 
		JOIN tblGLAccount B ON A.intAccountId = B.intAccountId
		JOIN tblGLAccountSegment S ON B.intCompanySegmentId = S.intAccountSegmentId
		WHERE A.[intJournalId] IN (SELECT [intJournalId] FROM @JournalIds)
				
		SET @msg = 'Debit and Credit amounts for Transaction Company ' + ''''+ @strCode +''' are not balanced.';
		
		RAISERROR(@msg, 11, 1);
	END

	INSERT INTO @tblIntraCompanyEntries
	SELECT
		B.intJournalId,
		Acc.intCompanySegmentId,
		SUM(ISNULL(dblDebit,0)) - SUM(ISNULL(dblCredit,0))
	FROM [dbo].tblGLJournalDetail A 
	INNER JOIN [dbo].tblGLJournal B 
		ON A.[intJournalId] = B.[intJournalId]
	OUTER APPLY (
		SELECT intCompanySegmentId FROM [dbo].[tblGLAccount] WHERE [intAccountId] = A.[intAccountId]
	) Acc
	WHERE B.[intJournalId] IN (SELECT [intJournalId] FROM @JournalIds)
		AND Acc.intCompanySegmentId <> B.intCompanySegmentId
	GROUP BY B.[intJournalId], B.intCompanySegmentId, Acc.intCompanySegmentId

	SELECT 
		 [strTransactionId]		= B.[strJournalId]
		,[intTransactionId]		= B.[intJournalId]
		,[intAccountId]			= C.[intAccountId]
		,[strDescription]		= B.[strDescription]
		,[dtmTransactionDate]	= B.[dtmDate]
		,[dblDebit]				= CASE WHEN Intra.dblDebitCredit < 0 THEN ABS(Intra.dblDebitCredit) ELSE 0 END
		,[dblCredit]			= CASE WHEN Intra.dblDebitCredit < 0 THEN 0 ELSE Intra.dblDebitCredit END
		,[dblDebitForeign]		= CASE WHEN Intra.dblDebitCredit < 0 THEN ABS(Intra.dblDebitCredit) ELSE 0 END
		,[dblCreditForeign]		= CASE WHEN Intra.dblDebitCredit < 0 THEN 0 ELSE Intra.dblDebitCredit END
		,[dblDebitReport]		= 0
		,[dblCreditReport]		= 0
		,[dblReportingRate]		= 1
		,[dblForeignRate]		= 1
		,[dblDebitUnit]			= 0
		,[dblCreditUnit]		= 0
		,[dtmDate]				= CASE 
									WHEN @ysnAudit = 1 THEN COALESCE(B.[dtmDate], @currentDateTime) 
									ELSE ISNULL(B.[dtmDate], @currentDateTime)
									END 
		,[ysnIsUnposted]		= 0 
		,[intConcurrencyId]		= 1
		,[intCurrencyId]		= @intDefaultCurrencyId
		,[dblExchangeRate]		= 1
		,[intUserId]			= 0
		,[intEntityId]			= @intEntityId			
		,[dtmDateEntered]		= @currentDateTime
		,[strBatchId]			= @strBatchId
		,[strCode]				= CASE	WHEN ISNULL(B.[strJournalType],'') IN ('Origin Journal','Adjusted Origin Journal','Imported Journal') THEN REPLACE(ISNULL(B.[strSourceType],''),' ','')
										ELSE 'GJ' END 
								
		,[strJournalLineDescription] = B.[strDescription]
		,[strTransactionType]	= B.[strJournalType]
		,[strTransactionForm]	= B.[strTransactionType]
		,[strModuleName]		= 'General Ledger'
		,[intCompanyLocationId]	= B.[intCompanyLocationId]
		,[ysnIntraCompanyEntry] = 1
	FROM [dbo].tblGLJournal B
	JOIN @tblIntraCompanyEntries Intra
		ON B.[intJournalId] = Intra.intJournalId
	JOIN @tblIntraAccounts C
		ON  C.intInterCompanySegmentId = Intra.intCompanySegmentId
	WHERE B.[intJournalId] IN (SELECT [intJournalId] FROM @JournalIds)
		AND Intra.dblDebitCredit <> 0
		AND C.intTransactionCompanySegmentId = B.intCompanySegmentId
		AND C.strAccountType = (CASE WHEN Intra.dblDebitCredit < 0 THEN 'Inter Company Due From' ELSE 'Inter Company Due To' END)
