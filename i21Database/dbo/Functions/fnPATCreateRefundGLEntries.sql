CREATE FUNCTION [dbo].[fnPATCreateRefundGLEntries]
(
	@transactionIds NVARCHAR(MAX),
	@intUserId INT,
	@batchId NVARCHAR(40)
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
	[strRateType]				NVARCHAR (50)	 COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]          INT              DEFAULT 1 NOT NULL
)
AS
BEGIN

	DECLARE @MODULE_NAME NVARCHAR(25) = 'Patronage'
	DECLARE @SCREEN_NAME NVARCHAR(25) = 'Refund'

	DECLARE @tmpTransacions TABLE (
		[intTransactionId] [int] PRIMARY KEY,
		UNIQUE (intTransactionId)
	);

	INSERT INTO @tmpTransacions SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@transactionIds)

	INSERT INTO @returntable
	--UNDISTRIBUTED EQUITY
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmRefundDate), 0),
		[strBatchID]					=	@batchId,
		[intAccountId]					=	D.intUndistributedEquityId,
		[dblDebit]						=	0,
		[dblCredit]						=	ROUND(B.dblEquityRefund, 2),
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	0,
		[strDescription]				=	'Undistributed Equity',
		[strCode]						=	'PAT',
		[strReference]					=	A.strRefundNo,
		[intCurrencyId]					=	0,
		[dblExchangeRate]				=	1,
		[dtmDateEntered]				=	GETDATE(),
		[dtmTransactionDate]			=	A.dtmRefundDate,
		[strJournalLineDescription]		=	'Undistributed Equity',
		[intJournalLineNo]				=	1,
		[ysnIsUnposted]					=	0,
		[intUserId]						=	@intUserId,
		[intEntityId]					=	@intUserId,
		[strTransactionId]				=	A.strRefundNo, 
		[intTransactionId]				=	A.intRefundId, 
		[strTransactionType]			=	'Undistributed Equity',
		[strTransactionForm]			=	@SCREEN_NAME,
		[strModuleName]					=	@MODULE_NAME,
		[dblDebitForeign]				=	0,      
		[dblDebitReport]				=	0,
		[dblCreditForeign]				=	0,
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]				=	0,
		[strRateType]					=	NULL,
		[intConcurrencyId]				=	1
	FROM	[dbo].tblPATRefund A
			INNER JOIN tblPATRefundCustomer B
				ON A.intRefundId = B.intRefundId
			INNER JOIN tblPATRefundRate D
				ON B.intRefundTypeId = D.intRefundTypeId
	WHERE	A.intRefundId IN (SELECT intTransactionId FROM @tmpTransacions) AND B.ysnEligibleRefund = 1
	UNION ALL
	--AP Clearing
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmRefundDate), 0),
		[strBatchID]					=	@batchId,
		[intAccountId]					=	E.intAPClearingGLAccount, 
		[dblDebit]						=	0,
		[dblCredit]						=	ROUND(B.dblCashRefund,2),
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	0,
		[strDescription]				=	'AP Clearing',
		[strCode]						=	'PAT',
		[strReference]					=	A.strRefundNo,
		[intCurrencyId]					=	0,
		[dblExchangeRate]				=	1,
		[dtmDateEntered]				=	GETDATE(),
		[dtmTransactionDate]			=	A.dtmRefundDate,
		[strJournalLineDescription]		=	'AP Clearing',
		[intJournalLineNo]				=	1,
		[ysnIsUnposted]					=	0,
		[intUserId]						=	@intUserId,
		[intEntityId]					=	@intUserId,
		[strTransactionId]				=	A.strRefundNo, 
		[intTransactionId]				=	A.intRefundId, 
		[strTransactionType]			=	'AP Clearing',
		[strTransactionForm]			=	@SCREEN_NAME,
		[strModuleName]					=	@MODULE_NAME,
		[dblDebitForeign]				=	0,      
		[dblDebitReport]				=	0,
		[dblCreditForeign]				=	0,
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]				=	0,
		[strRateType]					=	NULL,
		[intConcurrencyId]				=	1
	FROM	[dbo].tblPATRefund A
			INNER JOIN tblPATRefundCustomer B
				ON A.intRefundId = B.intRefundId
			INNER JOIN tblPATRefundRate D
				ON B.intRefundTypeId = D.intRefundTypeId
			CROSS JOIN tblPATCompanyPreference E
	WHERE	A.intRefundId IN (SELECT intTransactionId FROM @tmpTransacions) AND B.ysnEligibleRefund = 1
	UNION ALL
	--GENERAL RESERVE
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmRefundDate), 0),
		[strBatchID]					=	@batchId,
		[intAccountId]					=	D.intGeneralReserveId,
		[dblDebit]						=	ROUND(B.dblRefundAmount,2),
		[dblCredit]						=	0,
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	0,
		[strDescription]				=	'General Reserve',
		[strCode]						=	'PAT',
		[strReference]					=	A.strRefundNo,
		[intCurrencyId]					=	0,
		[dblExchangeRate]				=	1,
		[dtmDateEntered]				=	GETDATE(),
		[dtmTransactionDate]			=	A.dtmRefundDate,
		[strJournalLineDescription]		=	'General Reserve',
		[intJournalLineNo]				=	1,
		[ysnIsUnposted]					=	0,
		[intUserId]						=	@intUserId,
		[intEntityId]					=	@intUserId,
		[strTransactionId]				=	A.strRefundNo, 
		[intTransactionId]				=	A.intRefundId, 
		[strTransactionType]			=	'General Reserve',
		[strTransactionForm]			=	@SCREEN_NAME,
		[strModuleName]					=	@MODULE_NAME,
		[dblDebitForeign]				=	0,      
		[dblDebitReport]				=	0,
		[dblCreditForeign]				=	0,
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]				=	0,
		[strRateType]					=	NULL,
		[intConcurrencyId]				=	1
	FROM	[dbo].tblPATRefund A
			INNER JOIN tblPATRefundCustomer B
				ON A.intRefundId = B.intRefundId
			INNER JOIN tblPATRefundRate D
				ON B.intRefundTypeId = D.intRefundTypeId
	WHERE	A.intRefundId IN (SELECT intTransactionId FROM @tmpTransacions) AND B.ysnEligibleRefund = 1
	RETURN
END

GO