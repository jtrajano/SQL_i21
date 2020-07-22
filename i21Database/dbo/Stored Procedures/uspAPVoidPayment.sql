CREATE PROCEDURE [dbo].[uspAPVoidPayment]
	@paymentIds NVARCHAR(MAX),
	@voidDate DATETIME,
	@intUserId INT
AS
BEGIN

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET ANSI_WARNINGS OFF

	BEGIN TRY
	
	DECLARE @newPaymentId INT;
	DECLARE @description NVARCHAR(200) = 'Void transaction for ';
	DECLARE @GLEntries AS RecapTableType 
	DECLARE @batchId NVARCHAR(20)
	DECLARE @createdPayments NVARCHAR(MAX)
	DECLARE @paymentKeys AS Id;
	DECLARE @transCount INT = @@TRANCOUNT;

	IF @transCount = 0 BEGIN TRANSACTION

	EXEC uspSMGetStartingNumber 3, @batchId OUT

	CREATE TABLE #tmpPayables (
		[intPaymentId] INT,
		[intNewPaymentId] INT
	);

	INSERT INTO @paymentKeys
	SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@paymentIds)

	--Validate
	--Do not allow to void if not yet posted
	IF EXISTS(SELECT 1 FROM tblAPPayment WHERE intPaymentId IN (SELECT intId FROM @paymentKeys) AND ysnPosted = 0)
	BEGIN
		RAISERROR('Void failed. Payment not yet posted', 16, 1);
	END

	IF EXISTS(SELECT 1 FROM tblAPPayment A
				INNER JOIN tblCMBankTransaction B ON A.strPaymentRecordNum = B.strTransactionId
				WHERE intPaymentId IN (SELECT intId FROM @paymentKeys) AND A.ysnPosted = 1 AND (B.dtmCheckPrinted IS NULL OR B.ysnCheckVoid = 1 OR B.ysnClr = 1))
	BEGIN
		RAISERROR('Void failed. Payment already void or not yet printed or it has been cleared.', 16, 1);
	END

	--DO NOT ALLOW TO VOID THE PREPAYMENT PAYMENT IF IT WAS APPLIED ON THE BILLS
	IF(
		EXISTS(SELECT 1 FROM tblAPPayment A
					INNER JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
					INNER JOIN tblAPBill C ON B.intBillId = C.intBillId
					INNER JOIN tblAPAppliedPrepaidAndDebit D ON C.intBillId = D.intTransactionId
					INNER JOIN tblAPBill E ON D.intBillId = E.intBillId
					WHERE A.intPaymentId IN (SELECT intId FROM @paymentKeys)
					AND D.dblAmountApplied > 0
					AND E.ysnPosted = 1
					AND B.ysnOffset = 0)
		)
	BEGIN
		RAISERROR('Void failed. There are bills that applied this prepayment. Please unpost that first.', 16, 1);
	END

	--DO NOT ALLOW TO VOID IF PAYMENT WAS CREATED FROM IMPORTING.
	IF(EXISTS(SELECT 1 FROM tblAPPayment A WHERE A.intPaymentId IN (SELECT intId FROM @paymentKeys) AND ysnOrigin = 1))
	BEGIN
		RAISERROR('Unable to void payment created from origin.', 16, 1);
	END

	--Duplicate payment
	SELECT
	*
	INTO #tmpPayment
	FROM tblAPPayment A
	WHERE A.intPaymentId IN (SELECT intId FROM @paymentKeys)

	--DELETE FROM #tmpPayables
	IF OBJECT_ID('dbo.[UK_dbo.tblAPPayment_strPaymentRecordNum]', 'UQ') IS NOT NULL 
	ALTER TABLE tblAPPayment DROP CONSTRAINT [UK_dbo.tblAPPayment_strPaymentRecordNum]

	--Insert new payment records
	MERGE INTO tblAPPayment
	USING #tmpPayment p
	ON 1 = 0
	WHEN NOT MATCHED THEN
		INSERT
		(
			[intAccountId],
			[intBankAccountId],
			[intPaymentMethodId],
			[intCurrencyId],
			[intCompanyLocationId],
			[intCompanyId],
			[intUnitOfMeasureId],
			[strPaymentInfo],
			[strCheckMessage],
			[strNotes],
			[dtmDatePaid],
			[dblAmountPaid],
			[dblExchangeRate],
			[dblQuantity],
			[dblUnapplied],
			[ysnPosted],
			[dblWithheld],
			[intUserId],
			[intConcurrencyId],
			[intEntityId],
			[intEntityVendorId],
			[ysnOrigin],
			[ysnOverridePayTo],
			--[ysnVoid],
			[ysnPrinted],
			[ysnDeleted],
			[dtmDateDeleted],
			[ysnPrepay]
		)
		VALUES
		(
			p.[intAccountId],
			p.[intBankAccountId],
			p.[intPaymentMethodId],
			p.[intCurrencyId],
			p.[intCompanyLocationId],
			p.[intCompanyId],
			p.[intUnitOfMeasureId],
			p.[strPaymentInfo],
			p.[strCheckMessage],
			p.[strNotes],
			p.[dtmDatePaid],
			p.[dblAmountPaid],
			p.[dblExchangeRate],
			p.[dblQuantity],
			p.[dblUnapplied],
			p.[ysnPosted],
			p.[dblWithheld],
			p.[intUserId],
			p.[intConcurrencyId],
			p.[intEntityId],
			p.[intEntityVendorId],
			p.[ysnOrigin],
			p.[ysnOverridePayTo],
			--p.[ysnVoid],
			p.[ysnPrinted],
			p.[ysnDeleted],
			p.[dtmDateDeleted],
			p.[ysnPrepay]
		)
		OUTPUT p.intPaymentId, inserted.intPaymentId INTO #tmpPayables(intPaymentId, intNewPaymentId); --get the new and old payment id

	--update the new payment
	UPDATE A
		SET A.dtmDatePaid = @voidDate
		,A.strNotes = CASE WHEN ISNULL(A.strNotes,'') = '' THEN  @description + OldPayments.strPaymentRecordNum ELSE ' ' + @description + OldPayments.strPaymentRecordNum END
		,A.strPaymentRecordNum = OldPayments.strPaymentRecordNum + 'V'
		-- ,A.strPaymentInfo = 'Voided-' + A.strPaymentInfo
		,A.dblAmountPaid = A.dblAmountPaid * -1
		,A.dblWithheld = A.dblWithheld * -1
	FROM tblAPPayment A
	INNER JOIN #tmpPayables B
		ON A.intPaymentId = B.intNewPaymentId
	CROSS APPLY
	(
		SELECT 
			C.intPaymentId 
			,D.strPaymentRecordNum
		FROM #tmpPayables C
			INNER JOIN tblAPPayment D ON C.intPaymentId = D.intPaymentId
		WHERE C.intPaymentId = B.intPaymentId
	) OldPayments
	--WHERE B.intNewPaymentId IS NOT NULL

	IF OBJECT_ID(N'tempdb..#tmpPaymentDetail') IS NOT NULL DROP TABLE #tmpPaymentDetail

	SELECT
	*
	INTO #tmpPaymentDetail
	FROM tblAPPaymentDetail
	WHERE intPaymentId IN (SELECT intPaymentId FROM #tmpPayment)

	--Update foreign key
	ALTER TABLE #tmpPaymentDetail DROP COLUMN intPaymentDetailId
	UPDATE A
		SET A.intPaymentId  = B.intNewPaymentId
		,A.dblPayment = A.dblPayment * -1
		,A.dblDiscount = A.dblDiscount * -1
		,A.dblTotal = A.dblTotal * -1
		,A.intOrigBillId = A.intBillId
		,A.intBillId = NULL
		,A.intOrigInvoiceId = A.intInvoiceId
		,A.intInvoiceId = NULL
	FROM #tmpPaymentDetail A
	INNER JOIN #tmpPayables B
		ON A.intPaymentId = B.intPaymentId

	--Insert new payment detail records
	INSERT INTO tblAPPaymentDetail
	SELECT * FROM #tmpPaymentDetail

	--Reverse bank transaction
	DECLARE @isSuccessful BIT
	CREATE TABLE #tmpCMBankTransaction (
        --[intTransactionId] INT PRIMARY KEY,
        [strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL,
        UNIQUE (strTransactionId))

	--REVERSE ONLY THOSE ORIGINAL payments
	INSERT INTO #tmpCMBankTransaction
		SELECT strPaymentRecordNum FROM tblAPPayment A
		INNER JOIN #tmpPayables B ON A.intPaymentId = B.intPaymentId --AND B.intNewPaymentId IS NULL

	-- Calling the stored procedure
	EXEC dbo.uspCMBankTransactionReversal @intUserId, @voidDate, @isSuccessful OUTPUT

	IF @isSuccessful = 0
	BEGIN
		ALTER TABLE tblAPPayment ADD CONSTRAINT [UK_dbo.tblAPPayment_strPaymentRecordNum] UNIQUE (strPaymentRecordNum);
		RAISERROR('There was an error on reversing bank transaction.', 16, 1);
	END

	--Create CSV of new payments
	SELECT @createdPayments = COALESCE(@createdPayments + ',', '') +  CONVERT(VARCHAR(12),intNewPaymentId)
	FROM #tmpPayables WHERE intNewPaymentId IS NOT NULL
	ORDER BY intNewPaymentId
	
	DECLARE @Ids AS Id
	INSERT INTO @Ids
	SELECT DISTINCT intPaymentId FROM #tmpPayables

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
	FROM dbo.[fnAPReverseGLEntries](@Ids, 'Payable', @voidDate, @intUserId, @batchId)

	--Reversed gl entries of void check should be posted
	UPDATE A
		SET A.ysnIsUnposted = 0,
		A.dtmDate = @voidDate,
		A.strTransactionId = A.strTransactionId + 'V',
		A.intTransactionId = B.intNewPaymentId
	FROM @GLEntries A
	INNER JOIN #tmpPayables B ON A.intTransactionId = B.intPaymentId

	BEGIN TRY
		EXEC uspGLBookEntries @GLEntries, 1
	END TRY
	BEGIN CATCH
		ALTER TABLE tblAPPayment ADD CONSTRAINT [UK_dbo.tblAPPayment_strPaymentRecordNum] UNIQUE (strPaymentRecordNum);
		DECLARE @error NVARCHAR(200) = ERROR_MESSAGE()
		RAISERROR(@error, 16, 1);
	END CATCH

	--UPDATE Original Payments
	UPDATE A
		SET A.strNotes = 'Transaction Voided on ' + A.strPaymentRecordNum + 'V'
		,A.strPaymentInfo = C.strReferenceNo
	FROM tblAPPayment A
		INNER JOIN #tmpPayables B
		ON A.intPaymentId = B.intPaymentId
		INNER JOIN tblCMBankTransaction C
		ON A.strPaymentRecordNum = C.strTransactionId
	--WHERE B.intNewPaymentId IS NULL

	--Unposting Process
	UPDATE B
	SET B.dblAmountDue = CASE WHEN B.ysnOffset = 0 AND C.intTransactionType IN (2, 13) THEN B.dblAmountDue --DO NOTHING IF PREPAYMENT VOIDING
								ELSE 
									(CASE WHEN B.dblAmountDue = 0 
										THEN CAST(B.dblDiscount + B.dblPayment - B.dblInterest AS DECIMAL(18,2)) 
										ELSE (ISNULL(C.dblAmountDue,0) + B.dblPayment + B.dblDiscount - B.dblInterest) --this will handle issue on voiding which the first payment is voided
									END)
							END
		,B.intOrigBillId = B.intBillId
		,B.intBillId = NULL
		,B.intOrigInvoiceId = B.intInvoiceId
		,B.intInvoiceId = NULL
	FROM tblAPPayment A
		INNER JOIN tblAPPaymentDetail B
			ON A.intPaymentId = B.intPaymentId
		LEFT JOIN tblAPBill C
			ON C.intBillId = ISNULL(B.intOrigBillId, B.intBillId)
	WHERE A.intPaymentId IN (SELECT intPaymentId FROM #tmpPayables)

	--Update dblAmountDue, dtmDatePaid and ysnPaid on tblAPBill
	UPDATE C
		SET C.dblAmountDue = ABS(B.dblAmountDue),
			C.ysnPaid = 0,
			C.dtmDatePaid = NULL,
			C.dblWithheld = 0,
			C.dblPayment = CASE WHEN (C.dblPayment - ABS(B.dblPayment)) < 0 THEN 0 ELSE (C.dblPayment - ABS(B.dblPayment)) END,
			C.ysnPrepayHasPayment = CASE WHEN C.intTransactionType IN (2,13)
										THEN (
											CASE WHEN B.ysnOffset = 0
											THEN 0 ELSE 1 END
										)
										ELSE 0 END
			--C.ysnPosted = CASE WHEN A.ysnPrepay = 1 THEN 0 ELSE 1 END
	FROM tblAPPayment A
				INNER JOIN tblAPPaymentDetail B 
						ON A.intPaymentId = B.intPaymentId
				INNER JOIN tblAPBill C
						ON C.intBillId = ISNULL(B.intOrigBillId, B.intBillId)
				WHERE A.intPaymentId IN (SELECT intPaymentId FROM #tmpPayables)

	--UPDATE INVOICES
	DECLARE @invoices Id
	INSERT INTO @invoices
	SELECT DISTINCT
		B.intPaymentDetailId
	FROM @paymentKeys A
	INNER JOIN tblAPPaymentDetail B
		ON A.intId = B.intPaymentId
	WHERE B.intOrigInvoiceId > 0
	IF EXISTS(SELECT 1 FROM @invoices)
	BEGIN
		EXEC [uspARSettleInvoice] @PaymentDetailId = @invoices, @userId = @intUserId, @post = 0, @void = 1
	END

	--REMOVE OVERPAYMENT CREATED
	DELETE A
	FROM tblAPBill A INNER JOIN tblAPPayment B ON A.strReference = B.strPaymentRecordNum
	WHERE B.intPaymentId IN (SELECT intId FROM @paymentKeys)
	AND A.intTransactionType = 8

	ALTER TABLE tblAPPayment ADD CONSTRAINT [UK_dbo.tblAPPayment_strPaymentRecordNum] UNIQUE (strPaymentRecordNum);
	
	DECLARE @strDescription AS NVARCHAR(100),@PaymentId AS NVARCHAR(50);
	DECLARE @paymentCounter INT = 0, @totalRecords INT = 0, @Id NVARCHAR(50);

	DECLARE @voucherHistory AS Id
	INSERT INTO @voucherHistory
	SELECT
		DISTINCT intPaymentDetailId
	FROM @paymentKeys payments
	INNER JOIN tblAPPaymentDetail B ON payments.intId = B.intPaymentId
	EXEC uspAPUpdateVoucherHistory @paymentDetailIds = @voucherHistory, @post = 0

	SET @totalRecords = (SELECT COUNT(*) FROM @paymentKeys)
	WHILE(@paymentCounter != (@totalRecords))
	BEGIN
		SELECT @Id = CAST((SELECT TOP(1) intId FROM @paymentKeys) AS NVARCHAR(50))
		
		EXEC dbo.uspSMAuditLog 
		   @screenName = 'AccountsPayable.view.PayVouchersDetail'		-- Screen Namespace
		  ,@keyValue = @Id								-- Primary Key Value of the Voucher. 
		  ,@entityId = @intUserId									-- Entity Id.
		  ,@actionType = 'Voided'                        -- Action Type
		  ,@changeDescription = @strDescription				-- Description
		  ,@fromValue = ''									-- Previous Value
		  ,@toValue = ''
		SET @paymentCounter = @paymentCounter + 1
		DELETE FROM @paymentKeys WHERE intId = @Id
	END

	IF @transCount = 0 COMMIT TRANSACTION

	END TRY
	BEGIN CATCH
		DECLARE @ErrorSeverity INT,
				@ErrorNumber   INT,
				@ErrorMessage nvarchar(4000),
				@ErrorState INT,
				@ErrorLine  INT,
				@ErrorProc nvarchar(200);
		-- Grab error information from SQL functions
		SET @ErrorSeverity = ERROR_SEVERITY()
		SET @ErrorNumber   = ERROR_NUMBER()
		SET @ErrorMessage  = ERROR_MESSAGE()
		SET @ErrorState    = ERROR_STATE()
		SET @ErrorLine     = ERROR_LINE()
		IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION
		RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
	END CATCH

END