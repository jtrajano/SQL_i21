CREATE PROCEDURE [dbo].[uspPATPostRefund] 
	@intRefundId		INT = NULL,
	@ysnPosted			BIT = NULL,
	@ysnRecap			BIT = NULL,
	@intUserId			INT = NULL,
	@intAPClearingId	INT = NULL,
	@intFiscalYearId	INT = NULL,
	@batchIdUsed		NVARCHAR(40) = NULL OUTPUT,
	@successfulCount	INT = 0 OUTPUT,
	@invalidCount		INT = 0 OUTPUT,
	@success			BIT = 0 OUTPUT 
AS
BEGIN
	
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRANSACTION
--DECLARE VARIABLES
DECLARE @PostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully posted.';
DECLARE @UnpostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully unposted.';
DECLARE @MODULE_CODE NVARCHAR(25) = 'PAT';
DECLARE @MODULE_NAME NVARCHAR(25) = 'Patronage';
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Refund';
DECLARE @totalRecords INT;
DECLARE @GLEntries AS RecapTableType;
DECLARE @error NVARCHAR(200);
DECLARE @batchId NVARCHAR(40);
DECLARE @batchIdUsedInBill NVARCHAR(40);
DECLARE @strRefundNumber NVARCHAR(100) = NULL;

--=====================================================================================================================================
--  VALIDATE REFUND DETAILS
---------------------------------------------------------------------------------------------------------------------------------------
DECLARE @invalidRefundCustomer TABLE(
	  intRefundId INT
	, strErrorMsg NVARCHAR(MAX)
)

IF(@ysnPosted = 1)
BEGIN
	INSERT INTO @invalidRefundCustomer (
		  intRefundId
		, strErrorMsg
	)
	SELECT TOP 1 intRefundId	= R.intRefundId
			   , strErrorMsg	= 'There are volumes that were already processed which made the record obsolete. Please delete this refund record.'
	FROM tblPATRefundCustomer RC
	INNER JOIN tblPATRefund R ON R.intRefundId = RC.intRefundId
	INNER JOIN tblPATRefundCategory RCat ON RCat.intRefundCustomerId = RC.intRefundCustomerId
	INNER JOIN tblPATCustomerVolume CV ON R.intFiscalYearId = CV.intFiscalYear
									  AND RC.intCustomerId = CV.intCustomerPatronId
									  AND RCat.intPatronageCategoryId = CV.intPatronageCategoryId
									  AND R.ysnPosted <> 1
	WHERE RCat.dblVolume > (CV.dblVolume - CV.dblVolumeProcessed)
	  AND R.intRefundId = @intRefundId
END
ELSE
BEGIN
	--- Validate if there are paid vouchers
	IF(ISNULL(@ysnRecap, 0) = 0)
	BEGIN
	INSERT INTO @invalidRefundCustomer (
		  intRefundId
		, strErrorMsg
	)
	SELECT intRefundId	= intTransactionId
		 , strErrorMsg	= strError
	FROM dbo.fnPATValidateAssociatedTransaction(@intRefundId, 5, DEFAULT)
	END
END

IF EXISTS(SELECT 1 FROM @invalidRefundCustomer)
BEGIN
	SELECT TOP 1 @error = strErrorMsg FROM @invalidRefundCustomer;
	RAISERROR(@error, 16, 1);
	GOTO Post_Rollback
END

--=====================================================================================================================================
--  GET REFUND DETAILS
---------------------------------------------------------------------------------------------------------------------------------------
SELECT intRefundId					= R.intRefundId
	 , intFiscalYearId				= R.intFiscalYearId
     , dtmRefundDate				= R.dtmRefundDate
	 , strRefund					= R.strRefund
	 , dblMinimumRefund				= R.dblMinimumRefund
	 , dblServiceFee				= R.dblServiceFee
	 , dblCashCutoffAmount			= R.dblCashCutoffAmount
	 , dblFedWithholdingPercentage	= R.dblFedWithholdingPercentage
	 , intRefundCustomerId			= RC.intRefundCustomerId
	 , intCustomerId				= RC.intCustomerId
	 , strStockStatus				= RC.strStockStatus
	 , ysnEligibleRefund			= RC.ysnEligibleRefund
	 , intRefundTypeId				= RC.intRefundTypeId
	 , ysnQualified					= RC.ysnQualified
	 , dblRefundAmount				= RC.dblRefundAmount
	 , dblCashRefund				= RC.dblCashRefund
	 , intBillId					= RC.intBillId
	 , dblEquityRefund				= RC.dblEquityRefund
