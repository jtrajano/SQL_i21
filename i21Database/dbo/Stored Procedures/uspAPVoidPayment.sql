CREATE PROCEDURE [dbo].[uspAPVoidPayment]
	@paymentIds NVARCHAR(MAX),
	@voidDate DATETIME,
	@intUserId INT
AS
BEGIN

	DECLARE @newPaymentId INT;
	DECLARE @description NVARCHAR(200) = 'Void transaction for ';
	DECLARE @GLEntries AS RecapTableType 
	DECLARE @batchId NVARCHAR(20)

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
		RAISERROR('One of the payment cannot be void.', 16, 1);
	END

	IF EXISTS(SELECT 1 FROM tblAPPayment A
				INNER JOIN tblCMBankTransaction B ON A.strPaymentRecordNum = B.strTransactionId
				WHERE intPaymentId IN (SELECT intPaymentId FROM #tmpPayables) AND A.ysnPosted = 1 AND (B.dtmCheckPrinted IS NULL OR B.ysnCheckVoid = 1))
	BEGIN
		RAISERROR('One of the payment cannot be void.', 16, 1);
	END

	IF @@ERROR != 0
	BEGIN
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
			[intVendorId],
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
			p.[intVendorId],
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
		,A.strPaymentRecordNum = A.strPaymentRecordNum + 'V'
		,A.dblAmountPaid = A.dblAmountPaid * -1
	FROM tblAPPayment A
	WHERE intPaymentId IN (SELECT intNewPaymentId FROM #tmpPayables WHERE intNewPaymentId IS NOT NULL)

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
		RETURN;
	END

	INSERT INTO @GLEntries
	SELECT * FROM dbo.[fnAPReverseGLEntries](@paymentIds, 'Payable', @voidDate, @intUserId, @batchId)

	EXEC uspGLBookEntries @GLEntries, 1

END