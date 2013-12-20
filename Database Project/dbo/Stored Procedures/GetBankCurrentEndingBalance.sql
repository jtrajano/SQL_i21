
--=====================================================================================================================================
-- 	CREATE THE STORED PROCEDURE AFTER DELETING IT
---------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE GetBankCurrentEndingBalance
	@intBankAccountID INT = NULL,
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
FROM	tblCMCurrentBankReconciliation
WHERE	intBankAccountID = @intBankAccountID

SELECT	TOP 1 
		@dblEndingBalance = ISNULL(dblStatementEndingBalance, @dblEndingBalance)
FROM	tblCMBankReconciliation 
WHERE	intBankAccountID = @intBankAccountID 
		AND CAST(FLOOR(CAST(dtmDateReconciled AS FLOAT)) AS DATETIME) = CAST(FLOOR(CAST(ISNULL(@dtmStatementDate, dtmDateReconciled) AS FLOAT)) AS DATETIME)
		AND @dtmStatementDate IS NOT NULL

SELECT	intBankAccountID = @intBankAccountID,
		dblEndingBalance = ISNULL(@dblEndingBalance, 0)

