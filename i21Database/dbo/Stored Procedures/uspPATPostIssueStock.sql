CREATE PROCEDURE [dbo].[uspPATPostIssueStock]
	@intCustomerStockId INT = NULL,
	@ysnPosted BIT = NULL,
	@ysnRecap BIT = NULL,
	@ysnVoting BIT = NULL,
	@ysnRetired BIT = NULL,
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
DECLARE @intCreatedBillId INT;

CREATE TABLE #tempValidateTable (
	[strError] [NVARCHAR](MAX),
	[strTransactionType] [NVARCHAR](50),
	[strTransactionNo] [NVARCHAR](50),
	[intTransactionId] INT
);

IF(@batchId IS NULL)
	EXEC uspSMGetStartingNumber 3, @batchId OUT

SET @batchIdUsed = @batchId;

	SELECT	CS.intCustomerStockId,
			CS.intCustomerPatronId,
			CS.intStockId,
			CS.strCertificateNo,
			CS.strStockStatus,
			CS.dblSharesNo,
			CS.dtmIssueDate,
			CS.strActivityStatus,
			CS.dtmRetireDate,
			CS.intTransferredFrom,
			CS.dtmTransferredDate,
			CS.dblParValue,
			CS.dblFaceValue,
			CS.intBillId,
			CS.intInvoiceId,
			CS.ysnPosted
	INTO #tempCustomerStock
	FROM tblPATCustomerStock CS
		WHERE intCustomerStockId = @intCustomerStockId
		

IF(ISNULL(@ysnPosted,0) = 0)
BEGIN
	-------- VALIDATE IF CAN BE UNPOSTED
	INSERT INTO #tempValidateTable
	SELECT * FROM fnPATValidateAssociatedTransaction((SELECT intCustomerStockId FROM #tempCustomerStock),2)

	SELECT * FROM #tempValidateTable
	IF EXISTS(SELECT 1 FROM #tempValidateTable)
	BEGIN
		SELECT @error = V.strError FROM #tempValidateTable V
		RAISERROR(@error, 16, 1);
		GOTO Post_Rollback;
	END
END


IF (@ysnRetired = 1)
BEGIN
	IF(@ysnPosted = 1)
	BEGIN

	------------------------CREATE GL ENTRIES---------------------
		INSERT INTO @GLEntries
		SELECT * FROM [dbo].[fnPATCreateRetireStockGLEntries](@intCustomerStockId, 0, @intUserId, @batchId)

	END
	ELSE
	BEGIN
	------------------------REVERSE GL ENTRIES---------------------
		INSERT INTO @GLEntries
		SELECT * FROM [dbo].[fnPATReverseRetireStockGLEntries](@intCustomerStockId, @dateToday, @intUserId, @batchId)

		UPDATE tblGLDetail SET ysnIsUnposted = 1
		WHERE intTransactionId = @intCustomerStockId 
			AND strModuleName = N'Patronage' AND strTransactionForm = N'Retire Stock'
	END
END
ELSE
BEGIN
	IF(@ysnVoting = 1)
	BEGIN
		IF(@ysnPosted = 1)
		BEGIN

		------------------------CREATE GL ENTRIES---------------------
			INSERT INTO @GLEntries
			SELECT * FROM [dbo].[fnPATCreateIssueStockGLEntries](@intCustomerStockId, @ysnVoting, @intUserId, @batchId)

		END
		ELSE
		BEGIN

		------------------------REVERSE GL ENTRIES---------------------
			INSERT INTO @GLEntries
			SELECT * FROM [dbo].[fnPATReverseIssueStockGLEntries](@intCustomerStockId, @dateToday, @intUserId, @batchId)

			UPDATE tblGLDetail SET ysnIsUnposted = 1
			WHERE intTransactionId = @intCustomerStockId 
				AND strModuleName = N'Patronage' AND strTransactionForm = N'Issue Stock'
		END
	END
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


IF(@isGLSucces = 1)
BEGIN
	---------- UPDATE CUSTOMER STOCK TABLE ---------------
	UPDATE tblPATCustomerStock SET ysnPosted = @ysnPosted WHERE intCustomerStockId = @intCustomerStockId

	--------------------- RETIRED STOCKS ------------------	
	IF(@ysnRetired = 1)
	BEGIN
		IF(@ysnPosted = 1)
		BEGIN
			DECLARE @voucherDetailNonInventory AS VoucherDetailNonInventory;
			DECLARE @intCustomerId AS INT;
			DECLARE @dblFaceValue AS NUMERIC(18,6);
			DECLARE @strVenderOrderNumber AS NVARCHAR(50);
			DECLARE @apClearing AS INT;

			SELECT 
				@intCustomerId = tempCS.intCustomerPatronId,
				@dblFaceValue = tempCS.dblFaceValue,
				@strVenderOrderNumber = tempCS.strCertificateNo,
				@apClearing = ComPref.intAPClearingGLAccount
			FROM #tempCustomerStock tempCS
			CROSS APPLY tblPATCompanyPreference ComPref

			INSERT INTO @voucherDetailNonInventory([intAccountId], [strMiscDescription],[dblQtyReceived],[dblDiscount],[dblCost])
			VALUES(@apClearing, 'Patronage Retired Stock', 1, 0, @dblFaceValue);

			EXEC [dbo].[uspAPCreateBillData]
				@userId	= @intUserId
				,@vendorId = @intCustomerId
				,@type = 1	
				,@voucherNonInvDetails = @voucherDetailNonInventory
				,@shipTo = NULL
				,@vendorOrderNumber = @strVenderOrderNumber
				,@voucherDate = @dateToday
				,@billId = @intCreatedBillId OUTPUT

			UPDATE tblPATCustomerStock SET intBillId = @intCreatedBillId WHERE intCustomerStockId = @intCustomerStockId

			EXEC [dbo].[uspAPPostBill]
				@batchId = @intCreatedBillId,
				@billBatchId = NULL,
				@transactionType = NULL,
				@post = 1,
				@recap = 0,
				@isBatch = 0,
				@param = NULL,
				@userId = @intUserId,
				@beginTransaction = @intCreatedBillId,
				@endTransaction = @intCreatedBillId,
				@success = @success OUTPUT

		END
		ELSE
		BEGIN
			DELETE FROM tblAPBill WHERE intBillId IN (SELECT intBillId FROM #tempCustomerStock) AND ysnPaid <> 1;
			UPDATE tblPATCustomerStock SET intBillId = null WHERE intCustomerStockId = @intCustomerStockId
			EXEC uspPATProcessVoid @intCustomerStockId, @intUserId
		END

	END

END


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
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tempCustomerStock')) DROP TABLE #tempCustomerStock
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tempValidateTable')) DROP TABLE #tempValidateTable
END