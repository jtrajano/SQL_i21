CREATE PROCEDURE [dbo].[uspPATPostEquityPayments]
	@intEquityPayId AS INT = NULL,
	@ysnPosted AS BIT = NULL,
	@intUserId AS INT = NULL,
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
DECLARE @MODULE_CODE NVARCHAR(5)  = 'PAT'
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Equity Payment'
DECLARE @totalRecords INT
DECLARE @GLEntries AS RecapTableType 
DECLARE @error NVARCHAR(200)
DECLARE @dateToday AS DATETIME = GETDATE();
DECLARE @batchId NVARCHAR(40);


IF EXISTS(SELECT 1 FROM tblPATCompanyPreference WHERE intAPClearingGLAccount IS NULL)
BEGIN
	SET @error = 'Please setup AP Clearing account from Patronage Setup Screen.';
	RAISERROR(@error, 16, 1);
	GOTO Post_Rollback
END

IF(@batchId IS NULL)
	EXEC uspSMGetStartingNumber 3, @batchId OUT
	

	SELECT	EP.intEquityPayId,
			EP.strPaymentNumber,
			EP.dblPayoutPercent,
			EPS.intCustomerPatronId,
			EPD.intCustomerEquityId,
			EPD.intFiscalYearId,
			EPD.intRefundTypeId,
			EPD.strEquityType,
			EPD.dblEquityPay
	INTO #tempEquityPayment
	FROM tblPATEquityPay EP
	INNER JOIN tblPATEquityPaySummary EPS
		ON EPS.intEquityPayId = EP.intEquityPayId
	INNER JOIN tblPATEquityPayDetail EPD
		ON EPD.intEquityPaySummaryId = EPS.intEquityPaySummaryId
	WHERE EP.intEquityPayId = @intEquityPayId


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
		SELECT	
			[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmPaymentDate), 0),
			[strBatchID]					=	@batchId COLLATE Latin1_General_CI_AS,
			[intAccountId]					=	D.intUndistributedEquityId,
			[dblDebit]						=	SUM(ROUND(C.dblEquityPay,2)),
			[dblCredit]						=	0,
			[dblDebitUnit]					=	0,
			[dblCreditUnit]					=	0,
			[strDescription]				=	'Undistributed Equity',
			[strCode]						=	@MODULE_CODE,
			[strReference]					=	A.strPaymentNumber,
			[intCurrencyId]					=	1,
			[dtmDateEntered]				=	GETDATE(),
			[dtmTransactionDate]			=	A.dtmPaymentDate,
			[strJournalLineDescription]		=	'Undistributed Equity',
			[intJournalLineNo]				=	1,
			[ysnIsUnposted]					=	0,
			[intUserId]						=	@intUserId,
			[intEntityId]					=	@intUserId,
			[strTransactionId]				=	A.strPaymentNumber, 
			[intTransactionId]				=	A.intEquityPayId, 
			[strTransactionType]			=	@SCREEN_NAME,
			[strTransactionForm]			=	@SCREEN_NAME,
			[strModuleName]					=	@MODULE_NAME,
			[dblDebitForeign]				=	0,      
			[dblDebitReport]				=	0,
			[dblCreditForeign]				=	0,
			[dblCreditReport]				=	0,
			[dblReportingRate]				=	0,
			[dblForeignRate]				=	0,
			[strRateType]					=	NULL
		FROM	[dbo].[tblPATEquityPay] A
		INNER JOIN tblPATEquityPaySummary B ON
			B.intEquityPayId = A.intEquityPayId
		INNER JOIN tblPATEquityPayDetail C ON
			C.intEquityPaySummaryId = B.intEquityPaySummaryId
		INNER JOIN tblPATRefundRate D ON
			D.intRefundTypeId = C.intRefundTypeId
		WHERE	A.intEquityPayId IN (SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@intEquityPayId)) AND C.strEquityType = 'Undistributed' AND C.dblEquityPay <> 0
		GROUP BY D.intUndistributedEquityId, A.dtmPaymentDate, A.strPaymentNumber, A.intEquityPayId
		UNION ALL
		--Allocated Reserve
		SELECT	
			[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmPaymentDate), 0),
			[strBatchID]					=	@batchId COLLATE Latin1_General_CI_AS,
			[intAccountId]					=	D.intAllocatedReserveId,
			[dblDebit]						=	SUM(ROUND(C.dblEquityPay,2)),
			[dblCredit]						=	0,
			[dblDebitUnit]					=	0,
			[dblCreditUnit]					=	0,
			[strDescription]				=	'Reserve Equity',
			[strCode]						=	@MODULE_CODE,
			[strReference]					=	A.strPaymentNumber,
			[intCurrencyId]					=	1,
			[dtmDateEntered]				=	GETDATE(),
			[dtmTransactionDate]			=	A.dtmPaymentDate,
			[strJournalLineDescription]		=	'Reserve Equity',
			[intJournalLineNo]				=	1,
			[ysnIsUnposted]					=	0,
			[intUserId]						=	@intUserId,
			[intEntityId]					=	@intUserId,
			[strTransactionId]				=	A.strPaymentNumber, 
			[intTransactionId]				=	A.intEquityPayId, 
			[strTransactionType]			=	@SCREEN_NAME,
			[strTransactionForm]			=	@SCREEN_NAME,
			[strModuleName]					=	@MODULE_NAME,
			[dblDebitForeign]				=	0,      
			[dblDebitReport]				=	0,
			[dblCreditForeign]				=	0,
			[dblCreditReport]				=	0,
			[dblReportingRate]				=	0,
			[dblForeignRate]				=	0,
			[strRateType]					=	NULL
		FROM	[dbo].[tblPATEquityPay] A
		INNER JOIN tblPATEquityPaySummary B ON
			B.intEquityPayId = A.intEquityPayId
		INNER JOIN tblPATEquityPayDetail C ON
			C.intEquityPaySummaryId = B.intEquityPaySummaryId
		INNER JOIN tblPATRefundRate D ON
			D.intRefundTypeId = C.intRefundTypeId
		WHERE	A.intEquityPayId IN (SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@intEquityPayId)) AND C.strEquityType = 'Reserve' AND C.dblEquityPay <> 0
		GROUP BY D.intAllocatedReserveId, A.dtmPaymentDate, A.strPaymentNumber, A.intEquityPayId
		UNION ALL
		--AP Clearing
		SELECT	
			[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmPaymentDate), 0),
			[strBatchID]					=	@batchId COLLATE Latin1_General_CI_AS,
			[intAccountId]					=	ComPref.intAPClearingGLAccount,
			[dblDebit]						=	0,
			[dblCredit]						=	SUM(ROUND(C.dblEquityPay,2)),
			[dblDebitUnit]					=	0,
			[dblCreditUnit]					=	0,
			[strDescription]				=	'AP Clearing',
			[strCode]						=	@MODULE_CODE,
			[strReference]					=	A.strPaymentNumber,
			[intCurrencyId]					=	1,
			[dtmDateEntered]				=	GETDATE(),
			[dtmTransactionDate]			=	A.dtmPaymentDate,
			[strJournalLineDescription]		=	'AP Clearing',
			[intJournalLineNo]				=	1,
			[ysnIsUnposted]					=	0,
			[intUserId]						=	@intUserId,
			[intEntityId]					=	@intUserId,
			[strTransactionId]				=	A.strPaymentNumber, 
			[intTransactionId]				=	A.intEquityPayId, 
			[strTransactionType]			=	@SCREEN_NAME,
			[strTransactionForm]			=	@SCREEN_NAME,
			[strModuleName]					=	@MODULE_NAME,
			[dblDebitForeign]				=	0,      
			[dblDebitReport]				=	0,
			[dblCreditForeign]				=	0,
			[dblCreditReport]				=	0,
			[dblReportingRate]				=	0,
			[dblForeignRate]				=	0,
			[strRateType]					=	NULL
		FROM	[dbo].[tblPATEquityPay] A
		INNER JOIN tblPATEquityPaySummary B ON
			B.intEquityPayId = A.intEquityPayId
		INNER JOIN tblPATEquityPayDetail C ON
			C.intEquityPaySummaryId = B.intEquityPaySummaryId
		CROSS JOIN tblPATCompanyPreference ComPref
		WHERE	A.intEquityPayId IN (SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@intEquityPayId))
		GROUP BY A.dtmPaymentDate, ComPref.intAPClearingGLAccount, A.strPaymentNumber, A.intEquityPayId
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
		WHERE	intTransactionId IN (SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@intEquityPayId))
		AND ysnIsUnposted = 0 AND strTransactionForm = @SCREEN_NAME AND strModuleName = @MODULE_NAME
		ORDER BY intGLDetailId

		UPDATE tblGLDetail SET ysnIsUnposted = 1
		WHERE intTransactionId = @intEquityPayId 
		AND strModuleName = @MODULE_NAME AND strTransactionForm = @SCREEN_NAME
	END
	---------------- END - GET GL ENTRIES ----------------
	
	---------------- BEGIN - BOOK GL ----------------
	BEGIN TRY
		EXEC uspGLBookEntries @GLEntries, @ysnPosted
	END TRY
	BEGIN CATCH
		SET @error = ERROR_MESSAGE()
		RAISERROR(@error, 16, 1);
		GOTO Post_Rollback
	END CATCH
	---------------- END - BOOK GL ----------------

	---------------- BEGIN - UPDATE TABLES ----------------
	UPDATE tblPATEquityPay
	SET ysnPosted = @ysnPosted WHERE intEquityPayId = @intEquityPayId

	UPDATE CE
	SET	CE.dblEquityPaid = CASE WHEN @ysnPosted = 1 THEN CE.dblEquityPaid + tEP.dblEquityPay ELSE CE.dblEquityPaid - tEP.dblEquityPay END
	FROM tblPATCustomerEquity CE
	INNER JOIN #tempEquityPayment tEP
		ON tEP.intCustomerEquityId = CE.intCustomerEquityId

	---------------- END - UPDATE TABLES ------------------
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
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tempEquityPayment')) DROP TABLE #tempEquityPayment
END