INTO #tmpRefundData 
FROM tblPATRefundCustomer RC 
INNER JOIN tblPATRefund R ON R.intRefundId = RC.intRefundId 
WHERE R.intRefundId = @intRefundId

SELECT @totalRecords = COUNT(*) 
FROM #tmpRefundData	
WHERE ysnEligibleRefund = 1

IF(@totalRecords = 0)  
BEGIN
	SET @success = 0;
	SET @error = 'There are no refunds to post.';
	RAISERROR(@error, 16, 1);
	GOTO Post_Rollback
END
----------------------------------------------------------------------------------------

--=====================================================================================================================================
-- 	CREATE GL ENTRIES
---------------------------------------------------------------------------------------------------------------------------------------

IF(@batchId IS NULL)
	EXEC uspSMGetStartingNumber 3, @batchId OUT

SET @batchIdUsed = @batchId;

IF ISNULL(@ysnPosted,0) = 1
BEGIN
	INSERT INTO @GLEntries(
		  [dtmDate] 
		, [strBatchId]
		, [intAccountId]
		, [dblDebit]
		, [dblCredit]
		, [dblDebitUnit]
		, [dblCreditUnit]
		, [strDescription]
		, [strCode]
		, [strReference]
		, [intCurrencyId]
		, [dtmDateEntered]
		, [dtmTransactionDate]
		, [strJournalLineDescription]
		, [intJournalLineNo]
		, [ysnIsUnposted]
		, [intUserId]
		, [intEntityId]
		, [strTransactionId]
		, [intTransactionId]
		, [strTransactionType]
		, [strTransactionForm]
		, [strModuleName]
		, [dblDebitForeign]
		, [dblDebitReport]
		, [dblCreditForeign]
		, [dblCreditReport]
		, [dblReportingRate]
		, [dblForeignRate]
		, [strRateType]
	)
	--UNDISTRIBUTED EQUITY
	SELECT [dtmDate]					= DATEADD(dd, DATEDIFF(dd, 0, A.dtmRefundDate), 0)
		, [strBatchId]					= @batchId
		, [intAccountId]				= D.intUndistributedEquityId
		, [dblDebit]					= 0
		, [dblCredit]					= ROUND(B.dblEquityRefund, 2)
		, [dblDebitUnit]				= 0
		, [dblCreditUnit]				= 0
		, [strDescription]				= 'Undistributed Equity'
		, [strCode]						= @MODULE_CODE
		, [strReference]				= A.strRefundNo
		, [intCurrencyId]				= V.intCurrencyId
		, [dtmDateEntered]				= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0)
		, [dtmTransactionDate]			= A.dtmRefundDate
		, [strJournalLineDescription]	= 'Undistributed Equity'
		, [intJournalLineNo]			= 1
		, [ysnIsUnposted]				= 0
		, [intUserId]					= @intUserId
		, [intEntityId]					= @intUserId
		, [strTransactionId]			= A.strRefundNo
		, [intTransactionId]			= A.intRefundId
		, [strTransactionType]			= 'Undistributed Equity'
		, [strTransactionForm]			= @SCREEN_NAME
		, [strModuleName]				= @MODULE_NAME
		, [dblDebitForeign]				= 0      
		, [dblDebitReport]				= 0
		, [dblCreditForeign]			= 0
		, [dblCreditReport]				= 0
		, [dblReportingRate]			= 0
		, [dblForeignRate]				= 0
		, [strRateType]					= NULL
	FROM tblPATRefund A
	INNER JOIN tblPATRefundCustomer B ON A.intRefundId = B.intRefundId
	INNER JOIN tblPATRefundRate D ON B.intRefundTypeId = D.intRefundTypeId
	INNER JOIN tblAPVendor V ON B.intCustomerId = V.intEntityId
	WHERE A.intRefundId = @intRefundId 
	  AND B.ysnEligibleRefund = 1

	UNION ALL
	--AP Clearing
	SELECT [dtmDate]					= DATEADD(dd, DATEDIFF(dd, 0, A.dtmRefundDate), 0)
		, [strBatchId]					= @batchId
		, [intAccountId]				= E.intAPClearingGLAccount
		, [dblDebit]					= 0
		, [dblCredit]					= ROUND(B.dblCashRefund, 2)
		, [dblDebitUnit]				= 0
		, [dblCreditUnit]				= 0
		, [strDescription]				= 'AP Clearing'
		, [strCode]						= @MODULE_CODE
		, [strReference]				= A.strRefundNo
		, [intCurrencyId]				= V.intCurrencyId
		, [dtmDateEntered]				= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0)
		, [dtmTransactionDate]			= A.dtmRefundDate
		, [strJournalLineDescription]	= 'AP Clearing'
		, [intJournalLineNo]			= 1
		, [ysnIsUnposted]				= 0
		, [intUserId]					= @intUserId
		, [intEntityId]					= @intUserId
		, [strTransactionId]			= A.strRefundNo
		, [intTransactionId]			= A.intRefundId
		, [strTransactionType]			= 'AP Clearing'
		, [strTransactionForm]			= @SCREEN_NAME
		, [strModuleName]				= @MODULE_NAME
		, [dblDebitForeign]				= 0
		, [dblDebitReport]				= 0
		, [dblCreditForeign]			= 0
		, [dblCreditReport]				= 0
		, [dblReportingRate]			= 0
		, [dblForeignRate]				= 0
		, [strRateType]					= NULL
	FROM tblPATRefund A
	INNER JOIN tblPATRefundCustomer B ON A.intRefundId = B.intRefundId
	INNER JOIN tblPATRefundRate D ON B.intRefundTypeId = D.intRefundTypeId
	INNER JOIN tblAPVendor V ON B.intCustomerId = V.intEntityId
	CROSS JOIN tblPATCompanyPreference E
	WHERE A.intRefundId = @intRefundId 
	  AND B.ysnEligibleRefund = 1

	UNION ALL
	--GENERAL RESERVE
	SELECT [dtmDate]					= DATEADD(dd, DATEDIFF(dd, 0, A.dtmRefundDate), 0)
		, [strBatchId]					= @batchId
		, [intAccountId]				= D.intGeneralReserveId
		, [dblDebit]					= ROUND(B.dblRefundAmount, 2)
		, [dblCredit]					= 0
		, [dblDebitUnit]				= 0
		, [dblCreditUnit]				= 0
		, [strDescription]				= 'General Reserve'
		, [strCode]						= @MODULE_CODE
		, [strReference]				= A.strRefundNo
		, [intCurrencyId]				= V.intCurrencyId
		, [dtmDateEntered]				= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0)
		, [dtmTransactionDate]			= A.dtmRefundDate
		, [strJournalLineDescription]	= 'General Reserve'
		, [intJournalLineNo]			= 1
		, [ysnIsUnposted]				= 0
		, [intUserId]					= @intUserId
		, [intEntityId]					= @intUserId
		, [strTransactionId]			= A.strRefundNo
		, [intTransactionId]			= A.intRefundId
		, [strTransactionType]			= 'General Reserve'
		, [strTransactionForm]			= @SCREEN_NAME
		, [strModuleName]				= @MODULE_NAME
		, [dblDebitForeign]				= 0      
		, [dblDebitReport]				= 0
		, [dblCreditForeign]			= 0
		, [dblCreditReport]				= 0
		, [dblReportingRate]			= 0
		, [dblForeignRate]				= 0
		, [strRateType]					= NULL
	FROM tblPATRefund A
	INNER JOIN tblPATRefundCustomer B ON A.intRefundId = B.intRefundId
	INNER JOIN tblPATRefundRate D ON B.intRefundTypeId = D.intRefundTypeId
	INNER JOIN tblAPVendor V ON B.intCustomerId = V.intEntityId
	WHERE A.intRefundId = @intRefundId 
	  AND B.ysnEligibleRefund = 1
