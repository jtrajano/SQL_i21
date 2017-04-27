CREATE FUNCTION [dbo].[fnPATCreateTransferInstrumentsGLEntries]
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
	[strRateType]				NVARCHAR (50)	 COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]          INT              DEFAULT 1 NOT NULL
)
BEGIN

	DECLARE @MODULE_NAME NVARCHAR(25) = 'Patronage';
	DECLARE @SCREEN_NAME NVARCHAR(25) = 'Transfer Instrument';
	DECLARE @MODULE_CODE NVARCHAR(5)  = 'PAT';

	DECLARE @tmpTransactions TABLE (
		[intTransactionId] [int] PRIMARY KEY,
		UNIQUE (intTransactionId)
	);

	INSERT INTO @tmpTransactions SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@transactionIds)

	--TRANSFER STOCK TO EQUITY
		INSERT INTO @returnTable
		--Voting Stock Issued(Transfer Stock to Equity)
		SELECT	
			[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmTransferDate), 0),
			[strBatchID]					=	@batchId,
			[intAccountId]					=	ComPref.intVotingStockId,
			[dblDebit]						=	B.dblQuantityTransferred,
			[dblCredit]						=	0,
			[dblDebitUnit]					=	0,
			[dblCreditUnit]					=	0,
			[strDescription]				=	C.strTransferType,
			[strCode]						=	@MODULE_CODE,
			[strReference]					=	A.strTransferNo,
			[intCurrencyId]					=	0,
			[dblExchangeRate]				=	1,
			[dtmDateEntered]				=	GETDATE(),
			[dtmTransactionDate]			=	NULL,
			[strJournalLineDescription]		=	'Voting Stock Issued',
			[intJournalLineNo]				=	1,
			[ysnIsUnposted]					=	0,
			[intUserId]						=	@intUserId,
			[intEntityId]					=	@intUserId,
			[strTransactionId]				=	A.strTransferNo, 
			[intTransactionId]				=	A.intTransferId, 
			[strTransactionType]			=	C.strTransferType,
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
		FROM	[dbo].[tblPATTransfer] A
		INNER JOIN tblPATTransferDetail B ON
			B.intTransferId = A.intTransferId 
		INNER JOIN tblPATTransferType C ON
			C.intTransferType = A.intTransferType
		CROSS JOIN tblPATCompanyPreference ComPref
		WHERE	A.intTransferId IN (SELECT intTransactionId FROM @tmpTransactions) AND A.intTransferType = 2
		UNION ALL
		--Undistributed Equity(Transfer Stock to Equity)
		SELECT	
			[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmTransferDate), 0),
			[strBatchID]					=	@batchId,
			[intAccountId]					=	D.intUndistributedEquityId,
			[dblDebit]						=	0,
			[dblCredit]						=	B.dblQuantityTransferred,
			[dblDebitUnit]					=	0,
			[dblCreditUnit]					=	0,
			[strDescription]				=	C.strTransferType,
			[strCode]						=	@MODULE_CODE,
			[strReference]					=	A.strTransferNo,
			[intCurrencyId]					=	0,
			[dblExchangeRate]				=	1,
			[dtmDateEntered]				=	GETDATE(),
			[dtmTransactionDate]			=	NULL,
			[strJournalLineDescription]		=	'Undistributed Equity',
			[intJournalLineNo]				=	1,
			[ysnIsUnposted]					=	0,
			[intUserId]						=	@intUserId,
			[intEntityId]					=	@intUserId,
			[strTransactionId]				=	A.strTransferNo, 
			[intTransactionId]				=	A.intTransferId, 
			[strTransactionType]			=	C.strTransferType,
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
		FROM	[dbo].[tblPATTransfer] A
		INNER JOIN tblPATTransferDetail B
			ON B.intTransferId = A.intTransferId 
		INNER JOIN tblPATTransferType C
			ON C.intTransferType = A.intTransferType
		INNER JOIN tblPATRefundRate D
			ON B.intToRefundTypeId = D.intRefundTypeId
		WHERE	A.intTransferId IN (SELECT intTransactionId FROM @tmpTransactions) AND A.intTransferType = 2
		UNION ALL
		--Voting/Non-voting Stock Issued(Transfer Equity to Stock)
		SELECT	
			[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmTransferDate), 0),
			[strBatchID]					=	@batchId,
			[intAccountId]					=	CASE WHEN D.strStockStatus = 'Voting' THEN ComPref.intVotingStockId ELSE ComPref.intNonVotingStockId END,
			[dblDebit]						=	0,
			[dblCredit]						=	B.dblQuantityTransferred,
			[dblDebitUnit]					=	0,
			[dblCreditUnit]					=	0,
			[strDescription]				=	C.strTransferType,
			[strCode]						=	@MODULE_CODE,
			[strReference]					=	A.strTransferNo,
			[intCurrencyId]					=	0,
			[dblExchangeRate]				=	1,
			[dtmDateEntered]				=	GETDATE(),
			[dtmTransactionDate]			=	NULL,
			[strJournalLineDescription]		=	CASE WHEN D.strStockStatus = 'Voting' THEN 'Voting Stock Issue' ELSE 'Non-Voting Stock Issue' END ,
			[intJournalLineNo]				=	1,
			[ysnIsUnposted]					=	0,
			[intUserId]						=	@intUserId,
			[intEntityId]					=	@intUserId,
			[strTransactionId]				=	A.strTransferNo, 
			[intTransactionId]				=	A.intTransferId, 
			[strTransactionType]			=	C.strTransferType,
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
		FROM	[dbo].[tblPATTransfer] A
		INNER JOIN tblPATTransferDetail B ON
			B.intTransferId = A.intTransferId 
		INNER JOIN tblPATTransferType C ON
			C.intTransferType = A.intTransferType
		INNER JOIN tblARCustomer D
			ON D.[intEntityId] = B.intTransferorId
		CROSS JOIN tblPATCompanyPreference ComPref
		WHERE	A.intTransferId IN (SELECT intTransactionId FROM @tmpTransactions) AND A.intTransferType = 4
		UNION ALL
		--Undistributed Equity(Transfer Equity to Stock)
		SELECT	
			[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmTransferDate), 0),
			[strBatchID]					=	@batchId,
			[intAccountId]					=	D.intUndistributedEquityId,
			[dblDebit]						=	B.dblQuantityTransferred,
			[dblCredit]						=	0,
			[dblDebitUnit]					=	0,
			[dblCreditUnit]					=	0,
			[strDescription]				=	C.strTransferType,
			[strCode]						=	@MODULE_CODE,
			[strReference]					=	A.strTransferNo,
			[intCurrencyId]					=	0,
			[dblExchangeRate]				=	1,
			[dtmDateEntered]				=	GETDATE(),
			[dtmTransactionDate]			=	NULL,
			[strJournalLineDescription]		=	'Undistributed Equity',
			[intJournalLineNo]				=	1,
			[ysnIsUnposted]					=	0,
			[intUserId]						=	@intUserId,
			[intEntityId]					=	@intUserId,
			[strTransactionId]				=	A.strTransferNo, 
			[intTransactionId]				=	A.intTransferId, 
			[strTransactionType]			=	C.strTransferType,
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
		FROM	[dbo].[tblPATTransfer] A
		INNER JOIN tblPATTransferDetail B
			ON B.intTransferId = A.intTransferId 
		INNER JOIN tblPATTransferType C
			ON C.intTransferType = A.intTransferType
		INNER JOIN tblPATRefundRate D
			ON B.intRefundTypeId = D.intRefundTypeId
		WHERE	A.intTransferId IN (SELECT intTransactionId FROM @tmpTransactions) AND A.intTransferType = 4
		UNION ALL
		--Undistributed Equity(Transfer Equity to Equity Reserve)
		SELECT	
			[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmTransferDate), 0),
			[strBatchID]					=	@batchId,
			[intAccountId]					=	D.intUndistributedEquityId,
			[dblDebit]						=	B.dblQuantityTransferred,
			[dblCredit]						=	0,
			[dblDebitUnit]					=	0,
			[dblCreditUnit]					=	0,
			[strDescription]				=	C.strTransferType,
			[strCode]						=	@MODULE_CODE,
			[strReference]					=	A.strTransferNo,
			[intCurrencyId]					=	0,
			[dblExchangeRate]				=	1,
			[dtmDateEntered]				=	GETDATE(),
			[dtmTransactionDate]			=	NULL,
			[strJournalLineDescription]		=	'Undistributed Equity',
			[intJournalLineNo]				=	1,
			[ysnIsUnposted]					=	0,
			[intUserId]						=	@intUserId,
			[intEntityId]					=	@intUserId,
			[strTransactionId]				=	A.strTransferNo, 
			[intTransactionId]				=	A.intTransferId, 
			[strTransactionType]			=	C.strTransferType,
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
		FROM	[dbo].[tblPATTransfer] A
		INNER JOIN tblPATTransferDetail B
			ON B.intTransferId = A.intTransferId 
		INNER JOIN tblPATTransferType C
			ON C.intTransferType = A.intTransferType
		INNER JOIN tblPATRefundRate D
			ON B.intRefundTypeId = D.intRefundTypeId
		WHERE	A.intTransferId IN (SELECT intTransactionId FROM @tmpTransactions) AND A.intTransferType = 5
		UNION ALL
		--Allocated Reserve(Transfer Equity to Equity Reserve)
		SELECT	
			[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmTransferDate), 0),
			[strBatchID]					=	@batchId,
			[intAccountId]					=	D.intAllocatedReserveId,
			[dblDebit]						=	0,
			[dblCredit]						=	B.dblQuantityTransferred,
			[dblDebitUnit]					=	0,
			[dblCreditUnit]					=	0,
			[strDescription]				=	C.strTransferType,
			[strCode]						=	@MODULE_CODE,
			[strReference]					=	A.strTransferNo,
			[intCurrencyId]					=	0,
			[dblExchangeRate]				=	1,
			[dtmDateEntered]				=	GETDATE(),
			[dtmTransactionDate]			=	NULL,
			[strJournalLineDescription]		=	'Allocated Reserve',
			[intJournalLineNo]				=	1,
			[ysnIsUnposted]					=	0,
			[intUserId]						=	@intUserId,
			[intEntityId]					=	@intUserId,
			[strTransactionId]				=	A.strTransferNo, 
			[intTransactionId]				=	A.intTransferId, 
			[strTransactionType]			=	C.strTransferType,
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
		FROM	[dbo].[tblPATTransfer] A
		INNER JOIN tblPATTransferDetail B
			ON B.intTransferId = A.intTransferId 
		INNER JOIN tblPATTransferType C
			ON C.intTransferType = A.intTransferType
		INNER JOIN tblPATRefundRate D
			ON B.intRefundTypeId = D.intRefundTypeId
		WHERE	A.intTransferId IN (SELECT intTransactionId FROM @tmpTransactions) AND A.intTransferType = 5
		UNION ALL
		--Undistributed Equity(Transfer Equity Reserve to Equity)
		SELECT	
			[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmTransferDate), 0),
			[strBatchID]					=	@batchId,
			[intAccountId]					=	D.intUndistributedEquityId,
			[dblDebit]						=	0,
			[dblCredit]						=	B.dblQuantityTransferred,
			[dblDebitUnit]					=	0,
			[dblCreditUnit]					=	0,
			[strDescription]				=	C.strTransferType,
			[strCode]						=	@MODULE_CODE,
			[strReference]					=	A.strTransferNo,
			[intCurrencyId]					=	0,
			[dblExchangeRate]				=	1,
			[dtmDateEntered]				=	GETDATE(),
			[dtmTransactionDate]			=	NULL,
			[strJournalLineDescription]		=	'Undistributed Equity',
			[intJournalLineNo]				=	1,
			[ysnIsUnposted]					=	0,
			[intUserId]						=	@intUserId,
			[intEntityId]					=	@intUserId,
			[strTransactionId]				=	A.strTransferNo, 
			[intTransactionId]				=	A.intTransferId, 
			[strTransactionType]			=	C.strTransferType,
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
		FROM	[dbo].[tblPATTransfer] A
		INNER JOIN tblPATTransferDetail B
			ON B.intTransferId = A.intTransferId 
		INNER JOIN tblPATTransferType C
			ON C.intTransferType = A.intTransferType
		INNER JOIN tblPATRefundRate D
			ON B.intToRefundTypeId = D.intRefundTypeId
		WHERE	A.intTransferId IN (SELECT intTransactionId FROM @tmpTransactions) AND A.intTransferType = 6
		UNION ALL
		--Allocated Reserve(Transfer Equity Reserve to Equity)
		SELECT	
			[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmTransferDate), 0),
			[strBatchID]					=	@batchId,
			[intAccountId]					=	D.intAllocatedReserveId,
			[dblDebit]						=	B.dblQuantityTransferred,
			[dblCredit]						=	0,
			[dblDebitUnit]					=	0,
			[dblCreditUnit]					=	0,
			[strDescription]				=	C.strTransferType,
			[strCode]						=	@MODULE_CODE,
			[strReference]					=	A.strTransferNo,
			[intCurrencyId]					=	0,
			[dblExchangeRate]				=	1,
			[dtmDateEntered]				=	GETDATE(),
			[dtmTransactionDate]			=	NULL,
			[strJournalLineDescription]		=	'Allocated Reserve',
			[intJournalLineNo]				=	1,
			[ysnIsUnposted]					=	0,
			[intUserId]						=	@intUserId,
			[intEntityId]					=	@intUserId,
			[strTransactionId]				=	A.strTransferNo, 
			[intTransactionId]				=	A.intTransferId, 
			[strTransactionType]			=	C.strTransferType,
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
		FROM	[dbo].[tblPATTransfer] A
		INNER JOIN tblPATTransferDetail B
			ON B.intTransferId = A.intTransferId 
		INNER JOIN tblPATTransferType C
			ON C.intTransferType = A.intTransferType
		INNER JOIN tblPATRefundRate D
			ON B.intToRefundTypeId = D.intRefundTypeId
		WHERE	A.intTransferId IN (SELECT intTransactionId FROM @tmpTransactions) AND A.intTransferType = 6
	RETURN
END