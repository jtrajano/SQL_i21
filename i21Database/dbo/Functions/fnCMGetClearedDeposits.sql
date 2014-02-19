CREATE FUNCTION [dbo].[fnCMGetClearedDeposits]
(
	@intBankAccountId INT = NULL,
	@dtmStatementDate AS DATETIME = NULL
)
RETURNS NUMERIC(18,6)
AS
BEGIN 

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

		,@returnBalance AS NUMERIC(18,6)
		
SELECT	@returnBalance = SUM(ISNULL(dblAmount, 0))
FROM	[dbo].[tblCMBankTransaction]
WHERE	ysnPosted = 1
		AND ysnClr = 1
		AND intBankAccountId = @intBankAccountId
		AND dblAmount <> 0
		AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmStatementDate, dtmDate) AS FLOAT)) AS DATETIME)
		AND (
			-- Filter date reconciled. 
			-- 1. Include only bank transaction is not permanently reconciled. 
			-- 2. Or if the bank transaction is reconciled on the provided statement date. 
			dtmDateReconciled IS NULL 
			OR CAST(FLOOR(CAST(dtmDateReconciled AS FLOAT)) AS DATETIME) = CAST(FLOOR(CAST(ISNULL(@dtmStatementDate, dtmDate) AS FLOAT)) AS DATETIME)
		)
		AND (
			-- Filter for all the bank deposits and credits:
			intBankTransactionTypeId IN (@BANK_DEPOSIT, @BANK_TRANSFER_DEP, @ORIGIN_DEPOSIT)
			OR ( dblAmount > 0 AND intBankTransactionTypeId = @BANK_TRANSACTION )
		)

RETURN ISNULL(@returnBalance, 0)

END 