----------------------------------------------------------------------------------
END
ELSE
BEGIN
	INSERT INTO @GLEntries(
		  [strTransactionId]
		, [intTransactionId]
		, [dtmDate]
		, [strBatchId]
		, [intAccountId]
		, [dblDebit]
		, [dblCredit]
		, [dblDebitUnit]
		, [dblCreditUnit]
		, [strDescription]
		, [strCode]
		, [strReference]
		, [intCurrencyId]
		, [dblExchangeRate]
		, [dtmDateEntered]
		, [dtmTransactionDate]
		, [strJournalLineDescription]
		, [intJournalLineNo]
		, [ysnIsUnposted]
		, [intUserId]
		, [intEntityId]
		, [strTransactionType]
		, [strTransactionForm]
		, [strModuleName]
		, [dblDebitForeign]           
		, [dblDebitReport]            
		, [dblCreditForeign]          
		, [dblCreditReport]           
		, [dblReportingRate]          
		, [dblForeignRate]
		, [strRateType]
	)
	SELECT	
		[strTransactionId]
		,[intTransactionId]
		,[dtmDate]
		,@batchId --[strBatchId]
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
		,dtmDateEntered = DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0)
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
	FROM tblGLDetail 
	WHERE intTransactionId = @intRefundId
	  AND strModuleName = @MODULE_NAME 
	  AND strTransactionForm = @SCREEN_NAME 
	  AND strCode = @MODULE_CODE 
	  AND ysnIsUnposted = 0
	ORDER BY intGLDetailId
