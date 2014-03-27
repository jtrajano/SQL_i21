
CREATE PROCEDURE uspCMGetBankGLBalance
	@intBankAccountId INT = NULL,
	@dtmDate AS DATETIME = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF
			
SELECT	totalDebit = ISNULL(SUM(ISNULL(dblDebit, 0)), 0)
		,totalCredit = ISNULL(SUM(ISNULL(dblCredit, 0)), 0)
		,totalGL = ISNULL(SUM(ISNULL(dblDebit, 0)) - SUM(ISNULL(dblCredit, 0)), 0)
FROM	[dbo].[tblGLDetail] INNER JOIN [dbo].[tblCMBankAccount]
			ON [dbo].[tblGLDetail].intAccountId = [dbo].[tblCMBankAccount].intGLAccountId
WHERE	tblCMBankAccount.intBankAccountId = @intBankAccountId
		AND CAST(FLOOR(CAST(tblGLDetail.dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmDate, tblGLDetail.dtmDate) AS FLOAT)) AS DATETIME)