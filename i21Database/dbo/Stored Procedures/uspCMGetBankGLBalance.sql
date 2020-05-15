
CREATE PROCEDURE [dbo].[uspCMGetBankGLBalance]
	@intBankAccountId INT = NULL,
	@dtmDate AS DATETIME = NULL
AS

DECLARE @intDefaultCurrencyId INT

SELECT TOP 1 @intDefaultCurrencyId = intDefaultCurrencyId   FROM tblSMCompanyPreference

IF EXISTS (SELECT TOP 1 1 FROM tblCMBankAccount where intBankAccountId = @intBankAccountId and intCurrencyId = @intDefaultCurrencyId)

	SELECT	totalDebit = ISNULL(SUM(ISNULL(dblDebit, 0)), 0)
			,totalCredit = ISNULL(SUM(ISNULL(dblCredit, 0)), 0)
			,totalGL = ISNULL(SUM(ISNULL(dblDebit, 0)) - SUM(ISNULL(dblCredit, 0)), 0)
	FROM	[dbo].[tblGLDetail] INNER JOIN [dbo].[tblCMBankAccount]
				ON [dbo].[tblGLDetail].intAccountId = [dbo].[tblCMBankAccount].intGLAccountId
	WHERE	tblCMBankAccount.intBankAccountId = @intBankAccountId
			AND CAST(FLOOR(CAST(tblGLDetail.dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmDate, tblGLDetail.dtmDate) AS FLOAT)) AS DATETIME)
			AND ysnIsUnposted = 0
ELSE

	SELECT	totalDebit = ISNULL(SUM(ISNULL(dblDebitForeign, 0)), 0)
			,totalCredit = ISNULL(SUM(ISNULL(dblCreditForeign, 0)), 0)
			,totalGL = ISNULL(SUM(ISNULL(dblDebitForeign, 0)) - SUM(ISNULL(dblCreditForeign, 0)), 0)
	FROM	[dbo].[tblGLDetail] INNER JOIN [dbo].[tblCMBankAccount]
				ON [dbo].[tblGLDetail].intAccountId = [dbo].[tblCMBankAccount].intGLAccountId
	WHERE	tblCMBankAccount.intBankAccountId = @intBankAccountId
			AND CAST(FLOOR(CAST(tblGLDetail.dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmDate, tblGLDetail.dtmDate) AS FLOAT)) AS DATETIME)
			AND ysnIsUnposted = 0

GO

