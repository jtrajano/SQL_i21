
CREATE PROCEDURE uspCMApplyCheckChangeForCheckPrint
	@intBankAccountId INT = NULL,
	@strTransactionId NVARCHAR(40) = NULL,
	@strBatchId NVARCHAR(20) = NULL,
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

-- Mass update the ysnCheckToBePrinted
UPDATE	[dbo].[tblCMBankTransaction]
SET		ysnCheckToBePrinted = @ysnCheckToBePrinted
		,intConcurrencyId = intConcurrencyId + 1
WHERE	intBankAccountId = @intBankAccountId
		AND intBankTransactionTypeId IN (@MISC_CHECKS, @AP_PAYMENT)
		AND strTransactionId = ISNULL(@strTransactionId, strTransactionId)
		AND strLink = ISNULL(@strBatchId, strLink)
		AND ysnPosted = 1
		AND ysnClr = 0
		AND dblAmount <> 0