----------------------------------------------------------------------------------

END
BEGIN TRY
	IF(ISNULL(@ysnRecap,0) = 0)
		BEGIN
			EXEC uspGLBookEntries @GLEntries, @ysnPosted
		END
	ELSE
	BEGIN
		INSERT INTO tblGLPostRecap(
			  [strTransactionId]
			, [intTransactionId]
			, [intAccountId]
			, [strDescription]
			, [strJournalLineDescription]
			, [strReference]	
			, [dtmTransactionDate]
			, [dblDebit]
			, [dblCredit]
			, [dblDebitUnit]
			, [dblCreditUnit]
			, [dtmDate]
			, [ysnIsUnposted]
			, [intConcurrencyId]	
			, [dblExchangeRate]
			, [intUserId]
			, [dtmDateEntered]
			, [strBatchId]
			, [strCode]
			, [strModuleName]
			, [strTransactionForm]
			, [strTransactionType]
			, [strAccountId]
			, [strAccountGroup]
		)
		SELECT [strTransactionId]
			, A.[intTransactionId]
			, A.[intAccountId]
			, A.[strDescription]
			, A.[strJournalLineDescription]
			, A.[strReference]	
			, A.[dtmTransactionDate]
			, A.[dblDebit]
			, A.[dblCredit]
			, A.[dblDebitUnit]
			, A.[dblCreditUnit]
			, A.[dtmDate]
			, A.[ysnIsUnposted]
			, A.[intConcurrencyId]	
			, A.[dblExchangeRate]
			, A.[intUserId]
			, A.[dtmDateEntered]
			, A.[strBatchId]
			, A.[strCode]
			, A.[strModuleName]
			, A.[strTransactionForm]
			, A.[strTransactionType]
			, B.strAccountId
			, C.strAccountGroup
		FROM @GLEntries A
		INNER JOIN dbo.tblGLAccount B ON A.intAccountId = B.intAccountId
		INNER JOIN dbo.tblGLAccountGroup C ON B.intAccountGroupId = C.intAccountGroupId

		GOTO Post_Commit;
	END
