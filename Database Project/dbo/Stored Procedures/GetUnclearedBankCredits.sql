
--=====================================================================================================================================
-- 	CREATE THE STORED PROCEDURE AFTER DELETING IT
---------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE GetUnclearedBankCredits
	@intBankAccountID INT = NULL,
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
		
SELECT	ISNULL(SUM(ISNULL(dblAmount,0)), 0)
FROM	tblCMBankTransaction 
WHERE	ysnPosted = 1
		AND intBankAccountID = @intBankAccountID
		AND dblAmount <> 0
		AND	1 =	CASE	
					WHEN ysnClr = 0 THEN 
						CASE WHEN CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmStatementDate, dtmDate) AS FLOAT)) AS DATETIME) THEN 1 ELSE 0 END
					WHEN ysnClr = 1 THEN 
						CASE	WHEN	CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmStatementDate, dtmDate) AS FLOAT)) AS DATETIME) 
										AND CAST(FLOOR(CAST(ISNULL(dtmDateReconciled, dtmDate) AS FLOAT)) AS DATETIME) > CAST(FLOOR(CAST(ISNULL(@dtmStatementDate, dtmDate) AS FLOAT)) AS DATETIME) 
								THEN 1 ELSE 0 
						END
				END
		AND (
			-- Filter for all the bank deposits and credits:
			intBankTransactionTypeID IN (@BANK_DEPOSIT, @BANK_TRANSFER_DEP, @ORIGIN_DEPOSIT)
			OR ( dblAmount > 0 AND intBankTransactionTypeID = @BANK_TRANSACTION )
		)		
