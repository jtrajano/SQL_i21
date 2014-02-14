CREATE FUNCTION [dbo].[fnCMGetBankBeginningBalance]
(
	@intBankAccountId INT = NULL,
	@dtmDate AS DATETIME = NULL
)
RETURNS NUMERIC(18,6)
AS
BEGIN 

	DECLARE @dblBalance AS NUMERIC(18,6)

	-- Try to get the prior reconciliation and use return it as the opening balance for the current reconciliation. 
	SELECT	TOP 1 
			@dblBalance = dblStatementEndingBalance
	FROM	[dbo].[tblCMBankReconciliation]
	WHERE	intBankAccountId = @intBankAccountId
			AND CAST(FLOOR(CAST(dtmDateReconciled AS FLOAT)) AS DATETIME) < CAST(FLOOR(CAST(@dtmDate AS FLOAT)) AS DATETIME)
	ORDER BY  CAST(FLOOR(CAST(dtmDateReconciled AS FLOAT)) AS DATETIME) DESC 

	-- If there is no prior reconciliation, get the balance from the current reconciliation record.
	SELECT	TOP 1 
			@dblBalance = dblStatementOpeningBalance
	FROM	[dbo].[tblCMBankReconciliation]
	WHERE	intBankAccountId = @intBankAccountId 
			AND @dblBalance IS NULL 
			AND CAST(FLOOR(CAST(dtmDateReconciled AS FLOAT)) AS DATETIME) = CAST(FLOOR(CAST(@dtmDate AS FLOAT)) AS DATETIME)
			AND @dtmDate IS NOT NULL

	RETURN ISNULL(@dblBalance, 0)

END 