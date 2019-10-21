CREATE FUNCTION [dbo].[fnCMGetBankAccountHistoricRate]
	(
	@intBankAccountId INT,
	@dtmDate DATETIME
	)
RETURNS  DECIMAL(18,6)

AS

BEGIN
DECLARE @result DECIMAL(18,6)
DECLARE @bankBalance decimal(18,6)
DECLARE @glBalance decimal(18,6)

SELECT	@bankBalance = [dbo].[fnCMGetBankBalance] (@intBankAccountId, @dtmDate,1)
SELECT	@glBalance = ISNULL(SUM(ISNULL(dblDebit, 0)) - SUM(ISNULL(dblCredit, 0)), 0)
FROM	[dbo].[tblGLDetail] INNER JOIN [dbo].[tblCMBankAccount]
			ON [dbo].[tblGLDetail].intAccountId = [dbo].[tblCMBankAccount].intGLAccountId
WHERE	tblCMBankAccount.intBankAccountId = @intBankAccountId
		AND CAST(FLOOR(CAST(tblGLDetail.dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmDate, tblGLDetail.dtmDate) AS FLOAT)) AS DATETIME)
		AND ysnIsUnposted = 0

IF @glBalance = 0 RETURN -1
IF @bankBalance = 0 RETURN -2

SELECT @result = @glBalance/@bankBalance
RETURN @result
END



