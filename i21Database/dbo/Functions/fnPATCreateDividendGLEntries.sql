CREATE FUNCTION [dbo].[fnPATCreateDividendGLEntries]
(
	@transactionIds NVARCHAR(MAX),
	@intUserId INT,
	@apClearing	INT
)
RETURNS @returntable TABLE
(
	[dtmDate]                   DATETIME         NOT NULL,
	[strBatchId]                NVARCHAR (20)    COLLATE Latin1_General_CI_AS NULL,
	[intAccountId]              INT              NULL,
	[dblDebit]                  NUMERIC (18, 6)  NULL,
	[dblCredit]                 NUMERIC (18, 6)  NULL,
	[dblDebitUnit]              NUMERIC (18, 6)  NULL,
	[dblCreditUnit]             NUMERIC (18, 6)  NULL,
	[strDescription]            NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[strCode]                   NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,    
	[strReference]              NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[intCurrencyId]             INT              NULL,
	[dblExchangeRate]           NUMERIC (38, 20) DEFAULT 1 NOT NULL,
	[dtmDateEntered]            DATETIME         NOT NULL,
	[dtmTransactionDate]        DATETIME         NULL,
	[strJournalLineDescription] NVARCHAR (250)   COLLATE Latin1_General_CI_AS NULL,
	[intJournalLineNo]			INT              NULL,
	[ysnIsUnposted]             BIT              NOT NULL,    
	[intUserId]                 INT              NULL,
	[intEntityId]				INT              NULL,
	[strTransactionId]          NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,
	[intTransactionId]          INT              NULL,
	[strTransactionType]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[strTransactionForm]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[strModuleName]             NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[dblDebitForeign]           NUMERIC (18, 6)	NULL,
    [dblDebitReport]            NUMERIC (18, 6) NULL,
    [dblCreditForeign]          NUMERIC (18, 6) NULL,
    [dblCreditReport]           NUMERIC (18, 6) NULL,
    [dblReportingRate]          NUMERIC (18, 6) NULL,
    [dblForeignRate]            NUMERIC (18, 6) NULL,
	[intConcurrencyId]          INT              DEFAULT 1 NOT NULL
)
AS
BEGIN
	DECLARE @MODULE_NAME NVARCHAR(25) = 'Patronage'
	DECLARE @SCREEN_NAME NVARCHAR(25) = 'Dividend'

	DECLARE @tmpTransacions TABLE (
		[intTransactionId] [int] PRIMARY KEY,
		UNIQUE (intTransactionId)
	);

	INSERT INTO @tmpTransacions SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@transactionIds)

	INSERT INTO @returntable
	--UNDISTRIBUTED EQUITY
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmProcessDate), 0),
		[strBatchID]					=	'',
		[intAccountId]					=	D.intDividendsGLAccount,
		[dblDebit]						=	C.dblDividendAmount,
		[dblCredit]						=	0,
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	0,
		[strDescription]				=	A.strDividendNo,
		[strCode]						=	'PAT',
		[strReference]					=	A.strDividendNo,
		[intCurrencyId]					=	0,
		[dblExchangeRate]				=	1,
		[dtmDateEntered]				=	GETDATE(),
		[dtmTransactionDate]			=	NULL,
		[strJournalLineDescription]		=	'Posted Dividend GL',
		[intJournalLineNo]				=	1,
		[ysnIsUnposted]					=	0,
		[intUserId]						=	@intUserId,
		[intEntityId]					=	@intUserId,
		[strTransactionId]				=	A.strDividendNo, 
		[intTransactionId]				=	A.intDividendId, 
		[strTransactionType]			=	'Dividend GL',
		[strTransactionForm]			=	@SCREEN_NAME,
		[strModuleName]					=	@MODULE_NAME,
		[dblDebitForeign]				=	0,      
		[dblDebitReport]				=	0,
		[dblCreditForeign]				=	0,
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]				=	0,
		[intConcurrencyId]				=	1
	FROM	[dbo].tblPATDividends A
		INNER JOIN tblPATDividendsCustomer B
				ON A.intDividendId = B.intDividendId
		INNER JOIN tblPATDividendsStock C
				ON B.intDividendCustomerId = C.intDividendCustomerId
		INNER JOIN tblPATStockClassification D
				ON D.intStockId = C.intStockId
	WHERE	A.intDividendId IN (SELECT intTransactionId FROM @tmpTransacions)
	UNION ALL
	--AP Clearing
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmProcessDate), 0),
		[strBatchID]					=	'',
		[intAccountId]					=	@apClearing, 
		[dblDebit]						=	0,
		[dblCredit]						=	B.dblDividendAmount - (B.dblDividendAmount * (A.dblFederalTaxWithholding/100)),
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	0,
		[strDescription]				=	A.strDividendNo,
		[strCode]						=	'PAT',
		[strReference]					=	A.strDividendNo,
		[intCurrencyId]					=	0,
		[dblExchangeRate]				=	1,
		[dtmDateEntered]				=	GETDATE(),
		[dtmTransactionDate]			=	NULL,
		[strJournalLineDescription]		=	'Posted AP Clearing',
		[intJournalLineNo]				=	1,
		[ysnIsUnposted]					=	0,
		[intUserId]						=	@intUserId,
		[intEntityId]					=	@intUserId,
		[strTransactionId]				=	A.strDividendNo, 
		[intTransactionId]				=	A.intDividendId, 
		[strTransactionType]			=	'AP Clearing - Dividends',
		[strTransactionForm]			=	@SCREEN_NAME,
		[strModuleName]					=	@MODULE_NAME,
		[dblDebitForeign]				=	0,      
		[dblDebitReport]				=	0,
		[dblCreditForeign]				=	0,
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]				=	0,
		[intConcurrencyId]				=	1
	FROM	[dbo].tblPATDividends A
	INNER JOIN tblPATDividendsCustomer B
			ON A.intDividendId = B.intDividendId
	WHERE	A.intDividendId IN (SELECT intTransactionId FROM @tmpTransacions)
	UNION ALL
	--FWT Liability
	SELECT 
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmProcessDate), 0),
		[strBatchID]					=	'',
		[intAccountId]					=	(SELECT DISTINCT intFWTLiabilityAccountId FROM tblPATCompanyPreference), 
		[dblDebit]						=	0,
		[dblCredit]						=	B.dblDividendAmount - (B.dblDividendAmount - (B.dblDividendAmount * (A.dblFederalTaxWithholding/100))),
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	0,
		[strDescription]				=	A.strDividendNo,
		[strCode]						=	'PAT',
		[strReference]					=	A.strDividendNo,
		[intCurrencyId]					=	0,
		[dblExchangeRate]				=	1,
		[dtmDateEntered]				=	GETDATE(),
		[dtmTransactionDate]			=	NULL,
		[strJournalLineDescription]		=	'Posted FWT Liability',
		[intJournalLineNo]				=	1,
		[ysnIsUnposted]					=	0,
		[intUserId]						=	@intUserId,
		[intEntityId]					=	@intUserId,
		[strTransactionId]				=	A.strDividendNo, 
		[intTransactionId]				=	A.intDividendId, 
		[strTransactionType]			=	'FWT Liability',
		[strTransactionForm]			=	@SCREEN_NAME,
		[strModuleName]					=	@MODULE_NAME,
		[dblDebitForeign]				=	0,      
		[dblDebitReport]				=	0,
		[dblCreditForeign]				=	0,
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]				=	0,
		[intConcurrencyId]				=	1
	FROM	[dbo].tblPATDividends A
	INNER JOIN tblPATDividendsCustomer B
			ON A.intDividendId = B.intDividendId
	WHERE	A.intDividendId IN (SELECT intTransactionId FROM @tmpTransacions)	
	
	RETURN 
END

GO