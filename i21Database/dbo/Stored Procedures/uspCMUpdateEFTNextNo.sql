--This SP will set the strReference No to each transaction.
--This will also update corresponding transaction's reference no / payment info.
--Also in this SP will set the next eft no on Bank Account

CREATE PROCEDURE [dbo].[uspCMUpdateEFTNextNo]
	@intBankAccountId INT = NULL,
	@strTransactionIds NVARCHAR(MAX) = NULL,
	@strProcessType NVARCHAR(100) = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @intEFTNextNo AS INT,
		@intTransactionId AS INT,
		@strTransactionId AS NVARCHAR(50),
		@intBankTransactionTypeId AS INT

select @intEFTNextNo = intEFTNextNo from tblCMBankAccount where intBankAccountId = @intBankAccountId

IF @strProcessType = 'ACH From Customer'
BEGIN
	SELECT * INTO #tmpACHFromCustomer 
	FROM tblCMUndepositedFund 
	WHERE intUndepositedFundId IN (SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@strTransactionIds))
		AND (strReferenceNo = '' OR strReferenceNo IS NULL)

	WHILE EXISTS (SELECT 1 FROM #tmpACHFromCustomer) 
	BEGIN

		SELECT TOP 1 
		 @intTransactionId = intUndepositedFundId
		,@strTransactionId = strSourceTransactionId
		FROM #tmpACHFromCustomer ORDER BY intUndepositedFundId ASC
	
		UPDATE tblCMUndepositedFund SET strReferenceNo = @intEFTNextNo WHERE intUndepositedFundId = @intTransactionId AND (strReferenceNo = '' OR strReferenceNo IS NULL)
		
		--Update the reference no of other module's transaction (AR Transaction)
		UPDATE tblARPayment SET intCurrentStatus = 5 WHERE strRecordNumber = @strTransactionId
		UPDATE tblARPayment SET strPaymentInfo = @intEFTNextNo WHERE strRecordNumber = @strTransactionId
		UPDATE tblARPayment SET intCurrentStatus = NULL WHERE strRecordNumber = @strTransactionId
		
		SET @intEFTNextNo =  @intEFTNextNo + 1
		DELETE FROM #tmpACHFromCustomer WHERE intUndepositedFundId = @intTransactionId
	END

END
ELSE
BEGIN
	SELECT * INTO #tmpCMBankTransactions 
	FROM tblCMBankTransaction 
	WHERE intTransactionId IN (SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@strTransactionIds))
		AND (strReferenceNo = '' OR strReferenceNo IS NULL)

	WHILE EXISTS (SELECT 1 FROM #tmpCMBankTransactions) 
	BEGIN

		SELECT TOP 1 
		 @intTransactionId = intTransactionId 
		,@strTransactionId = strTransactionId
		,@intBankTransactionTypeId = intBankTransactionTypeId
		FROM #tmpCMBankTransactions ORDER BY intTransactionId ASC
	
		UPDATE tblCMBankTransaction SET strReferenceNo = @intEFTNextNo WHERE intTransactionId = @intTransactionId AND strReferenceNo = ''
		
		--Update the reference no of other module's transaction
		IF @intBankTransactionTypeId = 22 OR @intBankTransactionTypeId = 122
		BEGIN
			UPDATE tblAPPayment SET strPaymentInfo = @intEFTNextNo WHERE strPaymentRecordNum = @strTransactionId
		END
		IF @intBankTransactionTypeId = 23 OR @intBankTransactionTypeId = 123
		BEGIN
			UPDATE tblPRPaycheck SET strReferenceNo = @intEFTNextNo, ysnPrinted = 1 WHERE strPaycheckId = @strTransactionId
		END

		SET @intEFTNextNo =  @intEFTNextNo + 1

		DELETE FROM #tmpCMBankTransactions WHERE intTransactionId = @intTransactionId
	END

END

--Update the Bank Account's Next EFT No.
UPDATE tblCMBankAccount SET intEFTNextNo = @intEFTNextNo WHERE intBankAccountId = @intBankAccountId