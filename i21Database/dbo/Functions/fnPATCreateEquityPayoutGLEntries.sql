CREATE FUNCTION [dbo].[fnPATCreateEquityPayoutGLEntries]
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
	DECLARE @SCREEN_NAME NVARCHAR(25) = 'Equity Payment';
	DECLARE @MODULE_CODE NVARCHAR(5)  = 'PAT';

	DECLARE @tmpTransacions TABLE (
		[intTransactionId] [int] PRIMARY KEY,
		UNIQUE (intTransactionId)
	);

	INSERT INTO @tmpTransacions SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@transactionIds)

	INSERT INTO @returnTable
	--Undistributed Equity
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmPaymentDate), 0),
		[strBatchID]					=	@batchId,
		[intAccountId]					=	D.intUndistributedEquityId,
		[dblDebit]						=	ROUND(C.dblEquityPay,2),
		[dblCredit]						=	0,
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	0,
		[strDescription]				=	'',
		[strCode]						=	@MODULE_CODE,
		[strReference]					=	A.strPaymentNumber,
		[intCurrencyId]					=	0,
		[dblExchangeRate]				=	1,
		[dtmDateEntered]				=	GETDATE(),
		[dtmTransactionDate]			=	NULL,
		[strJournalLineDescription]		=	'Posted Undistributed Equity Payment',
		[intJournalLineNo]				=	1,
		[ysnIsUnposted]					=	0,
		[intUserId]						=	@intUserId,
		[intEntityId]					=	@intUserId,
		[strTransactionId]				=	A.strPaymentNumber, 
		[intTransactionId]				=	A.intEquityPayId, 
		[strTransactionType]			=	'Undistributed Equity Payment',
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
	FROM	[dbo].[tblPATEquityPay] A
	INNER JOIN tblPATEquityPaySummary B ON
		B.intEquityPayId = A.intEquityPayId
	INNER JOIN tblPATEquityPayDetail C ON
		C.intEquityPaySummaryId = B.intEquityPaySummaryId
	INNER JOIN tblPATRefundRate D ON
		D.intRefundTypeId = C.intRefundTypeId
	WHERE	A.intEquityPayId IN (SELECT intTransactionId FROM @tmpTransacions) AND C.strEquityType = 'Undistributed' AND C.dblEquityPay <> 0
	UNION ALL
	--Allocated Reserve
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmPaymentDate), 0),
		[strBatchID]					=	@batchId,
		[intAccountId]					=	D.intAllocatedReserveId,
		[dblDebit]						=	ROUND(C.dblEquityPay,2),
		[dblCredit]						=	0,
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	0,
		[strDescription]				=	'',
		[strCode]						=	@MODULE_CODE,
		[strReference]					=	A.strPaymentNumber,
		[intCurrencyId]					=	0,
		[dblExchangeRate]				=	1,
		[dtmDateEntered]				=	GETDATE(),
		[dtmTransactionDate]			=	NULL,
		[strJournalLineDescription]		=	'Posted Reserve Equity Payment',
		[intJournalLineNo]				=	1,
		[ysnIsUnposted]					=	0,
		[intUserId]						=	@intUserId,
		[intEntityId]					=	@intUserId,
		[strTransactionId]				=	A.strPaymentNumber, 
		[intTransactionId]				=	A.intEquityPayId, 
		[strTransactionType]			=	'Reserve Equity Payment',
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
	FROM	[dbo].[tblPATEquityPay] A
	INNER JOIN tblPATEquityPaySummary B ON
		B.intEquityPayId = A.intEquityPayId
	INNER JOIN tblPATEquityPayDetail C ON
		C.intEquityPaySummaryId = B.intEquityPaySummaryId
	INNER JOIN tblPATRefundRate D ON
		D.intRefundTypeId = C.intRefundTypeId
	WHERE	A.intEquityPayId IN (SELECT intTransactionId FROM @tmpTransacions) AND C.strEquityType = 'Reserve' AND C.dblEquityPay <> 0
	UNION ALL
	--AP Clearing
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmPaymentDate), 0),
		[strBatchID]					=	@batchId,
		[intAccountId]					=	ComPref.intAPClearingGLAccount,
		[dblDebit]						=	0,
		[dblCredit]						=	ROUND(B.dblEquityPaid,2),
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	0,
		[strDescription]				=	'',
		[strCode]						=	@MODULE_CODE,
		[strReference]					=	A.strPaymentNumber,
		[intCurrencyId]					=	0,
		[dblExchangeRate]				=	1,
		[dtmDateEntered]				=	GETDATE(),
		[dtmTransactionDate]			=	NULL,
		[strJournalLineDescription]		=	'Posted Equity Payment',
		[intJournalLineNo]				=	1,
		[ysnIsUnposted]					=	0,
		[intUserId]						=	@intUserId,
		[intEntityId]					=	@intUserId,
		[strTransactionId]				=	A.strPaymentNumber, 
		[intTransactionId]				=	A.intEquityPayId, 
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
	FROM	[dbo].[tblPATEquityPay] A
	INNER JOIN tblPATEquityPaySummary B ON
		B.intEquityPayId = A.intEquityPayId
	CROSS JOIN tblPATCompanyPreference ComPref
	WHERE	A.intEquityPayId IN (SELECT intTransactionId FROM @tmpTransacions)
	RETURN
END