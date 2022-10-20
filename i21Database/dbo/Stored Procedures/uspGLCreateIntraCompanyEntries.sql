CREATE PROCEDURE [dbo].[uspGLCreateIntraCompanyEntries]
	@JournalIds		AS JournalIDTableType READONLY,
	@strBatchId		AS NVARCHAR(100)	= '',
	@intEntityId	AS INT = 1,
	@ysnAudit		AS BIT = 0	

AS
	DECLARE 
		@strCode NVARCHAR(20),
		@msg NVARCHAR(255),
		@currentDateTime DATETIME =  GETDATE(),
		@intDefaultCurrencyId INT

	SELECT TOP 1 @intDefaultCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference

	DECLARE @tblIntraCompanyEntries TABLE (
		strType NVARCHAR(10),
		intJournalId INT,
		intCompanySegmentId INT,
		dblCreditDebit NUMERIC(18, 6)
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

	IF NOT EXISTS(SELECT 1 FROM tblGLJournalDetail A 
		JOIN tblGLAccount B ON A.intAccountId = B.intAccountId
		JOIN @tblIntraAccounts C ON B.intCompanySegmentId = C.intTransactionCompanySegmentId
		WHERE A.[intJournalId] IN (SELECT [intJournalId] FROM @JournalIds))
	BEGIN
		SELECT TOP 1  @strCode = S.strCode 
		FROM tblGLJournalDetail A 
		JOIN tblGLAccount B ON A.intAccountId = B.intAccountId
		JOIN tblGLAccountSegment S ON B.intCompanySegmentId = S.intAccountSegmentId
		LEFT JOIN @tblIntraAccounts C ON B.intCompanySegmentId = C.intTransactionCompanySegmentId
		WHERE A.[intJournalId] IN (SELECT [intJournalId] FROM @JournalIds) AND C.intAccountId IS NULL

		SET @msg = 'No Intra Company setup for accounts with Company Segment ' + ''''+ @strCode +'''.';
				
		RAISERROR(@msg, 11, 1);
	END

	INSERT INTO @tblIntraCompanyEntries
	SELECT
		'Header',
		B.intJournalId,
		Acc.intCompanySegmentId,
		SUM(ISNULL(dblCredit,0)) - SUM(ISNULL(dblDebit,0))
	FROM [dbo].tblGLJournalDetail A 
	INNER JOIN [dbo].tblGLJournal B 
		ON A.[intJournalId] = B.[intJournalId]
	OUTER APPLY (
		SELECT intCompanySegmentId FROM [dbo].[tblGLAccount] WHERE [intAccountId] = A.[intAccountId]
	) Acc
	WHERE B.[intJournalId] IN (SELECT [intJournalId] FROM @JournalIds)
		AND Acc.intCompanySegmentId = B.intCompanySegmentId
	GROUP BY B.[intJournalId], B.intCompanySegmentId, Acc.intCompanySegmentId
	UNION ALL
	SELECT
		'Intra',
		B.intJournalId,
		Acc.intCompanySegmentId,
		SUM(ISNULL(dblCredit,0)) - SUM(ISNULL(dblDebit,0))
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
		,[dblDebit]				= CASE WHEN Intra.dblCreditDebit > 0 THEN Intra.dblCreditDebit ELSE 0 END
		,[dblCredit]			= CASE WHEN Intra.dblCreditDebit > 0 THEN 0 ELSE ABS(Intra.dblCreditDebit) END
		,[dblDebitForeign]		= CASE WHEN Intra.dblCreditDebit > 0 THEN Intra.dblCreditDebit ELSE 0 END
		,[dblCreditForeign]		= CASE WHEN Intra.dblCreditDebit > 0 THEN 0 ELSE ABS(Intra.dblCreditDebit) END
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
	FROM [dbo].tblGLJournal B
	JOIN @tblIntraCompanyEntries Intra
		ON B.[intJournalId] = Intra.intJournalId
	JOIN @tblIntraAccounts C
		ON C.intTransactionCompanySegmentId = B.intCompanySegmentId AND
			C.intInterCompanySegmentId = B.intCompanySegmentId
	WHERE B.[intJournalId] IN (SELECT [intJournalId] FROM @JournalIds)
		AND Intra.dblCreditDebit <> 0
		AND Intra.strType = 'Header'
		AND C.strAccountType = (CASE WHEN Intra.dblCreditDebit > 0 THEN 'Transaction Company Due From' ELSE 'Transaction Company Due To' END)
	UNION ALL
	SELECT 
			[strTransactionId]		= B.[strJournalId]
		,[intTransactionId]		= B.[intJournalId]
		,[intAccountId]			= C.[intAccountId]
		,[strDescription]		= B.[strDescription]
		,[dtmTransactionDate]	= B.[dtmDate]
		,[dblDebit]				= CASE WHEN Intra.dblCreditDebit > 0 THEN Intra.dblCreditDebit ELSE 0 END
		,[dblCredit]			= CASE WHEN Intra.dblCreditDebit > 0 THEN 0 ELSE ABS(Intra.dblCreditDebit) END
		,[dblDebitForeign]		= CASE WHEN Intra.dblCreditDebit > 0 THEN Intra.dblCreditDebit ELSE 0 END
		,[dblCreditForeign]		= CASE WHEN Intra.dblCreditDebit > 0 THEN 0 ELSE ABS(Intra.dblCreditDebit) END
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
	FROM [dbo].tblGLJournal B
	JOIN @tblIntraCompanyEntries Intra
		ON B.[intJournalId] = Intra.intJournalId
	JOIN @tblIntraAccounts C
		ON  C.intInterCompanySegmentId = Intra.intCompanySegmentId 
		AND Intra.strType = 'Intra'
	WHERE B.[intJournalId] IN (SELECT [intJournalId] FROM @JournalIds)
		AND Intra.dblCreditDebit <> 0
		AND C.intTransactionCompanySegmentId = B.intCompanySegmentId
		AND C.strAccountType = (CASE WHEN Intra.dblCreditDebit > 0 THEN 'Inter Company Due From' ELSE 'Inter Company Due To' END)
