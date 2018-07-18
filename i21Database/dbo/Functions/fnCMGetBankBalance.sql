CREATE FUNCTION [dbo].[fnCMGetBankBalance]
(
	@intBankAccountId INT = NULL,
	@dtmDate AS DATETIME = NULL,
	@isForeignCurrency AS BIT = 0
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
		,@BANK_STMT_IMPORT AS INT = 17
		,@AR_PAYMENT AS INT = 18
		,@VOID_CHECK AS INT = 19
		,@AP_ECHECK AS INT = 20
		,@PAYCHECK AS INT = 21
		,@ACH AS INT = 22
		,@DIRECT_DEPOSIT AS INT = 23
		,@VOID_MISC_CHECKS INT = 103
		,@VOID_AP_PAYMENT AS INT = 116
		,@VOID_PAYCHECK AS INT = 121
		,@VOID_ACH AS INT = 122
		,@VOID_DIRECT_DEPOSIT AS INT = 123
		
DECLARE @openingBalance AS NUMERIC(18,6)		
DECLARE @returnBalance AS NUMERIC(18,6)	




-- Get the opening balance from the first bank reconciliation record. 
SELECT TOP 1 
		@openingBalance = dblStatementOpeningBalance
FROM	tblCMBankReconciliation
WHERE 	intBankAccountId = @intBankAccountId

-- Get bank amounts from Misc Check, Bank Transfer (WD), Origin Checks, Origin Withdrawal, Origin EFT, and Origin Wire
SELECT	@returnBalance = SUM(ISNULL(CASE WHEN @isForeignCurrency=0 THEN dblAmount ELSE dblAmountForeign END , 0) * -1)
FROM	[dbo].[tblCMBankTransaction]
WHERE	ysnPosted = 1
		AND ysnCheckVoid = 0
		AND dblAmount <> 0 
		AND intBankAccountId = @intBankAccountId
		AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmDate,dtmDate) AS FLOAT)) AS DATETIME)		
		AND intBankTransactionTypeId IN (@MISC_CHECKS, @BANK_TRANSFER_WD, @ORIGIN_CHECKS, @ORIGIN_EFT, @ORIGIN_WITHDRAWAL, @ORIGIN_WIRE, @AP_PAYMENT, @AP_ECHECK, @PAYCHECK, @DIRECT_DEPOSIT, @ACH )

--Include voided check that not yet effect in the bank balance for the voiding date is greater than the statement date
SELECT	 @returnBalance = ISNULL(@returnBalance,0) + ISNULL(SUM(ISNULL(CASE WHEN @isForeignCurrency=0 THEN dblAmount ELSE dblAmountForeign END, 0) * -1),0)
FROM	[dbo].[tblCMBankTransaction] A
WHERE	ysnPosted = 1
		AND ysnCheckVoid = 1 
		AND
		(1 = CASE 
			WHEN  (SELECT CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) FROM tblCMBankTransaction where strTransactionId = A.strTransactionId + 'V') >  CAST(FLOOR(CAST(ISNULL(@dtmDate,A.dtmDate) AS FLOAT)) AS DATETIME)	
				THEN 1
				ELSE 0
			END
		)
		AND dblAmount <> 0 
		AND intBankAccountId = @intBankAccountId
		AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmDate,dtmDate) AS FLOAT)) AS DATETIME)		
		--AND intBankTransactionTypeId IN (@VOID_CHECK, @VOID_MISC_CHECKS, @VOID_AP_PAYMENT, @VOID_PAYCHECK, @VOID_ACH, @VOID_DIRECT_DEPOSIT)--CM-2066

-- Get bank amounts from Bank Transactions 	
-- Note: The computations are based on the detail table (tblCMBankTransactionDetail). 
SELECT	@returnBalance = ISNULL(@returnBalance, 0) + ISNULL(SUM(ISNULL(CASE WHEN @isForeignCurrency = 0 THEN  B.dblCredit ELSE B.dblCreditForeign END, 0)), 0) - ISNULL(SUM(ISNULL(CASE WHEN @isForeignCurrency = 0 THEN B.dblDebit ELSE dblDebitForeign END, 0)), 0)
FROM	[dbo].[tblCMBankTransaction] A INNER JOIN [dbo].[tblCMBankTransactionDetail] B
			ON A.intTransactionId = B.intTransactionId
WHERE	A.ysnPosted = 1
		AND A.ysnCheckVoid = 0
		AND A.intBankAccountId = @intBankAccountId
		AND CAST(FLOOR(CAST(A.dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmDate, A.dtmDate) AS FLOAT)) AS DATETIME)		
		AND A.intBankTransactionTypeId IN (@BANK_TRANSACTION, @BANK_WITHDRAWAL)
HAVING	ISNULL(SUM(ISNULL(B.dblCredit, 0)), 0) - ISNULL(SUM(ISNULL(B.dblDebit, 0)), 0) <> 0

-- Get bank amounts for the rest of the transactions like deposits, transfer (dep), and etc.
SELECT	@returnBalance = ISNULL(@returnBalance, 0) + ISNULL(SUM(ISNULL(CASE WHEN @isForeignCurrency=0 THEN dblAmount ELSE dblAmountForeign END, 0)), 0)
FROM	[dbo].[tblCMBankTransaction]
WHERE	ysnPosted = 1
		AND ysnCheckVoid = 0
		AND dblAmount <> 0 
		AND intBankAccountId = @intBankAccountId
		AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmDate,dtmDate) AS FLOAT)) AS DATETIME)		
		AND intBankTransactionTypeId NOT IN (@MISC_CHECKS, @BANK_TRANSFER_WD, @BANK_TRANSACTION, @BANK_WITHDRAWAL, @ORIGIN_CHECKS, @ORIGIN_EFT, @ORIGIN_WITHDRAWAL, @ORIGIN_WIRE, @AP_PAYMENT, @AP_ECHECK, @PAYCHECK, @DIRECT_DEPOSIT, @ACH)

-- Add the opening balance to the return balance. 
SET @returnBalance = ISNULL(@openingBalance, 0) + @returnBalance

RETURN ISNULL(@returnBalance, 0)

END