END TRY
BEGIN CATCH
	SET @error = ERROR_MESSAGE()
	RAISERROR(@error, 16, 1);
	GOTO Post_Rollback
END CATCH

IF ISNULL(@ysnPosted,0) = 0
	BEGIN
		UPDATE tblGLDetail 
		SET ysnIsUnposted = 1
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
	
UPDATE CV
SET dblVolumeProcessed = CASE WHEN @ysnPosted = 1 THEN CV.dblVolumeProcessed + TR.dblVolume ELSE CV.dblVolumeProcessed - TR.dblVolume END
FROM tblPATCustomerVolume CV
INNER JOIN (
	SELECT DISTINCT intFiscalYearId			= TR.intFiscalYearId
				  , intCustomerId			= TR.intCustomerId
				  , intPatronageCategoryId	= RC.intPatronageCategoryId
				  , dblVolume				= RC.dblVolume
	FROM #tmpRefundData TR
	INNER JOIN tblPATRefundCategory RC ON RC.intRefundCustomerId = TR.intRefundCustomerId
) TR ON CV.intCustomerPatronId = TR.intCustomerId 
	AND CV.intFiscalYear = TR.intFiscalYearId
	AND CV.intPatronageCategoryId = TR.intPatronageCategoryId

UPDATE CV
SET ysnRefundProcessed = CASE WHEN @ysnPosted = 1 
							THEN CASE WHEN CV.dblVolume - CV.dblVolumeProcessed <= 0 
										THEN CAST(1 AS BIT) 
										ELSE CAST(0 AS BIT) 
								END
							ELSE CAST(0 AS BIT) 
						END
, intRefundCustomerId = CASE WHEN @ysnPosted = 1
							THEN RCAT.intRefundCustomerId
							ELSE NULL
						END
FROM tblPATRefund R
INNER JOIN tblPATRefundCustomer RC ON R.intRefundId = RC.intRefundId
INNER JOIN tblPATRefundCategory RCAT ON RC.intRefundCustomerId = RCAT.intRefundCustomerId
INNER JOIN tblPATCustomerVolume CV ON CV.intFiscalYear = R.intFiscalYearId
									AND CV.intCustomerPatronId = RC.intCustomerId
									AND CV.intPatronageCategoryId = RCAT.intPatronageCategoryId
WHERE R.intRefundId = @intRefundId
	AND RC.ysnEligibleRefund = 1

--=====================================================================================================================================
-- 	UPDATE REFUND TABLE
---------------------------------------------------------------------------------------------------------------------------------------
UPDATE tblPATRefund 
SET ysnPosted = @ysnPosted
WHERE intRefundId = @intRefundId	
---------------------------------------------------------------------------------------------------------------------------------------

--=====================================================================================================================================
-- 	AP CLEARING
---------------------------------------------------------------------------------------------------------------------------------------

DECLARE @APClearing APClearing
DECLARE @intLocationId	INT = NULL

SELECT @intLocationId = dbo.fnGetUserDefaultLocation(@intUserId)

INSERT INTO @APClearing (
	  [intTransactionId]
	, [strTransactionId]
	, [intTransactionType]
	, [strReferenceNumber]
	, [dtmDate]
	, [intEntityVendorId]
	, [intLocationId]
	, [intTransactionDetailId]
	, [intAccountId]
	, [intItemId]
	, [intItemUOMId]
	, [dblQuantity]
	, [dblAmount]
	, [intOffsetId]
	, [strOffsetId]
	, [intOffsetDetailId]
	, [intOffsetDetailTaxId]
	, [strCode]
	, [strRemarks]
)
SELECT [intTransactionId]		= R.intRefundId
	, [strTransactionId]		= R.strRefundNo
	, [intTransactionType]		= 9
	, [strReferenceNumber]		= R.strRefundNo
	, [dtmDate]					= R.dtmRefundDate
	, [intEntityVendorId]		= RC.intCustomerId
	, [intLocationId]			= @intLocationId
	, [intTransactionDetailId]	= RC.intRefundCustomerId
	, [intAccountId]			= E.intAPClearingGLAccount
	, [intItemId]				= NULL
	, [intItemUOMId]			= NULL
	, [dblQuantity]				= 1
	, [dblAmount]				= RC.dblCashRefund
	, [intOffsetId]				= NULL
	, [strOffsetId]				= NULL
	, [intOffsetDetailId]		= NULL
	, [intOffsetDetailTaxId]	= NULL	
	, [strCode]					= 'PAT'
	, [strRemarks]				= NULL
