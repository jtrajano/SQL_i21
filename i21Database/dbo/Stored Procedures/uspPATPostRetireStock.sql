CREATE PROCEDURE [dbo].[uspPATPostRetireStock]
	@intRetireStockId 		INT = NULL,
	@ysnPosted 				BIT = NULL,
	@ysnRecap 				BIT = NULL,
	@intCompanyLocationId 	INT = NULL,
	@intUserId 				INT = NULL,
	@batchIdUsed 			NVARCHAR(40) = NULL OUTPUT,
	@error 					NVARCHAR(200) = NULL OUTPUT,
	@successfulCount 		INT = 0 OUTPUT,
	@invalidCount 			INT = 0 OUTPUT,
	@success 				BIT = 0 OUTPUT
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
DECLARE @strRetireNumber AS NVARCHAR(100) = NULL

CREATE TABLE #tempValidateTable (
	[strError] [NVARCHAR](MAX),
	[strTransactionType] [NVARCHAR](50),
	[strTransactionNo] [NVARCHAR](50),
	[intTransactionId] INT
);

IF(@batchId IS NULL)
	EXEC uspSMGetStartingNumber 3, @batchId OUT

SET @batchIdUsed = @batchId;

SELECT intRetireStockId		= RetireStk.intRetireStockId
	 , strRetireNo			= RetireStk.strRetireNo
	 , dtmRetireDate		= RetireStk.dtmRetireDate
	 , strCertificateNo		= CS.strCertificateNo
	 , strStockStatus		= CS.strStockStatus
	 , intCustomerStockId	= RetireStk.intCustomerStockId
	 , intCustomerPatronId	= RetireStk.intCustomerPatronId
	 , dblSharesNo			= RetireStk.dblSharesNo
	 , dblParValue			= RetireStk.dblParValue
	 , dblFaceValue			= RetireStk.dblFaceValue
	 , intBillId			= RetireStk.intBillId
	 , ysnPosted			= RetireStk.ysnPosted
INTO #tempCustomerStock
FROM tblPATRetireStock RetireStk
INNER JOIN tblPATCustomerStock CS ON CS.intCustomerStockId = RetireStk.intCustomerStockId
WHERE RetireStk.intRetireStockId = @intRetireStockId		

SELECT @strRetireNumber = strRetireNo
FROM tblPATRetireStock
WHERE intRetireStockId = @intRetireStockId
---------------- VALIDATE IF CAN BE UNPOSTED----------------
IF(ISNULL(@ysnPosted,0) = 0)
BEGIN	
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

