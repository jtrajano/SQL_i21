
--=====================================================================================================================================
-- 	CREATE THE STORED PROCEDURE AFTER DELETING IT
---------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE PagedBankReconPaymentAndDebit
	@start INT
	,@limit INT
	,@intBankAccountID INT
	,@dtmDate DATETIME
	,@count INT OUTPUT 
AS
BEGIN
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
			,@ORIGIN_WIRE AS INT = 15;

	WITH PagedBankTransactions AS 
	(
		SELECT	RowNumber = ROW_NUMBER() OVER (ORDER BY cntID)
				,*				
		FROM	tblCMBankTransaction
		WHERE	ysnPosted = 1
				AND intBankAccountID = ISNULL(@intBankAccountID, intBankAccountID)
				AND dblAmount <> 0		
				AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmDate, dtmDate) AS FLOAT)) AS DATETIME)
				AND (
					-- Filter date reconciled. 
					-- 1. Include only bank transaction if not permanently reconciled. 
					-- 2. Or if the bank transaction is reconciled on the provided statement date. 
					dtmDateReconciled IS NULL 
					OR CAST(FLOOR(CAST(dtmDateReconciled AS FLOAT)) AS DATETIME) = CAST(FLOOR(CAST(ISNULL(@dtmDate, dtmDate) AS FLOAT)) AS DATETIME)
				)
				AND (
					-- Filter for all the bank payments and debits:
					intBankTransactionTypeID IN (@BANK_WITHDRAWAL, @MISC_CHECKS, @BANK_TRANSFER_WD, @ORIGIN_CHECKS, @ORIGIN_EFT, @ORIGIN_WITHDRAWAL, @ORIGIN_WIRE)
					OR ( dblAmount < 0 AND intBankTransactionTypeID = @BANK_TRANSACTION )
				)
	)

	-- Get the paged data
	SELECT	*
	FROM	PagedBankTransactions
	WHERE	RowNumber BETWEEN @start AND @limit 

	-- Get the total number of records
	SELECT	@count = COUNT(1)
	FROM	tblCMBankTransaction
	WHERE	ysnPosted = 1
			AND intBankAccountID = ISNULL(@intBankAccountID, intBankAccountID)
			AND dblAmount <> 0		
			AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmDate, dtmDate) AS FLOAT)) AS DATETIME)
			AND (
				-- Filter date reconciled. 
				-- 1. Include only bank transaction if not permanently reconciled. 
				-- 2. Or if the bank transaction is reconciled on the provided statement date. 
				dtmDateReconciled IS NULL 
				OR CAST(FLOOR(CAST(dtmDateReconciled AS FLOAT)) AS DATETIME) = CAST(FLOOR(CAST(ISNULL(@dtmDate, dtmDate) AS FLOAT)) AS DATETIME)
			)
			AND (
				-- Filter for all the bank payments and debits:
				intBankTransactionTypeID IN (@BANK_WITHDRAWAL, @MISC_CHECKS, @BANK_TRANSFER_WD, @ORIGIN_CHECKS, @ORIGIN_EFT, @ORIGIN_WITHDRAWAL, @ORIGIN_WIRE)
				OR ( dblAmount < 0 AND intBankTransactionTypeID = @BANK_TRANSACTION )
			)
END