CREATE FUNCTION [dbo].[fnPATCreateCancelEquityGLEntries]
(
	@transactionIds NVARCHAR(MAX),
	@batchId NVARCHAR(40),
	@intUserId INT
)
RETURNS @returnTable TABLE
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
	[strRateType]				NVARCHAR (50)	COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]          INT              DEFAULT 1 NOT NULL
)
BEGIN

	DECLARE @MODULE_NAME NVARCHAR(25) = 'Patronage';
	DECLARE @SCREEN_NAME NVARCHAR(25) = 'Cancel Equity';
	DECLARE @MODULE_CODE NVARCHAR(5)  = 'PAT';

	DECLARE @tmpTransacions TABLE (
		[intTransactionId] [int] PRIMARY KEY,
		UNIQUE (intTransactionId)
	);

	INSERT INTO @tmpTransacions SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@transactionIds)
	
	INSERT INTO @returnTable
	--Undistributed Equity/Allocated Reserve
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmCancelDate), 0),
		[strBatchID]					=	@batchId,
		[intAccountId]					=	CASE WHEN B.strEquityType = 'Undistributed' THEN C.intUndistributedEquityId ELSE C.intAllocatedReserveId END,
		[dblDebit]						=	B.dblQuantityCancelled,
		[dblCredit]						=	0,
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	0,
		[strDescription]				=	A.strDescription,
		[strCode]						=	@MODULE_CODE,
		[strReference]					=	A.strCancelNo,
		[intCurrencyId]					=	0,
		[dblExchangeRate]				=	1,
		[dtmDateEntered]				=	GETDATE(),
		[dtmTransactionDate]			=	NULL,
		[strJournalLineDescription]		=	CASE WHEN B.strEquityType = 'Undistributed' THEN 'Undistributed Equity' ELSE 'Allocated Reserve' END,
		[intJournalLineNo]				=	1,
		[ysnIsUnposted]					=	0,
		[intUserId]						=	@intUserId,
		[intEntityId]					=	@intUserId,
		[strTransactionId]				=	A.strCancelNo, 
		[intTransactionId]				=	A.intCancelEquityId, 
		[strTransactionType]			=	@SCREEN_NAME,
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
	FROM	[dbo].[tblPATCancelEquity] A
	INNER JOIN tblPATCancelEquityDetail B
		ON B.intCancelEquityId = A.intCancelEquityId
	INNER JOIN tblPATRefundRate C
		ON C.intRefundTypeId = B.intRefundTypeId
	WHERE	A.intCancelEquityId IN (SELECT intTransactionId FROM @tmpTransacions)
	UNION ALL
	--GENERAL RESERVE 
	SELECT
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmCancelDate), 0),
		[strBatchID]					=	@batchId,
		[intAccountId]					=	C.intGeneralReserveId,
		[dblDebit]						=	0,
		[dblCredit]						=	B.dblQuantityCancelled,
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	0,
		[strDescription]				=	A.strDescription,
		[strCode]						=	@MODULE_CODE,
		[strReference]					=	A.strCancelNo,
		[intCurrencyId]					=	0,
		[dblExchangeRate]				=	1,
		[dtmDateEntered]				=	GETDATE(),
		[dtmTransactionDate]			=	NULL,
		[strJournalLineDescription]		=	'General Reserve',
		[intJournalLineNo]				=	1,
		[ysnIsUnposted]					=	0,
		[intUserId]						=	@intUserId,
		[intEntityId]					=	@intUserId,
		[strTransactionId]				=	A.strCancelNo, 
		[intTransactionId]				=	A.intCancelEquityId, 
		[strTransactionType]			=	@SCREEN_NAME,
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
	FROM	[dbo].[tblPATCancelEquity] A
	INNER JOIN tblPATCancelEquityDetail B
		ON B.intCancelEquityId = A.intCancelEquityId
	INNER JOIN tblPATRefundRate C
		ON C.intRefundTypeId = B.intRefundTypeId
	WHERE	A.intCancelEquityId IN (SELECT intTransactionId FROM @tmpTransacions)

	RETURN
END