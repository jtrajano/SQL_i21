
CREATE PROCEDURE [dbo].[uspCMGetClearedPayments]
	@intBankAccountId INT = NULL,
	@dtmStatementDate AS DATETIME = NULL,
	@ysnCheckVoid BIT = 0

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
		,@BANK_INTEREST INT = 51
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
		,@NSF AS INT = 124
		,@LastReconDate AS DATETIME;

SELECT TOP 1 @LastReconDate = MAX(dtmDateReconciled) FROM tblCMBankReconciliation WHERE intBankAccountId = @intBankAccountId
		
SELECT	totalCount = ISNULL(COUNT(1), 0)
		,totalAmount = ISNULL(SUM(ABS(ISNULL(dblAmount, 0))), 0)
FROM	tblCMBankTransaction 
WHERE	ysnPosted = 1
		AND ysnClr = 1
		AND @ysnCheckVoid = (CASE WHEN ysnCheckVoid = 1 and @dtmStatementDate >= dtmDateReconciled THEN 1 ELSE 0 END )
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
			intBankTransactionTypeId IN (@BANK_WITHDRAWAL,@NSF,@BANK_INTEREST,@MISC_CHECKS, @BANK_TRANSFER_WD, @ORIGIN_CHECKS, @ORIGIN_EFT, @ORIGIN_WITHDRAWAL, @ORIGIN_WIRE, @AP_PAYMENT, @AP_ECHECK, @PAYCHECK, @ACH, @DIRECT_DEPOSIT)
			OR ( dblAmount < 0 AND intBankTransactionTypeId in ( @BANK_TRANSACTION, @BANK_INTEREST ))
		)
		AND 1 = CASE 
			WHEN CAST(FLOOR(CAST(@LastReconDate AS FLOAT)) AS DATETIME)  >= CAST(FLOOR(CAST(@dtmStatementDate AS FLOAT)) AS DATETIME) AND dtmDateReconciled IS NULL THEN 0 
			ELSE 1 
			END --CM-1143