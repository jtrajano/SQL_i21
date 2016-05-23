
CREATE PROCEDURE uspCMGetClearedDeposits
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
		,@BANK_STMT_IMPORT AS INT = 17
		,@AR_PAYMENT AS INT = 18
		,@VOID_CHECK AS INT = 19
		,@AP_ECHECK AS INT = 20
		,@PAYCHECK AS INT = 21
		,@LastReconDate AS DATETIME

		SELECT TOP 1 @LastReconDate = MAX(dtmDateReconciled) FROM tblCMBankReconciliation WHERE intBankAccountId = @intBankAccountId
		
SELECT	totalCount = ISNULL(COUNT(1), 0)
		,totalAmount = ISNULL(SUM(ISNULL(dblAmount, 0)), 0)
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
			intBankTransactionTypeId IN (@BANK_DEPOSIT, @BANK_TRANSFER_DEP, @ORIGIN_DEPOSIT, @AR_PAYMENT, @VOID_CHECK)
			OR ( dblAmount > 0 AND intBankTransactionTypeId = @BANK_TRANSACTION )
		)
		--AND dbo.fnIsDepositEntry(strLink) = 0
		AND strLink NOT IN ( --This is to improved the query by not using fnIsDespositEntry
					SELECT
					( CAST(a.apchk_cbk_no AS NVARCHAR(2)) 
									+ CAST(a.apchk_rev_dt AS NVARCHAR(10)) 
									+ CAST(a.apchk_trx_ind AS NVARCHAR(1)) 
									+ CAST(a.apchk_chk_no AS NVARCHAR(8))
						) COLLATE Latin1_General_CI_AS
					FROM	dbo.apchkmst a INNER JOIN dbo.aptrxmst b
								ON a.apchk_cbk_no = b.aptrx_cbk_no
								AND a.apchk_chk_no = b.aptrx_chk_no
								AND a.apchk_trx_ind = b.aptrx_trans_type			
								AND a.apchk_rev_dt = b.aptrx_chk_rev_dt
								AND a.apchk_vnd_no = b.aptrx_vnd_no
					WHERE	 b.aptrx_trans_type = 'O' -- Other CW transactions
			)
		AND 1 = CASE 
			WHEN CAST(FLOOR(CAST(@LastReconDate AS FLOAT)) AS DATETIME)  >= CAST(FLOOR(CAST(@dtmStatementDate AS FLOAT)) AS DATETIME) AND dtmDateReconciled IS NULL THEN 0 
			ELSE 1 
			END --CM-1143