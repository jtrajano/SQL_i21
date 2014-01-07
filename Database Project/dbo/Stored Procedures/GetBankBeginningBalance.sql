
CREATE PROCEDURE GetBankBeginningBalance
	@intBankAccountID INT = NULL,
	@dtmDate AS DATETIME = NULL,
	@dblBalance AS NUMERIC(18, 6) = NULL OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Try to get the prior reconciliation and use return it as the opening balance for the current reconciliation. 
SELECT	TOP 1 
		@dblBalance = dblStatementEndingBalance
FROM	tblCMBankReconciliation
WHERE	intBankAccountID = @intBankAccountID
		AND CAST(FLOOR(CAST(dtmDateReconciled AS FLOAT)) AS DATETIME) < CAST(FLOOR(CAST(@dtmDate AS FLOAT)) AS DATETIME)
ORDER BY  CAST(FLOOR(CAST(dtmDateReconciled AS FLOAT)) AS DATETIME) DESC 

-- If there is no prior reconciliation, get the balance from the current reconciliation record.
SELECT	TOP 1 
		@dblBalance = dblStatementOpeningBalance
FROM	tblCMBankReconciliation 
WHERE	intBankAccountID = @intBankAccountID 
		AND @dblBalance IS NULL 
		AND CAST(FLOOR(CAST(dtmDateReconciled AS FLOAT)) AS DATETIME) = CAST(FLOOR(CAST(@dtmDate AS FLOAT)) AS DATETIME)
		AND @dtmDate IS NOT NULL

SET @dblBalance = ISNULL(@dblBalance, 0)

SELECT	intBankAccountID = @intBankAccountID,
		dblBeginningBalance = @dblBalance
