
CREATE PROCEDURE GetBankCurrentEndingBalance
	@intBankAccountId INT = NULL,
	@dtmStatementDate DATETIME = NULL,	
	@dblEndingBalance AS NUMERIC(18, 6) = NULL OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF
	
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

SELECT	intBankAccountId = @intBankAccountId,
		dblEndingBalance = ISNULL(@dblEndingBalance, 0)

