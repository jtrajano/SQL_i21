
CREATE PROCEDURE uspCMApplyCheckChangeForCheckPrint
	@intBankAccountId INT = NULL,
	@strTransactionIds NVARCHAR(max) = NULL,
	@strBatchId NVARCHAR(20) = NULL,
	@strProcessType NVARCHAR(100),
	@ysnCheckToBePrinted BIT = 0
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @BANK_DEPOSIT INT = 1
		,@BANK_WITHDRAWAL INT = 2
		,@MISC_CHECKS INT = 3
		,@BANK_TRANSFER INT = 4
		,@BANK_TRANSACTION INT = 5
		,@CREDIT_CARD_CHARGE INT = 6
		,@CREDIT_CARD_RETURNS INT = 7
		,@CREDIT_CARD_PAYMENTS INT = 8
		,@BANK_TRANSFER_WD INT = 9
		,@BANK_TRANSFER_DEP INT = 10
		,@ORIGIN_DEPOSIT AS INT = 11
		,@ORIGIN_CHECKS AS INT = 12
		,@ORIGIN_EFT AS INT = 13
		,@ORIGIN_WITHDRAWAL AS INT = 14
		,@ORIGIN_WIRE AS INT = 15
		,@AP_PAYMENT AS INT = 16
		,@BANK_STMT_IMPORT AS INT = 17
		,@AR_PAYMENT AS INT = 18
		,@VOID_CHECK AS INT = 19
		,@AP_ECHECK AS INT = 20
		,@PAYCHECK AS INT = 21
		,@ACH AS INT = 22
		,@DIRECT_DEPOSIT AS INT = 23

		-- Constant variables for payment methods
		,@CASH_PAYMENT AS NVARCHAR(20) = 'Cash'

-- Mass update the ysnCheckToBePrinted
IF(@strProcessType = 'ACH From Customer')
BEGIN
	UPDATE tblCMUndepositedFund
	SET ysnToProcess = @ysnCheckToBePrinted
		,intConcurrencyId = intConcurrencyId + 1
	WHERE intUndepositedFundId IN (SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@strTransactionIds))
		AND ysnCommitted is null
END
ELSE
BEGIN
	UPDATE	[dbo].[tblCMBankTransaction]
	SET		ysnCheckToBePrinted = @ysnCheckToBePrinted
			,intConcurrencyId = intConcurrencyId + 1
	WHERE	intBankAccountId = @intBankAccountId
			AND intBankTransactionTypeId IN (@MISC_CHECKS, @AP_PAYMENT, @PAYCHECK, @ACH, @DIRECT_DEPOSIT)
			AND intTransactionId IN (SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@strTransactionIds))
			AND strLink = ISNULL(@strBatchId, strLink)
			AND ysnPosted = 1
			--AND ysnClr = 0
			AND dblAmount <> 0
			AND strReferenceNo NOT IN (@CASH_PAYMENT) -- Do not include AP Payments that is paid thru a "Cash" payment method. 
END