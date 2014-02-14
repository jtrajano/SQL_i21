CREATE PROCEDURE [dbo].[uspCreateBankTransactionPayment]
	@batchId INT = 0,
	@userId NVARCHAR(50) = NULL,
	@paymentId INT
AS
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
		[intCreatedUserId],
		[dtmCreated],
		[intLastModifiedUserId],
		[dtmLastModified],
		[intConcurrencyId]
	)
	SELECT
		[strTransactionID] = A.strPaymentRecordNum,
		[intBankTransactionTypeID] = (SELECT TOP 1 intBankTransactionTypeId FROM tblCMBankTransactionType WHERE strBankTransactionTypeName = 'AP Payment'),
		[intBankAccountID] = A.intBankAccountId,
		[intCurrencyID] = A.intCurrencyId,
		[dblExchangeRate] = 0,
		[dtmDate] = A.dtmDatePaid,
		[strPayee] = (SELECT TOP 1 strName FROM tblEntities WHERE intEntityId = B.intEntityId),
		[intPayeeID] = B.intEntityId,
		[strAddress] = '',
		[strZipCode] = '',
		[strCity] = '',
		[strState] = '',
		[strCountry] = '',
		[dblAmount] = A.dblAmountPaid,
		[strAmountInWords] = dbo.fnCMConvertNumberToWord(A.dblAmountPaid),
		[strMemo] = NULL,
		[strReferenceNo] = NULL,
		[ysnCheckToBePrinted] = 0,
		[ysnCheckVoid] = 0,
		[ysnPosted] = 1,
		[strLink] = @batchId,
		[ysnClr] = 0,
		[dtmDateReconciled] = NULL,
		[intCreatedUserID] = @userId,
		[dtmCreated] = GETDATE(),
		[intLastModifiedUserID] = NULL,
		[dtmLastModified] = GETDATE(),
		[intConcurrencyId] = 1
		FROM tblAPPayment A
			INNER JOIN tblAPVendor B
				ON A.strVendorId = B.strVendorId
END