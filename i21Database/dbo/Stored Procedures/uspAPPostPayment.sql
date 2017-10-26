﻿CREATE PROCEDURE uspAPPostPayment
	@batchId			AS NVARCHAR(40)		= NULL,
	@transactionType	AS NVARCHAR(30)		= NULL,
	@post				AS BIT				= 0,
	@recap				AS BIT				= 0,
	@isBatch			AS BIT				= 0,
	@param				AS NVARCHAR(MAX)	= NULL,
	@userId				AS INT,
	@beginDate			AS DATE				= NULL,
	@endDate			AS DATE				= NULL,
	@beginTransaction	AS NVARCHAR(50)		= NULL,
	@endTransaction		AS NVARCHAR(50)		= NULL,
	@exclude			AS NVARCHAR(MAX)	= NULL,
	@successfulCount	AS INT				= 0 OUTPUT,
	@invalidCount		AS INT				= 0 OUTPUT,
	@success			AS BIT				= 0 OUTPUT,
	@batchIdUsed		AS NVARCHAR(40)		= NULL OUTPUT,
	@recapId			AS NVARCHAR(250)	= NEWID OUTPUT
	--OUTPUT Parameter for GUID
	--Provision for Date Begin and Date End Parameter
	--Provision for Journal Begin and Journal End Parameter
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF
-- Start the transaction 
BEGIN TRY

IF @userId IS NULL
BEGIN
	RAISERROR('User is required', 16, 1);
END
--=====================================================================================================================================
-- 	DECLARE TEMPORARY TABLES
---------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE #tmpPayablePostData (
	[intPaymentId] [int] PRIMARY KEY,
	UNIQUE (intPaymentId)
);

CREATE TABLE #tmpPayableInvalidData (
	[strError] [NVARCHAR](100),
	[strTransactionType] [NVARCHAR](50),
	[strTransactionId] [NVARCHAR](50),
	[intTransactionId] INT
);

--DECLARRE VARIABLES
DECLARE @ErrorSeverity INT,
            @ErrorNumber   INT,
            @ErrorMessage nvarchar(4000),
            @ErrorState INT,
            @ErrorLine  INT,
            @ErrorProc nvarchar(200);
DECLARE @PostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully posted.'
DECLARE @UnpostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully unposted.'
DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Payable'
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Payable'
DECLARE @TRAN_TYPE NVARCHAR(25) = 'Payable'
DECLARE @paymentIds NVARCHAR(MAX) = @param
DECLARE @validPaymentIds NVARCHAR(MAX)
DECLARE @GLEntries AS RecapTableType 
DECLARE @count INT = 0;
DECLARE @prepayIds AS Id
DECLARE @payments AS Id
DECLARE @lenOfSuccessPay INT, @lenOfSuccessPrePay INT;
DECLARE @totalInvalid INT = 0;

SET @recapId = '1'

--SET BatchId
IF(@batchId IS NULL)
BEGIN
	EXEC uspSMGetStartingNumber 3, @batchId OUT
END

SET @batchIdUsed = @batchId

--=====================================================================================================================================
-- 	POPULATE TRANSACTIONS TO POST TEMPORARY TABLE
---------------------------------------------------------------------------------------------------------------------------------------
IF (@param IS NOT NULL) 
BEGIN
	IF(@param = 'all')
	BEGIN
		IF(@post = 0)
		BEGIN
			INSERT INTO #tmpPayablePostData SELECT intPaymentId FROM tblAPPayment WHERE ysnPosted = 0
		END
		ELSE IF(@post = 1)
		BEGIN
			INSERT INTO #tmpPayablePostData 
			SELECT intPaymentId FROM tblAPPayment WHERE ysnPosted = 1
			AND NOT EXISTS (SELECT 1 FROM tblCMBankTransaction WHERE strTransactionId = tblAPPayment.strPaymentRecordNum AND ysnClr = 1)
		END
	END
	ELSE
	BEGIN
		INSERT INTO #tmpPayablePostData SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@param)
	END
END

IF(@beginDate IS NOT NULL)
BEGIN
	INSERT INTO #tmpPayablePostData
	SELECT intPaymentId FROM tblAPPayment
	WHERE dtmDatePaid BETWEEN @beginDate AND @endDate
END

IF(@beginTransaction IS NOT NULL)
BEGIN
	INSERT INTO #tmpPayablePostData
	SELECT intPaymentId FROM tblAPPayment
	WHERE intPaymentId BETWEEN @beginTransaction AND @endTransaction
END

--Removed excluded bills to post/unpost
IF(@exclude IS NOT NULL)
BEGIN
	SELECT [intID] INTO #tmpPaymentsExclude FROM [dbo].fnGetRowsFromDelimitedValues(@exclude)
	DELETE FROM A
	FROM #tmpPayablePostData A
	WHERE EXISTS(SELECT * FROM #tmpPaymentsExclude B WHERE A.intPaymentId = B.intID)
END

--SET THE UPDATED @paymentIds
SELECT @paymentIds = COALESCE(@paymentIds + ',', '') +  CONVERT(VARCHAR(12),intPaymentId)
FROM #tmpPayablePostData
ORDER BY intPaymentId

--GET ALL PREPAY
INSERT INTO @prepayIds
SELECT 
	A.intPaymentId
FROM #tmpPayablePostData A
INNER JOIN tblAPPayment B ON A.intPaymentId = B.intPaymentId
WHERE B.ysnPrepay = 1 

--GET ALL PAYMENTS
INSERT INTO @payments
SELECT A.intPaymentId 
FROM #tmpPayablePostData A
INNER JOIN tblAPPayment B ON A.intPaymentId = B.intPaymentId
WHERE B.ysnPrepay != 1

--=====================================================================================================================================
-- 	GET ALL INVALID TRANSACTIONS
---------------------------------------------------------------------------------------------------------------------------------------
-- IF (ISNULL(@recap, 0) = 0)
-- BEGIN

--VALIDATIONS
INSERT INTO #tmpPayableInvalidData 
SELECT * FROM [fnAPValidatePostPayment](@payments, @post, @userId)
UNION ALL
SELECT * FROM [fnAPValidatePrepay](@prepayIds, @post, @userId)

SET @totalInvalid = (SELECT COUNT(*) FROM #tmpPayableInvalidData)

IF(@totalInvalid > 0)
BEGIN

	INSERT INTO tblAPPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
	SELECT strError, strTransactionType, strTransactionId, @batchId, intTransactionId FROM #tmpPayableInvalidData

	SET @invalidCount = @totalInvalid

	--DELETE Invalid Transaction From temp table
	DELETE A
	FROM @payments A
	INNER JOIN #tmpPayableInvalidData
		ON A.intId = #tmpPayableInvalidData.intTransactionId

	DELETE A
	FROM @prepayIds A
	INNER JOIN #tmpPayableInvalidData
		ON A.intId = #tmpPayableInvalidData.intTransactionId

	DELETE A
	FROM #tmpPayablePostData A
	INNER JOIN #tmpPayableInvalidData
		ON A.intPaymentId = #tmpPayableInvalidData.intTransactionId

END

DECLARE @totalRecords INT
SELECT @totalRecords = COUNT(*) 
FROM 
(
	SELECT intId FROM @payments
	UNION ALL 
	SELECT intId FROM @prepayIds
) PaymentRecords
IF(@totalRecords = 0)  
BEGIN
	SET @success = 1
	RETURN;
END

-- END

--DOUBLE VALIDATE, MAKE SURE TO NOT CONTINUE POSTING WHEN NOT RECORDS TO POST
IF @totalRecords = 0
BEGIN
	RAISERROR('No payment to post.', 16, 1);
END

--START THE TRANSACTION HERE, WE WANT THE ABOVE RESULT TO BE SAVED.. IT WILL USED BY THE POST RESULT SCREEN;
DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION

IF ISNULL(@post,0) = 1
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
	[dblExchangeRate],
	[dtmDateEntered] ,
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
	[intConcurrencyId],
	[dblDebitForeign],
    [dblDebitReport],
    [dblCreditForeign],
    [dblCreditReport],
    [dblReportingRate],
    [dblForeignRate],
	[strRateType])	
	SELECT 
	[dtmDate]     ,
	[strBatchId]  ,
	[intAccountId],
	[dblDebit]  ,
	[dblCredit] ,
	[dblDebitUnit],
	[dblCreditUnit],
	[strDescription],
	[strCode],    
	[strReference],
	[intCurrencyId],
	[dblExchangeRate],
	[dtmDateEntered] ,
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
	[intConcurrencyId],
	[dblDebitForeign],
    [dblDebitReport],
    [dblCreditForeign],
    [dblCreditReport],
    [dblReportingRate],
    [dblForeignRate],
	[strRateType]
	FROM dbo.[fnAPCreatePaymentGLEntries](@payments, @userId, @batchId)
	UNION ALL
	SELECT 
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
	[dblExchangeRate],
	[dtmDateEntered] ,
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
	[intConcurrencyId],
	[dblDebitForeign],
    [dblDebitReport],
    [dblCreditForeign],
    [dblCreditReport],
    [dblReportingRate],
    [dblForeignRate],
	[strRateType]
	FROM dbo.[fnAPCreatePaymentGLEntries](@prepayIds, @userId, @batchId) ORDER BY intTransactionId
END
ELSE
BEGIN
	INSERT INTO @GLEntries(
	[dtmDate],
	[strBatchId],
	[intAccountId],
	[dblDebit]  ,
	[dblCredit] ,
	[dblDebitUnit],
	[dblCreditUnit],
	[strDescription],
	[strCode],    
	[strReference],
	[intCurrencyId],
	[dblExchangeRate],
	[dtmDateEntered] ,
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
	[intConcurrencyId],
	[dblDebitForeign],
    [dblDebitReport],
    [dblCreditForeign],
    [dblCreditReport],
    [dblReportingRate],
    [dblForeignRate],
	[strRateType])
	SELECT 
	[dtmDate],
	[strBatchId]  ,
	[intAccountId],
	[dblDebit]  ,
	[dblCredit] ,
	[dblDebitUnit],
	[dblCreditUnit],
	[strDescription],
	[strCode],    
	[strReference],
	[intCurrencyId],
	[dblExchangeRate],
	[dtmDateEntered] ,
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
	[intConcurrencyId],
	[dblDebitForeign],
    [dblDebitReport],
    [dblCreditForeign],
    [dblCreditReport],
    [dblReportingRate],
    [dblForeignRate],
	[strRateType]
	FROM dbo.fnAPReverseGLEntries(@payments, 'Payable', DEFAULT, @userId, @batchId)
	UNION ALL
	SELECT 
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
	[dblExchangeRate],
	[dtmDateEntered] ,
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
	[intConcurrencyId],
	[dblDebitForeign],
    [dblDebitReport],
    [dblCreditForeign],
    [dblCreditReport],
    [dblReportingRate],
    [dblForeignRate],
	[strRateType]
	 FROM dbo.fnAPReverseGLEntries(@prepayIds, 'Payable', DEFAULT, @userId, @batchId)
END

--=====================================================================================================================================
-- 	CHECK IF THE PROCESS IS RECAP OR NOT
---------------------------------------------------------------------------------------------------------------------------------------
IF (ISNULL(@recap, 0) = 0)
BEGIN

	--BATCH POST
	EXEC uspGLBatchPostEntries @GLEntries, @batchId, @userId, @post

	--Add to invalid payment count those invalid GL entries
	SET @invalidCount = @totalInvalid + (SELECT COUNT(*) FROM tblGLPostResult B WHERE B.strDescription NOT LIKE '%success%' AND B.strBatchId = @batchId)

	--DELETE THE FAILED POST ENTRIES
	DELETE A
	FROM @payments A
	INNER JOIN tblGLPostResult B ON A.intId = B.intTransactionId
	WHERE B.strDescription NOT LIKE '%success%' AND B.strBatchId = @batchId

	DELETE A
	FROM @prepayIds A
	INNER JOIN tblGLPostResult B ON A.intId = B.intTransactionId
	WHERE B.strDescription NOT LIKE '%success%' AND B.strBatchId = @batchId

	--INSERT THE RESULT FOR SHOWING ON THE USER
	INSERT INTO tblAPPostResult(strMessage, strTransactionType, strTransactionId, intTransactionId, strBatchNumber)
	SELECT 
		A.strDescription
		,A.strTransactionType
		,A.strTransactionId
		,A.intTransactionId
		,@batchId
	FROM tblGLPostResult A
	WHERE A.strBatchId = @batchId

	--MAKE SURE THAT ALL GL ENTRIES ARE VALID
	SET @lenOfSuccessPay = (SELECT COUNT(*) FROM @payments)
	SET @lenOfSuccessPrePay = (SELECT COUNT(*) FROM @prepayIds)

	IF @lenOfSuccessPay = 0 AND @lenOfSuccessPrePay = 0
	BEGIN
		GOTO DONE;
	END

	IF @lenOfSuccessPay > 0 
	BEGIN
		--UPDATE tblAPPaymentDetail
		EXEC uspAPUpdatePaymentAmountDue @paymentIds = @payments, @post = @post
		--UPDATE BILL RECORDS
		EXEC uspAPUpdateBillPayment @paymentIds = @payments, @post = @post
	END
	
	--Update posted status
	UPDATE tblAPPayment
		SET		ysnPosted = @post
	WHERE	intPaymentId IN (SELECT intId FROM @payments UNION ALL SELECT intId FROM @prepayIds)

	UPDATE A
		SET A.ysnPrepayHasPayment = @post
	FROM tblAPBill A
	INNER JOIN tblAPPaymentDetail B ON A.intBillId = B.intBillId
	WHERE B.intPaymentId IN (SELECT intId FROM @prepayIds)

	--CREATE BANK TRANSACTION
	DECLARE @paymentForBankTransaction AS Id
	INSERT INTO @paymentForBankTransaction
	SELECT intPaymentId FROM #tmpPayablePostData
	EXEC uspAPUpdatePaymentBankTransaction @paymentIds = @paymentForBankTransaction, @post = @post, @userId = @userId, @batchId = @batchIdUsed

	--Insert Successfully posted transactions.
	INSERT INTO tblAPPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
	SELECT 
		CASE WHEN @post = 1 THEN @PostSuccessfulMsg ELSE @UnpostSuccessfulMsg END,
		'Payable',
		A.strPaymentRecordNum,
		@batchId,
		A.intPaymentId
	FROM tblAPPayment A
	WHERE intPaymentId IN (SELECT intId FROM @payments UNION ALL SELECT intId FROM @prepayIds)

	IF @post = 0
	BEGIN
		--UPDATE ysnIsUnposted of tblGLDetail
		UPDATE tblGLDetail
			SET tblGLDetail.ysnIsUnposted = 1
		FROM tblAPPayment A
			INNER JOIN tblGLDetail B
				ON A.intPaymentId = B.intTransactionId
		WHERE B.[strTransactionId] IN (SELECT strPaymentRecordNum FROM tblAPPayment 
							WHERE intPaymentId IN (SELECT intId FROM @payments UNION ALL SELECT intId FROM @prepayIds))

		--UPDATE strPaymentInfo
		UPDATE tblAPPayment
			SET strPaymentInfo = CASE WHEN B.dtmCheckPrinted IS NOT NULL AND ISNULL(A.strPaymentInfo,'') <> '' THEN B.strReferenceNo ELSE A.strPaymentInfo END
		FROM tblAPPayment A 
			INNER JOIN tblCMBankTransaction B
				ON A.strPaymentRecordNum = B.strTransactionId
		WHERE intPaymentId IN (SELECT intId FROM @payments UNION ALL SELECT intId FROM @prepayIds)
	END

	--OVERPAYMENT
	IF @post = 1 AND @lenOfSuccessPay > 0
	BEGIN
		--Create overpayment
		SELECT 
			intId 
		INTO #tmpPayableIds 
		FROM @payments A 
			INNER JOIN tblAPPayment B ON A.intId = B.intPaymentId 
		WHERE B.dblUnapplied > 0 --process only the records that has overpayment

		DECLARE @payId INT;
		SELECT TOP 1 @payId = intId FROM #tmpPayableIds
		WHILE (@payId IS NOT NULL)
		BEGIN
			EXEC uspAPCreateOverpayment @payId, @userId;
			DELETE FROM #tmpPayableIds WHERE intId = @payId;
			SET @payId = NULL;
			SELECT TOP 1 @payId = intId FROM #tmpPayableIds
		END
	END
	ELSE IF @post = 0
	BEGIN
		--remove overpayment when unposting
		DELETE A
		FROM tblAPBill A INNER JOIN tblAPPayment B ON A.strReference = B.strPaymentRecordNum
		WHERE B.intPaymentId IN (SELECT intId FROM @payments)
		AND A.intTransactionType = 8
	END

	--UPDATE 1099 Information
	EXEC [uspAPUpdateBill1099] @param
	
	--UPDATE INVOICES
	DECLARE @invoices Id
	INSERT INTO @invoices
	SELECT 
		B.intPaymentDetailId
	FROM @payments A
	INNER JOIN tblAPPaymentDetail B
		ON A.intId = B.intPaymentId
	WHERE B.intInvoiceId > 0
	IF EXISTS(SELECT 1 FROM @invoices)
	BEGIN
		EXEC [uspARSettleInvoice] @PaymentDetailId = @invoices, @userId = @userId, @post = @post, @void = 0
	END

	DECLARE @strDescription AS NVARCHAR(100),@actionType AS NVARCHAR(50),@PaymentId AS NVARCHAR(50);
	DECLARE @paymentCounter INT = 0;
	SELECT @actionType = CASE WHEN @post = 0 THEN 'Unposted' ELSE 'Posted' END

	WHILE(@paymentCounter != (@totalRecords))
	BEGIN
		SELECT @PaymentId = CAST((SELECT TOP(1) intPaymentId FROM #tmpPayablePostData) AS NVARCHAR(50))
		
		EXEC dbo.uspSMAuditLog 
		   @screenName = 'AccountsPayable.view.PayVouchersDetail'		-- Screen Namespace
		  ,@keyValue = @PaymentId								-- Primary Key Value of the Voucher. 
		  ,@entityId = @userId									-- Entity Id.
		  ,@actionType = @actionType                        -- Action Type
		  ,@changeDescription = @strDescription				-- Description
		  ,@fromValue = ''									-- Previous Value
		  ,@toValue = ''
		SET @paymentCounter = @paymentCounter + 1
		DELETE FROM #tmpPayablePostData WHERE intPaymentId = @PaymentId
	END
END
ELSE
	BEGIN

		--RECAP
		--TODO:
		--DELETE TABLE PER Session
		DELETE FROM tblGLPostRecap
			WHERE intTransactionId IN (SELECT intId FROM @payments UNION ALL SELECT intId FROM @prepayIds);

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
			,[dblDebitForeign]
			,[dblCreditForeign]
			,[strRateType]
		)
		SELECT
			[strTransactionId]
			,A.[intTransactionId]
			,A.[intAccountId]
			,A.[strDescription]
			,A.[strJournalLineDescription]
			,A.[strReference]	
			,A.[dtmTransactionDate]
			,Debit.Value--[dblDebit]
			,Credit.Value--[dblCredit]
			,A.[dblDebitUnit]
			,A.[dblCreditUnit]
			,A.[dtmDate]
			,A.[ysnIsUnposted]
			,A.[intConcurrencyId]	
			,A.[dblForeignRate]
			,A.[intUserId]
			,A.[dtmDateEntered]
			,A.[strBatchId]
			,A.[strCode]
			,A.[strModuleName]
			,A.[strTransactionForm]
			,A.[strTransactionType]
			,B.strAccountId
			,C.strAccountGroup
			,DebitForeign.Value
			,CreditForeign.Value
			,A.strRateType
		FROM @GLEntries A
		INNER JOIN dbo.tblGLAccount B 
			ON A.intAccountId = B.intAccountId
		INNER JOIN dbo.tblGLAccountGroup C
			ON B.intAccountGroupId = C.intAccountGroupId
		CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebit, 0) - ISNULL(A.dblCredit, 0)) Debit
		CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebit, 0) - ISNULL(A.dblCredit, 0))  Credit
		CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebitForeign, 0) - ISNULL(A.dblCreditForeign, 0)) DebitForeign
		CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebitForeign, 0) - ISNULL(A.dblCreditForeign, 0)) CreditForeign;
	END

IF(ISNULL(@recap,0) = 0)
BEGIN
----DELETE PAYMENT DETAIL WITHOUT PAYMENT AMOUNT
	IF @post = 1 AND @lenOfSuccessPay > 0
	BEGIN		
		DELETE FROM tblAPPaymentDetail
		WHERE intPaymentId IN (SELECT intPaymentId FROM @payments)
		AND dblPayment = 0
	END
END

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpPayablePostData')) DROP TABLE #tmpPayablePostData
IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..##tmpPayableInvalidData')) DROP TABLE #tmpPayableInvalidData

DONE:
IF @transCount = 0 COMMIT TRANSACTION
SET @success = 1
SET @successfulCount = @totalRecords

END TRY
BEGIN CATCH
        -- Grab error information from SQL functions
    SET @ErrorSeverity = ERROR_SEVERITY()
    SET @ErrorNumber   = ERROR_NUMBER()
    SET @ErrorMessage  = ERROR_MESSAGE()
    SET @ErrorState    = ERROR_STATE()
    SET @ErrorLine     = ERROR_LINE()
    SET @ErrorProc     = ERROR_PROCEDURE()
    --SET @ErrorMessage  = 'Problem posting payment.' + CHAR(13) + @ErrorMessage
    -- Not all errors generate an error state, to set to 1 if it's zero
    IF @ErrorState  = 0
    SET @ErrorState = 1
    -- If the error renders the transaction as uncommittable or we have open transactions, we may want to rollback
    IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION
	SET @success = 0;
    RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH