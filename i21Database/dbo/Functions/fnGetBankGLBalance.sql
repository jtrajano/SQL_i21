CREATE FUNCTION [dbo].[fnGetBankGLBalance]
(
	@intBankAccountId INT = NULL,
	@dtmDate AS DATETIME = NULL
)
RETURNS NUMERIC(18,6)
AS
BEGIN 

DECLARE @totalGL AS NUMERIC(18,6)

SELECT	@totalGL = SUM(ISNULL(dblDebit, 0)) - SUM(ISNULL(dblCredit, 0))
FROM	[dbo].[tblGLDetail] GL INNER JOIN [dbo].[tblCMBankAccount] BANK
			ON GL.intAccountId = BANK.intGLAccountId
WHERE	BANK.intBankAccountId = @intBankAccountId
		AND CAST(FLOOR(CAST(GL.dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmDate, GL.dtmDate) AS FLOAT)) AS DATETIME)

RETURN ISNULL(@totalGL, 0)

END 