
CREATE PROCEDURE ApplyCheckChangeBankReconciliation
	@intBankAccountId INT = NULL,
	@ysnClr BIT = NULL,
	@strSide AS NVARCHAR(10) = 'DEBIT', 
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

-- Bulk update the ysnClr
UPDATE	tblCMBankTransaction 
SET		ysnClr = @ysnClr
		,intConcurrencyId = intConcurrencyId + 1
WHERE	ysnPosted = 1
		AND dtmDateReconciled IS NULL
		AND intBankAccountId = @intBankAccountId
		AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmStatementDate AS FLOAT)) AS DATETIME)
		AND 1 = 
			CASE	WHEN	@strSide = 'DEBIT' 
							AND (
								intBankTransactionTypeId IN (@BANK_WITHDRAWAL, @MISC_CHECKS, @BANK_TRANSFER_WD, @ORIGIN_CHECKS, @ORIGIN_EFT, @ORIGIN_WITHDRAWAL, @ORIGIN_WIRE)
								OR ( dblAmount < 0 AND intBankTransactionTypeId = @BANK_TRANSACTION )
							) THEN 1 					
					WHEN	@strSide = 'CREDIT' 
							AND (
								intBankTransactionTypeId IN (@BANK_DEPOSIT, @BANK_TRANSFER_DEP, @ORIGIN_DEPOSIT)
								OR ( dblAmount > 0 AND intBankTransactionTypeId = @BANK_TRANSACTION )
							)
					THEN 1
					ELSE
					0
			END	