FROM tblPATRefund R
INNER JOIN tblPATRefundCustomer RC ON R.intRefundId = RC.intRefundId
INNER JOIN tblAPVendor V ON RC.intCustomerId = V.intEntityId
CROSS JOIN tblPATCompanyPreference E
WHERE R.intRefundId = @intRefundId

IF EXISTS(SELECT TOP 1 NULL FROM @APClearing)
	EXEC dbo.uspAPClearing @APClearing = @APClearing, @post = @ysnPosted
	
---------------------------------------------------------------------------------------------------------------------------------------

--=====================================================================================================================================
--  UNPOST AND DELETE VOUCHER
---------------------------------------------------------------------------------------------------------------------------------------

DECLARE @voucheredRefunds INT = 0;
SELECT @voucheredRefunds = COUNT(*) FROM #tmpRefundData WHERE intBillId IS NOT NULL;

IF(ISNULL(@ysnPosted,0) = 0 AND ISNULL(@ysnRecap, 0) = 0 AND @voucheredRefunds > 0)
BEGIN
	BEGIN TRY
		SET ANSI_WARNINGS ON;
		DECLARE @voucherId AS NVARCHAR(MAX);
		SELECT @voucherId = STUFF((SELECT ',' + CONVERT(NVARCHAR(MAX),intBillId) FROM #tmpRefundData
		WHERE intBillId IS NOT NULL 
		FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'),1,1,'');
		SET ANSI_WARNINGS OFF;

		UPDATE RC 
		SET intBillId = NULL 
		FROM tblPATRefundCustomer RC 
		INNER JOIN #tmpRefundData RD ON RC.intRefundCustomerId = RD.intRefundCustomerId

		EXEC uspAPPostBill @batchId = NULL
						 , @billBatchId = NULL
						 , @transactionType = 'Credit Card'
						 , @post = 0
						 , @recap = 0
						 , @isBatch = 0
						 , @param = @voucherId
						 , @userId = @intUserId
						 , @beginTransaction = NULL
						 , @endTransaction = NULL
						 , @success = @success OUTPUT
						 , @batchIdUsed = @batchIdUsedInBill OUTPUT
	END TRY
	BEGIN CATCH
		SET @error = ERROR_MESSAGE();
		RAISERROR(@error, 16, 1);
		GOTO Post_Rollback;
	END CATCH
	
	IF(@success = 0)
	BEGIN
		SELECT TOP 1 @error = strMessage
		FROM tblAPPostResult 
		WHERE strBatchNumber = @batchIdUsedInBill
		
		RAISERROR(@error, 16, 1);
		GOTO Post_Rollback;
	END

	DELETE BILL
	FROM tblAPBill BILL
	INNER JOIN tblPATRefundCustomer RC ON BILL.intBillId = RC.intBillId
	INNER JOIN #tmpRefundData RD ON RC.intRefundCustomerId = RD.intRefundCustomerId
	
	SELECT TOP 1 @strRefundNumber = strRefundNo
	FROM tblPATRefund
	WHERE intRefundId = @intRefundId

	EXEC dbo.[uspICDeleteTransactionLinks] @intRefundId, @strRefundNumber, @SCREEN_NAME, @MODULE_NAME
END

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