CREATE PROCEDURE [dbo].[uspAPVoidPayment]
	@paymentIds NVARCHAR(MAX),
	@voidDate DATETIME,
	@intUserId INT
AS
BEGIN

	BEGIN TRANSACTION

	DECLARE @newPaymentId INT;
	DECLARE @description NVARCHAR(200) = 'Void transaction for ';
	DECLARE @GLEntries AS RecapTableType 
	DECLARE @batchId NVARCHAR(20)
	DECLARE @createdPayments NVARCHAR(MAX)

	EXEC uspSMGetStartingNumber 3, @batchId OUT

	CREATE TABLE #tmpPayables (
		[intPaymentId] INT,
		[intNewPaymentId] INT);

	INSERT INTO #tmpPayables(intPaymentId)
	SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@paymentIds)

	--Validate
	--Do not allow to void if not yet posted
	IF EXISTS(SELECT 1 FROM tblAPPayment WHERE intPaymentId IN (SELECT intPaymentId FROM #tmpPayables) AND ysnPosted = 0)
	BEGIN
		RAISERROR('Void failed. Payment not yet posted', 16, 1);
	END

	IF EXISTS(SELECT 1 FROM tblAPPayment A
				INNER JOIN tblCMBankTransaction B ON A.strPaymentRecordNum = B.strTransactionId
				WHERE intPaymentId IN (SELECT intPaymentId FROM #tmpPayables) AND A.ysnPosted = 1 AND (B.dtmCheckPrinted IS NULL OR B.ysnCheckVoid = 1 OR B.ysnClr = 1))
	BEGIN
		RAISERROR('Void failed. Payment already void or not yet printed or it has been cleared.', 16, 1);
	END

	--DO NOT ALLOW TO VOID THE PREPAYMENT PAYMENT IF IT WAS APPLIED ON THE BILLS
	IF(EXISTS(SELECT 1 FROM tblAPPayment A
					INNER JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
					INNER JOIN tblAPBill C ON B.intBillId = C.intBillId
					INNER JOIN tblAPAppliedPrepaidAndDebit D ON C.intBillId = D.intTransactionId
					INNER JOIN tblAPBill E ON D.intBillId = E.intBillId
					WHERE A.intPaymentId IN (6258)
					AND D.dblAmountApplied > 0
					AND E.ysnPosted = 1))
	BEGIN
		RAISERROR('Void failed. There are bills that applied this payment. Please unpost that first.', 16, 1);
	END

	IF @@ERROR != 0
	BEGIN
		ROLLBACK TRANSACTION
		RETURN;
	END

	--Duplicate payment
	SELECT
	*
	INTO #tmpPayment
	FROM tblAPPayment A
	WHERE A.intPaymentId IN (SELECT intPaymentId FROM #tmpPayables)

	--DELETE FROM #tmpPayables

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
			[strPaymentInfo],
			[strNotes],
			[dtmDatePaid],
			[dblAmountPaid],
			[dblUnapplied],
			[ysnPosted],
			[strPaymentRecordNum],
			[dblWithheld],
			[intUserId],
			[intConcurrencyId],
			[intEntityId],
			[intEntityVendorId],
			[ysnOrigin],
			[ysnVoid],
			[ysnPrinted],
			[ysnDeleted],
			[dtmDateDeleted]
		)
		VALUES
		(
			p.[intAccountId],
			p.[intBankAccountId],
			p.[intPaymentMethodId],
			p.[intCurrencyId],
			p.[strPaymentInfo],
			p.[strNotes],
			p.[dtmDatePaid],
			p.[dblAmountPaid],
			p.[dblUnapplied],
			p.[ysnPosted],
			p.[strPaymentRecordNum],
			p.[dblWithheld],
			p.[intUserId],
			p.[intConcurrencyId],
			p.[intEntityId],
			p.[intEntityVendorId],
			p.[ysnOrigin],
			p.[ysnVoid],
			p.[ysnPrinted],
			p.[ysnDeleted],
			p.[dtmDateDeleted]
		)
		OUTPUT p.intPaymentId, inserted.intPaymentId INTO #tmpPayables(intPaymentId, intNewPaymentId); --get the new and old payment id

	--update the new payment
	UPDATE A
		SET A.dtmDatePaid = @voidDate
		,A.strNotes = CASE WHEN ISNULL(A.strNotes,'') = '' THEN  @description + A.strPaymentRecordNum ELSE ' ' + @description + A.strPaymentRecordNum END
		,A.strPaymentRecordNum = OldPayments.strPaymentRecordNum + 'V'
		,A.strPaymentInfo = 'Voided-' + A.strPaymentInfo
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
		WHERE intNewPaymentId IS NULL AND C.intPaymentId = B.intPaymentId
	) OldPayments
	WHERE B.intNewPaymentId IS NOT NULL

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
		INNER JOIN #tmpPayables B ON A.intPaymentId = B.intPaymentId AND B.intNewPaymentId IS NULL

	-- Calling the stored procedure
	EXEC dbo.uspCMBankTransactionReversal @intUserId, @voidDate, @isSuccessful OUTPUT

	IF @isSuccessful = 0
	BEGIN
		RAISERROR('There was an error on reversing bank transaction.', 16, 1);
		ROLLBACK TRANSACTION
		RETURN
	END

	--Create CSV of new payments
	SELECT @createdPayments = COALESCE(@createdPayments + ',', '') +  CONVERT(VARCHAR(12),intNewPaymentId)
	FROM #tmpPayables WHERE intNewPaymentId IS NOT NULL
	ORDER BY intNewPaymentId
	INSERT INTO @GLEntries
	SELECT * FROM [fnAPCreatePaymentGLEntries](@createdPayments, @intUserId, @batchId)
	--SELECT * FROM dbo.[fnAPReverseGLEntries](@paymentIds, 'Payable', @voidDate, @intUserId, @batchId)

	--Reversed gl entries of void check should be posted
	UPDATE A
		SET A.ysnIsUnposted = 0,
		A.dtmDate = @voidDate
	FROM @GLEntries A

	EXEC uspGLBookEntries @GLEntries, 1

	--UPDATE Original Payments
	UPDATE A
		SET A.strNotes = 'Transaction Voided on ' + A.strPaymentRecordNum + 'V'
		,A.strPaymentInfo = C.strReferenceNo
	FROM tblAPPayment A
		INNER JOIN #tmpPayables B
		ON A.intPaymentId = B.intPaymentId
		INNER JOIN tblCMBankTransaction C
		ON A.strPaymentRecordNum = C.strTransactionId
	WHERE B.intNewPaymentId IS NULL

	--Unposting Process
	UPDATE tblAPPaymentDetail
	SET tblAPPaymentDetail.dblAmountDue = (CASE WHEN B.dblAmountDue = 0 THEN B.dblDiscount + B.dblPayment - B.dblInterest ELSE (B.dblAmountDue + B.dblPayment) END)
	FROM tblAPPayment A
		LEFT JOIN tblAPPaymentDetail B
			ON A.intPaymentId = B.intPaymentId
		LEFT JOIN tblAPBill C
			ON B.intBillId = C.intBillId
	WHERE A.intPaymentId IN (SELECT intPaymentId FROM #tmpPayables)

	--Update dblAmountDue, dtmDatePaid and ysnPaid on tblAPBill
	UPDATE tblAPBill
		SET tblAPBill.dblAmountDue = B.dblAmountDue,
			tblAPBill.ysnPaid = 0,
			tblAPBill.dtmDatePaid = NULL,
			tblAPBill.dblWithheld = 0
	FROM tblAPPayment A
				INNER JOIN tblAPPaymentDetail B 
						ON A.intPaymentId = B.intPaymentId
				INNER JOIN tblAPBill C
						ON B.intBillId = C.intBillId
				WHERE A.intPaymentId IN (SELECT intPaymentId FROM #tmpPayables)

	IF @@ERROR != 0
	BEGIN
		ROLLBACK TRANSACTION
	END

	COMMIT TRANSACTION

END