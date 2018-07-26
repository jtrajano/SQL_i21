CREATE PROCEDURE [dbo].[uspPATPostRetireStock]
	@intRetireStockId INT = NULL,
	@ysnPosted BIT = NULL,
	@ysnRecap BIT = NULL,
	@intCompanyLocationId INT = NULL,
	@intUserId INT = NULL,
	@batchIdUsed NVARCHAR(40) = NULL OUTPUT,
	@error NVARCHAR(200) = NULL OUTPUT,
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

DECLARE @dateToday AS DATETIME = GETDATE();
DECLARE @GLEntries AS RecapTableType;
DECLARE @totalRecords INT;
DECLARE @batchId NVARCHAR(40);
DECLARE @isGLSucces AS BIT = 0;
DECLARE @intCreatedId INT;
DECLARE @MODULE_NAME NVARCHAR(25) = 'Patronage';
DECLARE @RETIRE_STOCK NVARCHAR(25) = 'Retire Stock';
DECLARE @MODULE_CODE NVARCHAR(5)  = 'PAT';
DECLARE @batchId2 AS NVARCHAR(40);
DECLARE @voidRetire AS BIT = 0;
DECLARE @voucherId as Id;

CREATE TABLE #tempValidateTable (
	[strError] [NVARCHAR](MAX),
	[strTransactionType] [NVARCHAR](50),
	[strTransactionNo] [NVARCHAR](50),
	[intTransactionId] INT
);

IF(@batchId IS NULL)
	EXEC uspSMGetStartingNumber 3, @batchId OUT

SET @batchIdUsed = @batchId;

	SELECT	RetireStk.intRetireStockId,
			RetireStk.strRetireNo,
			RetireStk.dtmRetireDate,
			CS.strCertificateNo,
			CS.strStockStatus,
			RetireStk.intCustomerStockId,
			RetireStk.intCustomerPatronId,
			RetireStk.dblSharesNo,
			RetireStk.dblParValue,
			RetireStk.dblFaceValue,
			RetireStk.intBillId,
			RetireStk.ysnPosted
	INTO #tempCustomerStock
	FROM tblPATRetireStock RetireStk
	INNER JOIN tblPATCustomerStock CS
		ON CS.intCustomerStockId = RetireStk.intCustomerStockId
	WHERE RetireStk.intRetireStockId = @intRetireStockId
		

IF(ISNULL(@ysnPosted,0) = 0)
BEGIN
	-------- VALIDATE IF CAN BE UNPOSTED
	INSERT INTO #tempValidateTable
	SELECT * FROM fnPATValidateAssociatedTransaction((SELECT intCustomerStockId FROM #tempCustomerStock), 2, @MODULE_NAME)

	SELECT * FROM #tempValidateTable
	IF EXISTS(SELECT 1 FROM #tempValidateTable)
	BEGIN
		SELECT @error = V.strError FROM #tempValidateTable V
		RAISERROR(@error, 16, 1);
		GOTO Post_Rollback;
	END
END


IF(@ysnPosted = 1)
BEGIN

------------------------CREATE GL ENTRIES---------------------
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
	--VOTING STOCK/NON-VOTING STOCK/OTHER ISSUED
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmRetireDate), 0),
		[strBatchID]					=	@batchId COLLATE Latin1_General_CI_AS,
		[intAccountId]					=	CASE WHEN A.strStockStatus = 'Voting' THEN ComPref.intVotingStockId ELSE ComPref.intNonVotingStockId END,
		[dblDebit]						=	ROUND(A.dblFaceValue, 2),
		[dblCredit]						=	0,
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	0,
		[strDescription]				=	CASE WHEN A.strStockStatus = 'Voting' THEN 'Posted Voting Retired Stock' ELSE 'Posted Non-Voting/Other Retired Stock' END,
		[strCode]						=	@MODULE_CODE,
		[strReference]					=	A.strCertificateNo,
		[intCurrencyId]					=	1,
		[dtmDateEntered]				=	GETDATE(),
		[dtmTransactionDate]			=	NULL,
		[strJournalLineDescription]		=	CASE WHEN A.strStockStatus = 'Voting' THEN 'Posted Voting Retired Stock' ELSE 'Posted Non-Voting/Other Retired Stock' END,
		[intJournalLineNo]				=	1,
		[ysnIsUnposted]					=	0,
		[intUserId]						=	@intUserId,
		[intEntityId]					=	@intUserId,
		[strTransactionId]				=	A.strRetireNo, 
		[intTransactionId]				=	A.intRetireStockId, 
		[strTransactionType]			=	CASE WHEN A.strStockStatus = 'Voting' THEN 'Voting' ELSE 'Non-Voting/Other' END,
		[strTransactionForm]			=	@RETIRE_STOCK,
		[strModuleName]					=	@MODULE_NAME,
		[dblDebitForeign]				=	0,      
		[dblDebitReport]				=	0,
		[dblCreditForeign]				=	0,
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]				=	0,
		[strRateType]					=	NULL
	FROM	#tempCustomerStock A
			CROSS JOIN tblPATCompanyPreference ComPref
	UNION ALL
	--AP CLEARING
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmRetireDate), 0),
		[strBatchID]					=	@batchId COLLATE Latin1_General_CI_AS,
		[intAccountId]					=	ComPref.intAPClearingGLAccount,
		[dblDebit]						=	0,
		[dblCredit]						=	ROUND(A.dblFaceValue,2),
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	0,
		[strDescription]				=	'Posted AP Clearing for Retire Stock',
		[strCode]						=	@MODULE_CODE,
		[strReference]					=	A.strCertificateNo,
		[intCurrencyId]					=	1,
		[dtmDateEntered]				=	GETDATE(),
		[dtmTransactionDate]			=	NULL,
		[strJournalLineDescription]		=	'Posted AP Clearing for Retire Stock',
		[intJournalLineNo]				=	1,
		[ysnIsUnposted]					=	0,
		[intUserId]						=	@intUserId,
		[intEntityId]					=	@intUserId,
		[strTransactionId]				=	A.strRetireNo, 
		[intTransactionId]				=	A.intRetireStockId, 
		[strTransactionType]			=	'Retire Stock',
		[strTransactionForm]			=	@RETIRE_STOCK,
		[strModuleName]					=	@MODULE_NAME,
		[dblDebitForeign]				=	0,      
		[dblDebitReport]				=	0,
		[dblCreditForeign]				=	0,
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]				=	0,
		[strRateType]					=	NULL
	FROM	#tempCustomerStock A
			CROSS JOIN tblPATCompanyPreference ComPref
		

END
ELSE
BEGIN
------------------------REVERSE GL ENTRIES---------------------
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
	WHERE	intTransactionId IN (SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@intRetireStockId))
	AND ysnIsUnposted = 0 AND strTransactionForm = @RETIRE_STOCK AND strModuleName = @MODULE_NAME
	ORDER BY intGLDetailId

	UPDATE tblGLDetail SET ysnIsUnposted = 1
	WHERE intTransactionId = @intRetireStockId 
		AND strModuleName = @MODULE_NAME AND strTransactionForm = @RETIRE_STOCK
END

BEGIN TRY
IF(ISNULL(@ysnRecap, 0) = 0)
BEGIN
	SELECT * FROM @GLEntries;
	EXEC uspGLBookEntries @GLEntries, @ysnPosted;
	
	SET @isGLSucces = 1;
END
ELSE
BEGIN
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




IF(@isGLSucces = 1)
BEGIN
	IF(@batchId2 IS NULL)
		EXEC uspSMGetStartingNumber 3, @batchId2 OUT

	--------------------- RETIRED STOCKS ------------------	
		IF(@ysnPosted = 1)
		BEGIN
			DECLARE @voucherDetailNonInventory AS VoucherDetailNonInventory;
			DECLARE @intCustomerId AS INT;
			DECLARE @dblNoOfShares AS NUMERIC(18,6);
			DECLARE @dblPARValue AS NUMERIC(18,6);
			DECLARE @strVenderOrderNumber AS NVARCHAR(50);
			DECLARE @apClearing AS INT;

			SELECT 
				@intCustomerId = tempCS.intCustomerPatronId,
				@dblNoOfShares = ROUND(tempCS.dblSharesNo,2),
				@dblPARValue = ROUND(tempCS.dblParValue,2),
				@strVenderOrderNumber = tempCS.strCertificateNo,
				@apClearing = ComPref.intAPClearingGLAccount
			FROM #tempCustomerStock tempCS
			CROSS APPLY tblPATCompanyPreference ComPref

			INSERT INTO @voucherDetailNonInventory([intAccountId], [strMiscDescription],[dblQtyReceived],[dblDiscount],[dblCost])
			VALUES(@apClearing, 'Patronage Retired Stock', @dblPARValue, 0, @dblNoOfShares);

			EXEC [dbo].[uspAPCreateBillData]
				@userId	= @intUserId
				,@vendorId = @intCustomerId
				,@type = 1	
				,@voucherNonInvDetails = @voucherDetailNonInventory
				,@shipTo = NULL
				,@vendorOrderNumber = @strVenderOrderNumber
				,@voucherDate = @dateToday
				,@billId = @intCreatedId OUTPUT

			UPDATE tblPATRetireStock SET intBillId = @intCreatedId WHERE intRetireStockId = @intRetireStockId;
			UPDATE tblAPBillDetail set intCurrencyId = [dbo].[fnSMGetDefaultCurrency]('FUNCTIONAL') WHERE intBillId = @intCreatedId;

			IF EXISTS(SELECT 1 FROM tblAPBillDetailTax WHERE intBillDetailId IN (SELECT intBillDetailId FROM tblAPBillDetail WHERE intBillId = @intCreatedId))
			BEGIN
				INSERT INTO @voucherId SELECT intBillId FROM tblAPBill where intBillId = @intCreatedId;

				EXEC [dbo].[uspAPDeletePatronageTaxes] @voucherId;

				UPDATE tblAPBill SET dblTax = 0 WHERE intBillId IN (SELECT intBillId FROM @voucherId);
				UPDATE tblAPBillDetail SET dblTax = 0 WHERE intBillId IN (SELECT intBillId FROM @voucherId);

				EXEC uspAPUpdateVoucherTotal @voucherId;
				DELETE FROM @voucherId;
			END

			EXEC [dbo].[uspAPPostBill]
				@batchId = @batchId2,
				@billBatchId = NULL,
				@transactionType = NULL,
				@post = 1,
				@recap = 0,
				@isBatch = 0,
				@param = NULL,
				@userId = @intUserId,
				@beginTransaction = @intCreatedId,
				@endTransaction = @intCreatedId,
				@success = @success OUTPUT

				UPDATE tblPATCustomerStock
				SET dblSharesNo = 0,
					strActivityStatus = 'Retired'
				WHERE intCustomerStockId IN (SELECT intCustomerStockId FROM #tempCustomerStock);
		END
		ELSE
		BEGIN

			DECLARE @voucher AS NVARCHAR(MAX);
			SELECT @voucher = intBillId FROM tblPATRetireStock WHERE intRetireStockId = @intRetireStockId;

			EXEC [dbo].[uspAPPostBill]
					@batchId = NULL,
					@billBatchId = NULL,
					@transactionType = @MODULE_NAME,
					@post = 0,
					@recap = 0,
					@isBatch = 0,
					@param = @voucher,
					@userId = @intUserId,
					@beginTransaction = NULL,
					@endTransaction = NULL,
					@success = @success OUTPUT

			IF(@success = 0)
			BEGIN
				SET @error = 'Unable to unpost transaction';
				RAISERROR(@error, 16, 1);
				GOTO Post_Rollback;
			END
			
			DELETE FROM tblAPBill WHERE intBillId IN (SELECT intBillId FROM #tempCustomerStock) AND ysnPaid <> 1;
			
			UPDATE CS 
			SET CS.dblSharesNo = tmpCS.dblSharesNo,
				CS.strActivityStatus = 'Open'
			FROM tblPATCustomerStock CS
			INNER JOIN #tempCustomerStock tmpCS
				ON tmpCS.intCustomerStockId = CS.intCustomerStockId
				
		END

		UPDATE tblPATRetireStock SET ysnPosted = @ysnPosted WHERE intRetireStockId = @intRetireStockId;
	END

---------------------------------------------------------------------------------------------------------------------------------------
IF @@ERROR <> 0 GOTO Post_Rollback;

GOTO Post_Commit;

Post_Commit:
	COMMIT TRANSACTION
	SET @success = 1
	SET @successfulCount = @totalRecords
	
	GOTO Post_Exit

Post_Rollback:
	IF(@@TRANCOUNT > 0)
		ROLLBACK TRANSACTION	
	SET @success = 0
	GOTO Post_Exit

Post_Exit:
END