
--=====================================================================================================================================
-- 	CREATE THE STORED PROCEDURE AFTER DELETING IT
---------------------------------------------------------------------------------------------------------------------------------------
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

SELECT	TOP 1 
		@dblBalance = ISNULL(dblStatementEndingBalance, 0)
FROM	tblCMBankReconciliation
WHERE	intBankAccountID = @intBankAccountID
		AND CAST(FLOOR(CAST(dtmDateReconciled AS FLOAT)) AS DATETIME) < CAST(FLOOR(CAST(ISNULL(@dtmDate,dtmDateReconciled) AS FLOAT)) AS DATETIME)
ORDER BY  CAST(FLOOR(CAST(dtmDateReconciled AS FLOAT)) AS DATETIME) DESC 

SET @dblBalance = ISNULL(@dblBalance, 0)

SELECT	intBankAccountID = @intBankAccountID,
		dblBeginningBalance = @dblBalance

