CREATE PROCEDURE [dbo].[uspPATPostRefund] 
	@intRefundId INT = NULL,
	@ysnPosted BIT = NULL,
	@intUserId INT = NULL,
	@intFiscalYearId INT = NULL,
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

BEGIN TRANSACTION -- START TRANSACTION

--DECLARE VARIABLES
DECLARE @PostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully posted.';
DECLARE @UnpostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully unposted.';
DECLARE @MODULE_NAME NVARCHAR(25) = 'Patronage';
DECLARE @MODULE_CODE NVARCHAR(5)  = 'PAT';
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Refund';
DECLARE @totalRecords INT;
DECLARE @GLEntries AS RecapTableType;
DECLARE @error NVARCHAR(200);
DECLARE @batchId NVARCHAR(40);

--=====================================================================================================================================
--  VALIDATE REFUND DETAILS
---------------------------------------------------------------------------------------------------------------------------------------
IF(@ysnPosted = 1)
BEGIN
	DECLARE  @validateRefundCustomer TABLE(
		[intRefundCustomerId] INT,
		[intCustomerVolumeId] INT
	)

	INSERT INTO @validateRefundCustomer
	SELECT	RC.intRefundCustomerId,
			CV.intCustomerVolumeId
	FROM tblPATRefundCustomer RC
	INNER JOIN tblPATRefund R
		ON R.intRefundId = RC.intRefundId
	INNER JOIN tblPATCustomerVolume CV
		ON CV.intRefundCustomerId = RC.intRefundCustomerId
	WHERE R.intRefundId = @intRefundId

	IF EXISTS(SELECT 1 FROM @validateRefundCustomer)
	BEGIN
		SET @error = 'There are volumes that were already processed which made the record obsolete. Please delete this refund record.';
		RAISERROR(@error, 16, 1);
		GOTO Post_Rollback
	END
END

--=====================================================================================================================================
--  GET REFUND DETAILS
---------------------------------------------------------------------------------------------------------------------------------------
SELECT R.intRefundId, 
		R.intFiscalYearId, 
		R.dtmRefundDate, 
		R.strRefund,
		R.dblMinimumRefund, 
		R.dblServiceFee,		   
		R.dblCashCutoffAmount, 
		R.dblFedWithholdingPercentage,
		RC.intRefundCustomerId,
		RC.intCustomerId,
		RC.strStockStatus,
		RC.ysnEligibleRefund,
		RC.intRefundTypeId,
		RC.ysnQualified, 
		RC.dblRefundAmount,
		RC.dblCashRefund,
		RC.dblEquityRefund
	INTO #tmpRefundData 
	FROM tblPATRefundCustomer RC 
	INNER JOIN tblPATRefund R 
		ON R.intRefundId = RC.intRefundId 
	WHERE R.intRefundId = @intRefundId

SELECT @totalRecords = COUNT(*) FROM #tmpRefundData	where ysnEligibleRefund = 1

COMMIT TRANSACTION --COMMIT inserted invalid transaction


IF(@totalRecords = 0)  
BEGIN
	SET @success = 0
	GOTO Post_Exit
END


---------------------------------------------------------------------------------------------------------------------------------------

BEGIN TRANSACTION
--=====================================================================================================================================
-- 	CREATE GL ENTRIES
---------------------------------------------------------------------------------------------------------------------------------------

IF(@batchId IS NULL)
	EXEC uspSMGetStartingNumber 3, @batchId OUT

DECLARE @validRefundIds NVARCHAR(MAX)

-- CREATE TEMP GL ENTRIES
SELECT DISTINCT @validRefundIds = COALESCE(@validRefundIds + ',', '') +  CONVERT(VARCHAR(12),intRefundId)
FROM #tmpRefundData

DECLARE @dblDiff NUMERIC(18,6)
DECLARE @intAdjustmentId INT

IF ISNULL(@ysnPosted,0) = 1
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
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmRefundDate), 0),
		[strBatchId]					=	@batchId COLLATE Latin1_General_CI_AS,
		[intAccountId]					=	D.intUndistributedEquityId,
		[dblDebit]						=	0,
		[dblCredit]						=	ROUND(B.dblEquityRefund, 2),
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	0,
		[strDescription]				=	'Undistributed Equity',
		[strCode]						=	@MODULE_CODE,
		[strReference]					=	A.strRefundNo,
		[intCurrencyId]					=	1,
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
		[strRateType]					=	NULL
	FROM	[dbo].tblPATRefund A
			INNER JOIN tblPATRefundCustomer B
				ON A.intRefundId = B.intRefundId
			INNER JOIN tblPATRefundRate D
				ON B.intRefundTypeId = D.intRefundTypeId
	WHERE	A.intRefundId IN (SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@validRefundIds)) AND B.ysnEligibleRefund = 1
	UNION ALL
	--AP Clearing
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmRefundDate), 0),
		[strBatchId]					=	@batchId COLLATE Latin1_General_CI_AS,
		[intAccountId]					=	E.intAPClearingGLAccount, 
		[dblDebit]						=	0,
		[dblCredit]						=	ROUND(B.dblCashRefund,2),
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	0,
		[strDescription]				=	'AP Clearing',
		[strCode]						=	@MODULE_CODE,
		[strReference]					=	A.strRefundNo,
		[intCurrencyId]					=	1,
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
		[strRateType]					=	NULL
	FROM	[dbo].tblPATRefund A
			INNER JOIN tblPATRefundCustomer B
				ON A.intRefundId = B.intRefundId
			INNER JOIN tblPATRefundRate D
				ON B.intRefundTypeId = D.intRefundTypeId
			CROSS JOIN tblPATCompanyPreference E
	WHERE	A.intRefundId IN (SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@validRefundIds)) AND B.ysnEligibleRefund = 1
	UNION ALL
	--GENERAL RESERVE
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmRefundDate), 0),
		[strBatchId]					=	@batchId COLLATE Latin1_General_CI_AS,
		[intAccountId]					=	D.intGeneralReserveId,
		[dblDebit]						=	ROUND(B.dblRefundAmount,2),
		[dblCredit]						=	0,
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	0,
		[strDescription]				=	'General Reserve',
		[strCode]						=	@MODULE_CODE,
		[strReference]					=	A.strRefundNo,
		[intCurrencyId]					=	1,
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
		[strRateType]					=	NULL
	FROM	[dbo].tblPATRefund A
			INNER JOIN tblPATRefundCustomer B
				ON A.intRefundId = B.intRefundId
			INNER JOIN tblPATRefundRate D
				ON B.intRefundTypeId = D.intRefundTypeId
	WHERE	A.intRefundId IN (SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@validRefundIds)) AND B.ysnEligibleRefund = 1

