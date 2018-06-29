CREATE PROCEDURE [dbo].[uspPATPostTransferInstruments]
	@intTransferId INT = NULL,
	@ysnPosted BIT = NULL,
	@intUserId INT = NULL,
	@postPreview BIT = NULL,
	@batchIdUsed NVARCHAR(40) = NULL OUTPUT,
	@successfulCount INT = 0 OUTPUT,
	@invalidCount INT = 0 OUTPUT,
	@success BIT = 0 OUTPUT 
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

--DECLARE VARIABLES
DECLARE @PostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully posted.'
DECLARE @UnpostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully unposted.'
DECLARE @MODULE_NAME NVARCHAR(25) = 'Patronage'
DECLARE @MODULE_CODE NVARCHAR(25) = 'PAT'
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Transfer Instrument'
DECLARE @totalRecords INT
DECLARE @GLEntries AS RecapTableType 
DECLARE @error NVARCHAR(200)
DECLARE @dateToday AS DATETIME = GETDATE();
DECLARE @batchId NVARCHAR(40);


IF(@batchId IS NULL)
	EXEC uspSMGetStartingNumber 3, @batchId OUT

SET @batchIdUsed = @batchId;

	SELECT	T.intTransferId,
			TD.intTransferDetailId,
			T.intTransferType,
			TD.intTransferorId,
			TD.strEquityType,
			TD.intCustomerEquityId,
			TD.intFiscalYearId,
			TD.intPatronageCategoryId,
			TD.intRefundTypeId,
			TD.intCustomerStockId,
			TD.dblParValue,
			TD.dblQuantityAvailable,
			TD.intTransfereeId,
			TD.intToFiscalYearId,
			TD.intToRefundTypeId,
			TD.intToStockId,
			TD.dblTransferPercentage,
			TD.strToCertificateNo,
			TD.dtmToIssueDate,
			TD.strToStockStatus,
			TD.dblToParValue,
			TD.dblQuantityTransferred
	INTO #tempTransferDetails
	FROM tblPATTransfer T
	INNER JOIN tblPATTransferDetail TD
		ON TD.intTransferId = T.intTransferId
	WHERE T.intTransferId = @intTransferId

	SELECT @totalRecords = COUNT(*) FROM #tempTransferDetails

	BEGIN TRANSACTION
	---------------- BEGIN - GET GL ENTRIES ----------------
	IF(@ysnPosted = 1)
	BEGIN
		INSERT INTO @GLEntries(
			[dtmDate], 
			[strBatchId], 
			[intAccountId],
			[dblDebit],
			[dblCredit],
			[dblDebitUnit],
			[dblCreditUnit],
			[strDescription],
			[strCode],
			[strReference],
			[intCurrencyId],
			[dtmDateEntered],
			[dtmTransactionDate],
			[strJournalLineDescription],
			[intJournalLineNo],
			[ysnIsUnposted],
			[intUserId],
			[intEntityId],
			[strTransactionId],
			[intTransactionId],
			[strTransactionType],
			[strTransactionForm],
			[strModuleName],
			[dblDebitForeign],
			[dblDebitReport],
			[dblCreditForeign],
			[dblCreditReport],
			[dblReportingRate],
			[dblForeignRate],
			[strRateType]
		)
		--Voting Stock Issued(Transfer Stock to Equity)
		SELECT	
			[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmTransferDate), 0),
			[strBatchID]					=	@batchId COLLATE Latin1_General_CI_AS,
			[intAccountId]					=	ComPref.intVotingStockId,
			[dblDebit]						=	B.dblQuantityTransferred,
			[dblCredit]						=	0,
			[dblDebitUnit]					=	0,
			[dblCreditUnit]					=	0,
			[strDescription]				=	'Voting Stock Issued',
			[strCode]						=	@MODULE_CODE,
			[strReference]					=	A.strTransferNo,
			[intCurrencyId]					=	1,
			[dtmDateEntered]				=	GETDATE(),
			[dtmTransactionDate]			=	NULL,
			[strJournalLineDescription]		=	C.strTransferType,
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
			[strRateType]					=	NULL
		FROM	[dbo].[tblPATTransfer] A
		INNER JOIN tblPATTransferDetail B ON
			B.intTransferId = A.intTransferId 
		INNER JOIN tblPATTransferType C ON
			C.intTransferType = A.intTransferType
		CROSS JOIN tblPATCompanyPreference ComPref
		WHERE	A.intTransferId IN (SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@intTransferId)) AND A.intTransferType = 2
		UNION ALL
		--Undistributed Equity(Transfer Stock to Equity)
		SELECT	
			[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmTransferDate), 0),
			[strBatchID]					=	@batchId COLLATE Latin1_General_CI_AS,
			[intAccountId]					=	D.intUndistributedEquityId,
			[dblDebit]						=	0,
			[dblCredit]						=	B.dblQuantityTransferred,
			[dblDebitUnit]					=	0,
			[dblCreditUnit]					=	0,
			[strDescription]				=	'Undistributed Equity',
			[strCode]						=	@MODULE_CODE,
			[strReference]					=	A.strTransferNo,
			[intCurrencyId]					=	1,
			[dtmDateEntered]				=	GETDATE(),
			[dtmTransactionDate]			=	NULL,
			[strJournalLineDescription]		=	C.strTransferType,
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
			[strRateType]					=	NULL
		FROM	[dbo].[tblPATTransfer] A
		INNER JOIN tblPATTransferDetail B
			ON B.intTransferId = A.intTransferId 
		INNER JOIN tblPATTransferType C
			ON C.intTransferType = A.intTransferType
		INNER JOIN tblPATRefundRate D
			ON B.intToRefundTypeId = D.intRefundTypeId
		WHERE	A.intTransferId IN (SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@intTransferId)) AND A.intTransferType = 2
		UNION ALL
		--Voting/Non-voting Stock Issued(Transfer Equity to Stock)
		SELECT	
			[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmTransferDate), 0),
			[strBatchID]					=	@batchId COLLATE Latin1_General_CI_AS,
			[intAccountId]					=	CASE WHEN D.strStockStatus = 'Voting' THEN ComPref.intVotingStockId ELSE ComPref.intNonVotingStockId END,
			[dblDebit]						=	0,
			[dblCredit]						=	B.dblQuantityTransferred,
			[dblDebitUnit]					=	0,
			[dblCreditUnit]					=	0,
			[strDescription]				=	CASE WHEN D.strStockStatus = 'Voting' THEN 'Voting Stock Issue' ELSE 'Non-Voting Stock Issue' END ,
			[strCode]						=	@MODULE_CODE,
			[strReference]					=	A.strTransferNo,
			[intCurrencyId]					=	1,
			[dtmDateEntered]				=	GETDATE(),
			[dtmTransactionDate]			=	NULL,
			[strJournalLineDescription]		=	C.strTransferType,
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
			[strRateType]					=	NULL
		FROM	[dbo].[tblPATTransfer] A
		INNER JOIN tblPATTransferDetail B ON
			B.intTransferId = A.intTransferId 
		INNER JOIN tblPATTransferType C ON
			C.intTransferType = A.intTransferType
		INNER JOIN tblARCustomer D
			ON D.intEntityId = B.intTransferorId
		CROSS JOIN tblPATCompanyPreference ComPref
		WHERE	A.intTransferId IN (SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@intTransferId)) AND A.intTransferType = 4
		UNION ALL
		--Undistributed Equity(Transfer Equity to Stock)
		SELECT	
			[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmTransferDate), 0),
			[strBatchID]					=	@batchId COLLATE Latin1_General_CI_AS,
			[intAccountId]					=	D.intUndistributedEquityId,
			[dblDebit]						=	B.dblQuantityTransferred,
			[dblCredit]						=	0,
			[dblDebitUnit]					=	0,
			[dblCreditUnit]					=	0,
			[strDescription]				=	'Undistributed Equity',
			[strCode]						=	@MODULE_CODE,
			[strReference]					=	A.strTransferNo,
			[intCurrencyId]					=	1,
			[dtmDateEntered]				=	GETDATE(),
			[dtmTransactionDate]			=	NULL,
			[strJournalLineDescription]		=	C.strTransferType,
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
			[strRateType]					=	NULL
		FROM	[dbo].[tblPATTransfer] A
		INNER JOIN tblPATTransferDetail B
			ON B.intTransferId = A.intTransferId 
		INNER JOIN tblPATTransferType C
			ON C.intTransferType = A.intTransferType
		INNER JOIN tblPATRefundRate D
			ON B.intRefundTypeId = D.intRefundTypeId
		WHERE	A.intTransferId IN (SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@intTransferId)) AND A.intTransferType = 4
		UNION ALL
		--Undistributed Equity(Transfer Equity to Equity Reserve)
		SELECT	
			[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmTransferDate), 0),
			[strBatchID]					=	@batchId COLLATE Latin1_General_CI_AS,
			[intAccountId]					=	D.intUndistributedEquityId,
			[dblDebit]						=	B.dblQuantityTransferred,
			[dblCredit]						=	0,
			[dblDebitUnit]					=	0,
			[dblCreditUnit]					=	0,
			[strDescription]				=	'Undistributed Equity',
			[strCode]						=	@MODULE_CODE,
			[strReference]					=	A.strTransferNo,
			[intCurrencyId]					=	1,
			[dtmDateEntered]				=	GETDATE(),
			[dtmTransactionDate]			=	NULL,
			[strJournalLineDescription]		=	C.strTransferType,
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
			[strRateType]					=	NULL
		FROM	[dbo].[tblPATTransfer] A
		INNER JOIN tblPATTransferDetail B
			ON B.intTransferId = A.intTransferId 
		INNER JOIN tblPATTransferType C
			ON C.intTransferType = A.intTransferType
		INNER JOIN tblPATRefundRate D
			ON B.intRefundTypeId = D.intRefundTypeId
		WHERE	A.intTransferId IN (SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@intTransferId)) AND A.intTransferType = 5
		UNION ALL
		--Allocated Reserve(Transfer Equity to Equity Reserve)
		SELECT	
			[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmTransferDate), 0),
			[strBatchID]					=	@batchId COLLATE Latin1_General_CI_AS,
			[intAccountId]					=	D.intAllocatedReserveId,
			[dblDebit]						=	0,
			[dblCredit]						=	B.dblQuantityTransferred,
			[dblDebitUnit]					=	0,
			[dblCreditUnit]					=	0,
			[strDescription]				=	'Allocated Reserve',
			[strCode]						=	@MODULE_CODE,
			[strReference]					=	A.strTransferNo,
			[intCurrencyId]					=	1,
			[dtmDateEntered]				=	GETDATE(),
			[dtmTransactionDate]			=	NULL,
			[strJournalLineDescription]		=	C.strTransferType,
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
			[strRateType]					=	NULL
		FROM	[dbo].[tblPATTransfer] A
		INNER JOIN tblPATTransferDetail B
			ON B.intTransferId = A.intTransferId 
		INNER JOIN tblPATTransferType C
			ON C.intTransferType = A.intTransferType
		INNER JOIN tblPATRefundRate D
			ON B.intRefundTypeId = D.intRefundTypeId
		WHERE	A.intTransferId IN (SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@intTransferId)) AND A.intTransferType = 5
		UNION ALL
		--Undistributed Equity(Transfer Equity Reserve to Equity)
		SELECT	
			[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmTransferDate), 0),
			[strBatchID]					=	@batchId COLLATE Latin1_General_CI_AS,
			[intAccountId]					=	D.intUndistributedEquityId,
			[dblDebit]						=	0,
			[dblCredit]						=	B.dblQuantityTransferred,
			[dblDebitUnit]					=	0,
			[dblCreditUnit]					=	0,
			[strDescription]				=	'Undistributed Equity',
			[strCode]						=	@MODULE_CODE,
			[strReference]					=	A.strTransferNo,
			[intCurrencyId]					=	1,
			[dtmDateEntered]				=	GETDATE(),
			[dtmTransactionDate]			=	NULL,
			[strJournalLineDescription]		=	C.strTransferType,
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
			[strRateType]					=	NULL
		FROM	[dbo].[tblPATTransfer] A
		INNER JOIN tblPATTransferDetail B
			ON B.intTransferId = A.intTransferId 
		INNER JOIN tblPATTransferType C
			ON C.intTransferType = A.intTransferType
		INNER JOIN tblPATRefundRate D
			ON B.intToRefundTypeId = D.intRefundTypeId
		WHERE	A.intTransferId IN (SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@intTransferId)) AND A.intTransferType = 6
		UNION ALL
		--Allocated Reserve(Transfer Equity Reserve to Equity)
		SELECT	
			[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmTransferDate), 0),
			[strBatchID]					=	@batchId COLLATE Latin1_General_CI_AS,
			[intAccountId]					=	D.intAllocatedReserveId,
			[dblDebit]						=	B.dblQuantityTransferred,
			[dblCredit]						=	0,
			[dblDebitUnit]					=	0,
			[dblCreditUnit]					=	0,
			[strDescription]				=	'Allocated Reserve',
			[strCode]						=	@MODULE_CODE,
			[strReference]					=	A.strTransferNo,
			[intCurrencyId]					=	1,
			[dtmDateEntered]				=	GETDATE(),
			[dtmTransactionDate]			=	NULL,
			[strJournalLineDescription]		=	C.strTransferType,
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
			[strRateType]					=	NULL
		FROM	[dbo].[tblPATTransfer] A
		INNER JOIN tblPATTransferDetail B
			ON B.intTransferId = A.intTransferId 
		INNER JOIN tblPATTransferType C
			ON C.intTransferType = A.intTransferType
		INNER JOIN tblPATRefundRate D
			ON B.intToRefundTypeId = D.intRefundTypeId
		WHERE	A.intTransferId IN (SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@intTransferId)) AND A.intTransferType = 6
	END
	ELSE
	BEGIN
		INSERT INTO @GLEntries(
			[strTransactionId]
			,[intTransactionId]
			,[dtmDate]
			,[strBatchId]
			,[intAccountId]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[strDescription]
			,[strCode]
			,[strReference]
			,[intCurrencyId]
			,[dblExchangeRate]
			,[dtmDateEntered]
			,[dtmTransactionDate]
			,[strJournalLineDescription]
			,[intJournalLineNo]
			,[ysnIsUnposted]
			,[intUserId]
			,[intEntityId]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]
			,[dblDebitForeign]           
			,[dblDebitReport]            
			,[dblCreditForeign]          
			,[dblCreditReport]           
			,[dblReportingRate]          
			,[dblForeignRate]
			,[strRateType]
		)
		SELECT	
			[strTransactionId]
			,[intTransactionId]
			,[dtmDate]
			,strBatchId = @batchId COLLATE Latin1_General_CI_AS
			,[intAccountId]
			,[dblDebit] = [dblCredit]		-- (Debit -> Credit)
			,[dblCredit] = [dblDebit]		-- (Debit <- Credit)
			,[dblDebitUnit] = [dblCreditUnit]	-- (Debit Unit -> Credit Unit)
			,[dblCreditUnit] = [dblDebitUnit]	-- (Debit Unit <- Credit Unit)
			,[strDescription]
			,[strCode]
			,[strReference]
			,[intCurrencyId]
			,[dblExchangeRate]
			,dtmDateEntered = GETDATE()
			,[dtmTransactionDate]
			,[strJournalLineDescription]
			,[intJournalLineNo]
			,ysnIsUnposted = 1
			,intUserId = @intUserId
			,[intEntityId]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]
			,[dblDebitForeign]           
			,[dblDebitReport]            
			,[dblCreditForeign]          
			,[dblCreditReport]           
			,[dblReportingRate]          
			,[dblForeignRate]
			,NULL
		FROM	tblGLDetail 
		WHERE	intTransactionId IN (SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@intTransferId))
		AND ysnIsUnposted = 0 AND strTransactionForm = @SCREEN_NAME AND strModuleName = @MODULE_NAME
		ORDER BY intGLDetailId

		UPDATE tblGLDetail SET ysnIsUnposted = 1
		WHERE intTransactionId = @intTransferId 
		AND strModuleName = @MODULE_NAME AND strTransactionForm = @SCREEN_NAME
	END
	---------------- END - GET GL ENTRIES ----------------
	
	---------------- BEGIN - BOOK GL ----------------
	BEGIN TRY
	IF(@postPreview = 0)
	BEGIN
		SELECT * FROM @GLEntries
		EXEC uspGLBookEntries @GLEntries, @ysnPosted
	END
	ELSE
	BEGIN
		SELECT * FROM @GLEntries
			INSERT INTO tblGLPostRecap(
			 [strTransactionId]
			,[intTransactionId]
			,[intAccountId]
			,[strDescription]
			,[strJournalLineDescription]
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
			,[dtmDateEntered]
			,[strBatchId]
			,[strCode]
			,[strModuleName]
			,[strTransactionForm]
			,[strTransactionType]
			,[strAccountId]
			,[strAccountGroup]
		)
		SELECT
			[strTransactionId]
			,A.[intTransactionId]
			,A.[intAccountId]
			,A.[strDescription]
			,A.[strJournalLineDescription]
			,A.[strReference]	
			,A.[dtmTransactionDate]
			,A.[dblDebit]
			,A.[dblCredit]
			,A.[dblDebitUnit]
			,A.[dblCreditUnit]
			,A.[dtmDate]
			,A.[ysnIsUnposted]
			,A.[intConcurrencyId]	
			,A.[dblExchangeRate]
			,A.[intUserId]
			,A.[dtmDateEntered]
			,A.[strBatchId]
			,A.[strCode]
			,A.[strModuleName]
			,A.[strTransactionForm]
			,A.[strTransactionType]
			,B.strAccountId
			,C.strAccountGroup
		FROM @GLEntries A
		INNER JOIN dbo.tblGLAccount B 
			ON A.intAccountId = B.intAccountId
		INNER JOIN dbo.tblGLAccountGroup C
			ON B.intAccountGroupId = C.intAccountGroupId
	END
	END TRY
	BEGIN CATCH
		SET @error = ERROR_MESSAGE()
		RAISERROR(@error, 16, 1);
		GOTO Post_Rollback
	END CATCH
	---------------- END - BOOK GL ----------------
	
	IF(@postPreview = 1)
		GOTO Post_Commit;

	---------------- BEGIN - UPDATE TABLES ----------------
	UPDATE tblPATTransfer SET ysnPosted = @ysnPosted
	WHERE intTransferId = @intTransferId

	IF EXISTS(SELECT 1 FROM #tempTransferDetails WHERE intTransferType = 2)
	BEGIN
		---------------------------- TRANSFER STOCK TO EQUITY -----------------------------
		MERGE tblPATCustomerEquity AS CE
		USING (SELECT * FROM #tempTransferDetails WHERE intTransferType = 2) TD
			ON (TD.intToFiscalYearId = CE.intFiscalYearId AND TD.intTransferorId = CE.intCustomerId AND TD.intToRefundTypeId = CE.intRefundTypeId AND CE.strEquityType = 'Undistributed')
			WHEN MATCHED
				THEN UPDATE SET CE.dblEquity = CASE WHEN @ysnPosted = 1 THEN CE.dblEquity + TD.dblQuantityTransferred ELSE CE.dblEquity - TD.dblQuantityTransferred END
			WHEN NOT MATCHED BY TARGET
				THEN INSERT (intCustomerId, intFiscalYearId, strEquityType, intRefundTypeId, dblEquity, dblEquityPaid, intConcurrencyId)
				VALUES(TD.intTransferorId, TD.intToFiscalYearId, 'Undistributed', TD.intToRefundTypeId, TD.dblQuantityTransferred, 0, 1);

		UPDATE CS
		SET CS.strActivityStatus = CASE WHEN @ysnPosted = 1 THEN 'Xferred' ELSE 'Open' END,
			CS.dtmTransferredDate = GETDATE()
		FROM tblPATCustomerStock AS CS 
		INNER JOIN #tempTransferDetails AS tempTD
			ON CS.intCustomerStockId = tempTD.intCustomerStockId

	END

	IF EXISTS(SELECT 1 FROM #tempTransferDetails WHERE intTransferType = 4)
	BEGIN
		---------------------  TRANSFER EQUITY TO STOCK ---------------------------------
		IF(@ysnPosted = 1)
		BEGIN
			DECLARE @certificateNo NVARCHAR(MAX), @issueStkNo NVARCHAR(50);
			SET @certificateNo = (SELECT TOP 1 strCertificateNo FROM #tempTransferDetails tempTD INNER JOIN tblPATIssueStock CS ON tempTD.strToCertificateNo = CS.strCertificateNo);
			EXEC [dbo].[uspSMGetStartingNumber] 126, @issueStkNo out;
			IF (@certificateNo = '' OR @certificateNo IS NULL)
			BEGIN
				INSERT INTO tblPATIssueStock(strIssueNo, intCustomerPatronId, intStockId, strCertificateNo, strStockStatus, dblSharesNo, dtmIssueDate, dblParValue, dblFaceValue, ysnPosted, intConcurrencyId)
				SELECT @issueStkNo,intTransferorId, intToStockId, strToCertificateNo, strToStockStatus, dblQuantityTransferred, dtmToIssueDate, dblToParValue, (dblQuantityTransferred * dblToParValue), 0, 1
				FROM #tempTransferDetails WHERE intTransferType = 4;
			END
			ELSE
			BEGIN
				SET @error = @certificateNo + ' already exists.';
				RAISERROR(@error, 16, 1);
				GOTO Post_Rollback;
			END
		END
		ELSE
		BEGIN
			IF NOT EXISTS(SELECT * FROM #tempTransferDetails tempTD INNER JOIN tblPATIssueStock CS ON tempTD.strToCertificateNo = CS.strCertificateNo)
			BEGIN
				DELETE FROM tblPATIssueStock WHERE strCertificateNo IN (SELECT strToCertificateNo FROM #tempTransferDetails where intTransferType = 4)
			END
			ELSE
			BEGIN
				RAISERROR('Issued stocks are already posted.', 16, 1);
				GOTO Post_Rollback;
			END
		END

		UPDATE CE
		SET CE.dblEquity = CASE WHEN @ysnPosted = 1 THEN CE.dblEquity - tempTD.dblQuantityTransferred ELSE CE.dblEquity + tempTD.dblQuantityTransferred END
		FROM tblPATCustomerEquity CE
		INNER JOIN #tempTransferDetails AS tempTD
			ON CE.intCustomerEquityId = tempTD.intCustomerEquityId AND tempTD.intTransferType = 4;
	END

	IF ExISTS(SELECT 1 FROM #tempTransferDetails WHERE intTransferType = 5)
	BEGIN
		---------------------  TRANSFER EQUITY TO EQUITY RESERVE ---------------------------------

		-- Apply adjustment to target record
		MERGE tblPATCustomerEquity CE
		USING (SELECT * FROM #tempTransferDetails WHERE intTransferType = 5) TD
			ON (CE.intFiscalYearId = TD.intToFiscalYearId AND CE.intCustomerId = TD.intTransfereeId AND CE.intRefundTypeId = TD.intToRefundTypeId
				AND CE.strEquityType = 'Reserve')
			WHEN MATCHED
				THEN UPDATE SET CE.dblEquity = CASE WHEN @ysnPosted = 1 THEN CE.dblEquity + TD.dblQuantityTransferred ELSE CE.dblEquity - TD.dblQuantityTransferred END
			WHEN NOT MATCHED BY TARGET
				THEN INSERT (intCustomerId, intFiscalYearId, strEquityType, intRefundTypeId, dblEquity, dblEquityPaid, intConcurrencyId)
				VALUES (TD.intTransfereeId, TD.intToFiscalYearId, 'Reserve', TD.intToRefundTypeId, TD.dblQuantityTransferred, 0, 1);

		-- Apply adjustment to source record
		MERGE tblPATCustomerEquity CE
		USING (SELECT * FROM #tempTransferDetails WHERE intTransferType = 5) tempTD
			ON (CE.intCustomerId = tempTD.intTransferorId AND CE.intFiscalYearId = tempTD.intFiscalYearId AND CE.intRefundTypeId = tempTD.intRefundTypeId 
				AND CE.strEquityType = 'Undistributed')
			WHEN MATCHED
				THEN UPDATE SET CE.dblEquity = CASE WHEN @ysnPosted = 1 THEN CE.dblEquity - tempTD.dblQuantityTransferred ELSE CE.dblEquity + tempTD.dblQuantityTransferred END
			WHEN NOT MATCHED BY TARGET
				THEN INSERT (intCustomerId, intFiscalYearId, strEquityType, intRefundTypeId, dblEquity, dblEquityPaid, intConcurrencyId)
				VALUES (tempTD.intTransfereeId, tempTD.intFiscalYearId, 'Undistributed', tempTD.intRefundTypeId, tempTD.dblQuantityTransferred, 0, 1);
		
	END

	IF ExISTS(SELECT 1 FROM #tempTransferDetails WHERE intTransferType = 6)
	BEGIN
		---------------------  TRANSFER EQUITY RESERVE TO EQUITY ---------------------------------
		
		-- Apply adjustment to target record
		MERGE tblPATCustomerEquity CE
		USING (SELECT * FROM #tempTransferDetails WHERE intTransferType = 6) TD
			ON (TD.intToFiscalYearId = CE.intFiscalYearId AND CE.intCustomerId = TD.intTransferorId AND CE.intRefundTypeId = TD.intToRefundTypeId AND CE.strEquityType = 'Undistributed')
			WHEN MATCHED
				THEN UPDATE SET CE.dblEquity = CASE WHEN @ysnPosted = 1 THEN CE.dblEquity + TD.dblQuantityTransferred ELSE CE.dblEquity - TD.dblQuantityTransferred END
			WHEN NOT MATCHED BY TARGET
				THEN INSERT (intCustomerId, intFiscalYearId, strEquityType, intRefundTypeId, dblEquity, intConcurrencyId)
				VALUES (TD.intTransferorId, TD.intToFiscalYearId, 'Undistributed', TD.intToRefundTypeId, TD.dblQuantityTransferred, 1);

		-- Apply adjustment to source record
		MERGE tblPATCustomerEquity CE
		USING (SELECT * FROM #tempTransferDetails WHERE intTransferType = 6) tempTD
			ON (tempTD.intFiscalYearId = CE.intFiscalYearId AND CE.intCustomerId = tempTD.intTransferorId AND CE.intRefundTypeId = tempTD.intRefundTypeId AND CE.strEquityType = 'Reserve')
			WHEN MATCHED
				THEN UPDATE SET CE.dblEquity = CASE WHEN @ysnPosted = 1 THEN CE.dblEquity - tempTD.dblQuantityTransferred ELSE CE.dblEquity + tempTD.dblQuantityTransferred END
			WHEN NOT MATCHED BY TARGET
				THEN INSERT (intCustomerId, intFiscalYearId, strEquityType, intRefundTypeId, dblEquity, intConcurrencyId)
				VALUES (tempTD.intTransferorId, tempTD.intFiscalYearId, 'Reserve', tempTD.intRefundTypeId, tempTD.dblQuantityTransferred, 1);			
	END
	---------------- END - UPDATE TABLES ----------------
	
---------------------------------------------------------------------------------------------------------------------------------------
IF @@ERROR <> 0	GOTO Post_Rollback;

GOTO Post_Commit;

Post_Commit:
	COMMIT TRANSACTION
	SET @success = 1
	SET @successfulCount = @totalRecords
	GOTO Post_Exit

Post_Rollback:
	ROLLBACK TRANSACTION	
	SET @success = 0
	GOTO Post_Exit

Post_Exit:
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tempTransferDetails')) DROP TABLE #tempTransferDetails
END