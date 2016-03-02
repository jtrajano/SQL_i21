CREATE PROCEDURE [dbo].[uspAPUpdatePaymentBankTransaction]
	@paymentIds AS Id READONLY,
	@post BIT,
	@userId INT,
	@batchId NVARCHAR(50)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

IF @post = 0
BEGIN
	-- Creating the temp table:
	DECLARE @isSuccessful BIT
	CREATE TABLE #tmpCMBankTransaction (
    --[intTransactionId] INT PRIMARY KEY,
    [strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL,
    UNIQUE (strTransactionId))

	INSERT INTO #tmpCMBankTransaction
	SELECT 
		strPaymentRecordNum 
	FROM tblAPPayment A
	INNER JOIN @paymentIds B ON A.intPaymentId = B.intId

	-- Calling the stored procedure
	EXEC dbo.uspCMBankTransactionReversal @userId, DEFAULT, @isSuccessful OUTPUT

	IF @isSuccessful = 0
	BEGIN
		RAISERROR('Failed to reverse bank transaction.', 16, 1);
	END
END
ELSE IF @post = 1
BEGIN
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
		[intBankTransactionTypeID] = CASE WHEN LOWER((SELECT strPaymentMethod FROM tblSMPaymentMethod WHERE intPaymentMethodID = A.intPaymentMethodId)) = 'echeck' THEN 20 
										WHEN LOWER((SELECT strPaymentMethod FROM tblSMPaymentMethod WHERE intPaymentMethodID = A.intPaymentMethodId)) = 'ach' THEN 22 
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
		[dblAmount] = A.dblAmountPaid + A.dblWithheld,
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
	WHERE A.intPaymentId IN (SELECT intId FROM @paymentIds)
END
