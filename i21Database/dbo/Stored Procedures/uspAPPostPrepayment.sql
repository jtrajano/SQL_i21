﻿CREATE PROCEDURE [dbo].[uspAPPostPrepayment]
	@batchId			AS NVARCHAR(20)		= NULL,
	@post				AS BIT				= 0,
	@recap				AS BIT				= 0,
	@prepaymentId		AS INT,
	@userId				AS INT,
	@success			AS BIT				= 0 OUTPUT,
	@batchIdUsed		AS NVARCHAR(20)		= NULL OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION

DECLARE @ErrorSeverity INT,
            @ErrorNumber   INT,
            @ErrorMessage nvarchar(4000),
            @ErrorState INT,
            @ErrorLine  INT,
            @ErrorProc nvarchar(200);

DECLARE @GLEntries AS RecapTableType 
DECLARE @PostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully posted.'
DECLARE @UnpostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully unposted.'

CREATE TABLE #tmpPrepayInvalidData (
	[strError] [NVARCHAR](100),
	[strTransactionType] [NVARCHAR](50),
	[strTransactionId] [NVARCHAR](50),
	[intTransactionId] INT
);

--SET BatchId
IF(@batchId IS NULL)
BEGIN
	EXEC uspSMGetStartingNumber 3, @batchId OUT
END

SET @batchIdUsed = @batchId

--INSERT INTO #tmpPrepayInvalidData 
--SELECT * FROM [fnAPValidatePrepay](@paymentIds, @post, @userId)

IF ISNULL(@post,0) = 1
BEGIN
	INSERT INTO @GLEntries
	SELECT * FROM dbo.[fnAPCreatePrepaymentGLEntries](@prepaymentId, @userId, @batchId)
END
ELSE
BEGIN
	INSERT INTO @GLEntries
	SELECT * FROM dbo.fnAPReverseGLEntries(CAST(@prepaymentId AS NVARCHAR(10)), 'Payable', DEFAULT, @userId, @batchId)
END

