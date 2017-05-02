CREATE FUNCTION [dbo].[fnPATCreateRetireStockGLEntries]
(
	@transactionIds NVARCHAR(MAX),
	@voidRetire BIT,
	@intUserId INT,
	@batchId NVARCHAR(40)
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
	[strRateType]				NVARCHAR (50)	 COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]          INT              DEFAULT 1 NOT NULL
)
AS
BEGIN

	DECLARE @MODULE_NAME NVARCHAR(25) = 'Patronage';
	DECLARE @SCREEN_NAME NVARCHAR(25) = 'Retire Stock';
	DECLARE @MODULE_CODE NVARCHAR(5)  = 'PAT';

	DECLARE @tmpTransacions TABLE (
		[intTransactionId] [int] PRIMARY KEY,
		UNIQUE (intTransactionId)
	);

	INSERT INTO @tmpTransacions SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@transactionIds)
	
	IF(@voidRetire = 0)
		BEGIN
		INSERT INTO @returnTable
		--VOTING STOCK/NON-VOTING STOCK/OTHER ISSUED
		SELECT	
			[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmIssueDate), 0),
			[strBatchID]					=	@batchId,
			[intAccountId]					=	CASE WHEN A.strStockStatus = 'Voting' THEN ComPref.intVotingStockId ELSE ComPref.intNonVotingStockId END,
			[dblDebit]						=	ROUND(A.dblFaceValue, 2),
			[dblCredit]						=	0,
			[dblDebitUnit]					=	0,
			[dblCreditUnit]					=	0,
			[strDescription]				=	CASE WHEN A.strStockStatus = 'Voting' THEN 'Posted Voting Retired Stock' ELSE 'Posted Non-Voting/Other Retired Stock' END,
			[strCode]						=	@MODULE_CODE,
			[strReference]					=	A.strCertificateNo,
			[intCurrencyId]					=	0,
			[dblExchangeRate]				=	1,
			[dtmDateEntered]				=	GETDATE(),
			[dtmTransactionDate]			=	NULL,
			[strJournalLineDescription]		=	CASE WHEN A.strStockStatus = 'Voting' THEN 'Posted Voting Retired Stock' ELSE 'Posted Non-Voting/Other Retired Stock' END,
			[intJournalLineNo]				=	1,
			[ysnIsUnposted]					=	0,
			[intUserId]						=	@intUserId,
			[intEntityId]					=	@intUserId,
			[strTransactionId]				=	A.intCustomerStockId, 
			[intTransactionId]				=	A.intCustomerStockId, 
			[strTransactionType]			=	CASE WHEN A.strStockStatus = 'Voting' THEN 'Voting' ELSE 'Non-Voting/Other' END,
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
		FROM	[dbo].[tblPATCustomerStock] A
				CROSS JOIN tblPATCompanyPreference ComPref
		WHERE	A.intCustomerStockId IN (SELECT intTransactionId FROM @tmpTransacions)
		UNION ALL
		--AP CLEARING
		SELECT	
			[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmIssueDate), 0),
			[strBatchID]					=	@batchId,
			[intAccountId]					=	ComPref.intAPClearingGLAccount,
			[dblDebit]						=	0,
			[dblCredit]						=	ROUND(A.dblFaceValue,2),
			[dblDebitUnit]					=	0,
			[dblCreditUnit]					=	0,
			[strDescription]				=	'Posted AP Clearing for Retire Stock',
			[strCode]						=	@MODULE_CODE,
			[strReference]					=	A.strCertificateNo,
			[intCurrencyId]					=	0,
			[dblExchangeRate]				=	1,
			[dtmDateEntered]				=	GETDATE(),
			[dtmTransactionDate]			=	NULL,
			[strJournalLineDescription]		=	'Posted AP Clearing for Retire Stock',
			[intJournalLineNo]				=	1,
			[ysnIsUnposted]					=	0,
			[intUserId]						=	@intUserId,
			[intEntityId]					=	@intUserId,
			[strTransactionId]				=	A.intCustomerStockId, 
			[intTransactionId]				=	A.intCustomerStockId, 
			[strTransactionType]			=	'Retire Stock',
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
		FROM	[dbo].[tblPATCustomerStock] A
				CROSS JOIN tblPATCompanyPreference ComPref
		WHERE	A.intCustomerStockId IN (SELECT intTransactionId FROM @tmpTransacions)
	END
	ELSE
		BEGIN
		INSERT INTO @returnTable
		--VOTING STOCK/NON-VOTING STOCK/OTHER ISSUED
		SELECT	
			[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmIssueDate), 0),
			[strBatchID]					=	@batchId,
			[intAccountId]					=	CASE WHEN A.strStockStatus = 'Voting' THEN ComPref.intVotingStockId ELSE ComPref.intNonVotingStockId END,
			[dblDebit]						=	0,
			[dblCredit]						=	ROUND(A.dblFaceValue, 2),
			[dblDebitUnit]					=	0,
			[dblCreditUnit]					=	0,
			[strDescription]				=	CASE WHEN A.strStockStatus = 'Voting' THEN 'Posted Voting Void Retire Stock' ELSE 'Posted Non-Voting/Other Void Retire Stock' END,
			[strCode]						=	@MODULE_CODE,
			[strReference]					=	A.strCertificateNo,
			[intCurrencyId]					=	0,
			[dblExchangeRate]				=	1,
			[dtmDateEntered]				=	GETDATE(),
			[dtmTransactionDate]			=	NULL,
			[strJournalLineDescription]		=	CASE WHEN A.strStockStatus = 'Voting' THEN 'Posted Voting Void Retire Stock' ELSE 'Posted Non-Voting/Other Void Retire Stock' END,
			[intJournalLineNo]				=	1,
			[ysnIsUnposted]					=	0,
			[intUserId]						=	@intUserId,
			[intEntityId]					=	@intUserId,
			[strTransactionId]				=	A.intCustomerStockId, 
			[intTransactionId]				=	A.intCustomerStockId, 
			[strTransactionType]			=	CASE WHEN A.strStockStatus = 'Voting' THEN 'Voting' ELSE 'Non-Voting/Other' END,
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
		FROM	[dbo].[tblPATCustomerStock] A
				CROSS JOIN tblPATCompanyPreference ComPref
		WHERE	A.intCustomerStockId IN (SELECT intTransactionId FROM @tmpTransacions)
		UNION ALL
		--AP CLEARING
		SELECT	
			[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmIssueDate), 0),
			[strBatchID]					=	@batchId,
			[intAccountId]					=	ComPref.intAPClearingGLAccount,
			[dblDebit]						=	ROUND(A.dblFaceValue,2),
			[dblCredit]						=	0,
			[dblDebitUnit]					=	0,
			[dblCreditUnit]					=	0,
			[strDescription]				=	'Posted AP Clearing for Void Retire Stock',
			[strCode]						=	@MODULE_CODE,
			[strReference]					=	A.strCertificateNo,
			[intCurrencyId]					=	0,
			[dblExchangeRate]				=	1,
			[dtmDateEntered]				=	GETDATE(),
			[dtmTransactionDate]			=	NULL,
			[strJournalLineDescription]		=	'Posted AP Clearing for Void Retire Stock',
			[intJournalLineNo]				=	1,
			[ysnIsUnposted]					=	0,
			[intUserId]						=	@intUserId,
			[intEntityId]					=	@intUserId,
			[strTransactionId]				=	A.intCustomerStockId, 
			[intTransactionId]				=	A.intCustomerStockId, 
			[strTransactionType]			=	'Void Retire Stock',
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
		FROM	[dbo].[tblPATCustomerStock] A
				CROSS JOIN tblPATCompanyPreference ComPref
		WHERE	A.intCustomerStockId IN (SELECT intTransactionId FROM @tmpTransacions)
		END
	RETURN
END

GO