----------------------------------------------------------------------------------

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
		,strBatchId = @batchId COLLATE Latin1_General_CI_AS--[strBatchId]
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
	WHERE	intTransactionId IN (SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@validRefundIds))
	AND strModuleName = @MODULE_NAME AND strTransactionForm = @SCREEN_NAME AND strCode = @MODULE_CODE AND ysnIsUnposted = 0
	ORDER BY intGLDetailId

----------------------------------------------------------------------------------

END

BEGIN TRY
	SELECT * FROM @GLEntries
	EXEC uspGLBookEntries @GLEntries, @ysnPosted
END TRY
BEGIN CATCH
	SET @error = ERROR_MESSAGE()
	RAISERROR(@error, 16, 1);
	GOTO Post_Rollback
END CATCH

IF ISNULL(@ysnPosted,0) = 0
BEGIN
	UPDATE tblGLDetail SET ysnIsUnposted = 1
		WHERE intTransactionId = @intRefundId 
			AND strModuleName = @MODULE_NAME 
			AND strTransactionForm = @SCREEN_NAME
END


--=====================================================================================================================================
-- 	UPDATE CUSTOMER EQUITY TABLE
---------------------------------------------------------------------------------------------------------------------------------------
BEGIN TRY
	MERGE tblPATCustomerEquity AS EQ
	USING (SELECT * FROM #tmpRefundData WHERE ysnEligibleRefund = 1) AS B
		ON (EQ.intCustomerId = B.intCustomerId AND EQ.intFiscalYearId = B.intFiscalYearId AND EQ.intRefundTypeId = B.intRefundTypeId)
		WHEN MATCHED
			THEN UPDATE SET EQ.dblEquity = CASE WHEN @ysnPosted = 1 THEN EQ.dblEquity + B.dblEquityRefund ELSE EQ.dblEquity - B.dblEquityRefund END
		WHEN NOT MATCHED BY TARGET
			THEN INSERT (intCustomerId, intFiscalYearId, strEquityType, intRefundTypeId, dblEquity, intConcurrencyId)
				VALUES (B.intCustomerId, B.intFiscalYearId , 'Undistributed', B.intRefundTypeId, B.dblEquityRefund, 1);
END TRY
BEGIN CATCH
	SET @error = ERROR_MESSAGE()
	RAISERROR(@error, 16, 1);
	GOTO Post_Rollback
END CATCH
---------------------------------------------------------------------------------------------------------------------------------------

--=====================================================================================================================================
-- 	UPDATE CUSTOMER VOLUME TABLE
---------------------------------------------------------------------------------------------------------------------------------------
	IF(@ysnPosted = 1)
	BEGIN
		UPDATE CV
		SET CV.intRefundCustomerId = tRD.intRefundCustomerId, CV.ysnRefundProcessed = @ysnPosted
		FROM tblPATCustomerVolume CV
		INNER JOIN #tmpRefundData tRD
			ON CV.intCustomerPatronId = tRD.intCustomerId AND CV.intFiscalYear = tRD.intFiscalYearId 
		WHERE CV.ysnRefundProcessed = 0 AND CV.intRefundCustomerId IS NULL
	END
	ELSE
	BEGIN
		UPDATE CV
		SET CV.intRefundCustomerId = null, ysnRefundProcessed = @ysnPosted
		FROM tblPATCustomerVolume CV
		INNER JOIN #tmpRefundData tRD
			ON CV.intRefundCustomerId = tRD.intRefundCustomerId
	END
	

---------------------------------------------------------------------------------------------------------------------------------------


--=====================================================================================================================================
-- 	UPDATE REFUND TABLE
---------------------------------------------------------------------------------------------------------------------------------------

	UPDATE tblPATRefund 
	SET ysnPosted = @ysnPosted
	WHERE intRefundId = @intRefundId
	
---------------------------------------------------------------------------------------------------------------------------------------

IF @@ERROR <> 0	GOTO Post_Rollback;

GOTO Post_Commit;

--=====================================================================================================================================
-- 	FINALIZING STAGE
---------------------------------------------------------------------------------------------------------------------------------------
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
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpRefundData')) DROP TABLE #tmpRefundData
END
---------------------------------------------------------------------------------------------------------------------------------------
GO