--=====================================================================================================================================
-- 	CHECK IF THE PROCESS IS RECAP OR NOT
---------------------------------------------------------------------------------------------------------------------------------------
IF (ISNULL(@recap, 0) = 0)
BEGIN

	EXEC uspGLBookEntries @GLEntries, @post

	IF(ISNULL(@post,0) = 0)
	BEGIN
		
		UPDATE tblGLDetail
			SET tblGLDetail.ysnIsUnposted = 1
		FROM tblAPPayment A
			INNER JOIN tblGLDetail B
				ON A.intPaymentId = B.intTransactionId
		WHERE B.[strTransactionId] IN (SELECT strPaymentRecordNum FROM tblAPPayment 
							WHERE intPaymentId IN (@prepaymentId))

		-- Creating the temp table:
		DECLARE @isSuccessful BIT
		CREATE TABLE #tmpCMBankTransaction (
         --[intTransactionId] INT PRIMARY KEY,
         [strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL,
         UNIQUE (strTransactionId))

		INSERT INTO #tmpCMBankTransaction
		 SELECT strPaymentRecordNum FROM tblAPPayment A
		 WHERE A.intPaymentId = @prepaymentId

		-- Calling the stored procedure
		EXEC dbo.uspCMBankTransactionReversal @userId, DEFAULT, @isSuccessful OUTPUT

		IF @isSuccessful = 0
		BEGIN
			RAISERROR('Failed to reverse bank transaction.', 16, 1);
		END

		--update payment record based on record from tblCMBankTransaction
		UPDATE tblAPPayment
			SET strPaymentInfo = CASE WHEN B.dtmCheckPrinted IS NOT NULL AND ISNULL(A.strPaymentInfo,'') <> '' THEN B.strReferenceNo ELSE A.strPaymentInfo END
		FROM tblAPPayment A 
			INNER JOIN tblCMBankTransaction B
				ON A.strPaymentRecordNum = B.strTransactionId
		WHERE intPaymentId IN (@prepaymentId)

		--update payment record
		UPDATE tblAPPayment
			SET ysnPosted= 0
		FROM tblAPPayment A 
		WHERE intPaymentId IN (@prepaymentId)

		--UPDATE POSTED PREPAYMENT
		--UPDATE A
		--	SET A.ysnPosted = 0
		--FROM tblAPBill A
		--INNER JOIN tblAPPaymentDetail B ON A.intBillId = B.intBillId
		--WHERE B.intPaymentId IN (@prepaymentId)

		--Insert Successfully unposted transactions.
		INSERT INTO tblAPPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
		SELECT 
			@UnpostSuccessfulMsg,
			'Payable',
			A.strPaymentRecordNum,
			@batchId,
			A.intPaymentId
		FROM tblAPPayment A
		WHERE intPaymentId IN (@prepaymentId)

	END
	ELSE
	BEGIN

		-- Update the posted flag in the transaction table
		UPDATE tblAPPayment
		SET		ysnPosted = 1
				--,intConcurrencyId += 1 
		WHERE	intPaymentId IN (@prepaymentId)

		--UPDATE POSTED PREPAYMENT
		--UPDATE A
		--	SET A.ysnPosted = 1
		--FROM tblAPBill A
		--INNER JOIN tblAPPaymentDetail B ON A.intBillId = B.intBillId
		--WHERE B.intPaymentId IN (@prepaymentId)
		
		--Insert to bank transaction
		INSERT INTO tblCMBankTransaction(
			[strTransactionId],
			[intBankTransactionTypeId],
			[intBankAccountId],
			[intCurrencyId],
			[dblExchangeRate],
			[dtmDate],
			[strPayee],
			[intPayeeId],
			[strAddress],
			[strZipCode],
			[strCity],
			[strState],
			[strCountry],
			[dblAmount],
			[strAmountInWords],
			[strMemo],
			[strReferenceNo],
			[ysnCheckToBePrinted],
			[ysnCheckVoid],
			[ysnPosted],
			[strLink],
			[ysnClr],
			[dtmDateReconciled],
			[intEntityId],
			[intCreatedUserId],
			[dtmCreated],
			[intLastModifiedUserId],
			[dtmLastModified],
			[intConcurrencyId]
		)
		SELECT
			[strTransactionId] = A.strPaymentRecordNum,
			[intBankTransactionTypeID] = CASE WHEN (SELECT LOWER(strPaymentMethod) FROM tblSMPaymentMethod WHERE intPaymentMethodID = A.intPaymentMethodId) = 'echeck' THEN 20 
							ELSE (SELECT TOP 1 intBankTransactionTypeId FROM tblCMBankTransactionType WHERE strBankTransactionTypeName = 'AP Payment') END,
			[intBankAccountID] = A.intBankAccountId,
			[intCurrencyID] = A.intCurrencyId,
			[dblExchangeRate] = 0,
			[dtmDate] = A.dtmDatePaid,
			[strPayee] = (SELECT TOP 1 strName FROM tblEntity WHERE intEntityId = B.intEntityVendorId),
			[intPayeeId] = B.intEntityVendorId,
			[strAddress] = '',
			[strZipCode] = '',
			[strCity] = '',
			[strState] = '',
			[strCountry] = '',
			[dblAmount] = A.dblAmountPaid,
			[strAmountInWords] = dbo.fnConvertNumberToWord(A.dblAmountPaid),
			[strMemo] = A.strNotes,
			[strReferenceNo] = CASE WHEN (SELECT strPaymentMethod FROM tblSMPaymentMethod WHERE intPaymentMethodID = A.intPaymentMethodId) = 'Cash' THEN 'Cash' ELSE A.strPaymentInfo END,
			[ysnCheckToBePrinted] = 1,
			[ysnCheckVoid] = 0,
			[ysnPosted] = 1,
			[strLink] = @batchId,
			[ysnClr] = 0,
			[dtmDateReconciled] = NULL,
			[intEntityId] = A.intEntityId,
			[intCreatedUserID] = @userId,
			[dtmCreated] = GETDATE(),
			[intLastModifiedUserID] = NULL,
			[dtmLastModified] = GETDATE(),
			[intConcurrencyId] = 1
			FROM tblAPPayment A
				INNER JOIN tblAPVendor B
					ON A.intEntityVendorId = B.intEntityVendorId
				--LEFT JOIN tblSMPaymentMethod C ON A.intPaymentMethodId = C.intPaymentMethodID
			WHERE A.intPaymentId IN (@prepaymentId)
			--AND C.strPaymentMethod = 'Check'

		--Insert Successfully posted transactions.
		INSERT INTO tblAPPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
		SELECT 
			@PostSuccessfulMsg,
			'Payable',
			A.strPaymentRecordNum,
			@batchId,
			A.intPaymentId
		FROM tblAPPayment A
		WHERE intPaymentId IN (@prepaymentId)
	END
END
ELSE
	BEGIN

		--RECAP
		--TODO:
		--DELETE TABLE PER Session
		DELETE FROM tblGLPostRecap
			WHERE intTransactionId IN (@prepaymentId);

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
			,Debit.Value--[dblDebit]
			,Credit.Value--[dblCredit]
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
		CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebit, 0) - ISNULL(A.dblCredit, 0)) Debit
		CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebit, 0) - ISNULL(A.dblCredit, 0))  Credit;
	END

IF @transCount = 0 COMMIT TRANSACTION
SET @success = 1

END TRY
BEGIN CATCH
        -- Grab error information from SQL functions
    SET @ErrorSeverity = ERROR_SEVERITY()
    SET @ErrorNumber   = ERROR_NUMBER()
    SET @ErrorMessage  = ERROR_MESSAGE()
    SET @ErrorState    = ERROR_STATE()
    SET @ErrorLine     = ERROR_LINE()
    SET @ErrorProc     = ERROR_PROCEDURE()
    SET @ErrorMessage  = 'Problem duplicating bill.' + CHAR(13) + 
			'SQL Server Error Message is: ' + CAST(@ErrorNumber AS VARCHAR(10)) + 
			' in procedure: ' + @ErrorProc + ' Line: ' + CAST(@ErrorLine AS VARCHAR(10)) + ' Error text: ' + @ErrorMessage
    -- Not all errors generate an error state, to set to 1 if it's zero
    IF @ErrorState  = 0
    SET @ErrorState = 1
    -- If the error renders the transaction as uncommittable or we have open transactions, we may want to rollback
    IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION
	SET @success = 0;
    RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH

