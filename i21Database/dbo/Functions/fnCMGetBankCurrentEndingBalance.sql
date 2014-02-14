CREATE FUNCTION [dbo].[fnCMGetBankCurrentEndingBalance]
(
	@intBankAccountId INT = NULL,
	@dtmStatementDate DATETIME = NULL
)
RETURNS NUMERIC(18,6)
AS
BEGIN 

	DECLARE @dblEndingBalance AS NUMERIC(18,6)
	
	SELECT	TOP 1 
			@dblEndingBalance = ISNULL(dblStatementEndingBalance, 0)
	FROM	[dbo].[tblCMCurrentBankReconciliation]
	WHERE	intBankAccountId = @intBankAccountId

	SELECT	TOP 1 
			@dblEndingBalance = ISNULL(dblStatementEndingBalance, @dblEndingBalance)
	FROM	[dbo].[tblCMBankReconciliation]
	WHERE	intBankAccountId = @intBankAccountId
			AND CAST(FLOOR(CAST(dtmDateReconciled AS FLOAT)) AS DATETIME) = CAST(FLOOR(CAST(ISNULL(@dtmStatementDate, dtmDateReconciled) AS FLOAT)) AS DATETIME)
			AND @dtmStatementDate IS NOT NULL

	RETURN ISNULL(@dblEndingBalance, 0)

END 