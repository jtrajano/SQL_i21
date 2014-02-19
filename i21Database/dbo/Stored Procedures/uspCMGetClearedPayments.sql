
CREATE PROCEDURE uspCMGetClearedPayments
	@intBankAccountId INT = NULL,
	@dtmStatementDate AS DATETIME = NULL
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
		
SELECT	totalCount = ISNULL(COUNT(1), 0)
		,totalAmount = ISNULL(SUM(ABS(ISNULL(dblAmount, 0))), 0)
FROM	tblCMBankTransaction 
WHERE	ysnPosted = 1
		AND ysnClr = 1
		AND intBankAccountId = @intBankAccountId
		AND dblAmount <> 0		
		AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmStatementDate, dtmDate) AS FLOAT)) AS DATETIME)
		AND (
			-- Filter date reconciled. 
			-- 1. Include only bank transaction if not permanently reconciled. 
			-- 2. Or if the bank transaction is reconciled on the provided statement date. 
			dtmDateReconciled IS NULL 
			OR CAST(FLOOR(CAST(dtmDateReconciled AS FLOAT)) AS DATETIME) = CAST(FLOOR(CAST(@dtmStatementDate AS FLOAT)) AS DATETIME)
		)
		AND (
			-- Filter for all the bank payments and debits:
			intBankTransactionTypeId IN (@BANK_WITHDRAWAL, @MISC_CHECKS, @BANK_TRANSFER_WD, @ORIGIN_CHECKS, @ORIGIN_EFT, @ORIGIN_WITHDRAWAL, @ORIGIN_WIRE, @AP_PAYMENT)
			OR ( dblAmount < 0 AND intBankTransactionTypeId = @BANK_TRANSACTION )
		)