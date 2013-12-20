
--=====================================================================================================================================
-- 	CREATE THE STORED PROCEDURE AFTER DELETING IT
---------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE GetBankBalance
	@intBankAccountID INT = NULL,
	@dtmDate AS DATETIME = NULL
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
	
DECLARE @returnBalance AS NUMERIC(18,6)		

-- Get bank amounts from Misc Check and Bank Transfer (WD)
SELECT	@returnBalance = SUM(ISNULL(dblAmount, 0) * -1)
FROM	tblCMBankTransaction
WHERE	ysnPosted = 1
		AND dblAmount <> 0 
		AND intBankAccountID = @intBankAccountID
		AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmDate,dtmDate) AS FLOAT)) AS DATETIME)		
		AND intBankTransactionTypeID IN (@MISC_CHECKS, @BANK_TRANSFER_WD)

-- Get bank amounts from Bank Transactions 		
SELECT	@returnBalance = ISNULL(@returnBalance, 0) + ISNULL(SUM(ISNULL(B.dblCredit, 0)), 0) - ISNULL(SUM(ISNULL(B.dblDebit, 0)), 0)
FROM	tblCMBankTransaction A INNER JOIN tblCMBankTransactionDetail B
			ON A.strTransactionID = B.strTransactionID
WHERE	A.ysnPosted = 1
		AND A.intBankAccountID = @intBankAccountID
		AND CAST(FLOOR(CAST(A.dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmDate, A.dtmDate) AS FLOAT)) AS DATETIME)		
		AND A.intBankTransactionTypeID IN (@BANK_TRANSACTION, @BANK_WITHDRAWAL)
HAVING	ISNULL(SUM(ISNULL(B.dblCredit, 0)), 0) - ISNULL(SUM(ISNULL(B.dblDebit, 0)), 0) <> 0

-- Get bank amounts for the rest of the transactions like deposits, transferd (dep), and etc.
SELECT	@returnBalance = ISNULL(@returnBalance, 0) + ISNULL(SUM(ISNULL(dblAmount, 0)), 0)
FROM	tblCMBankTransaction
WHERE	ysnPosted = 1
		AND dblAmount <> 0 
		AND intBankAccountID = @intBankAccountID
		AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmDate,dtmDate) AS FLOAT)) AS DATETIME)		
		AND intBankTransactionTypeID NOT IN (@MISC_CHECKS, @BANK_TRANSFER_WD, @BANK_TRANSACTION, @BANK_WITHDRAWAL)		

SELECT	intBankAccountID = @intBankAccountID,
		dblBalance = ISNULL(@returnBalance, 0)

