
--=====================================================================================================================================
-- 	CREATE THE STORED PROCEDURE AFTER DELETING IT
---------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE GetUnclearedBankDebits
	@intBankAccountID INT = NULL,
	@dtmStatementDate AS DATETIME = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @BANK_DEPOSIT INT = 1,
		@BANK_WITHDRAWAL INT = 2,
		@MISC_CHECKS INT = 3,
		@BANK_TRANSFER INT = 4,
		@BANK_TRANSACTION INT = 5,
		@CREDIT_CARD_CHARGE INT = 6,
		@CREDIT_CARD_RETURNS INT = 7,
		@CREDIT_CARD_PAYMENTS INT = 8,
		@BANK_TRANSFER_WD INT = 9,
		@BANK_TRANSFER_DEP INT = 10
		
SELECT	ISNULL(SUM(ABS(ISNULL(dblAmount, 0))), 0)
FROM	tblCMBankTransaction 
WHERE	ysnPosted = 1
		AND ysnClr = 0
		AND intBankAccountID = @intBankAccountID
		AND dblAmount <> 0		
		AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmStatementDate, dtmDate) AS FLOAT)) AS DATETIME)
		AND dtmDateReconciled IS NULL
		AND (
			-- Filter for all the bank payments and debits:
			intBankTransactionTypeID = @BANK_WITHDRAWAL
			OR intBankTransactionTypeID = @MISC_CHECKS
			OR intBankTransactionTypeID = @BANK_TRANSFER_WD
			OR ( dblAmount < 0 AND intBankTransactionTypeID = @BANK_TRANSACTION )
		)