------------------------CREATE GL ENTRIES---------------------
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
	FROM #tempCustomerStock A
	CROSS JOIN tblPATCompanyPreference ComPref

	UNION ALL
	--AP CLEARING
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmRetireDate), 0),
		[strBatchID]					=	@batchId COLLATE Latin1_General_CI_AS,
		[intAccountId]					=	ComPref.intAPClearingGLAccount,
		[dblDebit]						=	0,
		[dblCredit]						=	ROUND(A.dblFaceValue, 2),
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
	FROM #tempCustomerStock A
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
	FROM tblGLDetail 
	WHERE intTransactionId IN (SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@intRetireStockId))
	  AND ysnIsUnposted = 0 
	  AND strTransactionForm = @RETIRE_STOCK 
	  AND strModuleName = @MODULE_NAME
	ORDER BY intGLDetailId

	UPDATE tblGLDetail 
	SET ysnIsUnposted = 1
	WHERE intTransactionId = @intRetireStockId 
	 AND strModuleName = @MODULE_NAME 
	 AND strTransactionForm = @RETIRE_STOCK
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
		INNER JOIN dbo.tblGLAccount B ON A.intAccountId = B.intAccountId
		INNER JOIN dbo.tblGLAccountGroup C ON B.intAccountGroupId = C.intAccountGroupId
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
			DECLARE @voucherPayable AS VoucherPayable;
			DECLARE @voucherPayableTax	AS VoucherDetailTax;
			DECLARE @intCustomerId AS INT;
			DECLARE @dblNoOfShares AS NUMERIC(18,6);
			DECLARE @dblPARValue AS NUMERIC(18,6);
			DECLARE @strVenderOrderNumber AS NVARCHAR(50);
			DECLARE @apClearing AS INT;
			DECLARE @createdVouchersId NVARCHAR(MAX);

			SELECT TOP 1 @apClearing = ComPref.intAPClearingGLAccount
			FROM tblPATCompanyPreference ComPref

			INSERT INTO @voucherPayable(
				 [intEntityVendorId]
				,[intTransactionType]
				,[strVendorOrderNumber]
				,[strSourceNumber]
				,[strMiscDescription]
				,[intAccountId]
				,[dblQuantityToBill]
				,[dblCost]
			)
			SELECT [intEntityVendorId]		= intCustomerPatronId
				 , [intTransactionType]		= 1
				 , [strVendorOrderNumber]	= strCertificateNo
				 , [strSourceNumber]		= strRetireNo
				 , [strMiscDescription]		= 'Patronage Retired Stock'
				 , [intAccountId]			= @apClearing
				 , [dblQuantityToBill]		= ROUND(dblSharesNo, 2)
				 , [dblCost]				= ROUND(dblParValue, 2)
			FROM #tempCustomerStock RetireStock

			EXEC  [dbo].[uspAPCreateVoucher] @voucherPayables = @voucherPayable
										   , @voucherPayableTax = @voucherPayableTax
										   , @userId = @intUserId
										   , @throwError = 0
										   , @error  = @error OUTPUT
										   , @createdVouchersId = @createdVouchersId OUTPUT

			IF (@error != '')
			BEGIN
				GOTO Post_Rollback;
			END

			UPDATE RS
			SET intBillId = BILL.intBillId 
			FROM tblPATRetireStock RS
			CROSS APPLY (
				SELECT intBillId
				FROM tblAPBill BILL
				INNER JOIN dbo.fnGetRowsFromDelimitedValues(@createdVouchersId) DV ON BILL.intBillId = DV.intID
			) BILL
			WHERE RS.intRetireStockId = @intRetireStockId

			--LINK TRANSACTION
			DECLARE @tblTransactionLinks    udtICTransactionLinks

			INSERT INTO @tblTransactionLinks (
				  intSrcId
				, strSrcTransactionNo
				, strSrcTransactionType
				, strSrcModuleName
				, intDestId
				, strDestTransactionNo
				, strDestTransactionType
				, strDestModuleName
				, strOperation
			)
			SELECT intSrcId					= RS.intRetireStockId
				, strSrcTransactionNo       = RS.strRetireNo
				, strSrcTransactionType     = @RETIRE_STOCK
				, strSrcModuleName          = @MODULE_NAME
				, intDestId                 = BILL.intBillId
				, strDestTransactionNo      = BILL.strBillId
				, strDestTransactionType    = 'Voucher'
				, strDestModuleName         = 'Purchasing'
				, strOperation              = 'Process'
			FROM tblPATRetireStock RS
			INNER JOIN tblAPBill BILL ON BILL.intBillId = RS.intBillId
			WHERE RS.intRetireStockId = @intRetireStockId
			
			EXEC dbo.uspICAddTransactionLinks @tblTransactionLinks			

			EXEC [dbo].[uspAPPostBill] @batchId = @batchId2
									 , @billBatchId = NULL
									 , @transactionType = NULL
									 , @post = 1
									 , @recap = 0
									 , @isBatch = 0
									 , @param = @createdVouchersId
									 , @userId = @intUserId
									 , @beginTransaction = NULL
									 , @endTransaction = NULL
									 , @success = @success OUTPUT

			UPDATE CS
			SET dblSharesNo = 0
			  , strActivityStatus = 'Retired'
			FROM tblPATCustomerStock CS
			INNER JOIN #tempCustomerStock TCS ON TCS.intCustomerStockId = CS.intCustomerStockId
		END
		ELSE
		BEGIN
			DECLARE @voucher AS NVARCHAR(MAX);
			SELECT @voucher = intBillId FROM tblPATRetireStock WHERE intRetireStockId = @intRetireStockId;

			EXEC [dbo].[uspAPPostBill] @batchId = NULL
									 , @billBatchId = NULL
									 , @transactionType = @MODULE_NAME
									 , @post = 0
									 , @recap = 0
									 , @isBatch = 0
									 , @param = @voucher
									 , @userId = @intUserId
									 , @beginTransaction = NULL
									 , @endTransaction = NULL
									 , @success = @success OUTPUT

			IF(@success = 0)
			BEGIN
				SET @error = 'Unable to unpost transaction';
				RAISERROR(@error, 16, 1);
				GOTO Post_Rollback;
			END

			DELETE BILL 
			FROM tblAPBill BILL
			INNER JOIN #tempCustomerStock TCS ON BILL.intBillId = TCS.intBillId
			WHERE ysnPaid <> 1

			EXEC dbo.[uspICDeleteTransactionLinks] @intRetireStockId, @strRetireNumber, @RETIRE_STOCK, @MODULE_NAME
			
			UPDATE CS 
			SET dblSharesNo = tmpCS.dblSharesNo
			  , strActivityStatus = 'Open'
			FROM tblPATCustomerStock CS
			INNER JOIN #tempCustomerStock tmpCS ON tmpCS.intCustomerStockId = CS.intCustomerStockId				
		END		

		UPDATE tblPATRetireStock SET ysnPosted = @ysnPosted WHERE intRetireStockId = @intRetireStockId;
	
		--------------------- AP CLEARING -----------------------
		DECLARE @APClearingtbl		APClearing
		DECLARE @intLocationId	INT = NULL

		SELECT @intLocationId = dbo.fnGetUserDefaultLocation(@intUserId)

		INSERT INTO @APClearingtbl (
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
		SELECT [intTransactionId]		= RS.intRetireStockId
			, [strTransactionId]		= RS.strRetireNo
			, [intTransactionType]		= 9
			, [strReferenceNumber]		= RS.strRetireNo
			, [dtmDate]					= RS.dtmRetireDate
			, [intEntityVendorId]		= RS.intCustomerPatronId
			, [intLocationId]			= @intLocationId	
			, [intTransactionDetailId]	= RS.intRetireStockId
			, [intAccountId]			= E.intAPClearingGLAccount
			, [intItemId]				= NULL
			, [intItemUOMId]			= NULL
			, [dblQuantity]				= ROUND(RS.dblSharesNo, 2)
			, [dblAmount]				= ROUND(RS.dblFaceValue, 2)	
			, [intOffsetId]				= NULL
			, [strOffsetId]				= NULL
			, [intOffsetDetailId]		= NULL
			, [intOffsetDetailTaxId]	= NULL		
			, [strCode]					= 'PAT'
			, [strRemarks]				= NULL
		FROM tblPATRetireStock RS
		CROSS JOIN tblPATCompanyPreference E
		WHERE RS.intRetireStockId = @intRetireStockId

		IF EXISTS(SELECT TOP 1 NULL FROM @APClearingtbl)
			EXEC dbo.uspAPClearing @APClearing = @APClearingtbl, @post = @ysnPosted
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