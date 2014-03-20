
CREATE PROCEDURE uspCMReconcileBankRecords
	@intBankAccountId INT = NULL,
	@dtmDate AS DATETIME = NULL,
	@intUserId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRANSACTION 

-- Declare the transaction types (constant)
DECLARE @BANK_DEPOSIT AS INT = 1
		,@BANK_WITHDRAWAL AS INT = 2
		,@MISCELLANEOUS_CHECKS AS INT = 3
		,@BANK_TRANSFER AS INT = 4
		,@BANK_TRANSACTION AS INT = 5
		,@CREDIT_CARD_CHARGE AS INT = 6
		,@CREDIT_CARD_RETURNS AS INT = 7
		,@CREDIT_CARD_PAYMENTS AS INT = 8
		,@BANK_TRANSFER_WD AS INT = 9
		,@BANK_TRANSFER_DEP AS INT = 10
		,@ORIGIN_DEPOSIT AS INT = 11		-- NEGATIVE AMOUNT, INDICATOR: O, APCHK_CHK_NO PREFIX: NONE
		,@ORIGIN_CHECKS AS INT = 12			-- POSITIVE AMOUNT, INDICATOR: C, APCHK_CHK_NO PREFIX: N/A, IT MUST BE A VALId NUMBER
		,@ORIGIN_EFT AS INT = 13			-- POSITIVE AMOUNT, INDICATOR: N/A, APCHK_CHK_NO PREFIX: ''E''		
		,@ORIGIN_WITHDRAWAL AS INT = 14		-- POSITIVE AMOUNT, INDICATOR: N/A, APCHK_CHK_NO PREFIX: NONE
		,@ORIGIN_WIRE AS INT = 15			-- POSITIVE AMOUNT, INDICATOR: N/A, APCHK_CHK_NO PREFIX: ''W''
		,@AP_PAYMENT AS INT = 16

		-- Declare the local variables. 
		,@dtmLog AS DATETIME 
		
SET @dtmLog = GETDATE()

-- Log the status of the transactions to clear prior to the reconciliation. 
INSERT INTO [dbo].[tblCMBankReconciliationAudit]
(
		[intBankAccountId]
		,[intTransactionId]
		,[strTransactionId]
		,[ysnClr]
		,[dblAmount]
		,[intUserId]
		,[dtmDateReconciled]
		,[dtmLog]
		,[intConcurrencyId]
)
SELECT 
		[intBankAccountId] = f.intBankAccountId
		,[intTransactionId] = f.intTransactionId
		,[strTransactionId] = f.strTransactionId
		,[ysnClr] = f.ysnClr
		,[dblAmount] = f.dblAmount
		,[intUserId] = @intUserId
		,[dtmDateReconciled] = @dtmDate
		,[dtmLog] = @dtmLog
		,[intConcurrencyId] = 1
FROM	[dbo].[tblCMBankTransaction] f
WHERE	intBankAccountId = @intBankAccountId
		AND ysnPosted = 1
		AND ysnClr = 1
		AND dtmDateReconciled IS NULL 
		AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmDate, dtmDate) AS FLOAT)) AS DATETIME)		
IF @@ERROR <> 0	GOTO uspCMReconcileBankRecords_Rollback		

-- Mark all origin transactions as cleared.
UPDATE	[dbo].[apchkmst_origin]
SET		apchk_cleared_ind = 'C'
		,apchk_clear_rev_dt = CONVERT(VARCHAR(10), dtmDate, 112)
FROM	dbo.tblCMBankTransaction f INNER JOIN [dbo].[apchkmst_origin] origin
			ON f.strLink = ( CAST(origin.apchk_cbk_no AS NVARCHAR(2)) 
							+ CAST(origin.apchk_rev_dt AS NVARCHAR(10))
							+ CAST(origin.apchk_trx_ind AS NVARCHAR(1))
							+ CAST(origin.apchk_chk_no AS NVARCHAR(8))
			) COLLATE Latin1_General_CI_AS 
			AND f.intBankTransactionTypeId IN (@ORIGIN_DEPOSIT, @ORIGIN_CHECKS, @ORIGIN_EFT, @ORIGIN_WITHDRAWAL, @ORIGIN_WIRE)
WHERE	intBankAccountId = @intBankAccountId
		AND ysnPosted = 1
		AND ysnClr = 1
		AND dtmDateReconciled IS NULL 
		AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmDate, dtmDate) AS FLOAT)) AS DATETIME)
		AND origin.apchk_cleared_ind IS NULL 
		
IF @@ERROR <> 0	GOTO uspCMReconcileBankRecords_Rollback

-- Mark all CM transactions as cleared.
UPDATE	[dbo].[tblCMBankTransaction]
SET		dtmDateReconciled = @dtmDate
WHERE	intBankAccountId = @intBankAccountId
		AND ysnPosted = 1
		AND ysnClr = 1
		AND dtmDateReconciled IS NULL 
		AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmDate, dtmDate) AS FLOAT)) AS DATETIME)
IF @@ERROR <> 0	GOTO uspCMReconcileBankRecords_Rollback
		
--=====================================================================================================================================
-- 	EXIT ROUTINES
---------------------------------------------------------------------------------------------------------------------------------------
uspCMReconcileBankRecords_Commit:
	COMMIT TRANSACTION
	GOTO uspCMReconcileBankRecords_Exit
	
uspCMReconcileBankRecords_Rollback:
	ROLLBACK TRANSACTION 
	
uspCMReconcileBankRecords_Exit:

