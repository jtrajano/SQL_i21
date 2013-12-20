
--=====================================================================================================================================
-- 	CREATE THE STORED PROCEDURE AFTER DELETING IT
---------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE ApplyCheckChangeBankReconciliation
	@intBankAccountID INT = NULL,
	@ysnClr BIT = NULL,
	@strSide AS NVARCHAR(10) = 'DEBIT', 
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

-- Bulk update the ysnClr
UPDATE	tblCMBankTransaction 
SET		ysnClr = @ysnClr
		,intConcurrencyID = intConcurrencyID + 1
WHERE	ysnPosted = 1
		AND dtmDateReconciled IS NULL
		AND intBankAccountID = @intBankAccountID
		AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmStatementDate AS FLOAT)) AS DATETIME)
		AND 1 = 
			CASE	WHEN	@strSide = 'DEBIT' 
							AND (
								intBankTransactionTypeID = @BANK_WITHDRAWAL
								OR intBankTransactionTypeID = @MISC_CHECKS
								OR intBankTransactionTypeID = @BANK_TRANSFER_WD
								OR ( dblAmount < 0 AND intBankTransactionTypeID = @BANK_TRANSACTION )
							) THEN 1 					
					WHEN	@strSide = 'CREDIT' 
							AND (
								intBankTransactionTypeID = @BANK_DEPOSIT
								OR intBankTransactionTypeID = @BANK_TRANSFER_DEP
								OR ( dblAmount > 0 AND intBankTransactionTypeID = @BANK_TRANSACTION )
							)
					THEN 1
					ELSE
					0
			END	

