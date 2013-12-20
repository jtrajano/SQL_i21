
--=====================================================================================================================================
-- 	CREATE THE STORED PROCEDURE AFTER DELETING IT
---------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE GetBankGLBalance
	@intBankAccountID INT = NULL,
	@dtmDate AS DATETIME = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF
			
SELECT	totalDebit = SUM(ISNULL(dblDebit, 0))
		,totalCredit = SUM(ISNULL(dblCredit, 0))
		,totalGL = SUM(ISNULL(dblDebit, 0)) - SUM(ISNULL(dblCredit, 0))
FROM	tblGLDetail INNER JOIN tblCMBankAccount
			ON tblGLDetail.intAccountID = tblCMBankAccount.intGLAccountID
WHERE	tblCMBankAccount.intBankAccountID = @intBankAccountID
		AND CAST(FLOOR(CAST(tblGLDetail.dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmDate, tblGLDetail.dtmDate) AS FLOAT)) AS DATETIME)
