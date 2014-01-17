CREATE PROCEDURE [dbo].[uspCreateBankTransactionPayment]
	@batchId INT = 0,
	@userId NVARCHAR(50) = '',
	@paymentId INT
AS
BEGIN

	
	INSERT INTO tblCMBankTransaction(
		[strTransactionID],
		[intBankTransactionTypeID],
		[intBankAccountID],
		[intCurrencyID],
		[dblExchangeRate],
		[dtmDate],
		[strPayee],
		[intPayeeID],
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
		[intCreatedUserID],
		[dtmCreated],
		[intLastModifiedUserID],
		[dtmLastModified],
		[intConcurrencyID]
	)
	SELECT
		[strTransactionID] = A.strPaymentRecordNum,
		[intBankTransactionTypeID] = (SELECT TOP 1 intBankTransactionTypeID FROM tblCMBankTransactionType WHERE strBankTransactionTypeName = 'AP Payment'),
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
		[strAmountInWords] = fn_ConvertNUmberToWords(A.dblAmountPaid),
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
		[intConcurrencyID] = 1
		FROM tblAPPayment A
			INNER JOIN tblAPVendor B
				ON A.strVendorId = B.strVendorId
END
