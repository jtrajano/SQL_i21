CREATE FUNCTION [dbo].[fnGetBankGLBalance]
(
	@intBankAccountId INT = NULL,
	@dtmDate AS DATETIME = NULL
)
RETURNS NUMERIC(18,6)
AS
BEGIN 

DECLARE @totalGL AS NUMERIC(18,6)
DECLARE @intDefaultCurrencyId INT, @intAccountId INT,@intCurrencyId INT
SELECT TOP 1 @intDefaultCurrencyId= intDefaultCurrencyId FROM tblSMCompanyPreference 
SELECT TOP 1 @intCurrencyId = intCurrencyId , @intAccountId = intGLAccountId FROM tblCMBankAccount WHERE intBankAccountId = @intBankAccountId


IF @intDefaultCurrencyId = @intCurrencyId

	SELECT	@totalGL = SUM(ISNULL(dblDebit, 0)) - SUM(ISNULL(dblCredit, 0))
	FROM	[dbo].[tblGLDetail] GL 
	WHERE	intAccountId = @intAccountId
			AND CAST(FLOOR(CAST(GL.dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmDate, GL.dtmDate) AS FLOAT)) AS DATETIME)
			AND ysnIsUnposted = 0
ELSE
	SELECT	@totalGL = SUM(ISNULL(dblDebitForeign, 0)) - SUM(ISNULL(dblCreditForeign, 0))
	FROM	[dbo].[tblGLDetail] GL 
	WHERE	intAccountId = @intAccountId
			AND CAST(FLOOR(CAST(GL.dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmDate, GL.dtmDate) AS FLOAT)) AS DATETIME)
			AND ysnIsUnposted = 0
	


RETURN ISNULL(@totalGL, 0)

END 