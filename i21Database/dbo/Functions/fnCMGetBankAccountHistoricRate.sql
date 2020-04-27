CREATE FUNCTION [dbo].[fnCMGetBankAccountHistoricRate]
	(
	@intBankAccountId INT,
	@dtmDate DATETIME
	)
RETURNS  DECIMAL(18,6)

AS

BEGIN
DECLARE @result DECIMAL(18,6)
DECLARE @AbsbankBalance decimal(18,6)
DECLARE @AbsglBalance decimal(18,6)

SELECT	@AbsbankBalance = SUM(ABS(dblAmount))
FROM tblCMBankTransaction 
WHERE	ysnPosted = 1
		AND ysnCheckVoid = 0
		AND intBankAccountId = @intBankAccountId
		AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmDate, dtmDate) AS FLOAT)) AS DATETIME)		


SELECT	@AbsglBalance = SUM (ABS(ISNULL(dblDebit,0) - ISNULL(dblCredit,0)))
FROM	[dbo].[tblGLDetail] INNER JOIN [dbo].[tblCMBankAccount]
			ON [dbo].[tblGLDetail].intAccountId = [dbo].[tblCMBankAccount].intGLAccountId
WHERE	tblCMBankAccount.intBankAccountId = @intBankAccountId
		AND CAST(FLOOR(CAST(tblGLDetail.dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmDate, tblGLDetail.dtmDate) AS FLOAT)) AS DATETIME)
		AND ysnIsUnposted = 0

IF @AbsglBalance = 0 RETURN -1
IF @AbsbankBalance = 0 RETURN -2

SELECT @result = @AbsglBalance/@AbsbankBalance
RETURN @result
END



